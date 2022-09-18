Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 33D0AC6FA8B
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:32 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbm54BNJz1yBh;
	Sat, 17 Sep 2022 22:22:29 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVblz1XpGz1y78
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:23 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id DF50E8F04;
 Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D658DE8B94; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:21:56 -0400
Message-Id: <1663478534-19917-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/24] lustre: ptlrpc: change bd_sender in
 ptlrpc_bulk_frag_ops
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

From: Mr NeilBrown <neilb@suse.de>

bd_sender in struct ptlrpc_bulk_frag_ops is now 'struct lnet_nid'.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: d096ca267bb74fa3e1 ("LU-10391 ptlrpc: change bd_sender in ptlrpc_bulk_frag_ops")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/44640
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 2 +-
 fs/lustre/osc/osc_request.c    | 4 ++--
 fs/lustre/ptlrpc/events.c      | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index d9aa530..f8d2861 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1211,7 +1211,7 @@ struct ptlrpc_bulk_desc {
 	u64				bd_last_mbits;
 
 	struct ptlrpc_cb_id		bd_cbid;	/* network callback info */
-	lnet_nid_t			bd_sender;	/* stash event::sender */
+	struct lnet_nid			bd_sender;	/* stash event::sender */
 	int				bd_md_count;	/* # valid entries in bd_mds */
 	int				bd_md_max_brw;	/* max entries in bd_mds */
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index d66185b..7577fad 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2253,9 +2253,9 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 			goto out;
 
 		if (req->rq_bulk &&
-		    lnet_nid_to_nid4(&peer->nid) != req->rq_bulk->bd_sender) {
+		    !nid_same(&peer->nid, &req->rq_bulk->bd_sender)) {
 			via = " via ";
-			router = libcfs_nid2str(req->rq_bulk->bd_sender);
+			router = libcfs_nidstr(&req->rq_bulk->bd_sender);
 		}
 
 		if (server_cksum != client_cksum) {
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index e6313af..17ef775 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -213,7 +213,7 @@ void client_bulk_callback(struct lnet_event *ev)
 
 	if (ev->type != LNET_EVENT_UNLINK && ev->status == 0) {
 		desc->bd_nob_transferred += ev->mlength;
-		desc->bd_sender = lnet_nid_to_nid4(&ev->sender);
+		desc->bd_sender = ev->sender;
 	} else {
 		/* start reconnect and resend if network error hit */
 		spin_lock(&req->rq_lock);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
