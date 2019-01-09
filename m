From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:02 +1100
Subject: [lustre-devel] [PATCH 19/29] lustre: osc_cache: convert while to
 for in get_write_extents()
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504232.26726.5168102908572630267.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This 'while' loop is really a 'for' loop in disguise.
So change it to 'for'.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 5666f384ac6c..db28cc4d5ae8 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2012,19 +2012,16 @@ static unsigned int get_write_extents(struct osc_object *obj,
 			break;
 	}
 
-	ext = first_extent(obj);
-	while (ext) {
+	for (ext = first_extent(obj);
+	     ext;
+	     ext = next_extent(ext)) {
 		if ((ext->oe_state != OES_CACHE) ||
 		    /* this extent may be already in current rpclist */
-		    (!list_empty(&ext->oe_link) && ext->oe_owner)) {
-			ext = next_extent(ext);
+		    (!list_empty(&ext->oe_link) && ext->oe_owner))
 			continue;
-		}
 
 		if (!try_to_add_extent_for_io(cli, ext, &data))
 			return data.erd_page_count;
-
-		ext = next_extent(ext);
 	}
 	return data.erd_page_count;
 }
