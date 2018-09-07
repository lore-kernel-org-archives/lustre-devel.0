From: NeilBrown <neilb@suse.com>
Date: Fri, 07 Sep 2018 10:49:32 +1000
Subject: [lustre-devel] [PATCH 22/34] lnet: don't take reference in
 lnet_XX2ni_locked()
In-Reply-To: <153628058697.8267.6056114844033479774.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
Message-ID: <153628137211.8267.6066882916704220570.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

lnet_net2ni_locked() and lnet_nid2ni_locked() no longer take
a reference - as the lock is held, a ref isn't always needed.

Instead, introduce lnet_nid2ni_addref() which does take the reference
(but doesn't need the lock).
Various places which called lnet_net2ni_locked() or
lnet_nid2ni_locked() no longer need to drop the ref afterwards.

This is part of
    8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
       LU-7734 lnet: Multi-Rail local NI split

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    1 +
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    2 +
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 +
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   27 +++++++++++++-------
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   17 +------------
 5 files changed, 21 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 54a93235834c..6401d9a37b23 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -398,6 +398,7 @@ extern int avoid_asym_router_failure;
 int lnet_cpt_of_nid_locked(lnet_nid_t nid, struct lnet_ni *ni);
 int lnet_cpt_of_nid(lnet_nid_t nid, struct lnet_ni *ni);
 struct lnet_ni *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
+struct lnet_ni *lnet_nid2ni_addref(lnet_nid_t nid);
 struct lnet_ni *lnet_net2ni_locked(__u32 net, int cpt);
 struct lnet_ni *lnet_net2ni(__u32 net);
 bool lnet_is_ni_healthy_locked(struct lnet_ni *ni);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index e64c14914924..af8f863b6a68 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2294,7 +2294,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	}
 
 	nid = reqmsg->ibm_srcnid;
-	ni = lnet_net2ni(LNET_NIDNET(reqmsg->ibm_dstnid));
+	ni = lnet_nid2ni_addref(reqmsg->ibm_dstnid);
 
 	if (ni) {
 		net = (struct kib_net *)ni->ni_data;
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 88b90c1fdbaf..25205f686801 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -296,7 +296,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 	if (flip)
 		__swab64s(&cr.acr_nid);
 
-	ni = lnet_net2ni(LNET_NIDNET(cr.acr_nid));
+	ni = lnet_nid2ni_addref(cr.acr_nid);
 	if (!ni ||	       /* no matching net */
 	    ni->ni_nid != cr.acr_nid) { /* right NET, wrong NID! */
 		if (ni)
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index ce3dd0f32e12..42e775e2a669 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -655,7 +655,6 @@ lnet_net2ni_locked(__u32 net_id, int cpt)
 		if (net->net_id == net_id) {
 			ni = list_entry(net->net_ni_list.next, struct lnet_ni,
 					ni_netlist);
-			lnet_ni_addref_locked(ni, cpt);
 			return ni;
 		}
 	}
@@ -794,16 +793,29 @@ lnet_nid2ni_locked(lnet_nid_t nid, int cpt)
 
 	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
 		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
-			if (ni->ni_nid == nid) {
-				lnet_ni_addref_locked(ni, cpt);
+			if (ni->ni_nid == nid)
 				return ni;
-			}
 		}
 	}
 
 	return NULL;
 }
 
+struct lnet_ni *
+lnet_nid2ni_addref(lnet_nid_t nid)
+{
+	struct lnet_ni *ni;
+
+	lnet_net_lock(0);
+	ni = lnet_nid2ni_locked(nid, 0);
+	if (ni)
+		lnet_ni_addref_locked(ni, 0);
+	lnet_net_unlock(0);
+
+	return ni;
+}
+EXPORT_SYMBOL(lnet_nid2ni_addref);
+
 int
 lnet_islocalnid(lnet_nid_t nid)
 {
@@ -812,8 +824,6 @@ lnet_islocalnid(lnet_nid_t nid)
 
 	cpt = lnet_net_lock_current();
 	ni = lnet_nid2ni_locked(nid, cpt);
-	if (ni)
-		lnet_ni_decref_locked(ni, cpt);
 	lnet_net_unlock(cpt);
 
 	return !!ni;
@@ -1412,6 +1422,7 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
 		if (rc < 0)
 			goto failed1;
 
+		lnet_ni_addref(ni);
 		list_add_tail(&ni->ni_netlist, &local_ni_list);
 
 		ni_count++;
@@ -2032,9 +2043,6 @@ lnet_dyn_del_ni(__u32 net)
 		goto failed;
 	}
 
-	/* decrement the reference counter taken by lnet_net2ni() */
-	lnet_ni_decref_locked(ni, 0);
-
 	lnet_shutdown_lndni(ni);
 
 	if (!lnet_count_acceptor_nets())
@@ -2264,7 +2272,6 @@ LNetCtl(unsigned int cmd, void *arg)
 		else
 			rc = ni->ni_net->net_lnd->lnd_ctl(ni, cmd, arg);
 
-		lnet_ni_decref(ni);
 		return rc;
 	}
 	/* not reached */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 00a89221c9b3..60f34c4b85d3 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1127,11 +1127,7 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 		if (!src_ni) {
 			src_ni = local_ni;
 			src_nid = src_ni->ni_nid;
-		} else if (src_ni == local_ni) {
-			lnet_ni_decref_locked(local_ni, cpt);
-		} else {
-			lnet_ni_decref_locked(local_ni, cpt);
-			lnet_ni_decref_locked(src_ni, cpt);
+		} else if (src_ni != local_ni) {
 			lnet_net_unlock(cpt);
 			LCONSOLE_WARN("No route to %s via from %s\n",
 				      libcfs_nid2str(dst_nid),
@@ -1149,16 +1145,10 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 			/* No send credit hassles with LOLND */
 			lnet_net_unlock(cpt);
 			lnet_ni_send(src_ni, msg);
-
-			lnet_net_lock(cpt);
-			lnet_ni_decref_locked(src_ni, cpt);
-			lnet_net_unlock(cpt);
 			return 0;
 		}
 
 		rc = lnet_nid2peer_locked(&lp, dst_nid, cpt);
-		/* lp has ref on src_ni; lose mine */
-		lnet_ni_decref_locked(src_ni, cpt);
 		if (rc) {
 			lnet_net_unlock(cpt);
 			LCONSOLE_WARN("Error %d finding peer %s\n", rc,
@@ -1173,8 +1163,6 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 					    src_ni->ni_net : NULL,
 					    dst_nid, rtr_nid);
 		if (!lp) {
-			if (src_ni)
-				lnet_ni_decref_locked(src_ni, cpt);
 			lnet_net_unlock(cpt);
 
 			LCONSOLE_WARN("No route to %s via %s (all routers down)\n",
@@ -1192,8 +1180,6 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 		if (rtr_nid != lp->lp_nid) {
 			cpt2 = lp->lp_cpt;
 			if (cpt2 != cpt) {
-				if (src_ni)
-					lnet_ni_decref_locked(src_ni, cpt);
 				lnet_net_unlock(cpt);
 
 				rtr_nid = lp->lp_nid;
@@ -1212,7 +1198,6 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 			src_nid = src_ni->ni_nid;
 		} else {
 			LASSERT(src_ni->ni_net == lp->lp_net);
-			lnet_ni_decref_locked(src_ni, cpt);
 		}
 
 		lnet_peer_addref_locked(lp);
