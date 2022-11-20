Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DD00CC433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:26:55 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXhK33FPz1yGl;
	Sun, 20 Nov 2022 06:19:13 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXgd4TbJz1yD3
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:18:37 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C56911008049;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C1A0BE8BBF; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:16:54 -0500
Message-Id: <1668953828-10909-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/22] lnet: allow ping packet to contain
 large nids
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

The ping packet has an array of fixed-size status entries that only
have room for a 4-byte-address nid.

This patches adds a feature flag which activates a list of variable
sized entries after the initial array.

Each entry contains a 4-byte status and then a nid, rounded to a
multiple of 4 bytes.  The total number of bytes of the ping_info
(header, first array, subsequent list) is stored in the ns_unused
field of the first entry in the array.

The user-space interfaces only see the initial array.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: db0fb8f2b649c0c38 ("LU-10391 lnet: allow ping packet to contain large nids")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/44628
Tested-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h     |  39 +++++++++++
 include/uapi/linux/lnet/lnet-idl.h |  58 +++++++++++-----
 net/lnet/lnet/api-ni.c             | 131 +++++++++++++++++++++++--------------
 net/lnet/lnet/lib-msg.c            |   2 +-
 4 files changed, 165 insertions(+), 65 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 2d3b044..73d962f 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -684,6 +684,45 @@ struct lnet_ping_buffer {
 #define LNET_PING_INFO_TO_BUFFER(PINFO)	\
 	container_of((PINFO), struct lnet_ping_buffer, pb_info)
 
+static inline int
+lnet_ping_sts_size(const struct lnet_nid *nid)
+{
+	int size;
+
+	if (nid_is_nid4(nid))
+		return sizeof(struct lnet_ni_status);
+
+	size = offsetof(struct lnet_ni_large_status, ns_nid) +
+	       NID_BYTES(nid);
+
+	return round_up(size, 4);
+}
+
+static inline struct lnet_ni_large_status *
+lnet_ping_sts_next(const struct lnet_ni_large_status *nis)
+{
+	return (void *)nis + lnet_ping_sts_size(&nis->ns_nid);
+}
+
+static inline bool
+lnet_ping_at_least_two_entries(const struct lnet_ping_info *pi)
+{
+	/* Return true if we have at lease two entries.  There is always a
+	 * least one, a 4-byte lo0 interface.
+	 */
+	struct lnet_ni_large_status *lns;
+
+	if ((pi->pi_features & LNET_PING_FEAT_LARGE_ADDR) == 0)
+		return pi->pi_nnis <= 2;
+	/* There is at least 1 large-address entry */
+	if (pi->pi_nnis != 1)
+		return false;
+	lns = (void *)&pi->pi_ni[1];
+	lns = lnet_ping_sts_next(lns);
+
+	return ((void *)pi + lnet_ping_info_size(pi) <= (void *)lns);
+}
+
 struct lnet_nid_list {
 	struct list_head nl_list;
 	struct lnet_nid nl_nid;
diff --git a/include/uapi/linux/lnet/lnet-idl.h b/include/uapi/linux/lnet/lnet-idl.h
index 41bbb40..479e7fa 100644
--- a/include/uapi/linux/lnet/lnet-idl.h
+++ b/include/uapi/linux/lnet/lnet-idl.h
@@ -247,7 +247,6 @@ struct lnet_counters_common {
 	__u64	lcc_drop_length;
 } __attribute__((packed));
 
-
 #define LNET_NI_STATUS_UP	0x15aac0de
 #define LNET_NI_STATUS_DOWN	0xdeadface
 #define LNET_NI_STATUS_INVALID	0x00000000
@@ -255,19 +254,32 @@ struct lnet_counters_common {
 struct lnet_ni_status {
 	lnet_nid_t ns_nid;
 	__u32      ns_status;
-	__u32      ns_unused;
+	__u32      ns_msg_size;	/* represents ping buffer size if message
+				 * contains large NID addresses.
+				 */
 } __attribute__((packed));
 
-/*
- * NB: value of these features equal to LNET_PROTO_PING_VERSION_x
+/* When this appears in lnet_ping_info, it will be large
+ * enough to hold whatever nid is present, rounded up
+ * to a multiple of 4 bytes.
+ * NOTE: all users MUST check ns_nid.nid_size is usable.
+ */
+struct lnet_ni_large_status {
+	__u32		ns_status;
+	struct lnet_nid	ns_nid;
+} __attribute__((packed));
+
+/* NB: value of these features equal to LNET_PROTO_PING_VERSION_x
  * of old LNet, so there shouldn't be any compatibility issue
  */
 #define LNET_PING_FEAT_INVAL		(0)		/* no feature */
 #define LNET_PING_FEAT_BASE		(1 << 0)	/* just a ping */
 #define LNET_PING_FEAT_NI_STATUS	(1 << 1)	/* return NI status */
-#define LNET_PING_FEAT_RTE_DISABLED	(1 << 2)        /* Routing enabled */
-#define LNET_PING_FEAT_MULTI_RAIL	(1 << 3)        /* Multi-Rail aware */
+#define LNET_PING_FEAT_RTE_DISABLED	(1 << 2)	/* Routing enabled */
+#define LNET_PING_FEAT_MULTI_RAIL	(1 << 3)	/* Multi-Rail aware */
 #define LNET_PING_FEAT_DISCOVERY	(1 << 4)	/* Supports Discovery */
+#define LNET_PING_FEAT_LARGE_ADDR	(1 << 5)	/* Large addr nids present */
+#define LNET_PING_FEAT_PRIMARY_LARGE	(1 << 6)	/* Primary is first Large addr */
 
 /*
  * All ping feature bits fit to hit the wire.
@@ -277,17 +289,26 @@ struct lnet_ni_status {
  * New feature bits can be added, just be aware that this does change the
  * over-the-wire protocol.
  */
-#define LNET_PING_FEAT_BITS		(LNET_PING_FEAT_BASE | \
-					 LNET_PING_FEAT_NI_STATUS | \
-					 LNET_PING_FEAT_RTE_DISABLED | \
-					 LNET_PING_FEAT_MULTI_RAIL | \
-					 LNET_PING_FEAT_DISCOVERY)
-
+#define LNET_PING_FEAT_BITS		(LNET_PING_FEAT_BASE |		\
+					 LNET_PING_FEAT_NI_STATUS |	\
+					 LNET_PING_FEAT_RTE_DISABLED |	\
+					 LNET_PING_FEAT_MULTI_RAIL |	\
+					 LNET_PING_FEAT_DISCOVERY |	\
+					 LNET_PING_FEAT_LARGE_ADDR |	\
+					 LNET_PING_FEAT_PRIMARY_LARGE)
+
+/* NOTE:
+ * The first address in pi_ni *must* be the loop-back nid: LNET_NID_LO_0
+ * The second address must be the primary nid for the host unless
+ * LNET_PING_FEAT_PRIMARY_LARGE is set, then the first large address
+ * is the preferred primary.  However nodes that do not recognise that
+ * flag will quietly ignore it.
+ */
 struct lnet_ping_info {
 	__u32			pi_magic;
 	__u32			pi_features;
 	lnet_pid_t		pi_pid;
-	__u32			pi_nnis;
+	__u32			pi_nnis;	/* number of nid4 entries */
 	struct lnet_ni_status	pi_ni[0];
 } __attribute__((packed));
 
@@ -297,7 +318,14 @@ struct lnet_ping_info {
 	offsetof(struct lnet_ping_info, pi_ni[LNET_INTERFACES_MIN])
 #define LNET_PING_INFO_LONI(PINFO)      ((PINFO)->pi_ni[0].ns_nid)
 #define LNET_PING_INFO_SEQNO(PINFO)     ((PINFO)->pi_ni[0].ns_status)
-#define lnet_ping_info_size(pinfo)	\
-	offsetof(struct lnet_ping_info, pi_ni[(pinfo)->pi_nnis])
+/* If LNET_PING_FEAT_LARGE_ADDR set, pi_nnis is the number of nid4 entries
+ * and pi_ni[0].ns_msg_size is the total number of bytes, including header and
+ * lnet_ni_large_status entries which follow the lnet_ni_status entries.
+ * This must be a multiple of 4.
+ */
+#define lnet_ping_info_size(pinfo)				\
+	(((pinfo)->pi_features & LNET_PING_FEAT_LARGE_ADDR)	\
+	? ((pinfo)->pi_ni[0].ns_msg_size & ~3)			\
+	: offsetof(struct lnet_ping_info, pi_ni[(pinfo)->pi_nnis]))
 
 #endif
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index af875ba..935c848 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -823,8 +823,15 @@ static void lnet_assert_wire_constants(void)
 	BUILD_BUG_ON((int)sizeof(((struct lnet_ni_status *)0)->ns_nid) != 8);
 	BUILD_BUG_ON((int)offsetof(struct lnet_ni_status, ns_status) != 8);
 	BUILD_BUG_ON((int)sizeof(((struct lnet_ni_status *)0)->ns_status) != 4);
-	BUILD_BUG_ON((int)offsetof(struct lnet_ni_status, ns_unused) != 12);
-	BUILD_BUG_ON((int)sizeof(((struct lnet_ni_status *)0)->ns_unused) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_ni_status, ns_msg_size) != 12);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_ni_status *)0)->ns_msg_size) != 4);
+
+	/* Checks for struct lnet_ni_large_status */
+	BUILD_BUG_ON((int)sizeof(struct lnet_ni_large_status) != 24);
+	BUILD_BUG_ON((int)offsetof(struct lnet_ni_large_status, ns_status) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_ni_large_status *)0)->ns_status) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_ni_large_status, ns_nid) != 4);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_ni_large_status *)0)->ns_nid) != 20);
 
 	/* Checks for struct lnet_ping_info and related constants */
 	BUILD_BUG_ON(LNET_PROTO_PING_MAGIC != 0x70696E67);
