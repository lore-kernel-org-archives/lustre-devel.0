From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:57 -0500
Subject: [lustre-devel] [PATCH 21/40] staging: lustre: improve LNet clean up
	code and API
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

This patch addresses a set of related issues: LU-5734, LU-5839,
LU-5849, LU-5850.

Create the local lnet_startup_lndni() API.  This function starts
up one LND.  lnet_startup_lndnis() calls this function in a loop
on every ni in the list passed in.  lnet_startup_lndni() is
responsible for cleaning up after itself in case of failure.
It calls lnet_free_ni() if the ni fails to start.  It calls
lnet_shutdown_lndni() if it successfully called the
lnd startup function, but fails later on.

lnet_startup_lndnis() also cleans up after itself.
If lnet_startup_lndni() fails then lnet_shutdown_lndnis() is
called to clean up all nis that might have been
started, and then free the rest of the nis on the list
which have not been started yet.

To facilitate the above changes lnet_dyn_del_ni() now
manages the ping info.  It calls lnet_shutdown_lndni(),
to shutdown the NI.  lnet_shutdown_lndni() is no longer
an exposed API and doesn't manage the ping info, making
it callable from lnet_startup_lndni() as well.

There are two scenarios for calling lnet_startup_lndni()

1. from lnet_startup_lndnis()
If lnet_startup_lndni() fails it requires to shutdown the ni
without doing anything with the ping information as it hasn't
been created yet.

2. from lnet_dyn_add_ni()
As above it will shutdown the ni, and then lnet_dyn_add_ni() will
take care of managing the ping info

The second part of this change is to ensure that the LOLND is not
added by lnet_parse_networks(), but the caller which needs to do
it (IE: LNetNIInit)

This change ensures that lnet_dyn_add_ni() need only check if there is
only one net that's being added, if not then it frees everything,
otherwise it proceeds to startup the requested net.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5734
Reviewed-on: http://review.whamcloud.com/12658
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    2 +
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  461 ++++++++++----------
 drivers/staging/lustre/lnet/lnet/config.c          |   14 +-
 3 files changed, 245 insertions(+), 232 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index a1f94db..4c2d824 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -420,6 +420,8 @@ lnet_ni_decref(lnet_ni_t *ni)
 }
 
 void lnet_ni_free(lnet_ni_t *ni);
+lnet_ni_t *
+lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist);
 
 static inline int
 lnet_nid2peerhash(lnet_nid_t nid)
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index bfc1f13..e40c657 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1064,6 +1064,20 @@ lnet_ni_tq_credits(lnet_ni_t *ni)
 }
 
 static void
+lnet_ni_unlink_locked(lnet_ni_t *ni)
+{
+	if (!list_empty(&ni->ni_cptlist)) {
+		list_del_init(&ni->ni_cptlist);
+		lnet_ni_decref_locked(ni, 0);
+	}
+
+	/* move it to zombie list and nobody can find it anymore */
+	LASSERT(!list_empty(&ni->ni_list));
+	list_move(&ni->ni_list, &the_lnet.ln_nis_zombie);
+	lnet_ni_decref_locked(ni, 0);	/* drop ln_nis' ref */
+}
+
+static void
 lnet_clear_zombies_nis_locked(void)
 {
 	int i;
@@ -1146,14 +1160,7 @@ lnet_shutdown_lndnis(void)
 	while (!list_empty(&the_lnet.ln_nis)) {
 		ni = list_entry(the_lnet.ln_nis.next,
 				lnet_ni_t, ni_list);
-		/* move it to zombie list and nobody can find it anymore */
-		list_move(&ni->ni_list, &the_lnet.ln_nis_zombie);
-		lnet_ni_decref_locked(ni, 0);	/* drop ln_nis' ref */
-
-		if (!list_empty(&ni->ni_cptlist)) {
-			list_del_init(&ni->ni_cptlist);
-			lnet_ni_decref_locked(ni, 0);
-		}
+		lnet_ni_unlink_locked(ni);
 	}
 
 	/* Drop the cached eqwait NI. */
@@ -1186,233 +1193,196 @@ lnet_shutdown_lndnis(void)
 	lnet_net_unlock(LNET_LOCK_EX);
 }
 
