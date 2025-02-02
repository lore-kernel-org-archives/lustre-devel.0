Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8C1D8C0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:49:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMBw1b9yz1yXx;
	Sun, 02 Feb 2025 12:47:36 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmM9w2CH7z1y82
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:46:44 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id ADF458998DC;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id AA465106BE15; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:05 -0500
Message-ID: <20250202204633.1148872-6-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 05/33] lustre: obd: change lmd flags to bitmap
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

Change lmd flags to an enum that is accessible with the Linux
bitmap API. This lays the foundation for creating a match table
for the server options for mounting.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: a342697e580ffea62 ("LU-6142 obd: change lmd flags to bitmap")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49912
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/include/lustre_disk.h | 51 +++++++++++++++-----------
 fs/lustre/mgc/mgc_request.c     |  2 +-
 fs/lustre/obdclass/obd_mount.c  | 64 +++++++++++++++++++++------------
 3 files changed, 73 insertions(+), 44 deletions(-)

diff --git a/fs/lustre/include/lustre_disk.h b/fs/lustre/include/lustre_disk.h
index a8e935eaeefa..976c0bb749c1 100644
--- a/fs/lustre/include/lustre_disk.h
+++ b/fs/lustre/include/lustre_disk.h
@@ -68,10 +68,38 @@
 #define LMD_MAGIC		0xbdacbd03
 #define LMD_PARAMS_MAXLEN	4096
 
