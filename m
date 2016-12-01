From: James Simmons <jsimmons@infradead.org>
Date: Thu,  1 Dec 2016 17:35:31 -0500
Subject: [lustre-devel] [PATCH 2/3] staging: lustre: osc: create cli_name to
	get obd name
In-Reply-To: <1480631732-6880-1-git-send-email-jsimmons@infradead.org>
References: <1480631732-6880-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480631732-6880-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Create the inline function cli_name() to get the name
of the OSC device.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5108
Reviewed-on: http://review.whamcloud.com/10458
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c    |    8 ++++----
 drivers/staging/lustre/lustre/osc/osc_internal.h |    5 +++++
 drivers/staging/lustre/lustre/osc/osc_page.c     |   12 +++++-------
 drivers/staging/lustre/lustre/osc/osc_quota.c    |    4 ++--
 drivers/staging/lustre/lustre/osc/osc_request.c  |   13 +++++--------
 5 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 0b5f4b2..462a3ad 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -961,7 +961,7 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
 	if (rc == -ETIMEDOUT) {
 		OSC_EXTENT_DUMP(D_ERROR, ext,
 				"%s: wait ext to %u timedout, recovery in progress?\n",
-				osc_export(obj)->exp_obd->obd_name, state);
+				cli_name(osc_cli(obj)), state);
 
 		lwi = LWI_INTR(NULL, NULL);
 		rc = l_wait_event(ext->oe_waitq, extent_wait_cb(ext, state),
@@ -1384,7 +1384,7 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	CDEBUG(lvl, "%s: grant { dirty: %ld/%ld dirty_pages: %ld/%lu "	      \
 	       "dropped: %ld avail: %ld, reserved: %ld, flight: %d }"	      \
 	       "lru {in list: %ld, left: %ld, waiters: %d }" fmt "\n",	      \
-	       __tmp->cl_import->imp_obd->obd_name,			      \
+	       cli_name(__tmp),						      \
 	       __tmp->cl_dirty_pages, __tmp->cl_dirty_max_pages,	      \
 	       atomic_long_read(&obd_dirty_pages), obd_max_dirty_pages,	      \
 	       __tmp->cl_lost_grant, __tmp->cl_avail_grant,		      \
@@ -1622,7 +1622,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 		osc_io_unplug_async(env, cli, NULL);
 
 		CDEBUG(D_CACHE, "%s: sleeping for cache space @ %p for %p\n",
-		       cli->cl_import->imp_obd->obd_name, &ocw, oap);
+		       cli_name(cli), &ocw, oap);
 
 		rc = l_wait_event(ocw.ocw_waitq, ocw_granted(cli, &ocw), &lwi);
 
@@ -1666,7 +1666,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 		break;
 	default:
 		CDEBUG(D_CACHE, "%s: event for cache space @ %p never arrived due to %d, fall back to sync i/o\n",
-		       cli->cl_import->imp_obd->obd_name, &ocw, rc);
+		       cli_name(cli), &ocw, rc);
 		break;
 	}
 out:
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 981b7e1..c5b58e9 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -155,6 +155,11 @@ static inline unsigned long rpcs_in_flight(struct client_obd *cli)
 	return cli->cl_r_in_flight + cli->cl_w_in_flight;
 }
 
