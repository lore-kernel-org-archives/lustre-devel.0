Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBB55C433ED
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7E69161396
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E69161396
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E027A3283A0;
	Mon,  5 Apr 2021 00:51:47 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 13F1221F858
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:22 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id BBDF66D1;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B8B7A90AAC; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:43 -0400
Message-Id: <1617583870-32029-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/41] lnet: Add the kernel level Marshalling
 API
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

Given a UDSP, Marshal the UDSP pointed to by udsp
into the memory block that is allocated from userspace.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9121
Lustre-commit: cd0ef3165e1d1b5f ("LU-9121 lnet: Add the kernel level Marshalling API")
Signed-off-by: Sonia Sharma <sharmaso@whamcloud.com>
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34403
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/udsp.h |  13 +++
 net/lnet/lnet/udsp.c      | 214 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 227 insertions(+)

diff --git a/include/linux/lnet/udsp.h b/include/linux/lnet/udsp.h
index 265cb42..0cf630f 100644
--- a/include/linux/lnet/udsp.h
+++ b/include/linux/lnet/udsp.h
@@ -114,4 +114,17 @@
  */
 void lnet_udsp_destroy(bool shutdown);
 
+/**
+ * lnet_get_udsp_size
+ *	Return the size needed to store the marshalled UDSP
+ */
+size_t lnet_get_udsp_size(struct lnet_udsp *udsp);
+
+/**
+ * lnet_udsp_marshal
+ *	Marshal the udsp into the bulk memory provided.
+ *	Return success/failure.
+ */
+int lnet_udsp_marshal(struct lnet_udsp *udsp,
+		      struct lnet_ioctl_udsp *ioc_udsp);
 #endif /* UDSP_H */
diff --git a/net/lnet/lnet/udsp.c b/net/lnet/lnet/udsp.c
index 85e31fe..499035d 100644
--- a/net/lnet/lnet/udsp.c
+++ b/net/lnet/lnet/udsp.c
@@ -1049,3 +1049,217 @@ struct lnet_udsp *
 		lnet_udsp_free(udsp);
 	}
 }