@@ -834,7 +841,9 @@ static void lnet_assert_wire_constants(void)
 	BUILD_BUG_ON(LNET_PING_FEAT_RTE_DISABLED != 4);
 	BUILD_BUG_ON(LNET_PING_FEAT_MULTI_RAIL != 8);
 	BUILD_BUG_ON(LNET_PING_FEAT_DISCOVERY != 16);
-	BUILD_BUG_ON(LNET_PING_FEAT_BITS != 31);
+	BUILD_BUG_ON(LNET_PING_FEAT_LARGE_ADDR != 32);
+	BUILD_BUG_ON(LNET_PING_FEAT_PRIMARY_LARGE != 64);
+	BUILD_BUG_ON(LNET_PING_FEAT_BITS != 127);
 
 	/* Checks for struct lnet_ping_info */
 	BUILD_BUG_ON((int)sizeof(struct lnet_ping_info) != 16);
@@ -1770,21 +1779,7 @@ struct lnet_ping_buffer *
 	int bytes = 0;
 
 	list_for_each_entry(ni, &net->net_ni_list, ni_netlist)
-		if (nid_is_nid4(&ni->ni_nid))
-			bytes += sizeof(struct lnet_ni_status);
-
-	return bytes;
-}
-
-static inline int
-lnet_get_net_ni_bytes_pre(struct lnet_net *net)
-{
-	struct lnet_ni *ni;
-	int bytes = 0;
-
-	list_for_each_entry(ni, &net->net_ni_added, ni_netlist)
-		if (nid_is_nid4(&ni->ni_nid))
-			bytes += sizeof(struct lnet_ni_status);
+		bytes += lnet_ping_sts_size(&ni->ni_nid);
 
 	return bytes;
 }
