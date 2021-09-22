Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DEBCC433F5
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:28 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2BC2060F4C
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 2BC2060F4C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1F38821F246;
	Tue, 21 Sep 2021 19:20:24 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 57CF521CA53
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:06 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 09080350;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F0BA2FF4BE; Tue, 21 Sep 2021 22:20:03 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:40 -0400
Message-Id: <1632277201-6920-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/24] lnet: introduce struct lnet_nid
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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

LNet nids are currently limited to 4-bytes for addresses.
This excludes the use of IPv6.

In order to support IPv6, introduce 'struct lnet_nid' which can hold
up to 128bit address and is extensible, and deprecate 'lnet_nid_t'.
lnet_nid_it will eventually be removed.  Where lnet_nid_t is often
passed around by value, 'struct lnet_nid' will normally be passed
around by reference as it is over twice as large.

The net_type field, which currently has value up to 16, is now limited
to 0-254 with 255 being used as a wildcard.  The most significant byte
is now a size field which gives the size of the whole nid minus 8.  So
zero is correct for current nids with 4-byte addresses.

Where we still need to use 4-byte-address nids, we will use names
containing "nid4".  So "nid4" is a lnet_nid_t when "nid" is a struct
lnet_nid.  lnet_nid_to_nid4 converts a 'struct lnet_nid' to an
lnet_nid_t.

While lnet_nid_t is stored and often transmitted in host-endian format
(and possibly byte-swapped on receipt), 'struct lnet_nid' is always
stored in network-byte-order (i.e.  big-endian).  This is more common
approach for network addresses.

In this first instance, 'struct lnet_nid' is used for ni_nid in
'struct lnet_ni', and related support functions.

In particular libcfs_nidstr() is introduced which parallels
libcfs_nid2str(), but takes 'struct lnet_nid'.

