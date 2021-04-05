Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDCDAC433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:52 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B51E96138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B51E96138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AC93E32C4E4;
	Mon,  5 Apr 2021 00:52:22 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6975B21FB85
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:26 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 0EF32E3B;
 Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 09E8B90AAC; Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:59 -0400
Message-Id: <1617583870-32029-31-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 30/41] lustre: lov: style cleanups in
 lov_set_osc_active()
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

1/ don't pre-declare the function as it is not used before it
   is defined.
2/ " TEST ? 1 : 0" is identical to "TEST", so remove the "? 1 : 0".
3/ When the 'then' part of an 'if' ends with a goto, there is
   not point having an 'else', particularly if there is also
   code in the block following the "if".  The 'else' code and
   the following code should be together.

4/ other minor changes, and conversion of spaces to tabs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: cab152600ebe8a0 ("LU-6142 lov: style cleanups in lov_set_osc_active()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39382
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_obd.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index c8654bd..9554d85 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -114,8 +114,6 @@ void lov_tgts_putref(struct obd_device *obd)
 	}
 }
 
-static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
-			      enum obd_notify_event ev);
 static int lov_notify(struct obd_device *obd, struct obd_device *watched,
 		      enum obd_notify_event ev);
 
@@ -354,7 +352,8 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 {
 	struct lov_obd *lov = &obd->u.lov;
 	struct lov_tgt_desc *tgt;
-	int index, activate, active;
+	int index;
+	bool activate, active;
 
 	CDEBUG(D_INFO, "Searching in lov %p for uuid %s event(%d)\n",
 	       lov, uuid->uuid, ev);
@@ -362,9 +361,7 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 	lov_tgts_getref(obd);
 	for (index = 0; index < lov->desc.ld_tgt_count; index++) {
 		tgt = lov->lov_tgts[index];
-		if (!tgt)
-			continue;
-		if (obd_uuid_equals(uuid, &tgt->ltd_uuid))
+		if (tgt && obd_uuid_equals(uuid, &tgt->ltd_uuid))
 			break;
 	}
 
@@ -374,7 +371,7 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 	}
 
 	if (ev == OBD_NOTIFY_DEACTIVATE || ev == OBD_NOTIFY_ACTIVATE) {
-		activate = (ev == OBD_NOTIFY_ACTIVATE) ? 1 : 0;
+		activate = (ev == OBD_NOTIFY_ACTIVATE);
 
 		/*
 		 * LU-642, initially inactive OSC could miss the obd_connect,
@@ -401,9 +398,8 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 			CDEBUG(D_CONFIG, "%sactivate OSC %s\n",
 			       activate ? "" : "de", obd_uuid2str(uuid));
 		}
-
 	} else if (ev == OBD_NOTIFY_INACTIVE || ev == OBD_NOTIFY_ACTIVE) {
-		active = (ev == OBD_NOTIFY_ACTIVE) ? 1 : 0;
+		active = (ev == OBD_NOTIFY_ACTIVE);
 
 		if (lov->lov_tgts[index]->ltd_active == active) {
 			CDEBUG(D_INFO, "OSC %s already %sactive!\n",
@@ -422,7 +418,8 @@ static int lov_set_osc_active(struct obd_device *obd, struct obd_uuid *uuid,
 			lov->lov_tgts[index]->ltd_exp->exp_obd->obd_inactive = 1;
 		}
 	} else {
-		CERROR("Unknown event(%d) for uuid %s", ev, uuid->uuid);
+		CERROR("%s: unknown event %d for uuid %s\n", obd->obd_name,
+		       ev, uuid->uuid);
 	}
 
 	if (tgt->ltd_exp)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
