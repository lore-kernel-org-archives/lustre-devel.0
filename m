Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA232C433ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:27 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8961B6124B
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8961B6124B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2F19321F888;
	Sun, 25 Apr 2021 13:09:09 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9B6BF21F7E7
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 499EA10087D4;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4728B69A7D; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:32 -0400
Message-Id: <1619381316-7719-26-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 25/29] lustre: misc: limit CDEBUG console
 message frequency
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

From: Andreas Dilger <adilger@whamcloud.com>

Some CDEBUG() messages have variable message levels, but if printed
to the console it is not rate limited like CWARN() and CERROR():

server_bulk_callback()) event type 5, status -110
server_bulk_callback()) event type 5, status -110
server_bulk_callback()) event type 5, status -110
:

Instead, use CDEBUG_LIMIT() for those messages to limit them.

WC-bug-id: https://jira.whamcloud.com/browse/LU-930
Lustre-commit: 7462e8cad730897f4 ("LU-930 misc: limit CDEBUG console message frequency")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40571
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c    |  6 +++---
 fs/lustre/lov/lov_obd.c   | 10 +++++-----
 fs/lustre/ptlrpc/client.c |  8 ++++----
 fs/lustre/ptlrpc/events.c | 16 +++++++---------
 4 files changed, 19 insertions(+), 21 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index c049433..15072bb1 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -329,9 +329,9 @@ static int ll_md_close(struct inode *inode, struct file *file)
 		 * application crashed, we need to release here.
 		 */
 		rc = ll_lease_close(fd->fd_lease_och, inode, &lease_broken);
-		CDEBUG(rc ? D_ERROR : D_INODE,
-		       "Clean up lease " DFID " %d/%d\n",
-		       PFID(&lli->lli_fid), rc, lease_broken);
+		CDEBUG_LIMIT(rc ? D_ERROR : D_INODE,
+			     "Clean up lease " DFID " %d/%d\n",
+			     PFID(&lli->lli_fid), rc, lease_broken);
 
 		fd->fd_lease_och = NULL;
 	}
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 29b0645..20e0be0 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -1081,11 +1081,11 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 					    len, karg, uarg);
 			if (err) {
 				if (lov->lov_tgts[i]->ltd_active) {
-					CDEBUG(err == -ENOTTY ?
-					       D_IOCTL : D_WARNING,
-					       "iocontrol OSC %s on OST idx %d cmd %x: err = %d\n",
-					       lov_uuid2str(lov, i),
-					       i, cmd, err);
+					CDEBUG_LIMIT(err == -ENOTTY ?
+						     D_IOCTL : D_WARNING,
+						     "iocontrol OSC %s on OST idx %d cmd %x: err = %d\n",
+						     lov_uuid2str(lov, i),
+						     i, cmd, err);
 					if (!rc)
 						rc = err;
 				}
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 3c57b69..a818b01 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -378,10 +378,10 @@ void ptlrpc_at_adj_net_latency(struct ptlrpc_request *req,
 		 * resent time, but server sent back service time of original
 		 * RPC.
 		 */
-		CDEBUG((lustre_msg_get_flags(req->rq_reqmsg) & MSG_RESENT) ?
-		       D_ADAPTTO : D_WARNING,
-		       "Reported service time %u > total measured time %lld\n",
-		       service_timeout, now - req->rq_sent);
+		CDEBUG_LIMIT((lustre_msg_get_flags(req->rq_reqmsg) &
+			      MSG_RESENT) ?  D_ADAPTTO : D_WARNING,
+			     "Reported service time %u > total measured time %lld\n",
+			     service_timeout, now - req->rq_sent);
 		return;
 	}
 
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index fe33600..e348e4a 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -203,9 +203,9 @@ void client_bulk_callback(struct lnet_event *ev)
 				 CFS_FAIL_ONCE))
 		ev->status = -EIO;
 
-	CDEBUG((ev->status == 0) ? D_NET : D_ERROR,
-	       "event type %d, status %d, desc %p\n",
-	       ev->type, ev->status, desc);
+	CDEBUG_LIMIT((ev->status == 0) ? D_NET : D_ERROR,
+		     "event type %d, status %d, desc %p\n",
+		     ev->type, ev->status, desc);
 
 	spin_lock(&desc->bd_lock);
 	req = desc->bd_req;
@@ -311,9 +311,9 @@ void request_in_callback(struct lnet_event *ev)
 	LASSERT((char *)ev->md_start + ev->offset + ev->mlength <=
 		rqbd->rqbd_buffer + service->srv_buf_size);
 
-	CDEBUG((ev->status == 0) ? D_NET : D_ERROR,
-	       "event type %d, status %d, service %s\n",
-	       ev->type, ev->status, service->srv_name);
+	CDEBUG_LIMIT((ev->status == 0) ? D_NET : D_ERROR,
+		     "event type %d, status %d, service %s\n",
+		     ev->type, ev->status, service->srv_name);
 
 	if (ev->unlinked) {
 		/* If this is the last request message to fit in the
@@ -326,10 +326,8 @@ void request_in_callback(struct lnet_event *ev)
 		memset(req, 0, sizeof(*req));
 	} else {
 		LASSERT(ev->type == LNET_EVENT_PUT);
-		if (ev->status != 0) {
-			/* We moaned above already... */
+		if (ev->status != 0) /* We moaned above already... */
 			return;
-		}
 		req = ptlrpc_request_cache_alloc(GFP_ATOMIC);
 		if (!req) {
 			CERROR("Can't allocate incoming request descriptor: Dropping %s RPC from %s\n",
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
