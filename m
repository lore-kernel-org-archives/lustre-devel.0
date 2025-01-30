Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 194F3C0218F
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:24:44 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLcg1lxrz212R;
	Thu, 30 Jan 2025 06:14:27 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLYl36Y4z1xf0
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:11:55 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 143BE899AD7;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 1090A106BE14; Thu, 30 Jan 2025 09:11:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:11:03 -0500
Message-ID: <20250130141115.950749-14-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 13/25] lustre: obdclass: convert
 class_parse_nid4 to class_parse_nid
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

All callers of class_parse_nid4() now use class_parse_nid()
and so much handle a large nid.

do_lcfg_nid() is introduced to help with this.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13340
Lustre-commit: 6c3b50434b321cc16 ("LU-13340 mgs: convert class_parse_nid4 to class_parse_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50094
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/obd_mount.c | 34 +++++++++++++++++++++-------------
 1 file changed, 21 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index 6eaa214c813f..c569592bd6e7 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -179,6 +179,15 @@ static int do_lcfg(char *cfgname, lnet_nid_t nid, int cmd,
 	return rc;
 }
 
+static int do_lcfg_nid(char *cfgname, struct lnet_nid *nid, int cmd,
+		       char *s1)
+{
+	if (nid_is_nid4(nid))
+		return do_lcfg(cfgname, lnet_nid_to_nid4(nid), cmd, s1,
+			       NULL, NULL, NULL);
+	return -EINVAL;
+}
+
 /** Call class_attach and class_setup.  These methods in turn call
  * obd type-specific methods.
  */
@@ -218,7 +227,7 @@ int lustre_start_mgc(struct super_block *sb)
 	struct obd_export *exp;
 	struct obd_uuid *uuid = NULL;
 	uuid_t uuidc;
-	lnet_nid_t nid;
+	struct lnet_nid nid;
 	char nidstr[LNET_NIDSTR_SIZE];
 	char *mgcname = NULL, *niduuid = NULL, *mgssec = NULL;
 	char *ptr;
@@ -228,7 +237,7 @@ int lustre_start_mgc(struct super_block *sb)
 
 	/* Use nids from mount line: uml1,1@elan:uml2,2@elan:/lustre */
 	ptr = lsi->lsi_lmd->lmd_dev;
-	if (class_parse_nid4(ptr, &nid, &ptr) == 0)
+	if (class_parse_nid(ptr, &nid, &ptr) == 0)
 		i++;
 	if (i == 0) {
 		CERROR("No valid MGS nids found.\n");
@@ -237,7 +246,7 @@ int lustre_start_mgc(struct super_block *sb)
 
 	mutex_lock(&mgc_start_lock);
 
-	libcfs_nid2str_r(nid, nidstr, sizeof(nidstr));
+	libcfs_nidstr_r(&nid, nidstr, sizeof(nidstr));
 	mgcname = kasprintf(GFP_NOFS,
 			    "%s%s", LUSTRE_MGC_OBDNAME, nidstr);
 	niduuid = kasprintf(GFP_NOFS, "%s_%x", mgcname, 0);
@@ -314,10 +323,9 @@ int lustre_start_mgc(struct super_block *sb)
 	i = 0;
 	/* Use nids from mount line: uml1,1@elan:uml2,2@elan:/lustre */
 	ptr = lsi->lsi_lmd->lmd_dev;
-	while (class_parse_nid4(ptr, &nid, &ptr) == 0) {
-		rc = do_lcfg(mgcname, nid,
-			     LCFG_ADD_UUID, niduuid, NULL, NULL, NULL);
-		if (!rc)
+	while (class_parse_nid(ptr, &nid, &ptr) == 0) {
+		rc = do_lcfg_nid(mgcname, &nid, LCFG_ADD_UUID, niduuid);
+		if (rc == 0)
 			i++;
 		/* Stop at the first failover nid */
 		if (*ptr == ':')
@@ -354,10 +362,10 @@ int lustre_start_mgc(struct super_block *sb)
 		/* New failover node */
 		sprintf(niduuid, "%s_%x", mgcname, i);
 		j = 0;
-		while (class_parse_nid4_quiet(ptr, &nid, &ptr) == 0) {
-			rc = do_lcfg(mgcname, nid, LCFG_ADD_UUID, niduuid,
-				     NULL, NULL, NULL);
-			if (!rc)
+		while (class_parse_nid_quiet(ptr, &nid, &ptr) == 0) {
+			rc = do_lcfg_nid(mgcname, &nid, LCFG_ADD_UUID,
+					 niduuid);
+			if (rc == 0)
 				++j;
 			if (*ptr == ':')
 				break;
@@ -863,14 +871,14 @@ static int lmd_parse_string(char **handle, char *ptr)
 /* Collect multiple values for mgsnid specifiers */
 static int lmd_parse_mgs(struct lustre_mount_data *lmd, char **ptr)
 {
-	lnet_nid_t nid;
+	struct lnet_nid nid;
 	char *tail = *ptr;
 	char *mgsnid;
 	int length;
 	int oldlen = 0;
 
 	/* Find end of nidlist */
-	while (class_parse_nid4_quiet(tail, &nid, &tail) == 0)
+	while (class_parse_nid_quiet(tail, &nid, &tail) == 0)
 		;
 	length = tail - *ptr;
 	if (length == 0) {
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