@@ -1800,9 +1795,7 @@ struct lnet_ping_buffer *
 
 	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
 		list_for_each_entry(ni, &net->net_ni_list, ni_netlist)
-			if (nid_is_nid4(&ni->ni_nid))
-				bytes += sizeof(struct lnet_ni_status);
-
+			bytes += lnet_ping_sts_size(&ni->ni_nid);
 	}
 
 	lnet_net_unlock(0);
@@ -1813,6 +1806,7 @@ struct lnet_ping_buffer *
 void
 lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf)
 {
+	struct lnet_ni_large_status *lstat, *lend;
 	struct lnet_ni_status *stat, *end;
 	int nnis;
 	int i;
@@ -1827,6 +1821,19 @@ struct lnet_ping_buffer *
 	for (i = 0; i < nnis && stat + 1 <= end; i++, stat++) {
 		__swab64s(&stat->ns_nid);
 		__swab32s(&stat->ns_status);
+		if (i == 0)
+			/* Might be total size */
+			__swab32s(&stat->ns_msg_size);
+	}
+	if (!(pbuf->pb_info.pi_features & LNET_PING_FEAT_LARGE_ADDR))
+		return;
+
+	lstat = (struct lnet_ni_large_status *)stat;
+	lend = (void *)end;
+	while (lstat + 1 <= lend) {
+		__swab32s(&lstat->ns_status);
+		/* struct lnet_nid never needs to be swabed */
+		lstat = lnet_ping_sts_next(lstat);
 	}
 }
 
