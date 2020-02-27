From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:33 -0500
Subject: [lustre-devel] [PATCH 105/622] lustre: llite: check truncate race
 for DOM pages
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-106-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

In ll_dom_finish_open() check vmpage mapping still
exists after locking and exit otherwise. This can
happen if page has been truncated concurrently.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11275
Lustre-commit: 0f7d7b200b58 ("LU-11275 llite: check truncate race for DOM pages")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33087
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 68fb623..ae39b2c 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -496,6 +496,13 @@ void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
 			break;
 		}
 		lock_page(vmpage);
+		if (!vmpage->mapping) {
+			unlock_page(vmpage);
+			put_page(vmpage);
+			/* page was truncated */
+			rc = -ENODATA;
+			goto out_io;
+		}
 		clp = cl_page_find(env, obj, vmpage->index, vmpage,
 				   CPT_CACHEABLE);
 		if (IS_ERR(clp)) {
-- 
1.8.3.1
