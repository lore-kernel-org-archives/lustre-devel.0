Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 942ACC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:55 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 01D7221C93C;
	Sun, 28 Nov 2021 15:28:37 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AC8022010B6
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:28:03 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id C6972274;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C3257C1AC4; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:53 -0500
Message-Id: <1638142074-5945-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/19] lnet: Netlink improvements
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

With the expansion of the use of Netlink several issues have been
encountered. This patch fixes many of the issues. The issues are:

1) Fix idx handling in lnet_genl_parse_list() function. It needs
   to always been incremented. Some renaming suggestion for
   enum lnet_nl_scalar_attrs from Neil. New LN_SCALAR_ATTR_INT_VALUE
   to allow pushing integers as well as strings from userspace.

2) Create struct genl_filter_list which will be used to create
   a list of items to pass back to userland. This will be a common
   setup.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9680
Lustre-commit: 82835a1952dcb37e8 ("LU-9680 net: Netlink improvements")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/44358
Reviewed-by: Ben Evans <beevans@whamcloud.com>
Reviewed-by: Petros Koutoupis <petros.koutoupis@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 include/linux/lnet/lib-types.h    |  8 +++++++-
 include/uapi/linux/lnet/lnet-nl.h | 29 +++++++++++++++++++++++++----
 net/lnet/lnet/api-ni.c            |  9 +++++----
 3 files changed, 37 insertions(+), 9 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 628d133..7631044 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -1320,7 +1320,13 @@ struct lnet {
 	struct list_head		ln_udsp_list;
 };
 
-static const struct nla_policy scalar_attr_policy[LN_SCALAR_CNT + 1] = {
+struct genl_filter_list {
+	struct list_head	 lp_list;
+	void			*lp_cursor;
+	bool			 lp_first;
+};
+
+static const struct nla_policy scalar_attr_policy[LN_SCALAR_MAX + 1] = {
 	[LN_SCALAR_ATTR_LIST]		= { .type = NLA_NESTED },
 	[LN_SCALAR_ATTR_LIST_SIZE]	= { .type = NLA_U16 },
 	[LN_SCALAR_ATTR_INDEX]		= { .type = NLA_U16 },
diff --git a/include/uapi/linux/lnet/lnet-nl.h b/include/uapi/linux/lnet/lnet-nl.h
index f5bb67c..83f6e27 100644
--- a/include/uapi/linux/lnet/lnet-nl.h
+++ b/include/uapi/linux/lnet/lnet-nl.h
@@ -38,23 +38,44 @@ enum lnet_nl_key_format {
 	LNKF_SEQUENCE		= 4,
 };
 
+/**
+ * enum lnet_nl_scalar_attrs		- scalar LNet netlink attributes used
+ *					  to compose messages for sending or
+ *					  receiving.
+ *
+ * @LN_SCALAR_ATTR_UNSPEC:		unspecified attribute to catch errors
+ * @LN_SCALAR_ATTR_PAD:			padding for 64-bit attributes, ignore
+ *
+ * @LN_SCALAR_ATTR_LIST:		List of scalar attributes (NLA_NESTED)
+ * @LN_SCALAR_ATTR_LIST_SIZE:		Number of items in scalar list (NLA_U16)
+ * @LN_SCALAR_ATTR_INDEX:		True Netlink attr value (NLA_U16)
+ * @LN_SCALAR_ATTR_NLA_TYPE:		Data format for value part of the pair
+ *					(NLA_U16)
+ * @LN_SCALAR_ATTR_VALUE:		String value of key part of the pair.
+ *					(NLA_NUL_STRING)
+ * @LN_SCALAR_ATTR_INT_VALUE:		Numeric value of key part of the pair.
+ *					(NLA_S64)
+ * @LN_SCALAR_ATTR_KEY_FORMAT:		LNKF_* format of the key value pair.
+ */
 enum lnet_nl_scalar_attrs {
 	LN_SCALAR_ATTR_UNSPEC = 0,
-	LN_SCALAR_ATTR_LIST,
+	LN_SCALAR_ATTR_PAD = LN_SCALAR_ATTR_UNSPEC,
 
+	LN_SCALAR_ATTR_LIST,
 	LN_SCALAR_ATTR_LIST_SIZE,
 	LN_SCALAR_ATTR_INDEX,
 	LN_SCALAR_ATTR_NLA_TYPE,
 	LN_SCALAR_ATTR_VALUE,
+	LN_SCALAR_ATTR_INT_VALUE,
 	LN_SCALAR_ATTR_KEY_FORMAT,
 
-	__LN_SCALAR_ATTR_LAST,
+	__LN_SCALAR_ATTR_MAX_PLUS_ONE,
 };
 
-#define LN_SCALAR_CNT (__LN_SCALAR_ATTR_LAST - 1)
+#define LN_SCALAR_MAX (__LN_SCALAR_ATTR_MAX_PLUS_ONE - 1)
 
 struct ln_key_props {
-	char			*lkp_values;
+	char			*lkp_value;
 	__u16			lkp_key_format;
 	__u16			lkp_data_type;
 };
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 9d9d0e6..3ed3f0b 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -2670,9 +2670,9 @@ static int lnet_genl_parse_list(struct sk_buff *msg,
 				    list->lkl_maxattr);
 
 		nla_put_u16(msg, LN_SCALAR_ATTR_INDEX, count);
-		if (props[count].lkp_values)
+		if (props[count].lkp_value)
 			nla_put_string(msg, LN_SCALAR_ATTR_VALUE,
-				       props[count].lkp_values);
+				       props[count].lkp_value);
 		if (props[count].lkp_key_format)
 			nla_put_u16(msg, LN_SCALAR_ATTR_KEY_FORMAT,
 				    props[count].lkp_key_format);
@@ -2684,13 +2684,14 @@ static int lnet_genl_parse_list(struct sk_buff *msg,
 			rc = lnet_genl_parse_list(msg, data, ++idx);
 			if (rc < 0)
 				return rc;
+			idx = rc;
 		}
 
 		nla_nest_end(msg, key);
 	}
 
 	nla_nest_end(msg, node);
-	return 0;
+	return idx;
 }
 
 int lnet_genl_send_scalar_list(struct sk_buff *msg, u32 portid, u32 seq,
@@ -2717,7 +2718,7 @@ int lnet_genl_send_scalar_list(struct sk_buff *msg, u32 portid, u32 seq,
 canceled:
 	if (rc < 0)
 		genlmsg_cancel(msg, hdr);
-	return rc;
+	return rc > 0 ? 0 : rc;
 }
 EXPORT_SYMBOL(lnet_genl_send_scalar_list);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
