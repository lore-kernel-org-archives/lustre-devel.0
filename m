From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:58 -0500
Subject: [lustre-devel] [PATCH 370/622] lustre: llite,
 readahead: don't always use max RPC size
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-371-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

Since 64M RPC landed, @PTLRPC_MAX_BRW_PAGES will be 64M.
And we always try to use this max possible RPC size to check
whether we should avoid fast IO and trigger real context IO.

This is not good for following reasons:

(1) Since current default RPC size is still 4M,
most of system won't use 64M for most of time.

(2) Currently default readahead size per file is still 64M,
which makes fast IO always run out of all readahead pages
before next IO. This breaks what users really want for readahead
grapping pages in advance.

To fix this problem, we use 16M as a balance value if RPC smaller
than 16M, patch also fix the problem that @ras_rpc_size could not
grow bigger which is possibe in the following case:

1) set RPC to 16M
2) Set RPC to 64M

In the current logic ras->ras_rpc_size will be kept as 16M which is wrong.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12043
Lustre-commit: 7864a6854c3d ("LU-12043 llite,readahead: don't always use max RPC size")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/35033
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 3 +++
 fs/lustre/llite/rw.c             | 6 ++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index d36e01e..36b620e 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -307,6 +307,9 @@ static inline struct pcc_inode *ll_i2pcci(struct inode *inode)
 	return ll_i2info(inode)->lli_pcc_inode;
 }
 
+/* default to use at least 16M for fast read if possible */
+#define RA_REMAIN_WINDOW_MIN			MiB_TO_PAGES(16UL)
+
 /* default to about 64M of readahead on a given system. */
 #define SBI_DEFAULT_READAHEAD_MAX		MiB_TO_PAGES(64UL)
 
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index c42bbab..ad55695 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -376,7 +376,7 @@ static int ras_inside_ra_window(unsigned long idx, struct ra_io_arg *ria)
 				 * update read ahead RPC size.
 				 * NB: it's racy but doesn't matter
 				 */
-				if (ras->ras_rpc_size > ra.cra_rpc_size &&
+				if (ras->ras_rpc_size != ra.cra_rpc_size &&
 				    ra.cra_rpc_size > 0)
 					ras->ras_rpc_size = ra.cra_rpc_size;
 				/* trim it to align with optimal RPC size */
@@ -1203,6 +1203,8 @@ int ll_readpage(struct file *file, struct page *vmpage)
 		struct ll_readahead_state *ras = &fd->fd_ras;
 		struct lu_env *local_env = NULL;
 		struct inode *inode = file_inode(file);
+		unsigned long fast_read_pages =
+			max(RA_REMAIN_WINDOW_MIN, ras->ras_rpc_size);
 		struct vvp_page *vpg;
 
 		result = -ENODATA;
@@ -1245,7 +1247,7 @@ int ll_readpage(struct file *file, struct page *vmpage)
 			 * a cl_io to issue the RPC.
 			 */
 			if (ras->ras_window_start + ras->ras_window_len <
-			    ras->ras_next_readahead + PTLRPC_MAX_BRW_PAGES) {
+			    ras->ras_next_readahead + fast_read_pages) {
 				/* export the page and skip io stack */
 				vpg->vpg_ra_used = 1;
 				cl_page_export(env, page, 1);
-- 
1.8.3.1
