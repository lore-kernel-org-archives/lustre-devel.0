Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8874CC05027
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:26:47 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15PT66P8z215M;
	Mon, 23 Jan 2023 15:08:29 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15NF0dzPz22Pc
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:07:25 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8FFDBA1E;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8D72558991; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:43 -0500
Message-Id: <1674514855-15399-31-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 30/42] lnet: socklnd: clarify error message
 on timeout
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Aurelien Degremont <degremoa@amazon.com>

When the local peer times out when writing
to another peer, prints an explicit error message
rather than a generic one. This is make it clearer
for admins and easier to debug.

Add port to help determining if this is always
the same one or not.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16439
Lustre-commit: 5b06ba9d46e19b9d7 ("LU-16439 socklnd: clarify error message on timeout")
Signed-off-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49540
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd_cb.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 15fba9d7f0ac..17ea0cca9255 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -533,11 +533,15 @@ ksocknal_process_transmit(struct ksock_conn *conn, struct ksock_tx *tx)
 	if (!conn->ksnc_closing) {
 		switch (rc) {
 		case -ECONNRESET:
-			LCONSOLE_WARN("Host %pISc reset our connection while we were sending data; it may have rebooted.\n",
-				      &conn->ksnc_peeraddr);
+			LCONSOLE_WARN("Host %pISc reset our connection while we were sending data; it may have rebooted: rc = %d\n",
+				      &conn->ksnc_peeraddr, rc);
+			break;
+		case -ETIMEDOUT:
+			LCONSOLE_WARN("Timeout error while writing to %pISp. Closing socket: rc = %d\n",
+				      &conn->ksnc_peeraddr, rc);
 			break;
 		default:
-			LCONSOLE_WARN("There was an unexpected network error while writing to %pISc: %d.\n",
+			LCONSOLE_WARN("There was an unexpected network error while writing to %pISc: rc = %d\n",
 				      &conn->ksnc_peeraddr, rc);
 			break;
 		}
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
