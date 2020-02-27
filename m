From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:52 -0500
Subject: [lustre-devel] [PATCH 304/622] lustre: llite: hash just created
 files if lock allows
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-305-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@whamcloud.com>

If open|creat (and other intent operations later) returned a lookup bit
as part of the lock, hash the resultant dentry under this lock,
not to trigger further RPCs in subsequent lookups.

Benchmark results:

This patch can significantly improve open-create + stat on the same
client.

This patch in combination with two others:

https://review.whamcloud.com/32157
https://review.whamcloud.com/33585

Improves the 'stat' side of open-create + stat by >10x.

Without patches (master branch commit 26a7abe):

mpirun -np 24 --allow-run-as-root /work/tools/bin/mdtest -n 50000 -d /cache1/out/ -F -C -T -v -w 32k
SUMMARY rate: (of 1 iterations)
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

WC-bug-id: https://jira.whamcloud.com/browse/LU-11623
Lustre-commit: fc42cbe0e2e5 ("LU-11623 llite: hash just created files if lock allows")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33584
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/namei.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index c3e8de4..3c796bd 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -678,9 +678,9 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		if (bits & MDS_INODELOCK_LOOKUP)
 			d_lustre_revalidate(*de);
 	} else if (!it_disposition(it, DISP_OPEN_CREATE)) {
-		/* If file created on server, don't depend on parent UPDATE
-		 * lock to unhide it. It is left hidden and next lookup can
-		 * find it in ll_splice_alias.
+		/*
+		 * If file was created on the server, the dentry is revalidated
+		 * in ll_create_it if the lock allows for it.
 		 */
 		/* Check that parent has UPDATE lock. */
 		struct lookup_intent parent_it = {
@@ -1063,6 +1063,7 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 			struct lookup_intent *it, void *secctx, u32 secctxlen)
 {
 	struct inode *inode;
+	u64 bits = 0;
 	int rc = 0;
 
 	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir=" DFID "(%p), intent=%s\n",
@@ -1088,6 +1089,10 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 			return rc;
 	}
 
+	ll_set_lock_data(ll_i2sbi(dir)->ll_md_exp, inode, it, &bits);
+	if (bits & MDS_INODELOCK_LOOKUP)
+		d_lustre_revalidate(dentry);
+
 	d_instantiate(dentry, inode);
 
 	if (!(ll_i2sbi(inode)->ll_flags & LL_SBI_FILE_SECCTX))
-- 
1.8.3.1
