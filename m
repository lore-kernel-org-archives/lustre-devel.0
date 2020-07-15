From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:59 -0400
Subject: [lustre-devel] [PATCH 18/37] lustre: llite: Fix lock ordering in
 pagevec_dirty
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shaun Tancheff <shaun.tancheff@hpe.com>

In vvp_set_pagevec_dirty lock order between i_pages and
lock_page_memcg was inverted with the expectation that
no other users would conflict.

However in vvp_page_completion_write the call to
test_clear_page_writeback does expect to be able
to lock_page_memcg then lock i_pages which appears
to conflict with the original analysis.

The reported case shows as RCU stalls with
vvp_set_pagevec_dirty blocked attempting to lock i_pages.

Fixes: f8a5fb036ae ("lustre: vvp: dirty pages with pagevec")
HPE-bug-id: LUS-8798
WC-bug-id: https://jira.whamcloud.com/browse/LU-13746
Lustre-commit: c4ed9b0fb1013 ("LU-13476 llite: Fix lock ordering in pagevec_dirty")
Signed-off-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-on: https://review.whamcloud.com/38317
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_io.c | 34 +++++++++++++++++++++-------------
 1 file changed, 21 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 8edd3c1..7627431 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -897,19 +897,31 @@ void vvp_set_pagevec_dirty(struct pagevec *pvec)
 	struct page *page = pvec->pages[0];
 	struct address_space *mapping = page->mapping;
 	unsigned long flags;
+	unsigned long skip_pages = 0;
 	int count = pagevec_count(pvec);
 	int dirtied = 0;
-	int i = 0;
-
-	/* From set_page_dirty */
-	for (i = 0; i < count; i++)
-		ClearPageReclaim(pvec->pages[i]);
+	int i;
 
+	BUILD_BUG_ON(PAGEVEC_SIZE > BITS_PER_LONG);
 	LASSERTF(page->mapping,
 		 "mapping must be set. page %p, page->private (cl_page) %p\n",
 		 page, (void *) page->private);
 
-	/* Rest of code derived from __set_page_dirty_nobuffers */
+	for (i = 0; i < count; i++) {
+		page = pvec->pages[i];
+
+		ClearPageReclaim(page);
+
+		lock_page_memcg(page);
+		if (TestSetPageDirty(page)) {
+			/* page is already dirty .. no extra work needed
+			 * set a flag for the i'th page to be skipped
+			 */
+			unlock_page_memcg(page);
+			skip_pages |= (1 << i);
+		}
+	}
+
 	xa_lock_irqsave(&mapping->i_pages, flags);
 
 	/* Notes on differences with __set_page_dirty_nobuffers:
@@ -920,17 +932,13 @@ void vvp_set_pagevec_dirty(struct pagevec *pvec)
 	 * 3. No mapping is impossible. (Race w/truncate mentioned in
 	 * dirty_nobuffers should be impossible because we hold the page lock.)
 	 * 4. All mappings are the same because i/o is only to one file.
-	 * 5. We invert the lock order on lock_page_memcg(page) and the mapping
-	 * xa_lock, but this is the only function that should use that pair of
-	 * locks and it can't race because Lustre locks pages throughout i/o.
 	 */
 	for (i = 0; i < count; i++) {
 		page = pvec->pages[i];
-		lock_page_memcg(page);
-		if (TestSetPageDirty(page)) {
-			unlock_page_memcg(page);
+		/* if the i'th page was unlocked above, skip it here */
+		if ((skip_pages >> i) & 1)
 			continue;
-		}
+
 		LASSERTF(page->mapping == mapping,
 			 "all pages must have the same mapping.  page %p, mapping %p, first mapping %p\n",
 			 page, page->mapping, mapping);
-- 
1.8.3.1
