From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:02 +1100
Subject: [lustre-devel] [PATCH 16/29] lustre: osc_cache: use
 osc_makes_hprpc() more consistently.
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504207.26726.261002093793293176.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We have a function "osc_makes_hprpc()", and a few places
that could use it, but instead open-code the content.

Move the function earlier, and use it more broadly.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 9b78562d3366..d2d5867156ad 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1654,9 +1654,14 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	return rc;
 }
 
+static int osc_makes_hprpc(struct osc_object *obj)
+{
+	return !list_empty(&obj->oo_hp_exts);
+}
+
 static int osc_max_rpc_in_flight(struct client_obd *cli, struct osc_object *osc)
 {
-	int hprpc = !!list_empty(&osc->oo_hp_exts);
+	int hprpc = !osc_makes_hprpc(osc);
 
 	return rpcs_in_flight(cli) >= cli->cl_max_rpcs_in_flight + hprpc;
 }
@@ -1685,7 +1690,7 @@ static bool osc_makes_rpc(struct client_obd *cli, struct osc_object *osc,
 			CDEBUG(D_CACHE, "invalid import forcing RPC\n");
 			return true;
 		}
-		if (!list_empty(&osc->oo_hp_exts)) {
+		if (osc_makes_hprpc(osc)) {
 			CDEBUG(D_CACHE, "high prio request forcing RPC\n");
 			return true;
 		}
@@ -1736,11 +1741,6 @@ static void osc_update_pending(struct osc_object *obj, int cmd, int delta)
 	OSC_IO_DEBUG(obj, "update pending cmd %d delta %d.\n", cmd, delta);
 }
 
-static int osc_makes_hprpc(struct osc_object *obj)
-{
-	return !list_empty(&obj->oo_hp_exts);
-}
-
 static void on_list(struct list_head *item, struct list_head *list, int should_be_on)
 {
 	if (list_empty(item) && should_be_on)
