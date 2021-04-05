Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B2CBC43460
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:14 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 15A3E61396
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15A3E61396
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 06DD1328C47;
	Mon,  5 Apr 2021 00:51:51 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5D59821F897
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:22 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id C005B6D8;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BC1EA90AAE; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:44 -0400
Message-Id: <1617583870-32029-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/41] lnet: Add the kernel level
 De-Marshalling API
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

From: Sonia Sharma <sharmaso@whamcloud.com>

Given a bulk allocated from userspace containing a
single UDSP, De-Marshalling API demarshals it
and populate the provided udsp structure.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9121
Lustre-commit: 764d16bf7803908 ("LU-9121 lnet: Add the kernel level De-Marshalling API")
Signed-off-by: Sonia Sharma <sharmaso@whamcloud.com>
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34488
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/udsp.h |   7 ++
 net/lnet/lnet/udsp.c      | 202 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 208 insertions(+), 1 deletion(-)

diff --git a/include/linux/lnet/udsp.h b/include/linux/lnet/udsp.h
index 0cf630f..3683d43 100644
--- a/include/linux/lnet/udsp.h
+++ b/include/linux/lnet/udsp.h
@@ -127,4 +127,11 @@
  */
 int lnet_udsp_marshal(struct lnet_udsp *udsp,
 		      struct lnet_ioctl_udsp *ioc_udsp);
+/**
+ * lnet_udsp_demarshal_add
+ *	Given a bulk containing a single UDSP,
+ *	demarshal and populate a udsp structure then add policy
+ */
+int lnet_udsp_demarshal_add(void *bulk, u32 bulk_size);
+
 #endif /* UDSP_H */
diff --git a/net/lnet/lnet/udsp.c b/net/lnet/lnet/udsp.c
index 499035d..f686ff2 100644
--- a/net/lnet/lnet/udsp.c
+++ b/net/lnet/lnet/udsp.c
@@ -1124,7 +1124,7 @@ struct lnet_udsp *
 
 static int
 copy_nid_range(struct lnet_ud_nid_descr *nid_descr, char *type,
-	       void **bulk, u32 *bulk_size)
+	       void __user **bulk, u32 *bulk_size)
 {
 	struct lnet_ioctl_udsp_descr ioc_udsp_descr;
 	struct cfs_expr_list *expr;
@@ -1263,3 +1263,203 @@ struct lnet_udsp *
 	CERROR("Failed to marshal udsp: %d\n", rc);
 	return rc;
 }