+
+static size_t
+lnet_size_marshaled_nid_descr(struct lnet_ud_nid_descr *descr)
+{
+	struct cfs_expr_list *expr;
+	int expr_count = 0;
+	int range_count = 0;
+	size_t size = sizeof(struct lnet_ioctl_udsp_descr);
+
+	if (!lnet_udsp_criteria_present(descr))
+		return size;
+
+	/* we always have one net expression */
+	if (!list_empty(&descr->ud_net_id.udn_net_num_range)) {
+		expr = list_first_entry(&descr->ud_net_id.udn_net_num_range,
+					struct cfs_expr_list, el_link);
+
+		/* count the number of cfs_range_expr in the net expression */
+		range_count = lnet_get_list_len(&expr->el_exprs);
+	}
+
+	/* count the number of cfs_range_expr in the address expressions */
+	list_for_each_entry(expr, &descr->ud_addr_range, el_link) {
+		expr_count++;
+		range_count += lnet_get_list_len(&expr->el_exprs);
+	}
+
+	size += (sizeof(struct lnet_expressions) * expr_count);
+	size += (sizeof(struct lnet_range_expr) * range_count);
+
+	return size;
+}
+
+size_t
+lnet_get_udsp_size(struct lnet_udsp *udsp)
+{
+	size_t size = sizeof(struct lnet_ioctl_udsp);
+
+	size += lnet_size_marshaled_nid_descr(&udsp->udsp_src);
+	size += lnet_size_marshaled_nid_descr(&udsp->udsp_dst);
+	size += lnet_size_marshaled_nid_descr(&udsp->udsp_rte);
+
+	CDEBUG(D_NET, "get udsp (%p) size: %d\n", udsp, (int)size);
+
+	return size;
+}
+
+static int
+copy_exprs(struct cfs_expr_list *expr, void __user **bulk,
+	   u32 *bulk_size)
+{
+	struct cfs_range_expr *range;
+	struct lnet_range_expr range_expr;
+
+	/* copy over the net range expressions to the bulk */
+	list_for_each_entry(range, &expr->el_exprs, re_link) {
+		range_expr.re_lo = range->re_lo;
+		range_expr.re_hi = range->re_hi;
+		range_expr.re_stride = range->re_stride;
+		CDEBUG(D_NET, "Copy Range %u:%u:%u\n",
+		       range_expr.re_lo, range_expr.re_hi,
+		       range_expr.re_stride);
+		if (copy_to_user(*bulk, &range_expr, sizeof(range_expr))) {
+			CDEBUG(D_NET, "Failed to copy range_expr\n");
+			return -EFAULT;
+		}
+		*bulk += sizeof(range_expr);
+		*bulk_size -= sizeof(range_expr);
+	}
+
+	return 0;
+}
+
+static int
+copy_nid_range(struct lnet_ud_nid_descr *nid_descr, char *type,
+	       void **bulk, u32 *bulk_size)
+{
+	struct lnet_ioctl_udsp_descr ioc_udsp_descr;
+	struct cfs_expr_list *expr;
+	struct lnet_expressions ioc_expr;
+	int expr_count;
+	int net_expr_count;
+	int rc;
+
+	memset(&ioc_udsp_descr, 0, sizeof(ioc_udsp_descr));
+	ioc_udsp_descr.iud_src_hdr.ud_descr_type = *(u32 *)type;
+
+	/* if criteria not present, copy over the static part of the NID
+	 * descriptor
+	 */
+	if (!lnet_udsp_criteria_present(nid_descr)) {
+		CDEBUG(D_NET, "Descriptor %u:%u:%u:%u\n",
+		       ioc_udsp_descr.iud_src_hdr.ud_descr_type,
+		       ioc_udsp_descr.iud_src_hdr.ud_descr_count,
+		       ioc_udsp_descr.iud_net.ud_net_type,
+		       ioc_udsp_descr.iud_net.ud_net_num_expr.le_count);
+		if (copy_to_user(*bulk, &ioc_udsp_descr,
+				 sizeof(ioc_udsp_descr))) {
+			CDEBUG(D_NET, "failed to copy ioc_udsp_descr\n");
+			return -EFAULT;
+		}
+		*bulk += sizeof(ioc_udsp_descr);
+		*bulk_size -= sizeof(ioc_udsp_descr);
+		return 0;
+	}
+
+	expr_count = lnet_get_list_len(&nid_descr->ud_addr_range);
+
+	/* copy the net information */
+	if (!list_empty(&nid_descr->ud_net_id.udn_net_num_range)) {
+		expr = list_first_entry(&nid_descr->ud_net_id.udn_net_num_range,
+					struct cfs_expr_list, el_link);
+		net_expr_count = lnet_get_list_len(&expr->el_exprs);
+	} else {
+		net_expr_count = 0;
+	}
+
+	/* set the total expression count */
+	ioc_udsp_descr.iud_src_hdr.ud_descr_count = expr_count;
+	ioc_udsp_descr.iud_net.ud_net_type =
+		nid_descr->ud_net_id.udn_net_type;
+	ioc_udsp_descr.iud_net.ud_net_num_expr.le_count = net_expr_count;
+
+	CDEBUG(D_NET, "Descriptor %u:%u:%u:%u\n",
+	       ioc_udsp_descr.iud_src_hdr.ud_descr_type,
+	       ioc_udsp_descr.iud_src_hdr.ud_descr_count,
+	       ioc_udsp_descr.iud_net.ud_net_type,
+	       ioc_udsp_descr.iud_net.ud_net_num_expr.le_count);
+
+	/* copy over the header info to the bulk */
+	if (copy_to_user(*bulk, &ioc_udsp_descr, sizeof(ioc_udsp_descr))) {
+		CDEBUG(D_NET, "Failed to copy data\n");
+		return -EFAULT;
+	}
+	*bulk += sizeof(ioc_udsp_descr);
+	*bulk_size -= sizeof(ioc_udsp_descr);
+
+	/* copy over the net num expression if it exists */
+	if (net_expr_count) {
+		rc = copy_exprs(expr, bulk, bulk_size);
+		if (rc)
+			return rc;
+	}
+
+	/* copy the address range */
+	list_for_each_entry(expr, &nid_descr->ud_addr_range, el_link) {
+		ioc_expr.le_count = lnet_get_list_len(&expr->el_exprs);
+		if (copy_to_user(*bulk, &ioc_expr, sizeof(ioc_expr))) {
+			CDEBUG(D_NET, "failex to copy ioc_expr\n");
+			return -EFAULT;
+		}
+		*bulk += sizeof(ioc_expr);
+		*bulk_size -= sizeof(ioc_expr);
+
+		rc = copy_exprs(expr, bulk, bulk_size);
+		if (rc)
+			return rc;
+	}
+
+	return 0;
+}
+
+int
+lnet_udsp_marshal(struct lnet_udsp *udsp, struct lnet_ioctl_udsp *ioc_udsp)
+{
+	int rc = -ENOMEM;
+	void __user *bulk;
+	u32 bulk_size;
+
+	if (!ioc_udsp)
+		return -EINVAL;
+
+	bulk = ioc_udsp->iou_bulk;
+	bulk_size = ioc_udsp->iou_hdr.ioc_len +
+	  ioc_udsp->iou_bulk_size;
+
+	CDEBUG(D_NET, "marshal udsp (%p)\n", udsp);
+	CDEBUG(D_NET, "MEM -----> bulk: %p:0x%x\n", bulk, bulk_size);
+	/* make sure user space allocated enough buffer to marshal the
+	 * udsp
+	 */
+	if (bulk_size != lnet_get_udsp_size(udsp)) {
+		rc = -ENOSPC;
+		goto fail;
+	}
+
+	ioc_udsp->iou_idx = udsp->udsp_idx;
+	ioc_udsp->iou_action_type = udsp->udsp_action_type;
+	ioc_udsp->iou_action.priority = udsp->udsp_action.udsp_priority;
+
+	bulk_size -= sizeof(*ioc_udsp);
+
+	rc = copy_nid_range(&udsp->udsp_src, "SRC", &bulk, &bulk_size);
+	if (rc)
+		goto fail;
+
+	rc = copy_nid_range(&udsp->udsp_dst, "DST", &bulk, &bulk_size);
+	if (rc)
+		goto fail;
+
+	rc = copy_nid_range(&udsp->udsp_rte, "RTE", &bulk, &bulk_size);
+	if (rc)
+		goto fail;
+
+	CDEBUG(D_NET, "MEM <----- bulk: %p\n", bulk);
+
+	/* we should've consumed the entire buffer */
+	LASSERT(bulk_size == 0);
+	return 0;
+
+fail:
+	CERROR("Failed to marshal udsp: %d\n", rc);
+	return rc;
+}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