In cases were we need to have similar functions for old and new style
nid, the new function is introduced with a slightly different name,
such as libcfs_nid2str above, or LNET_NID_NET (like LNET_NIDNET).
It will be confusing having both, but the plan is to remove the old
names as soon as practical.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 82a17076f880770a ("LU-10391 lnet: introduce struct lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/42100
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h        |  4 +-
 include/linux/lnet/lib-types.h       |  2 +-
 include/uapi/linux/lnet/lnet-idl.h   | 28 ++++++++++-
 include/uapi/linux/lnet/lnet-types.h | 66 ++++++++++++++++++++++++-
 include/uapi/linux/lnet/nidstr.h     | 10 +++-
 net/lnet/klnds/o2iblnd/o2iblnd.c     | 13 +++--
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c  | 17 ++++---
 net/lnet/klnds/socklnd/socklnd.c     | 10 ++--
 net/lnet/klnds/socklnd/socklnd_cb.c  | 10 ++--
 net/lnet/lnet/acceptor.c             |  3 +-
 net/lnet/lnet/api-ni.c               | 60 +++++++++++++---------
 net/lnet/lnet/config.c               |  5 +-
 net/lnet/lnet/lib-move.c             | 96 +++++++++++++++++++++---------------
 net/lnet/lnet/lib-msg.c              | 11 +++--
 net/lnet/lnet/lib-socket.c           | 32 +++++++++---
 net/lnet/lnet/lo.c                   |  3 +-
 net/lnet/lnet/net_fault.c            |  2 +-
 net/lnet/lnet/nidstrings.c           | 40 +++++++++++++++
 net/lnet/lnet/router.c               |  8 +--
 net/lnet/lnet/router_proc.c          |  2 +-
 net/lnet/lnet/udsp.c                 | 13 ++---
 21 files changed, 312 insertions(+), 123 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 37489ae..acc069d 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -110,7 +110,7 @@
 
 	if (ni->ni_status && ni->ni_status->ns_status != status) {
 		CDEBUG(D_NET, "ni %s status changed from %#x to %#x\n",
-		       libcfs_nid2str(ni->ni_nid),
+		       libcfs_nidstr(&ni->ni_nid),
 		       ni->ni_status->ns_status, status);
 		ni->ni_status->ns_status = status;
 		update = true;
@@ -123,7 +123,7 @@
 lnet_ni_get_status_locked(struct lnet_ni *ni)
 __must_hold(&ni->ni_lock)
 {
-	if (ni->ni_nid == LNET_NID_LO_0)
+	if (nid_is_lo0(&ni->ni_nid))
 		return LNET_NI_STATUS_UP;
 	else if (atomic_read(&ni->ni_fatal_error_on))
 		return LNET_NI_STATUS_DOWN;
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 85b0d54..80cf4f3 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -463,7 +463,7 @@ struct lnet_ni {
 	u32			*ni_cpts;
 
 	/* interface's NID */
-	lnet_nid_t		ni_nid;
+	struct lnet_nid		ni_nid;
 
 	/* instance-specific data */
 	void			*ni_data;
diff --git a/include/uapi/linux/lnet/lnet-idl.h b/include/uapi/linux/lnet/lnet-idl.h
index 1e27f3b..3fc0df1 100644
--- a/include/uapi/linux/lnet/lnet-idl.h
+++ b/include/uapi/linux/lnet/lnet-idl.h
@@ -40,18 +40,42 @@
  * These are sent in sender's byte order (i.e. receiver flips).
  */
 
-/**
- * Address of an end-point in an LNet network.
+/** Address of an end-point in an LNet network.
  *
  * A node can have multiple end-points and hence multiple addresses.
  * An LNet network can be a simple network (e.g. tcp0) or a network of
  * LNet networks connected by LNet routers. Therefore an end-point address
  * has two parts: network ID, and address within a network.
+ * The most-significant-byte in this format is always 0.  A larger value
+ * would imply a larger nid with a larger address.
  *
  * \see LNET_NIDNET, LNET_NIDADDR, and LNET_MKNID.
  */
 typedef __u64 lnet_nid_t;
 
+/*
+ * Address of LNet end-point in extended form
+ *
+ * To support addresses larger than 32bits we have
+ * an extended nid which supports up to 128 bits
+ * of address and is extensible.
+ * If nid_size is 0, then the nid can be stored in an lnet_nid_t,
+ * and the first 8 bytes of the 'struct lnet_nid' are identical to
+ * the lnet_nid_t in big-endian format.
+ * If nid_type == 0xff, then all other fields should be ignored
+ * and this is an ANY wildcard address.  In particular, the nid_size
+ * can be 0xff without making the address too big to fit.
+ */
+struct lnet_nid {
+	__u8	nid_size;	/* total bytes - 8 */
+	__u8	nid_type;
+	__be16	nid_num;
+	__be32	nid_addr[4];
+} __attribute__((packed));
+
+#define NID_BYTES(nid)		((nid)->nid_size + 8)
+#define NID_ADDR_BYTES(nid)	((nid)->nid_size + 4)
+
 /**
  * ID of a process in a node. Shortened as PID to distinguish from
  * lnet_process_id, the global process ID.
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 0c426ac..ba8a079 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -37,6 +37,9 @@
 #include <linux/types.h>
 #include <linux/lnet/lnet-idl.h>
 
+#include <linux/string.h>
+#include <asm/byteorder.h>
+
 /** \addtogroup lnet
  * @{
  */
@@ -57,6 +60,15 @@
 /** wildcard PID that matches any lnet_pid_t */
 #define LNET_PID_ANY	((lnet_pid_t)(-1))
 
+static inline int LNET_NID_IS_ANY(const struct lnet_nid *nid)
+{
+	/* A NULL pointer can be used to mean "ANY" */
+	return !nid || nid->nid_type == 0xFF;
+}
+
+#define LNET_ANY_NID ((struct lnet_nid)			\
+		      {0xFF, 0xFF, ~0, {~0, ~0, ~0, ~0} })
+
 #define LNET_PID_RESERVED 0xf0000000 /* reserved bits in PID */
 #define LNET_PID_USERFLAG 0x80000000 /* set in userspace peers */
 #define LNET_PID_LUSTRE	  12345
@@ -86,7 +98,7 @@ static inline __u32 LNET_NETNUM(__u32 net)
 
 static inline __u32 LNET_NETTYP(__u32 net)
 {
-	return (net >> 16) & 0xffff;
+	return (net >> 16) & 0xff;
 }
 
 static inline __u32 LNET_MKNET(__u32 type, __u32 num)
@@ -99,6 +111,58 @@ static inline __u32 LNET_MKNET(__u32 type, __u32 num)
 
 #define LNET_NET_ANY LNET_NIDNET(LNET_NID_ANY)
 
+static inline int nid_is_nid4(const struct lnet_nid *nid)
+{
+	return NID_ADDR_BYTES(nid) == 4;
+}
+
+/* LOLND may not be defined yet, so we cannot use an inline */
+#define nid_is_lo0(__nid)						\
+	((__nid)->nid_type == LOLND &&					\
+	 nid_is_nid4(__nid) &&						\
+	 (__nid)->nid_num == 0 &&					\
+	 (__nid)->nid_addr[0] == 0)
+
+static inline __u32 LNET_NID_NET(const struct lnet_nid *nid)
+{
+	return LNET_MKNET(nid->nid_type, __be16_to_cpu(nid->nid_num));
+}
+
+static inline void lnet_nid4_to_nid(lnet_nid_t nid4, struct lnet_nid *nid)
+{
+	if (nid4 == LNET_NID_ANY) {
+		/* equal to setting to LNET_ANY_NID */
+		memset(nid, 0xff, sizeof(*nid));
+		return;
+	}
+
+	nid->nid_size = 0;
+	nid->nid_type = LNET_NETTYP(LNET_NIDNET(nid4));
+	nid->nid_num = __cpu_to_be16(LNET_NETNUM(LNET_NIDNET(nid4)));
+	nid->nid_addr[0] = __cpu_to_be32(LNET_NIDADDR(nid4));
+	nid->nid_addr[1] = nid->nid_addr[2] = nid->nid_addr[3] = 0;
+}
+
+static inline lnet_nid_t lnet_nid_to_nid4(const struct lnet_nid *nid)
+{
+	if (LNET_NID_IS_ANY(nid))
+		return LNET_NID_ANY;
+
+	return LNET_MKNID(LNET_NID_NET(nid), __be32_to_cpu(nid->nid_addr[0]));
+}
+
+static inline int nid_same(const struct lnet_nid *n1,
+			    const struct lnet_nid *n2)
+{
+	return n1->nid_size == n2->nid_size &&
+		n1->nid_type == n2->nid_type &&
+		n1->nid_num == n2->nid_num &&
+		n1->nid_addr[0] == n2->nid_addr[0] &&
+		n1->nid_addr[1] == n2->nid_addr[1] &&
+		n1->nid_addr[2] == n2->nid_addr[2] &&
+		n1->nid_addr[3] == n2->nid_addr[3];
+}
+
 struct lnet_counters_health {
 	__u32	lch_rst_alloc;
 	__u32	lch_resend_count;
diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index caf28e2..d5b9d69 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -62,7 +62,7 @@ enum {
 struct list_head;
 
 #define LNET_NIDSTR_COUNT	1024	/* # of nidstrings */
-#define LNET_NIDSTR_SIZE	32	/* size of each one (see below for usage) */
+#define LNET_NIDSTR_SIZE	64	/* size of each one (see below for usage) */
 
 /* support decl needed by both kernel and user space */
 char *libcfs_next_nidstring(void);
@@ -90,6 +90,14 @@ static inline char *libcfs_nid2str(lnet_nid_t nid)
 				LNET_NIDSTR_SIZE);
 }
 
+char *libcfs_nidstr_r(const struct lnet_nid *nid,
+		      char *buf, __kernel_size_t buf_size);
+static inline char *libcfs_nidstr(const struct lnet_nid *nid)
+{
+	return libcfs_nidstr_r(nid, libcfs_next_nidstring(),
+			       LNET_NIDSTR_SIZE);
+}
+
 __u32 libcfs_str2net(const char *str);
 lnet_nid_t libcfs_str2nid(const char *str);
 int libcfs_str2anynid(lnet_nid_t *nid, const char *str);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index a4949d8..fd807c2 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -178,8 +178,7 @@ void kiblnd_pack_msg(struct lnet_ni *ni, struct kib_msg *msg, int version,
 {
 	struct kib_net *net = ni->ni_data;
 
-	/*
-	 * CAVEAT EMPTOR! all message fields not set here should have been
+	/* CAVEAT EMPTOR! all message fields not set here should have been
 	 * initialised previously.
 	 */
 	msg->ibm_magic = IBLND_MSG_MAGIC;
@@ -188,7 +187,7 @@ void kiblnd_pack_msg(struct lnet_ni *ni, struct kib_msg *msg, int version,
 	msg->ibm_credits = credits;
 	/*   ibm_nob */
 	msg->ibm_cksum = 0;
-	msg->ibm_srcnid = ni->ni_nid;
+	msg->ibm_srcnid = lnet_nid_to_nid4(&ni->ni_nid);
 	msg->ibm_srcstamp = net->ibn_incarnation;
 	msg->ibm_dstnid = dstnid;
 	msg->ibm_dststamp = dststamp;
@@ -397,7 +396,7 @@ struct kib_peer_ni *kiblnd_find_peer_locked(struct lnet_ni *ni, lnet_nid_t nid)
 		 * created.
 		 */
 		if (peer_ni->ibp_nid != nid ||
-		    peer_ni->ibp_ni->ni_nid != ni->ni_nid)
+		    !nid_same(&peer_ni->ibp_ni->ni_nid, &ni->ni_nid))
 			continue;
 
 		CDEBUG(D_NET, "got peer_ni [%p] -> %s (%d) version: %x\n",
@@ -2201,7 +2200,7 @@ static int kiblnd_port_get_attr(struct kib_hca_dev *hdev)
 	list_for_each_entry(net, &hdev->ibh_dev->ibd_nets, ibn_list) {
 		if (val)
 			CDEBUG(D_NETERROR, "Fatal device error for NI %s\n",
-			       libcfs_nid2str(net->ibn_ni->ni_nid));
+			       libcfs_nidstr(&net->ibn_ni->ni_nid));
 		atomic_set(&net->ibn_ni->ni_fatal_error_on, val);
 	}
 }
@@ -2591,7 +2590,7 @@ static void kiblnd_shutdown(struct lnet_ni *ni)
 		wait_var_event_warning(&net->ibn_npeers,
 				       atomic_read(&net->ibn_npeers) == 0,
 				       "%s: waiting for %d peers to disconnect\n",
-				       libcfs_nid2str(ni->ni_nid),
+				       libcfs_nidstr(&ni->ni_nid),
 				       atomic_read(&net->ibn_npeers));
 
 		kiblnd_net_fini_pools(net);
@@ -2906,7 +2905,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	}
 
 	net->ibn_dev = ibdev;
-	ni->ni_nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid), ibdev->ibd_ifip);
+	ni->ni_nid.nid_addr[0] = cpu_to_be32(ibdev->ibd_ifip);
 
 	ni->ni_dev_cpt = ifaces[i].li_cpt;
 
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 8ccd2ab..380374e 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -507,7 +507,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	}
 
 	if (msg->ibm_srcnid != conn->ibc_peer->ibp_nid ||
-	    msg->ibm_dstnid != ni->ni_nid ||
+	    msg->ibm_dstnid != lnet_nid_to_nid4(&ni->ni_nid) ||
 	    msg->ibm_srcstamp != conn->ibc_incarnation ||
 	    msg->ibm_dststamp != net->ibn_incarnation) {
 		CERROR("Stale rx from %s\n",
@@ -2369,11 +2369,12 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	}
 
 	if (!ni ||				/* no matching net */
-	    ni->ni_nid != reqmsg->ibm_dstnid ||	/* right NET, wrong NID! */
+	    lnet_nid_to_nid4(&ni->ni_nid) !=
+	    reqmsg->ibm_dstnid ||		/* right NET, wrong NID! */
 	    net->ibn_dev != ibdev) {		/* wrong device */
 		CERROR("Can't accept conn from %s on %s (%s:%d:%pI4h): bad dst nid %s\n",
 		       libcfs_nid2str(nid),
-		       !ni ? "NA" : libcfs_nid2str(ni->ni_nid),
+		       ni ? libcfs_nidstr(&ni->ni_nid) : "NA",
 		       ibdev->ibd_ifname, ibdev->ibd_nnets,
 		       &ibdev->ibd_ifip,
 		       libcfs_nid2str(reqmsg->ibm_dstnid));
@@ -2490,8 +2491,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		 * the lower NID connection win so we can move forward.
 		 */
 		if (peer2->ibp_connecting &&
-		    nid < ni->ni_nid && peer2->ibp_races <
-		    MAX_CONN_RACES_BEFORE_ABORT) {
+		    nid < lnet_nid_to_nid4(&ni->ni_nid) &&
+		    peer2->ibp_races < MAX_CONN_RACES_BEFORE_ABORT) {
 			peer2->ibp_races++;
 			write_unlock_irqrestore(g_lock, flags);
 
@@ -2924,7 +2925,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	}
 
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
-	if (msg->ibm_dstnid == ni->ni_nid &&
+	if (msg->ibm_dstnid == lnet_nid_to_nid4(&ni->ni_nid) &&
 	    msg->ibm_dststamp == net->ibn_incarnation)
 		rc = 0;
 	else
@@ -3568,13 +3569,13 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	case IB_EVENT_PORT_ERR:
 	case IB_EVENT_DEVICE_FATAL:
 		CERROR("Fatal device error for NI %s\n",
-		       libcfs_nid2str(conn->ibc_peer->ibp_ni->ni_nid));
+		       libcfs_nidstr(&conn->ibc_peer->ibp_ni->ni_nid));
 		atomic_set(&conn->ibc_peer->ibp_ni->ni_fatal_error_on, 1);
 		return;
 
 	case IB_EVENT_PORT_ACTIVE:
 		CERROR("Port reactivated for NI %s\n",
-		       libcfs_nid2str(conn->ibc_peer->ibp_ni->ni_nid));
+		       libcfs_nidstr(&conn->ibc_peer->ibp_ni->ni_nid));
 		atomic_set(&conn->ibc_peer->ibp_ni->ni_fatal_error_on, 0);
 		return;
 
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 96cb0e0..21569fb 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -949,7 +949,7 @@ struct ksock_peer_ni *
 		 * Am I already connecting to this guy?  Resolve in
 		 * favour of higher NID...
 		 */
-		if (peerid.nid < ni->ni_nid &&
+		if (peerid.nid < lnet_nid_to_nid4(&ni->ni_nid) &&
 		    ksocknal_connecting(peer_ni->ksnp_conn_cb,
 					((struct sockaddr *)&conn->ksnc_peeraddr))) {
 			rc = EALREADY;
@@ -1820,12 +1820,13 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 	case IOC_LIBCFS_REGISTER_MYNID:
 		/* Ignore if this is a noop */
-		if (data->ioc_nid == ni->ni_nid)
+		if (nid_is_nid4(&ni->ni_nid) &&
+		    data->ioc_nid == lnet_nid_to_nid4(&ni->ni_nid))
 			return 0;
 
 		CERROR("obsolete IOC_LIBCFS_REGISTER_MYNID: %s(%s)\n",
 		       libcfs_nid2str(data->ioc_nid),
-		       libcfs_nid2str(ni->ni_nid));
+		       libcfs_nidstr(&ni->ni_nid));
 		return -EINVAL;
 
 	case IOC_LIBCFS_PUSH_CONNECTION:
@@ -2369,8 +2370,7 @@ static int ksocknal_device_event(struct notifier_block *unused,
 
 	LASSERT(ksi);
 	LASSERT(ksi->ksni_addr.ss_family == AF_INET);
-	ni->ni_nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid),
-				ntohl(((struct sockaddr_in *)&ksi->ksni_addr)->sin_addr.s_addr));
+	ni->ni_nid.nid_addr[0] = ((struct sockaddr_in *)&ksi->ksni_addr)->sin_addr.s_addr;
 	list_add(&net->ksnn_list, &ksocknal_data.ksnd_nets);
 	net->ksnn_ni = ni;
 	ksocknal_data.ksnd_nnets++;
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index efec479..e6cd976 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1579,7 +1579,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	/* rely on caller to hold a ref on socket so it wouldn't disappear */
 	LASSERT(conn->ksnc_proto);
 
-	hello->kshm_src_nid = ni->ni_nid;
+	hello->kshm_src_nid = lnet_nid_to_nid4(&ni->ni_nid);
 	hello->kshm_dst_nid = peer_nid;
 	hello->kshm_src_pid = the_lnet.ln_pid;
 
@@ -1628,7 +1628,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	LASSERT(!active == !(conn->ksnc_type != SOCKLND_CONN_NONE));
 
 	timeout = active ? ksocknal_timeout() :
-			    lnet_acceptor_timeout();
+		lnet_acceptor_timeout();
 
 	rc = lnet_sock_read(sock, &hello->kshm_magic,
 			    sizeof(hello->kshm_magic), timeout);
@@ -1672,7 +1672,9 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 				conn->ksnc_proto = &ksocknal_protocol_v1x;
 #endif
 			hello->kshm_nips = 0;
-			ksocknal_send_hello(ni, conn, ni->ni_nid, hello);
+			ksocknal_send_hello(ni, conn,
+					    lnet_nid_to_nid4(&ni->ni_nid),
+					    hello);
 		}
 
 		CERROR("Unknown protocol version (%d.x expected) from %pIS\n",
@@ -1709,7 +1711,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		recv_id.pid = rpc_get_port((struct sockaddr *)
 					   &conn->ksnc_peeraddr) |
 					   LNET_PID_USERFLAG;
-		recv_id.nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid),
+		recv_id.nid = LNET_MKNID(LNET_NID_NET(&ni->ni_nid),
 					 ntohl(((struct sockaddr_in *)
 					 &conn->ksnc_peeraddr)->sin_addr.s_addr));
 	} else {
diff --git a/net/lnet/lnet/acceptor.c b/net/lnet/lnet/acceptor.c
index 3708b89..243c34f 100644
--- a/net/lnet/lnet/acceptor.c
+++ b/net/lnet/lnet/acceptor.c
@@ -284,7 +284,8 @@ struct socket *
 
 	ni = lnet_nid2ni_addref(cr.acr_nid);
 	if (!ni ||			/* no matching net */
-	    ni->ni_nid != cr.acr_nid) { /* right NET, wrong NID! */
+	    lnet_nid_to_nid4(&ni->ni_nid) != cr.acr_nid) {
+		/* right NET, wrong NID! */
 		if (ni)
 			lnet_ni_decref(ni);
 		LCONSOLE_ERROR_MSG(0x120,
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 41d2d26..9471edb 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -667,6 +667,17 @@ static void lnet_assert_wire_constants(void)
 	BUILD_BUG_ON((int)sizeof(lnet_nid_t) != 8);
 	BUILD_BUG_ON((int)sizeof(lnet_pid_t) != 4);
 
+	/* Checks for struct lnet_nid */
+	BUILD_BUG_ON((int)sizeof(struct lnet_nid) != 20);
+	BUILD_BUG_ON((int)offsetof(struct lnet_nid, nid_size) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_nid *)0)->nid_size) != 1);
+	BUILD_BUG_ON((int)offsetof(struct lnet_nid, nid_type) != 1);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_nid *)0)->nid_type) != 1);
+	BUILD_BUG_ON((int)offsetof(struct lnet_nid, nid_num) != 2);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_nid *)0)->nid_num) != 2);
+	BUILD_BUG_ON((int)offsetof(struct lnet_nid, nid_addr) != 4);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_nid *)0)->nid_addr) != 16);
+
 	/* Checks for struct lnet_process_id_packed */
 	BUILD_BUG_ON((int)sizeof(struct lnet_process_id_packed) != 12);
 	BUILD_BUG_ON((int)offsetof(struct lnet_process_id_packed, nid) != 0);