-int
-lnet_shutdown_lndni(__u32 net)
+/* shutdown down the NI and release refcount */
+static void
+lnet_shutdown_lndni(struct lnet_ni *ni)
 {
-	lnet_ping_info_t *pinfo;
-	lnet_handle_md_t md_handle;
-	lnet_ni_t *found_ni = NULL;
-	int ni_count;
-	int rc;
-
-	if (LNET_NETTYP(net) == LOLND)
-		return -EINVAL;
-
-	ni_count = lnet_get_ni_count();
-
-	/* create and link a new ping info, before removing the old one */
-	rc = lnet_ping_info_setup(&pinfo, &md_handle, ni_count - 1, false);
-	if (rc != 0)
-		return rc;
-
-	/* proceed with shutting down the NI */
 	lnet_net_lock(LNET_LOCK_EX);
-
-	found_ni = lnet_net2ni_locked(net, 0);
-	if (!found_ni) {
-		lnet_net_unlock(LNET_LOCK_EX);
-		lnet_ping_md_unlink(pinfo, &md_handle);
-		lnet_ping_info_free(pinfo);
-		return -EINVAL;
-	}
-
-	/*
-	 * decrement the reference counter on found_ni which was
-	 * incremented when we called lnet_net2ni_locked()
-	 */
-	lnet_ni_decref_locked(found_ni, 0);
-	/* Move ni to zombie list so nobody can find it anymore */
-	list_move(&found_ni->ni_list, &the_lnet.ln_nis_zombie);
-
-	/* Drop the lock reference for the ln_nis ref. */
-	lnet_ni_decref_locked(found_ni, 0);
-
-	if (!list_empty(&found_ni->ni_cptlist)) {
-		list_del_init(&found_ni->ni_cptlist);
-		lnet_ni_decref_locked(found_ni, 0);
-	}
-
+	lnet_ni_unlink_locked(ni);
 	lnet_net_unlock(LNET_LOCK_EX);
 
 	/* Do peer table cleanup for this ni */
-	lnet_peer_tables_cleanup(found_ni);
+	lnet_peer_tables_cleanup(ni);
 
 	lnet_net_lock(LNET_LOCK_EX);
 	lnet_clear_zombies_nis_locked();
 	lnet_net_unlock(LNET_LOCK_EX);
-
-	lnet_ping_target_update(pinfo, md_handle);
-
-	return 0;
 }
 
-/*
- * Callers of lnet_startup_lndnis need to clean up using
- * lnet_shutdown_lndnis if startup fails
- */
 static int
