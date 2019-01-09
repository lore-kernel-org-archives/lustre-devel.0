From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:02 +1100
Subject: [lustre-devel] [PATCH 20/29] lustre: osc_cache: don't drop a lock
 we didn't take.
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504236.26726.14318399777937714593.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Dropping a lock in a function which didn't take the lock
is best avoided as it makes it difficult to understand the code.
Sometimes it is unavoidable, but not in this case.

There is very little code in the (only) calling function which is also
locked, so we can move that code into the called function, and
then just take the lock inside the called function - the same function
which drops it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |   78 ++++++++++++-------------
 1 file changed, 38 insertions(+), 40 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index db28cc4d5ae8..863884cac028 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2029,7 +2029,6 @@ static unsigned int get_write_extents(struct osc_object *obj,
 static int
 osc_send_write_rpc(const struct lu_env *env, struct client_obd *cli,
 		   struct osc_object *osc)
-	__must_hold(osc)
 {
 	LIST_HEAD(rpclist);
 	struct osc_extent *ext;
@@ -2039,13 +2038,16 @@ osc_send_write_rpc(const struct lu_env *env, struct client_obd *cli,
 	int srvlock = 0;
 	int rc = 0;
 
-	assert_osc_object_is_locked(osc);
+	osc_object_lock(osc);
+	if (osc_makes_rpc(cli, osc, OBD_BRW_WRITE))
+		page_count = get_write_extents(osc, &rpclist);
 
-	page_count = get_write_extents(osc, &rpclist);
 	LASSERT(equi(page_count == 0, list_empty(&rpclist)));
 
-	if (list_empty(&rpclist))
+	if (list_empty(&rpclist)) {
+		osc_object_unlock(osc);
 		return 0;
+	}
 
 	osc_update_pending(osc, OBD_BRW_WRITE, -page_count);
 
@@ -2086,7 +2088,6 @@ osc_send_write_rpc(const struct lu_env *env, struct client_obd *cli,
 		LASSERT(list_empty(&rpclist));
 	}
 
-	osc_object_lock(osc);
 	return rc;
 }
 
@@ -2103,7 +2104,6 @@ osc_send_write_rpc(const struct lu_env *env, struct client_obd *cli,
 static int
 osc_send_read_rpc(const struct lu_env *env, struct client_obd *cli,
 		  struct osc_object *osc)
-	__must_hold(osc)
 {
 	struct osc_extent *ext;
 	struct osc_extent *next;
@@ -2117,7 +2117,12 @@ osc_send_read_rpc(const struct lu_env *env, struct client_obd *cli,
 	};
 	int rc = 0;
 
-	assert_osc_object_is_locked(osc);
+	osc_object_lock(osc);
+	if (!osc_makes_rpc(cli, osc, OBD_BRW_READ)) {
+		osc_object_unlock(osc);
+		return rc;
+	}
+
 	list_for_each_entry_safe(ext, next, &osc->oo_reading_exts, oe_link) {
 		EASSERT(ext->oe_state == OES_LOCK_DONE, ext);
 		if (!try_to_add_extent_for_io(cli, ext, &data))
@@ -2129,13 +2134,12 @@ osc_send_read_rpc(const struct lu_env *env, struct client_obd *cli,
 
 	osc_update_pending(osc, OBD_BRW_READ, -data.erd_page_count);
 
+	osc_object_unlock(osc);
 	if (!list_empty(&rpclist)) {
-		osc_object_unlock(osc);
 
 		rc = osc_build_rpc(env, cli, &rpclist, OBD_BRW_READ);
 		LASSERT(list_empty(&rpclist));
 
-		osc_object_lock(osc);
 	}
 	return rc;
 }
@@ -2210,38 +2214,32 @@ static void osc_check_rpcs(const struct lu_env *env, struct client_obd *cli)
 		 * partial read pending queue when we're given this object to
 		 * do io on writes while there are cache waiters
 		 */
-		osc_object_lock(osc);
-		if (osc_makes_rpc(cli, osc, OBD_BRW_WRITE)) {
-			rc = osc_send_write_rpc(env, cli, osc);
-			if (rc < 0) {
-				CERROR("Write request failed with %d\n", rc);
-
-				/* osc_send_write_rpc failed, mostly because of
-				 * memory pressure.
-				 *
-				 * It can't break here, because if:
-				 *  - a page was submitted by osc_io_submit, so
-				 *    page locked;
-				 *  - no request in flight
-				 *  - no subsequent request
-				 * The system will be in live-lock state,
-				 * because there is no chance to call
-				 * osc_io_unplug() and osc_check_rpcs() any
-				 * more. pdflush can't help in this case,
-				 * because it might be blocked at grabbing
-				 * the page lock as we mentioned.
-				 *
-				 * Anyway, continue to drain pages.
-				 */
-				/* break; */
-			}
-		}
-		if (osc_makes_rpc(cli, osc, OBD_BRW_READ)) {
-			rc = osc_send_read_rpc(env, cli, osc);
-			if (rc < 0)
-				CERROR("Read request failed with %d\n", rc);
+		rc = osc_send_write_rpc(env, cli, osc);
+		if (rc < 0) {
+			CERROR("Write request failed with %d\n", rc);
+
+			/* osc_send_write_rpc failed, mostly because of
+			 * memory pressure.
+			 *
+			 * It can't break here, because if:
+			 *  - a page was submitted by osc_io_submit, so
+			 *    page locked;
+			 *  - no request in flight
+			 *  - no subsequent request
+			 * The system will be in live-lock state,
+			 * because there is no chance to call
+			 * osc_io_unplug() and osc_check_rpcs() any
+			 * more. pdflush can't help in this case,
+			 * because it might be blocked@grabbing
+			 * the page lock as we mentioned.
+			 *
+			 * Anyway, continue to drain pages.
+			 */
+			/* break; */
 		}
-		osc_object_unlock(osc);
+		rc = osc_send_read_rpc(env, cli, osc);
+		if (rc < 0)
+			CERROR("Read request failed with %d\n", rc);
 
 		osc_list_maint(cli, osc);
 		lu_object_ref_del_at(&obj->co_lu, &link, "check", current);
