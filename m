Return-Path: <SRS0=JyPa=L7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F0BBC07E95
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:54 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F3A5161A13
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3A5161A13
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 54F19338A54;
	Wed,  7 Jul 2021 12:11:39 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8673421F8D5
 for <lustre-devel@lists.lustre.org>; Wed,  7 Jul 2021 12:11:22 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 4F243100F361;
 Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4BCC99D8BC; Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  7 Jul 2021 15:11:11 -0400
Message-Id: <1625685076-1964-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
References: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/15] lnet: add netlink infrastructure
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

Netlink was designed as a successor to ioctl as defined under
RFC 3549. There are several advantages to using netlink over
ioctls or virtual file system interfaces like proc. Collecting
proc doesn't scale well which was seen with power drain on Android
phones. A netlink implementation was developed to remove this
performance hit. Details can be read at:

https://lwn.net/Articles/406975

Besides the scaling gains the other benefit is the flexiblity
with API changes. Adding or removing information to be transmitted
doesn't require creating a new interface like ioctl do. Instead
you add new code to handle the stream of attributes read from the
socket. Lastly you can multiplex data to N listeners with groups
using one request.

This patch adds netlink handling in a generic way that can be
used by the libyaml library. This greatly lowers the barrier by
only requiring the implementor to understand the libyaml API.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9680
Lustre-commit: 3c39dac19aaf7f3f ("LU-9680 utils: add netlink infrastructure")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/34230
Reviewed-by: Petros Koutoupis <petros.koutoupis@hpe.com>
Reviewed-by: Ben Evans <beevans@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 include/linux/lnet/lib-types.h    | 15 ++++++++
 include/uapi/linux/lnet/lnet-nl.h | 67 ++++++++++++++++++++++++++++++++
 net/lnet/lnet/api-ni.c            | 81 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 163 insertions(+)
 create mode 100644 include/uapi/linux/lnet/lnet-nl.h

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index cb0a950..64d7472 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -43,7 +43,9 @@
 #include <linux/types.h>
 #include <linux/completion.h>
 #include <linux/kref.h>
+#include <net/genetlink.h>
 
+#include <uapi/linux/lnet/lnet-nl.h>
 #include <uapi/linux/lnet/lnet-types.h>
 #include <uapi/linux/lnet/lnetctl.h>
 #include <uapi/linux/lnet/lnet-dlc.h>
@@ -1280,4 +1282,17 @@ struct lnet {
 	struct list_head		ln_udsp_list;
 };
 
+static const struct nla_policy scalar_attr_policy[LN_SCALAR_CNT + 1] = {
+	[LN_SCALAR_ATTR_LIST]		= { .type = NLA_NESTED },
+	[LN_SCALAR_ATTR_LIST_SIZE]	= { .type = NLA_U16 },
+	[LN_SCALAR_ATTR_INDEX]		= { .type = NLA_U16 },
+	[LN_SCALAR_ATTR_NLA_TYPE]	= { .type = NLA_U16 },
+	[LN_SCALAR_ATTR_VALUE]		= { .type = NLA_STRING },
+	[LN_SCALAR_ATTR_KEY_FORMAT]	= { .type = NLA_U16 },
+};
+
+int lnet_genl_send_scalar_list(struct sk_buff *msg, u32 portid, u32 seq,
+			       const struct genl_family *family, int flags,
+			       u8 cmd, const struct ln_key_list *data[]);
+
 #endif
