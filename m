From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:18:00 -0500
Subject: [lustre-devel] [PATCH 612/622] lustre: llite: Update mdc and lite
 stats on open|creat
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-613-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Faaland <faaland1@llnl.gov>

Increment "create" counter in mdc/<instance>/md_stats, and
"mknod" counter in llite/<instance>stats when an open with
the CREAT flag results in a newly created file.

The mknod counter is chosen for consistency with
patch http://review.whamcloud.com/20246
 "LU-8150 mdt: Track open+create as mknod"
but the mdc counter set does not include mknod.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11114
Lustre-commit: 4b8518ee4fa5 ("LU-11114 llite: Update mdc and lite stats on open|creat")
Signed-off-by: Olaf Faaland <faaland1@llnl.gov>
Reviewed-on: https://review.whamcloud.com/36948
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/namei.c   | 12 ++++++++++--
 fs/lustre/mdc/mdc_locks.c |  6 ++++++
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 89317db..cf2a77f 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -605,7 +605,8 @@ struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de)
 static int ll_lookup_it_finish(struct ptlrpc_request *request,
 			       struct lookup_intent *it,
 			       struct inode *parent, struct dentry **de,
-			       void *secctx, u32 secctxlen)
+			       void *secctx, u32 secctxlen,
+			       ktime_t kstart)
 {
 	struct inode *inode = NULL;
 	u64 bits = 0;
@@ -708,6 +709,11 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		}
 	}
 
+	if (it_disposition(it, DISP_OPEN_CREATE)) {
+		ll_stats_ops_tally(ll_i2sbi(parent), LPROC_LL_MKNOD,
+				   ktime_us_delta(ktime_get(), kstart));
+	}
+
 out:
 	if (rc != 0 && it->it_op & IT_OPEN) {
 		ll_intent_drop_lock(it);
@@ -722,6 +728,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 				   u32 *secctxlen,
 				   struct pcc_create_attach *pca)
 {
+	ktime_t kstart = ktime_get();
 	struct lookup_intent lookup_it = { .it_op = IT_LOOKUP };
 	struct dentry *save = dentry, *retval;
 	struct ptlrpc_request *req = NULL;
@@ -887,7 +894,8 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	ll_unlock_md_op_lsm(op_data);
 	rc = ll_lookup_it_finish(req, it, parent, &dentry,
 				 secctx ? *secctx : NULL,
-				 secctxlen ? *secctxlen : 0);
+				 secctxlen ? *secctxlen : 0,
+				kstart);
 	if (rc != 0) {
 		ll_intent_release(it);
 		retval = ERR_PTR(rc);
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 60bbae1..b252605 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -733,6 +733,12 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 			mdc_set_open_replay_data(NULL, NULL, it);
 		}
 
+		if (it_disposition(it, DISP_OPEN_CREATE) &&
+		    !it_open_error(DISP_OPEN_CREATE, it)) {
+			lprocfs_counter_incr(exp->exp_obd->obd_md_stats,
+					     LPROC_MD_CREATE);
+		}
+
 		if (body->mbo_valid & (OBD_MD_FLDIREA | OBD_MD_FLEASIZE)) {
 			void *eadata;
 
-- 
1.8.3.1
