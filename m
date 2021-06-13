Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DF2AC48BDF
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:14 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3C0A4611CA
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C0A4611CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9205221F5A7;
	Sun, 13 Jun 2021 16:12:00 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3418B21C959
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:41 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B020D100B006;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A47B19C306; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:12 -0400
Message-Id: <1623625897-17706-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/27] lustre: uapi: rename CONFIG_T_* to
 MGS_CFG_T_*
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

The Linux kernel uses CONFIG_* as a way to determine if a feature
is available. Using CONFIG_* in an UAPI is considered an error
and in the most recent kernels will break a build. While we don't
have any CONFIG_* in our UAPI headers we do have CONFIG_T_*
which is used for config logs. This naming confuses the Linux
kernel build system so just rename these variables to MGS_CFG_T_*
instead.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14651
Lustre-commit: 4d5a2eba617780ea ("LU-14651 uapi: rename CONFIG_T_* to MGS_CFG_T_*")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/43494
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/include/lustre_disk.h        |  3 ++-
 fs/lustre/include/obd_class.h          |  2 +-
 fs/lustre/mgc/mgc_internal.h           |  8 ++++----
 fs/lustre/mgc/mgc_request.c            | 27 ++++++++++++++-------------
 fs/lustre/ptlrpc/wiretest.c            |  8 ++++----
 include/uapi/linux/lustre/lustre_idl.h | 13 +++++++------
 6 files changed, 32 insertions(+), 29 deletions(-)

