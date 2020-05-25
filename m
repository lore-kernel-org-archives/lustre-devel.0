From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:20 -0400
Subject: [lustre-devel] [PATCH 43/45] lustre: llite: check if page truncated
 in ll_write_begin()
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-44-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

See following function flows:

CPU0					CPU1:
|->grab_cache_page_nowait
  |->find_get_page
    |->__find_get_page (page unlocked)
					|->truncate page
    |->trylock_page -->page might has been truncated after

So it is possible that page might has been truncated after
grab_cache_page_nowait() return even page lock is held.

We need check wheather vmpage->mapping change in ll_write_begin()
otherwise, we will have truncated page with NULL mapping, which
will trigger assertions in vvp_set_pagevec_dirty().

This patch also fix assertion string doesn't end in newline.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13493
Lustre-commit: 985de582849df ("LU-13493 llite: check if page truncated in ll_write_begin()")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/38425
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw26.c   | 16 +++++++++++++---
 fs/lustre/llite/vvp_io.c |  2 +-
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index dd388b9..7abf3fc 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -453,11 +453,12 @@ static int ll_prepare_partial_page(const struct lu_env *env, struct cl_io *io,
 	return result;
 }
 
-static int ll_tiny_write_begin(struct page *vmpage)
+static int ll_tiny_write_begin(struct page *vmpage,
+			       struct address_space *mapping)
 {
 	/* Page must be present, up to date, dirty, and not in writeback. */
 	if (!vmpage || !PageUptodate(vmpage) || !PageDirty(vmpage) ||
-	    PageWriteback(vmpage))
+	    PageWriteback(vmpage) || vmpage->mapping != mapping)
 		return -ENODATA;
 
 	return 0;
@@ -483,7 +484,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 	lcc = ll_cl_find(file);
 	if (!lcc) {
 		vmpage = grab_cache_page_nowait(mapping, index);
-		result = ll_tiny_write_begin(vmpage);
+		result = ll_tiny_write_begin(vmpage, mapping);
 		goto out;
 	}
 
@@ -547,6 +548,15 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 		}
 	}
 
+	/* page was truncated */
+	if (mapping != vmpage->mapping) {
+		CDEBUG(D_VFSTRACE, "page: %lu was truncated\n", index);
+		unlock_page(vmpage);
+		put_page(vmpage);
+		vmpage = NULL;
+		goto again;
+	}
+
 	page = cl_page_find(env, clob, vmpage->index, vmpage, CPT_CACHEABLE);
 	if (IS_ERR(page)) {
 		result = PTR_ERR(page);
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index d755551..371d988 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -899,7 +899,7 @@ void vvp_set_pagevec_dirty(struct pagevec *pvec)
 		ClearPageReclaim(pvec->pages[i]);
 
 	LASSERTF(page->mapping,
-		 "mapping must be set. page %p, page->private (cl_page) %p",
+		 "mapping must be set. page %p, page->private (cl_page) %p\n",
 		 page, (void *) page->private);
 
 	/* Rest of code derived from __set_page_dirty_nobuffers */
-- 
1.8.3.1
