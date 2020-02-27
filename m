From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:37 -0500
Subject: [lustre-devel] [PATCH 169/622] lustre: llite: protect reading
 inode->i_data.nrpages
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-170-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@whamcloud.com>

truncate_inode_pages() looks up pages in the radix tree without
lock, and could miss finding pages removed from the radix tree
by __remove_mapping(), so that after calling truncate_inode_pages()
we need to read the nrpages of the inode->i_data with the protection
of tree_lock.

Since it could still be in the race window of __remove_mapping()->
__delete_from_page_cache()->page_cache_tree_delte(), before the
nrpages being decreased.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11582
Lustre-commit: 04c172b68676 ("LU-11582 llite: protect reading inode->i_data.nrpages")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33639
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 25 +++++++++++++++++++++----
 1 file changed, 21 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index ed2d1c6..b766402 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2011,6 +2011,8 @@ int ll_read_inode2(struct inode *inode, void *opaque)
 void ll_delete_inode(struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
+	struct address_space *mapping = &inode->i_data;
+	unsigned long nrpages;
 
 	if (S_ISREG(inode->i_mode) && lli->lli_clob)
 		/* discard all dirty pages before truncating them, required by
@@ -2019,11 +2021,26 @@ void ll_delete_inode(struct inode *inode)
 		cl_sync_file_range(inode, 0, OBD_OBJECT_EOF,
 				   CL_FSYNC_LOCAL, 1);
 
-	truncate_inode_pages_final(&inode->i_data);
+	truncate_inode_pages_final(mapping);
 
-	LASSERTF(!inode->i_data.nrpages,
-		 "inode=" DFID "(%p) nrpages=%lu, see http://jira.whamcloud.com/browse/LU-118\n",
-		 PFID(ll_inode2fid(inode)), inode, inode->i_data.nrpages);
+	/* Workaround for LU-118: Note nrpages may not be totally updated when
+	 * truncate_inode_pages() returns, as there can be a page in the process
+	 * of deletion (inside __delete_from_page_cache()) in the specified
+	 * range. Thus mapping->nrpages can be non-zero when this function
+	 * returns even after truncation of the whole mapping.  Only do this if
+	 * npages isn't already zero.
+	 */
+	nrpages = mapping->nrpages;
+	if (nrpages) {
+		xa_lock_irq(&mapping->i_pages);
+		nrpages = mapping->nrpages;
+		xa_unlock_irq(&mapping->i_pages);
+	} /* Workaround end */
+
+	LASSERTF(nrpages == 0,
+		 "%s: inode="DFID"(%p) nrpages=%lu, see https://jira.whamcloud.com/browse/LU-118\n",
+		 ll_get_fsname(inode->i_sb, NULL, 0),
+		 PFID(ll_inode2fid(inode)), inode, nrpages);
 
 	ll_clear_inode(inode);
 	clear_inode(inode);
-- 
1.8.3.1
