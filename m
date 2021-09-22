Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 176A4C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:33 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CCC5E6112F
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org CCC5E6112F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 715F321EBE2;
	Tue, 21 Sep 2021 19:21:32 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 68B0121E0B4
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:08 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 161CE35A;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 12F91FF4A8; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:46 -0400
Message-Id: <1632277201-6920-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/24] lnet: introduce lnet_processid for
 ksock_peer_ni
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

struct lnet_processid (without the '_') is like lnet_process_id, but
contains a 'struct lnet_nid' rather than lnet_nid_t.

So far it is only used for ksnp_id in struct ksock_peer_ni, and
related functions.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: e1dbfdd53e2ce9543 ("LU-10391 lnet: introduce lnet_processid for ksock_peer_ni")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/42104
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h          |   1 +
 include/uapi/linux/lnet/lnet-types.h   |  36 +++++-
 include/uapi/linux/lnet/nidstr.h       |   1 +
 net/lnet/klnds/socklnd/socklnd.c       | 208 ++++++++++++++++++---------------
 net/lnet/klnds/socklnd/socklnd.h       |  14 +--
 net/lnet/klnds/socklnd/socklnd_cb.c    | 111 ++++++++++--------
 net/lnet/klnds/socklnd/socklnd_proto.c |  14 +--
 net/lnet/lnet/api-ni.c                 |  21 +++-
 net/lnet/lnet/nidstrings.c             |  18 +++
 9 files changed, 259 insertions(+), 165 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index a4ec067..3842976 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -484,6 +484,7 @@ unsigned int lnet_nid_cpt_hash(struct lnet_nid *nid,
 			       unsigned int number);
 int lnet_cpt_of_nid_locked(struct lnet_nid *nid, struct lnet_ni *ni);
 int lnet_cpt_of_nid(lnet_nid_t nid, struct lnet_ni *ni);
+int lnet_nid2cpt(struct lnet_nid *nid, struct lnet_ni *ni);
 struct lnet_ni *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
 struct lnet_ni *lnet_nid2ni_addref(lnet_nid_t nid);
 struct lnet_ni *lnet_net2ni_locked(u32 net, int cpt);
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 5538d4e..ec0c4ef 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -164,12 +164,14 @@ static inline int nid_same(const struct lnet_nid *n1,
 }
 
 /* This can be used when we need to hash a nid */
-static inline unsigned long nidhash(lnet_nid_t nid)
+static inline unsigned long nidhash(const struct lnet_nid *nid)
 {
+	int i;
 	unsigned long hash = 0;
 
-	hash ^= LNET_NIDNET(nid);
-	hash ^= LNET_NIDADDR(nid);
+	hash ^= LNET_NID_NET(nid);
+	for (i = 0; i < 4; i++)
+		hash ^= nid->nid_addr[i];
 	return hash;
 }
 
@@ -241,6 +243,34 @@ struct lnet_process_id {
 	/** process id */
 	lnet_pid_t pid;
 };
+
+/**
+ * Global process ID - with large addresses
+ */
+struct lnet_processid {
+	/** node id */
+	struct lnet_nid nid;
+	/** process id */
+	lnet_pid_t pid;
+};
+
+static inline void
+lnet_pid4_to_pid(struct lnet_process_id pid4, struct lnet_processid *pid)
+{
+	pid->pid = pid4.pid;
+	lnet_nid4_to_nid(pid4.nid, &pid->nid);
+}
+
+static inline struct lnet_process_id
+lnet_pid_to_pid4(struct lnet_processid *pid)
+{
+	struct lnet_process_id ret;
+
+	ret.pid = pid->pid;
+	ret.nid = lnet_nid_to_nid4(&pid->nid);
+	return ret;
+}
+
 /** @} lnet_addr */
 
 /** \addtogroup lnet_me
diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index 13a0d10..bfc9644 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -103,6 +103,7 @@ static inline char *libcfs_nidstr(const struct lnet_nid *nid)
 int libcfs_strnid(struct lnet_nid *nid, const char *str);
 int libcfs_str2anynid(lnet_nid_t *nid, const char *str);
 char *libcfs_id2str(struct lnet_process_id id);
+char *libcfs_idstr(struct lnet_processid *id);
 void cfs_free_nidlist(struct list_head *list);
 int cfs_parse_nidlist(char *str, int len, struct list_head *list);
 int cfs_print_nidlist(char *buffer, int count, struct list_head *list);
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 08d1cf4..7397ac7 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -152,14 +152,14 @@ static int ksocknal_ip2index(struct sockaddr *addr, struct lnet_ni *ni)
 }
 
 static struct ksock_peer_ni *
-ksocknal_create_peer(struct lnet_ni *ni, struct lnet_process_id id)
+ksocknal_create_peer(struct lnet_ni *ni, struct lnet_processid *id)
 {
-	int cpt = lnet_cpt_of_nid(id.nid, ni);
+	int cpt = lnet_nid2cpt(&id->nid, ni);
 	struct ksock_net *net = ni->ni_data;
 	struct ksock_peer_ni *peer_ni;
 
-	LASSERT(id.nid != LNET_NID_ANY);
-	LASSERT(id.pid != LNET_PID_ANY);
+	LASSERT(!LNET_NID_IS_ANY(&id->nid));
+	LASSERT(id->pid != LNET_PID_ANY);
 	LASSERT(!in_interrupt());
 
 	if (!atomic_inc_unless_negative(&net->ksnn_npeers)) {
@@ -174,7 +174,7 @@ static int ksocknal_ip2index(struct sockaddr *addr, struct lnet_ni *ni)
 	}
 
 	peer_ni->ksnp_ni = ni;
-	peer_ni->ksnp_id = id;
+	peer_ni->ksnp_id = *id;
 	refcount_set(&peer_ni->ksnp_refcount, 1);   /* 1 ref for caller */
 	peer_ni->ksnp_closing = 0;
 	peer_ni->ksnp_accepting = 0;
@@ -197,7 +197,7 @@ static int ksocknal_ip2index(struct sockaddr *addr, struct lnet_ni *ni)
 	struct ksock_net *net = peer_ni->ksnp_ni->ni_data;
 
 	CDEBUG(D_NET, "peer_ni %s %p deleted\n",
-	       libcfs_id2str(peer_ni->ksnp_id), peer_ni);
+	       libcfs_idstr(&peer_ni->ksnp_id), peer_ni);
 
 	LASSERT(!refcount_read(&peer_ni->ksnp_refcount));
 	LASSERT(!peer_ni->ksnp_accepting);
@@ -218,10 +218,10 @@ static int ksocknal_ip2index(struct sockaddr *addr, struct lnet_ni *ni)
 }
 
 struct ksock_peer_ni *
