Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3D60BECAAA1
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:12:56 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MynZH38Rbz219m;
	Thu, 27 Oct 2022 07:07:51 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MynWw6htpz1wLC
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:05:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6E38910090F6;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 62F4DFD4E1; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:28 -0400
Message-Id: <1666879542-10737-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
References: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/15] lnet: o2iblnd: Avoid NULL md deref
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

struct lnet_msg::msg_md is NULL when a router is forwarding a
REPLY. ko2iblnd attempts to access this pointer on the receive path.
This causes a panic.

Fixes: 4c95c6b6c7 (" lnet: Replace msg_rdma_force with a new md_flag LNET_MD_FLAG_GPU.")
HPE-bug-id: LUS-11269
WC-bug-id: https://jira.whamcloud.com/browse/LU-16211
Lustre-commit: f792297212387c2ff ("LU-16211 o2iblnd: Avoid NULL md deref")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48777
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 6f04096..3e3be065 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1738,7 +1738,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	struct bio_vec *kiov = lntmsg->msg_kiov;
 	unsigned int offset = lntmsg->msg_offset;
 	unsigned int nob = lntmsg->msg_len;
-	struct lnet_libmd *payload_md = lntmsg->msg_md;
+	struct lnet_libmd *msg_md = lntmsg->msg_md;
 	struct kib_tx *tx;
 	int rc;
 
@@ -1749,7 +1749,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		goto failed_0;
 	}
 
-	tx->tx_gpu = !!(payload_md->md_flags & LNET_MD_FLAG_GPU);
+	tx->tx_gpu = msg_md ? (msg_md->md_flags & LNET_MD_FLAG_GPU) : 0;
 	if (!nob)
 		rc = 0;
 	else
@@ -1847,7 +1847,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	case IBLND_MSG_PUT_REQ: {
 		struct kib_msg *txmsg;
 		struct kib_rdma_desc *rd;
-		struct lnet_libmd *payload_md = lntmsg->msg_md;
+		struct lnet_libmd *msg_md = lntmsg->msg_md;
 
 		ibprm_cookie = rxmsg->ibm_u.putreq.ibprm_cookie;
 
@@ -1867,7 +1867,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			break;
 		}
 
-		tx->tx_gpu = !!(payload_md->md_flags & LNET_MD_FLAG_GPU);
+		tx->tx_gpu = msg_md ? (msg_md->md_flags & LNET_MD_FLAG_GPU) : 0;
+
 		txmsg = tx->tx_msg;
 		rd = &txmsg->ibm_u.putack.ibpam_rd;
 		rc = kiblnd_setup_rd_kiov(ni, tx, rd,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