+enum lmd_flags {
+	LMD_FLG_SERVER		= 0,	/* Mounting a server */
+	LMD_FLG_CLIENT,			/* Mounting a client */
+	LMD_FLG_SKIP_LFSCK,		/* NOT auto resume LFSCK when mount */
+	LMD_FLG_ABORT_RECOV,		/* Abort recovery */
+	LMD_FLG_NOSVC,			/* Only start MGS/MGC for servers,
+					 * no other services
+					 */
+	LMD_FLG_NOMGS,			/* Only start target for servers,
+					 * reusing existing MGS services
+					 */
+	LMD_FLG_WRITECONF,		/* Rewrite config log */
+	LMD_FLG_NOIR,			/* NO imperative recovery */
+	LMD_FLG_NOSCRUB,			/* Do not trigger scrub automatically */
+	LMD_FLG_MGS,			/* Also start MGS along with server */
+	LMD_FLG_IAM,			/* IAM dir */
+	LMD_FLG_NO_PRIMNODE,		/* all nodes are service nodes */
+	LMD_FLG_VIRGIN,			/* the service registers first time */
+	LMD_FLG_UPDATE,			/* update parameters */
+	LMD_FLG_HSM,			/* Start coordinator */
+	LMD_FLG_DEV_RDONLY,		/* discard modification quitely */
+	LMD_FLG_NO_PRECREATE,		/* do not allow OST object creation */
+	LMD_FLG_LOCAL_RECOV,		/* force recovery for local clients */
+	LMD_FLG_ABORT_RECOV_MDT,	/* Abort recovery between MDTs */
+	LMD_FLG_NO_LOCAL_LOGS,		/* Use config logs from MGS */
+	LMD_FLG_NUM_FLAGS
+};
+
 /* gleaned from the mount command - no persistent info here */
 struct lustre_mount_data {
 	u32	lmd_magic;
-	u32	lmd_flags;	/* lustre mount flags */
+	DECLARE_BITMAP(lmd_flags, LMD_FLG_NUM_FLAGS); /* lustre mount flags */
 	int	lmd_mgs_failnodes; /* mgs failover node count */
 	int	lmd_exclude_count;
 	int	lmd_recovery_time_soft;
@@ -90,26 +118,7 @@ struct lustre_mount_data {
 	char    *lmd_nidnet;	/* network to restrict this client to */
 };
 
-#define LMD_FLG_SERVER		0x0001	/* Mounting a server */
-#define LMD_FLG_CLIENT		0x0002	/* Mounting a client */
-#define LMD_FLG_ABORT_RECOV	0x0008	/* Abort recovery */
-#define LMD_FLG_NOSVC		0x0010	/* Only start MGS/MGC for servers,
-					 * no other services
-					 */
-#define LMD_FLG_NOMGS		0x0020	/* Only start target for servers,
-					 * reusing existing MGS services
-					 */
-#define LMD_FLG_WRITECONF	0x0040	/* Rewrite config log */
-#define LMD_FLG_NOIR		0x0080	/* NO imperative recovery */
-#define LMD_FLG_NOSCRUB		0x0100	/* Do not trigger scrub automatically */
-#define LMD_FLG_MGS		0x0200	/* Also start MGS along with server */
-#define LMD_FLG_IAM		0x0400	/* IAM dir */
-#define LMD_FLG_NO_PRIMNODE	0x0800	/* all nodes are service nodes */
-#define LMD_FLG_VIRGIN		0x1000	/* the service registers first time */
-#define LMD_FLG_UPDATE		0x2000	/* update parameters */
-#define LMD_FLG_HSM		0x4000	/* Start coordinator */
-
-#define lmd_is_client(x) ((x)->lmd_flags & LMD_FLG_CLIENT)
+#define lmd_is_client(x) (test_bit(LMD_FLG_CLIENT, (x)->lmd_flags))
 
 /****************** superblock additional info *********************/
 
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 62bf0eab512d..94e15f9e7c52 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -342,7 +342,7 @@ config_log_add(struct obd_device *obd, char *logname,
 	}
 
 	LASSERT(lsi->lsi_lmd);
-	if (!(lsi->lsi_lmd->lmd_flags & LMD_FLG_NOIR) &&
+	if (!test_bit(LMD_FLG_NOIR, lsi->lsi_lmd->lmd_flags) &&
 	    cfg->cfg_sub_clds & CONFIG_SUB_RECOVER) {
 		ptr = strrchr(seclogname, '-');
 		if (ptr) {
diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index c569592bd6e7..02b7d88263c7 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -280,22 +280,25 @@ int lustre_start_mgc(struct super_block *sb)
 		if (lmd_is_client(lsi->lsi_lmd)) {
 			int has_ir;
 			int vallen = sizeof(*data);
-			u32 *flags = &lsi->lsi_lmd->lmd_flags;
 
 			rc = obd_get_info(NULL, obd->obd_self_export,
 					  strlen(KEY_CONN_DATA), KEY_CONN_DATA,
 					  &vallen, data);
 			LASSERT(rc == 0);
 			has_ir = OCD_HAS_FLAG(data, IMP_RECOV);
-			if (has_ir ^ !(*flags & LMD_FLG_NOIR)) {
+			if (has_ir ^ !test_bit(LMD_FLG_NOIR,
+					       lsi->lsi_lmd->lmd_flags)) {
 				/* LMD_FLG_NOIR is for test purpose only */
 				LCONSOLE_WARN(
 					"Trying to mount a client with IR setting not compatible with current mgc. Force to use current mgc setting that is IR %s.\n",
 					has_ir ? "enabled" : "disabled");
-				if (has_ir)
-					*flags &= ~LMD_FLG_NOIR;
-				else
-					*flags |= LMD_FLG_NOIR;
+				if (has_ir) {
+					clear_bit(LMD_FLG_NOIR,
+						  lsi->lsi_lmd->lmd_flags);
+				} else {
+					set_bit(LMD_FLG_NOIR,
+						lsi->lsi_lmd->lmd_flags);
+				}
 			}
 		}
 
@@ -408,7 +411,7 @@ int lustre_start_mgc(struct super_block *sb)
 	data->ocd_connect_flags2 = OBD_CONNECT2_REP_MBITS;
 
 	if (lmd_is_client(lsi->lsi_lmd) &&
-	    lsi->lsi_lmd->lmd_flags & LMD_FLG_NOIR)
+	    test_bit(LMD_FLG_NOIR, lsi->lsi_lmd->lmd_flags))
 		data->ocd_connect_flags &= ~OBD_CONNECT_IMP_RECOV;
 	data->ocd_version = LUSTRE_VERSION_CODE;
 	rc = obd_connect(NULL, &exp, obd, uuid, data, NULL);
@@ -695,7 +698,6 @@ static void lmd_print(struct lustre_mount_data *lmd)
 	if (lmd_is_client(lmd))
 		PRINT_CMD(D_MOUNT, "profile: %s\n", lmd->lmd_profile);
 	PRINT_CMD(D_MOUNT, "device:  %s\n", lmd->lmd_dev);
-	PRINT_CMD(D_MOUNT, "flags:   %x\n", lmd->lmd_flags);
 
 	if (lmd->lmd_opts)
 		PRINT_CMD(D_MOUNT, "options: %s\n", lmd->lmd_opts);
@@ -1053,8 +1055,12 @@ int lmd_parse(char *options, struct lustre_mount_data *lmd)
 		/* Parse non-ldiskfs options here. Rather than modifying
 		 * ldiskfs, we just zero these out here
 		 */
-		if (strncmp(s1, "abort_recov", 11) == 0) {
-			lmd->lmd_flags |= LMD_FLG_ABORT_RECOV;
+		if (!strncmp(s1, "abort_recov_mdt", 15) ||
+		    !strncmp(s1, "abort_recovery_mdt", 18)) {
+			set_bit(LMD_FLG_ABORT_RECOV_MDT, lmd->lmd_flags);
+			clear++;
+		} else if (strncmp(s1, "abort_recov", 11) == 0) {
+			set_bit(LMD_FLG_ABORT_RECOV, lmd->lmd_flags);
 			clear++;
 		} else if (strncmp(s1, "recovery_time_soft=", 19) == 0) {
 			lmd->lmd_recovery_time_soft = max_t(int,
@@ -1064,17 +1070,26 @@ int lmd_parse(char *options, struct lustre_mount_data *lmd)
 			lmd->lmd_recovery_time_hard = max_t(int,
 				simple_strtoul(s1 + 19, NULL, 10), time_min);
 			clear++;
-		} else if (strncmp(s1, "noir", 4) == 0) {
-			lmd->lmd_flags |= LMD_FLG_NOIR; /* test purpose only. */
+		} else if (strncmp(s1, "no_precreate", 12) == 0) {
+			set_bit(LMD_FLG_NO_PRECREATE, lmd->lmd_flags);
+			clear++;
+		} else if (strncmp(s1, "noir", 4) == 0) { /* test case only */
+			set_bit(LMD_FLG_NOIR, lmd->lmd_flags);
 			clear++;
 		} else if (strncmp(s1, "nosvc", 5) == 0) {
-			lmd->lmd_flags |= LMD_FLG_NOSVC;
+			set_bit(LMD_FLG_NOSVC, lmd->lmd_flags);
 			clear++;
 		} else if (strncmp(s1, "nomgs", 5) == 0) {
-			lmd->lmd_flags |= LMD_FLG_NOMGS;
+			set_bit(LMD_FLG_NOMGS, lmd->lmd_flags);
 			clear++;
 		} else if (strncmp(s1, "noscrub", 7) == 0) {
-			lmd->lmd_flags |= LMD_FLG_NOSCRUB;
+			set_bit(LMD_FLG_NOSCRUB, lmd->lmd_flags);
+			clear++;
+		} else if (strncmp(s1, "skip_lfsck", 10) == 0) {
+			set_bit(LMD_FLG_SKIP_LFSCK, lmd->lmd_flags);
+			clear++;
+		} else if (strncmp(s1, "rdonly_dev", 10) == 0) {
+			set_bit(LMD_FLG_DEV_RDONLY, lmd->lmd_flags);
 			clear++;
 		} else if (strncmp(s1, PARAM_MGSNODE,
 				   sizeof(PARAM_MGSNODE) - 1) == 0) {
@@ -1087,16 +1102,19 @@ int lmd_parse(char *options, struct lustre_mount_data *lmd)
 				goto invalid;
 			clear++;
 		} else if (strncmp(s1, "writeconf", 9) == 0) {
-			lmd->lmd_flags |= LMD_FLG_WRITECONF;
+			set_bit(LMD_FLG_WRITECONF, lmd->lmd_flags);
+			clear++;
+		} else if (strncmp(s1, "nolocallogs", 11) == 0) {
+			set_bit(LMD_FLG_NO_LOCAL_LOGS, lmd->lmd_flags);
 			clear++;
 		} else if (strncmp(s1, "update", 6) == 0) {
-			lmd->lmd_flags |= LMD_FLG_UPDATE;
+			set_bit(LMD_FLG_UPDATE, lmd->lmd_flags);
 			clear++;
 		} else if (strncmp(s1, "virgin", 6) == 0) {
-			lmd->lmd_flags |= LMD_FLG_VIRGIN;
+			set_bit(LMD_FLG_VIRGIN, lmd->lmd_flags);
 			clear++;
 		} else if (strncmp(s1, "noprimnode", 10) == 0) {
-			lmd->lmd_flags |= LMD_FLG_NO_PRIMNODE;
+			set_bit(LMD_FLG_NO_PRIMNODE, lmd->lmd_flags);
 			clear++;
 		} else if (strncmp(s1, "mgssec=", 7) == 0) {
 			rc = lmd_parse_mgssec(lmd, s1 + 7);
@@ -1112,7 +1130,7 @@ int lmd_parse(char *options, struct lustre_mount_data *lmd)
 			clear++;
 		} else if (strncmp(s1, "mgs", 3) == 0) {
 			/* We are an MGS */
-			lmd->lmd_flags |= LMD_FLG_MGS;
+			set_bit(LMD_FLG_MGS, lmd->lmd_flags);
 			clear++;
 		} else if (strncmp(s1, "svname=", 7) == 0) {
 			rc = lmd_parse_string(&lmd->lmd_profile, s1 + 7);
@@ -1143,6 +1161,9 @@ int lmd_parse(char *options, struct lustre_mount_data *lmd)
 			strlcat(lmd->lmd_params, " ", LMD_PARAMS_MAXLEN);
 			s3 = s1 + 6 + length;
 			clear++;
+		} else if (strncmp(s1, "localrecov", 10) == 0) {
+			set_bit(LMD_FLG_LOCAL_RECOV, lmd->lmd_flags);
+			clear++;
 		} else if (strncmp(s1, "osd=", 4) == 0) {
 			rc = lmd_parse_string(&lmd->lmd_osd_type, s1 + 4);
 			if (rc)
@@ -1196,7 +1217,7 @@ int lmd_parse(char *options, struct lustre_mount_data *lmd)
 	s1 = strstr(devname, ":/");
 	if (s1) {
 		++s1;
-		lmd->lmd_flags |= LMD_FLG_CLIENT;
+		set_bit(LMD_FLG_CLIENT, lmd->lmd_flags);
 		/* Remove leading /s from fsname */
 		while (*++s1 == '/')
 			;
@@ -1248,7 +1269,6 @@ int lmd_parse(char *options, struct lustre_mount_data *lmd)
 	}
 
 	lmd_print(lmd);
-	lmd->lmd_magic = LMD_MAGIC;
 
 	return rc;
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
