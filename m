From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:02 +1100
Subject: [lustre-devel] [PATCH 14/29] lustre: osc_cache: convert
 cl_cache_waiters to a wait_queue.
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504196.26726.10177553592840024331.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

cli->cl_cache_waiters is a list of tasks that need
to be woken when grant-space becomes available.  This
means it is acting much like a wait queue.
So let's change it to really be a wait queue.

The current implementation adds new waiters to the end of the list,
and calls osc_enter_cache_try() on each in order.
We can provide the same behaviour by using an exclusive wait,
and having each waiter wake the next task when it succeeds.

If a waiter notices that success has become impossible, it wakes all
other waiters.

If a waiter times out, it doesn't wake other - just leaves them to
time out themselves.

Note that the old code handled -EINTR from the wait function.  That is
not a possible return value when wait_event_idle* is used, so that
case is discarded.

For all this to work, we need a
  wait_event_idle_exclusive_timeout_cmd()
macro. This fits the pattern of other macros in wait.h, and can
be moved to wait.h when this code lands in mainline.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/obd.h      |    2 
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c    |    2 
 drivers/staging/lustre/lustre/osc/osc_cache.c    |  145 ++++++++--------------
 drivers/staging/lustre/lustre/osc/osc_internal.h |   12 +-
 drivers/staging/lustre/lustre/osc/osc_page.c     |    2 
 5 files changed, 57 insertions(+), 106 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index d6a968ceb274..bb6f3e1fce6e 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -209,7 +209,7 @@ struct client_obd {
 	 * See osc_{reserve|unreserve}_grant for details.
 	 */
 	long		 cl_reserved_grant;
-	struct list_head cl_cache_waiters; /* waiting for cache/grant */
+	wait_queue_head_t cl_cache_waiters; /* waiting for cache/grant */
 	unsigned long	 cl_next_shrink_grant;   /* jiffies */
 	struct list_head cl_grant_shrink_list;  /* Timeout event list */
 	int		 cl_grant_shrink_interval; /* seconds */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 732ef3a64c72..609b9d04eb40 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -323,7 +323,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	 * ptlrpc_connect_interpret().
 	 */
 	client_adjust_max_dirty(cli);
-	INIT_LIST_HEAD(&cli->cl_cache_waiters);
+	init_waitqueue_head(&cli->cl_cache_waiters);
 	INIT_LIST_HEAD(&cli->cl_loi_ready_list);
 	INIT_LIST_HEAD(&cli->cl_loi_hp_ready_list);
 	INIT_LIST_HEAD(&cli->cl_loi_write_list);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index e9987c187ecd..ddfb61502f30 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1557,15 +1557,22 @@ static bool osc_enter_cache_try(struct client_obd *cli,
 	}
 }
 
-static int ocw_granted(struct client_obd *cli, struct osc_cache_waiter *ocw)
-{
-	int rc;
-
-	spin_lock(&cli->cl_loi_list_lock);
-	rc = list_empty(&ocw->ocw_entry);
-	spin_unlock(&cli->cl_loi_list_lock);
-	return rc;
-}
+#define __wait_event_idle_exclusive_timeout_cmd(wq_head, condition,	\
+						timeout, cmd1, cmd2)	\
+	___wait_event(wq_head, ___wait_cond_timeout(condition),		\
+		      TASK_IDLE, 1, timeout,				\
+		      cmd1; __ret = schedule_timeout(__ret); cmd2)
+
+#define wait_event_idle_exclusive_timeout_cmd(wq_head, condition, timeout,\
+					      cmd1, cmd2)		\
+({									\
+	long __ret = timeout;						\
+	might_sleep();							\
+	if (!___wait_cond_timeout(condition))				\
+		__ret = __wait_event_idle_exclusive_timeout_cmd(	\
+			wq_head, condition, timeout, cmd1, cmd2);	\
+	__ret;								\
+})
 
 /**
  * The main entry to reserve dirty page accounting. Usually the grant reserved
@@ -1579,9 +1586,10 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 {
 	struct osc_object *osc = oap->oap_obj;
 	struct lov_oinfo *loi = osc->oo_oinfo;
-	struct osc_cache_waiter ocw;
 	unsigned long timeout = (AT_OFF ? obd_timeout : at_max) * HZ;
 	int rc = -EDQUOT;
+	int remain;
+	bool entered = false;
 
 	OSC_DUMP_GRANT(D_CACHE, cli, "need:%d\n", bytes);
 
@@ -1598,107 +1606,54 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
 		goto out;
 	}
 
-	/* Hopefully normal case - cache space and write credits available */
-	if (osc_enter_cache_try(cli, oap, bytes, 0)) {
-		OSC_DUMP_GRANT(D_CACHE, cli, "granted from cache\n");
-		rc = 0;
-		goto out;
-	}
-
-	/* We can get here for two reasons: too many dirty pages in cache, or
+	/*
+	 * We can wait here for two reasons: too many dirty pages in cache, or
 	 * run out of grants. In both cases we should write dirty pages out.
 	 * Adding a cache waiter will trigger urgent write-out no matter what
 	 * RPC size will be.
-	 * The exiting condition is no avail grants and no dirty pages caching,
-	 * that really means there is no space on the OST.
+	 * The exiting condition (other then success) is no avail grants
+	 * and no dirty pages caching, that really means there is no space
+	 * on the OST.
 	 */
