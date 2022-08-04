Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DB105C19F2D
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:40:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyryf3r2jz23KM;
	Wed,  3 Aug 2022 18:40:26 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Lyrwk488wz23J7
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:46 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 028AD100B054;
 Wed,  3 Aug 2022 21:38:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F3A9B82CCE; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:13 -0400
Message-Id: <1659577097-19253-29-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 28/32] lnet: Adjust niov checks for large MD
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

An LNet user can allocate a large contiguous MD. That MD can have >
LNET_MAX_IOV pages which causes some LNDs to assert on either niov
argument passed to lnd_recv() or the value stored in
lnet_msg::msg_niov. This is true even in cases where the actual
transfer size is <= LNET_MTU and will not exceed limits in the LNDs.

Adjust ksocklnd_send()/ksocklnd_recv() to assert on the return value
of lnet_extract_kiov().

Remove the assert on msg_niov (payload_niov) from kiblnd_send().
kiblnd_setup_rd_kiov() will already fail if we exceed ko2iblnd's
available scatter gather entries.

HPE-bug-id: LUS-10878
Fixes: 05cd1717bb ("lnet: always put a page list into struct lnet_libmd")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15851
Lustre-commit: 105193b4a147257a0 ("LU-15851 lnet: Adjust niov checks for large MD")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/47319
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 1 -
 net/lnet/klnds/socklnd/socklnd_cb.c | 5 +++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index d4d8954..30e77c0 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1564,7 +1564,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	       payload_nob, payload_niov, libcfs_idstr(target));
 
 	LASSERT(!payload_nob || payload_niov > 0);
-	LASSERT(payload_niov <= LNET_MAX_IOV);
 
 	/* Thread context */
 	LASSERT(!in_interrupt());
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 94600f3..308d8b0 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -936,7 +936,6 @@ struct ksock_conn_cb *
 	       payload_nob, payload_niov, libcfs_idstr(target));
 
 	LASSERT(!payload_nob || payload_niov > 0);
-	LASSERT(payload_niov <= LNET_MAX_IOV);
 	LASSERT(!in_interrupt());
 
 	desc_size = offsetof(struct ksock_tx,
@@ -962,6 +961,8 @@ struct ksock_conn_cb *
 					 payload_niov, payload_kiov,
 					 payload_offset, payload_nob);
 
+	LASSERT(tx->tx_nkiov <= LNET_MAX_IOV);
+
 	if (payload_nob >= *ksocknal_tunables.ksnd_zc_min_payload)
 		tx->tx_zc_capable = 1;
 
@@ -1278,13 +1279,13 @@ struct ksock_conn_cb *
 	struct ksock_sched *sched = conn->ksnc_scheduler;
 
 	LASSERT(iov_iter_count(to) <= rlen);
-	LASSERT(to->nr_segs <= LNET_MAX_IOV);
 
 	conn->ksnc_lnet_msg = msg;
 	conn->ksnc_rx_nob_left = rlen;
 
 	conn->ksnc_rx_to = *to;
 
+	LASSERT(conn->ksnc_rx_to.nr_segs <= LNET_MAX_IOV);
 	LASSERT(conn->ksnc_rx_scheduled);
 
 	spin_lock_bh(&sched->kss_lock);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