@@ -1518,16 +1529,18 @@ struct lnet_net *
 }
 
 struct lnet_ni *
-lnet_nid2ni_locked(lnet_nid_t nid, int cpt)
+lnet_nid2ni_locked(lnet_nid_t nid4, int cpt)
 {
 	struct lnet_net *net;
 	struct lnet_ni *ni;
+	struct lnet_nid nid;
 
 	LASSERT(cpt != LNET_LOCK_EX);
+	lnet_nid4_to_nid(nid4, &nid);
 
 	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
 		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
-			if (ni->ni_nid == nid)
+			if (nid_same(&ni->ni_nid, &nid))
 				return ni;
 		}
 	}
@@ -1826,7 +1839,9 @@ struct lnet_ping_buffer *
 
 			ns = &pbuf->pb_info.pi_ni[i];
 
-			ns->ns_nid = ni->ni_nid;
+			if (!nid_is_nid4(&ni->ni_nid))
+				continue;
+			ns->ns_nid = lnet_nid_to_nid4(&ni->ni_nid);
 
 			lnet_ni_lock(ni);
 			ns->ns_status = lnet_ni_get_status_locked(ni);
@@ -2142,7 +2157,7 @@ static void lnet_push_target_fini(void)
 			++i;
 			if ((i & (-i)) == i) {
 				CDEBUG(D_WARNING, "Waiting for zombie LNI %s\n",
-				       libcfs_nid2str(ni->ni_nid));
+				       libcfs_nidstr(&ni->ni_nid));
 			}
 			schedule_timeout_uninterruptible(HZ);
 