-	init_waitqueue_head(&ocw.ocw_waitq);
-	ocw.ocw_oap   = oap;
-	ocw.ocw_grant = bytes;
-	while (cli->cl_dirty_pages > 0 || cli->cl_w_in_flight > 0) {
-		list_add_tail(&ocw.ocw_entry, &cli->cl_cache_waiters);
-		ocw.ocw_rc = 0;
-		spin_unlock(&cli->cl_loi_list_lock);
+	remain = wait_event_idle_exclusive_timeout_cmd(
+		cli->cl_cache_waiters,
+		(entered = osc_enter_cache_try(
+			cli, oap, bytes, 0)) ||
+		(cli->cl_dirty_pages == 0 &&
+		 cli->cl_w_in_flight == 0),
+		timeout,
 
+		spin_unlock(&cli->cl_loi_list_lock);
 		osc_io_unplug_async(env, cli, NULL);
-
-		CDEBUG(D_CACHE, "%s: sleeping for cache space @ %p for %p\n",
-		       cli_name(cli), &ocw, oap);
-
-		rc = wait_event_idle_timeout(ocw.ocw_waitq,
-					     ocw_granted(cli, &ocw), timeout);
-
-		spin_lock(&cli->cl_loi_list_lock);
-
-		if (rc == 0) {
-			/* wait_event is interrupted by signal, or timed out */
-			list_del_init(&ocw.ocw_entry);
-			rc = -ETIMEDOUT;
-			break;
-		}
-		LASSERT(list_empty(&ocw.ocw_entry));
-		rc = ocw.ocw_rc;
-
-		if (rc != -EDQUOT)
-			break;
-		if (osc_enter_cache_try(cli, oap, bytes, 0)) {
-			rc = 0;
-			break;
-		}
-	}
-
-	switch (rc) {
-	case 0:
-		OSC_DUMP_GRANT(D_CACHE, cli, "finally got grant space\n");
-		break;
-	case -ETIMEDOUT:
+		CDEBUG(D_CACHE,
+		       "%s: sleeping for cache space for %p\n",
+		       cli_name(cli), oap);
+		,
+		spin_lock(&cli->cl_loi_list_lock));
+
+	if (entered) {
+		if (remain == timeout)
+			OSC_DUMP_GRANT(D_CACHE, cli, "granted from cache\n");
+		else
+			OSC_DUMP_GRANT(D_CACHE, cli,
+				       "finally got grant space\n");
+		wake_up(&cli->cl_cache_waiters);
+		rc = 0;
+	} else if (remain == 0) {
 		OSC_DUMP_GRANT(D_CACHE, cli,
 			       "timeout, fall back to sync i/o\n");
 		osc_extent_tree_dump(D_CACHE, osc);
 		/* fall back to synchronous I/O */
-		rc = -EDQUOT;
-		break;
-	case -EINTR:
-		/* Ensures restartability - LU-3581 */
-		OSC_DUMP_GRANT(D_CACHE, cli, "interrupted\n");
-		rc = -ERESTARTSYS;
-		break;
-	case -EDQUOT:
+	} else {
 		OSC_DUMP_GRANT(D_CACHE, cli,
 			       "no grant space, fall back to sync i/o\n");
-		break;
-	default:
-		CDEBUG(D_CACHE, "%s: event for cache space @ %p never arrived due to %d, fall back to sync i/o\n",
-		       cli_name(cli), &ocw, rc);
-		break;
+		wake_up_all(&cli->cl_cache_waiters);
 	}
 out:
 	spin_unlock(&cli->cl_loi_list_lock);
 	return rc;
 }
 