+static inline char *cli_name(struct client_obd *cli)
+{
+	return cli->cl_import->imp_obd->obd_name;
+}
+
 struct osc_device {
 	struct cl_device    od_cl;
 	struct obd_export  *od_exp;
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 2cdc30a..54c483c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -385,7 +385,7 @@ int lru_queue_work(const struct lu_env *env, void *data)
 {
 	struct client_obd *cli = data;
 
-	CDEBUG(D_CACHE, "Run LRU work for client obd %p.\n", cli);
+	CDEBUG(D_CACHE, "%s: run LRU work for client obd\n", cli_name(cli));
 
 	if (osc_cache_too_much(cli))
 		osc_lru_shrink(env, cli, lru_shrink_max, true);
@@ -675,8 +675,7 @@ long osc_lru_reclaim(struct client_obd *cli)
 	}
 
 	CDEBUG(D_CACHE, "%s: cli %p no free slots, pages: %ld, busy: %ld.\n",
-	       cli->cl_import->imp_obd->obd_name, cli,
-	       atomic_long_read(&cli->cl_lru_in_list),
+	       cli_name(cli), cli, atomic_long_read(&cli->cl_lru_in_list),
 	       atomic_long_read(&cli->cl_lru_busy));
 
 	/* Reclaim LRU slots from other client_obd as it can't free enough
@@ -694,7 +693,7 @@ long osc_lru_reclaim(struct client_obd *cli)
 				 cl_lru_osc);
 
 		CDEBUG(D_CACHE, "%s: cli %p LRU pages: %ld, busy: %ld.\n",
-		       cli->cl_import->imp_obd->obd_name, cli,
+		       cli_name(cli), cli,
 		       atomic_long_read(&cli->cl_lru_in_list),
 		       atomic_long_read(&cli->cl_lru_busy));
 
@@ -714,7 +713,7 @@ long osc_lru_reclaim(struct client_obd *cli)
 out:
 	cl_env_put(env, &refcheck);
 	CDEBUG(D_CACHE, "%s: cli %p freed %ld pages.\n",
-	       cli->cl_import->imp_obd->obd_name, cli, rc);
+	       cli_name(cli), cli, rc);
 	return rc;
 }
 
@@ -903,8 +902,7 @@ bool osc_over_unstable_soft_limit(struct client_obd *cli)
 
 	CDEBUG(D_CACHE,
 	       "%s: cli: %p unstable pages: %lu, osc unstable pages: %lu\n",
-	       cli->cl_import->imp_obd->obd_name, cli,
-	       unstable_nr, osc_unstable_count);
+	       cli_name(cli), cli, unstable_nr, osc_unstable_count);
 
 	/*
 	 * If the LRU slots are in shortage - 25% remaining AND this OSC
diff --git a/drivers/staging/lustre/lustre/osc/osc_quota.c b/drivers/staging/lustre/lustre/osc/osc_quota.c
index acdd91a..4bb3b45 100644
--- a/drivers/staging/lustre/lustre/osc/osc_quota.c
+++ b/drivers/staging/lustre/lustre/osc/osc_quota.c
@@ -106,7 +106,7 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 			}
 
 			CDEBUG(D_QUOTA, "%s: setdq to insert for %s %d (%d)\n",
-			       cli->cl_import->imp_obd->obd_name,
+			       cli_name(cli),
 			       type == USRQUOTA ? "user" : "group",
 			       qid[type], rc);
 		} else {
@@ -122,7 +122,7 @@ int osc_quota_setdq(struct client_obd *cli, const unsigned int qid[],
 				kmem_cache_free(osc_quota_kmem, oqi);
 
 			CDEBUG(D_QUOTA, "%s: setdq to remove for %s %d (%p)\n",
-			       cli->cl_import->imp_obd->obd_name,
+			       cli_name(cli),
 			       type == USRQUOTA ? "user" : "group",
 			       qid[type], oqi);
 		}
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 4d4d3eb..6618379 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -589,8 +589,7 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 		 * this CERROR() unless we add in a small fudge factor (+1).
 		 */
 		CERROR("%s: dirty %ld + %ld > system dirty_max %lu\n",
-		       cli->cl_import->imp_obd->obd_name,
-		       atomic_long_read(&obd_dirty_pages),
+		       cli_name(cli), atomic_long_read(&obd_dirty_pages),
 		       atomic_long_read(&obd_dirty_transit_pages),
 		       obd_max_dirty_pages);
 		oa->o_undirty = 0;
@@ -785,12 +784,10 @@ static int osc_add_shrink_grant(struct client_obd *client)
 				       osc_grant_shrink_grant_cb, NULL,
 				       &client->cl_grant_shrink_list);
 	if (rc) {
-		CERROR("add grant client %s error %d\n",
-		       client->cl_import->imp_obd->obd_name, rc);
+		CERROR("add grant client %s error %d\n", cli_name(client), rc);
 		return rc;
 	}
-	CDEBUG(D_CACHE, "add grant client %s\n",
-	       client->cl_import->imp_obd->obd_name);
+	CDEBUG(D_CACHE, "add grant client %s\n", cli_name(client));
 	osc_update_next_shrink(client);
 	return 0;
 }
@@ -824,8 +821,8 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 	spin_unlock(&cli->cl_loi_list_lock);
 
 	CDEBUG(D_CACHE, "%s, setting cl_avail_grant: %ld cl_lost_grant: %ld chunk bits: %d\n",
-	       cli->cl_import->imp_obd->obd_name,
-	       cli->cl_avail_grant, cli->cl_lost_grant, cli->cl_chunkbits);
+	       cli_name(cli), cli->cl_avail_grant, cli->cl_lost_grant,
+	       cli->cl_chunkbits);
 
 	if (ocd->ocd_connect_flags & OBD_CONNECT_GRANT_SHRINK &&
 	    list_empty(&cli->cl_grant_shrink_list))
-- 
1.7.1