@@ -1954,6 +1961,7 @@ struct lnet_ping_buffer *
 static void
 lnet_ping_target_install_locked(struct lnet_ping_buffer *pbuf)
 {
+	struct lnet_ni_large_status *lns, *lend;
 	struct lnet_ni_status *ns, *end;
 	struct lnet_ni *ni;
 	struct lnet_net *net;
@@ -1964,8 +1972,14 @@ struct lnet_ping_buffer *
 	end = (void *)&pbuf->pb_info + pbuf->pb_nbytes;
 	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
 		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
-			if (!nid_is_nid4(&ni->ni_nid))
+			if (!nid_is_nid4(&ni->ni_nid)) {
+				if (ns == &pbuf->pb_info.pi_ni[1]) {
+					/* This is primary, and it is long */
+					pbuf->pb_info.pi_features |=
+						LNET_PING_FEAT_PRIMARY_LARGE;
+				}
 				continue;
+			}
 			LASSERT(ns + 1 <= end);
 			ns->ns_nid = lnet_nid_to_nid4(&ni->ni_nid);
 
@@ -1979,6 +1993,31 @@ struct lnet_ping_buffer *
 		}
 	}
 
+	lns = (void *)ns;
+	lend = (void *)end;
+	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
+		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
+			if (nid_is_nid4(&ni->ni_nid))
+				continue;
+			LASSERT(lns + 1 <= lend);
+
+			lns->ns_nid = ni->ni_nid;
+
+			lnet_ni_lock(ni);
+			ns->ns_status = lnet_ni_get_status_locked(ni);
+			ni->ni_status = &lns->ns_status;
+			lnet_ni_unlock(ni);
+
+			lns = lnet_ping_sts_next(lns);
+		}
+	}
+	if ((void *)lns > (void *)ns) {
+		/* Record total info size */
+		pbuf->pb_info.pi_ni[0].ns_msg_size =
+			(void *)lns - (void *)&pbuf->pb_info;
+		pbuf->pb_info.pi_features |= LNET_PING_FEAT_LARGE_ADDR;
+	}
+
 	/* We (ab)use the ns_status of the loopback interface to
 	 * transmit the sequence number. The first interface listed
 	 * must be the loopback interface.
@@ -3397,7 +3436,6 @@ static int lnet_add_net_common(struct lnet_net *net,
 	struct lnet_ping_buffer *pbuf;
 	struct lnet_remotenet *rnet;
 	struct lnet_ni *ni;
-	int net_ni_bytes;
 	u32 net_id;
 	int rc;
 
@@ -3415,39 +3453,32 @@ static int lnet_add_net_common(struct lnet_net *net,
 		return -EUSERS;
 	}
 
-	/*
-	 * make sure you calculate the correct number of slots in the ping
+	if (tun)
+		memcpy(&net->net_tunables,
+		       &tun->lt_cmn, sizeof(net->net_tunables));
+	else
+		memset(&net->net_tunables, -1, sizeof(net->net_tunables));
+
+	net_id = net->net_id;
+
+	rc = lnet_startup_lndnet(net, (tun ? &tun->lt_tun : NULL));
+	if (rc < 0)
+		return rc;
+
+	/* make sure you calculate the correct number of slots in the ping
 	 * buffer. Since the ping info is a flattened list of all the NIs,
 	 * we should allocate enough slots to accomodate the number of NIs
 	 * which will be added.
-	 *
-	 * since ni hasn't been configured yet, use
-	 * lnet_get_net_ni_bytes_pre() which checks the net_ni_added list
 	 */