-/* caller must hold loi_list_lock */
-void osc_wake_cache_waiters(struct client_obd *cli)
-{
-	struct osc_cache_waiter *ocw;
-
-	while ((ocw = list_first_entry_or_null(&cli->cl_cache_waiters,
-					       struct osc_cache_waiter,
-					       ocw_entry))) {
-		list_del_init(&ocw->ocw_entry);
-
-		if (osc_enter_cache_try(cli, ocw->ocw_oap, ocw->ocw_grant, 0))
-			ocw->ocw_rc = 0;
-		else
-			ocw->ocw_rc = -EDQUOT;
-
-		CDEBUG(D_CACHE, "wake up %p for oap %p, avail grant %ld, %d\n",
-		       ocw, ocw->ocw_oap, cli->cl_avail_grant, ocw->ocw_rc);
-
-		wake_up(&ocw->ocw_waitq);
-	}
-}
-
 static int osc_max_rpc_in_flight(struct client_obd *cli, struct osc_object *osc)
 {
 	int hprpc = !!list_empty(&osc->oo_hp_exts);
@@ -1742,7 +1697,7 @@ static int osc_makes_rpc(struct client_obd *cli, struct osc_object *osc,
 		 * waiting for space.  as they're waiting, they're not going to
 		 * create more pages to coalesce with what's waiting..
 		 */
-		if (!list_empty(&cli->cl_cache_waiters)) {
+		if (waitqueue_active(&cli->cl_cache_waiters)) {
 			CDEBUG(D_CACHE, "cache waiters forcing RPC\n");
 			return 1;
 		}
@@ -2219,7 +2174,7 @@ static struct osc_object *osc_next_obj(struct client_obd *cli)
 	 * have filled up the cache and not been fired into rpcs because
 	 * they don't pass the nr_pending/object threshold
 	 */
-	if (!list_empty(&cli->cl_cache_waiters) &&
+	if (waitqueue_active(&cli->cl_cache_waiters) &&
 	    !list_empty(&cli->cl_loi_write_list))
 		return list_to_obj(&cli->cl_loi_write_list, write_item);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 0de8a3ee826d..0354272fe192 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -87,15 +87,11 @@ static inline struct osc_async_page *brw_page2oap(struct brw_page *pga)
 	return container_of(pga, struct osc_async_page, oap_brw_page);
 }
 
-struct osc_cache_waiter {
-	struct list_head		ocw_entry;
-	wait_queue_head_t		ocw_waitq;
-	struct osc_async_page		*ocw_oap;
-	int				ocw_grant;
-	int				ocw_rc;
-};
+static inline void osc_wake_cache_waiters(struct client_obd *cli)
+{
+	wake_up(&cli->cl_cache_waiters);
+}
 
-void osc_wake_cache_waiters(struct client_obd *cli);
 int osc_shrink_grant_to_target(struct client_obd *cli, __u64 target_bytes);
 void osc_update_next_shrink(struct client_obd *cli);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index ada1eda24614..28b12729d7e9 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -155,7 +155,7 @@ static int osc_page_print(const struct lu_env *env,
 			  cli->cl_r_in_flight, cli->cl_w_in_flight,
 			  cli->cl_max_rpcs_in_flight,
 			  cli->cl_avail_grant,
-			  osc_list(&cli->cl_cache_waiters),
+			  waitqueue_active(&cli->cl_cache_waiters) ? "+" : "-",
 			  osc_list(&cli->cl_loi_ready_list),
 			  osc_list(&cli->cl_loi_hp_ready_list),
 			  osc_list(&cli->cl_loi_write_list),
