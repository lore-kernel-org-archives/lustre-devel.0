Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 64D8FC433FE
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:39 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0BR0S4Hz21H8;
	Fri, 14 Oct 2022 14:38:39 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0B33njJz1y2t
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:19 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id F349A1006F31;
 Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E71B1DEE01; Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:37:56 -0400
Message-Id: <1665783491-13827-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/20] lnet: track pinginfo size in bytes,
 not nis.
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

When we extend the pinginfo to be able to store large-address nids,
there could be nids of different sizes in it.  So using the number of
nis to track the size won't work.  So change to using the number of
bytes.  i.e.  the total size of the 'struct lnet_ping_info'.

This affects pb_nnis in the ping_buffer, and the global
ln_push_target_nnis.

LNET_PING_INFO_SIZE is removed as size won't depend on number of nids
any more.

When determining the number of bytes expected in a received ping_info,
use a new macro lnet_ping_info_size() which can extract information
as required from the ping_info.

Note that lnet_ping_target_create() now initializes pi_nis to 0.
Setting the initial size doesn't seem to be useful.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 941218e09e1d6bb9b ("LU-10391 lnet: track pinginfo size in bytes, not nis.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/44627
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h      |   6 +-
 include/linux/lnet/lib-types.h     |  13 ++-
 include/uapi/linux/lnet/lnet-idl.h |   8 +-
 net/lnet/lnet/api-ni.c             | 180 ++++++++++++++++-------------
 net/lnet/lnet/lib-move.c           |  10 +-
 net/lnet/lnet/lib-msg.c            |  14 +--
 net/lnet/lnet/peer.c               |  58 +++++-----
 7 files changed, 157 insertions(+), 132 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index fc086dab080e..a95919e69802 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -646,7 +646,7 @@ void lnet_prep_send(struct lnet_msg *msg, int type,
 int lnet_send(struct lnet_nid *nid, struct lnet_msg *msg,
 	      struct lnet_nid *rtr_nid);
 int lnet_send_ping(struct lnet_nid *dest_nid, struct lnet_handle_md *mdh,
-		   int nnis, void *user_ptr, lnet_handler_t handler,
+		   int bytes, void *user_ptr, lnet_handler_t handler,
 		   bool recovery);
 void lnet_return_tx_credits_locked(struct lnet_msg *msg);
 void lnet_return_rx_credits_locked(struct lnet_msg *msg);
@@ -860,7 +860,7 @@ void lnet_wait_router_start(void);
 void lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf);
 
 int lnet_ping_info_validate(struct lnet_ping_info *pinfo);
-struct lnet_ping_buffer *lnet_ping_buffer_alloc(int nnis, gfp_t gfp);
+struct lnet_ping_buffer *lnet_ping_buffer_alloc(int bytes, gfp_t gfp);
 void lnet_ping_buffer_free(struct lnet_ping_buffer *pbuf);
 
 static inline void lnet_ping_buffer_addref(struct lnet_ping_buffer *pbuf)
