Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26608C43462
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:50 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D9B2B613C0
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9B2B613C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EF76832F845;
	Wed, 14 Apr 2021 21:04:20 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D2BFA32F68F
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:57 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B69F0100F367;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B571C91884; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:30 -0400
Message-Id: <1618459361-17909-39-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 38/49] lustre: lmv: don't use lqr_alloc
 spinlock in lmv
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

The only place the lrq_alloc spinlock is used in lmv is in
lmv_locate_tgt_rr().  The purpose here is presumably to protect
lmv_qos_rr_index from concurrent updates.  This is a field that is
only tangentially related the the structure that holds the spinlock.

lmv_qos_rr_index is directly in 'struct lmv_obd' while lqr_alloc
is in struct lu_qos_rr which is in struct lu_qos, which is in lmv_obd.

As there is a spinlock in 'struct lmv_obd' (lmv_lock) it makes more
sense to use that to protect lmv_qos_rr_index.  Then the entire
lu_qos_rr structure will be unused on the client and can be made
server-only.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8837
Lustre-commit: 3e14a71d87efde0 ("U-8837 lmv: don't use lqr_alloc spinlock in lmv")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41949
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 9c0a0cf..6555c6e 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1493,7 +1493,7 @@ static struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt)
 	int i;
 	int index;
 
-	spin_lock(&lmv->lmv_qos.lq_rr.lqr_alloc);
+	spin_lock(&lmv->lmv_lock);
 	for (i = 0; i < lmv->lmv_mdt_descs.ltd_tgts_size; i++) {
 		index = (i + lmv->lmv_qos_rr_index) %
 			lmv->lmv_mdt_descs.ltd_tgts_size;
@@ -1504,11 +1504,11 @@ static struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt)
 		*mdt = tgt->ltd_index;
 		lmv->lmv_qos_rr_index = (*mdt + 1) %
 					lmv->lmv_mdt_descs.ltd_tgts_size;
-		spin_unlock(&lmv->lmv_qos.lq_rr.lqr_alloc);
+		spin_unlock(&lmv->lmv_lock);
 
 		return tgt;
 	}
-	spin_unlock(&lmv->lmv_qos.lq_rr.lqr_alloc);
+	spin_unlock(&lmv->lmv_lock);
 
 	return ERR_PTR(-ENODEV);
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
