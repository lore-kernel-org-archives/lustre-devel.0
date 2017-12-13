From: NeilBrown <neilb@suse.com>
Date: Wed, 13 Dec 2017 14:15:54 +1100
Subject: [lustre-devel] [PATCH 01/12] staging: lustre: use list_last_entry
 to simplify fld_cache_shrink
In-Reply-To: <151313493380.27582.16490205348451477393.stgit@noble>
References: <151313493380.27582.16490205348451477393.stgit@noble>
Message-ID: <151313495480.27582.15094470661680270941.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

Using list_empty() and list_last_entry() makes the code clearer,
and allows a local variable to be discarded.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/fld/fld_cache.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index 7d6a7106c0a5..ecf8b9e1ed5c 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -213,19 +213,18 @@ static inline void fld_cache_entry_add(struct fld_cache *cache,
  */
 static int fld_cache_shrink(struct fld_cache *cache)
 {
-	struct fld_cache_entry *flde;
-	struct list_head *curr;
 	int num = 0;
 
 	if (cache->fci_cache_count < cache->fci_cache_size)
 		return 0;
 
-	curr = cache->fci_lru.prev;
-
 	while (cache->fci_cache_count + cache->fci_threshold >
-	       cache->fci_cache_size && curr != &cache->fci_lru) {
-		flde = list_entry(curr, struct fld_cache_entry, fce_lru);
-		curr = curr->prev;
+	       cache->fci_cache_size &&
+	       !list_empty(&cache->fci_lru)) {
+		struct fld_cache_entry *flde =
+			list_last_entry(&cache->fci_lru,
+					struct fld_cache_entry, fce_lru);
+
 		fld_cache_entry_delete(cache, flde);
 		num++;
 	}
