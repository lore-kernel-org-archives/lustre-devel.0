Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D4865C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:36 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0B31921CAFB;
	Sun, 20 Mar 2022 06:31:26 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 55A4C21E098
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:14 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 2564FEE5;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 23D73D6A26; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:32 -0400
Message-Id: <1647783064-20688-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/50] lnet: convert to struct
 lnet_process_id in lib-move
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

Various functions in lib-move.c create a 'struct lnet_process_id' just
for the purpose of reporting it in error/debug messages.

Change these to 'struct lnet_processid' with larger address support.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 9feddf7e5d01be437 ("LU-10391 lnet: convert to struct lnet_process_id in lib-move")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43606
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 1c72ea2..aa230d7 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4046,7 +4046,7 @@ void lnet_monitor_thr_stop(void)
 {
 	void *private = msg->msg_private;
 	struct lnet_hdr *hdr = &msg->msg_hdr;
-	struct lnet_process_id src = { 0 };
+	struct lnet_processid src = {};
 	struct lnet_libmd *md;
 	int rlength;
 	int mlength;
@@ -4055,14 +4055,14 @@ void lnet_monitor_thr_stop(void)
 	cpt = lnet_cpt_of_cookie(hdr->msg.reply.dst_wmd.wh_object_cookie);
 	lnet_res_lock(cpt);
 
-	src.nid = lnet_nid_to_nid4(&hdr->src_nid);
+	src.nid = hdr->src_nid;
 	src.pid = hdr->src_pid;
 
 	/* NB handles only looked up by creator (no flips) */
 	md = lnet_wire_handle2md(&hdr->msg.reply.dst_wmd);
 	if (!md || !md->md_threshold || md->md_me) {
 		CNETERR("%s: Dropping REPLY from %s for %s MD %#llx.%#llx\n",
-			libcfs_nidstr(&ni->ni_nid), libcfs_id2str(src),
+			libcfs_nidstr(&ni->ni_nid), libcfs_idstr(&src),
 			!md ? "invalid" : "inactive",
 			hdr->msg.reply.dst_wmd.wh_interface_cookie,
 			hdr->msg.reply.dst_wmd.wh_object_cookie);
@@ -4082,7 +4082,7 @@ void lnet_monitor_thr_stop(void)
 	if (mlength < rlength &&
 	    !(md->md_options & LNET_MD_TRUNCATE)) {
 		CNETERR("%s: Dropping REPLY from %s length %d for MD %#llx would overflow (%d)\n",
-			libcfs_nidstr(&ni->ni_nid), libcfs_id2str(src),
+			libcfs_nidstr(&ni->ni_nid), libcfs_idstr(&src),
 			rlength, hdr->msg.reply.dst_wmd.wh_object_cookie,
 			mlength);
 		lnet_res_unlock(cpt);
@@ -4090,7 +4090,7 @@ void lnet_monitor_thr_stop(void)
 	}
 
 	CDEBUG(D_NET, "%s: Reply from %s of length %d/%d into md %#llx\n",
-	       libcfs_nidstr(&ni->ni_nid), libcfs_id2str(src),
+	       libcfs_nidstr(&ni->ni_nid), libcfs_idstr(&src),
 	       mlength, rlength, hdr->msg.reply.dst_wmd.wh_object_cookie);
 
 	lnet_msg_attach_md(msg, md, 0, mlength);
@@ -4110,11 +4110,11 @@ void lnet_monitor_thr_stop(void)
 lnet_parse_ack(struct lnet_ni *ni, struct lnet_msg *msg)
 {
 	struct lnet_hdr *hdr = &msg->msg_hdr;
-	struct lnet_process_id src = { 0 };
+	struct lnet_processid src = {};
 	struct lnet_libmd *md;
 	int cpt;
 
-	src.nid = lnet_nid_to_nid4(&hdr->src_nid);
+	src.nid = hdr->src_nid;
 	src.pid = hdr->src_pid;
 
 	/* Convert ack fields to host byte order */
@@ -4130,7 +4130,7 @@ void lnet_monitor_thr_stop(void)
 		/* Don't moan; this is expected */
 		CDEBUG(D_NET,
 		       "%s: Dropping ACK from %s to %s MD %#llx.%#llx\n",
-		       libcfs_nidstr(&ni->ni_nid), libcfs_id2str(src),
+		       libcfs_nidstr(&ni->ni_nid), libcfs_idstr(&src),
 		       !md ? "invalid" : "inactive",
 		       hdr->msg.ack.dst_wmd.wh_interface_cookie,
 		       hdr->msg.ack.dst_wmd.wh_object_cookie);
@@ -4143,7 +4143,7 @@ void lnet_monitor_thr_stop(void)
 	}
 
 	CDEBUG(D_NET, "%s: ACK from %s into md %#llx\n",
-	       libcfs_nidstr(&ni->ni_nid), libcfs_id2str(src),
+	       libcfs_nidstr(&ni->ni_nid), libcfs_idstr(&src),
 	       hdr->msg.ack.dst_wmd.wh_object_cookie);
 
 	lnet_msg_attach_md(msg, md, 0, 0);
@@ -4543,11 +4543,11 @@ void lnet_monitor_thr_stop(void)
 
 	while ((msg = list_first_entry_or_null(head, struct lnet_msg,
 					       msg_list)) != NULL) {
-		struct lnet_process_id id = { 0 };
+		struct lnet_processid id = {};
 
 		list_del(&msg->msg_list);
 
-		id.nid = lnet_nid_to_nid4(&msg->msg_hdr.src_nid);
+		id.nid = msg->msg_hdr.src_nid;
 		id.pid = msg->msg_hdr.src_pid;
 
 		LASSERT(!msg->msg_md);
@@ -4556,7 +4556,7 @@ void lnet_monitor_thr_stop(void)
 		LASSERT(msg->msg_hdr.type == LNET_MSG_PUT);
 
 		CWARN("Dropping delayed PUT from %s portal %d match %llu offset %d length %d: %s\n",
-		      libcfs_id2str(id),
+		      libcfs_idstr(&id),
 		      msg->msg_hdr.msg.put.ptl_index,
 		      msg->msg_hdr.msg.put.match_bits,
 		      msg->msg_hdr.msg.put.offset,
@@ -4588,14 +4588,14 @@ void lnet_monitor_thr_stop(void)
 
 	while ((msg = list_first_entry_or_null(head, struct lnet_msg,
 					       msg_list)) != NULL) {
-		struct lnet_process_id id;
+		struct lnet_processid id;
 
 		list_del(&msg->msg_list);
 
 		/* md won't disappear under me, since each msg
 		 * holds a ref on it
 		 */
-		id.nid = lnet_nid_to_nid4(&msg->msg_hdr.src_nid);
+		id.nid = msg->msg_hdr.src_nid;
 		id.pid = msg->msg_hdr.src_pid;
 
 		LASSERT(msg->msg_rx_delayed);
@@ -4605,7 +4605,7 @@ void lnet_monitor_thr_stop(void)
 		LASSERT(msg->msg_hdr.type == LNET_MSG_PUT);
 
 		CDEBUG(D_NET, "Resuming delayed PUT from %s portal %d match %llu offset %d length %d.\n",
-		       libcfs_id2str(id), msg->msg_hdr.msg.put.ptl_index,
+		       libcfs_idstr(&id), msg->msg_hdr.msg.put.ptl_index,
 		       msg->msg_hdr.msg.put.match_bits,
 		       msg->msg_hdr.msg.put.offset,
 		       msg->msg_hdr.payload_length);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
