Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 041FEC433FE
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:51 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0Bg3ynXz21HS;
	Fri, 14 Oct 2022 14:38:51 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0BB0LfCz21HL
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:26 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 207D310087C5;
 Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1D2E7DD535; Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:38:06 -0400
Message-Id: <1665783491-13827-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/20] lnet: o2iblnd: fix handling of
 RDMA_CM_EVENT_UNREACHABLE
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

RDMA_CM_EVENT_UNREACHABLE may be received not only when connection
is being connected, but also when it is being closed. Fix handing
of this event accordingly.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15885
Lustre-commit: 3925b1669d519e6c0 ("LU-15885 o2iblnd: fix handling of RDMA_CM_EVENT_UNREACHABLE")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48492
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 30e77c0382f1..919b83d5c6e2 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3171,13 +3171,17 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		return event->status;	/* rc destroys cmid */
 
 	case RDMA_CM_EVENT_UNREACHABLE:
-		conn = (struct kib_conn *)cmid->context;
-		LASSERT(conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT ||
-			conn->ibc_state == IBLND_CONN_PASSIVE_WAIT);
-		CNETERR("%s: UNREACHABLE %d\n",
-			libcfs_nid2str(conn->ibc_peer->ibp_nid), event->status);
-		kiblnd_connreq_done(conn, -ENETDOWN);
-		kiblnd_conn_decref(conn);
+		CNETERR("%s: UNREACHABLE %d, ibc_state: %d\n",
+			libcfs_nid2str(conn->ibc_peer->ibp_nid),
+			event->status,
+			conn->ibc_state);
+		LASSERT(conn->ibc_state != IBLND_CONN_ESTABLISHED &&
+			conn->ibc_state != IBLND_CONN_INIT);
+		if (conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT ||
+		    conn->ibc_state == IBLND_CONN_PASSIVE_WAIT) {
+			kiblnd_connreq_done(conn, -ENETDOWN);
+			kiblnd_conn_decref(conn);
+		}
 		return 0;
 
 	case RDMA_CM_EVENT_CONNECT_ERROR:
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
