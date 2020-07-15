From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:09 -0400
Subject: [lustre-devel] [PATCH 28/37] lnet: libcfs: don't call
 unshare_fs_struct()
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

A kthread runs with the same fs_struct as init.
It is only helpful to unshare this if the thread
will change one of the fields in the fs_struct:
  root directory
  current working directory
  umask.

No lustre kthread changes any of these, so there is
no need to call unshare_fs_struct().

WC-bug-id: https://jira.whamcloud.com/browse/LU-9859
Lustre-commit: 9013eb2bb5492 ("LU-9859 libcfs: don't call unshare_fs_struct()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39132
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/llog.c  | 2 --
 fs/lustre/ptlrpc/import.c  | 2 --
 fs/lustre/ptlrpc/ptlrpcd.c | 1 -
 fs/lustre/ptlrpc/service.c | 3 ---
 4 files changed, 8 deletions(-)

diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index b2667d9..e172ebc 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -449,8 +449,6 @@ static int llog_process_thread_daemonize(void *arg)
 	struct lu_env env;
 	int rc;
 
-	unshare_fs_struct();
-
 	/* client env has no keys, tags is just 0 */
 	rc = lu_env_init(&env, LCT_LOCAL | LCT_MG_THREAD);
 	if (rc)
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 1b62b81..1490dcf 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -1438,8 +1438,6 @@ static int ptlrpc_invalidate_import_thread(void *data)
 {
 	struct obd_import *imp = data;
 
-	unshare_fs_struct();
-
 	CDEBUG(D_HA, "thread invalidate import %s to %s@%s\n",
 	       imp->imp_obd->obd_name, obd2cli_tgt(imp->imp_obd),
 	       imp->imp_connection->c_remote_uuid.uuid);
diff --git a/fs/lustre/ptlrpc/ptlrpcd.c b/fs/lustre/ptlrpc/ptlrpcd.c
index 533f592..b0b81cc 100644
--- a/fs/lustre/ptlrpc/ptlrpcd.c
+++ b/fs/lustre/ptlrpc/ptlrpcd.c
@@ -393,7 +393,6 @@ static int ptlrpcd(void *arg)
 	int rc = 0;
 	int exit = 0;
 
-	unshare_fs_struct();
 	if (cfs_cpt_bind(cfs_cpt_tab, pc->pc_cpt) != 0)
 		CWARN("Failed to bind %s on CPT %d\n", pc->pc_name, pc->pc_cpt);
 
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 4d5e6b3..5881e0a 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -2175,7 +2175,6 @@ static int ptlrpc_main(void *arg)
 
 	thread->t_task = current;
 	thread->t_pid = current->pid;
-	unshare_fs_struct();
 
 	if (svc->srv_cpt_bind) {
 		rc = cfs_cpt_bind(svc->srv_cptable, svcpt->scp_cpt);
@@ -2391,8 +2390,6 @@ static int ptlrpc_hr_main(void *arg)
 	if (!env)
 		return -ENOMEM;
 
-	unshare_fs_struct();
-
 	rc = cfs_cpt_bind(ptlrpc_hr.hr_cpt_table, hrp->hrp_cpt);
 	if (rc != 0) {
 		char threadname[20];
-- 
1.8.3.1
