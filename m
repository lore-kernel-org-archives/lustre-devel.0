From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:02 +1100
Subject: [lustre-devel] [PATCH 15/29] lustre: osc_cache: change
 osc_make_rpc() to return bool.
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504202.26726.9471170836147674405.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

'bool' more accurately reflects the nature of this function.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |   28 +++++++++++++------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index ddfb61502f30..9b78562d3366 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1665,10 +1665,10 @@ static int osc_max_rpc_in_flight(struct client_obd *cli, struct osc_object *osc)
  * (lop).  This is used by osc_check_rpcs->osc_next_obj() and osc_list_maint()
  * to quickly find objects that are ready to send an RPC.
  */
-static int osc_makes_rpc(struct client_obd *cli, struct osc_object *osc,
-			 int cmd)
+static bool osc_makes_rpc(struct client_obd *cli, struct osc_object *osc,
+			  int cmd)
 {
-	int invalid_import = 0;
+	bool invalid_import = false;
 
 	/* if we have an invalid import we want to drain the queued pages
 	 * by forcing them through rpcs that immediately fail and complete
@@ -1676,22 +1676,22 @@ static int osc_makes_rpc(struct client_obd *cli, struct osc_object *osc,
 	 * before canceling the locks and evicting down the llite pages
 	 */
 	if (!cli->cl_import || cli->cl_import->imp_invalid)
-		invalid_import = 1;
+		invalid_import = true;
 
 	if (cmd & OBD_BRW_WRITE) {
 		if (atomic_read(&osc->oo_nr_writes) == 0)
-			return 0;
+			return false;
 		if (invalid_import) {
 			CDEBUG(D_CACHE, "invalid import forcing RPC\n");
-			return 1;
+			return true;
 		}
 		if (!list_empty(&osc->oo_hp_exts)) {
 			CDEBUG(D_CACHE, "high prio request forcing RPC\n");
-			return 1;
+			return true;
 		}
 		if (!list_empty(&osc->oo_urgent_exts)) {
 			CDEBUG(D_CACHE, "urgent request forcing RPC\n");
-			return 1;
+			return true;
 		}
 		/* trigger a write rpc stream as long as there are dirtiers
 		 * waiting for space.  as they're waiting, they're not going to
@@ -1699,25 +1699,25 @@ static int osc_makes_rpc(struct client_obd *cli, struct osc_object *osc,
 		 */
 		if (waitqueue_active(&cli->cl_cache_waiters)) {
 			CDEBUG(D_CACHE, "cache waiters forcing RPC\n");
-			return 1;
+			return true;
 		}
 		if (!list_empty(&osc->oo_full_exts)) {
 			CDEBUG(D_CACHE, "full extent ready, make an RPC\n");
-			return 1;
+			return true;
 		}
 	} else {
 		if (atomic_read(&osc->oo_nr_reads) == 0)
-			return 0;
+			return false;
 		if (invalid_import) {
 			CDEBUG(D_CACHE, "invalid import forcing RPC\n");
-			return 1;
+			return true;
 		}
 		/* all read are urgent. */
 		if (!list_empty(&osc->oo_reading_exts))
-			return 1;
+			return true;
 	}
 
-	return 0;
+	return false;
 }
 
 static void osc_update_pending(struct osc_object *obj, int cmd, int delta)
