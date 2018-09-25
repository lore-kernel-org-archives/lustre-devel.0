From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:15 +1000
Subject: [lustre-devel] [PATCH 06/34] lnet: introduce
 lnet_find_peer_ni_locked()
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763508.32103.13303107512736711408.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Use in place of lnet_find_peer_locked()

This is part of
    Commit: 58091af960fe ("LU-7734 lnet: Multi-Rail peer split")
from upstream lustre, where it is marked:
    Signed-off-by: Amir Shehata <amir.shehata@intel.com>
    WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
    Reviewed-on: http://review.whamcloud.com/18293
    Reviewed-by: Olaf Weber <olaf@sgi.com>
    Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    1 +
 drivers/staging/lustre/lnet/lnet/peer.c            |   31 ++++++++++++++++++++
 drivers/staging/lustre/lnet/lnet/router.c          |    2 +
 3 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index f925e3cd64ca..656177b64336 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -639,6 +639,7 @@ bool lnet_ni_unique_net(struct list_head *nilist, char *iface);
 int lnet_nid2peerni_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt);
 struct lnet_peer_ni *lnet_find_peer_locked(struct lnet_peer_table *ptable,
 					   lnet_nid_t nid);
+struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid, int cpt);
 void lnet_peer_tables_cleanup(struct lnet_ni *ni);
 void lnet_peer_tables_destroy(void);
 int lnet_peer_tables_create(void);
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index fcfad77b9f2c..53b0ca0a2021 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -216,6 +216,37 @@ lnet_peer_tables_cleanup(struct lnet_ni *ni)
 	}
 }
 
+static struct lnet_peer_ni *
+lnet_get_peer_ni_locked(struct lnet_peer_table *ptable, lnet_nid_t nid)
+{
+	struct list_head	*peers;
+	struct lnet_peer_ni	*lp;
+
+	LASSERT(!the_lnet.ln_shutdown);
+
+	peers = &ptable->pt_hash[lnet_nid2peerhash(nid)];
+	list_for_each_entry(lp, peers, lpni_hashlist) {
+		if (lp->lpni_nid == nid) {
+			lnet_peer_ni_addref_locked(lp);
+			return lp;
+		}
+	}
+
+	return NULL;
+}
+
+struct lnet_peer_ni *
+lnet_find_peer_ni_locked(lnet_nid_t nid, int cpt)
+{
+	struct lnet_peer_ni *lpni;
+	struct lnet_peer_table *ptable;
+
+	ptable = the_lnet.ln_peer_tables[cpt];
+	lpni = lnet_get_peer_ni_locked(ptable, nid);
+
+	return lpni;
+}
+
 void
 lnet_destroy_peer_ni_locked(struct lnet_peer_ni *lp)
 {
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index ba2b2b930576..de037a77671d 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1734,7 +1734,7 @@ lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, int alive, time64_t when)
 		return -ESHUTDOWN;
 	}
 
-	lp = lnet_find_peer_locked(the_lnet.ln_peer_tables[cpt], nid);
+	lp = lnet_find_peer_ni_locked(nid, cpt);
 	if (!lp) {
 		/* nid not found */
 		lnet_net_unlock(cpt);
