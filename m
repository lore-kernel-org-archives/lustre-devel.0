Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C326EECAAA1
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:56:32 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7m03XTVz1yD4;
	Mon,  5 Sep 2022 18:56:32 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7l74RJnz1y76
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id BA210100B003;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B43D7589A2; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:22 -0400
Message-Id: <1662429337-18737-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/24] lnet: o2iblnd: Salt comp_vector
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
Cc: Ian Ziemba <ian.ziemba@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Ian Ziemba <ian.ziemba@hpe.com>

If conns_per_peer is greater than 1, all the connections targeting
the same peer are assigned the same comp_vector. This results in
multiple IB CQs targeting the same peer to be serialized on a single
comp_vector.

Help spread out the IB CQ work to multiple cores by salting
comp_vector based on number of connections.

1 client to 1 server LST 1M write results with 4 conns_per_peer and
RXE configured to spread out work based on comp_vector.

Before: 1377.92 MB/s
After: 3828.48 MB/s

HPE-bug-id: LUS-11043
WC-bug-id: https://jira.whamcloud.com/browse/LU-16078
Lustre-commit: 1ef1fa06b20c424f5 ("LU-16078 o2iblnd: Salt comp_vector")
Signed-off-by: Ian Ziemba <ian.ziemba@hpe.com>
Reviewed-on: https://review.whamcloud.com/48148
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 14 +++++++++++---
 net/lnet/klnds/o2iblnd/o2iblnd.h |  2 ++
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index ea28c65..c713528 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -338,6 +338,7 @@ int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer_ni **peerp,
 	peer_ni->ibp_queue_depth = ni->ni_net->net_tunables.lct_peer_tx_credits;
 	peer_ni->ibp_queue_depth_mod = 0;	/* try to use the default */
 	kref_init(&peer_ni->ibp_kref);
+	atomic_set(&peer_ni->ibp_nconns, 0);
 
 	INIT_HLIST_NODE(&peer_ni->ibp_list);
 	INIT_LIST_HEAD(&peer_ni->ibp_conns);
@@ -569,7 +570,7 @@ static int kiblnd_get_completion_vector(struct kib_conn *conn, int cpt)
 	int vectors;
 	int off;
 	int i;
-	lnet_nid_t nid = conn->ibc_peer->ibp_nid;
+	lnet_nid_t ibp_nid;
 
 	vectors = conn->ibc_cmid->device->num_comp_vectors;
 	if (vectors <= 1)
@@ -579,8 +580,13 @@ static int kiblnd_get_completion_vector(struct kib_conn *conn, int cpt)
 	if (!mask)
 		return 0;
 
-	/* hash NID to CPU id in this partition... */
-	off = do_div(nid, cpumask_weight(*mask));
+	/* hash NID to CPU id in this partition... when targeting a single peer
+	 * with multiple QPs, to engage more cores in CQ processing to a single
+	 * peer, use ibp_nconns to salt the value the comp_vector value
+	 */
+	ibp_nid = conn->ibc_peer->ibp_nid +
+		  atomic_read(&conn->ibc_peer->ibp_nconns);
+	off = do_div(ibp_nid, cpumask_weight(*mask));
 	for_each_cpu(i, *mask) {
 		if (!off--)
 			return i % vectors;
@@ -889,6 +895,7 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 	conn->ibc_state = state;
 
 	/* 1 more conn */
+	atomic_inc(&peer_ni->ibp_nconns);
 	atomic_inc(&net->ibn_nconns);
 	return conn;
 
@@ -954,6 +961,7 @@ void kiblnd_destroy_conn(struct kib_conn *conn)
 
 		kiblnd_peer_decref(peer_ni);
 		rdma_destroy_id(cmid);
+		atomic_dec(&peer_ni->ibp_nconns);
 		atomic_dec(&net->ibn_nconns);
 	}
 }
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 0066e85..56d486f 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -522,6 +522,8 @@ struct kib_peer_ni {
 	u16			ibp_queue_depth;
 	/* reduced value which allows conn to be created if max fails */
 	u16			ibp_queue_depth_mod;
+	/* Number of connections allocated. */
+	atomic_t		ibp_nconns;
 };
 
 extern struct kib_data kiblnd_data;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
