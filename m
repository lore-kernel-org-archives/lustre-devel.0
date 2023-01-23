Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6B6A4C25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:32:45 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15R05Njqz1wfR;
	Mon, 23 Jan 2023 15:09:48 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15Pg3mfJz22T8
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:08:39 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A1993E02;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9E28358991; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:47 -0500
Message-Id: <1674514855-15399-35-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 34/42] lnet: o2iblnd: reset hiw proportionally
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

As a result of connection negotiation, queue depth may end up
being shorter than "peer_tx_credits" tunables value. Before this
patch, the high-water mark "lnd_peercredits_hiw" would be set at
    min(current hiw, queue depth - 1).

For example, considering that hiw is allowed to only be as low as
half of peer_tx_credits, negotiating queue_depth/peer_credits down
from 32 to 8 would always result in hiw set at 7, i.e. credits would
be released as late as possible.

With this patch, if queue depth is reduced, hiw is set proportionally
relative to the level it was at before:
    hiw = (queue_depth * lnd_peercredits_hiw) / peer_tx_credits

Using the above example with queue depth initially at 32, negotiating
down to 8 would result in hiw set to 4 if "lnd_peercredits_hiw" is
initially at 16, 17, 18, 19; hiw set to 5 if "lnd_peercredits_hiw" is
initially at 20, 21, 22, 23, and so on.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15828
Lustre-commit: e1944c29793d48942 ("LU-15828 o2iblnd: reset hiw proportionally")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49497
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.h | 30 ++++++++++++++++++++++--------
 1 file changed, 22 insertions(+), 8 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index e3c069bd1a7f..5884cda7a707 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -114,13 +114,6 @@ extern struct kib_tunables  kiblnd_tunables;
 /* Max # of peer_ni credits */
 #define IBLND_CREDITS_MAX	  ((typeof(((struct kib_msg *)0)->ibm_credits)) - 1)
 
-/* when eagerly to return credits */
-#define IBLND_CREDITS_HIGHWATER(t, conn)			\
-	(((conn)->ibc_version) == IBLND_MSG_VERSION_1 ?		\
-	 IBLND_CREDIT_HIGHWATER_V1 :				\
-	 min((t)->lnd_peercredits_hiw,				\
-	     (u32)(conn)->ibc_queue_depth - 1))
-
 # define kiblnd_rdma_create_id(ns, cb, dev, ps, qpt) \
 	 rdma_create_id((ns) ? (ns) : &init_net, cb, dev, ps, qpt)
 
@@ -699,17 +692,38 @@ kiblnd_send_keepalive(struct kib_conn *conn)
 			    ktime_add_ns(conn->ibc_last_send, keepalive_ns));
 }
 
+/* when to return credits eagerly */
+static inline int
+kiblnd_credits_highwater(struct lnet_ioctl_config_o2iblnd_tunables *t,
+			 struct lnet_ioctl_config_lnd_cmn_tunables *nt,
+			 struct kib_conn *conn)
+{
+	int credits_hiw = IBLND_CREDIT_HIGHWATER_V1;
+
+	if (conn->ibc_version == IBLND_MSG_VERSION_1)
+		return credits_hiw;
+
+	/* if queue depth is negotiated down, calculate hiw proportionally */
+	credits_hiw = (conn->ibc_queue_depth * t->lnd_peercredits_hiw) /
+		       nt->lct_peer_tx_credits;
+
+	return credits_hiw;
+}
+
 static inline int
 kiblnd_need_noop(struct kib_conn *conn)
 {
 	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
 	struct lnet_ni *ni = conn->ibc_peer->ibp_ni;
+	struct lnet_ioctl_config_lnd_cmn_tunables *net_tunables;
 
 	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
 	tunables = &ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
+	net_tunables = &ni->ni_net->net_tunables;
+
 
 	if (conn->ibc_outstanding_credits <
-	    IBLND_CREDITS_HIGHWATER(tunables, conn) &&
+	    kiblnd_credits_highwater(tunables, net_tunables, conn) &&
 	    !kiblnd_send_keepalive(conn))
 		return 0; /* No need to send NOOP */
 
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