diff --git a/fs/lustre/include/lustre_disk.h b/fs/lustre/include/lustre_disk.h
index 81a0d40..d8686fc 100644
--- a/fs/lustre/include/lustre_disk.h
+++ b/fs/lustre/include/lustre_disk.h
@@ -154,7 +154,8 @@ struct lustre_sb_info {
 int lmd_parse(char *options, struct lustre_mount_data *lmd);
 
 /* mgc_request.c */
-int mgc_fsname2resid(char *fsname, struct ldlm_res_id *res_id, int type);
+int mgc_fsname2resid(char *fsname, struct ldlm_res_id *res_id,
+		     enum mgs_cfg_type type);
 
 /** @} disk */
 
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index eb52733..5cbed01 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -205,7 +205,7 @@ struct config_llog_data {
 	struct config_llog_data	       *cld_recover;	/* imperative recover log */
 	struct obd_export	       *cld_mgcexp;
 	struct mutex			cld_lock;
-	int				cld_type;
+	enum mgs_cfg_type		cld_type;
 	unsigned int			cld_stopping:1, /*
 							 * we were told to stop
 							 * watching
diff --git a/fs/lustre/mgc/mgc_internal.h b/fs/lustre/mgc/mgc_internal.h
index e323f90..a2a09d4 100644
--- a/fs/lustre/mgc/mgc_internal.h
+++ b/fs/lustre/mgc/mgc_internal.h
@@ -43,14 +43,14 @@
 
 int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld);
 
-static inline int cld_is_sptlrpc(struct config_llog_data *cld)
+static inline bool cld_is_sptlrpc(struct config_llog_data *cld)
 {
-	return cld->cld_type == CONFIG_T_SPTLRPC;
+	return cld->cld_type == MGS_CFG_T_SPTLRPC;
 }
 
-static inline int cld_is_recover(struct config_llog_data *cld)
+static inline bool cld_is_recover(struct config_llog_data *cld)
 {
-	return cld->cld_type == CONFIG_T_RECOVER;
+	return cld->cld_type == MGS_CFG_T_RECOVER;
 }
 
 #endif  /* _MGC_INTERNAL_H */
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index c2ad5d3..5ea965c 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -50,7 +50,7 @@
 #include "mgc_internal.h"
 
 static int mgc_name2resid(char *name, int len, struct ldlm_res_id *res_id,
-			  int type)
+			  enum mgs_cfg_type type)
 {
 	u64 resname = 0;
 
@@ -69,12 +69,12 @@ static int mgc_name2resid(char *name, int len, struct ldlm_res_id *res_id,
 	res_id->name[0] = cpu_to_le64(resname);
 	/* XXX: unfortunately, sptlprc and config llog share one lock */
 	switch (type) {
-	case CONFIG_T_CONFIG:
-	case CONFIG_T_SPTLRPC:
+	case MGS_CFG_T_CONFIG:
+	case MGS_CFG_T_SPTLRPC:
 		resname = 0;
 		break;
-	case CONFIG_T_RECOVER:
-	case CONFIG_T_PARAMS:
+	case MGS_CFG_T_RECOVER:
+	case MGS_CFG_T_PARAMS:
 		resname = type;
 		break;
 	default:
@@ -86,7 +86,8 @@ static int mgc_name2resid(char *name, int len, struct ldlm_res_id *res_id,
 	return 0;
 }
 
-int mgc_fsname2resid(char *fsname, struct ldlm_res_id *res_id, int type)
+int mgc_fsname2resid(char *fsname, struct ldlm_res_id *res_id,
+		     enum mgs_cfg_type type)
 {
 	/* fsname is at most 8 chars long, maybe contain "-".
 	 * e.g. "lustre", "SUN-000"
@@ -96,7 +97,7 @@ int mgc_fsname2resid(char *fsname, struct ldlm_res_id *res_id, int type)
 EXPORT_SYMBOL(mgc_fsname2resid);
 
 static int mgc_logname2resid(char *logname, struct ldlm_res_id *res_id,
-			     int type)
+			     enum mgs_cfg_type type)
 {
 	char *name_end;
 	int len;
@@ -190,7 +191,7 @@ struct config_llog_data *config_log_find(char *logname,
 static
 struct config_llog_data *do_config_log_add(struct obd_device *obd,
 					   char *logname,
-					   int type,
+					   enum mgs_cfg_type type,
 					   struct config_llog_instance *cfg,
 					   struct super_block *sb)
 {
@@ -258,13 +259,13 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 	LASSERT(lcfg.cfg_instance);
 	strcat(logname, "-cliir");
 
-	cld = do_config_log_add(obd, logname, CONFIG_T_RECOVER, &lcfg, sb);
+	cld = do_config_log_add(obd, logname, MGS_CFG_T_RECOVER, &lcfg, sb);
 	return cld;
 }
 
 static struct config_llog_data *
 config_log_find_or_add(struct obd_device *obd, char *logname,
-		       struct super_block *sb, int type,
+		       struct super_block *sb, enum mgs_cfg_type type,
 		       struct config_llog_instance *cfg)
 {
 	struct config_llog_instance lcfg = *cfg;
@@ -314,7 +315,7 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 
 	if (cfg->cfg_sub_clds & CONFIG_SUB_SPTLRPC) {
 		sptlrpc_cld = config_log_find_or_add(obd, seclogname, NULL,
-						     CONFIG_T_SPTLRPC, cfg);
+						     MGS_CFG_T_SPTLRPC, cfg);
 		if (IS_ERR(sptlrpc_cld)) {
 			CERROR("can't create sptlrpc log: %s\n", seclogname);
 			rc = PTR_ERR(sptlrpc_cld);
@@ -324,7 +325,7 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 
 	if (cfg->cfg_sub_clds & CONFIG_SUB_PARAMS) {
 		params_cld = config_log_find_or_add(obd, PARAMS_FILENAME, sb,
-						    CONFIG_T_PARAMS, cfg);
+						    MGS_CFG_T_PARAMS, cfg);
 		if (IS_ERR(params_cld)) {
 			rc = PTR_ERR(params_cld);
 			CERROR("%s: can't create params log: rc = %d\n",
@@ -333,7 +334,7 @@ struct config_llog_data *do_config_log_add(struct obd_device *obd,
 		}
 	}
 
-	cld = do_config_log_add(obd, logname, CONFIG_T_CONFIG, cfg, sb);
+	cld = do_config_log_add(obd, logname, MGS_CFG_T_CONFIG, cfg, sb);
 	if (IS_ERR(cld)) {
 		CERROR("can't create log: %s\n", logname);
 		rc = PTR_ERR(cld);
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 71f9e32..03fd815 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -4151,10 +4151,10 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct mgs_config_body *)0)->mcb_units) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct mgs_config_body *)0)->mcb_units));
 
-	BUILD_BUG_ON(CONFIG_T_CONFIG != 0);
-	BUILD_BUG_ON(CONFIG_T_SPTLRPC != 1);
-	BUILD_BUG_ON(CONFIG_T_RECOVER != 2);
-	BUILD_BUG_ON(CONFIG_T_PARAMS != 3);
+	BUILD_BUG_ON(MGS_CFG_T_CONFIG != 0);
+	BUILD_BUG_ON(MGS_CFG_T_SPTLRPC != 1);
+	BUILD_BUG_ON(MGS_CFG_T_RECOVER != 2);
+	BUILD_BUG_ON(MGS_CFG_T_PARAMS != 3);
 
 	/* Checks for struct mgs_config_res */
 	LASSERTF((int)sizeof(struct mgs_config_res) == 16, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index c79010b..d62b3cd 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2362,17 +2362,18 @@ struct mgs_nidtbl_entry {
 	} u;
 };
 
-enum {
-	CONFIG_T_CONFIG  = 0,
-	CONFIG_T_SPTLRPC = 1,
-	CONFIG_T_RECOVER = 2,
-	CONFIG_T_PARAMS  = 3,
+enum mgs_cfg_type {
+	MGS_CFG_T_CONFIG	= 0,
+	MGS_CFG_T_SPTLRPC	= 1,
+	MGS_CFG_T_RECOVER	= 2,
+	MGS_CFG_T_PARAMS	= 3,
+	MGS_CFG_T_MAX
 };
 
 struct mgs_config_body {
 	char		mcb_name[MTI_NAME_MAXLEN]; /* logname */
 	__u64		mcb_offset;    /* next index of config log to request */
-	__u16		mcb_type;      /* type of log: CONFIG_T_[CONFIG|RECOVER] */
+	__u16		mcb_type;      /* type of log: MGS_CFG_T_[CONFIG|RECOVER] */
 	__u8		mcb_nm_cur_pass;
 	__u8		mcb_bits;      /* bits unit size of config log */
 	__u32		mcb_units;     /* # of units for bulk transfer */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
