Return-Path: <SRS0=HxeM=ML=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51584C07E9D
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:33:04 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EEF4C6113B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:33:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEF4C6113B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B1B7034FADC;
	Mon, 19 Jul 2021 05:32:40 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1D4D334F976
 for <lustre-devel@lists.lustre.org>; Mon, 19 Jul 2021 05:32:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B16976D6;
 Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A898FBD1CD; Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 19 Jul 2021 08:32:08 -0400
Message-Id: <1626697933-6971-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
References: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/18] lnet: o2iblnd: Avoid double posting
 invalidate
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
Cc: Mike Marciniszyn <mike.marciniszyn@cornelisnetworks.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mike Marciniszyn <mike.marciniszyn@cornelisnetworks.com>

When the kib_tx is provisioned during kiblnd_fmr_pool_map(), spare
WRs in the kib_fast_reg_descriptor are setup and the mapping of
pages is given to the mr.

kiblnd_post_tx_locked() then posts the spare WRs from the
kib_fast_reg_descriptor.

if (rc == 0)
        return 0;

The code returns and the kib_fast_reg_descriptor is still contains
the spare WRs.   The next time the kib_tx is used, the
now obsolete WRs will be inadvertently posted.   For rdmavt, the
obsolete invalidate will cause an -EINVAL to be returned from
the post send.

Fix by adding a state variable frd_posted to the kib_fast_reg_descriptor.
The variable is set to false in kiblnd_fmr_pool_unmap().
kiblnd_post_tx_locked() is adjusted to avoid prepending the
kib_fast_reg_descriptor WRs when frd_posted is true.   After
the post succeeds, the frd_posted is set to true.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14733
Lustre-commit: 5930576791e864529 ("LU-14733 o2iblnd: Avoid double posting invalidate")
Signed-off-by: Mike Marciniszyn <mike.marciniszyn@cornelisnetworks.com>
Reviewed-on: https://review.whamcloud.com/44190
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c    |  2 ++
 net/lnet/klnds/o2iblnd/o2iblnd.h    |  1 +
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 12 +++++++-----
 3 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 81d9e4d..b519a31 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1539,6 +1539,7 @@ void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status)
 	fps = fpo->fpo_owner;
 	if (frd) {
 		frd->frd_valid = false;
+		frd->frd_posted = false;
 		fmr->fmr_frd = NULL;
 		spin_lock(&fps->fps_lock);
 		list_add_tail(&frd->frd_list, &fpo->fast_reg.fpo_pool_list);
@@ -1634,6 +1635,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 			fmr->fmr_key = is_rx ? mr->rkey : mr->lkey;
 			fmr->fmr_frd = frd;
 			fmr->fmr_pool = fpo;
+			frd->frd_posted = false;
 			return 0;
 		}
 
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 824b204..8d1d7eb 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -272,6 +272,7 @@ struct kib_fast_reg_descriptor { /* For fast registration */
 	struct ib_reg_wr	frd_fastreg_wr;
 	struct ib_mr	       *frd_mr;
 	bool			frd_valid;
+	bool			frd_posted;
 };
 
 struct kib_fmr_pool {
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index c66acc51..32ccac2 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -721,6 +721,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	struct kib_msg *msg = tx->tx_msg;
 	struct kib_peer_ni *peer_ni = conn->ibc_peer;
 	struct lnet_ni *ni = peer_ni->ibp_ni;
+	struct kib_fast_reg_descriptor *frd = tx->tx_fmr.fmr_frd;
 	int ver = conn->ibc_version;
 	int rc;
 	int done;
@@ -809,11 +810,10 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		/* close_conn will launch failover */
 		rc = -ENETDOWN;
 	} else {
-		struct kib_fast_reg_descriptor *frd = tx->tx_fmr.fmr_frd;
 		const struct ib_send_wr *bad = &tx->tx_wrq[tx->tx_nwrq - 1].wr;
 		struct ib_send_wr *wrq = &tx->tx_wrq[0].wr;
 
-		if (frd) {
+		if (frd && !frd->frd_posted) {
 			if (!frd->frd_valid) {
 				wrq = &frd->frd_inv_wr;
 				wrq->next = &frd->frd_fastreg_wr.wr;
@@ -837,11 +837,13 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 	conn->ibc_last_send = ktime_get();
 
-	if (!rc)
+	if (rc == 0) {
+		if (frd)
+			frd->frd_posted = true;
 		return 0;
+	}
 
-	/*
-	 * NB credits are transferred in the actual
+	/* NB credits are transferred in the actual
 	 * message, which can only be the last work item
 	 */
 	conn->ibc_credits += credit;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
