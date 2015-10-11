From: Ryan Van Quinlan <ryan.van.quinlan@gmail.com>
Date: Sat, 10 Oct 2015 21:53:50 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: lclient: NULL comparison
	style
Message-ID: <20151011045349.GA21387@ryan-ThinkPad-T430s>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Fixes checkpatch.pl checks:
CHECK: Comparison to NULL could be written ...

Signed-off-by: Ryan Van Quinlan <ryan.van.quinlan@gmail.com>
---
 drivers/staging/lustre/lustre/lclient/glimpse.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lclient/glimpse.c b/drivers/staging/lustre/lustre/lclient/glimpse.c
index b9f2bb6..8533a1e 100644
--- a/drivers/staging/lustre/lustre/lclient/glimpse.c
+++ b/drivers/staging/lustre/lustre/lclient/glimpse.c
@@ -73,7 +73,7 @@ blkcnt_t dirty_cnt(struct inode *inode)
 	struct ccc_object *vob = cl_inode2ccc(inode);
 	void	      *results[1];
 
-	if (inode->i_mapping != NULL)
+	if (inode->i_mapping)
 		cnt += radix_tree_gang_lookup_tag(&inode->i_mapping->page_tree,
 						  results, 0, 1,
 						  PAGECACHE_TAG_DIRTY);
@@ -129,7 +129,7 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 					       current);
 			cio->cui_glimpse = 0;
 
-			if (lock == NULL)
+			if (!lock)
 				return 0;
 
 			if (IS_ERR(lock))
@@ -255,7 +255,7 @@ int cl_local_size(struct inode *inode)
 		*descr = whole_file;
 		descr->cld_obj = clob;
 		lock = cl_lock_peek(env, io, descr, "localsize", current);
-		if (lock != NULL) {
+		if (lock) {
 			cl_merge_lvb(env, inode);
 			cl_unuse(env, lock);
 			cl_lock_release(env, lock, "localsize", current);
-- 
1.9.1