@@ -878,7 +878,7 @@ static inline void lnet_ping_buffer_decref(struct lnet_ping_buffer *pbuf)
 
 static inline int lnet_push_target_resize_needed(void)
 {
-	return the_lnet.ln_push_target->pb_nnis < the_lnet.ln_push_target_nnis;
+	return the_lnet.ln_push_target->pb_nbytes < the_lnet.ln_push_target_nbytes;
 }
 
 int lnet_push_target_resize(void);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 2266d1be16a6..499385bb981b 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -567,14 +567,14 @@ struct lnet_ni {
  * area that may be overwritten by network data.
  */
 struct lnet_ping_buffer {
-	int			pb_nnis;
+	int			pb_nbytes;	/* sizeof pb_info */
 	atomic_t		pb_refcnt;
 	bool			pb_needs_post;
 	struct lnet_ping_info	pb_info;
 };
 
-#define LNET_PING_BUFFER_SIZE(NNIDS) \
-	offsetof(struct lnet_ping_buffer, pb_info.pi_ni[NNIDS])
+#define LNET_PING_BUFFER_SIZE(bytes) \
+	(offsetof(struct lnet_ping_buffer, pb_info) + bytes)
 #define LNET_PING_BUFFER_LONI(PBUF)	((PBUF)->pb_info.pi_ni[0].ns_nid)
 #define LNET_PING_BUFFER_SEQNO(PBUF)	((PBUF)->pb_info.pi_ni[0].ns_status)
 
@@ -733,8 +733,8 @@ struct lnet_peer {
 	/* MD handle for push in progress */
 	struct lnet_handle_md	lp_push_mdh;
 
-	/* number of NIDs for sizing push data */
-	int			lp_data_nnis;
+	/* number of bytes for sizing pb_info in push data */
+	int			lp_data_bytes;
 
 	/* NI config sequence number of peer */
 	u32			lp_peer_seqno;
@@ -1255,7 +1255,8 @@ struct lnet {
 	lnet_handler_t			ln_push_target_handler;
 	struct lnet_handle_md		ln_push_target_md;
 	struct lnet_ping_buffer	       *ln_push_target;
-	int				ln_push_target_nnis;
+	/* bytes needed for pb_info to receive push */
+	int				ln_push_target_nbytes;
 
 	/* discovery event queue handle */
 	lnet_handler_t			ln_dc_handler;
diff --git a/include/uapi/linux/lnet/lnet-idl.h b/include/uapi/linux/lnet/lnet-idl.h
index 74036e7ef406..41bbb404af6c 100644
--- a/include/uapi/linux/lnet/lnet-idl.h
+++ b/include/uapi/linux/lnet/lnet-idl.h
@@ -291,9 +291,13 @@ struct lnet_ping_info {
 	struct lnet_ni_status	pi_ni[0];
 } __attribute__((packed));
 
-#define LNET_PING_INFO_SIZE(NNIDS) \
-	offsetof(struct lnet_ping_info, pi_ni[NNIDS])
+#define LNET_PING_INFO_HDR_SIZE \
+	offsetof(struct lnet_ping_info, pi_ni[0])
+#define LNET_PING_INFO_MIN_SIZE \
+	offsetof(struct lnet_ping_info, pi_ni[LNET_INTERFACES_MIN])
 #define LNET_PING_INFO_LONI(PINFO)      ((PINFO)->pi_ni[0].ns_nid)
 #define LNET_PING_INFO_SEQNO(PINFO)     ((PINFO)->pi_ni[0].ns_status)
+#define lnet_ping_info_size(pinfo)	\
+	offsetof(struct lnet_ping_info, pi_ni[(pinfo)->pi_nnis])
 
 #endif
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 89c7b99e45be..9459fc0f103f 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1720,13 +1720,13 @@ lnet_count_acceptor_nets(void)
 }
 
 struct lnet_ping_buffer *
-lnet_ping_buffer_alloc(int nnis, gfp_t gfp)
+lnet_ping_buffer_alloc(int nbytes, gfp_t gfp)
 {
 	struct lnet_ping_buffer *pbuf;
 
-	pbuf = kmalloc(LNET_PING_BUFFER_SIZE(nnis), gfp);
+	pbuf = kmalloc(LNET_PING_BUFFER_SIZE(nbytes), gfp);
 	if (pbuf) {
-		pbuf->pb_nnis = nnis;
+		pbuf->pb_nbytes = nbytes;	/* sizeof of pb_info */
 		pbuf->pb_needs_post = false;
 		atomic_set(&pbuf->pb_refcnt, 1);
 	}
@@ -1742,17 +1742,17 @@ lnet_ping_buffer_free(struct lnet_ping_buffer *pbuf)
 }
 
 static struct lnet_ping_buffer *
-lnet_ping_target_create(int nnis)
+lnet_ping_target_create(int nbytes)
 {
 	struct lnet_ping_buffer *pbuf;
 
-	pbuf = lnet_ping_buffer_alloc(nnis, GFP_KERNEL);
+	pbuf = lnet_ping_buffer_alloc(nbytes, GFP_KERNEL);
 	if (!pbuf) {
-		CERROR("Can't allocate ping source [%d]\n", nnis);
+		CERROR("Can't allocate ping source [%d]\n", nbytes);
 		return NULL;
 	}
 
-	pbuf->pb_info.pi_nnis = nnis;
+	pbuf->pb_info.pi_nnis = 0;
 	pbuf->pb_info.pi_pid = the_lnet.ln_pid;
 	pbuf->pb_info.pi_magic = LNET_PROTO_PING_MAGIC;
 	pbuf->pb_info.pi_features =
@@ -1762,52 +1762,56 @@ lnet_ping_target_create(int nnis)
 }
 
 static inline int
-lnet_get_net_ni_count_locked(struct lnet_net *net)
+lnet_get_net_ni_bytes_locked(struct lnet_net *net)
 {
 	struct lnet_ni *ni;
-	int count = 0;
+	int bytes = 0;
 
 	list_for_each_entry(ni, &net->net_ni_list, ni_netlist)
-		count++;
+		if (nid_is_nid4(&ni->ni_nid))
+			bytes += sizeof(struct lnet_ni_status);
 
-	return count;
+	return bytes;
 }
 
 static inline int
-lnet_get_net_ni_count_pre(struct lnet_net *net)
+lnet_get_net_ni_bytes_pre(struct lnet_net *net)
 {
 	struct lnet_ni *ni;
-	int count = 0;
+	int bytes = 0;
 
 	list_for_each_entry(ni, &net->net_ni_added, ni_netlist)
-		count++;
+		if (nid_is_nid4(&ni->ni_nid))
+			bytes += sizeof(struct lnet_ni_status);
 
-	return count;
+	return bytes;
 }
 
 static inline int
-lnet_get_ni_count(void)
+lnet_get_ni_bytes(void)
 {
 	struct lnet_ni *ni;
 	struct lnet_net *net;
-	int count = 0;
+	int bytes = 0;
 
 	lnet_net_lock(0);
 
 	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
 		list_for_each_entry(ni, &net->net_ni_list, ni_netlist)
-			count++;
+			if (nid_is_nid4(&ni->ni_nid))
+				bytes += sizeof(struct lnet_ni_status);
+
 	}
 
 	lnet_net_unlock(0);
 
-	return count;
+	return bytes;
 }
 
 void
 lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf)
 {
-	struct lnet_ni_status *stat;
+	struct lnet_ni_status *stat, *end;
 	int nnis;
 	int i;
 
@@ -1816,10 +1820,9 @@ lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf)
 	__swab32s(&pbuf->pb_info.pi_pid);
 	__swab32s(&pbuf->pb_info.pi_nnis);
 	nnis = pbuf->pb_info.pi_nnis;
