Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0ED5BC77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:30:26 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWMF2Y7Wz21Jq;
	Sun,  9 Apr 2023 05:17:29 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWHM08yZz1yCN
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:14:07 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id EA1481008279;
 Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E8D392AB; Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:51 -0400
Message-Id: <1681042400-15491-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/40] lnet: o2iblnd: Fix key mismatch issue
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
Cc: Cyril Bordage <cbordage@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Cyril Bordage <cbordage@whamcloud.com>

If a pool memory region (mr) is mapped then unmapped without being
used, its key becomes out of sync with the RDMA subsystem.

At pool mr map time, the present code will create a local
invalidate work request (wr) using the mr's present key and then
change the mr's key.  When the mr is first used after being mapped,
the local invalidate wr will invalidate the original mr key, and
then a fast register wr is used with the modified key.  The fast
register will update the RDMA subsystem's key for the mr.

The error occurs when the mr is never used.  The next time the mr
is mapped, a local invalidate wr will again be created, but this
time it will use the mr's modified key.  The RDMA subsystem never
saw the original local invalidate, so now the RDMA subsystem's
key for the mr and o2iblnd's key for the mr are out of sync.

Fix the issue by tracking if the invalidate has been used.
Repurpose the boolean frd->frd_valid.  Presently, frd_valid is
always false.  Remove the code that used frd_valid to conditionally
split the invalidate from the fast register.  Instead, use frd_valid
to indicate when a new invalidate needs to be generated.  After a
post, evaluate if the invalidate was successfully used in the post.

These changes are only meaningful to the FRWR code path.  The failure
has only been observed when using Omni-Path Architecture.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16349
Lustre-commit: 0c93919f1375ce16d ("LU-16349 o2iblnd: Fix key mismatch issue")
Signed-off-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49714
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c    |  5 +++--
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 17 +++++++++++------
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index c1dfbe5..a7a3c79 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1584,7 +1584,8 @@ static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps,
 			goto out_middle;
 		}
 
-		frd->frd_valid = true;
+		/* indicate that the local invalidate needs to be generated */
+		frd->frd_valid = false;
 
 		list_add_tail(&frd->frd_list, &fpo->fast_reg.fpo_pool_list);
 		fpo->fast_reg.fpo_pool_size++;
@@ -1738,7 +1739,6 @@ void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status)
 
 	fps = fpo->fpo_owner;
 	if (frd) {
-		frd->frd_valid = false;
 		frd->frd_posted = false;
 		fmr->fmr_frd = NULL;
 		spin_lock(&fps->fps_lock);
@@ -1800,6 +1800,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 				u32 key = is_rx ? mr->rkey : mr->lkey;
 				struct ib_send_wr *inv_wr;
 
+				frd->frd_valid = true;
 				inv_wr = &frd->frd_inv_wr;
 				memset(inv_wr, 0, sizeof(*inv_wr));
 				inv_wr->opcode = IB_WR_LOCAL_INV;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 6fc1730..5596fd6b 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -847,12 +847,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		struct ib_send_wr *wrq = &tx->tx_wrq[0].wr;
 
 		if (frd && !frd->frd_posted) {
-			if (!frd->frd_valid) {
-				wrq = &frd->frd_inv_wr;
-				wrq->next = &frd->frd_fastreg_wr.wr;
-			} else {
-				wrq = &frd->frd_fastreg_wr.wr;
-			}
+			wrq = &frd->frd_inv_wr;
+			wrq->next = &frd->frd_fastreg_wr.wr;
 			frd->frd_fastreg_wr.wr.next = &tx->tx_wrq[0].wr;
 		}
 
@@ -866,6 +862,15 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			rc = -EINVAL;
 		else
 			rc = ib_post_send(conn->ibc_cmid->qp, wrq, &bad);
+
+		if (frd && !frd->frd_posted) {
+			/* The local invalidate becomes invalid (has been
+			 * successfully used) if the post succeeds or the
+			 * failing wr was not the invalidate.
+			 */
+			frd->frd_valid =
+				!(rc == 0 || (bad != &frd->frd_inv_wr));
+		}
 	}
 
 	conn->ibc_last_send = ktime_get();
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