-ksocknal_find_peer_locked(struct lnet_ni *ni, struct lnet_process_id id)
+ksocknal_find_peer_locked(struct lnet_ni *ni, struct lnet_processid *id)
 {
 	struct ksock_peer_ni *peer_ni;
-	unsigned long hash = nidhash(id.nid);
+	unsigned long hash = nidhash(&id->nid);
 
 	hash_for_each_possible(ksocknal_data.ksnd_peers, peer_ni,
 			       ksnp_list, hash) {
@@ -230,12 +230,12 @@ struct ksock_peer_ni *
 		if (peer_ni->ksnp_ni != ni)
 			continue;
 
-		if (peer_ni->ksnp_id.nid != id.nid ||
-		    peer_ni->ksnp_id.pid != id.pid)
+		if (!nid_same(&peer_ni->ksnp_id.nid, &id->nid) ||
+		    peer_ni->ksnp_id.pid != id->pid)
 			continue;
 
 		CDEBUG(D_NET, "got peer_ni [%p] -> %s (%d)\n",
-		       peer_ni, libcfs_id2str(id),
+		       peer_ni, libcfs_idstr(id),
 		       refcount_read(&peer_ni->ksnp_refcount));
 		return peer_ni;
 	}
@@ -243,7 +243,7 @@ struct ksock_peer_ni *
 }
 
 struct ksock_peer_ni *
-ksocknal_find_peer(struct lnet_ni *ni, struct lnet_process_id id)
+ksocknal_find_peer(struct lnet_ni *ni, struct lnet_processid *id)
 {
 	struct ksock_peer_ni *peer_ni;
 
@@ -312,7 +312,8 @@ struct ksock_peer_ni *
 			if (index-- > 0)
 				continue;
 
-			*id = peer_ni->ksnp_id;
+			id->pid = peer_ni->ksnp_id.pid;
+			id->nid = lnet_nid_to_nid4(&peer_ni->ksnp_id.nid);
 			*myip = 0;
 			*peer_ip = 0;
 			*port = 0;
@@ -326,7 +327,8 @@ struct ksock_peer_ni *
 			if (index-- > 0)
 				continue;
 
-			*id = peer_ni->ksnp_id;
+			id->pid = peer_ni->ksnp_id.pid;
+			id->nid = lnet_nid_to_nid4(&peer_ni->ksnp_id.nid);
 			*myip = peer_ni->ksnp_passive_ips[j];
 			*peer_ip = 0;
 			*port = 0;
@@ -342,7 +344,8 @@ struct ksock_peer_ni *
 
 			conn_cb = peer_ni->ksnp_conn_cb;
 
-			*id = peer_ni->ksnp_id;
+			id->pid = peer_ni->ksnp_id.pid;
+			id->nid = lnet_nid_to_nid4(&peer_ni->ksnp_id.nid);
 			if (conn_cb->ksnr_addr.ss_family == AF_INET) {
 				struct sockaddr_in *sa;
 
@@ -465,13 +468,13 @@ struct ksock_peer_ni *
 			 * conn_cb)
 			 */
 			CDEBUG(D_NET, "Binding %s %pIS to interface %d\n",
-			       libcfs_id2str(peer_ni->ksnp_id),
+			       libcfs_idstr(&peer_ni->ksnp_id),
 			       &conn_cb->ksnr_addr,
 			       conn_iface);
 		} else {
 			CDEBUG(D_NET,
 			       "Rebinding %s %pIS from interface %d to %d\n",
-			       libcfs_id2str(peer_ni->ksnp_id),
+			       libcfs_idstr(&peer_ni->ksnp_id),
 			       &conn_cb->ksnr_addr,
 			       conn_cb->ksnr_myiface,
 			       conn_iface);
@@ -567,26 +570,27 @@ struct ksock_peer_ni *
 }
 
 int
-ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, u32 ipaddr,
-		  int port)
+ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id4,
+		  struct sockaddr *addr)
 {
 	struct ksock_peer_ni *peer_ni;
 	struct ksock_peer_ni *peer2;
 	struct ksock_conn_cb *conn_cb;
-	struct sockaddr_in sa = {.sin_family = AF_INET};
+	struct lnet_processid id;
 
-	if (id.nid == LNET_NID_ANY ||
-	    id.pid == LNET_PID_ANY)
+	if (id4.nid == LNET_NID_ANY ||
+	    id4.pid == LNET_PID_ANY)
 		return -EINVAL;
 
+	id.pid = id4.pid;
+	lnet_nid4_to_nid(id4.nid, &id.nid);
+
 	/* Have a brand new peer_ni ready... */
-	peer_ni = ksocknal_create_peer(ni, id);
+	peer_ni = ksocknal_create_peer(ni, &id);
 	if (IS_ERR(peer_ni))
 		return PTR_ERR(peer_ni);
 
-	sa.sin_addr.s_addr = htonl(ipaddr);
-	sa.sin_port = htons(port);
-	conn_cb = ksocknal_create_conn_cb((struct sockaddr *)&sa);
+	conn_cb = ksocknal_create_conn_cb(addr);
 	if (!conn_cb) {
 		ksocknal_peer_decref(peer_ni);
 		return -ENOMEM;
@@ -597,14 +601,14 @@ struct ksock_peer_ni *
 	/* always called with a ref on ni, so shutdown can't have started */
 	LASSERT(atomic_read(&((struct ksock_net *)ni->ni_data)->ksnn_npeers) >= 0);
 
-	peer2 = ksocknal_find_peer_locked(ni, id);
+	peer2 = ksocknal_find_peer_locked(ni, &id);
 	if (peer2) {
 		ksocknal_peer_decref(peer_ni);
 		peer_ni = peer2;
 	} else {
 		/* peer_ni table takes my ref on peer_ni */
 		hash_add(ksocknal_data.ksnd_peers, &peer_ni->ksnp_list,
-			 nidhash(id.nid));
+			 nidhash(&id.nid));
 	}
 
 	ksocknal_add_conn_cb_locked(peer_ni, conn_cb);
@@ -645,7 +649,7 @@ struct ksock_peer_ni *
 }
 
 static int
