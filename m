Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C2BB1C433F5
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:50 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E09833AD9AA;
	Thu, 13 Jan 2022 17:38:37 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7FC043AD812
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:09 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C5E13100F32D;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C2B7FE07E3; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:49 -0500
Message-Id: <1642124283-10148-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/24] lnet: socklnd: decrement connection
 counters on close
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

To gracefully handle potential race with delayed connection create,
decrement connection counters per type as connections are being
closed.

Fixes: 511ace4a ("lnet: socklnd: add conns_per_peer parameter")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15137
Lustre-commit: 7e26413aa85fdc931 ("LU-15137 socklnd: decrement connection counters on close")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45422
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 69 ++++++++++++++++++++++++++++++++++------
 1 file changed, 60 insertions(+), 9 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index b014aa8..6d1f85c 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -422,7 +422,9 @@ struct ksock_peer_ni *
 	switch (type) {
 	case SOCKLND_CONN_CONTROL:
 		conn_cb->ksnr_ctrl_conn_count++;
-		/* there's a single control connection per peer */
+		/* there's a single control connection per peer,
+		 * two in case of loopback
+		 */
 		conn_cb->ksnr_connected |= BIT(type);
 		break;
 	case SOCKLND_CONN_BULK_IN:
@@ -449,6 +451,45 @@ struct ksock_peer_ni *
 }
 
 static void
+ksocknal_decr_conn_count(struct ksock_conn_cb *conn_cb,
+			 int type)
+{
+	conn_cb->ksnr_conn_count--;
+
+	/* check if all connections of the given type got created */
+	switch (type) {
+	case SOCKLND_CONN_CONTROL:
+		conn_cb->ksnr_ctrl_conn_count--;
+		/* there's a single control connection per peer,
+		 * two in case of loopback
+		 */
+		if (conn_cb->ksnr_ctrl_conn_count == 0)
+			conn_cb->ksnr_connected &= ~BIT(type);
+		break;
+	case SOCKLND_CONN_BULK_IN:
+		conn_cb->ksnr_blki_conn_count--;
+		if (conn_cb->ksnr_blki_conn_count < conn_cb->ksnr_max_conns)
+			conn_cb->ksnr_connected &= ~BIT(type);
+		break;
+	case SOCKLND_CONN_BULK_OUT:
+		conn_cb->ksnr_blko_conn_count--;
+		if (conn_cb->ksnr_blko_conn_count < conn_cb->ksnr_max_conns)
+			conn_cb->ksnr_connected &= ~BIT(type);
+		break;
+	case SOCKLND_CONN_ANY:
+		if (conn_cb->ksnr_conn_count < conn_cb->ksnr_max_conns)
+			conn_cb->ksnr_connected &= ~BIT(type);
+		break;
+	default:
+		LBUG();
+		break;
+	}
+
+	CDEBUG(D_NET, "Del conn type %d, ksnr_connected %x ksnr_max_conns %d\n",
+	       type, conn_cb->ksnr_connected, conn_cb->ksnr_max_conns);
+}
+
+static void
 ksocknal_associate_cb_conn_locked(struct ksock_conn_cb *conn_cb,
 				  struct ksock_conn *conn)
 {
@@ -1249,6 +1290,8 @@ struct ksock_peer_ni *
 	struct ksock_peer_ni *peer_ni = conn->ksnc_peer;
 	struct ksock_conn_cb *conn_cb;
 	struct ksock_conn *conn2;
+	int conn_count;
+	int duplicate_count = 0;
 
 	LASSERT(!peer_ni->ksnp_error);
 	LASSERT(!conn->ksnc_closing);
@@ -1262,21 +1305,29 @@ struct ksock_peer_ni *
 		/* dissociate conn from cb... */
 		LASSERT(!conn_cb->ksnr_deleted);
 
+		conn_count = ksocknal_get_conn_count_by_type(conn_cb,
+							     conn->ksnc_type);
 		/* connected bit is set only if all connections
 		 * of the given type got created
 		 */
-		if (ksocknal_get_conn_count_by_type(conn_cb, conn->ksnc_type) ==
-		    conn_cb->ksnr_max_conns)
+		if (conn_count == conn_cb->ksnr_max_conns)
 			LASSERT((conn_cb->ksnr_connected &
 				BIT(conn->ksnc_type)) != 0);
 
-		list_for_each_entry(conn2, &peer_ni->ksnp_conns, ksnc_list) {
-			if (conn2->ksnc_conn_cb == conn_cb &&
-			    conn2->ksnc_type == conn->ksnc_type)
-				goto conn2_found;
+		if (conn_count == 1) {
+			list_for_each_entry(conn2, &peer_ni->ksnp_conns,
+					    ksnc_list) {
+				if (conn2->ksnc_conn_cb == conn_cb &&
+				    conn2->ksnc_type == conn->ksnc_type)
+					duplicate_count += 1;
+			}
+			if (duplicate_count > 0)
+				CERROR("Found %d duplicate conns type %d\n",
+				       duplicate_count,
+				       conn->ksnc_type);
 		}
-		conn_cb->ksnr_connected &= ~BIT(conn->ksnc_type);
-conn2_found:
+		ksocknal_decr_conn_count(conn_cb, conn->ksnc_type);
+
 		conn->ksnc_conn_cb = NULL;
 
 		/* drop conn's ref on route */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
