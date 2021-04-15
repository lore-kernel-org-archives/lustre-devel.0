Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DA24C433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:33 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E6FC560230
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6FC560230
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D01FF32F63B;
	Wed, 14 Apr 2021 21:03:15 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3027432F494
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:51 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6EDB2100F350;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6DE3191883; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:07 -0400
Message-Id: <1618459361-17909-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/49] lnet: o2iblnd: change some ints to
 bool.
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

Each of these ints can suitably be bool.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 86e192059905ac49 ("LU-12678 o2iblnd: change some ints to bool.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39304
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c    |  8 ++++----
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 26 +++++++++++++-------------
 2 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index c8cebf6..01cc1ed 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -127,7 +127,7 @@ static int kiblnd_msgtype2size(int type)
 	}
 }
 
-static int kiblnd_unpack_rd(struct kib_msg *msg, int flip)
+static int kiblnd_unpack_rd(struct kib_msg *msg, bool flip)
 {
 	struct kib_rdma_desc *rd;
 	int nob;
@@ -206,7 +206,7 @@ int kiblnd_unpack_msg(struct kib_msg *msg, int nob)
 	u32 msg_cksum;
 	u16 version;
 	int msg_nob;
-	int flip;
+	bool flip;
 
 	/* 6 bytes are enough to have received magic + version */
 	if (nob < 6) {
@@ -215,9 +215,9 @@ int kiblnd_unpack_msg(struct kib_msg *msg, int nob)
 	}
 
 	if (msg->ibm_magic == IBLND_MSG_MAGIC) {
-		flip = 0;
+		flip = false;
 	} else if (msg->ibm_magic == __swab32(IBLND_MSG_MAGIC)) {
-		flip = 1;
+		flip = true;
 	} else {
 		CERROR("Bad magic: %08x\n", msg->ibm_magic);
 		return -EPROTO;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 2ebda4e..5066c93 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2758,7 +2758,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		if (priv_nob >= offsetof(struct kib_rej, ibr_padding)) {
 			struct kib_rej *rej = priv;
 			struct kib_connparams *cp = NULL;
-			int flip = 0;
+			bool flip = false;
 			u64 incarnation = -1;
 
 			/* NB. default incarnation is -1 because:
@@ -2777,7 +2777,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			    rej->ibr_magic == __swab32(LNET_PROTO_MAGIC)) {
 				__swab32s(&rej->ibr_magic);
 				__swab16s(&rej->ibr_version);
-				flip = 1;
+				flip = true;
 			}
 
 			if (priv_nob >= sizeof(struct kib_rej) &&
@@ -3385,7 +3385,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	struct kib_conn *conn;
 	int timeout;
 	int i;
-	int dropped_lock;
+	bool dropped_lock;
 	int peer_index = 0;
 	unsigned long deadline = jiffies;
 
@@ -3397,7 +3397,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	while (!kiblnd_data.kib_shutdown) {
 		int reconn = 0;
 
-		dropped_lock = 0;
+		dropped_lock = false;
 
 		conn = list_first_entry_or_null(
 			&kiblnd_data.kib_connd_zombies,
@@ -3412,7 +3412,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			}
 
 			spin_unlock_irqrestore(lock, flags);
-			dropped_lock = 1;
+			dropped_lock = true;
 
 			kiblnd_destroy_conn(conn);
 
@@ -3439,7 +3439,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			list_del(&conn->ibc_list);
 
 			spin_unlock_irqrestore(lock, flags);
-			dropped_lock = 1;
+			dropped_lock = true;
 
 			kiblnd_disconnect_conn(conn);
 			wait = conn->ibc_waits;
@@ -3469,7 +3469,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			list_del(&conn->ibc_list);
 
 			spin_unlock_irqrestore(lock, flags);
-			dropped_lock = 1;
+			dropped_lock = true;
 
 			reconn += kiblnd_reconnect_peer(conn->ibc_peer);
 			kiblnd_peer_decref(conn->ibc_peer);
@@ -3503,7 +3503,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			unsigned int lnd_timeout;
 
 			spin_unlock_irqrestore(lock, flags);
-			dropped_lock = 1;
+			dropped_lock = true;
 
 			/*
 			 * Time to check for RDMA timeouts on a few more
@@ -3677,7 +3677,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	wait_queue_entry_t wait;
 	unsigned long flags;
 	struct ib_wc wc;
-	int did_something;
+	bool did_something;
 	int rc;
 
 	init_wait(&wait);
@@ -3701,7 +3701,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			spin_lock_irqsave(&sched->ibs_lock, flags);
 		}
 
-		did_something = 0;
+		did_something = false;
 
 		conn = list_first_entry_or_null(&sched->ibs_conns,
 						struct kib_conn,
@@ -3778,7 +3778,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			}
 
 			kiblnd_conn_decref(conn); /* ...drop my ref from above */
-			did_something = 1;
+			did_something = true;
 		}
 
 		if (did_something)
@@ -3816,14 +3816,14 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	write_lock_irqsave(glock, flags);
 
 	while (!kiblnd_data.kib_shutdown) {
-		int do_failover = 0;
+		bool do_failover = false;
 		int long_sleep;
 
 		list_for_each_entry(dev, &kiblnd_data.kib_failed_devs,
 				    ibd_fail_list) {
 			if (ktime_get_seconds() < dev->ibd_next_failover)
 				continue;
-			do_failover = 1;
+			do_failover = true;
 			break;
 		}
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