-ksocknal_del_peer(struct lnet_ni *ni, struct lnet_process_id id, u32 ip)
+ksocknal_del_peer(struct lnet_ni *ni, struct lnet_process_id id4, u32 ip)
 {
 	LIST_HEAD(zombies);
 	struct hlist_node *pnxt;
@@ -654,11 +658,15 @@ struct ksock_peer_ni *
 	int hi;
 	int i;
 	int rc = -ENOENT;
+	struct lnet_processid id;
+
+	id.pid = id4.pid;
+	lnet_nid4_to_nid(id4.nid, &id.nid);
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
-	if (id.nid != LNET_NID_ANY) {
-		lo = hash_min(nidhash(id.nid),
+	if (!LNET_NID_IS_ANY(&id.nid)) {
+		lo = hash_min(nidhash(&id.nid),
 			      HASH_BITS(ksocknal_data.ksnd_peers));
 		hi = lo;
 	} else {
@@ -673,8 +681,8 @@ struct ksock_peer_ni *
 			if (peer_ni->ksnp_ni != ni)
 				continue;
 
-			if (!((id.nid == LNET_NID_ANY ||
-			       peer_ni->ksnp_id.nid == id.nid) &&
+			if (!((LNET_NID_IS_ANY(&id.nid) ||
+			       nid_same(&peer_ni->ksnp_id.nid, &id.nid)) &&
 			      (id.pid == LNET_PID_ANY ||
 			       peer_ni->ksnp_id.pid == id.pid)))
 				continue;
@@ -805,7 +813,7 @@ struct ksock_peer_ni *
 {
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
 	LIST_HEAD(zombies);
-	struct lnet_process_id peerid;
+	struct lnet_process_id peerid4;
 	u64 incarnation;
 	struct ksock_conn *conn;
 	struct ksock_conn *conn2;
@@ -879,7 +887,7 @@ struct ksock_peer_ni *
 
 		/* Active connection sends HELLO eagerly */
 		hello->kshm_nips =  0;
-		peerid = peer_ni->ksnp_id;
+		peerid4 = lnet_pid_to_pid4(&peer_ni->ksnp_id);
 
 		write_lock_bh(global_lock);
 		conn->ksnc_proto = peer_ni->ksnp_proto;
@@ -895,32 +903,35 @@ struct ksock_peer_ni *
 #endif
 		}
 
-		rc = ksocknal_send_hello(ni, conn, peerid.nid, hello);
+		rc = ksocknal_send_hello(ni, conn, peerid4.nid, hello);
 		if (rc)
 			goto failed_1;
 	} else {
-		peerid.nid = LNET_NID_ANY;
-		peerid.pid = LNET_PID_ANY;
+		peerid4.nid = LNET_NID_ANY;
+		peerid4.pid = LNET_PID_ANY;
 
 		/* Passive, get protocol from peer_ni */
 		conn->ksnc_proto = NULL;
 	}
 
-	rc = ksocknal_recv_hello(ni, conn, hello, &peerid, &incarnation);
+	rc = ksocknal_recv_hello(ni, conn, hello, &peerid4, &incarnation);
 	if (rc < 0)
 		goto failed_1;
 
 	LASSERT(!rc || active);
 	LASSERT(conn->ksnc_proto);
-	LASSERT(peerid.nid != LNET_NID_ANY);
+	LASSERT(peerid4.nid != LNET_NID_ANY);
 
-	cpt = lnet_cpt_of_nid(peerid.nid, ni);
+	cpt = lnet_cpt_of_nid(peerid4.nid, ni);
 
 	if (active) {
 		ksocknal_peer_addref(peer_ni);
 		write_lock_bh(global_lock);
 	} else {
-		peer_ni = ksocknal_create_peer(ni, peerid);
+		struct lnet_processid peerid;
+
+		lnet_pid4_to_pid(peerid4, &peerid);
+		peer_ni = ksocknal_create_peer(ni, &peerid);
 		if (IS_ERR(peer_ni)) {
 			rc = PTR_ERR(peer_ni);
 			goto failed_1;
@@ -931,14 +942,14 @@ struct ksock_peer_ni *
 		/* called with a ref on ni, so shutdown can't have started */
 		LASSERT(atomic_read(&((struct ksock_net *)ni->ni_data)->ksnn_npeers) >= 0);
 
-		peer2 = ksocknal_find_peer_locked(ni, peerid);
+		peer2 = ksocknal_find_peer_locked(ni, &peerid);
 		if (!peer2) {
 			/*
 			 * NB this puts an "empty" peer_ni in the peer
 			 * table (which takes my ref)
 			 */
 			hash_add(ksocknal_data.ksnd_peers,
-				 &peer_ni->ksnp_list, nidhash(peerid.nid));
+				 &peer_ni->ksnp_list, nidhash(&peerid.nid));
 		} else {
 			ksocknal_peer_decref(peer_ni);
 			peer_ni = peer2;
@@ -952,7 +963,7 @@ struct ksock_peer_ni *
 		 * Am I already connecting to this guy?  Resolve in
 		 * favour of higher NID...
 		 */
-		if (peerid.nid < lnet_nid_to_nid4(&ni->ni_nid) &&
+		if (peerid4.nid < lnet_nid_to_nid4(&ni->ni_nid) &&
 		    ksocknal_connecting(peer_ni->ksnp_conn_cb,
 					((struct sockaddr *)&conn->ksnc_peeraddr))) {
 			rc = EALREADY;
@@ -1051,7 +1062,7 @@ struct ksock_peer_ni *
 	    !rpc_cmp_addr((struct sockaddr *)&conn_cb->ksnr_addr,
 			  (struct sockaddr *)&conn->ksnc_peeraddr)) {
 		CERROR("Route %s %pIS connected to %pIS\n",
-		       libcfs_id2str(peer_ni->ksnp_id),
+		       libcfs_idstr(&peer_ni->ksnp_id),
 		       &conn_cb->ksnr_addr,
 		       &conn->ksnc_peeraddr);
 	}
@@ -1123,13 +1134,13 @@ struct ksock_peer_ni *
 	 */
 	CDEBUG(D_NET,
 	       "New conn %s p %d.x %pIS -> %pISp incarnation:%lld sched[%d]\n",
-	       libcfs_id2str(peerid), conn->ksnc_proto->pro_version,
+	       libcfs_id2str(peerid4), conn->ksnc_proto->pro_version,
 	       &conn->ksnc_myaddr, &conn->ksnc_peeraddr,
 	       incarnation, cpt);
 
 	if (!active) {
 		hello->kshm_nips = 0;
-		rc = ksocknal_send_hello(ni, conn, peerid.nid, hello);
+		rc = ksocknal_send_hello(ni, conn, peerid4.nid, hello);
 	}
 
 	kvfree(hello);
@@ -1185,10 +1196,10 @@ struct ksock_peer_ni *
 	if (warn) {
 		if (rc < 0)
 			CERROR("Not creating conn %s type %d: %s\n",
-			       libcfs_id2str(peerid), conn->ksnc_type, warn);
+			       libcfs_id2str(peerid4), conn->ksnc_type, warn);
 		else
 			CDEBUG(D_NET, "Not creating conn %s type %d: %s\n",
-			       libcfs_id2str(peerid), conn->ksnc_type, warn);
+			       libcfs_id2str(peerid4), conn->ksnc_type, warn);
 	}
 
 	if (!active) {
@@ -1199,7 +1210,7 @@ struct ksock_peer_ni *
 			 */
 			conn->ksnc_type = SOCKLND_CONN_NONE;
 			hello->kshm_nips = 0;
-			ksocknal_send_hello(ni, conn, peerid.nid, hello);
+			ksocknal_send_hello(ni, conn, peerid4.nid, hello);
 		}
 
 		write_lock_bh(global_lock);
@@ -1338,7 +1349,8 @@ struct ksock_peer_ni *
 	read_unlock(&ksocknal_data.ksnd_global_lock);
 
 	if (notify)
-		lnet_notify(peer_ni->ksnp_ni, peer_ni->ksnp_id.nid,
+		lnet_notify(peer_ni->ksnp_ni,
+			    lnet_nid_to_nid4(&peer_ni->ksnp_id.nid),
 			    false, false, last_alive);
 }
 
@@ -1481,7 +1493,8 @@ struct ksock_peer_ni *
 		last_rcv = conn->ksnc_rx_deadline -
 			   ksocknal_timeout();
 		CERROR("Completing partial receive from %s[%d], ip %pISp, with error, wanted: %zd, left: %d, last alive is %lld secs ago\n",
-		       libcfs_id2str(conn->ksnc_peer->ksnp_id), conn->ksnc_type,
+		       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
+		       conn->ksnc_type,
 		       &conn->ksnc_peeraddr,
 		       iov_iter_count(&conn->ksnc_rx_to), conn->ksnc_rx_nob_left,
 		       ktime_get_seconds() - last_rcv);
@@ -1493,21 +1506,21 @@ struct ksock_peer_ni *
 	case SOCKNAL_RX_LNET_HEADER:
 		if (conn->ksnc_rx_started)
 			CERROR("Incomplete receive of lnet header from %s, ip %pISp, with error, protocol: %d.x.\n",
-			       libcfs_id2str(conn->ksnc_peer->ksnp_id),
+			       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
 			       &conn->ksnc_peeraddr,
 			       conn->ksnc_proto->pro_version);
 		break;
 	case SOCKNAL_RX_KSM_HEADER:
 		if (conn->ksnc_rx_started)
 			CERROR("Incomplete receive of ksock message from %s, ip %pISp, with error, protocol: %d.x.\n",
-			       libcfs_id2str(conn->ksnc_peer->ksnp_id),
+			       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
 			       &conn->ksnc_peeraddr,
 			       conn->ksnc_proto->pro_version);
 		break;
 	case SOCKNAL_RX_SLOP:
 		if (conn->ksnc_rx_started)
 			CERROR("Incomplete receive of slops from %s, ip %pISp, with error\n",
-			       libcfs_id2str(conn->ksnc_peer->ksnp_id),
+			       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
 			       &conn->ksnc_peeraddr);
 	       break;
 	default:
@@ -1557,7 +1570,7 @@ struct ksock_peer_ni *
 }
 
 int
-ksocknal_close_matching_conns(struct lnet_process_id id, u32 ipaddr)
+ksocknal_close_matching_conns(struct lnet_processid *id, u32 ipaddr)
 {
 	struct ksock_peer_ni *peer_ni;
 	struct hlist_node *pnxt;
@@ -1569,8 +1582,8 @@ struct ksock_peer_ni *
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
-	if (id.nid != LNET_NID_ANY) {
-		lo = hash_min(nidhash(id.nid),
+	if (!LNET_NID_IS_ANY(&id->nid)) {
+		lo = hash_min(nidhash(&id->nid),
 			      HASH_BITS(ksocknal_data.ksnd_peers));
 		hi = lo;
 	} else {
@@ -1583,10 +1596,10 @@ struct ksock_peer_ni *
 		hlist_for_each_entry_safe(peer_ni, pnxt,
 					  &ksocknal_data.ksnd_peers[i],
 					  ksnp_list) {
-			if (!((id.nid == LNET_NID_ANY ||
-			       id.nid == peer_ni->ksnp_id.nid) &&
-			      (id.pid == LNET_PID_ANY ||
-			       id.pid == peer_ni->ksnp_id.pid)))
+			if (!((LNET_NID_IS_ANY(&id->nid) ||
+			       nid_same(&id->nid, &peer_ni->ksnp_id.nid)) &&
+			      (id->pid == LNET_PID_ANY ||
+			       id->pid == peer_ni->ksnp_id.pid)))
 				continue;
 
 			count += ksocknal_close_peer_conns_locked(peer_ni,
@@ -1598,7 +1611,8 @@ struct ksock_peer_ni *
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
 	/* wildcards always succeed */
-	if (id.nid == LNET_NID_ANY || id.pid == LNET_PID_ANY || !ipaddr)
+	if (LNET_NID_IS_ANY(&id->nid) || id->pid == LNET_PID_ANY ||
+	    !ipaddr)
 		return 0;
 
 	return count ? 0 : -ENOENT;
@@ -1611,15 +1625,15 @@ struct ksock_peer_ni *
 	 * The router is telling me she's been notified of a change in
 	 * gateway state....
 	 */
-	struct lnet_process_id id = {0};
-
-	id.nid = gw_nid;
-	id.pid = LNET_PID_ANY;
+	struct lnet_processid id = {
+		.pid	= LNET_PID_ANY,
+	};
 
 	CDEBUG(D_NET, "gw %s down\n", libcfs_nid2str(gw_nid));
 
+	lnet_nid4_to_nid(gw_nid, &id.nid);
 	/* If the gateway crashed, close all open connections... */
-	ksocknal_close_matching_conns(id, 0);
+	ksocknal_close_matching_conns(&id, 0);
 	return;
 
 	/*
@@ -1658,15 +1672,15 @@ struct ksock_peer_ni *
 	}
 }
 
-static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
+static int ksocknal_push(struct lnet_ni *ni, struct lnet_processid *id)
 {
 	int lo;
 	int hi;
 	int bkt;
 	int rc = -ENOENT;
 
-	if (id.nid != LNET_NID_ANY) {
-		lo = hash_min(nidhash(id.nid),
+	if (!LNET_NID_IS_ANY(&id->nid)) {
+		lo = hash_min(nidhash(&id->nid),
 			      HASH_BITS(ksocknal_data.ksnd_peers));
 		hi = lo;
 	} else {
@@ -1685,10 +1699,11 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 			hlist_for_each_entry(peer_ni,
 					     &ksocknal_data.ksnd_peers[bkt],
 					     ksnp_list) {
-				if (!((id.nid == LNET_NID_ANY ||
-				       id.nid == peer_ni->ksnp_id.nid) &&
-				      (id.pid == LNET_PID_ANY ||
-				       id.pid == peer_ni->ksnp_id.pid)))
+				if (!((LNET_NID_IS_ANY(&id->nid) ||
+				       nid_same(&id->nid,
+						&peer_ni->ksnp_id.nid)) &&
+				      (id->pid == LNET_PID_ANY ||
+				       id->pid == peer_ni->ksnp_id.pid)))
 					continue;
 
 				if (i++ == peer_off) {
@@ -1712,7 +1727,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 int
 ksocknal_ctl(struct lnet_ni *ni, unsigned int cmd, void *arg)
 {
-	struct lnet_process_id id = {0};
+	struct lnet_process_id id4 = {};
+	struct lnet_processid id = {};
 	struct libcfs_ioctl_data *data = arg;
 	int rc;
 
@@ -1752,32 +1768,34 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		int share_count = 0;
 
 		rc = ksocknal_get_peer_info(ni, data->ioc_count,
-					    &id, &myip, &ip, &port,
+					    &id4, &myip, &ip, &port,
 					    &conn_count,  &share_count);
 		if (rc)
 			return rc;
 
-		data->ioc_nid  = id.nid;
+		data->ioc_nid = id4.nid;
 		data->ioc_count = share_count;
 		data->ioc_u32[0] = ip;
 		data->ioc_u32[1] = port;
 		data->ioc_u32[2] = myip;
 		data->ioc_u32[3] = conn_count;
-		data->ioc_u32[4] = id.pid;
+		data->ioc_u32[4] = id4.pid;
 		return 0;
 	}
 
-	case IOC_LIBCFS_ADD_PEER:
-		id.nid = data->ioc_nid;
-		id.pid = LNET_PID_LUSTRE;
-		return ksocknal_add_peer(ni, id,
-					 data->ioc_u32[0], /* IP */
-					 data->ioc_u32[1]); /* port */
+	case IOC_LIBCFS_ADD_PEER: {
+		struct sockaddr_in sa = {.sin_family = AF_INET};
 
+		id4.nid = data->ioc_nid;
+		id4.pid = LNET_PID_LUSTRE;
+		sa.sin_addr.s_addr = htonl(data->ioc_u32[0]);
+		sa.sin_port = htons(data->ioc_u32[1]);
+		return ksocknal_add_peer(ni, id4, (struct sockaddr *)&sa);
+	}
 	case IOC_LIBCFS_DEL_PEER:
-		id.nid = data->ioc_nid;
-		id.pid = LNET_PID_ANY;
-		return ksocknal_del_peer(ni, id,
+		id4.nid = data->ioc_nid;
+		id4.pid = LNET_PID_ANY;
+		return ksocknal_del_peer(ni, id4,
 					 data->ioc_u32[0]); /* IP */
 
 	case IOC_LIBCFS_GET_CONN: {
@@ -1797,7 +1815,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		ksocknal_lib_get_conn_tunables(conn, &txmem, &rxmem, &nagle);
 
 		data->ioc_count = txmem;
-		data->ioc_nid = conn->ksnc_peer->ksnp_id.nid;
+		data->ioc_nid = lnet_nid_to_nid4(&conn->ksnc_peer->ksnp_id.nid);
 		data->ioc_flags = nagle;
 		if (psa->sin_family == AF_INET)
 			data->ioc_u32[0] = ntohl(psa->sin_addr.s_addr);
@@ -1818,9 +1836,9 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	}
 
 	case IOC_LIBCFS_CLOSE_CONNECTION:
-		id.nid = data->ioc_nid;
+		lnet_nid4_to_nid(data->ioc_nid, &id.nid);
 		id.pid = LNET_PID_ANY;
-		return ksocknal_close_matching_conns(id,
+		return ksocknal_close_matching_conns(&id,
 						     data->ioc_u32[0]);
 
 	case IOC_LIBCFS_REGISTER_MYNID:
@@ -1835,9 +1853,9 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		return -EINVAL;
 
 	case IOC_LIBCFS_PUSH_CONNECTION:
-		id.nid = data->ioc_nid;
+		lnet_nid4_to_nid(data->ioc_nid, &id.nid);
 		id.pid = LNET_PID_ANY;
-		return ksocknal_push(ni, id);
+		return ksocknal_push(ni, &id);
 
 	default:
 		return -EINVAL;
@@ -2145,7 +2163,7 @@ static int ksocknal_device_event(struct notifier_block *unused,
 			continue;
 
 		CWARN("Active peer_ni on shutdown: %s, ref %d, closing %d, accepting %d, err %d, zcookie %llu, txq %d, zc_req %d\n",
-		      libcfs_id2str(peer_ni->ksnp_id),
+		      libcfs_idstr(&peer_ni->ksnp_id),
 		      refcount_read(&peer_ni->ksnp_refcount),
 		      peer_ni->ksnp_closing,
 		      peer_ni->ksnp_accepting, peer_ni->ksnp_error,
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 7a55492..fe1bc7d 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -415,7 +415,7 @@ struct ksock_peer_ni {
 	time64_t		ksnp_last_alive;	/* when (in seconds) I was last
 							 * alive
 							 */
-	struct lnet_process_id	ksnp_id;		/* who's on the other end(s) */
+	struct lnet_processid	ksnp_id;		/* who's on the other end(s) */
 	refcount_t		ksnp_refcount;		/* # users */
 	int			ksnp_closing;		/* being closed */
 	int			ksnp_accepting;		/* # passive connections pending
@@ -625,12 +625,12 @@ int ksocknal_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
 		  int delayed, struct iov_iter *to, unsigned int rlen);
 int ksocknal_accept(struct lnet_ni *ni, struct socket *sock);
 
-int ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, u32 ip,
-		      int port);
+int ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id,
+		      struct sockaddr *addr);
 struct ksock_peer_ni *ksocknal_find_peer_locked(struct lnet_ni *ni,
-					        struct lnet_process_id id);
+						struct lnet_processid *id);
 struct ksock_peer_ni *ksocknal_find_peer(struct lnet_ni *ni,
-				         struct lnet_process_id id);
+					 struct lnet_processid *id);
 void ksocknal_peer_failed(struct ksock_peer_ni *peer_ni);
 int ksocknal_create_conn(struct lnet_ni *ni, struct ksock_conn_cb *conn_cb,
 			 struct socket *sock, int type);
@@ -640,12 +640,12 @@ int ksocknal_create_conn(struct lnet_ni *ni, struct ksock_conn_cb *conn_cb,
 int ksocknal_close_peer_conns_locked(struct ksock_peer_ni *peer_ni,
 				     struct sockaddr *peer, int why);
 int ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why);
-int ksocknal_close_matching_conns(struct lnet_process_id id, u32 ipaddr);
+int ksocknal_close_matching_conns(struct lnet_processid *id, u32 ipaddr);
 struct ksock_conn *ksocknal_find_conn_locked(struct ksock_peer_ni *peer_ni,
 					     struct ksock_tx *tx, int nonblk);
 
 int ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
-			   struct lnet_process_id id);
+			   struct lnet_processid *id);
 struct ksock_tx *ksocknal_alloc_tx(int type, int size);
 void ksocknal_free_tx(struct ksock_tx *tx);
 struct ksock_tx *ksocknal_alloc_tx_noop(u64 cookie, int nonblk);
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index e6cd976..a2298275 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -542,7 +542,7 @@ struct ksock_tx *
 			break;
 		}
 		CDEBUG(D_NET, "[%p] Error %d on write to %s ip %pISp\n",
-		       conn, rc, libcfs_id2str(conn->ksnc_peer->ksnp_id),
+		       conn, rc, libcfs_idstr(&conn->ksnc_peer->ksnp_id),
 		       &conn->ksnc_peeraddr);
 	}
 
@@ -677,7 +677,7 @@ struct ksock_conn *
 	LASSERT(!conn->ksnc_closing);
 
 	CDEBUG(D_NET, "Sending to %s ip %pISp\n",
-	       libcfs_id2str(conn->ksnc_peer->ksnp_id),
+	       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
 	       &conn->ksnc_peeraddr);
 
 	ksocknal_tx_prep(conn, tx);
@@ -804,10 +804,11 @@ struct ksock_conn_cb *
 
 int
 ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
-		       struct lnet_process_id id)
+		       struct lnet_processid *id)
 {
 	struct ksock_peer_ni *peer_ni;
 	struct ksock_conn *conn;
+	struct sockaddr_in sa;
 	rwlock_t *g_lock;
 	int retry;
 	int rc;
@@ -846,23 +847,31 @@ struct ksock_conn_cb *
 
 		write_unlock_bh(g_lock);
 
-		if (id.pid & LNET_PID_USERFLAG) {
+		if (id->pid & LNET_PID_USERFLAG) {
 			CERROR("Refusing to create a connection to userspace process %s\n",
-			       libcfs_id2str(id));
+			       libcfs_idstr(id));
 			return -EHOSTUNREACH;
 		}
 
 		if (retry) {
-			CERROR("Can't find peer_ni %s\n", libcfs_id2str(id));
+			CERROR("Can't find peer_ni %s\n", libcfs_idstr(id));
 			return -EHOSTUNREACH;
 		}
 
-		rc = ksocknal_add_peer(ni, id,
-				       LNET_NIDADDR(id.nid),
-				       lnet_acceptor_port());
+		memset(&sa, 0, sizeof(sa));
+		sa.sin_family = AF_INET;
+		sa.sin_addr.s_addr = id->nid.nid_addr[0];
+		sa.sin_port = htons(lnet_acceptor_port());
+		{
+			struct lnet_process_id id4 = {
+				.pid = id->pid,
+				.nid = lnet_nid_to_nid4(&id->nid),
+			};
+			rc = ksocknal_add_peer(ni, id4, (struct sockaddr *)&sa);
+		}
 		if (rc) {
 			CERROR("Can't add peer_ni %s: %d\n",
-			       libcfs_id2str(id), rc);
+			       libcfs_idstr(id), rc);
 			return rc;
 		}
 	}
@@ -892,7 +901,7 @@ struct ksock_conn_cb *
 	write_unlock_bh(g_lock);
 
 	/* NB Routes may be ignored if connections to them failed recently */
-	CNETERR("No usable routes to %s\n", libcfs_id2str(id));
+	CNETERR("No usable routes to %s\n", libcfs_idstr(id));
 	tx->tx_hstatus = LNET_MSG_STATUS_REMOTE_ERROR;
 	return -EHOSTUNREACH;
 }
@@ -902,7 +911,7 @@ struct ksock_conn_cb *
 {
 	unsigned int mpflag = 0;
 	int type = lntmsg->msg_type;
-	struct lnet_process_id target = lntmsg->msg_target;
+	struct lnet_processid target;
 	unsigned int payload_niov = lntmsg->msg_niov;
 	struct bio_vec *payload_kiov = lntmsg->msg_kiov;
 	unsigned int payload_offset = lntmsg->msg_offset;
@@ -911,12 +920,14 @@ struct ksock_conn_cb *
 	int desc_size;
 	int rc;
 
-	/*
-	 * NB 'private' is different depending on what we're sending.
+	/* NB 'private' is different depending on what we're sending.
 	 * Just ignore it...
 	 */
+	target.pid = lntmsg->msg_target.pid;
+	lnet_nid4_to_nid(lntmsg->msg_target.nid, &target.nid);
+
 	CDEBUG(D_NET, "sending %u bytes in %d frags to %s\n",
-	       payload_nob, payload_niov, libcfs_id2str(target));
+	       payload_nob, payload_niov, libcfs_idstr(&target));
 
 	LASSERT(!payload_nob || payload_niov > 0);
 	LASSERT(payload_niov <= LNET_MAX_IOV);
@@ -954,7 +965,7 @@ struct ksock_conn_cb *
 	tx->tx_msg.ksm_zc_cookies[1] = 0;
 
 	/* The first fragment will be set later in pro_pack */
-	rc = ksocknal_launch_packet(ni, tx, target);
+	rc = ksocknal_launch_packet(ni, tx, &target);
 	if (mpflag)
 		memalloc_noreclaim_restore(mpflag);
 
@@ -1051,7 +1062,7 @@ struct ksock_conn_cb *
 {
 	struct kvec *kvec = conn->ksnc_rx_iov_space;
 	struct lnet_hdr *lhdr;
-	struct lnet_process_id *id;
+	struct lnet_processid *id;
 	int rc;
 
 	LASSERT(refcount_read(&conn->ksnc_conn_refcount) > 0);
@@ -1067,19 +1078,19 @@ struct ksock_conn_cb *
 		rc = ksocknal_receive(conn);
 
 		if (rc <= 0) {
-			struct lnet_process_id ksnp_id;
+			struct lnet_processid *ksnp_id;
 
-			ksnp_id = conn->ksnc_peer->ksnp_id;
+			ksnp_id = &conn->ksnc_peer->ksnp_id;
 
 			LASSERT(rc != -EAGAIN);
 
 			if (!rc)
 				CDEBUG(D_NET, "[%p] EOF from %s ip %pISp\n",
-				       conn, libcfs_id2str(ksnp_id),
+				       conn, libcfs_idstr(ksnp_id),
 				       &conn->ksnc_peeraddr);
 			else if (!conn->ksnc_closing)
 				CERROR("[%p] Error %d on read from %s ip %pISp\n",
-				       conn, rc, libcfs_id2str(ksnp_id),
+				       conn, rc, libcfs_idstr(ksnp_id),
 				       &conn->ksnc_peeraddr);
 
 			/* it's not an error if conn is being closed */
@@ -1105,7 +1116,7 @@ struct ksock_conn_cb *
 		if (conn->ksnc_msg.ksm_type != KSOCK_MSG_NOOP &&
 		    conn->ksnc_msg.ksm_type != KSOCK_MSG_LNET) {
 			CERROR("%s: Unknown message type: %x\n",
-			       libcfs_id2str(conn->ksnc_peer->ksnp_id),
+			       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
 			       conn->ksnc_msg.ksm_type);
 			ksocknal_new_packet(conn, 0);
 			ksocknal_close_conn_and_siblings(conn, -EPROTO);
@@ -1117,7 +1128,7 @@ struct ksock_conn_cb *
 		    conn->ksnc_msg.ksm_csum != conn->ksnc_rx_csum) {
 			/* NOOP Checksum error */
 			CERROR("%s: Checksum error, wire:0x%08X data:0x%08X\n",
-			       libcfs_id2str(conn->ksnc_peer->ksnp_id),
+			       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
 			       conn->ksnc_msg.ksm_csum, conn->ksnc_rx_csum);
 			ksocknal_new_packet(conn, 0);
 			ksocknal_close_conn_and_siblings(conn, -EPROTO);
@@ -1133,12 +1144,12 @@ struct ksock_conn_cb *
 				cookie = conn->ksnc_msg.ksm_zc_cookies[0];
 
 			rc = conn->ksnc_proto->pro_handle_zcack(conn, cookie,
-					       conn->ksnc_msg.ksm_zc_cookies[1]);
-
+								conn->ksnc_msg.ksm_zc_cookies[1]);
 			if (rc) {
 				CERROR("%s: Unknown ZC-ACK cookie: %llu, %llu\n",
-				       libcfs_id2str(conn->ksnc_peer->ksnp_id),
-				       cookie, conn->ksnc_msg.ksm_zc_cookies[1]);
+				       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
+				       cookie,
+				       conn->ksnc_msg.ksm_zc_cookies[1]);
 				ksocknal_new_packet(conn, 0);
 				ksocknal_close_conn_and_siblings(conn, -EPROTO);
 				return rc;
@@ -1172,7 +1183,7 @@ struct ksock_conn_cb *
 
 			/* Substitute process ID assigned at connection time */
 			lhdr->src_pid = cpu_to_le32(id->pid);
-			lhdr->src_nid = cpu_to_le64(id->nid);
+			lhdr->src_nid = cpu_to_le64(lnet_nid_to_nid4(&id->nid));
 		}
 
 		conn->ksnc_rx_state = SOCKNAL_RX_PARSE;
@@ -1180,7 +1191,8 @@ struct ksock_conn_cb *
 
 		rc = lnet_parse(conn->ksnc_peer->ksnp_ni,
 				&conn->ksnc_msg.ksm_u.lnetmsg.ksnm_hdr,
-				conn->ksnc_peer->ksnp_id.nid, conn, 0);
+				lnet_nid_to_nid4(&conn->ksnc_peer->ksnp_id.nid),
+				conn, 0);
 		if (rc < 0) {
 			/* I just received garbage: give up on this conn */
 			ksocknal_new_packet(conn, 0);
@@ -1207,7 +1219,7 @@ struct ksock_conn_cb *
 		    conn->ksnc_msg.ksm_csum &&  /* has checksum */
 		    conn->ksnc_msg.ksm_csum != conn->ksnc_rx_csum) {
 			CERROR("%s: Checksum error, wire:0x%08X data:0x%08X\n",
-			       libcfs_id2str(conn->ksnc_peer->ksnp_id),
+			       libcfs_idstr(&conn->ksnc_peer->ksnp_id),
 			       conn->ksnc_msg.ksm_csum, conn->ksnc_rx_csum);
 			rc = -EIO;
 		}
@@ -1219,9 +1231,10 @@ struct ksock_conn_cb *
 			id = &conn->ksnc_peer->ksnp_id;
 
 			rc = conn->ksnc_proto->pro_handle_zcreq(conn,
-					conn->ksnc_msg.ksm_zc_cookies[0],
-					*ksocknal_tunables.ksnd_nonblk_zcack ||
-					le64_to_cpu(lhdr->src_nid) != id->nid);
+								conn->ksnc_msg.ksm_zc_cookies[0],
+								*ksocknal_tunables.ksnd_nonblk_zcack ||
+								le64_to_cpu(lhdr->src_nid) !=
+								lnet_nid_to_nid4(&id->nid));
 		}
 
 		if (rc && conn->ksnc_lnet_msg)
@@ -1796,7 +1809,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		if (peer_ni->ksnp_accepting > 0) {
 			CDEBUG(D_NET,
 			       "peer_ni %s(%d) already connecting to me, retry later.\n",
-			       libcfs_nid2str(peer_ni->ksnp_id.nid),
+			       libcfs_nidstr(&peer_ni->ksnp_id.nid),
 			       peer_ni->ksnp_accepting);
 			retry_later = true;
 		}
@@ -1820,13 +1833,13 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 		if (ktime_get_seconds() >= deadline) {
 			rc = -ETIMEDOUT;
-			lnet_connect_console_error(rc, peer_ni->ksnp_id.nid,
-						   (struct sockaddr *)
-						   &conn_cb->ksnr_addr);
+			lnet_connect_console_error(rc,
+						   lnet_nid_to_nid4(&peer_ni->ksnp_id.nid),
+						   (struct sockaddr *)&conn_cb->ksnr_addr);
 			goto failed;
 		}
 
-		sock = lnet_connect(peer_ni->ksnp_id.nid,
+		sock = lnet_connect(lnet_nid_to_nid4(&peer_ni->ksnp_id.nid),
 				    conn_cb->ksnr_myiface,
 				    (struct sockaddr *)&conn_cb->ksnr_addr,
 				    peer_ni->ksnp_ni->ni_net_ns);
@@ -1838,9 +1851,9 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		rc = ksocknal_create_conn(peer_ni->ksnp_ni, conn_cb, sock,
 					  type);
 		if (rc < 0) {
-			lnet_connect_console_error(rc, peer_ni->ksnp_id.nid,
-						   (struct sockaddr *)
-						   &conn_cb->ksnr_addr);
+			lnet_connect_console_error(rc,
+						   lnet_nid_to_nid4(&peer_ni->ksnp_id.nid),
+						   (struct sockaddr *)&conn_cb->ksnr_addr);
 			goto failed;
 		}
 
@@ -1851,7 +1864,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		retry_later = (rc);
 		if (retry_later)
 			CDEBUG(D_NET, "peer_ni %s: conn race, retry later.\n",
-			       libcfs_nid2str(peer_ni->ksnp_id.nid));
+			       libcfs_nidstr(&peer_ni->ksnp_id.nid));
 
 		write_lock_bh(&ksocknal_data.ksnd_global_lock);
 	}
@@ -2191,18 +2204,18 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			switch (error) {
 			case ECONNRESET:
 				CNETERR("A connection with %s (%pISp) was reset; it may have rebooted.\n",
-					libcfs_id2str(peer_ni->ksnp_id),
+					libcfs_idstr(&peer_ni->ksnp_id),
 					&conn->ksnc_peeraddr);
 				break;
 			case ETIMEDOUT:
 				CNETERR("A connection with %s (%pISp) timed out; the network or node may be down.\n",
-					libcfs_id2str(peer_ni->ksnp_id),
+					libcfs_idstr(&peer_ni->ksnp_id),
 					&conn->ksnc_peeraddr);
 				break;
 			default:
 				CNETERR("An unexpected network error %d occurred with %s (%pISp\n",
 					error,
-					libcfs_id2str(peer_ni->ksnp_id),
+					libcfs_idstr(&peer_ni->ksnp_id),
 					&conn->ksnc_peeraddr);
 				break;
 			}
@@ -2215,7 +2228,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			/* Timed out incomplete incoming message */
 			ksocknal_conn_addref(conn);
 			CNETERR("Timeout receiving from %s (%pISp), state %d wanted %zd left %d\n",
-				libcfs_id2str(peer_ni->ksnp_id),
+				libcfs_idstr(&peer_ni->ksnp_id),
 				&conn->ksnc_peeraddr,
 				conn->ksnc_rx_state,
 				iov_iter_count(&conn->ksnc_rx_to),
@@ -2236,7 +2249,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 				tx->tx_hstatus =
 					LNET_MSG_STATUS_LOCAL_TIMEOUT;
 			CNETERR("Timeout sending data to %s (%pISp) the network or that node may be down.\n",
-				libcfs_id2str(peer_ni->ksnp_id),
+				libcfs_idstr(&peer_ni->ksnp_id),
 				&conn->ksnc_peeraddr);
 			return conn;
 		}
@@ -2322,7 +2335,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		return -ENOMEM;
 	}
 
-	if (!ksocknal_launch_packet(peer_ni->ksnp_ni, tx, peer_ni->ksnp_id)) {
+	if (!ksocknal_launch_packet(peer_ni->ksnp_ni, tx, &peer_ni->ksnp_id)) {
 		read_lock(&ksocknal_data.ksnd_global_lock);
 		return 1;
 	}
@@ -2423,7 +2436,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		read_unlock(&ksocknal_data.ksnd_global_lock);
 
 		CERROR("Total %d stale ZC_REQs for peer_ni %s detected; the oldest(%p) timed out %lld secs ago, resid: %d, wmem: %d\n",
-		       n, libcfs_nid2str(peer_ni->ksnp_id.nid), tx_stale,
+		       n, libcfs_nidstr(&peer_ni->ksnp_id.nid), tx_stale,
 		       ktime_get_seconds() - deadline,
 		       resid, conn->ksnc_sock->sk->sk_wmem_queued);
 
diff --git a/net/lnet/klnds/socklnd/socklnd_proto.c b/net/lnet/klnds/socklnd/socklnd_proto.c
index 0a6072b..c3ba070 100644
--- a/net/lnet/klnds/socklnd/socklnd_proto.c
+++ b/net/lnet/klnds/socklnd/socklnd_proto.c
@@ -189,7 +189,7 @@
 	if (cookie == tx->tx_msg.ksm_zc_cookies[0] ||
 	    cookie == tx->tx_msg.ksm_zc_cookies[1]) {
 		CWARN("%s: duplicated ZC cookie: %llu\n",
-		      libcfs_id2str(conn->ksnc_peer->ksnp_id), cookie);
+		      libcfs_idstr(&conn->ksnc_peer->ksnp_id), cookie);
 		return 1; /* XXX return error in the future */
 	}
 
@@ -243,14 +243,14 @@
 		}
 
 	} else {
-		/*
-		 * ksm_zc_cookies[0] < ksm_zc_cookies[1],
-		 * it is range of cookies
+		/* ksm_zc_cookies[0] < ksm_zc_cookies[1], it is range
+		 * of cookies
 		 */
 		if (cookie >= tx->tx_msg.ksm_zc_cookies[0] &&
 		    cookie <= tx->tx_msg.ksm_zc_cookies[1]) {
 			CWARN("%s: duplicated ZC cookie: %llu\n",
-			      libcfs_id2str(conn->ksnc_peer->ksnp_id), cookie);
+			      libcfs_idstr(&conn->ksnc_peer->ksnp_id),
+			      cookie);
 			return 1; /* XXX: return error in the future */
 		}
 
@@ -398,8 +398,8 @@
 	if (!tx)
 		return -ENOMEM;
 
-	rc = ksocknal_launch_packet(peer_ni->ksnp_ni, tx, peer_ni->ksnp_id);
-	if (!rc)
+	rc = ksocknal_launch_packet(peer_ni->ksnp_ni, tx, &peer_ni->ksnp_id);
+	if (rc == 0)
 		return 0;
 
 	ksocknal_free_tx(tx);
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index f5b022f..1f053b3 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1509,22 +1509,35 @@ struct lnet_net *
 }
 
 int
-lnet_cpt_of_nid(lnet_nid_t nid4, struct lnet_ni *ni)
+lnet_nid2cpt(struct lnet_nid *nid, struct lnet_ni *ni)
 {
 	int cpt;
 	int cpt2;
-	struct lnet_nid nid;
 
 	if (LNET_CPT_NUMBER == 1)
 		return 0; /* the only one */
 
-	lnet_nid4_to_nid(nid4, &nid);
 	cpt = lnet_net_lock_current();
-	cpt2 = lnet_cpt_of_nid_locked(&nid, ni);
+
+	cpt2 = lnet_cpt_of_nid_locked(nid, ni);
+
 	lnet_net_unlock(cpt);
 
 	return cpt2;
 }
+EXPORT_SYMBOL(lnet_nid2cpt);
+
+int
+lnet_cpt_of_nid(lnet_nid_t nid4, struct lnet_ni *ni)
+{
+	struct lnet_nid nid;
+
+	if (LNET_CPT_NUMBER == 1)
+		return 0; /* the only one */
+
+	lnet_nid4_to_nid(nid4, &nid);
+	return lnet_nid2cpt(&nid, ni);
+}
 EXPORT_SYMBOL(lnet_cpt_of_nid);
 
 int
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index 08f828b..d91815d 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -1139,6 +1139,24 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 }
 EXPORT_SYMBOL(libcfs_id2str);
 
+char *
+libcfs_idstr(struct lnet_processid *id)
+{
+	char *str = libcfs_next_nidstring();
+
+	if (id->pid == LNET_PID_ANY) {
+		snprintf(str, LNET_NIDSTR_SIZE,
+			 "LNET_PID_ANY-%s", libcfs_nidstr(&id->nid));
+		return str;
+	}
+
+	snprintf(str, LNET_NIDSTR_SIZE, "%s%u-%s",
+		 ((id->pid & LNET_PID_USERFLAG) != 0) ? "U" : "",
+		 (id->pid & ~LNET_PID_USERFLAG), libcfs_nidstr(&id->nid));
+	return str;
+}
+EXPORT_SYMBOL(libcfs_idstr);
+
 int
 libcfs_str2anynid(lnet_nid_t *nidp, const char *str)
 {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
