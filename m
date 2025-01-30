Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3A6E6C0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:25:46 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLcm5qlZz213R;
	Thu, 30 Jan 2025 06:14:32 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLYv4tbWz1xh7
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:12:03 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 17AA8899AD8;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 14BA7106BE16; Thu, 30 Jan 2025 09:11:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:11:04 -0500
Message-ID: <20250130141115.950749-15-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 14/25] lustre: obdclass: remove
 class_parse_nid4()
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

class_parse_nid4() not used any more.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 89aac3d3b39f68982 ("LU-10391 obdclass: remove class_parse_nid4()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50095
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h   |  4 ----
 fs/lustre/obdclass/obd_config.c | 31 +------------------------------
 2 files changed, 1 insertion(+), 34 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index e91335e8cd70..06dfcf9bbd9e 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -144,12 +144,8 @@ int class_find_param(char *buf, char *key, char **valp);
 struct cfg_interop_param *class_find_old_param(const char *param,
 					       struct cfg_interop_param *ptr);
 int class_get_next_param(char **params, char *copy);
-int class_parse_nid4(char *buf, lnet_nid_t *nid4, char **endh);
-int class_parse_nid4_quiet(char *buf, lnet_nid_t *nid4, char **endh);
 int class_parse_nid(char *buf, struct lnet_nid *nid, char **endh);
 int class_parse_nid_quiet(char *buf, struct lnet_nid *nid, char **endh);
-int class_parse_net(char *buf, u32 *net, char **endh);
-int class_match_net(char *buf, char *key, u32 net);
 
 struct obd_device *class_incref(struct obd_device *obd,
 				const char *scope, const void *source);
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 689e8f54084d..3fe1cb6e5341 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -152,19 +152,6 @@ static int class_match_param(char *buf, const char *key, char **valp)
 	return 0;
 }
 
-static int parse_nid4(char *buf, void *value, int quiet)
-{
-	lnet_nid_t *nid4 = value;
-
-	*nid4 = libcfs_str2nid(buf);
-	if (*nid4 != LNET_NID_ANY)
-		return 0;
-
-	if (!quiet)
-		LCONSOLE_ERROR_MSG(0x159, "Can't parse NID '%s'\n", buf);
-	return -EINVAL;
-}
-
 static int parse_nid(char *buf, void *value, int quiet)
 {
 	struct lnet_nid *nid = value;
@@ -187,8 +174,7 @@ static int parse_net(char *buf, void *value)
 }
 
 enum {
-	CLASS_PARSE_NID4 = 1,
-	CLASS_PARSE_NID,
+	CLASS_PARSE_NID = 1,
 	CLASS_PARSE_NET,
 };
 
@@ -221,9 +207,6 @@ static int class_parse_value(char *buf, int opc, void *value, char **endh,
 	switch (opc) {
 	default:
 		LBUG();
-	case CLASS_PARSE_NID4:
-		rc = parse_nid4(buf, value, quiet);
-		break;
 	case CLASS_PARSE_NID:
 		rc = parse_nid(buf, value, quiet);
 		break;
@@ -239,18 +222,6 @@ static int class_parse_value(char *buf, int opc, void *value, char **endh,
 	return 0;
 }
 
-int class_parse_nid4(char *buf, lnet_nid_t *nid4, char **endh)
-{
-	return class_parse_value(buf, CLASS_PARSE_NID4, (void *)nid4, endh, 0);
-}
-EXPORT_SYMBOL(class_parse_nid4);
-
-int class_parse_nid4_quiet(char *buf, lnet_nid_t *nid4, char **endh)
-{
-	return class_parse_value(buf, CLASS_PARSE_NID4, (void *)nid4, endh, 1);
-}
-EXPORT_SYMBOL(class_parse_nid4_quiet);
-
 int class_parse_nid(char *buf, struct lnet_nid *nid, char **endh)
 {
 	return class_parse_value(buf, CLASS_PARSE_NID, (void *)nid, endh, 0);
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