@@ -2167,7 +2182,7 @@ static void lnet_push_target_fini(void)
 
 		if (!islo)
 			CDEBUG(D_LNI, "Removed LNI %s\n",
-			       libcfs_nid2str(ni->ni_nid));
+			       libcfs_nidstr(&ni->ni_nid));
 
 		lnet_ni_free(ni);
 		i = 2;
@@ -2283,7 +2298,6 @@ static void lnet_push_target_fini(void)
 	struct lnet_tx_queue *tq;
 	int i;
 	struct lnet_net *net = ni->ni_net;
-	u32 seed;
 
 	mutex_lock(&the_lnet.ln_lnd_mutex);
 
@@ -2339,18 +2353,12 @@ static void lnet_push_target_fini(void)
 		tq->tq_credits = lnet_ni_tq_credits(ni);
 	}
 
-	/* Nodes with small feet have little entropy. The NID for this
-	 * node gives the most entropy in the low bits.
-	 */
-	seed = LNET_NIDADDR(ni->ni_nid);
-	add_device_randomness(&seed, sizeof(seed));
-
 	atomic_set(&ni->ni_tx_credits,
 		   lnet_ni_tq_credits(ni) * ni->ni_ncpts);
 	atomic_set(&ni->ni_healthv, LNET_MAX_HEALTH_VALUE);
 
 	CDEBUG(D_LNI, "Added LNI %s [%d/%d/%d/%d]\n",
-	       libcfs_nid2str(ni->ni_nid),
+	       libcfs_nidstr(&ni->ni_nid),
 	       ni->ni_net->net_tunables.lct_peer_tx_credits,
 	       lnet_ni_tq_credits(ni) * LNET_CPT_NUMBER,
 	       ni->ni_net->net_tunables.lct_peer_rtr_credits,
@@ -2924,7 +2932,7 @@ void lnet_lib_exit(void)
 	size_t min_size = 0;
 	int i;
 
-	if (!ni || !cfg_ni || !tun)
+	if (!ni || !cfg_ni || !tun || !nid_is_nid4(&ni->ni_nid))
 		return;
 
 	if (ni->ni_interface) {
@@ -2933,7 +2941,7 @@ void lnet_lib_exit(void)
 			sizeof(cfg_ni->lic_ni_intf));
 	}
 
-	cfg_ni->lic_nid = ni->ni_nid;
+	cfg_ni->lic_nid = lnet_nid_to_nid4(&ni->ni_nid);
 	cfg_ni->lic_status = lnet_ni_get_status_locked(ni);
 	cfg_ni->lic_dev_cpt = ni->ni_dev_cpt;
 
@@ -2993,7 +3001,7 @@ void lnet_lib_exit(void)
 	size_t min_size, tunable_size = 0;
 	int i;
 
-	if (!ni || !config)
+	if (!ni || !config || !nid_is_nid4(&ni->ni_nid))
 		return;
 
 	net_config = (struct lnet_ioctl_net_config *)config->cfg_bulk;
@@ -3007,7 +3015,7 @@ void lnet_lib_exit(void)
 		ni->ni_interface,
 		sizeof(net_config->ni_interface));
 
-	config->cfg_nid = ni->ni_nid;
+	config->cfg_nid = lnet_nid_to_nid4(&ni->ni_nid);
 	config->cfg_config_u.cfg_net.net_peer_timeout =
 		ni->ni_net->net_tunables.lct_peer_timeout;
 	config->cfg_config_u.cfg_net.net_max_tx_credits =
@@ -3287,7 +3295,7 @@ static int lnet_add_net_common(struct lnet_net *net,
 		rc = lnet_udsp_apply_policies_on_ni(ni);
 		if (rc)
 			CERROR("Failed to apply UDSPs on ni %s\n",
-			       libcfs_nid2str(ni->ni_nid));
+			       libcfs_nidstr(&ni->ni_nid));
 	}
 	lnet_net_unlock(LNET_LOCK_EX);
 
@@ -3637,12 +3645,13 @@ u32 lnet_get_dlc_seq_locked(void)
 	lnet_net_lock(LNET_LOCK_EX);
 	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
 		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
