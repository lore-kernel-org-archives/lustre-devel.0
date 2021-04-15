Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27328C433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:30 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id BC76361222
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC76361222
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 34BCE32CBE4;
	Wed, 14 Apr 2021 21:03:43 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F36E332F5F5
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:53 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 8E434100F35A;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8C8DE9188E; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:17 -0400
Message-Id: <1618459361-17909-26-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 25/49] lnet: uapi: move userland only
 nidstr.h handling
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

The function cfs_expand_nidlist() no longer exist for kernel
internals. We can move the function prototype from the UAPI
header to string.h which is a libcfs user land header.
The structure netstrfns that is defined in a UAPI header
has been adding user land only handling. Additional its
use struct list_head which will confuse reviewers since
kernel developers see this as a kernel only thing.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13903
Lustre-commit: 062809b1313ac700 ("LU-13903 utils: move userland only nidstr.h handling")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/39115
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 include/linux/lnet/lib-types.h   | 15 +++++++++++++++
 include/uapi/linux/lnet/nidstr.h | 15 ---------------
 net/lnet/lnet/nidstrings.c       |  1 +
 3 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 2424993..cc451cf 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -238,6 +238,21 @@ struct lnet_test_peer {
 #define LNET_COOKIE_TYPE_BITS	2
 #define LNET_COOKIE_MASK	((1ULL << LNET_COOKIE_TYPE_BITS) - 1ULL)
 
+struct netstrfns {
+	u32	nf_type;
+	char	*nf_name;
+	char	*nf_modname;
+	void	(*nf_addr2str)(u32 addr, char *str, size_t size);
+	int	(*nf_str2addr)(const char *str, int nob, u32 *addr);
+	int	(*nf_parse_addrlist)(char *str, int len,
+				     struct list_head *list);
+	int	(*nf_print_addrlist)(char *buffer, int count,
+				     struct list_head *list);
+	int	(*nf_match_addr)(u32 addr, struct list_head *list);
+	int	(*nf_min_max)(struct list_head *nidlist, u32 *min_nid,
+			      u32 *max_nid);
+};
+
 struct lnet_ni;			/* forward ref */
 
 struct lnet_lnd {
diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index d402a6a..caf28e2 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -108,19 +108,4 @@ int cfs_match_net(__u32 net_id, __u32 net_type,
 int cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
 			      char *max_nid, __kernel_size_t nidstr_length);
 
-struct netstrfns {
-	__u32	nf_type;
-	char	*nf_name;
-	char	*nf_modname;
-	void	(*nf_addr2str)(__u32 addr, char *str, __kernel_size_t size);
-	int	(*nf_str2addr)(const char *str, int nob, __u32 *addr);
-	int	(*nf_parse_addrlist)(char *str, int len,
-				     struct list_head *list);
-	int	(*nf_print_addrlist)(char *buffer, int count,
-				     struct list_head *list);
-	int	(*nf_match_addr)(__u32 addr, struct list_head *list);
-	int	(*nf_min_max)(struct list_head *nidlist, __u32 *min_nid,
-			      __u32 *max_nid);
-};
-
 #endif /* _LNET_NIDSTRINGS_H */
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index b1cd86b..cce2ae4 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -42,6 +42,7 @@
 #include <linux/libcfs/libcfs.h>
 #include <linux/libcfs/libcfs_string.h>
 #include <uapi/linux/lnet/nidstr.h>
+#include <linux/lnet/lib-types.h>
 
 /* max value for numeric network address */
 #define MAX_NUMERIC_VALUE 0xffffffff
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