-	if (nnis > pbuf->pb_nnis)
-		nnis = pbuf->pb_nnis;
-	for (i = 0; i < nnis; i++) {
-		stat = &pbuf->pb_info.pi_ni[i];
+	stat = &pbuf->pb_info.pi_ni[0];
+	end = (void *)&pbuf->pb_info + pbuf->pb_nbytes;
+	for (i = 0; i < nnis && stat + 1 <= end; i++, stat++) {
 		__swab64s(&stat->ns_nid);
 		__swab32s(&stat->ns_status);
 	}
@@ -1876,7 +1879,7 @@ lnet_ping_target_event_handler(struct lnet_event *event)
 static int
 lnet_ping_target_setup(struct lnet_ping_buffer **ppbuf,
 		       struct lnet_handle_md *ping_mdh,
-		       int ni_count, bool set_eq)
+		       int ni_bytes, bool set_eq)
 {
 	struct lnet_processid id = {
 		.nid = LNET_ANY_NID,
@@ -1890,7 +1893,7 @@ lnet_ping_target_setup(struct lnet_ping_buffer **ppbuf,
 		the_lnet.ln_ping_target_handler =
 			lnet_ping_target_event_handler;
 
-	*ppbuf = lnet_ping_target_create(ni_count);
+	*ppbuf = lnet_ping_target_create(ni_bytes);
 	if (!*ppbuf) {
 		rc = -ENOMEM;
 		goto fail_free_eq;
@@ -1908,7 +1911,7 @@ lnet_ping_target_setup(struct lnet_ping_buffer **ppbuf,
 
 	/* initialize md content */
 	md.start = &(*ppbuf)->pb_info;
-	md.length = LNET_PING_INFO_SIZE((*ppbuf)->pb_nnis);
+	md.length = (*ppbuf)->pb_nbytes;
 	md.threshold = LNET_MD_THRESH_INF;
 	md.max_size = 0;
 	md.options = LNET_MD_OP_GET | LNET_MD_TRUNCATE |
@@ -1949,20 +1952,19 @@ lnet_ping_md_unlink(struct lnet_ping_buffer *pbuf,
 static void
 lnet_ping_target_install_locked(struct lnet_ping_buffer *pbuf)
 {
-	struct lnet_ni_status *ns;
+	struct lnet_ni_status *ns, *end;
 	struct lnet_ni *ni;
 	struct lnet_net *net;
-	int i = 0;
 	int rc;
 
+	pbuf->pb_info.pi_nnis = 0;
+	ns = &pbuf->pb_info.pi_ni[0];
+	end = (void *)&pbuf->pb_info + pbuf->pb_nbytes;
 	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
 		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
-			LASSERT(i < pbuf->pb_nnis);
-
-			ns = &pbuf->pb_info.pi_ni[i];
-
 			if (!nid_is_nid4(&ni->ni_nid))
 				continue;
+			LASSERT(ns + 1 <= end);
 			ns->ns_nid = lnet_nid_to_nid4(&ni->ni_nid);
 
 			lnet_ni_lock(ni);
@@ -1970,11 +1972,12 @@ lnet_ping_target_install_locked(struct lnet_ping_buffer *pbuf)
 			ni->ni_status = &ns->ns_status;
 			lnet_ni_unlock(ni);
 
-			i++;
+			pbuf->pb_info.pi_nnis++;
+			ns++;
 		}
 	}
-	/*
-	 * We (ab)use the ns_status of the loopback interface to
+
+	/* We (ab)use the ns_status of the loopback interface to
 	 * transmit the sequence number. The first interface listed
 	 * must be the loopback interface.
 	 */
@@ -2043,13 +2046,13 @@ int lnet_push_target_resize(void)
 	struct lnet_handle_md old_mdh;
 	struct lnet_ping_buffer *pbuf;
 	struct lnet_ping_buffer *old_pbuf;
-	int nnis;
+	int nbytes;
 	int rc;
 
 again:
-	nnis = the_lnet.ln_push_target_nnis;
-	if (nnis <= 0) {
-		CDEBUG(D_NET, "Invalid nnis %d\n", nnis);
+	nbytes = the_lnet.ln_push_target_nbytes;
+	if (nbytes <= 0) {
+		CDEBUG(D_NET, "Invalid nbytes %d\n", nbytes);
 		return -EINVAL;
 	}
 
@@ -2057,9 +2060,9 @@ int lnet_push_target_resize(void)
 	 * dropped when we need to resize again (see "old_pbuf" below) or when
 	 * LNet is shutdown (see lnet_push_target_fini())
 	 */
-	pbuf = lnet_ping_buffer_alloc(nnis, GFP_NOFS);
+	pbuf = lnet_ping_buffer_alloc(nbytes, GFP_NOFS);
 	if (!pbuf) {
-		CDEBUG(D_NET, "Can't allocate pbuf for nnis %d\n", nnis);
+		CDEBUG(D_NET, "Can't allocate pbuf for nbytes %d\n", nbytes);
 		return  -ENOMEM;
 	}
 
@@ -2084,10 +2087,10 @@ int lnet_push_target_resize(void)
 	}
 
 	/* Received another push or reply that requires a larger buffer */
-	if (nnis < the_lnet.ln_push_target_nnis)
+	if (nbytes < the_lnet.ln_push_target_nbytes)
 		goto again;
 
-	CDEBUG(D_NET, "nnis %d success\n", nnis);
+	CDEBUG(D_NET, "nbytes %d success\n", nbytes);
 	return 0;
 }
 
@@ -2118,7 +2121,7 @@ int lnet_push_target_post(struct lnet_ping_buffer *pbuf,
 
 	/* initialize md content */
 	md.start = &pbuf->pb_info;
-	md.length = LNET_PING_INFO_SIZE(pbuf->pb_nnis);
+	md.length = pbuf->pb_nbytes;
 	md.threshold = 1;
 	md.max_size = 0;
 	md.options = LNET_MD_OP_PUT | LNET_MD_TRUNCATE;
@@ -2175,7 +2178,7 @@ static int lnet_push_target_init(void)
 	LASSERT(rc == 0);
 
 	/* Start at the required minimum, we'll enlarge if required. */
-	the_lnet.ln_push_target_nnis = LNET_INTERFACES_MIN;
+	the_lnet.ln_push_target_nbytes = LNET_PING_INFO_MIN_SIZE;
 
 	rc = lnet_push_target_resize();
 	if (rc) {
@@ -2204,7 +2207,7 @@ static void lnet_push_target_fini(void)
 	/* Drop ref set by lnet_ping_buffer_alloc() */
 	lnet_ping_buffer_decref(the_lnet.ln_push_target);
 	the_lnet.ln_push_target = NULL;
-	the_lnet.ln_push_target_nnis = 0;
+	the_lnet.ln_push_target_nbytes = 0;
 
 	LNetClearLazyPortal(LNET_RESERVED_PORTAL);
 	lnet_assert_handler_unused(the_lnet.ln_push_target_handler);
@@ -2865,7 +2868,7 @@ LNetNIInit(lnet_pid_t requested_pid)
 {
 	int im_a_router = 0;
 	int rc;
-	int ni_count;
+	int ni_bytes;
 	struct lnet_ping_buffer *pbuf;
 	struct lnet_handle_md ping_mdh;
 	LIST_HEAD(net_head);
@@ -2921,11 +2924,9 @@ LNetNIInit(lnet_pid_t requested_pid)
 			goto err_empty_list;
 	}
 
-	ni_count = lnet_startup_lndnets(&net_head);
-	if (ni_count < 0) {
-		rc = ni_count;
+	rc = lnet_startup_lndnets(&net_head);
+	if (rc < 0)
 		goto err_empty_list;
-	}
 
 	if (!the_lnet.ln_nis_from_mod_params) {
 		rc = lnet_parse_routes(lnet_get_routes(), &im_a_router);
@@ -2944,7 +2945,11 @@ LNetNIInit(lnet_pid_t requested_pid)
 	the_lnet.ln_refcount = 1;
 	/* Now I may use my own API functions... */
 
-	rc = lnet_ping_target_setup(&pbuf, &ping_mdh, ni_count, true);
+	ni_bytes = LNET_PING_INFO_HDR_SIZE;
+	list_for_each_entry(net, &the_lnet.ln_nets, net_list)
+		ni_bytes += lnet_get_net_ni_bytes_locked(net);
+
+	rc = lnet_ping_target_setup(&pbuf, &ping_mdh, ni_bytes, true);
 	if (rc)
 		goto err_acceptor_stop;
 
@@ -3363,7 +3368,7 @@ static int lnet_add_net_common(struct lnet_net *net,
 	struct lnet_ping_buffer *pbuf;
 	struct lnet_remotenet *rnet;
 	struct lnet_ni *ni;
-	int net_ni_count;
+	int net_ni_bytes;
 	u32 net_id;
 	int rc;
 
@@ -3388,12 +3393,13 @@ static int lnet_add_net_common(struct lnet_net *net,
 	 * which will be added.
 	 *
 	 * since ni hasn't been configured yet, use
-	 * lnet_get_net_ni_count_pre() which checks the net_ni_added list
+	 * lnet_get_net_ni_bytes_pre() which checks the net_ni_added list
 	 */
-	net_ni_count = lnet_get_net_ni_count_pre(net);
+	net_ni_bytes = lnet_get_net_ni_bytes_pre(net);
 
 	rc = lnet_ping_target_setup(&pbuf, &ping_mdh,
-				    net_ni_count + lnet_get_ni_count(),
+				    LNET_PING_INFO_HDR_SIZE +
+				    net_ni_bytes + lnet_get_ni_bytes(),
 				    false);
 	if (rc < 0) {
 		lnet_net_free(net);
@@ -3589,8 +3595,8 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 	u32 net_id = LNET_NIDNET(conf->lic_nid);
 	struct lnet_ping_buffer *pbuf;
 	struct lnet_handle_md ping_mdh;
-	int rc;
-	int net_count;
+	int net_bytes, rc;
+	bool net_empty;
 	u32 addr;
 
 	/* don't allow userspace to shutdown the LOLND */
@@ -3616,13 +3622,13 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 	addr = LNET_NIDADDR(conf->lic_nid);
 	if (addr == 0) {
 		/* remove the entire net */
-		net_count = lnet_get_net_ni_count_locked(net);
+		net_bytes = lnet_get_net_ni_bytes_locked(net);
 
 		lnet_net_unlock(0);
 
 		/* create and link a new ping info, before removing the old one */
 		rc = lnet_ping_target_setup(&pbuf, &ping_mdh,
-					    lnet_get_ni_count() - net_count,
+					    lnet_get_ni_bytes() - net_bytes,
 					    false);
 		if (rc != 0)
 			goto unlock_api_mutex;
@@ -3644,13 +3650,17 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 		goto unlock_net;
 	}
 
-	net_count = lnet_get_net_ni_count_locked(net);
+	net_bytes = lnet_get_net_ni_bytes_locked(net);
+	net_empty = list_is_singular(&net->net_ni_list);
 
 	lnet_net_unlock(0);
 
 	/* create and link a new ping info, before removing the old one */
 	rc = lnet_ping_target_setup(&pbuf, &ping_mdh,
-				    lnet_get_ni_count() - 1, false);
+				    (LNET_PING_INFO_HDR_SIZE +
+				     lnet_get_ni_bytes() -
+				     sizeof(pbuf->pb_info.pi_ni[0])),
+				    false);
 	if (rc != 0)
 		goto unlock_api_mutex;
 
@@ -3661,7 +3671,7 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 	lnet_ping_target_update(pbuf, ping_mdh);
 
 	/* check if the net is empty and remove it if it is */
-	if (net_count == 1)
+	if (net_empty)
 		lnet_shutdown_lndnet(net);
 
 	goto unlock_api_mutex;
@@ -3744,8 +3754,7 @@ lnet_dyn_del_net(u32 net_id)
 	struct lnet_net *net;
 	struct lnet_ping_buffer *pbuf;
 	struct lnet_handle_md ping_mdh;
-	int rc;
-	int net_ni_count;
+	int net_ni_bytes, rc;
 
 	/* don't allow userspace to shutdown the LOLND */
 	if (LNET_NETTYP(net_id) == LOLND)
@@ -3766,13 +3775,15 @@ lnet_dyn_del_net(u32 net_id)
 		goto out;
 	}
 
-	net_ni_count = lnet_get_net_ni_count_locked(net);
+	net_ni_bytes = lnet_get_net_ni_bytes_locked(net);
 
 	lnet_net_unlock(0);
 
 	/* create and link a new ping info, before removing the old one */
 	rc = lnet_ping_target_setup(&pbuf, &ping_mdh,
-				    lnet_get_ni_count() - net_ni_count, false);
+				     LNET_PING_INFO_HDR_SIZE +
+				     lnet_get_ni_bytes() - net_ni_bytes,
+				     false);
 	if (rc)
 		goto out;
 
@@ -4626,6 +4637,12 @@ lnet_ping_event_handler(struct lnet_event *event)
 		complete(&pd->completion);
 }
 
+/* lnet_ping() only works with nid4 nids, so we can calculate
+ * size from number of nids
+ */
+#define LNET_PING_INFO_SIZE(NNIDS) \
+	offsetof(struct lnet_ping_info, pi_ni[NNIDS])
+
 static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 		     signed long timeout, struct lnet_process_id __user *ids,
 		     int n_ids)
@@ -4635,6 +4652,7 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 	struct lnet_ping_buffer *pbuf;
 	struct lnet_process_id tmpid;
 	struct lnet_processid id;
+	int id_bytes;
 	int i;
 	int nob;
 	int rc;
@@ -4653,13 +4671,14 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 	if (id4.pid == LNET_PID_ANY)
 		id4.pid = LNET_PID_LUSTRE;
 
-	pbuf = lnet_ping_buffer_alloc(n_ids, GFP_NOFS);
+	id_bytes = LNET_PING_INFO_SIZE(n_ids);
+	pbuf = lnet_ping_buffer_alloc(id_bytes, GFP_NOFS);
 	if (!pbuf)
 		return -ENOMEM;
 
 	/* initialize md content */
 	md.start = &pbuf->pb_info;
-	md.length = LNET_PING_INFO_SIZE(n_ids);
+	md.length = id_bytes;
 	md.threshold = 2; /* GET/REPLY */
 	md.max_size = 0;
 	md.options = LNET_MD_TRUNCATE;
@@ -4696,7 +4715,7 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 	}
 
 	nob = pd.rc;
-	LASSERT(nob >= 0 && nob <= LNET_PING_INFO_SIZE(n_ids));
+	LASSERT(nob >= 0 && nob <= id_bytes);
 
 	rc = -EPROTO;		/* if I can't parse... */
 
@@ -4720,20 +4739,21 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 		goto fail_ping_buffer_decref;
 	}
 
-	if (nob < LNET_PING_INFO_SIZE(0)) {
-		CERROR("%s: Short reply %d(%d min)\n",
-		       libcfs_idstr(&id),
-		       nob, (int)LNET_PING_INFO_SIZE(0));
+	/* Test if smaller than lnet_pinginfo with no pi_ni status info */
+	if (nob < LNET_PING_INFO_HDR_SIZE) {
+		CERROR("%s: Short reply %d(%lu min)\n",
+		       libcfs_idstr(&id), nob, LNET_PING_INFO_HDR_SIZE);
 		goto fail_ping_buffer_decref;
 	}
 
-	if (pbuf->pb_info.pi_nnis < n_ids)
+	if (pbuf->pb_info.pi_nnis < n_ids) {
 		n_ids = pbuf->pb_info.pi_nnis;
+		id_bytes = lnet_ping_info_size(&pbuf->pb_info);
+	}
 
-	if (nob < LNET_PING_INFO_SIZE(n_ids)) {
+	if (nob < id_bytes) {
 		CERROR("%s: Short reply %d(%d expected)\n",
-		       libcfs_idstr(&id),
-		       nob, (int)LNET_PING_INFO_SIZE(n_ids));
+		       libcfs_idstr(&id), nob, id_bytes);
 		goto fail_ping_buffer_decref;
 	}
 
@@ -4753,6 +4773,8 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 	return rc;
 }
 
+#undef LNET_PING_INFO_SIZE
+
 static int
 lnet_discover(struct lnet_process_id id4, u32 force,
 	      struct lnet_process_id __user *ids,
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index a8a5ddbab84a..d46578929d08 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3334,7 +3334,7 @@ lnet_recover_local_nis(void)
 
 			ev_info->mt_type = MT_TYPE_LOCAL_NI;
 			ev_info->mt_nid = nid;
-			rc = lnet_send_ping(&nid, &mdh, LNET_INTERFACES_MIN,
+			rc = lnet_send_ping(&nid, &mdh, LNET_PING_INFO_MIN_SIZE,
 					    ev_info, the_lnet.ln_mt_handler,
 					    true);
 			/* lookup the nid again */
@@ -3563,7 +3563,7 @@ lnet_recover_peer_nis(void)
 
 			ev_info->mt_type = MT_TYPE_PEER_NI;
 			ev_info->mt_nid = nid;
-			rc = lnet_send_ping(&nid, &mdh, LNET_INTERFACES_MIN,
+			rc = lnet_send_ping(&nid, &mdh, LNET_PING_INFO_MIN_SIZE,
 					    ev_info, the_lnet.ln_mt_handler,
 					    true);
 			lnet_net_lock(0);
@@ -3672,7 +3672,7 @@ lnet_monitor_thread(void *arg)
  */
 int
 lnet_send_ping(struct lnet_nid *dest_nid,
-	       struct lnet_handle_md *mdh, int nnis,
+	       struct lnet_handle_md *mdh, int bytes,
 	       void *user_data, lnet_handler_t handler, bool recovery)
 {
 	struct lnet_md md = { NULL };
@@ -3685,7 +3685,7 @@ lnet_send_ping(struct lnet_nid *dest_nid,
 		goto fail_error;
 	}
 
-	pbuf = lnet_ping_buffer_alloc(nnis, GFP_NOFS);
+	pbuf = lnet_ping_buffer_alloc(bytes, GFP_NOFS);
 	if (!pbuf) {
 		rc = ENOMEM;
 		goto fail_error;
@@ -3693,7 +3693,7 @@ lnet_send_ping(struct lnet_nid *dest_nid,
 
 	/* initialize md content */
 	md.start = &pbuf->pb_info;
-	md.length = LNET_PING_INFO_SIZE(nnis);
+	md.length = bytes;
 	md.threshold = 2; /* GET/REPLY */
 	md.max_size = 0;
 	md.options = LNET_MD_TRUNCATE | LNET_MD_TRACK_RESPONSE;
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 3b1f6a36bfe0..9fb001e5815e 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -814,6 +814,8 @@ lnet_health_check(struct lnet_msg *msg)
 	 * messages with a health status != OK.
 	 */
 	if (hstatus != LNET_MSG_STATUS_OK) {
+		struct lnet_ping_info *pi;
+
 		/* Don't further decrement the health value if a recovery
 		 * message failed.
 		 */
@@ -826,11 +828,10 @@ lnet_health_check(struct lnet_msg *msg)
 		}
 
 		/* For local failures, health/recovery/resends are not needed if
-		 * I only have a single (non-lolnd) interface. NB: pb_nnis
-		 * includes the lolnd interface, so a single-rail node would
-		 * have pb_nnis == 2.
+		 * I only have a single (non-lolnd) interface.
 		 */
-		if (the_lnet.ln_ping_target->pb_nnis <= 2) {
+		pi = &the_lnet.ln_ping_target->pb_info;
+		if (pi->pi_nnis <= 2) {
 			handle_local_health = false;
 			attempt_local_resend = false;
 		}
@@ -840,9 +841,8 @@ lnet_health_check(struct lnet_msg *msg)
 		/* For remote failures, health/recovery/resends are not needed
 		 * if the peer only has a single interface. Special case for
 		 * routers where we rely on health feature to manage route
-		 * aliveness. NB: unlike pb_nnis above, lp_nnis does _not_
-		 * include the lolnd, so a single-rail node would have
-		 * lp_nnis == 1.
+		 * aliveness. NB: lp_nnis does _not_ include the lolnd, so a
+		 * single-rail node would have lp_nnis == 1.
 		 */
 		if (lpni && lpni->lpni_peer_net &&
 		    lpni->lpni_peer_net->lpn_peer &&
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index e7c3c835b528..9b2066028509 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -2254,6 +2254,7 @@ void lnet_peer_push_event(struct lnet_event *ev)
 {
 	struct lnet_ping_buffer *pbuf;
 	struct lnet_peer *lp;
+	int infobytes;
 
 	pbuf = LNET_PING_INFO_TO_BUFFER(ev->md_start + ev->offset);
 
@@ -2298,12 +2299,12 @@ void lnet_peer_push_event(struct lnet_event *ev)
 		goto out;
 	}
 
-	/*
-	 * Make sure we'll allocate the correct size ping buffer when
+	/* Make sure we'll allocate the correct size ping buffer when
 	 * pinging the peer.
 	 */
-	if (lp->lp_data_nnis < pbuf->pb_info.pi_nnis)
-		lp->lp_data_nnis = pbuf->pb_info.pi_nnis;
+	infobytes = lnet_ping_info_size(&pbuf->pb_info);
+	if (lp->lp_data_bytes < infobytes)
+		lp->lp_data_bytes = infobytes;
 
 	/*
 	 * A non-Multi-Rail peer is not supposed to be capable of
@@ -2369,13 +2370,12 @@ void lnet_peer_push_event(struct lnet_event *ev)
 	 * and tell discovery to allocate a bigger buffer.
 	 */
 	if (ev->mlength < ev->rlength) {
-		if (the_lnet.ln_push_target_nnis < pbuf->pb_info.pi_nnis)
-			the_lnet.ln_push_target_nnis = pbuf->pb_info.pi_nnis;
+		if (the_lnet.ln_push_target_nbytes < infobytes)
+			the_lnet.ln_push_target_nbytes = infobytes;
 		lp->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
 		lp->lp_state |= LNET_PEER_FORCE_PING;
-		CDEBUG(D_NET, "Truncated Push from %s (%d nids)\n",
-		       libcfs_nidstr(&lp->lp_primary_nid),
-		       pbuf->pb_info.pi_nnis);
+		CDEBUG(D_NET, "Truncated Push from %s (%d bytes)\n",
+		       libcfs_nidstr(&lp->lp_primary_nid), infobytes);
 		goto out;
 	}
 
@@ -2383,8 +2383,7 @@ void lnet_peer_push_event(struct lnet_event *ev)
 	lp->lp_peer_seqno = LNET_PING_BUFFER_SEQNO(pbuf);
 	lp->lp_state &= ~LNET_PEER_NIDS_UPTODATE;
 
-	/*
-	 * If there is data present that hasn't been processed yet,
+	/* If there is data present that hasn't been processed yet,
 	 * we'll replace it if the Put contained newer data and it
 	 * fits. We're racing with a Ping or earlier Push in this
 	 * case.
@@ -2392,9 +2391,9 @@ void lnet_peer_push_event(struct lnet_event *ev)
 	if (lp->lp_state & LNET_PEER_DATA_PRESENT) {
 		if (LNET_PING_BUFFER_SEQNO(pbuf) >
 			LNET_PING_BUFFER_SEQNO(lp->lp_data) &&
-		    pbuf->pb_info.pi_nnis <= lp->lp_data->pb_nnis) {
+		    infobytes <= lp->lp_data->pb_nbytes) {
 			memcpy(&lp->lp_data->pb_info, &pbuf->pb_info,
-			       LNET_PING_INFO_SIZE(pbuf->pb_info.pi_nnis));
+			       infobytes);
 			CDEBUG(D_NET, "Ping/Push race from %s: %u vs %u\n",
 			       libcfs_nidstr(&lp->lp_primary_nid),
 			       LNET_PING_BUFFER_SEQNO(pbuf),
@@ -2408,7 +2407,7 @@ void lnet_peer_push_event(struct lnet_event *ev)
 	 * the Push and set FORCE_PING to force the discovery
 	 * thread to fix the problem by pinging the peer.
 	 */
-	lp->lp_data = lnet_ping_buffer_alloc(lp->lp_data_nnis, GFP_ATOMIC);
+	lp->lp_data = lnet_ping_buffer_alloc(lp->lp_data_bytes, GFP_ATOMIC);
 	if (!lp->lp_data) {
 		lp->lp_state |= LNET_PEER_FORCE_PING;
 		CDEBUG(D_NET, "Cannot allocate Push buffer for %s %u\n",
@@ -2418,8 +2417,7 @@ void lnet_peer_push_event(struct lnet_event *ev)
 	}
 
 	/* Success */
-	memcpy(&lp->lp_data->pb_info, &pbuf->pb_info,
-	       LNET_PING_INFO_SIZE(pbuf->pb_info.pi_nnis));
+	memcpy(&lp->lp_data->pb_info, &pbuf->pb_info, infobytes);
 	lp->lp_state |= LNET_PEER_DATA_PRESENT;
 	CDEBUG(D_NET, "Received Push %s %u\n",
 	       libcfs_nidstr(&lp->lp_primary_nid),
@@ -2580,6 +2578,7 @@ static void
 lnet_discovery_event_reply(struct lnet_peer *lp, struct lnet_event *ev)
 {
 	struct lnet_ping_buffer *pbuf;
+	int infobytes;
 	int rc;
 
 	spin_lock(&lp->lp_lock);
@@ -2692,25 +2691,24 @@ lnet_discovery_event_reply(struct lnet_peer *lp, struct lnet_event *ev)
 		}
 	}
 
+	infobytes = lnet_ping_info_size(&pbuf->pb_info);
 	/*
 	 * Make sure we'll allocate the correct size ping buffer when
 	 * pinging the peer.
 	 */
-	if (lp->lp_data_nnis < pbuf->pb_info.pi_nnis)
-		lp->lp_data_nnis = pbuf->pb_info.pi_nnis;
+	if (lp->lp_data_bytes < infobytes)
+		lp->lp_data_bytes = infobytes;
 
-	/*
-	 * Check for truncation of the Reply. Clear PING_SENT and set
+	/* Check for truncation of the Reply. Clear PING_SENT and set
 	 * PING_FAILED to trigger a retry.
 	 */
-	if (pbuf->pb_nnis < pbuf->pb_info.pi_nnis) {
-		if (the_lnet.ln_push_target_nnis < pbuf->pb_info.pi_nnis)
-			the_lnet.ln_push_target_nnis = pbuf->pb_info.pi_nnis;
+	if (pbuf->pb_nbytes < infobytes) {
+		if (the_lnet.ln_push_target_nbytes < infobytes)
+			the_lnet.ln_push_target_nbytes = infobytes;
 		lp->lp_state |= LNET_PEER_PING_FAILED;
 		lp->lp_ping_error = 0;
-		CDEBUG(D_NET, "Truncated Reply from %s (%d nids)\n",
-		       libcfs_nidstr(&lp->lp_primary_nid),
-		       pbuf->pb_info.pi_nnis);
+		CDEBUG(D_NET, "Truncated Reply from %s (%d bytes)\n",
+		       libcfs_nidstr(&lp->lp_primary_nid), infobytes);
 		goto out;
 	}
 
@@ -3391,7 +3389,7 @@ __must_hold(&lp->lp_lock)
 static int lnet_peer_send_ping(struct lnet_peer *lp)
 __must_hold(&lp->lp_lock)
 {
-	int nnis;
+	int bytes;
 	int rc;
 	int cpt;
 
@@ -3404,9 +3402,9 @@ __must_hold(&lp->lp_lock)
 	lnet_peer_addref_locked(lp);
 	lnet_net_unlock(cpt);
 
-	nnis = max_t(int, lp->lp_data_nnis, LNET_INTERFACES_MIN);
+	bytes = max_t(int, lp->lp_data_bytes, LNET_PING_INFO_MIN_SIZE);
 
-	rc = lnet_send_ping(&lp->lp_primary_nid, &lp->lp_ping_mdh, nnis, lp,
+	rc = lnet_send_ping(&lp->lp_primary_nid, &lp->lp_ping_mdh, bytes, lp,
 			    the_lnet.ln_dc_handler, false);
 	/* if LNetMDBind in lnet_send_ping fails we need to decrement the
 	 * refcount on the peer, otherwise LNetMDUnlink will be called
@@ -3514,7 +3512,7 @@ __must_hold(&lp->lp_lock)
 
 	/* Push source MD */
 	md.start = &pbuf->pb_info;
-	md.length = LNET_PING_INFO_SIZE(pbuf->pb_nnis);
+	md.length = pbuf->pb_nbytes;
 	md.threshold = 2; /* Put/Ack */
 	md.max_size = 0;
 	md.options = LNET_MD_TRACK_RESPONSE;
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
