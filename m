From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:04 -0500
Subject: [lustre-devel] [PATCH 376/622] lustre: obdclass: protect imp_sec
 using rwlock_t
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-377-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Dongyang <dongyangli@ddn.com>

We've seen spinlock contention on imp_lock in
sptlrpc_import_sec_ref(), introduce a new rwlock
imp_sec_lock to protect imp_sec instead of using imp_lock.

This patch also removes imp_sec_mutex from obd_import,
which is not needed, to avoid confusion between
imp_sec_lock/mutex.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11775
Lustre-commit: 8ed361345154 ("LU-11775 obdclass: protect imp_sec using rwlock_t")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/33861
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h |  2 +-
 fs/lustre/obdclass/genops.c       |  2 +-
 fs/lustre/ptlrpc/sec.c            | 15 ++++++---------
 fs/lustre/ptlrpc/sec_config.c     |  4 ++--
 4 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index f16d621..ff171d1 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -206,7 +206,7 @@ struct obd_import {
 	 * @{
 	 */
 	struct ptlrpc_sec	       *imp_sec;
-	struct mutex			imp_sec_mutex;
+	rwlock_t			imp_sec_lock;
 	time64_t			imp_sec_expire;
 	/** @} */
 
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index fd9dd96..2b1175f 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -997,7 +997,7 @@ struct obd_import *class_new_import(struct obd_device *obd)
 	imp->imp_last_success_conn = 0;
 	imp->imp_state = LUSTRE_IMP_NEW;
 	imp->imp_obd = class_incref(obd, "import", imp);
-	mutex_init(&imp->imp_sec_mutex);
+	rwlock_init(&imp->imp_sec_lock);
 	init_waitqueue_head(&imp->imp_recovery_waitq);
 	INIT_WORK(&imp->imp_zombie_work, obd_zombie_imp_cull);
 
diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index 789b5cb..d82809f 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -303,13 +303,13 @@ static int import_sec_check_expire(struct obd_import *imp)
 {
 	int adapt = 0;
 
-	spin_lock(&imp->imp_lock);
+	write_lock(&imp->imp_sec_lock);
 	if (imp->imp_sec_expire &&
 	    imp->imp_sec_expire < ktime_get_real_seconds()) {
 		adapt = 1;
 		imp->imp_sec_expire = 0;
 	}
-	spin_unlock(&imp->imp_lock);
+	write_unlock(&imp->imp_sec_lock);
 
 	if (!adapt)
 		return 0;
@@ -1317,9 +1317,9 @@ struct ptlrpc_sec *sptlrpc_import_sec_ref(struct obd_import *imp)
 {
 	struct ptlrpc_sec *sec;
 
-	spin_lock(&imp->imp_lock);
+	read_lock(&imp->imp_sec_lock);
 	sec = sptlrpc_sec_get(imp->imp_sec);
-	spin_unlock(&imp->imp_lock);
+	read_unlock(&imp->imp_sec_lock);
 
 	return sec;
 }
@@ -1332,10 +1332,10 @@ static void sptlrpc_import_sec_install(struct obd_import *imp,
 
 	LASSERT_ATOMIC_POS(&sec->ps_refcount);
 
-	spin_lock(&imp->imp_lock);
+	write_lock(&imp->imp_sec_lock);
 	old_sec = imp->imp_sec;
 	imp->imp_sec = sec;
-	spin_unlock(&imp->imp_lock);
+	write_unlock(&imp->imp_sec_lock);
 
 	if (old_sec) {
 		sptlrpc_sec_kill(old_sec);
@@ -1455,8 +1455,6 @@ int sptlrpc_import_sec_adapt(struct obd_import *imp,
 		       sptlrpc_flavor2name(&sf, str, sizeof(str)));
 	}
 
-	mutex_lock(&imp->imp_sec_mutex);
-
 	newsec = sptlrpc_sec_create(imp, svc_ctx, &sf, sp);
 	if (newsec) {
 		sptlrpc_import_sec_install(imp, newsec);
@@ -1467,7 +1465,6 @@ int sptlrpc_import_sec_adapt(struct obd_import *imp,
 		rc = -EPERM;
 	}
 
-	mutex_unlock(&imp->imp_sec_mutex);
 out:
 	sptlrpc_sec_put(sec);
 	return rc;
diff --git a/fs/lustre/ptlrpc/sec_config.c b/fs/lustre/ptlrpc/sec_config.c
index e4b1a075..9ced6c7 100644
--- a/fs/lustre/ptlrpc/sec_config.c
+++ b/fs/lustre/ptlrpc/sec_config.c
@@ -846,11 +846,11 @@ void sptlrpc_conf_client_adapt(struct obd_device *obd)
 
 	imp = obd->u.cli.cl_import;
 	if (imp) {
-		spin_lock(&imp->imp_lock);
+		write_lock(&imp->imp_sec_lock);
 		if (imp->imp_sec)
 			imp->imp_sec_expire = ktime_get_real_seconds() +
 				SEC_ADAPT_DELAY;
-		spin_unlock(&imp->imp_lock);
+		write_unlock(&imp->imp_sec_lock);
 	}
 
 	up_read(&obd->u.cli.cl_sem);
-- 
1.8.3.1