+
+static void
+copy_range_info(void **bulk, void **buf, struct list_head *list,
+		int count)
+{
+	struct lnet_range_expr *range_expr;
+	struct cfs_range_expr *range;
+	struct cfs_expr_list *exprs;
+	int range_count = count;
+	int i;
+
+	if (range_count == 0)
+		return;
+
+	if (range_count == -1) {
+		struct lnet_expressions *e;
+
+		e = *bulk;
+		range_count = e->le_count;
+		*bulk += sizeof(*e);
+	}
+
+	exprs = *buf;
+	INIT_LIST_HEAD(&exprs->el_link);
+	INIT_LIST_HEAD(&exprs->el_exprs);
+	list_add_tail(&exprs->el_link, list);
+	*buf += sizeof(*exprs);
+
+	for (i = 0; i < range_count; i++) {
+		range_expr = *bulk;
+		range = *buf;
+		INIT_LIST_HEAD(&range->re_link);
+		range->re_lo = range_expr->re_lo;
+		range->re_hi = range_expr->re_hi;
+		range->re_stride = range_expr->re_stride;
+		CDEBUG(D_NET, "Copy Range %u:%u:%u\n",
+		       range->re_lo,
+		       range->re_hi,
+		       range->re_stride);
+		list_add_tail(&range->re_link, &exprs->el_exprs);
+		*bulk += sizeof(*range_expr);
+		*buf += sizeof(*range);
+	}
+}
+
+static int
+copy_ioc_udsp_descr(struct lnet_ud_nid_descr *nid_descr, char *type,
+		    void **bulk, u32 *bulk_size)
+{
+	struct lnet_ioctl_udsp_descr *ioc_nid = *bulk;
+	struct lnet_expressions *exprs;
+	u32 descr_type;
+	int expr_count = 0;
+	int range_count = 0;
+	int i;
+	u32 size;
+	int remaining_size = *bulk_size;
+	void *tmp = *bulk;
+	u32 alloc_size;
+	void *buf;
+	size_t range_expr_s = sizeof(struct lnet_range_expr);
+	size_t lnet_exprs_s = sizeof(struct lnet_expressions);
+
+	CDEBUG(D_NET, "%s: bulk = %p:%u\n", type, *bulk, *bulk_size);
+
+	/* criteria not present, skip over the static part of the
+	 * bulk, which is included for each NID descriptor
+	 */
+	if (ioc_nid->iud_net.ud_net_type == 0) {
+		remaining_size -= sizeof(*ioc_nid);
+		if (remaining_size < 0) {
+			CERROR("Truncated userspace udsp buffer given\n");
+			return -EINVAL;
+		}
+		*bulk += sizeof(*ioc_nid);
+		*bulk_size = remaining_size;
+		return 0;
+	}
+
+	descr_type = ioc_nid->iud_src_hdr.ud_descr_type;
+	if (descr_type != *(u32 *)type) {
+		CERROR("Bad NID descriptor type. Expected %s, given %c%c%c\n",
+		       type, (u8)descr_type, (u8)(descr_type << 4),
+		       (u8)(descr_type << 8));
+		return -EINVAL;
+	}
+
+	/* calculate the total size to verify we have enough buffer.
+	 * Start of by finding how many ranges there are for the net
+	 * expression.
+	 */
+	range_count = ioc_nid->iud_net.ud_net_num_expr.le_count;
+	size = sizeof(*ioc_nid) + (range_count * range_expr_s);
+	remaining_size -= size;
+	if (remaining_size < 0) {
+		CERROR("Truncated userspace udsp buffer given\n");
+		return -EINVAL;
+	}
+
+	CDEBUG(D_NET, "Total net num ranges in %s: %d:%u\n", type,
+	       range_count, size);
+	/* the number of expressions for the NID. IE 4 for IP, 1 for GNI */
+	expr_count = ioc_nid->iud_src_hdr.ud_descr_count;
+	CDEBUG(D_NET, "addr as %d exprs\n", expr_count);
+	/* point tmp to the beginning of the NID expressions */
+	tmp += size;
+	for (i = 0; i < expr_count; i++) {
+		/* get the number of ranges per expression */
+		exprs = tmp;
+		range_count += exprs->le_count;
+		size = (range_expr_s * exprs->le_count) + lnet_exprs_s;
+		remaining_size -= size;
+		CDEBUG(D_NET, "expr %d:%d:%u:%d:%d\n", i, exprs->le_count,
+		       size, remaining_size, range_count);
+		if (remaining_size < 0) {
+			CERROR("Truncated userspace udsp buffer given\n");
+			return -EINVAL;
+		}
+		tmp += size;
+	}
+
+	*bulk_size = remaining_size;
+
+	/* copy over the net type */
+	nid_descr->ud_net_id.udn_net_type = ioc_nid->iud_net.ud_net_type;
+
+	CDEBUG(D_NET, "%u\n", nid_descr->ud_net_id.udn_net_type);
+
+	/* allocate the total memory required to copy this NID descriptor */
+	alloc_size = (sizeof(struct cfs_expr_list) * (expr_count + 1)) +
+		     (sizeof(struct cfs_range_expr) * (range_count));
+	buf = kzalloc(alloc_size, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	/* store the amount of memory allocated so we can free it later on */
+	nid_descr->ud_mem_size = alloc_size;
+
+	/* copy over the net number range */
+	range_count = ioc_nid->iud_net.ud_net_num_expr.le_count;
+	*bulk += sizeof(*ioc_nid);
+	CDEBUG(D_NET, "bulk = %p\n", *bulk);
+	copy_range_info(bulk, &buf, &nid_descr->ud_net_id.udn_net_num_range,
+			range_count);
+	CDEBUG(D_NET, "bulk = %p\n", *bulk);
+
+	/* copy over the NID descriptor */
+	for (i = 0; i < expr_count; i++) {
+		copy_range_info(bulk, &buf, &nid_descr->ud_addr_range, -1);
+		CDEBUG(D_NET, "bulk = %p\n", *bulk);
+	}
+
+	return 0;
+}
+
+int
+lnet_udsp_demarshal_add(void *bulk, u32 bulk_size)
+{
+	struct lnet_ioctl_udsp *ioc_udsp;
+	struct lnet_udsp *udsp;
+	int rc = -ENOMEM;
+	int idx;
+
+	if (bulk_size < sizeof(*ioc_udsp))
+		return -ENOSPC;
+
+	udsp = lnet_udsp_alloc();
+	if (!udsp)
+		return rc;
+
+	ioc_udsp = bulk;
+
+	udsp->udsp_action_type = ioc_udsp->iou_action_type;
+	udsp->udsp_action.udsp_priority = ioc_udsp->iou_action.priority;
+	idx = ioc_udsp->iou_idx;
+
+	CDEBUG(D_NET, "demarshal descr %u:%u:%d:%u\n", udsp->udsp_action_type,
+	       udsp->udsp_action.udsp_priority, idx, bulk_size);
+
+	bulk += sizeof(*ioc_udsp);
+	bulk_size -= sizeof(*ioc_udsp);
+
+	rc = copy_ioc_udsp_descr(&udsp->udsp_src, "SRC", &bulk, &bulk_size);
+	if (rc < 0)
+		goto free_udsp;
+
+	rc = copy_ioc_udsp_descr(&udsp->udsp_dst, "DST", &bulk, &bulk_size);
+	if (rc < 0)
+		goto free_udsp;
+
+	rc = copy_ioc_udsp_descr(&udsp->udsp_rte, "RTE", &bulk, &bulk_size);
+	if (rc < 0)
+		goto free_udsp;
+
+	return lnet_udsp_add_policy(udsp, idx);
+
+free_udsp:
+	lnet_udsp_free(udsp);
+	return rc;
+}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
