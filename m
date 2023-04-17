Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 58207C77B76
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 14:07:07 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T4l5Yqzz22RF;
	Mon, 17 Apr 2023 06:52:07 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0T2P6Gmhz21Hs
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:50:05 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B7DE21008499;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B68C1375; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:19 -0400
Message-Id: <1681739243-29375-24-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 23/27] lustre: obdclass: rename
 class_parse_nid to class_parse_nid4
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
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

Use the name "nid4" for class_parse_nid(), class_parse_nid_quiet(),
parse_nid() and CLASS_PARSE_NID.  This will allow a new
class_parse_nid which handle larger nids.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: b4a28a3269fadb1059 ("LU-10391 lustre: rename class_parse_nid to class_parse_nid4")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50088
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h   |  5 ++---
 fs/lustre/obdclass/obd_config.c | 26 +++++++++++++-------------
 fs/lustre/obdclass/obd_mount.c  |  8 ++++----
 3 files changed, 19 insertions(+), 20 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index f77fd12..2b66bc4 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -144,10 +144,9 @@ struct cfg_interop_param {
 struct cfg_interop_param *class_find_old_param(const char *param,
 					       struct cfg_interop_param *ptr);
 int class_get_next_param(char **params, char *copy);
-int class_parse_nid(char *buf, lnet_nid_t *nid, char **endh);
-int class_parse_nid_quiet(char *buf, lnet_nid_t *nid, char **endh);
+int class_parse_nid4(char *buf, lnet_nid_t *nid4, char **endh);
+int class_parse_nid4_quiet(char *buf, lnet_nid_t *nid4, char **endh);
 int class_parse_net(char *buf, u32 *net, char **endh);
-int class_match_nid(char *buf, char *key, lnet_nid_t nid);
 int class_match_net(char *buf, char *key, u32 net);
 
 struct obd_device *class_incref(struct obd_device *obd,
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 81021e1..eb14ca8 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -152,12 +152,12 @@ static int class_match_param(char *buf, const char *key, char **valp)
 	return 0;
 }
 
-static int parse_nid(char *buf, void *value, int quiet)
+static int parse_nid4(char *buf, void *value, int quiet)
 {
-	lnet_nid_t *nid = value;
+	lnet_nid_t *nid4 = value;
 
-	*nid = libcfs_str2nid(buf);
-	if (*nid != LNET_NID_ANY)
+	*nid4 = libcfs_str2nid(buf);
+	if (*nid4 != LNET_NID_ANY)
 		return 0;
 
 	if (!quiet)
@@ -175,7 +175,7 @@ static int parse_net(char *buf, void *value)
 }
 
 enum {
-	CLASS_PARSE_NID = 1,
+	CLASS_PARSE_NID4 = 1,
 	CLASS_PARSE_NET,
 };
 
@@ -208,8 +208,8 @@ static int class_parse_value(char *buf, int opc, void *value, char **endh,
 	switch (opc) {
 	default:
 		LBUG();
-	case CLASS_PARSE_NID:
-		rc = parse_nid(buf, value, quiet);
+	case CLASS_PARSE_NID4:
+		rc = parse_nid4(buf, value, quiet);
 		break;
 	case CLASS_PARSE_NET:
 		rc = parse_net(buf, value);
@@ -223,17 +223,17 @@ static int class_parse_value(char *buf, int opc, void *value, char **endh,
 	return 0;
 }
 
-int class_parse_nid(char *buf, lnet_nid_t *nid, char **endh)
+int class_parse_nid4(char *buf, lnet_nid_t *nid4, char **endh)
 {
-	return class_parse_value(buf, CLASS_PARSE_NID, (void *)nid, endh, 0);
+	return class_parse_value(buf, CLASS_PARSE_NID4, (void *)nid4, endh, 0);
 }
-EXPORT_SYMBOL(class_parse_nid);
+EXPORT_SYMBOL(class_parse_nid4);
 
-int class_parse_nid_quiet(char *buf, lnet_nid_t *nid, char **endh)
+int class_parse_nid4_quiet(char *buf, lnet_nid_t *nid4, char **endh)
 {
-	return class_parse_value(buf, CLASS_PARSE_NID, (void *)nid, endh, 1);
+	return class_parse_value(buf, CLASS_PARSE_NID4, (void *)nid4, endh, 1);
 }
-EXPORT_SYMBOL(class_parse_nid_quiet);
+EXPORT_SYMBOL(class_parse_nid4_quiet);
 
 char *lustre_cfg_string(struct lustre_cfg *lcfg, u32 index)
 {
diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index 58ca72d..6eaa214 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -228,7 +228,7 @@ int lustre_start_mgc(struct super_block *sb)
 
 	/* Use nids from mount line: uml1,1@elan:uml2,2@elan:/lustre */
 	ptr = lsi->lsi_lmd->lmd_dev;
-	if (class_parse_nid(ptr, &nid, &ptr) == 0)
+	if (class_parse_nid4(ptr, &nid, &ptr) == 0)
 		i++;
 	if (i == 0) {
 		CERROR("No valid MGS nids found.\n");
@@ -314,7 +314,7 @@ int lustre_start_mgc(struct super_block *sb)
 	i = 0;
 	/* Use nids from mount line: uml1,1@elan:uml2,2@elan:/lustre */
 	ptr = lsi->lsi_lmd->lmd_dev;
-	while (class_parse_nid(ptr, &nid, &ptr) == 0) {
+	while (class_parse_nid4(ptr, &nid, &ptr) == 0) {
 		rc = do_lcfg(mgcname, nid,
 			     LCFG_ADD_UUID, niduuid, NULL, NULL, NULL);
 		if (!rc)
@@ -354,7 +354,7 @@ int lustre_start_mgc(struct super_block *sb)
 		/* New failover node */
 		sprintf(niduuid, "%s_%x", mgcname, i);
 		j = 0;
-		while (class_parse_nid_quiet(ptr, &nid, &ptr) == 0) {
+		while (class_parse_nid4_quiet(ptr, &nid, &ptr) == 0) {
 			rc = do_lcfg(mgcname, nid, LCFG_ADD_UUID, niduuid,
 				     NULL, NULL, NULL);
 			if (!rc)
@@ -870,7 +870,7 @@ static int lmd_parse_mgs(struct lustre_mount_data *lmd, char **ptr)
 	int oldlen = 0;
 
 	/* Find end of nidlist */
-	while (class_parse_nid_quiet(tail, &nid, &tail) == 0)
+	while (class_parse_nid4_quiet(tail, &nid, &tail) == 0)
 		;
 	length = tail - *ptr;
 	if (length == 0) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
