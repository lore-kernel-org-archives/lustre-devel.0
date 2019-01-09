From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:02 +1100
Subject: [lustre-devel] [PATCH 23/29] lustre: osc_cache: remove 'transient'
 arg from osc_enter_cache_try
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504254.26726.7702205638412400024.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This arg is always '0', so remove it.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 8a68d3eb9314..b4bb36926046 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1535,7 +1535,7 @@ static void osc_exit_cache(struct client_obd *cli, struct osc_async_page *oap)
  */
 static bool osc_enter_cache_try(struct client_obd *cli,
 				struct osc_async_page *oap,
-				int bytes, int transient)
+				int bytes)
 {
 	OSC_DUMP_GRANT(D_CACHE, cli, "need:%d\n", bytes);
 
@@ -1545,11 +1545,6 @@ static bool osc_enter_cache_try(struct client_obd *cli,
 	if (cli->cl_dirty_pages < cli->cl_dirty_max_pages &&
 	    atomic_long_read(&obd_dirty_pages) + 1 <= obd_max_dirty_pages) {
 		osc_consume_write_grant(cli, &oap->oap_brw_page);
-		if (transient) {
-			cli->cl_dirty_transit++;
-			atomic_long_inc(&obd_dirty_transit_pages);
-			oap->oap_brw_flags |= OBD_BRW_NOCACHE;
-		}
 		return true;
 	} else {
 		__osc_unreserve_grant(cli, bytes, bytes);
@@ -1618,7 +1613,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	remain = wait_event_idle_exclusive_timeout_cmd(
 		cli->cl_cache_waiters,
 		(entered = osc_enter_cache_try(
-			cli, oap, bytes, 0)) ||
+			cli, oap, bytes)) ||
 		(cli->cl_dirty_pages == 0 &&
 		 cli->cl_w_in_flight == 0),
 		timeout,
@@ -2396,7 +2391,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
 
 		/* it doesn't need any grant to dirty this page */
 		spin_lock(&cli->cl_loi_list_lock);
-		if (!osc_enter_cache_try(cli, oap, grants, 0)) {
+		if (!osc_enter_cache_try(cli, oap, grants)) {
 			grants = 0;
 			need_release = 1;
 		}
