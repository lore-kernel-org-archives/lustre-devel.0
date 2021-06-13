Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13F29C48BE8
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:27 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CDC21611CA
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDC21611CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E27CF21F5F6;
	Sun, 13 Jun 2021 16:12:07 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 241C621E06F
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:44 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C5FCA100B054;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C49809C308; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:22 -0400
Message-Id: <1623625897-17706-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/27] lustre: obd: check if sbi->ll_md_exp
 is initialized
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
Cc: Artem Blagodarenko <artem.blagodarenko@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Artem Blagodarenko <artem.blagodarenko@hpe.com>

Null reference at the start of obd_statfs() function is possible
because of ll_fill_super vs lctl race.

ll_md_exp is initialized in ll_fill_super()->
client_common_fill_super(), but if mount process stucks
in lustre_process_log() it doesn't reach client_common_fill_super().

HPE-bug-id: LUS-9150
WC-bug-id: https://jira.whamcloud.com/browse/LU-13942
Lustre-commit: 1de8c3739d6bac76b ("LU-13942 obd: check if sbi->ll_md_exp is initialized")
Signed-off-by: Artem Blagodarenko <artem.blagodarenko@hpe.com>
Reviewed-on: https://es-gerrit.dev.cray.com/157732
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Tested-by: Alexander Lezhoev <c17454@cray.com>
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/39812
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 5cbed01..4cc5a7df 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -921,12 +921,13 @@ static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
 			     struct obd_statfs *osfs, time64_t max_age,
 			     u32 flags)
 {
-	struct obd_device *obd = exp->exp_obd;
+	struct obd_device *obd;
 	int rc = 0;
 
-	if (unlikely(!obd))
+	if (unlikely(!exp) || !exp->exp_obd)
 		return -EINVAL;
 
+	obd = exp->exp_obd;
 	rc = obd_check_dev_active(obd);
 	if (rc)
 		return rc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