-	net_ni_bytes = lnet_get_net_ni_bytes_pre(net);
-
 	rc = lnet_ping_target_setup(&pbuf, &ping_mdh,
 				    LNET_PING_INFO_HDR_SIZE +
-				    net_ni_bytes + lnet_get_ni_bytes(),
+				    lnet_get_ni_bytes(),
 				    false);
 	if (rc < 0) {
-		lnet_net_free(net);
+		lnet_shutdown_lndnet(net);
 		return rc;
 	}
 
-	if (tun)
-		memcpy(&net->net_tunables,
-		       &tun->lt_cmn, sizeof(net->net_tunables));
-	else
-		memset(&net->net_tunables, -1, sizeof(net->net_tunables));
-
-	net_id = net->net_id;
-
-	rc = lnet_startup_lndnet(net, (tun ?
-				     &tun->lt_tun : NULL));
-	if (rc < 0)
-		goto failed;
-
 	lnet_net_lock(LNET_LOCK_EX);
 	net = lnet_get_net_locked(net_id);
 	LASSERT(net);
@@ -3678,7 +3709,7 @@ int lnet_dyn_del_ni(struct lnet_nid *nid)
 	rc = lnet_ping_target_setup(&pbuf, &ping_mdh,
 				    (LNET_PING_INFO_HDR_SIZE +
 				     lnet_get_ni_bytes() -
-				     sizeof(pbuf->pb_info.pi_ni[0])),
+				     lnet_ping_sts_size(&ni->ni_nid)),
 				    false);
 	if (rc != 0)
 		goto unlock_api_mutex;
@@ -5428,10 +5459,12 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 		goto fail_ping_buffer_decref;
 	}
 
-	/* Test if smaller than lnet_pinginfo with no pi_ni status info */
-	if (nob < LNET_PING_INFO_HDR_SIZE) {
+	/* Test if smaller than lnet_pinginfo with just one pi_ni status info.
+	 * That one might contain size when large nids are used.
+	 */
+	if (nob < LNET_PING_INFO_SIZE(1)) {
 		CERROR("%s: Short reply %d(%lu min)\n",
-		       libcfs_idstr(&id), nob, LNET_PING_INFO_HDR_SIZE);
+		       libcfs_idstr(&id), nob, LNET_PING_INFO_SIZE(1));
 		goto fail_ping_buffer_decref;
 	}
 
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 9fb001e..898d867 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -831,7 +831,7 @@
 		 * I only have a single (non-lolnd) interface.
 		 */
 		pi = &the_lnet.ln_ping_target->pb_info;
-		if (pi->pi_nnis <= 2) {
+		if (lnet_ping_at_least_two_entries(pi)) {
 			handle_local_health = false;
 			attempt_local_resend = false;
 		}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
