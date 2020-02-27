From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:51 -0500
Subject: [lustre-devel] [PATCH 303/622] lustre: llite: Revalidate dentries
 in ll_intent_file_open
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-304-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@whamcloud.com>

We might get a lookup lock in response to our open request and we
definitely want to ensure that our dentry is valid, so it could
actually be matched by dcache code in future operations.

Benchmark results:

This patch can significantly improve open-create + stat on the same
client.

This patch in combination with two others:

https://review.whamcloud.com/#/c/33584
https://review.whamcloud.com/#/c/33585

Improves the 'stat' side of open-create + stat by >10x.

Without patches (master branch commit 26a7abe):

mpirun -np 24 --allow-run-as-root /work/tools/bin/mdtest -n 50000 -d /cache1/out/ -F -C -T -v -w 32k

   Operation                      Max            Min           Mean        Std Dev
   ---------                      ---            ---           ----        -------
   File creation     :       3838.205       3838.204       3838.204          0.000
   File stat         :      33459.289      33459.249      33459.271          0.011
   File read         :          0.000          0.000          0.000          0.000
   File removal      :          0.000          0.000          0.000          0.000
   Tree creation     :       3146.841       3146.841       3146.841          0.000
   Tree removal      :          0.000          0.000          0.000          0.000

With the three patches:

mpirun -np 24 --allow-run-as-root /work/tools/bin/mdtest -n 50000 -d /cache1/out/ -F -C -T -v -w 32k
SUMMARY rate: (of 1 iterations)
   Operation                      Max            Min           Mean        Std Dev
   ---------                      ---            ---           ----        -------
   File creation     :       3822.440       3822.439       3822.440          0.000
   File stat         :     350620.140     350615.980     350617.193          1.051
   File read         :          0.000          0.000          0.000          0.000
   File removal      :          0.000          0.000          0.000          0.000
   Tree creation     :       2076.727       2076.727       2076.727          0.000
   Tree removal      :          0.000          0.000          0.000          0.000

Note 33K stats/second vs 350K stats/second.

ls -l time of the mdtest directory is also reduced from 23.5 seconds to
5.8 seconds.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10948
Lustre-commit: 14ca3157b21d ("LU-10948 llite: Revalidate dentries in ll_intent_file_open")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32157
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 34 ++++++++++++++++++++--------------
 1 file changed, 20 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index e9d0ff9..191b0f9 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -419,25 +419,12 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 	struct page *vmpage;
 	struct niobuf_remote *rnb;
 	char *data;
-	struct lustre_handle lockh;
-	struct ldlm_lock *lock;
 	unsigned long index, start;
 	struct niobuf_local lnb;
-	bool dom_lock = false;
 
 	if (!obj)
 		return;
 
-	if (it->it_lock_mode != 0) {
-		lockh.cookie = it->it_lock_handle;
-		lock = ldlm_handle2lock(&lockh);
-		if (lock)
-			dom_lock = ldlm_has_dom(lock);
-		LDLM_LOCK_PUT(lock);
-	}
-	if (!dom_lock)
-		return;
-
 	if (!req_capsule_has_field(&req->rq_pill, &RMF_NIOBUF_INLINE,
 				   RCL_SERVER))
 		return;
@@ -576,8 +563,27 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 	rc = ll_prep_inode(&inode, req, NULL, itp);
 
 	if (!rc && itp->it_lock_mode) {
-		ll_dom_finish_open(d_inode(de), req, itp);
+		struct lustre_handle handle = {.cookie = itp->it_lock_handle};
+		struct ldlm_lock *lock;
+		bool has_dom_bit = false;
+
+		/* If we got a lock back and it has a LOOKUP bit set,
+		 * make sure the dentry is marked as valid so we can find it.
+		 * We don't need to care about actual hashing since other bits
+		 * of kernel will deal with that later.
+		 */
+		lock = ldlm_handle2lock(&handle);
+		if (lock) {
+			has_dom_bit = ldlm_has_dom(lock);
+			if (lock->l_policy_data.l_inodebits.bits &
+			    MDS_INODELOCK_LOOKUP)
+				d_lustre_revalidate(de);
+
+			LDLM_LOCK_PUT(lock);
+		}
 		ll_set_lock_data(sbi->ll_md_exp, inode, itp, NULL);
+		if (has_dom_bit)
+			ll_dom_finish_open(inode, req, itp);
 	}
 
 out:
-- 
1.8.3.1
