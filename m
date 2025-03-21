Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 31134C36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:18:33 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2nw3Wywz1xh4;
	Fri, 21 Mar 2025 06:08:52 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2mq19L5z1xp1
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:07:55 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm4-e204-208.ccs.ornl.gov [160.91.203.22])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7636D17B5A5;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 74805106BE14; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:54 -0400
Message-ID: <20250321130711.3257092-12-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 11/27] lnet: remove unused,
 fix non-static functions
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Timothy Day <timday@amazon.com>

lnet_net_is_pref_rtr_locked() is never called.
This patch removes this function.

Static analysis shows that a number of functions
could be made static. This patch also declares
several functions in lnet static.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8191
Lustre-commit: 43cbc93f1edc493e4 ("LU-8191 lnet: remove unused, fix non-static functions")
Signed-off-by: Timothy Day <timday@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51436
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c |  2 +-
 net/lnet/klnds/socklnd/socklnd.c |  2 +-
 net/lnet/lnet/api-ni.c           | 31 ++++---------------------------
 net/lnet/lnet/lib-move.c         |  4 ++--
 net/lnet/lnet/lib-msg.c          |  4 ++--
 net/lnet/lnet/module.c           |  4 ++--
 net/lnet/lnet/peer.c             |  4 ++--
 net/lnet/selftest/conctl.c       |  2 +-
 8 files changed, 15 insertions(+), 38 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index c954df32ab50..b9d6b2477e2d 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2390,7 +2390,7 @@ kiblnd_set_ni_fatal_on(struct kib_hca_dev *hdev, int val)
 		lnet_update_ping_buffer();
 }
 
-void
+static void
 kiblnd_event_handler(struct ib_event_handler *handler, struct ib_event *event)
 {
 	rwlock_t *g_lock = &kiblnd_data.kib_global_lock;
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index d8fc20d18d44..2db7fc0b0e48 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1655,7 +1655,7 @@ ksocknal_close_matching_conns(struct lnet_processid *id, u32 ipaddr)
 	return count ? 0 : -ENOENT;
 }
 
