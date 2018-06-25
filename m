From: NeilBrown <neilb@suse.com>
Date: Mon, 25 Jun 2018 10:03:26 +1000
Subject: [lustre-devel] [PATCH 3/3] lustre: discard truncate_complete_page()
In-Reply-To: <87in67ag28.fsf@notabene.neil.brown.name>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669032.10587.11474850109829193046.stgit@noble>
 <alpine.LFD.2.21.1806160115430.15679@casper.infradead.org>
 <87y3ffft80.fsf@notabene.neil.brown.name>
 <61C2F92E-8F88-49C6-83FB-F3013289265C@linuxhacker.ru>
 <877emwg8ao.fsf@notabene.neil.brown.name>
 <87lgb3ag3k.fsf@notabene.neil.brown.name>
 <87in67ag28.fsf@notabene.neil.brown.name>
Message-ID: <87fu1bag1d.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


This function is no longer used, so remove it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/lustre/include/lustre_patchless_compat.h      | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h b/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
index 298476ea7557..dca1e3dbd183 100644
--- a/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
+++ b/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
@@ -41,22 +41,6 @@
 #include <linux/hash.h>
 #include <linux/pagemap.h>
 
-#define ll_delete_from_page_cache(page) delete_from_page_cache(page)
-
-static inline void
-truncate_complete_page(struct address_space *mapping, struct page *page)
-{
-	if (page->mapping != mapping)
-		return;
-
-	if (PagePrivate(page))
-		page->mapping->a_ops->invalidatepage(page, 0, PAGE_SIZE);
-
-	cancel_dirty_page(page);
-	ClearPageMappedToDisk(page);
-	ll_delete_from_page_cache(page);
-}
-
 #ifndef ATTR_CTIME_SET
 /*
  * set ATTR_CTIME_SET to a high value to avoid any risk of collision with other
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180625/bb5e4e4c/attachment.sig>