diff --git a/include/uapi/linux/lnet/lnet-nl.h b/include/uapi/linux/lnet/lnet-nl.h
new file mode 100644
index 0000000..f5bb67c
--- /dev/null
+++ b/include/uapi/linux/lnet/lnet-nl.h
@@ -0,0 +1,67 @@
+/* SPDX-License-Identifier: LGPL-2.0+ WITH Linux-syscall-note */
+/*
+ * LGPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This library is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU Lesser General Public
+ * License as published by the Free Software Foundation; either
+ * version 2.1 of the License, or (at your option) any later version.
+ *
+ * This library is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * Lesser General Public License for more details.
+ *
+ * You should have received a copy of the GNU Lesser General Public
+ * License along with this library.
+ *
+ * LGPL HEADER END
+ *
+ */
+/* Copyright (c) 2021,  UT-Battelle, LLC
+ *
+ * Author: James Simmons <jsimmons@infradead.org>
+ */
+
+#ifndef __UAPI_LNET_NL_H__
+#define __UAPI_LNET_NL_H__
+
+#include <linux/types.h>
+
+enum lnet_nl_key_format {
+	/* Is it FLOW or BLOCK */
+	LNKF_FLOW		= 1,
+	/* Is it SEQUENCE or MAPPING */
+	LNKF_MAPPING		= 2,
+	LNKF_SEQUENCE		= 4,
+};
+
+enum lnet_nl_scalar_attrs {
+	LN_SCALAR_ATTR_UNSPEC = 0,
+	LN_SCALAR_ATTR_LIST,
+
+	LN_SCALAR_ATTR_LIST_SIZE,
+	LN_SCALAR_ATTR_INDEX,
+	LN_SCALAR_ATTR_NLA_TYPE,
+	LN_SCALAR_ATTR_VALUE,
+	LN_SCALAR_ATTR_KEY_FORMAT,
+
+	__LN_SCALAR_ATTR_LAST,
+};
+
+#define LN_SCALAR_CNT (__LN_SCALAR_ATTR_LAST - 1)
+
+struct ln_key_props {
+	char			*lkp_values;
+	__u16			lkp_key_format;
+	__u16			lkp_data_type;
+};
+
+struct ln_key_list {
+	__u16			lkl_maxattr;
+	struct ln_key_props	lkl_list[];
+};
+
+#endif /* __UAPI_LNET_NL_H__ */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index e52bb41..687df3b 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -2572,6 +2572,87 @@ static void lnet_push_target_fini(void)
 	return rc;
 }
 
+static int lnet_genl_parse_list(struct sk_buff *msg,
+				const struct ln_key_list *data[], u16 idx)
+{
+	const struct ln_key_list *list = data[idx];
+	const struct ln_key_props *props;
+	struct nlattr *node;
+	u16 count;
+
+	if (!list)
+		return 0;
+
+	if (!list->lkl_maxattr)
+		return -ERANGE;
+
+	props = list->lkl_list;
+	if (!props)
+		return -EINVAL;
+
+	node = nla_nest_start(msg, LN_SCALAR_ATTR_LIST);
+	if (!node)
+		return -ENOBUFS;
+
+	for (count = 1; count <= list->lkl_maxattr; count++) {
+		struct nlattr *key = nla_nest_start(msg, count);
+
+		if (count == 1)
+			nla_put_u16(msg, LN_SCALAR_ATTR_LIST_SIZE,
+				    list->lkl_maxattr);
+
+		nla_put_u16(msg, LN_SCALAR_ATTR_INDEX, count);
+		if (props[count].lkp_values)
+			nla_put_string(msg, LN_SCALAR_ATTR_VALUE,
+				       props[count].lkp_values);
+		if (props[count].lkp_key_format)
+			nla_put_u16(msg, LN_SCALAR_ATTR_KEY_FORMAT,
+				    props[count].lkp_key_format);
+		nla_put_u16(msg, LN_SCALAR_ATTR_NLA_TYPE,
+			    props[count].lkp_data_type);
+		if (props[count].lkp_data_type == NLA_NESTED) {
+			int rc;
+
+			rc = lnet_genl_parse_list(msg, data, ++idx);
+			if (rc < 0)
+				return rc;
+		}
+
+		nla_nest_end(msg, key);
+	}
+
+	nla_nest_end(msg, node);
+	return 0;
+}
+
+int lnet_genl_send_scalar_list(struct sk_buff *msg, u32 portid, u32 seq,
+			       const struct genl_family *family, int flags,
+			       u8 cmd, const struct ln_key_list *data[])
+{
+	int rc = 0;
+	void *hdr;
+
+	if (!data[0])
+		return -EINVAL;
+
+	hdr = genlmsg_put(msg, portid, seq, family, flags, cmd);
+	if (!hdr) {
+		rc = -EMSGSIZE;
+		goto canceled;
+	}
+
+	rc = lnet_genl_parse_list(msg, data, 0);
+	if (rc < 0)
+		goto canceled;
+
+	genlmsg_end(msg, hdr);
+canceled:
+	if (rc < 0)
+		genlmsg_cancel(msg, hdr);
+	return rc;
+}
+EXPORT_SYMBOL(lnet_genl_send_scalar_list);
+
 /**
  * Initialize LNet library.
  *
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
