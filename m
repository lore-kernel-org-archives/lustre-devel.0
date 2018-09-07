From: NeilBrown <neilb@suse.com>
Date: Fri, 07 Sep 2018 10:49:32 +1000
Subject: [lustre-devel] [PATCH 20/34] lnet: discard ni_cpt_list
In-Reply-To: <153628058697.8267.6056114844033479774.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
Message-ID: <153628137203.8267.14277020278461943610.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This isn't used any more.
The new comment is odd - this is no net_ni_cpt !!
The ni_cptlist linkage is no longer used - should it go too?

This is part of
    8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
       LU-7734 lnet: Multi-Rail local NI split

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    4 +---
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    7 -------
 2 files changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 6c34ecf22021..dc15fa75a9d2 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -305,7 +305,7 @@ struct lnet_net {
 struct lnet_ni {
 	/* chain on the lnet_net structure */
 	struct list_head	  ni_netlist;
-	/* chain on ln_nis_cpt */
+	/* chain on net_ni_cpt */
 	struct list_head	ni_cptlist;
 
 	spinlock_t		ni_lock;
@@ -671,8 +671,6 @@ struct lnet {
 
 	/* LND instances */
 	struct list_head		ln_nets;
-	/* NIs bond on specific CPT(s) */
-	struct list_head		ln_nis_cpt;
 	/* the loopback NI */
 	struct lnet_ni			*ln_loni;
 	/* network zombie list */
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 546d5101360f..960f235df5e7 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -538,7 +538,6 @@ lnet_prepare(lnet_pid_t requested_pid)
 
 	INIT_LIST_HEAD(&the_lnet.ln_test_peers);
 	INIT_LIST_HEAD(&the_lnet.ln_nets);
-	INIT_LIST_HEAD(&the_lnet.ln_nis_cpt);
 	INIT_LIST_HEAD(&the_lnet.ln_routers);
 	INIT_LIST_HEAD(&the_lnet.ln_drop_rules);
 	INIT_LIST_HEAD(&the_lnet.ln_delay_rules);
@@ -616,7 +615,6 @@ lnet_unprepare(void)
 	LASSERT(!the_lnet.ln_refcount);
 	LASSERT(list_empty(&the_lnet.ln_test_peers));
 	LASSERT(list_empty(&the_lnet.ln_nets));
-	LASSERT(list_empty(&the_lnet.ln_nis_cpt));
 
 	lnet_portals_destroy();
 
@@ -1294,11 +1292,6 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
 	/* refcount for ln_nis */
 	lnet_ni_addref_locked(ni, 0);
 	list_add_tail(&ni->ni_net->net_list, &the_lnet.ln_nets);
-	if (ni->ni_cpts) {
-		lnet_ni_addref_locked(ni, 0);
-		list_add_tail(&ni->ni_cptlist, &the_lnet.ln_nis_cpt);
-	}
-
 	lnet_net_unlock(LNET_LOCK_EX);
 
 	ni->ni_state = LNET_NI_STATE_ACTIVE;
