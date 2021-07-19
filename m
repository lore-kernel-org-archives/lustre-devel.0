Return-Path: <SRS0=HxeM=ML=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01058C07E9D
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:54 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B2E916113B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2E916113B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 49C7934FA9D;
	Mon, 19 Jul 2021 05:32:35 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1DC4034F962
 for <lustre-devel@lists.lustre.org>; Mon, 19 Jul 2021 05:32:20 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A98A26C7;
 Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A210BBD1CB; Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 19 Jul 2021 08:32:06 -0400
Message-Id: <1626697933-6971-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
References: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/18] lnet: RMDA infrastructure updates
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
Cc: Amir Shehata <ashehata@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Amir Shehata <ashehata@whamcloud.com>

Add infrastructure to force RDMA for payloads < 4K.
Add infrastructure to extract the first page in a
payload. Useful for determining the type of the payload
to be transmitted.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14798
Lustre-commit: 7ac839837c1c6cd1f ("LU-14798 lnet: RMDA infrastructure updates")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Lustre-change: https://review.whamcloud.com/37453
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Whamcloud-bug-id: EX-773
Reviewed-on: https://review.whamcloud.com/44109
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h       |  1 +
 include/linux/lnet/lib-types.h      |  2 ++
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c |  4 ++--
 net/lnet/lnet/lib-md.c              | 29 +++++++++++++++++++++++------
 4 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 6b9e926..f56ecab 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -711,6 +711,7 @@ void lnet_copy_kiov2iter(struct iov_iter *to,
 void lnet_md_unlink(struct lnet_libmd *md);
 void lnet_md_deconstruct(struct lnet_libmd *lmd, struct lnet_event *ev);
 struct page *lnet_kvaddr_to_page(unsigned long vaddr);
+struct page *lnet_get_first_page(struct lnet_libmd *md, unsigned int offset);
 int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset);
 
 unsigned int lnet_get_lnd_timeout(void);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 64d7472..e951e02 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -122,6 +122,8 @@ struct lnet_msg {
 	enum lnet_msg_hstatus	msg_health_status;
 	/* This is a recovery message */
 	bool			msg_recovery;
+	/* force an RDMA even if the message size is < 4K */
+	bool			msg_rdma_force;
 	/* the number of times a transmission has been retried */
 	int			msg_retry_count;
 	/* flag to indicate that we do not want to resend this message */
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index ec0d05a..c66acc51 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1553,7 +1553,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 		/* is the REPLY message too small for RDMA? */
 		nob = offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[lntmsg->msg_md->md_length]);
-		if (nob <= IBLND_MSG_SIZE)
+		if (nob <= IBLND_MSG_SIZE && !lntmsg->msg_rdma_force)
 			break;		/* send IMMEDIATE */
 
 		tx = kiblnd_get_idle_tx(ni, target.nid);
@@ -1599,7 +1599,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	case LNET_MSG_PUT:
 		/* Is the payload small enough not to need RDMA? */
 		nob = offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[payload_nob]);
-		if (nob <= IBLND_MSG_SIZE)
+		if (nob <= IBLND_MSG_SIZE && !lntmsg->msg_rdma_force)
 			break;			/* send IMMEDIATE */
 
 		tx = kiblnd_get_idle_tx(ni, target.nid);
diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index fbee4e0..affa921 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -87,9 +87,9 @@ struct page *lnet_kvaddr_to_page(unsigned long vaddr)
 }
 EXPORT_SYMBOL(lnet_kvaddr_to_page);
 
-int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
+struct page *
+lnet_get_first_page(struct lnet_libmd *md, unsigned int offset)
 {
-	int cpt = CFS_CPT_ANY;
 	unsigned int niov;
 	struct bio_vec *kiov;
 
@@ -102,7 +102,7 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 		md = lnet_handle2md(&md->md_bulk_handle);
 
 	if (!md || md->md_niov == 0)
-		return CFS_CPT_ANY;
+		return NULL;
 
 	kiov = md->md_kiov;
 	niov = md->md_niov;
@@ -113,12 +113,29 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 		kiov++;
 		if (niov == 0) {
 			CERROR("offset %d goes beyond iov\n", offset);
-			goto out;
+			return NULL;
 		}
 	}
 
-	cpt = cfs_cpt_of_node(lnet_cpt_table(),
-			      page_to_nid(kiov->bv_page));
+	return kiov->bv_page;
+}
+
+int
+lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
+{
+	struct page *page;
+	int cpt = CFS_CPT_ANY;
+
+	page = lnet_get_first_page(md, offset);
+	if (!page) {
+		CDEBUG(D_NET,
+		       "Couldn't resolve first page of md %p with offset %u\n",
+		       md, offset);
+		goto out;
+	}
+
+	cpt = cfs_cpt_of_node(lnet_cpt_table(), page_to_nid(page));
+
 out:
 	return cpt;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
