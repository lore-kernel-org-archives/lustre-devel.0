From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:14 -0400
Subject: [lustre-devel] [PATCH 055/151] lustre: misc: replace LASSERT() with
 BUILD_BUG_ON()
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-56-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Some code consistency checks are being done at runtime with
LASSERT() when they could be done at compile time with
BUILD_BUG_ON(). This might miss defects introduced into the
code if that particular code path is not exercised during testing.

Replace LASSERT() with BUILD_BUG_ON() in such cases.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10046
Lustre-commit: 558c93dc56dc ("LU-10046 misc: replace LASSERT() with CLASSERT()")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/29256
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c           | 6 +++---
 fs/lustre/ptlrpc/client.c       | 2 +-
 fs/lustre/ptlrpc/lproc_ptlrpc.c | 1 +
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index ba53c1e..8968110 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1229,9 +1229,9 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		BUILD_BUG_ON(sizeof(struct lov_user_md_v3) <=
 			     sizeof(struct lov_comp_md_v1));
-		LASSERT(sizeof(lumv3) == sizeof(*lumv3p));
-		LASSERT(sizeof(lumv3.lmm_objects[0]) ==
-			sizeof(lumv3p->lmm_objects[0]));
+		BUILD_BUG_ON(sizeof(lumv3) != sizeof(*lumv3p));
+		BUILD_BUG_ON(sizeof(lumv3.lmm_objects[0]) !=
+			     sizeof(lumv3p->lmm_objects[0]));
 		/* first try with v1 which is smaller than v3 */
 		if (copy_from_user(lumv1, lumv1p, sizeof(*lumv1)))
 			return -EFAULT;
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index fc909a8..e0b2b91 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -2934,7 +2934,7 @@ int ptlrpc_replay_req(struct ptlrpc_request *req)
 
 	LASSERT(req->rq_import->imp_state == LUSTRE_IMP_REPLAY);
 
-	LASSERT(sizeof(*aa) <= sizeof(req->rq_async_args));
+	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
 	aa = ptlrpc_req_async_args(req);
 	memset(aa, 0, sizeof(*aa));
 
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index bc5dc3f..937a413 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -449,6 +449,7 @@ static void nrs_policy_get_info_locked(struct ptlrpc_nrs_policy *policy,
 {
 	assert_spin_locked(&policy->pol_nrs->nrs_lock);
 
+	BUILD_BUG_ON(sizeof(info->pi_arg) != sizeof(policy->pol_arg));
 	memcpy(info->pi_name, policy->pol_desc->pd_name, NRS_POL_NAME_MAX);
 
 	info->pi_fallback = !!(policy->pol_flags & PTLRPC_NRS_FL_FALLBACK);
-- 
1.8.3.1