-lnet_startup_lndnis(struct list_head *nilist, __s32 peer_timeout,
-		    __s32 peer_cr, __s32 peer_buf_cr, __s32 credits,
-		    int *ni_count)
+lnet_startup_lndni(struct lnet_ni *ni, __s32 peer_timeout,
+		   __s32 peer_cr, __s32 peer_buf_cr, __s32 credits)
 {
+	int rc = 0;
+	__u32 lnd_type;
 	lnd_t *lnd;
-	struct lnet_ni *ni;
 	struct lnet_tx_queue *tq;
 	int i;
-	int rc = 0;
-	__u32 lnd_type;
 
-	while (!list_empty(nilist)) {
-		ni = list_entry(nilist->next, lnet_ni_t, ni_list);
-		lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
+	lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
 
-		if (!libcfs_isknown_lnd(lnd_type))
-			goto failed;
-
-		if (lnd_type == CIBLND    ||
-		    lnd_type == OPENIBLND ||
-		    lnd_type == IIBLND    ||
-		    lnd_type == VIBLND) {
-			CERROR("LND %s obsoleted\n",
-			       libcfs_lnd2str(lnd_type));
-			goto failed;
-		}
+	LASSERT(libcfs_isknown_lnd(lnd_type));
 
-		/* Make sure this new NI is unique. */
-		lnet_net_lock(LNET_LOCK_EX);
-		if (!lnet_net_unique(LNET_NIDNET(ni->ni_nid),
-				     &the_lnet.ln_nis)) {
-			if (lnd_type == LOLND) {
-				lnet_net_unlock(LNET_LOCK_EX);
-				list_del(&ni->ni_list);
-				lnet_ni_free(ni);
-				continue;
-			}
+	if (lnd_type == CIBLND || lnd_type == OPENIBLND ||
+	    lnd_type == IIBLND || lnd_type == VIBLND) {
+		CERROR("LND %s obsoleted\n", libcfs_lnd2str(lnd_type));
+		goto failed0;
+	}
 
-			CERROR("Net %s is not unique\n",
-			       libcfs_net2str(LNET_NIDNET(ni->ni_nid)));
+	/* Make sure this new NI is unique. */
+	lnet_net_lock(LNET_LOCK_EX);
+	if (!lnet_net_unique(LNET_NIDNET(ni->ni_nid), &the_lnet.ln_nis)) {
+		if (lnd_type == LOLND) {
 			lnet_net_unlock(LNET_LOCK_EX);
-			goto failed;
+			lnet_ni_free(ni);
+			return 0;
 		}
 		lnet_net_unlock(LNET_LOCK_EX);
 
+		CERROR("Net %s is not unique\n",
+		       libcfs_net2str(LNET_NIDNET(ni->ni_nid)));
+		goto failed0;
+	}
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	mutex_lock(&the_lnet.ln_lnd_mutex);
+	lnd = lnet_find_lnd_by_type(lnd_type);
+
+	if (!lnd) {
+		mutex_unlock(&the_lnet.ln_lnd_mutex);
+		rc = request_module("%s", libcfs_lnd2modname(lnd_type));
 		mutex_lock(&the_lnet.ln_lnd_mutex);
-		lnd = lnet_find_lnd_by_type(lnd_type);
 
+		lnd = lnet_find_lnd_by_type(lnd_type);
 		if (lnd == NULL) {
 			mutex_unlock(&the_lnet.ln_lnd_mutex);
-			rc = request_module("%s",
-						libcfs_lnd2modname(lnd_type));
-			mutex_lock(&the_lnet.ln_lnd_mutex);
-
-			lnd = lnet_find_lnd_by_type(lnd_type);
-			if (lnd == NULL) {
-				mutex_unlock(&the_lnet.ln_lnd_mutex);
-				CERROR("Can't load LND %s, module %s, rc=%d\n",
-				       libcfs_lnd2str(lnd_type),
-				       libcfs_lnd2modname(lnd_type), rc);
-				goto failed;
-			}
+			CERROR("Can't load LND %s, module %s, rc=%d\n",
+			       libcfs_lnd2str(lnd_type),
+			       libcfs_lnd2modname(lnd_type), rc);
+			goto failed0;
 		}
+	}
+
+	lnet_net_lock(LNET_LOCK_EX);
+	lnd->lnd_refcount++;
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	ni->ni_lnd = lnd;
 
+	rc = lnd->lnd_startup(ni);
+
+	mutex_unlock(&the_lnet.ln_lnd_mutex);
+
+	if (rc != 0) {
+		LCONSOLE_ERROR_MSG(0x105, "Error %d starting up LNI %s\n",
+				   rc, libcfs_lnd2str(lnd->lnd_type));
 		lnet_net_lock(LNET_LOCK_EX);
-		lnd->lnd_refcount++;
+		lnd->lnd_refcount--;
 		lnet_net_unlock(LNET_LOCK_EX);
+		goto failed0;
+	}
 
-		ni->ni_lnd = lnd;
+	/*
+	 * If given some LND tunable parameters, parse those now to
+	 * override the values in the NI structure.
+	 */
+	if (peer_buf_cr >= 0)
+		ni->ni_peerrtrcredits = peer_buf_cr;
+	if (peer_timeout >= 0)
+		ni->ni_peertimeout = peer_timeout;
+	/*
+	 * TODO
+	 * Note: For now, don't allow the user to change
+	 * peertxcredits as this number is used in the
+	 * IB LND to control queue depth.
+	 * if (peer_cr != -1)
+	 *	ni->ni_peertxcredits = peer_cr;
+	 */
+	if (credits >= 0)
+		ni->ni_maxtxcredits = credits;
 
-		rc = (lnd->lnd_startup)(ni);
+	LASSERT(ni->ni_peertimeout <= 0 || lnd->lnd_query);
 
-		mutex_unlock(&the_lnet.ln_lnd_mutex);
+	lnet_net_lock(LNET_LOCK_EX);
+	/* refcount for ln_nis */
+	lnet_ni_addref_locked(ni, 0);
+	list_add_tail(&ni->ni_list, &the_lnet.ln_nis);
+	if (ni->ni_cpts) {
+		lnet_ni_addref_locked(ni, 0);
+		list_add_tail(&ni->ni_cptlist, &the_lnet.ln_nis_cpt);
+	}
 
-		if (rc != 0) {
-			LCONSOLE_ERROR_MSG(0x105, "Error %d starting up LNI %s\n",
-					   rc, libcfs_lnd2str(lnd->lnd_type));
-			lnet_net_lock(LNET_LOCK_EX);
-			lnd->lnd_refcount--;
-			lnet_net_unlock(LNET_LOCK_EX);
-			goto failed;
-		}
+	lnet_net_unlock(LNET_LOCK_EX);
 
+	if (lnd->lnd_type == LOLND) {
+		lnet_ni_addref(ni);
+		LASSERT(!the_lnet.ln_loni);
+		the_lnet.ln_loni = ni;
+		return 0;
+	}
+
+	if (ni->ni_peertxcredits == 0 || ni->ni_maxtxcredits == 0) {
+		LCONSOLE_ERROR_MSG(0x107, "LNI %s has no %scredits\n",
+				   libcfs_lnd2str(lnd->lnd_type),
+				   ni->ni_peertxcredits == 0 ?
+				   "" : "per-peer ");
 		/*
-		 * If given some LND tunable parameters, parse those now to
-		 * override the values in the NI structure.
-		 */
-		if (peer_buf_cr >= 0)
-			ni->ni_peerrtrcredits = peer_buf_cr;
-		if (peer_timeout >= 0)
-			ni->ni_peertimeout = peer_timeout;
-		/*
-		 * TODO
-		 * Note: For now, don't allow the user to change
-		 * peertxcredits as this number is used in the
-		 * IB LND to control queue depth.
-		 * if (peer_cr != -1)
-		 *	ni->ni_peertxcredits = peer_cr;
+		 * shutdown the NI since if we get here then it must've already
+		 * been started
 		 */
-		if (credits >= 0)
-			ni->ni_maxtxcredits = credits;
+		lnet_shutdown_lndni(ni);
+		return -EINVAL;
+	}
 
-		LASSERT(ni->ni_peertimeout <= 0 || lnd->lnd_query != NULL);
+	cfs_percpt_for_each(tq, i, ni->ni_tx_queues) {
+		tq->tq_credits_min =
+		tq->tq_credits_max =
+		tq->tq_credits = lnet_ni_tq_credits(ni);
+	}
 
-		list_del(&ni->ni_list);
+	CDEBUG(D_LNI, "Added LNI %s [%d/%d/%d/%d]\n",
+	       libcfs_nid2str(ni->ni_nid), ni->ni_peertxcredits,
+	       lnet_ni_tq_credits(ni) * LNET_CPT_NUMBER,
+	       ni->ni_peerrtrcredits, ni->ni_peertimeout);
 
-		lnet_net_lock(LNET_LOCK_EX);
-		/* refcount for ln_nis */
-		lnet_ni_addref_locked(ni, 0);
-		list_add_tail(&ni->ni_list, &the_lnet.ln_nis);
-		if (ni->ni_cpts != NULL) {
-			list_add_tail(&ni->ni_cptlist,
-					  &the_lnet.ln_nis_cpt);
-			lnet_ni_addref_locked(ni, 0);
-		}
-
-		lnet_net_unlock(LNET_LOCK_EX);
+	return 0;
+failed0:
+	lnet_ni_free(ni);
+	return -EINVAL;
+}
 
-		/* increment the ni_count here to account for the LOLND as
-		 * well.  If we increment past this point then the number
-		 * of count will be missing the LOLND, and then ping and
-		 * will not report the LOLND
-		 */
-		if (ni_count)
-			(*ni_count)++;
+static int
+lnet_startup_lndnis(struct list_head *nilist)
+{
+	struct lnet_ni *ni;
+	int rc;
+	int lnd_type;
+	int ni_count = 0;
 
-		if (lnd->lnd_type == LOLND) {
-			lnet_ni_addref(ni);
-			LASSERT(the_lnet.ln_loni == NULL);
-			the_lnet.ln_loni = ni;
-			continue;
-		}
+	while (!list_empty(nilist)) {
+		ni = list_entry(nilist->next, lnet_ni_t, ni_list);
+		list_del(&ni->ni_list);
+		rc = lnet_startup_lndni(ni, -1, -1, -1, -1);
 
-		if (ni->ni_peertxcredits == 0 ||
-		    ni->ni_maxtxcredits == 0) {
-			LCONSOLE_ERROR_MSG(0x107, "LNI %s has no %scredits\n",
-					   libcfs_lnd2str(lnd->lnd_type),
-					   ni->ni_peertxcredits == 0 ?
-					   "" : "per-peer ");
+		if (rc < 0)
 			goto failed;
-		}
 
-		cfs_percpt_for_each(tq, i, ni->ni_tx_queues) {
-			tq->tq_credits_min =
-			tq->tq_credits_max =
-			tq->tq_credits = lnet_ni_tq_credits(ni);
-		}
+		ni_count++;
+	}
 
-		CDEBUG(D_LNI, "Added LNI %s [%d/%d/%d/%d]\n",
-		       libcfs_nid2str(ni->ni_nid), ni->ni_peertxcredits,
-		       lnet_ni_tq_credits(ni) * LNET_CPT_NUMBER,
-		       ni->ni_peerrtrcredits, ni->ni_peertimeout);
+	if (the_lnet.ln_eq_waitni && ni_count > 1) {
+		lnd_type = the_lnet.ln_eq_waitni->ni_lnd->lnd_type;
+		LCONSOLE_ERROR_MSG(0x109, "LND %s can only run single-network\n",
+				   libcfs_lnd2str(lnd_type));
+		rc = -EINVAL;
+		goto failed;
 	}
 
-	return 0;
+	return ni_count;
 failed:
-	while (!list_empty(nilist)) {
-		ni = list_entry(nilist->next, lnet_ni_t, ni_list);
-		list_del(&ni->ni_list);
-		lnet_ni_free(ni);
-	}
-	return -EINVAL;
+	lnet_shutdown_lndnis();
+
+	return rc;
 }
 
 /**
@@ -1525,10 +1495,8 @@ int
 LNetNIInit(lnet_pid_t requested_pid)
 {
 	int im_a_router = 0;
-	int rc;
-	int ni_count = 0;
-	int lnd_type;
-	struct lnet_ni *ni;
+	int rc, rc2;
+	int ni_count;
 	lnet_ping_info_t *pinfo;
 	lnet_handle_md_t md_handle;
 	struct list_head net_head;
@@ -1547,37 +1515,50 @@ LNetNIInit(lnet_pid_t requested_pid)
 	}
 
 	rc = lnet_prepare(requested_pid);
-	if (rc != 0)
-		goto failed0;
+	if (rc != 0) {
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		return rc;
+	}
 
-	rc = lnet_parse_networks(&net_head,
-				 !the_lnet.ln_nis_from_mod_params ?
-				 lnet_get_networks() : "");
-	if (rc < 0)
-		goto failed1;
+	/* Add in the loopback network */
+	if (!lnet_ni_alloc(LNET_MKNET(LOLND, 0), NULL, &net_head)) {
+		rc = -ENOMEM;
+		goto failed0;
+	}
 
-	rc = lnet_startup_lndnis(&net_head, -1, -1, -1, -1, &ni_count);
-	if (rc != 0)
-		goto failed2;
+	/*
+	 * If LNet is being initialized via DLC it is possible
+	 * that the user requests not to load module parameters (ones which
+	 * are supported by DLC) on initialization.  Therefore, make sure not
+	 * to load networks, routes and forwarding from module parameters
+	 * in this case. On cleanup in case of failure only clean up
+	 * routes if it has been loaded
+	 */
+	if (!the_lnet.ln_nis_from_mod_params) {
+		rc = lnet_parse_networks(&net_head, lnet_get_networks());
+		if (rc < 0)
+			goto failed0;
+	}
 
-	if (the_lnet.ln_eq_waitni && ni_count > 1) {
-		lnd_type = the_lnet.ln_eq_waitni->ni_lnd->lnd_type;
-		LCONSOLE_ERROR_MSG(0x109, "LND %s can only run single-network\n",
-				   libcfs_lnd2str(lnd_type));
-		goto failed2;
+	ni_count = lnet_startup_lndnis(&net_head);
+	if (ni_count < 0) {
+		rc = ni_count;
+		goto failed0;
 	}
 
-	rc = lnet_parse_routes(lnet_get_routes(), &im_a_router);
-	if (rc != 0)
-		goto failed2;
+	if (!the_lnet.ln_nis_from_mod_params) {
+		rc = lnet_parse_routes(lnet_get_routes(), &im_a_router);
+		if (rc != 0)
+			goto failed1;
 
-	rc = lnet_check_routes();
-	if (rc != 0)
-		goto failed2;
+		rc = lnet_check_routes();
+		if (rc != 0)
+			goto failed2;
 
-	rc = lnet_rtrpools_alloc(im_a_router);
-	if (rc != 0)
-		goto failed2;
+		rc = lnet_rtrpools_alloc(im_a_router);
+		if (rc != 0)
+			goto failed2;
+	}
 
 	rc = lnet_acceptor_start();
 	if (rc != 0)
@@ -1603,22 +1584,25 @@ LNetNIInit(lnet_pid_t requested_pid)
 	return 0;
 
  failed4:
-	the_lnet.ln_refcount = 0;
 	lnet_ping_md_unlink(pinfo, &md_handle);
 	lnet_ping_info_free(pinfo);
+	rc2 = LNetEQFree(the_lnet.ln_ping_target_eq);
+	LASSERT(rc2 == 0);
  failed3:
+	the_lnet.ln_refcount = 0;
 	lnet_acceptor_stop();
-	rc = LNetEQFree(the_lnet.ln_ping_target_eq);
-	LASSERT(rc == 0);
  failed2:
-	lnet_destroy_routes();
-	lnet_shutdown_lndnis();
+	if (!the_lnet.ln_nis_from_mod_params)
+		lnet_destroy_routes();
  failed1:
-	lnet_unprepare();
+	lnet_shutdown_lndnis();
  failed0:
+	lnet_unprepare();
 	LASSERT(rc < 0);
 	mutex_unlock(&the_lnet.ln_api_mutex);
 	while (!list_empty(&net_head)) {
+		struct lnet_ni *ni;
+
 		ni = list_entry(net_head.next, struct lnet_ni, ni_list);
 		list_del_init(&ni->ni_list);
 		lnet_ni_free(ni);
@@ -1769,8 +1753,8 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, char *nets,
 
 	/* Create a ni structure for the network string */
 	rc = lnet_parse_networks(&net_head, nets);
-	if (rc < 0)
-		return rc;
+	if (rc <= 0)
+		return rc == 0 ? -EINVAL : rc;
 
 	mutex_lock(&the_lnet.ln_api_mutex);
 
@@ -1784,8 +1768,11 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, char *nets,
 	if (rc != 0)
 		goto failed0;
 
-	rc = lnet_startup_lndnis(&net_head, peer_timeout, peer_cr,
-				 peer_buf_cr, credits, NULL);
+	ni = list_entry(net_head.next, struct lnet_ni, ni_list);
+	list_del_init(&ni->ni_list);
+
+	rc = lnet_startup_lndni(ni, peer_timeout, peer_cr,
+				peer_buf_cr, credits);
 	if (rc != 0)
 		goto failed1;
 
@@ -1810,10 +1797,38 @@ failed0:
 int
 lnet_dyn_del_ni(__u32 net)
 {
+	lnet_ni_t *ni;
+	lnet_ping_info_t *pinfo;
+	lnet_handle_md_t md_handle;
 	int rc;
 
+	/* don't allow userspace to shutdown the LOLND */
+	if (LNET_NETTYP(net) == LOLND)
+		return -EINVAL;
+
 	mutex_lock(&the_lnet.ln_api_mutex);
-	rc = lnet_shutdown_lndni(net);
+	/* create and link a new ping info, before removing the old one */
+	rc = lnet_ping_info_setup(&pinfo, &md_handle,
+				  lnet_get_ni_count() - 1, false);
+	if (rc != 0)
+		goto out;
+
+	ni = lnet_net2ni(net);
+	if (!ni) {
+		rc = -EINVAL;
+		goto failed;
+	}
+
+	/* decrement the reference counter taken by lnet_net2ni() */
+	lnet_ni_decref_locked(ni, 0);
+
+	lnet_shutdown_lndni(ni);
+	lnet_ping_target_update(pinfo, md_handle);
+	goto out;
+failed:
+	lnet_ping_md_unlink(pinfo, &md_handle);
+	lnet_ping_info_free(pinfo);
+out:
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
 	return rc;
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index d1e0217..7b7412b 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -114,7 +114,7 @@ lnet_ni_free(struct lnet_ni *ni)
 	LIBCFS_FREE(ni, sizeof(*ni));
 }
 
-static lnet_ni_t *
+lnet_ni_t *
 lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist)
 {
 	struct lnet_tx_queue *tq;
@@ -191,6 +191,7 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 	struct lnet_ni *ni;
 	__u32 net;
 	int nnets = 0;
+	struct list_head *temp_node;
 
 	if (!networks) {
 		CERROR("networks string is undefined\n");
@@ -215,11 +216,6 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 	memcpy(tokens, networks, tokensize);
 	str = tmp = tokens;
 
-	/* Add in the loopback network */
-	ni = lnet_ni_alloc(LNET_MKNET(LOLND, 0), NULL, nilist);
-	if (ni == NULL)
-		goto failed;
-
 	while (str != NULL && *str != 0) {
 		char *comma = strchr(str, ',');
 		char *bracket = strchr(str, '(');
@@ -292,7 +288,6 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 			goto failed_syntax;
 		}
 
-		nnets++;
 		ni = lnet_ni_alloc(net, el, nilist);
 		if (ni == NULL)
 			goto failed;
@@ -370,10 +365,11 @@ lnet_parse_networks(struct list_head *nilist, char *networks)
 		}
 	}
 
-	LASSERT(!list_empty(nilist));
+	list_for_each(temp_node, nilist)
+		nnets++;
 
 	LIBCFS_FREE(tokens, tokensize);
-	return 0;
+	return nnets;
 
  failed_syntax:
 	lnet_syntax("networks", networks, (int)(tmp - tokens), strlen(tmp));
-- 
1.7.1
