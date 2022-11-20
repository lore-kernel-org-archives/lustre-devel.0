Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A4283C433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:39:57 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXmY3R2Yz1wZV;
	Sun, 20 Nov 2022 06:22:53 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXm33nbnz226T
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:22:27 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E761A1009355;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E460CE8B84; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:17:03 -0500
Message-Id: <1668953828-10909-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/22] lnet: Signal completion on ping send
 failure
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

Call complete() on the ping_data::completion if we get
LNET_EVENT_SEND with non-zero status. Otherwise the thread which
issued the ping is stuck waiting for the full ping timeout.

A pd_unlinked member is added to struct ping_data to indicate whether
the associated MD has been unlinked. This is checked by lnet_ping() to
determine whether it needs to explicitly called LNetMDUnlink().

Lastly, in cases where we do not receive a reply, we now return the
value of pd.rc, if it is non-zero, rather than -EIO. This can provide
more information about the underlying ping failure.

HPE-bug-id: LUS-11317
WC-bug-id: https://jira.whamcloud.com/browse/LU-16290
Lustre-commit: 48c34c71de65e8a25 ("LU-16290 lnet: Signal completion on ping send failure")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49020
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 935c848..8b53adf 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -5333,6 +5333,7 @@ void LNetDebugPeer(struct lnet_processid *id)
 struct ping_data {
 	int rc;
 	int replied;
+	int pd_unlinked;
 	struct lnet_handle_md mdh;
 	struct completion completion;
 };
@@ -5353,7 +5354,12 @@ struct ping_data {
 		pd->replied = 1;
 		pd->rc = event->mlength;
 	}
+
 	if (event->unlinked)
+		pd->pd_unlinked = 1;
+
+	if (event->unlinked ||
+	    (event->type == LNET_EVENT_SEND && event->status))
 		complete(&pd->completion);
 }
 
@@ -5424,13 +5430,14 @@ static int lnet_ping(struct lnet_process_id id4, struct lnet_nid *src_nid,
 		/* NB must wait for the UNLINK event below... */
 	}
 
-	if (wait_for_completion_timeout(&pd.completion, timeout) == 0) {
-		/* Ensure completion in finite time... */
+	/* Ensure completion in finite time... */
+	wait_for_completion_timeout(&pd.completion, timeout);
+	if (!pd.pd_unlinked) {
 		LNetMDUnlink(pd.mdh);
 		wait_for_completion(&pd.completion);
 	}
 	if (!pd.replied) {
-		rc = -EIO;
+		rc = pd.rc ?: -EIO;
 		goto fail_ping_buffer_decref;
 	}
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
