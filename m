Return-Path: <SRS0=GtYW=HL=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF6D2C433DB
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:46 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 826B364E77
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 826B364E77
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 83AD730FACE;
	Mon,  8 Feb 2021 16:54:41 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3B5E630F758
 for <lustre-devel@lists.lustre.org>; Mon,  8 Feb 2021 16:54:31 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id ECAD11006EBA;
 Mon,  8 Feb 2021 19:54:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E7B394CC36; Mon,  8 Feb 2021 19:54:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Feb 2021 19:54:21 -0500
Message-Id: <1612832067-1449-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
References: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 3/9] lustre: obdclass: connect vs disconnect
 race
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
Cc: Wang Shilong <wshilong@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Wang Shilong <wshilong@ddn.com>

There might be a possible race if setup (connect)
and cleanup (disconnect) are tangled together(similar
comments in osc_disconnect()):

  Thread1:                              Thread2:
    connecting                            class_cleanup
      ptlrpc_connect_interpret
                                            obd->obd_setup = 0
      obd_import_event
        if (obd->obd_set_up)
            osc_init_grant() /*skipped*/
        ptlrpc_activate_import..

And If RPC was waked up and send out before
class_disconnect_exports(), It might hit divide zero crash
in osc_announce_cached() because @cl_max_extent_pages is zero.

The problem is we clear @obd_setup too early, It should be cleared
when OBD is really shutdown.

Fixes: cfd750 ("lustre: obdclass: obd_device improvement")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14283
Lustre-commit: 4f689a30fb5d870 ("LU-14283 obdclass: connect vs disconnect race")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/41256
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/obd_config.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 09dee7b..8f062bb 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -467,10 +467,6 @@ static int class_cleanup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	}
 	/* Leave this on forever */
 	obd->obd_stopping = 1;
-	/* function can't return error after that point, so clear setup flag
-	 * as early as possible to avoid finding via obd_devs / hash
-	 */
-	obd->obd_set_up = 0;
 	spin_unlock(&obd->obd_dev_lock);
 
 	while (obd->obd_conn_inprogress > 0)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
