From: NeilBrown <neilb@suse.com>
Date: Fri, 07 Sep 2018 10:49:32 +1000
Subject: [lustre-devel] [PATCH 21/34] lnet: add net_ni_added
In-Reply-To: <153628058697.8267.6056114844033479774.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
Message-ID: <153628137207.8267.8628833457984431545.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

When we allocate an ni, it is now added to the new net_ni_added
list of unstarted interfaces.
lnet_startup_lndnet() now starts all those added interfaces.

This is part of
    8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
       LU-7734 lnet: Multi-Rail local NI split

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    3 ++
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   39 +++++++++++++++++---
 drivers/staging/lustre/lnet/lnet/config.c          |   13 ++++++-
 3 files changed, 48 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index dc15fa75a9d2..1faa247a93b8 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -298,6 +298,9 @@ struct lnet_net {
 	/* list of NIs on this net */
 	struct list_head	net_ni_list;
 
+	/* list of NIs being added, but not started yet */
+	struct list_head	net_ni_added;
+
 	/* dying LND instances */
 	struct list_head	net_ni_zombie;
 };
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 960f235df5e7..ce3dd0f32e12 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1350,12 +1350,15 @@ static int
 lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
 {
 	struct lnet_ni		*ni;
+	struct list_head	local_ni_list;
+	int			rc;
+	int			ni_count = 0;
 	__u32			lnd_type;
 	struct lnet_lnd		*lnd;
-	int			rc;
 
 	lnd_type = LNET_NETTYP(net->net_id);
 
+	INIT_LIST_HEAD(&local_ni_list);
 	LASSERT(libcfs_isknown_lnd(lnd_type));
 
 	/* Make sure this new NI is unique. */
@@ -1399,12 +1402,36 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
 	net->net_lnd = lnd;
 	mutex_unlock(&the_lnet.ln_lnd_mutex);
 
-	ni = list_first_entry(&net->net_ni_list, struct lnet_ni, ni_netlist);
+	while (!list_empty(&net->net_ni_added)) {
+		ni = list_entry(net->net_ni_added.next, struct lnet_ni,
+				ni_netlist);
+		list_del_init(&ni->ni_netlist);
 
-	rc = lnet_startup_lndni(ni, tun);
-	if (rc < 0)
-		return rc;
-	return 1;
+		rc = lnet_startup_lndni(ni, tun);
+
+		if (rc < 0)
+			goto failed1;
+
+		list_add_tail(&ni->ni_netlist, &local_ni_list);
+
+		ni_count++;
+	}
+	lnet_net_lock(LNET_LOCK_EX);
+	list_splice_tail(&local_ni_list, &net->net_ni_list);
+	lnet_net_unlock(LNET_LOCK_EX);
+	return ni_count;
+
+failed1:
+	/*
+	 * shutdown the new NIs that are being started up
+	 * free the NET being started
+	 */
+	while (!list_empty(&local_ni_list)) {
+		ni = list_entry(local_ni_list.next, struct lnet_ni,
+				ni_netlist);
+
+		lnet_shutdown_lndni(ni);
+	}
 
 failed0:
 	lnet_net_free(net);
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 081812e19b13..f886dcfc6d6e 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -281,6 +281,16 @@ lnet_net_free(struct lnet_net *net)
 
 	LASSERT(list_empty(&net->net_ni_zombie));
 
+	/*
+	 * delete any nis that haven't been added yet. This could happen
+	 * if there is a failure on net startup
+	 */
+	list_for_each_safe(tmp, tmp2, &net->net_ni_added) {
+		ni = list_entry(tmp, struct lnet_ni, ni_netlist);
+		list_del_init(&ni->ni_netlist);
+		lnet_ni_free(ni);
+	}
+
 	/* delete any nis which have been started. */
 	list_for_each_safe(tmp, tmp2, &net->net_ni_list) {
 		ni = list_entry(tmp, struct lnet_ni, ni_netlist);
@@ -314,6 +324,7 @@ lnet_net_alloc(__u32 net_id, struct list_head *net_list)
 
 	INIT_LIST_HEAD(&net->net_list);
 	INIT_LIST_HEAD(&net->net_ni_list);
+	INIT_LIST_HEAD(&net->net_ni_added);
 	INIT_LIST_HEAD(&net->net_ni_zombie);
 
 	net->net_id = net_id;
@@ -397,7 +408,7 @@ lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el, char *iface)
 	rc = lnet_net_append_cpts(ni->ni_cpts, ni->ni_ncpts, net);
 	if (rc != 0)
 		goto failed;
-	list_add_tail(&ni->ni_netlist, &net->net_ni_list);
+	list_add_tail(&ni->ni_netlist, &net->net_ni_added);
 
 	return ni;
 failed:
