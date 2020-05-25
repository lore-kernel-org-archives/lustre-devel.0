From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:14 -0400
Subject: [lustre-devel] [PATCH 37/45] lustre: osc: Ensure immediate
 departure of sync write pages
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-38-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@whamcloud.com>

Except for the case of direct-io and server-lock, we are
hold potentially multiple locks that are next to impossible
to find and cross reference.
So instead just send it all right away - should only
be a factor in rare cases of out of quota or close to out
of space.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13131
Lustre-commit: 13b7cf4fabdd5 ("LU-13131 osc: Ensure immediate departure of sync write pages")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38453
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_cache.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index c7f1502..5049aaa 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2015,7 +2015,6 @@ static unsigned int get_write_extents(struct osc_object *obj,
 	while ((ext = list_first_entry_or_null(&obj->oo_hp_exts,
 					       struct osc_extent,
 					       oe_link))) {
-		LASSERT(ext->oe_state == OES_CACHE);
 		if (!try_to_add_extent_for_io(cli, ext, &data))
 			return data.erd_page_count;
 		EASSERT(ext->oe_nr_pages <= data.erd_max_pages, ext);
@@ -2701,7 +2700,22 @@ int osc_queue_sync_pages(const struct lu_env *env, const struct cl_io *io,
 	/* Reuse the initial refcount for RPC, don't drop it */
 	osc_extent_state_set(ext, OES_LOCK_DONE);
 	if (!ext->oe_rw) { /* write */
-		list_add_tail(&ext->oe_link, &obj->oo_urgent_exts);
+		if (!ext->oe_srvlock && !ext->oe_dio) {
+			/* The most likely case here is from lack of grants
+			 * so we are either out of quota or out of space.
+			 * Since this means we are holding locks across
+			 * potentially multi-striped IO, we must send out
+			 * everything out instantly to avoid prolonged
+			 * waits resulting in lock eviction (likely since
+			 * the extended wait in osc_cache_enter() did not
+			 * yield any additional grant due to a timeout.
+			 * LU-13131
+			 */
+			ext->oe_hp = 1;
+			list_add_tail(&ext->oe_link, &obj->oo_hp_exts);
+		} else {
+			list_add_tail(&ext->oe_link, &obj->oo_urgent_exts);
+		}
 		osc_update_pending(obj, OBD_BRW_WRITE, page_count);
 	} else {
 		list_add_tail(&ext->oe_link, &obj->oo_reading_exts);
-- 
1.8.3.1