-			if (ni->ni_nid == nid || all) {
+			if (all || (nid_is_nid4(&ni->ni_nid) &&
+				    lnet_nid_to_nid4(&ni->ni_nid) == nid)) {
 				atomic_set(&ni->ni_healthv, value);
 				if (list_empty(&ni->ni_recovery) &&
 				    value < LNET_MAX_HEALTH_VALUE) {
 					CERROR("manually adding local NI %s to recovery\n",
-					       libcfs_nid2str(ni->ni_nid));
+					       libcfs_nidstr(&ni->ni_nid));
 					list_add_tail(&ni->ni_recovery,
 						      &the_lnet.ln_mt_localNIRecovq);
 					lnet_ni_addref_locked(ni, 0);
@@ -3666,7 +3675,7 @@ u32 lnet_get_dlc_seq_locked(void)
 	lnet_net_lock(LNET_LOCK_EX);
 	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
 		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
-			if (ni->ni_nid != nid && !all)
+			if (lnet_nid_to_nid4(&ni->ni_nid) != nid && !all)
 				continue;
 			if (LNET_NETTYP(net->net_id) == SOCKLND)
 				ni->ni_lnd_tunables.lnd_tun_u.lnd_sock.lnd_conns_per_peer = value;
@@ -3729,7 +3738,9 @@ u32 lnet_get_dlc_seq_locked(void)
 
 	lnet_net_lock(LNET_LOCK_EX);
 	list_for_each_entry(ni, &the_lnet.ln_mt_localNIRecovq, ni_recovery) {
-		list->rlst_nid_array[i] = ni->ni_nid;
+		if (!nid_is_nid4(&ni->ni_nid))
+			continue;
+		list->rlst_nid_array[i] = lnet_nid_to_nid4(&ni->ni_nid);
 		i++;
 		if (i >= LNET_MAX_SHOW_NUM_NID)
 			break;
@@ -4381,10 +4392,13 @@ void LNetDebugPeer(struct lnet_process_id id)
 
 	list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
 		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
+			if (!nid_is_nid4(&ni->ni_nid))
+				/* FIXME this needs to be handled */
+				continue;
 			if (index-- != 0)
 				continue;
 
-			id->nid = ni->ni_nid;
+			id->nid = lnet_nid_to_nid4(&ni->ni_nid);
 			id->pid = the_lnet.ln_pid;
 			rc = 0;
 			break;
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 0117611..0c833fe 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -375,7 +375,7 @@ struct lnet_net *
 	if (ni->ni_interface) {
 		LCONSOLE_ERROR_MSG(0x115, "%s: interface %s already set for net %s: rc = %d\n",
 				   iface, ni->ni_interface,
-				   libcfs_net2str(LNET_NIDNET(ni->ni_nid)),
+				   libcfs_net2str(LNET_NID_NET(&ni->ni_nid)),
 				   -EINVAL);
 		return -EINVAL;
 	}
@@ -435,7 +435,8 @@ struct lnet_net *
 
 	ni->ni_net = net;
 	/* LND will fill in the address part of the NID */
-	ni->ni_nid = LNET_MKNID(net->net_id, 0);
+	ni->ni_nid.nid_type = LNET_NETTYP(net->net_id);
+	ni->ni_nid.nid_num = cpu_to_be16(LNET_NETNUM(net->net_id));
 
 	/* Store net namespace in which current ni is being created */
 	if (current->nsproxy && current->nsproxy->net_ns)
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 035bda3..c70ec37 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -537,7 +537,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	int rc;
 
 	LASSERT(!in_interrupt());
-	LASSERT(ni->ni_nid == LNET_NID_LO_0 ||
+	LASSERT(nid_is_lo0(&ni->ni_nid) ||
 		(msg->msg_txcredit && msg->msg_peertxcredit));
 
 	rc = ni->ni_net->net_lnd->lnd_send(ni, priv, msg);
@@ -648,7 +648,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 	/* can't get here if we're sending to the loopback interface */
 	if (the_lnet.ln_loni)
-		LASSERT(lp->lpni_nid != the_lnet.ln_loni->ni_nid);
+		LASSERT(lp->lpni_nid !=
+			lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid));
 
 	/* NB 'lp' is always the next hop */
 	if (!(msg->msg_target.pid & LNET_PID_USERFLAG) &&
@@ -1133,10 +1134,11 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		 * preferred, then let's use it
 		 */
 		if (best_ni) {
+			/* FIXME need to handle large-addr nid */
 			lpni_is_preferred = lnet_peer_is_pref_nid_locked(lpni,
-									 best_ni->ni_nid);
+									 lnet_nid_to_nid4(&best_ni->ni_nid));
 			CDEBUG(D_NET, "%s lpni_is_preferred = %d\n",
-			       libcfs_nid2str(best_ni->ni_nid),
+			       libcfs_nidstr(&best_ni->ni_nid),
 			       lpni_is_preferred);
 		} else {
 			lpni_is_preferred = false;
@@ -1514,9 +1516,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		if (best_ni)
 			CDEBUG(D_NET,
 			       "compare ni %s [c:%d, d:%d, s:%d, p:%u, g:%u] with best_ni %s [c:%d, d:%d, s:%d, p:%u, g:%u]\n",
-			       libcfs_nid2str(ni->ni_nid), ni_credits, distance,
+			       libcfs_nidstr(&ni->ni_nid), ni_credits, distance,
 			       ni->ni_seq, ni_sel_prio, ni_dev_prio,
-			       (best_ni) ? libcfs_nid2str(best_ni->ni_nid)
+			       (best_ni) ? libcfs_nidstr(&best_ni->ni_nid)
 			       : "not selected", best_credits, shortest_distance,
 			       (best_ni) ? best_ni->ni_seq : 0,
 			       best_sel_prio, best_dev_prio);
@@ -1561,7 +1563,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	}
 
 	CDEBUG(D_NET, "selected best_ni %s\n",
-	       (best_ni) ? libcfs_nid2str(best_ni->ni_nid) : "no selection");
+	       (best_ni) ? libcfs_nidstr(&best_ni->ni_nid) : "no selection");
 
 	return best_ni;
 }
@@ -1620,11 +1622,12 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 	/* No send credit hassles with LOLND */
 	lnet_ni_addref_locked(the_lnet.ln_loni, cpt);
-	msg->msg_hdr.dest_nid = cpu_to_le64(the_lnet.ln_loni->ni_nid);
+	msg->msg_hdr.dest_nid =
+		cpu_to_le64(lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid));
 	if (!msg->msg_routing)
 		msg->msg_hdr.src_nid =
-			cpu_to_le64(the_lnet.ln_loni->ni_nid);
-	msg->msg_target.nid = the_lnet.ln_loni->ni_nid;
+			cpu_to_le64(lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid));
+	msg->msg_target.nid = lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid);
 	lnet_msg_commit(msg, cpt);
 	msg->msg_txni = the_lnet.ln_loni;
 
@@ -1655,7 +1658,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 	CDEBUG(D_NET,
 	       "%s NI seq info: [%d:%d:%d:%u] %s LPNI seq info [%d:%d:%d:%u]\n",
-	       libcfs_nid2str(best_ni->ni_nid),
+	       libcfs_nidstr(&best_ni->ni_nid),
 	       best_ni->ni_seq, best_ni->ni_net->net_seq,
 	       atomic_read(&best_ni->ni_tx_credits),
 	       best_ni->ni_sel_priority,
@@ -1719,7 +1722,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	 * originator and set it here.
 	 */
 	if (!msg->msg_routing)
-		msg->msg_hdr.src_nid = cpu_to_le64(msg->msg_txni->ni_nid);
+		msg->msg_hdr.src_nid =
+			cpu_to_le64(lnet_nid_to_nid4(&msg->msg_txni->ni_nid));
 
 	if (routing) {
 		msg->msg_target_is_router = 1;
@@ -1757,7 +1761,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	if (!rc)
 		CDEBUG(D_NET, "TRACE: %s(%s:%s) -> %s(%s:%s) %s : %s try# %d\n",
 		       libcfs_nid2str(msg->msg_hdr.src_nid),
-		       libcfs_nid2str(msg->msg_txni->ni_nid),
+		       libcfs_nidstr(&msg->msg_txni->ni_nid),
 		       libcfs_nid2str(sd->sd_src_nid),
 		       libcfs_nid2str(msg->msg_hdr.dest_nid),
 		       libcfs_nid2str(sd->sd_dst_nid),
@@ -1775,9 +1779,10 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	if (!lnet_peer_is_multi_rail(lpni->lpni_peer_net->lpn_peer) &&
 	    !lnet_msg_is_response(msg) && lpni->lpni_pref_nnids == 0) {
 		CDEBUG(D_NET, "Setting preferred local NID %s on NMR peer %s\n",
-		       libcfs_nid2str(lni->ni_nid),
+		       libcfs_nidstr(&lni->ni_nid),
 		       libcfs_nid2str(lpni->lpni_nid));
-		lnet_peer_ni_set_non_mr_pref_nid(lpni, lni->ni_nid);
+		lnet_peer_ni_set_non_mr_pref_nid(lpni,
+						 lnet_nid_to_nid4(&lni->ni_nid));
 	}
 }
 
@@ -1828,7 +1833,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	}
 
 	if (sd->sd_best_lpni &&
-	    sd->sd_best_lpni->lpni_nid == the_lnet.ln_loni->ni_nid)
+	    sd->sd_best_lpni->lpni_nid ==
+	    lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid))
 		return lnet_handle_lo_send(sd);
 	else if (sd->sd_best_lpni)
 		return lnet_handle_send(sd);
@@ -1951,7 +1957,7 @@ struct lnet_ni *
 	struct lnet_peer_ni *gwni = NULL;
 	bool route_found = false;
 	lnet_nid_t src_nid = (sd->sd_src_nid != LNET_NID_ANY) ? sd->sd_src_nid :
-			      sd->sd_best_ni ? sd->sd_best_ni->ni_nid :
+			      sd->sd_best_ni ? lnet_nid_to_nid4(&sd->sd_best_ni->ni_nid) :
 			      LNET_NID_ANY;
 	int best_lpn_healthv = 0;
 	u32 best_lpn_sel_prio = LNET_MAX_SELECTION_PRIORITY;
