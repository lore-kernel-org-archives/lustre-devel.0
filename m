From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:01 +1100
Subject: [lustre-devel] [PATCH 13/29] lustre: osc_cache: change
 osc_enter_cache_try to return bool.
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504186.26726.10969814573194089501.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

'bool' is the natural type for this, so make that obvious.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |   26 +++++++++++--------------
 1 file changed, 11 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 5a295799f177..e9987c187ecd 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1533,17 +1533,14 @@ static void osc_exit_cache(struct client_obd *cli, struct osc_async_page *oap)
  * Non-blocking version of osc_enter_cache() that consumes grant only when it
  * is available.
  */
-static int osc_enter_cache_try(struct client_obd *cli,
-			       struct osc_async_page *oap,
-			       int bytes, int transient)
+static bool osc_enter_cache_try(struct client_obd *cli,
+				struct osc_async_page *oap,
+				int bytes, int transient)
 {
-	int rc;
-
 	OSC_DUMP_GRANT(D_CACHE, cli, "need:%d\n", bytes);
 
-	rc = osc_reserve_grant(cli, bytes);
-	if (rc < 0)
-		return 0;
+	if (osc_reserve_grant(cli, bytes) < 0)
+		return false;
 
 	if (cli->cl_dirty_pages < cli->cl_dirty_max_pages &&
 	    atomic_long_read(&obd_dirty_pages) + 1 <= obd_max_dirty_pages) {
@@ -1553,12 +1550,11 @@ static int osc_enter_cache_try(struct client_obd *cli,
 			atomic_long_inc(&obd_dirty_transit_pages);
 			oap->oap_brw_flags |= OBD_BRW_NOCACHE;
 		}
-		rc = 1;
+		return true;
 	} else {
 		__osc_unreserve_grant(cli, bytes, bytes);
-		rc = 0;
+		return false;
 	}
-	return rc;
 }
 
 static int ocw_granted(struct client_obd *cli, struct osc_cache_waiter *ocw)
@@ -2457,12 +2453,12 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 
 		/* it doesn't need any grant to dirty this page */
 		spin_lock(&cli->cl_loi_list_lock);
-		rc = osc_enter_cache_try(cli, oap, grants, 0);
-		spin_unlock(&cli->cl_loi_list_lock);
-		if (rc == 0) { /* try failed */
+		if (!osc_enter_cache_try(cli, oap, grants, 0)) {
 			grants = 0;
 			need_release = 1;
-		} else if (ext->oe_end < index) {
+		}
+		spin_unlock(&cli->cl_loi_list_lock);
+		if (!need_release && ext->oe_end < index) {
 			tmp = grants;
 			/* try to expand this extent */
 			rc = osc_extent_expand(ext, index, &tmp);
