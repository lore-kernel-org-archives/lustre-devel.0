Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 12A9DC433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:33:32 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 00F7A21FCAD;
	Sun, 20 Mar 2022 06:32:25 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0994B21E083
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:14 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 22692EE4;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 20875AB; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:31 -0400
Message-Id: <1647783064-20688-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/50] lnet: change lnet_prep_send to take
 net_processid
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

Instead of a 'struct lnet_process_id', lnet_prep_send() now takes a
"struct lnet_processid *" with allows larger address.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: c0ccfaf1e35935273 ("LU-10391 lnet: change lnet_prep_send to take net_processid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43605
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  2 +-
 net/lnet/lnet/lib-move.c      | 61 +++++++++++++++++++++++--------------------
 net/lnet/lnet/lib-msg.c       |  3 +--
 3 files changed, 35 insertions(+), 31 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 8c4940f..ce18897 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -613,7 +613,7 @@ void lnet_msg_attach_md(struct lnet_msg *msg, struct lnet_libmd *md,
 void lnet_msg_decommit(struct lnet_msg *msg, int cpt, int status);
 
 void lnet_prep_send(struct lnet_msg *msg, int type,
-		    struct lnet_process_id target, unsigned int offset,
+		    struct lnet_processid *target, unsigned int offset,
 		    unsigned int len);
 int lnet_send(struct lnet_nid *nid, struct lnet_msg *msg,
 	      struct lnet_nid *rtr_nid);
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index f4c24ff..1c72ea2 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -513,12 +513,11 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 }
 
 void
-lnet_prep_send(struct lnet_msg *msg, int type, struct lnet_process_id target,
+lnet_prep_send(struct lnet_msg *msg, int type, struct lnet_processid *target,
 	       unsigned int offset, unsigned int len)
 {
 	msg->msg_type = type;
-	msg->msg_target.pid = target.pid;
-	lnet_nid4_to_nid(target.nid, &msg->msg_target.nid);
+	msg->msg_target = *target;
 	msg->msg_len = len;
 	msg->msg_offset = offset;
 
@@ -528,8 +527,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	memset(&msg->msg_hdr, 0, sizeof(msg->msg_hdr));
 	msg->msg_hdr.type = type;
 	/* dest_nid will be overwritten by lnet_select_pathway() */
-	lnet_nid4_to_nid(target.nid, &msg->msg_hdr.dest_nid);
-	msg->msg_hdr.dest_pid = target.pid;
+	msg->msg_hdr.dest_nid = target->nid;
+	msg->msg_hdr.dest_pid = target->pid;
 	/* src_nid will be set later */
 	msg->msg_hdr.src_pid = the_lnet.ln_pid;
 	msg->msg_hdr.payload_length = len;
@@ -3978,7 +3977,7 @@ void lnet_monitor_thr_stop(void)
 {
 	struct lnet_match_info info;
 	struct lnet_hdr *hdr = &msg->msg_hdr;
-	struct lnet_process_id source_id;
+	struct lnet_processid source_id;
 	struct lnet_handle_wire reply_wmd;
 	int rc;
 
@@ -3988,7 +3987,7 @@ void lnet_monitor_thr_stop(void)
 	le32_to_cpus(&hdr->msg.get.sink_length);
 	le32_to_cpus(&hdr->msg.get.src_offset);
 
-	source_id.nid = lnet_nid_to_nid4(&hdr->src_nid);
+	source_id.nid = hdr->src_nid;
 	source_id.pid = hdr->src_pid;
 	/* Primary peer NID */
 	info.mi_id.nid = msg->msg_initiator;
@@ -4014,7 +4013,7 @@ void lnet_monitor_thr_stop(void)
 
 	reply_wmd = hdr->msg.get.return_wmd;
 
-	lnet_prep_send(msg, LNET_MSG_REPLY, source_id,
+	lnet_prep_send(msg, LNET_MSG_REPLY, &source_id,
 		       msg->msg_offset, msg->msg_wanted);
 
 	msg->msg_hdr.msg.reply.dst_wmd = reply_wmd;
@@ -4702,11 +4701,12 @@ void lnet_monitor_thr_stop(void)
  */
 int
 LNetPut(lnet_nid_t self4, struct lnet_handle_md mdh, enum lnet_ack_req ack,
-	struct lnet_process_id target, unsigned int portal,
+	struct lnet_process_id target4, unsigned int portal,
 	u64 match_bits, unsigned int offset,
 	u64 hdr_data)
 {
 	struct lnet_rsp_tracker *rspt = NULL;
+	struct lnet_processid target;
 	struct lnet_msg *msg;
 	struct lnet_libmd *md;
 	struct lnet_nid self;
@@ -4716,18 +4716,20 @@ void lnet_monitor_thr_stop(void)
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	lnet_nid4_to_nid(self4, &self);
+	lnet_nid4_to_nid(target4.nid, &target.nid);
+	target.pid = target4.pid;
 
-	if (!list_empty(&the_lnet.ln_test_peers) && /* normally we don't */
-	    fail_peer(target.nid, 1)) { /* shall we now? */
+	if (!list_empty(&the_lnet.ln_test_peers) &&	/* normally we don't */
+	    fail_peer(target4.nid, 1)) {		/* shall we now? */
 		CERROR("Dropping PUT to %s: simulated failure\n",
-		       libcfs_id2str(target));
+		       libcfs_id2str(target4));
 		return -EIO;
 	}
 
 	msg = kmem_cache_zalloc(lnet_msg_cachep, GFP_NOFS);
 	if (!msg) {
 		CERROR("Dropping PUT to %s: ENOMEM on struct lnet_msg\n",
-		       libcfs_id2str(target));
+		       libcfs_id2str(target4));
 		return -ENOMEM;
 	}
 	msg->msg_vmflush = !!(current->flags & PF_MEMALLOC);
@@ -4738,7 +4740,7 @@ void lnet_monitor_thr_stop(void)
 		rspt = lnet_rspt_alloc(cpt);
 		if (!rspt) {
 			CERROR("Dropping PUT to %s: ENOMEM on response tracker\n",
-			       libcfs_id2str(target));
+			       libcfs_id2str(target4));
 			return -ENOMEM;
 		}
 		INIT_LIST_HEAD(&rspt->rspt_on_list);
@@ -4749,7 +4751,7 @@ void lnet_monitor_thr_stop(void)
 	md = lnet_handle2md(&mdh);
 	if (!md || !md->md_threshold || md->md_me) {
 		CERROR("Dropping PUT (%llu:%d:%s): MD (%d) invalid\n",
-		       match_bits, portal, libcfs_id2str(target),
+		       match_bits, portal, libcfs_id2str(target4),
 		       !md ? -1 : md->md_threshold);
 		if (md && md->md_me)
 			CERROR("Source MD also attached to portal %d\n",
@@ -4763,11 +4765,11 @@ void lnet_monitor_thr_stop(void)
 		return -ENOENT;
 	}
 
-	CDEBUG(D_NET, "%s -> %s\n", __func__, libcfs_id2str(target));
+	CDEBUG(D_NET, "%s -> %s\n", __func__, libcfs_id2str(target4));
 
 	lnet_msg_attach_md(msg, md, 0, 0);
 
-	lnet_prep_send(msg, LNET_MSG_PUT, target, 0, md->md_length);
+	lnet_prep_send(msg, LNET_MSG_PUT, &target, 0, md->md_length);
 
 	msg->msg_hdr.msg.put.match_bits = cpu_to_le64(match_bits);
 	msg->msg_hdr.msg.put.ptl_index = cpu_to_le32(portal);
@@ -4804,7 +4806,7 @@ void lnet_monitor_thr_stop(void)
 		rc = lnet_send(&self, msg, NULL);
 	if (rc) {
 		CNETERR("Error sending PUT to %s: %d\n",
-			libcfs_id2str(target), rc);
+			libcfs_id2str(target4), rc);
 		msg->msg_no_resend = true;
 		lnet_finalize(msg, rc);
 	}
@@ -4946,10 +4948,11 @@ struct lnet_msg *
  */
 int
 LNetGet(lnet_nid_t self4, struct lnet_handle_md mdh,
-	struct lnet_process_id target, unsigned int portal,
+	struct lnet_process_id target4, unsigned int portal,
 	u64 match_bits, unsigned int offset, bool recovery)
 {
 	struct lnet_rsp_tracker *rspt;
+	struct lnet_processid target;
 	struct lnet_msg *msg;
 	struct lnet_libmd *md;
 	struct lnet_nid self;
@@ -4959,18 +4962,20 @@ struct lnet_msg *
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	lnet_nid4_to_nid(self4, &self);
+	lnet_nid4_to_nid(target4.nid, &target.nid);
+	target.pid = target4.pid;
 
-	if (!list_empty(&the_lnet.ln_test_peers) && /* normally we don't */
-	    fail_peer(target.nid, 1)) {		/* shall we now? */
+	if (!list_empty(&the_lnet.ln_test_peers) &&	/* normally we don't */
+	    fail_peer(target4.nid, 1)) {		/* shall we now? */
 		CERROR("Dropping GET to %s: simulated failure\n",
-		       libcfs_id2str(target));
+		       libcfs_id2str(target4));
 		return -EIO;
 	}
 
 	msg = kmem_cache_zalloc(lnet_msg_cachep, GFP_NOFS);
 	if (!msg) {
 		CERROR("Dropping GET to %s: ENOMEM on struct lnet_msg\n",
-		       libcfs_id2str(target));
+		       libcfs_id2str(target4));
 		return -ENOMEM;
 	}
 
@@ -4979,7 +4984,7 @@ struct lnet_msg *
 	rspt = lnet_rspt_alloc(cpt);
 	if (!rspt) {
 		CERROR("Dropping GET to %s: ENOMEM on response tracker\n",
-		       libcfs_id2str(target));
+		       libcfs_id2str(target4));
 		return -ENOMEM;
 	}
 	INIT_LIST_HEAD(&rspt->rspt_on_list);
@@ -4991,7 +4996,7 @@ struct lnet_msg *
 	md = lnet_handle2md(&mdh);
 	if (!md || !md->md_threshold || md->md_me) {
 		CERROR("Dropping GET (%llu:%d:%s): MD (%d) invalid\n",
-		       match_bits, portal, libcfs_id2str(target),
+		       match_bits, portal, libcfs_id2str(target4),
 		       !md ? -1 : md->md_threshold);
 		if (md && md->md_me)
 			CERROR("REPLY MD also attached to portal %d\n",
@@ -5004,11 +5009,11 @@ struct lnet_msg *
 		return -ENOENT;
 	}
 
-	CDEBUG(D_NET, "%s -> %s\n", __func__, libcfs_id2str(target));
+	CDEBUG(D_NET, "%s -> %s\n", __func__, libcfs_id2str(target4));
 
 	lnet_msg_attach_md(msg, md, 0, 0);
 
-	lnet_prep_send(msg, LNET_MSG_GET, target, 0, 0);
+	lnet_prep_send(msg, LNET_MSG_GET, &target, 0, 0);
 
 	msg->msg_hdr.msg.get.match_bits = cpu_to_le64(match_bits);
 	msg->msg_hdr.msg.get.ptl_index = cpu_to_le32(portal);
@@ -5033,7 +5038,7 @@ struct lnet_msg *
 	rc = lnet_send(&self, msg, NULL);
 	if (rc < 0) {
 		CNETERR("Error sending GET to %s: %d\n",
-			libcfs_id2str(target), rc);
+			libcfs_id2str(target4), rc);
 		msg->msg_no_resend = true;
 		lnet_finalize(msg, rc);
 	}
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 9a4e268..88f017b 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -390,8 +390,7 @@
 
 		ack_wmd = msg->msg_hdr.msg.put.ack_wmd;
 
-		lnet_prep_send(msg, LNET_MSG_ACK,
-			       lnet_pid_to_pid4(&msg->msg_ev.source), 0, 0);
+		lnet_prep_send(msg, LNET_MSG_ACK, &msg->msg_ev.source, 0, 0);
 
 		msg->msg_hdr.msg.ack.dst_wmd = ack_wmd;
 		msg->msg_hdr.msg.ack.match_bits = msg->msg_ev.match_bits;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
