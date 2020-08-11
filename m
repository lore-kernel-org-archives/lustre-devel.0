From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:19:58 -0400
Subject: [lustre-devel] [PATCH 02/23] lustre: lov: annotate nested locking
 of obd_dev_mutex
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

obd_statfs() can call lmv_statfs() with ->obd_dev_mutex helds.
lmv_statfs will then call obd_statfs() on a different device
and ->obd_dev_mutex will be taken again.  This is a *different*
mutex, but lockdep cannot see the difference, so it complains.

We can tell lockdep not to worry in this case using
mutex_lock_interruptible_nested().

WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
Lustre-commit: 10dae4c3b68eb ("LU-9679 lov: annotate nested locking of obd_dev_mutex")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39248
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h | 8 +++++++-
 fs/lustre/lmv/lmv_obd.c       | 3 ++-
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 78f7b16..e8168bc5 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -49,6 +49,10 @@
 #define OBD_STATFS_FOR_MDT0	0x0004
 /* get aggregated statfs from MDT */
 #define OBD_STATFS_SUM		0x0008
+#define OBD_STATFS_NESTED	0x0010 /* Call while already holding
+					* obd_dev_mutex of a difference
+					* device.
+					*/
 
 /* OBD Device Declarations */
 extern rwlock_t obd_dev_lock;
@@ -945,7 +949,9 @@ static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
 	    ((obd->obd_osfs.os_state & OS_STATFS_SUM) &&
 	     !(flags & OBD_STATFS_SUM))) {
 		/* the RPC will block anyway, so avoid sending many at once */
-		rc = mutex_lock_interruptible(&obd->obd_dev_mutex);
+		rc = mutex_lock_interruptible_nested(&obd->obd_dev_mutex,
+						     (flags & OBD_STATFS_NESTED)
+						     ? SINGLE_DEPTH_NESTING : 0);
 		if (rc)
 			return rc;
 		if (obd->obd_osfs_age < max_age ||
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 4131b49..5a75c69 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1248,7 +1248,8 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 		if (!tgt || !tgt->ltd_exp)
 			continue;
 
-		rc = obd_statfs(env, tgt->ltd_exp, temp, max_age, flags);
+		rc = obd_statfs(env, tgt->ltd_exp, temp, max_age,
+				flags | OBD_STATFS_NESTED);
 		if (rc) {
 			CERROR("%s: can't stat MDS #%d: rc = %d\n",
 			       tgt->ltd_exp->exp_obd->obd_name, i, rc);
-- 
1.8.3.1
