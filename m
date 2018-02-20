From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:37 +1100
Subject: [lustre-devel] [PATCH 02/21] staging: lustre: opencode
 cfs_cap_{raise, lower, raised}
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341760.25814.3463876381688003123.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Each of these functions is used precisely once, so having
a separate exported function seems like overkill.

cfs_cap_raised() is trivial - one line.
cfs_cap_raise() and cfs_cap_lower() are used as a pair
which is more effectively implemented with
override_cred() / revert_creds().
---
 .../staging/lustre/include/linux/libcfs/curproc.h  |    3 --
 .../lustre/lnet/libcfs/linux/linux-curproc.c       |   30 --------------------
 drivers/staging/lustre/lustre/obdclass/llog.c      |   18 ++++++++----
 3 files changed, 12 insertions(+), 39 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/curproc.h b/drivers/staging/lustre/include/linux/libcfs/curproc.h
index cdc549e2979f..51f2179b7534 100644
--- a/drivers/staging/lustre/include/linux/libcfs/curproc.h
+++ b/drivers/staging/lustre/include/linux/libcfs/curproc.h
@@ -66,9 +66,6 @@ typedef u32 cfs_cap_t;
 			 BIT(CAP_SYS_BOOT) |	\
 			 BIT(CAP_SYS_RESOURCE))
 
-void cfs_cap_raise(cfs_cap_t cap);
-void cfs_cap_lower(cfs_cap_t cap);
-int cfs_cap_raised(cfs_cap_t cap);
 cfs_cap_t cfs_curproc_cap_pack(void);
 
 /* __LIBCFS_CURPROC_H__ */
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
index 1d8949f1a4fa..6b75c5cdc3ec 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-curproc.c
@@ -52,36 +52,6 @@
  * for Linux kernel.
  */
 
-void cfs_cap_raise(cfs_cap_t cap)
-{
-	struct cred *cred;
-
-	cred = prepare_creds();
-	if (cred) {
-		cap_raise(cred->cap_effective, cap);
-		commit_creds(cred);
-	}
-}
-EXPORT_SYMBOL(cfs_cap_raise);
-
-void cfs_cap_lower(cfs_cap_t cap)
-{
-	struct cred *cred;
-
-	cred = prepare_creds();
-	if (cred) {
-		cap_lower(cred->cap_effective, cap);
-		commit_creds(cred);
-	}
-}
-EXPORT_SYMBOL(cfs_cap_lower);
-
-int cfs_cap_raised(cfs_cap_t cap)
-{
-	return cap_raised(current_cap(), cap);
-}
-EXPORT_SYMBOL(cfs_cap_raised);
-
 static void cfs_kernel_cap_pack(kernel_cap_t kcap, cfs_cap_t *cap)
 {
 	/* XXX lost high byte */
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index aa48b3d2199e..934f067adb14 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -466,7 +466,7 @@ int llog_open(const struct lu_env *env, struct llog_ctxt *ctxt,
 	      struct llog_handle **lgh, struct llog_logid *logid,
 	      char *name, enum llog_open_param open_param)
 {
-	int	 raised;
+	const struct cred *old_cred = NULL;
 	int	 rc;
 
 	LASSERT(ctxt);
@@ -483,12 +483,18 @@ int llog_open(const struct lu_env *env, struct llog_ctxt *ctxt,
 	(*lgh)->lgh_ctxt = ctxt;
 	(*lgh)->lgh_logops = ctxt->loc_logops;
 
-	raised = cfs_cap_raised(CAP_SYS_RESOURCE);
-	if (!raised)
-		cfs_cap_raise(CAP_SYS_RESOURCE);
+	if (cap_raised(current_cap(), CAP_SYS_RESOURCE)) {
+		struct cred *cred = prepare_creds();
+
+		if (cred) {
+			cap_raise(cred->cap_effective, CAP_SYS_RESOURCE);
+			old_cred = override_creds(cred);
+		}
+	}
 	rc = ctxt->loc_logops->lop_open(env, *lgh, logid, name, open_param);
-	if (!raised)
-		cfs_cap_lower(CAP_SYS_RESOURCE);
+	if (old_cred)
+		revert_creds(old_cred);
+
 	if (rc) {
 		llog_free_handle(*lgh);
 		*lgh = NULL;