-void
+static void
 ksocknal_notify_gw_down(struct lnet_nid *gw_nid)
 {
 	/* The router is telling me she's been notified of a change in
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index d65ccb4e78aa..d87bc33b1103 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1505,29 +1505,6 @@ __must_hold(&the_lnet.ln_api_mutex)
 	return 0;
 }
 
-bool
-lnet_net_is_pref_rtr_locked(struct lnet_net *net, struct lnet_nid *rtr_nid)
-{
-	struct lnet_nid_list *ne;
-
-	CDEBUG(D_NET, "%s: rtr pref empty: %d\n",
-	       libcfs_net2str(net->net_id),
-	       list_empty(&net->net_rtr_pref_nids));
-
-	if (list_empty(&net->net_rtr_pref_nids))
-		return false;
-
-	list_for_each_entry(ne, &net->net_rtr_pref_nids, nl_list) {
-		CDEBUG(D_NET, "Comparing pref %s with gw %s\n",
-		       libcfs_nidstr(&ne->nl_nid),
-		       libcfs_nidstr(rtr_nid));
-		if (nid_same(rtr_nid, &ne->nl_nid))
-			return true;
-	}
-
-	return false;
-}
-
 static unsigned int
 lnet_nid4_cpt_hash(lnet_nid_t nid, unsigned int number)
 {
@@ -3388,7 +3365,7 @@ lnet_get_net_config(struct lnet_ioctl_config_data *config)
 	return rc;
 }
 
-int
+static int
 lnet_get_ni_config(struct lnet_ioctl_config_ni *cfg_ni,
 		   struct lnet_ioctl_config_lnd_tunables *tun,
 		   struct lnet_ioctl_element_stats *stats,
@@ -3415,7 +3392,7 @@ lnet_get_ni_config(struct lnet_ioctl_config_ni *cfg_ni,
 	return rc;
 }
 
-int lnet_get_ni_stats(struct lnet_ioctl_element_msg_stats *msg_stats)
+static int lnet_get_ni_stats(struct lnet_ioctl_element_msg_stats *msg_stats)
 {
 	struct lnet_ni *ni;
 	int cpt;
@@ -5379,8 +5356,8 @@ static int lnet_route_show_done(struct netlink_callback *cb)
 	return 0;
 }
 
-int lnet_scan_route(struct lnet_genl_route_list *rlist,
-		    struct lnet_route_properties *settings)
+static int lnet_scan_route(struct lnet_genl_route_list *rlist,
+			   struct lnet_route_properties *settings)
 {
 	struct lnet_remotenet *rnet;
 	struct list_head *rn_list;
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index d9f5eb94ff6e..48b65aeb0bc1 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1890,7 +1890,7 @@ lnet_handle_spec_local_mr_dst(struct lnet_send_data *sd)
 	return -EHOSTUNREACH;
 }
 
-struct lnet_ni *
+static struct lnet_ni *
 lnet_find_best_ni_on_spec_net(struct lnet_ni *cur_best_ni,
 			      struct lnet_peer *peer,
 			      struct lnet_peer_net *peer_net,
@@ -2248,7 +2248,7 @@ lnet_handle_spec_router_dst(struct lnet_send_data *sd)
 	return lnet_handle_send(sd);
 }
 
-struct lnet_ni *
+static struct lnet_ni *
 lnet_find_best_ni_on_local_net(struct lnet_peer *peer, int md_cpt,
 			       struct lnet_msg *msg, bool discovery)
 {
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 420236dfaf52..af2a295d8bf0 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -628,7 +628,7 @@ lnet_resend_msg_locked(struct lnet_msg *msg)
 	complete(&the_lnet.ln_mt_wait_complete);
 }
 
-int
+static int
 lnet_check_finalize_recursion_locked(struct lnet_msg *msg,
 				     struct list_head *containerq,
 				     int nworkers, void **workers)
@@ -654,7 +654,7 @@ lnet_check_finalize_recursion_locked(struct lnet_msg *msg,
 	return my_slot;
 }
 
-int
+static int
 lnet_attempt_msg_resend(struct lnet_msg *msg)
 {
 	struct lnet_msg_container *container;
diff --git a/net/lnet/lnet/module.c b/net/lnet/lnet/module.c
index 6e41e4b985cd..e6e34dcad90e 100644
--- a/net/lnet/lnet/module.c
+++ b/net/lnet/lnet/module.c
@@ -41,7 +41,7 @@ MODULE_PARM_DESC(config_on_load, "configure network at module load");
 
 static DEFINE_MUTEX(lnet_config_mutex);
 
-int lnet_configure(void *arg)
+static int lnet_configure(void *arg)
 {
 	/* 'arg' only there so I can be passed to cfs_create_thread() */
 	int rc = 0;
@@ -67,7 +67,7 @@ int lnet_configure(void *arg)
 	return rc;
 }
 
-int lnet_unconfigure(void)
+static int lnet_unconfigure(void)
 {
 	int refcount;
 
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 0aa4a77ab0d4..061afcf5e63e 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1090,7 +1090,7 @@ lnet_peer_ni_set_non_mr_pref_nid(struct lnet_peer_ni *lpni,
  * Clear the preferred NID from a non-multi-rail peer_ni, provided
  * this preference was set by lnet_peer_ni_set_non_mr_pref_nid().
  */
-int
+static int
 lnet_peer_ni_clr_non_mr_pref_nid(struct lnet_peer_ni *lpni)
 {
 	int rc = 0;
@@ -1120,7 +1120,7 @@ lnet_peer_ni_set_selection_priority(struct lnet_peer_ni *lpni, u32 priority)
 /*
  * Clear the preferred NIDs from a non-multi-rail peer.
  */
-void
+static void
 lnet_peer_clr_non_mr_pref_nids(struct lnet_peer *lp)
 {
 	struct lnet_peer_ni *lpni = NULL;
diff --git a/net/lnet/selftest/conctl.c b/net/lnet/selftest/conctl.c
index f79368448d3e..9d3e3268731e 100644
--- a/net/lnet/selftest/conctl.c
+++ b/net/lnet/selftest/conctl.c
@@ -921,7 +921,7 @@ static char *lst_node_state2str(int state)
 	return "Unknown";
 }
 
-int lst_node_str2state(char *str)
+static int lst_node_str2state(char *str)
 {
 	int state = 0;
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