@@ -2454,7 +2460,8 @@ struct lnet_ni *
 		 * network
 		 */
 		if (sd->sd_best_lpni &&
-		    sd->sd_best_lpni->lpni_nid == the_lnet.ln_loni->ni_nid) {
+		    sd->sd_best_lpni->lpni_nid ==
+		    lnet_nid_to_nid4(&the_lnet.ln_loni->ni_nid)) {
 			/* in case we initially started with a routed
 			 * destination, let's reset to local
 			 */
@@ -3195,7 +3202,7 @@ struct lnet_mt_event_info {
 		lnet_net_unlock(0);
 
 		CDEBUG(D_NET, "attempting to recover local ni: %s\n",
-		       libcfs_nid2str(ni->ni_nid));
+		       libcfs_nidstr(&ni->ni_nid));
 
 		lnet_ni_lock(ni);
 		if (!(ni->ni_recovery_state & LNET_NI_RECOVERY_PENDING)) {
@@ -3205,7 +3212,7 @@ struct lnet_mt_event_info {
 			ev_info = kzalloc(sizeof(*ev_info), GFP_NOFS);
 			if (!ev_info) {
 				CERROR("out of memory. Can't recover %s\n",
-				       libcfs_nid2str(ni->ni_nid));
+				       libcfs_nidstr(&ni->ni_nid));
 				lnet_ni_lock(ni);
 				ni->ni_recovery_state &=
 				  ~LNET_NI_RECOVERY_PENDING;
@@ -3218,7 +3225,8 @@ struct lnet_mt_event_info {
 			 * We'll unlink the mdh in this case below.
 			 */
 			LNetInvalidateMDHandle(&ni->ni_ping_mdh);
-			nid = ni->ni_nid;
+			/* FIXME need to handle large-addr nid */
+			nid = lnet_nid_to_nid4(&ni->ni_nid);
 
 			/* remove the NI from the local queue and drop the
 			 * reference count to it while we're recovering
@@ -3986,11 +3994,12 @@ void lnet_monitor_thr_stop(void)
 	lnet_ni_recv(ni, msg->msg_private, NULL, 0, 0, 0, 0);
 	msg->msg_receiving = 0;
 
-	rc = lnet_send(ni->ni_nid, msg, msg->msg_from);
+	/* FIXME need to handle large-addr nid */
+	rc = lnet_send(lnet_nid_to_nid4(&ni->ni_nid), msg, msg->msg_from);
 	if (rc < 0) {
 		/* didn't get as far as lnet_ni_send() */
 		CERROR("%s: Unable to send REPLY for GET from %s: %d\n",
-		       libcfs_nid2str(ni->ni_nid),
+		       libcfs_nidstr(&ni->ni_nid),
 		       libcfs_id2str(info.mi_id), rc);
 
 		lnet_finalize(msg, rc);
@@ -4020,7 +4029,7 @@ void lnet_monitor_thr_stop(void)
 	md = lnet_wire_handle2md(&hdr->msg.reply.dst_wmd);
 	if (!md || !md->md_threshold || md->md_me) {
 		CNETERR("%s: Dropping REPLY from %s for %s MD %#llx.%#llx\n",
-			libcfs_nid2str(ni->ni_nid), libcfs_id2str(src),
+			libcfs_nidstr(&ni->ni_nid), libcfs_id2str(src),
 			!md ? "invalid" : "inactive",
 			hdr->msg.reply.dst_wmd.wh_interface_cookie,
 			hdr->msg.reply.dst_wmd.wh_object_cookie);
@@ -4040,7 +4049,7 @@ void lnet_monitor_thr_stop(void)
 	if (mlength < rlength &&
 	    !(md->md_options & LNET_MD_TRUNCATE)) {
 		CNETERR("%s: Dropping REPLY from %s length %d for MD %#llx would overflow (%d)\n",
-			libcfs_nid2str(ni->ni_nid), libcfs_id2str(src),
+			libcfs_nidstr(&ni->ni_nid), libcfs_id2str(src),
 			rlength, hdr->msg.reply.dst_wmd.wh_object_cookie,
 			mlength);
 		lnet_res_unlock(cpt);
@@ -4048,7 +4057,7 @@ void lnet_monitor_thr_stop(void)
 	}
 
 	CDEBUG(D_NET, "%s: Reply from %s of length %d/%d into md %#llx\n",
-	       libcfs_nid2str(ni->ni_nid), libcfs_id2str(src),
+	       libcfs_nidstr(&ni->ni_nid), libcfs_id2str(src),
 	       mlength, rlength, hdr->msg.reply.dst_wmd.wh_object_cookie);
 
 	lnet_msg_attach_md(msg, md, 0, mlength);
@@ -4088,7 +4097,7 @@ void lnet_monitor_thr_stop(void)
 		/* Don't moan; this is expected */
 		CDEBUG(D_NET,
 		       "%s: Dropping ACK from %s to %s MD %#llx.%#llx\n",
-		       libcfs_nid2str(ni->ni_nid), libcfs_id2str(src),
+		       libcfs_nidstr(&ni->ni_nid), libcfs_id2str(src),
 		       !md ? "invalid" : "inactive",
 		       hdr->msg.ack.dst_wmd.wh_interface_cookie,
 		       hdr->msg.ack.dst_wmd.wh_object_cookie);
@@ -4101,7 +4110,7 @@ void lnet_monitor_thr_stop(void)
 	}
 
 	CDEBUG(D_NET, "%s: ACK from %s into md %#llx\n",
-	       libcfs_nid2str(ni->ni_nid), libcfs_id2str(src),
+	       libcfs_nidstr(&ni->ni_nid), libcfs_id2str(src),
 	       hdr->msg.ack.dst_wmd.wh_object_cookie);
 
 	lnet_msg_attach_md(msg, md, 0, 0);
@@ -4213,12 +4222,13 @@ void lnet_monitor_thr_stop(void)
 	dest_pid = le32_to_cpu(hdr->dest_pid);
 	payload_length = le32_to_cpu(hdr->payload_length);
 
-	for_me = (ni->ni_nid == dest_nid);
+	/* FIXME handle large-addr nids */
+	for_me = (lnet_nid_to_nid4(&ni->ni_nid) == dest_nid);
 	cpt = lnet_cpt_of_nid(from_nid, ni);
 
 	CDEBUG(D_NET, "TRACE: %s(%s) <- %s : %s\n",
 	       libcfs_nid2str(dest_nid),
-	       libcfs_nid2str(ni->ni_nid),
+	       libcfs_nidstr(&ni->ni_nid),
 	       libcfs_nid2str(src_nid),
 	       lnet_msgtyp2str(type));
 
@@ -4274,7 +4284,7 @@ void lnet_monitor_thr_stop(void)
 	 * or malicious so we chop them off at the knees :)
 	 */
 	if (!for_me) {
-		if (LNET_NIDNET(dest_nid) == LNET_NIDNET(ni->ni_nid)) {
+		if (LNET_NIDNET(dest_nid) == LNET_NID_NET(&ni->ni_nid)) {
 			/* should have gone direct */
 			CERROR("%s, src %s: Bad dest nid %s (should have been sent direct)\n",
 			       libcfs_nid2str(from_nid),
@@ -4324,8 +4334,9 @@ void lnet_monitor_thr_stop(void)
 		goto drop;
 	}
 
+	/* FIXME need to support large-addr nid */
 	if (!list_empty(&the_lnet.ln_drop_rules) &&
-	    lnet_drop_rule_match(hdr, ni->ni_nid, NULL)) {
+	    lnet_drop_rule_match(hdr, lnet_nid_to_nid4(&ni->ni_nid), NULL)) {
 		CDEBUG(D_NET, "%s, src %s, dst %s: Dropping %s to simulate silent message loss\n",
 		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
 		       libcfs_nid2str(dest_nid), lnet_msgtyp2str(type));
@@ -4368,7 +4379,9 @@ void lnet_monitor_thr_stop(void)
 	}
 
 	lnet_net_lock(cpt);
-	lpni = lnet_nid2peerni_locked(from_nid, ni->ni_nid, cpt);
+	/* FIXME support large-addr nid */
+	lpni = lnet_nid2peerni_locked(from_nid, lnet_nid_to_nid4(&ni->ni_nid),
+				      cpt);
 	if (IS_ERR(lpni)) {
 		lnet_net_unlock(cpt);
 		CERROR("%s, src %s: Dropping %s (error %ld looking up sender)\n",
@@ -4790,7 +4803,7 @@ struct lnet_msg *
 	msg = kmem_cache_zalloc(lnet_msg_cachep, GFP_NOFS);
 	if (!msg) {
 		CERROR("%s: Dropping REPLY from %s: can't allocate msg\n",
-		       libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id));
+		       libcfs_nidstr(&ni->ni_nid), libcfs_id2str(peer_id));
 		goto drop;
 	}
 
@@ -4801,7 +4814,7 @@ struct lnet_msg *
 
 	if (!getmd->md_threshold) {
 		CERROR("%s: Dropping REPLY from %s for inactive MD %p\n",
-		       libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id),
+		       libcfs_nidstr(&ni->ni_nid), libcfs_id2str(peer_id),
 		       getmd);
 		lnet_res_unlock(cpt);
 		goto drop;
@@ -4810,7 +4823,7 @@ struct lnet_msg *
 	LASSERT(!getmd->md_offset);
 
 	CDEBUG(D_NET, "%s: Reply from %s md %p\n",
-	       libcfs_nid2str(ni->ni_nid), libcfs_id2str(peer_id), getmd);
+	       libcfs_nidstr(&ni->ni_nid), libcfs_id2str(peer_id), getmd);
 
 	/* setup information for lnet_build_msg_event */
 	msg->msg_initiator = getmsg->msg_txpeer->lpni_peer_net->lpn_peer->lp_primary_nid;
@@ -5032,7 +5045,8 @@ struct lnet_msg *
 	cpt = lnet_net_lock_current();
 
 	while ((ni = lnet_get_next_ni_locked(NULL, ni))) {
-		if (ni->ni_nid == dstnid) {
+		/* FIXME support large-addr nid */
+		if (lnet_nid_to_nid4(&ni->ni_nid) == dstnid) {
 			if (srcnidp)
 				*srcnidp = dstnid;
 			if (orderp) {
@@ -5046,7 +5060,7 @@ struct lnet_msg *
 			return local_nid_dist_zero ? 0 : 1;
 		}
 
-		if (!matched_dstnet && LNET_NIDNET(ni->ni_nid) == dstnet) {
+		if (!matched_dstnet && LNET_NID_NET(&ni->ni_nid) == dstnet) {
 			matched_dstnet = true;
 			/* We matched the destination net, but we may have
 			 * additional local NIs to inspect.
@@ -5055,7 +5069,8 @@ struct lnet_msg *
 			 * they may be overwritten if we match local NI above.
 			 */
 			if (srcnidp)
-				*srcnidp = ni->ni_nid;
+				/* FIXME support large-addr nids */
+				*srcnidp = lnet_nid_to_nid4(&ni->ni_nid);
 
 			if (orderp) {
 				/* Check if ni was originally created in
@@ -5110,7 +5125,8 @@ struct lnet_msg *
 				net = lnet_get_net_locked(shortest->lr_lnet);
 				LASSERT(net);
 				ni = lnet_get_next_ni_locked(net, NULL);
-				*srcnidp = ni->ni_nid;
+				/* FIXME support large-addr nids */
+				*srcnidp = lnet_nid_to_nid4(&ni->ni_nid);
 			}
 			if (orderp)
 				*orderp = order;
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index e471848..b1f684f 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -473,7 +473,7 @@
 
 	CDEBUG(D_NET,
 	       "%s added to recovery queue. ping count: %u next ping: %lld health :%d\n",
-	       libcfs_nid2str(ni->ni_nid),
+	       libcfs_nidstr(&ni->ni_nid),
 	       ni->ni_ping_count,
 	       ni->ni_next_ping,
 	       atomic_read(&ni->ni_healthv));
@@ -796,10 +796,11 @@
 	/* if we're sending to the LOLND then the msg_txpeer will not be
 	 * set. So no need to sanity check it.
 	 */
-	if (msg->msg_tx_committed && msg->msg_txni->ni_nid != LNET_NID_LO_0)
+	if (msg->msg_tx_committed &&
+	    !nid_is_lo0(&msg->msg_txni->ni_nid))
 		LASSERT(msg->msg_txpeer);
 	else if (msg->msg_tx_committed &&
-		 msg->msg_txni->ni_nid == LNET_NID_LO_0)
+		 nid_is_lo0(&msg->msg_txni->ni_nid))
 		lo = true;
 
 	if (hstatus != LNET_MSG_STATUS_OK &&
@@ -827,7 +828,7 @@
 		LASSERT(ni);
 
 	CDEBUG(D_NET, "health check: %s->%s: %s: %s\n",
-	       libcfs_nid2str(ni->ni_nid),
+	       libcfs_nidstr(&ni->ni_nid),
 	       (lo) ? "self" : libcfs_nid2str(lpni->lpni_nid),
 	       lnet_msgtyp2str(msg->msg_type),
 	       lnet_health_error2str(hstatus));
@@ -1114,7 +1115,7 @@
 	CDEBUG(D_NET,
 	       "src %s(%s)->dst %s: %s simulate health error: %s\n",
 	       libcfs_nid2str(msg->msg_hdr.src_nid),
-	       libcfs_nid2str(msg->msg_txni->ni_nid),
+	       libcfs_nidstr(&msg->msg_txni->ni_nid),
 	       libcfs_nid2str(msg->msg_hdr.dest_nid),
 	       lnet_msgtyp2str(msg->msg_type),
 	       lnet_health_error2str(*hstatus));
diff --git a/net/lnet/lnet/lib-socket.c b/net/lnet/lnet/lib-socket.c
index 317d3cf..7deb48a 100644
--- a/net/lnet/lnet/lib-socket.c
+++ b/net/lnet/lnet/lib-socket.c
@@ -235,9 +235,33 @@ int choose_ipv4_src(u32 *ret, int interface, u32 dst_ipaddr, struct net *ns)
 #if IS_ENABLED(CONFIG_IPV6)
 		case AF_INET6: {
 			struct sockaddr_in6 *sin6 = (void *)&locaddr;
+			int val = 0;
 
 			sin6->sin6_family = AF_INET6;
 			sin6->sin6_addr = in6addr_any;
+
+			/* Make sure we get both IPv4 and IPv6 connections.
+			 * This is the default, but it can be overridden so we
+			 * force it back.
+			 */
+			/* From v5.7-rc6-2614-g5a892ff2facb when
+			 * kernel_setsockopt() was removed until
+			 * sockptr_t (above) there is no clean way to
+			 * pass kernel address to setsockopt.  We could
+			 * use get_fs()/set_fs(), but in this particular
+			 * situation there is an easier way.  It depends
+			 * on the fact that at least for these few
+			 * kernels a NULL address to ipv6_setsockopt()
+			 * is treated like the address of a zero.
+			 */
+			if (ipv6_only_sock(sock->sk) && !val) {
+				void *optval = NULL;
+
+				sock->ops->setsockopt(sock,
+						      IPPROTO_IPV6, IPV6_V6ONLY,
+						      optval, sizeof(val));
+			}
+
 			if (interface >= 0 && remaddr) {
 				struct sockaddr_in6 *rem = (void *)remaddr;
 
@@ -352,7 +376,6 @@ struct socket *
 lnet_sock_listen(int local_port, int backlog, struct net *ns)
 {
 	struct socket *sock;
-	int val = 0;
 	int rc;
 
 	sock = lnet_sock_create(-1, NULL, local_port, ns);
@@ -364,13 +387,6 @@ struct socket *
 		return ERR_PTR(rc);
 	}
 
-	/* Make sure we get both IPv4 and IPv6 connections.
-	 * This is the default, but it can be overridden so
-	 * we force it back.
-	 */
-	kernel_setsockopt(sock, IPPROTO_IPV6, IPV6_V6ONLY,
-			  (char *)&val, sizeof(val));
-
 	rc = kernel_listen(sock, backlog);
 	if (!rc)
 		return sock;
diff --git a/net/lnet/lnet/lo.c b/net/lnet/lnet/lo.c
index 4ddf1cd..3d3dcf8 100644
--- a/net/lnet/lnet/lo.c
+++ b/net/lnet/lnet/lo.c
@@ -40,7 +40,8 @@
 	LASSERT(!lntmsg->msg_routing);
 	LASSERT(!lntmsg->msg_target_is_router);
 
-	return lnet_parse(ni, &lntmsg->msg_hdr, ni->ni_nid, lntmsg, 0);
+	return lnet_parse(ni, &lntmsg->msg_hdr,
+			  lnet_nid_to_nid4(&ni->ni_nid), lntmsg, 0);
 }
 
 static int
diff --git a/net/lnet/lnet/net_fault.c b/net/lnet/lnet/net_fault.c
index 0d19da4..4c50eec 100644
--- a/net/lnet/lnet/net_fault.c
+++ b/net/lnet/lnet/net_fault.c
@@ -684,7 +684,7 @@ struct delay_daemon_data {
 			list_del_init(&msg->msg_list);
 			ni = msg->msg_txni;
 			CDEBUG(D_NET, "TRACE: msg %p %s -> %s : %s\n", msg,
-			       libcfs_nid2str(ni->ni_nid),
+			       libcfs_nidstr(&ni->ni_nid),
 			       libcfs_nid2str(msg->msg_txpeer->lpni_nid),
 			       lnet_msgtyp2str(msg->msg_type));
 			lnet_ni_send(ni, msg);
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index 209da0f..6da43d5 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -906,6 +906,46 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 }
 EXPORT_SYMBOL(libcfs_nid2str_r);
 
+char *
+libcfs_nidstr_r(const struct lnet_nid *nid, char *buf, size_t buf_size)
+{
+	u32 nnum = be16_to_cpu(nid->nid_num);
+	u32 lnd  = nid->nid_type;
+	struct netstrfns *nf;
+
+	if (LNET_NID_IS_ANY(nid)) {
+		strncpy(buf, "<?>", buf_size);
+		buf[buf_size - 1] = '\0';
+		return buf;
+	}
+
+	nf = libcfs_lnd2netstrfns(lnd);
+	if (nf && nid_is_nid4(nid)) {
+		size_t addr_len;
+
+		nf->nf_addr2str(ntohl(nid->nid_addr[0]), buf, buf_size);
+		addr_len = strlen(buf);
+		if (nnum == 0)
+			snprintf(buf + addr_len, buf_size - addr_len, "@%s",
+				 nf->nf_name);
+		else
+			snprintf(buf + addr_len, buf_size - addr_len, "@%s%u",
+				 nf->nf_name, nnum);
+	} else {
+		int l = 0;
+		int words = DIV_ROUND_UP(NID_ADDR_BYTES(nid), 4);
+		int i;
+
+		for (i = 0; i < words && i < 4; i++)
+			l = snprintf(buf + l, buf_size - l, "%s%x",
+				     i ? ":" : "", ntohl(nid->nid_addr[i]));
+		snprintf(buf + l, buf_size - l, "@<%u:%u>", lnd, nnum);
+	}
+
+	return buf;
+}
+EXPORT_SYMBOL(libcfs_nidstr_r);
+
 static struct netstrfns *
 libcfs_str2net_internal(const char *str, u32 *net)
 {
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 9003d47..6335425 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1691,21 +1691,21 @@ bool lnet_router_checker_active(void)
 	LASSERT(!in_interrupt());
 
 	CDEBUG(D_NET, "%s notifying %s: %s\n",
-	       !ni ? "userspace" : libcfs_nid2str(ni->ni_nid),
+	       !ni ? "userspace" : libcfs_nidstr(&ni->ni_nid),
 	       libcfs_nid2str(nid), alive ? "up" : "down");
 
 	if (ni &&
-	    LNET_NIDNET(ni->ni_nid) != LNET_NIDNET(nid)) {
+	    LNET_NID_NET(&ni->ni_nid) != LNET_NIDNET(nid)) {
 		CWARN("Ignoring notification of %s %s by %s (different net)\n",
 		      libcfs_nid2str(nid), alive ? "birth" : "death",
-		      libcfs_nid2str(ni->ni_nid));
+		      libcfs_nidstr(&ni->ni_nid));
 		return -EINVAL;
 	}
 
 	/* can't do predictions... */
 	if (when > now) {
 		CWARN("Ignoring prediction from %s of %s %s %lld seconds in the future\n",
-		      !ni ? "userspace" : libcfs_nid2str(ni->ni_nid),
+		      ni ? libcfs_nidstr(&ni->ni_nid) : "userspace",
 		      libcfs_nid2str(nid), alive ? "up" : "down", when - now);
 		return -EINVAL;
 	}
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 43f70b6..6649f06 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -702,7 +702,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 
 				s += scnprintf(s, tmpstr + tmpsiz - s,
 					       "%-24s %6s %5lld %4d %4d %4d %5d %5d %5d\n",
-					       libcfs_nid2str(ni->ni_nid), stat,
+					       libcfs_nidstr(&ni->ni_nid), stat,
 					       last_alive, *ni->ni_refs[i],
 					       ni->ni_net->net_tunables.lct_peer_tx_credits,
 					       ni->ni_net->net_tunables.lct_peer_rtr_credits,
diff --git a/net/lnet/lnet/udsp.c b/net/lnet/lnet/udsp.c
index 516db98..4495062 100644
--- a/net/lnet/lnet/udsp.c
+++ b/net/lnet/lnet/udsp.c
@@ -213,7 +213,7 @@ enum udsp_apply {
 	struct lnet_ud_nid_descr *ni_match = udi->udi_match;
 	u32 priority = (udi->udi_revert) ? -1 : udi->udi_priority;
 
-	rc = cfs_match_nid_net(ni->ni_nid,
+	rc = cfs_match_nid_net(lnet_nid_to_nid4(&ni->ni_nid),
 			       ni_match->ud_net_id.udn_net_type,
 			       &ni_match->ud_net_id.udn_net_num_range,
 			       &ni_match->ud_addr_range);
@@ -221,7 +221,7 @@ enum udsp_apply {
 		return 0;
 
 	CDEBUG(D_NET, "apply udsp on ni %s\n",
-	       libcfs_nid2str(ni->ni_nid));
+	       libcfs_nidstr(&ni->ni_nid));
 
 	/* Detected match. Set NIDs priority */
 	lnet_ni_set_sel_priority_locked(ni, priority);
@@ -481,7 +481,7 @@ enum udsp_apply {
 		    ni_action->ud_net_id.udn_net_type)
 			continue;
 		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
-			rc = cfs_match_nid_net(ni->ni_nid,
+			rc = cfs_match_nid_net(lnet_nid_to_nid4(&ni->ni_nid),
 					       ni_action->ud_net_id.udn_net_type,
 					       &ni_action->ud_net_id.udn_net_num_range,
 					       &ni_action->ud_addr_range);
@@ -500,15 +500,16 @@ enum udsp_apply {
 				}
 			}
 			CDEBUG(D_NET, "add nid %s as preferred for peer %s\n",
-			       libcfs_nid2str(ni->ni_nid),
+			       libcfs_nidstr(&ni->ni_nid),
 			       libcfs_nid2str(lpni->lpni_nid));
 			/* match. Add to pref NIDs */
-			rc = lnet_peer_add_pref_nid(lpni, ni->ni_nid);
+			rc = lnet_peer_add_pref_nid(lpni,
+						    lnet_nid_to_nid4(&ni->ni_nid));
 			lnet_net_lock(LNET_LOCK_EX);
 			/* success if EEXIST return */
 			if (rc && rc != -EEXIST) {
 				CERROR("Failed to add %s to %s pref nid list\n",
-				       libcfs_nid2str(ni->ni_nid),
+				       libcfs_nidstr(&ni->ni_nid),
 				       libcfs_nid2str(lpni->lpni_nid));
 				return rc;
 			}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
