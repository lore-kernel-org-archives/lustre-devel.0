From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:44 -0500
Subject: [lustre-devel] [PATCH 416/622] lustre: llite: don't check vmpage
 refcount in ll_releasepage()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-417-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

We could not use vmpage refcount to check whether page could be
released because it break invalidate_complete_page2():

See comments:
/*
 * This is like invalidate_complete_page(), except it ignores the page's
 * refcount.  We do this because invalidate_inode_pages2() needs stronger
 * invalidation guarantees, and cannot afford to leave pages behind because
 * shrink_page_list() has a temp ref on them, or because they're transiently
 * sitting in the lru_cache_add() pagevecs.
 */

So checking refcount > 3 might be wrong here, one common
case is page might be transiently in lru_cache_add().

Since we have checked whether vmpage is used by cl_page later in the
function, and vmpage will be locked before called, it should be safe
to remove vmpage refcount check.

One of problem currently is following DIO will mostly
fall back to Buffer IO:

 $ dd if=/dev/zero of=data bs=1M count=1
 $ dd if=/dev/zero of=data bs=1M count=1 oflag=direct conv=notrunc

Which is because DIO will firstly try to writeback and invalidate
clean page which fail because vmpage refcount could be 4 here.

Function calls come from:

|->generic_file_direct_write()
  |->filemap_write_and_wait_range()
    |->invalidate_inode_pages2_range()
          |->invalidate_complete_page2() If a page can not be invalidated,
                                         return 0 to fall back to buffered write.
                |->try_to_release_page()
                  |->ll_releasepage()
                        return 0 because of vmpage count is 4 > 3
   |->generic_file_buffered_write

WC-bug-id: https://jira.whamcloud.com/browse/LU-12587
Lustre-commit: e59f0c9a245f ("LU-12587 llite: don't check vmpage refcount in ll_releasepage()")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/35610
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw26.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index f5c1479..75348bf 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -119,10 +119,6 @@ static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
 	if (!obj)
 		return 1;
 
-	/* 1 for caller, 1 for cl_page and 1 for page cache */
-	if (page_count(vmpage) > 3)
-		return 0;
-
 	page = cl_vmpage_page(vmpage, obj);
 	if (!page)
 		return 1;
-- 
1.8.3.1
