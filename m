From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:02 +1100
Subject: [lustre-devel] [PATCH 17/29] lustre: osc_cache: simplify list walk
 in get_write_extents().
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504211.26726.81439906958866826.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This iteration is exactly what list_first_entry_or_null() is for.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index d2d5867156ad..14e6efb4b80b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1982,9 +1982,9 @@ static unsigned int get_write_extents(struct osc_object *obj,
 	};
 
 	assert_osc_object_is_locked(obj);
-	while (!list_empty(&obj->oo_hp_exts)) {
-		ext = list_entry(obj->oo_hp_exts.next, struct osc_extent,
-				 oe_link);
+	while ((ext = list_first_entry_or_null(&obj->oo_hp_exts,
+					       struct osc_extent,
+					       oe_link))) {
 		LASSERT(ext->oe_state == OES_CACHE);
 		if (!try_to_add_extent_for_io(cli, ext, &data))
 			return data.erd_page_count;
