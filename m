Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BE0DC4338F
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:38 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5984D61360
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 5984D61360
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D062C21CB81;
	Sun, 22 Aug 2021 19:28:16 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5AD5A21CAB1
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 19:27:52 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 2F5E9100BAFB;
 Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 22869B6C95; Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 22 Aug 2021 22:27:39 -0400
Message-Id: <1629685666-4533-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
References: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/15] lustre: mgc: rework
 mgc_apply_recover_logs() for gcc10
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

From: Alex Zhuravlev <bzzz@whamcloud.com>

rework mgc_apply_recover_logs() to use a separate buffer of
appropriate size so that gcc10 doesn't complain:
mgc_request.c:1506:24: error: argument 4 may overlap destination
        object [-Werror=restrict]
 1506 |        pos += sprintf(obdname + pos, "-%s-%s", cname, inst);

WC-bug-id: https://jira.whamcloud.com/browse/LU-14093
Lustre-commit: d13d8158e816b7ac ("LU-14093 mgc: rework mgc_apply_recover_logs() for gcc10")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40484
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mgc/mgc_request.c | 24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 50044aa2..3955d1f 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -1093,7 +1093,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 	struct lustre_cfg *lcfg;
 	struct lustre_cfg_bufs bufs;
 	u64 prev_version = 0;
-	char *inst;
+	char inst[MTI_NAME_MAXLEN + 1];
 	char *buf;
 	int bufsz;
 	int pos;
@@ -1107,19 +1107,15 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 	/* get dynamic nids setting */
 	dynamic_nids = mgc->obd_dynamic_nids;
 
-	inst = kzalloc(PAGE_SIZE, GFP_KERNEL);
-	if (!inst)
-		return -ENOMEM;
-
-	pos = snprintf(inst, PAGE_SIZE, "%px", cfg->cfg_instance);
-	if (pos >= PAGE_SIZE) {
-		kfree(inst);
+	pos = snprintf(inst, sizeof(inst), "%px", cfg->cfg_instance);
+	if (pos >= sizeof(inst))
 		return -E2BIG;
-	}
 
-	++pos;
-	buf = inst + pos;
-	bufsz = PAGE_SIZE - pos;
+	buf = kzalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+	bufsz = PAGE_SIZE;
+	pos = 0;
 
 	while (datalen > 0) {
 		int entry_len = sizeof(*entry);
@@ -1204,7 +1200,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 				  is_ost ? "OST" : "MDT", entry->mne_index);
 
 		cname = is_ost ? "osc" : "mdc",
-			pos += sprintf(obdname + pos, "-%s-%s", cname, inst);
+		pos += snprintf(obdname + pos, bufsz, "-%s-%s", cname, inst);
 		lustre_cfg_bufs_reset(&bufs, obdname);
 
 		/* find the obd by obdname */
@@ -1308,7 +1304,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 		/* continue, even one with error */
 	}
 
-	kfree(inst);
+	kfree(buf);
 	return rc;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
