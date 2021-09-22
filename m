Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 638B0C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:50 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2C50B6112F
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 2C50B6112F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4849321F1C6;
	Tue, 21 Sep 2021 19:21:49 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7FC3221F222
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:09 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 20C7D465;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1CE30FF4BF; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:49 -0400
Message-Id: <1632277201-6920-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/24] lnet: extend rspt_next_hop_nid in
 lnet_rsp_tracker
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

rspt_next_hop_nid in 'struct lnet_rsp_tracker' is now
a 'struct lnet_nid'.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: a34afe7f20ec7d618 ("LU-10391 lnet: extend rspt_next_hop_nid in lnet_rsp_tracker")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43594
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  2 +-
 net/lnet/lnet/lib-move.c       | 10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 1e1ddd7..380a7b9 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -87,7 +87,7 @@ struct lnet_rsp_tracker {
 	/* cpt to lock */
 	int rspt_cpt;
 	/* nid of next hop */
-	lnet_nid_t rspt_next_hop_nid;
+	struct lnet_nid rspt_next_hop_nid;
 	/* deadline of the REPLY/ACK */
 	ktime_t rspt_deadline;
 	/* parent MD */
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 2454a0c..f2978eb 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1755,9 +1755,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		rspt = msg->msg_md->md_rspt_ptr;
 		if (rspt) {
 			rspt->rspt_next_hop_nid =
-				lnet_nid_to_nid4(&msg->msg_txpeer->lpni_nid);
+				msg->msg_txpeer->lpni_nid;
 			CDEBUG(D_NET, "rspt_next_hop_nid = %s\n",
-			       libcfs_nid2str(rspt->rspt_next_hop_nid));
+			       libcfs_nidstr(&rspt->rspt_next_hop_nid));
 		}
 	}
 
@@ -2969,7 +2969,7 @@ struct lnet_mt_event_info {
 			if (ktime_compare(now, rspt->rspt_deadline) >= 0 ||
 			    the_lnet.ln_mt_state == LNET_MT_STATE_SHUTDOWN) {
 				struct lnet_peer_ni *lpni;
-				lnet_nid_t nid;
+				struct lnet_nid nid;
 
 				md = lnet_handle2md(&rspt->rspt_mdh);
 				if (!md) {
@@ -3028,14 +3028,14 @@ struct lnet_mt_event_info {
 
 				CDEBUG(D_NET,
 				       "Response timeout: md = %p: nid = %s\n",
-				       md, libcfs_nid2str(nid));
+				       md, libcfs_nidstr(&nid));
 
 				/* If there is a timeout on the response
 				 * from the next hop decrement its health
 				 * value so that we don't use it
 				 */
 				lnet_net_lock(0);
-				lpni = lnet_find_peer_ni_locked(nid);
+				lpni = lnet_peer_ni_find_locked(&nid);
 				if (lpni) {
 					lnet_handle_remote_failure_locked(lpni);
 					lnet_peer_ni_decref_locked(lpni);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
