From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Oct 2017 15:59:27 +1100
Subject: [lustre-devel] [PATCH 01/10] staging: lustre: use list_last_entry
 to simplify fld_cache_shrink
In-Reply-To: <150933945578.22133.8029060522107378499.stgit@noble>
References: <150933945578.22133.8029060522107378499.stgit@noble>
Message-ID: <150933956703.22133.5329157273101330596.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/fld/fld_cache.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index b723ece02eff..c01709cd22a1 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -212,19 +212,18 @@ static inline void fld_cache_entry_add(struct fld_cache *cache,
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
