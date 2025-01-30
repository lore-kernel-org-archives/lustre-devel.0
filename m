Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 03564C0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:33:17 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLf74vkGz21YC;
	Thu, 30 Jan 2025 06:15:43 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLYW4B5Sz1xGG
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:11:43 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id DED7D18232E;
 Thu, 30 Jan 2025 09:11:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id D7DF7106BE18; Thu, 30 Jan 2025 09:11:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:10:53 -0500
Message-ID: <20250130141115.950749-4-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 03/25] lustre: introduce class_parse_nid()
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
Cc: Frank Sehr <fsehr@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

class_parse_nid() and class_parse_nid_quiet() can be used to parse
struct lnet_nid including nids with ipv6 addresses.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 163331cb81c9f7d7a ("LU-10391 lustre: introduce class_parse_nid()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50089
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h   |  2 ++
 fs/lustre/obdclass/obd_config.c | 28 ++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index eef9bfb91f4d..e91335e8cd70 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -146,6 +146,8 @@ struct cfg_interop_param *class_find_old_param(const char *param,
 int class_get_next_param(char **params, char *copy);
 int class_parse_nid4(char *buf, lnet_nid_t *nid4, char **endh);
 int class_parse_nid4_quiet(char *buf, lnet_nid_t *nid4, char **endh);
+int class_parse_nid(char *buf, struct lnet_nid *nid, char **endh);
+int class_parse_nid_quiet(char *buf, struct lnet_nid *nid, char **endh);
 int class_parse_net(char *buf, u32 *net, char **endh);
 int class_match_net(char *buf, char *key, u32 net);
 
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index eb14ca807f34..cc7810cae659 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -165,6 +165,18 @@ static int parse_nid4(char *buf, void *value, int quiet)
 	return -EINVAL;
 }
 
+static int parse_nid(char *buf, void *value, int quiet)
+{
+	struct lnet_nid *nid = value;
+
+	if (libcfs_strnid(nid, buf) == 0)
+		return 0;
+
+	if (!quiet)
+		LCONSOLE_ERROR_MSG(0x159, "Can't parse NID '%s'\n", buf);
+	return -EINVAL;
+}
+
 static int parse_net(char *buf, void *value)
 {
 	u32 *net = value;
@@ -176,6 +188,7 @@ static int parse_net(char *buf, void *value)
 
 enum {
 	CLASS_PARSE_NID4 = 1,
+	CLASS_PARSE_NID,
 	CLASS_PARSE_NET,
 };
 
@@ -211,6 +224,9 @@ static int class_parse_value(char *buf, int opc, void *value, char **endh,
 	case CLASS_PARSE_NID4:
 		rc = parse_nid4(buf, value, quiet);
 		break;
+	case CLASS_PARSE_NID:
+		rc = parse_nid(buf, value, quiet);
+		break;
 	case CLASS_PARSE_NET:
 		rc = parse_net(buf, value);
 		break;
@@ -235,6 +251,18 @@ int class_parse_nid4_quiet(char *buf, lnet_nid_t *nid4, char **endh)
 }
 EXPORT_SYMBOL(class_parse_nid4_quiet);
 
+int class_parse_nid(char *buf, struct lnet_nid *nid, char **endh)
+{
+	return class_parse_value(buf, CLASS_PARSE_NID, (void *)nid, endh, 0);
+}
+EXPORT_SYMBOL(class_parse_nid);
+
+int class_parse_nid_quiet(char *buf, struct lnet_nid *nid, char **endh)
+{
+	return class_parse_value(buf, CLASS_PARSE_NID, (void *)nid, endh, 1);
+}
+EXPORT_SYMBOL(class_parse_nid_quiet);
+
 char *lustre_cfg_string(struct lustre_cfg *lcfg, u32 index)
 {
 	char *s;
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
