From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:47 -0400
Subject: [lustre-devel] [PATCH 108/124] staging: lustre: grant: quiet
	message on grant waiting timeout
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-109-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Johann Lombardi <johann.lombardi@intel.com>, James Simmons <jsimmons@infradead.org>

From: Johann Lombardi <johann.lombardi@intel.com>

Use at_max in osc_enter_cache() to bound how long we wait for grant
space before switching to synchronous I/Os. Do not print a message
on the console when the timeout is hit since such long wait can
be legitimate with flaky network (i.e. BRW is resent multiple times).

Signed-off-by: Johann Lombardi <johann.lombardi@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5521
Reviewed-on: http://review.whamcloud.com/12146
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |   61 ++++++++++++++++---------
 1 files changed, 40 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 8152cc7..6b7677f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1536,7 +1536,7 @@ static int osc_enter_cache_try(struct client_obd *cli,
 {
 	int rc;
 
-	OSC_DUMP_GRANT(D_CACHE, cli, "need:%d.\n", bytes);
+	OSC_DUMP_GRANT(D_CACHE, cli, "need:%d\n", bytes);
 
 	rc = osc_reserve_grant(cli, bytes);
 	if (rc < 0)
@@ -1581,11 +1581,13 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	struct osc_object *osc = oap->oap_obj;
 	struct lov_oinfo *loi = osc->oo_oinfo;
 	struct osc_cache_waiter ocw;
-	struct l_wait_info lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(600), NULL,
-						  LWI_ON_SIGNAL_NOOP, NULL);
+	struct l_wait_info lwi;
 	int rc = -EDQUOT;
 
-	OSC_DUMP_GRANT(D_CACHE, cli, "need:%d.\n", bytes);
+	lwi = LWI_TIMEOUT_INTR(cfs_time_seconds(AT_OFF ? obd_timeout : at_max),
+			       NULL, LWI_ON_SIGNAL_NOOP, NULL);
+
+	OSC_DUMP_GRANT(D_CACHE, cli, "need:%d\n", bytes);
 
 	spin_lock(&cli->cl_loi_list_lock);
 
@@ -1595,12 +1597,14 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_NO_GRANT) ||
 	    !cli->cl_dirty_max_pages || cli->cl_ar.ar_force_sync ||
 	    loi->loi_ar.ar_force_sync) {
+		OSC_DUMP_GRANT(D_CACHE, cli, "forced sync i/o\n");
 		rc = -EDQUOT;
 		goto out;
 	}
 
 	/* Hopefully normal case - cache space and write credits available */
 	if (osc_enter_cache_try(cli, oap, bytes, 0)) {
+		OSC_DUMP_GRANT(D_CACHE, cli, "granted from cache\n");
 		rc = 0;
 		goto out;
 	}
@@ -1629,32 +1633,49 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 
 		spin_lock(&cli->cl_loi_list_lock);
 
-		/* l_wait_event is interrupted by signal, or timed out */
 		if (rc < 0) {
-			if (rc == -ETIMEDOUT) {
-				OSC_DUMP_GRANT(D_ERROR, cli,
-					       "try to reserve %d.\n", bytes);
-				osc_extent_tree_dump(D_ERROR, osc);
-				rc = -EDQUOT;
-			}
-
+			/* l_wait_event is interrupted by signal, or timed out */
 			list_del_init(&ocw.ocw_entry);
-			goto out;
+			break;
 		}
-
 		LASSERT(list_empty(&ocw.ocw_entry));
 		rc = ocw.ocw_rc;
 
 		if (rc != -EDQUOT)
-			goto out;
+			break;
 		if (osc_enter_cache_try(cli, oap, bytes, 0)) {
 			rc = 0;
-			goto out;
+			break;
 		}
 	}
+
+	switch (rc) {
+	case 0:
+		OSC_DUMP_GRANT(D_CACHE, cli, "finally got grant space\n");
+		break;
+	case -ETIMEDOUT:
+		OSC_DUMP_GRANT(D_CACHE, cli,
+			       "timeout, fall back to sync i/o\n");
+		osc_extent_tree_dump(D_CACHE, osc);
+		/* fall back to synchronous I/O */
+		rc = -EDQUOT;
+		break;
+	case -EINTR:
+		/* Ensures restartability - LU-3581 */
+		OSC_DUMP_GRANT(D_CACHE, cli, "interrupted\n");
+		rc = -ERESTARTSYS;
+		break;
+	case -EDQUOT:
+		OSC_DUMP_GRANT(D_CACHE, cli,
+			       "no grant space, fall back to sync i/o\n");
+		break;
+	default:
+		CDEBUG(D_CACHE, "%s: event for cache space @ %p never arrived due to %d, fall back to sync i/o\n",
+		       cli->cl_import->imp_obd->obd_name, &ocw, rc);
+		break;
+	}
 out:
 	spin_unlock(&cli->cl_loi_list_lock);
-	OSC_DUMP_GRANT(D_CACHE, cli, "returned %d.\n", rc);
 	return rc;
 }
 
@@ -1679,10 +1700,8 @@ void osc_wake_cache_waiters(struct client_obd *cli)
 			goto wakeup;
 		}
 
-		ocw->ocw_rc = 0;
-		if (!osc_enter_cache_try(cli, ocw->ocw_oap, ocw->ocw_grant, 0))
-			ocw->ocw_rc = -EDQUOT;
-
+		if (osc_enter_cache_try(cli, ocw->ocw_oap, ocw->ocw_grant, 0))
+			ocw->ocw_rc = 0;
 wakeup:
 		CDEBUG(D_CACHE, "wake up %p for oap %p, avail grant %ld, %d\n",
 		       ocw, ocw->ocw_oap, cli->cl_avail_grant, ocw->ocw_rc);
-- 
1.7.1
