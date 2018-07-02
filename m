From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:23 -0400
Subject: [lustre-devel] [PATCH 06/18] lustre: obd: reserve connection flag
 OBD_CONNECT2_FILE_SECCTX
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

The connection flag OBD_CONNECT2_FILE_SECCTX will be set (in
ocd_connect_flags2) if an MDT supports setting the file security
context at create time.

Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-5560
Reviewed-on: http://review.whamcloud.com/19970
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |  4 ++
 .../staging/lustre/lustre/include/lustre_import.h  |  1 +
 drivers/staging/lustre/lustre/include/obd_class.h  |  3 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |  1 +
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  9 +++-
 .../lustre/lustre/obdclass/lprocfs_status.c        | 62 ++++++++++++++++++----
 drivers/staging/lustre/lustre/ptlrpc/import.c      | 10 ++++
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |  2 +
 8 files changed, 80 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index 6defc6d..4e25521 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -695,6 +695,10 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT_BULK_MBITS	 0x2000000000000000ULL
 #define OBD_CONNECT_OBDOPACK	 0x4000000000000000ULL /* compact OUT obdo */
 #define OBD_CONNECT_FLAGS2	 0x8000000000000000ULL /* second flags word */
+/* ocd_connect_flags2 flags */
+#define OBD_CONNECT2_FILE_SECCTX	0x1ULL		/* set file security
+							 * context at create
+							 */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index ac3805e..a629f6b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -307,6 +307,7 @@ struct obd_import {
 	__u32		     imp_connect_op;
 	struct obd_connect_data   imp_connect_data;
 	__u64		     imp_connect_flags_orig;
+	u64			imp_connect_flags2_orig;
 	int		       imp_connect_error;
 
 	__u32		     imp_msg_magic;
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 20d07f8..adfe2ab 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -80,7 +80,8 @@ struct obd_device *class_devices_in_group(struct obd_uuid *grp_uuid,
 
 int class_notify_sptlrpc_conf(const char *fsname, int namelen);
 
-int obd_connect_flags2str(char *page, int count, __u64 flags, char *sep);
+int obd_connect_flags2str(char *page, int count, u64 flags, u64 flags2,
+			  const char *sep);
 
 int obd_zombie_impexp_init(void);
 void obd_zombie_impexp_stop(void);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 0aa4f23..07baea7 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -518,6 +518,7 @@ int client_connect_import(const struct lu_env *env,
 		if (is_mdc)
 			data->ocd_connect_flags |= OBD_CONNECT_MULTIMODRPCS;
 		imp->imp_connect_flags_orig = data->ocd_connect_flags;
+		imp->imp_connect_flags2_orig = data->ocd_connect_flags2;
 	}
 
 	rc = ptlrpc_connect_import(imp);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 6e47e5b..640205a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -203,7 +203,10 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_OPEN_BY_FID |
 				  OBD_CONNECT_DIR_STRIPE |
 				  OBD_CONNECT_BULK_MBITS |
-				  OBD_CONNECT_SUBTREE;
+				  OBD_CONNECT_SUBTREE |
+				  OBD_CONNECT_FLAGS2;
+
+	data->ocd_connect_flags2 = 0;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
@@ -292,7 +295,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 			goto out_md_fid;
 		}
 		obd_connect_flags2str(buf, PAGE_SIZE,
-				      valid ^ CLIENT_CONNECT_MDT_REQD, ",");
+				      valid ^ CLIENT_CONNECT_MDT_REQD, 0, ",");
 		LCONSOLE_ERROR_MSG(0x170,
 				   "Server %s does not support feature(s) needed for correct operation of this client (%s). Please upgrade server or downgrade client.\n",
 				   sbi->ll_md_exp->exp_obd->obd_name, buf);
@@ -375,6 +378,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_PINGLESS | OBD_CONNECT_LFSCK |
 				  OBD_CONNECT_BULK_MBITS;
 
+	data->ocd_connect_flags2 = 0;
+
 	if (!OBD_FAIL_CHECK(OBD_FAIL_OSC_CONNECT_GRANT_PARAM))
 		data->ocd_connect_flags |= OBD_CONNECT_GRANT_PARAM;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index dd88179..9f76d8a 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -45,6 +45,7 @@
 #include <linux/ctype.h>
 
 static const char * const obd_connect_names[] = {
+	/* flags names */
 	"read_only",
 	"lov_index",
 	"connect_from_mds",
@@ -109,23 +110,42 @@
 	"bulk_mbits",
 	"compact_obdo",
 	"second_flags",
+	/* flags2 names */
+	"file_secctx",
 	NULL
 };
 
-int obd_connect_flags2str(char *page, int count, __u64 flags, char *sep)
+int obd_connect_flags2str(char *page, int count, u64 flags, u64 flags2,
+			  const char *sep)
 {
-	__u64 mask = 1;
+	__u64 mask;
 	int i, ret = 0;
 
-	for (i = 0; obd_connect_names[i]; i++, mask <<= 1) {
+	for (i = 0, mask = 1; i < 64; i++, mask <<= 1) {
 		if (flags & mask)
 			ret += snprintf(page + ret, count - ret, "%s%s",
 					ret ? sep : "", obd_connect_names[i]);
 	}
+
 	if (flags & ~(mask - 1))
 		ret += snprintf(page + ret, count - ret,
 				"%sunknown flags %#llx",
 				ret ? sep : "", flags & ~(mask - 1));
+
+	if (!(flags & OBD_CONNECT_FLAGS2) || flags2 == 0)
+		return ret;
+
+	for (i = 64, mask = 1; obd_connect_names[i]; i++, mask <<= 1) {
+		if (flags2 & mask)
+			ret += snprintf(page + ret, count - ret, "%s%s",
+					ret ? sep : "", obd_connect_names[i]);
+	}
+
+	if (flags2 & ~(mask - 1))
+		ret += snprintf(page + ret, count - ret,
+				"%sunknown2_%#llx",
+				ret ? sep : "", flags2 & ~(mask - 1));
+
 	return ret;
 }
 EXPORT_SYMBOL(obd_connect_flags2str);
@@ -659,22 +679,43 @@ static int obd_import_flags2str(struct obd_import *imp, struct seq_file *m)
 
 #undef flags2str
 
-static void obd_connect_seq_flags2str(struct seq_file *m, __u64 flags, char *sep)
+static void obd_connect_seq_flags2str(struct seq_file *m, u64 flags,
+				      u64 flags2, const char *sep)
 {
-	__u64 mask = 1;
+	__u64 mask;
 	int i;
 	bool first = true;
 
-	for (i = 0; obd_connect_names[i]; i++, mask <<= 1) {
+	for (i = 0, mask = 1; i < 64; i++, mask <<= 1) {
 		if (flags & mask) {
 			seq_printf(m, "%s%s",
 				   first ? sep : "", obd_connect_names[i]);
 			first = false;
 		}
 	}
-	if (flags & ~(mask - 1))
+
+	if (flags & ~(mask - 1)) {
 		seq_printf(m, "%sunknown flags %#llx",
 			   first ? sep : "", flags & ~(mask - 1));
+		first = false;
+	}
+
+	if (!(flags & OBD_CONNECT_FLAGS2) || flags2 == 0)
+		return;
+
+	for (i = 64, mask = 1; obd_connect_names[i]; i++, mask <<= 1) {
+		if (flags2 & mask) {
+			seq_printf(m, "%s%s",
+				   first ? "" : sep, obd_connect_names[i]);
+			first = false;
+		}
+	}
+
+	if (flags2 & ~(mask - 1)) {
+		seq_printf(m, "%sunknown2_%#llx",
+			   first ? "" : sep, flags2 & ~(mask - 1));
+		first = false;
+	}
 }
 
 int lprocfs_rd_import(struct seq_file *m, void *data)
@@ -710,6 +751,7 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 		   ptlrpc_import_state_name(imp->imp_state),
 		   imp->imp_connect_data.ocd_instance);
 	obd_connect_seq_flags2str(m, imp->imp_connect_data.ocd_connect_flags,
+				  imp->imp_connect_data.ocd_connect_flags2,
 				  ", ");
 	seq_puts(m, " ]\n");
 	obd_connect_data_seqprint(m, ocd);
@@ -932,7 +974,7 @@ int lprocfs_rd_timeouts(struct seq_file *m, void *data)
 int lprocfs_rd_connect_flags(struct seq_file *m, void *data)
 {
 	struct obd_device *obd = data;
-	__u64 flags;
+	__u64 flags, flags2;
 	int rc;
 
 	rc = lprocfs_climp_check(obd);
@@ -940,8 +982,10 @@ int lprocfs_rd_connect_flags(struct seq_file *m, void *data)
 		return rc;
 
 	flags = obd->u.cli.cl_import->imp_connect_data.ocd_connect_flags;
+	flags2 = obd->u.cli.cl_import->imp_connect_data.ocd_connect_flags2;
 	seq_printf(m, "flags=%#llx\n", flags);
-	obd_connect_seq_flags2str(m, flags, "\n");
+	seq_printf(m, "flags2=%#llx\n", flags2);
+	obd_connect_seq_flags2str(m, flags, flags2, "\n");
 	seq_puts(m, "\n");
 	up_read(&obd->u.cli.cl_sem);
 	return 0;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 54ceac5..4db0d89 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -641,6 +641,7 @@ int ptlrpc_connect_import(struct obd_import *imp)
 	 * the server is updated on-the-fly we will get the new features.
 	 */
 	imp->imp_connect_data.ocd_connect_flags = imp->imp_connect_flags_orig;
+	imp->imp_connect_data.ocd_connect_flags2 = imp->imp_connect_flags2_orig;
 	/* Reset ocd_version each time so the server knows the exact versions */
 	imp->imp_connect_data.ocd_version = LUSTRE_VERSION_CODE;
 	imp->imp_msghdr_flags &= ~MSGHDR_AT_SUPPORT;
@@ -1019,6 +1020,15 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 		goto out;
 	}
 
+	if ((ocd->ocd_connect_flags2 & imp->imp_connect_flags2_orig) !=
+	    ocd->ocd_connect_flags2) {
+		CERROR("%s: Server didn't grant requested subset of flags2: asked=%#llx granted=%#llx\n",
+		       imp->imp_obd->obd_name, imp->imp_connect_flags2_orig,
+		       ocd->ocd_connect_flags2);
+		rc = -EPROTO;
+		goto out;
+	}
+
 	old_connect_flags = exp_connect_flags(exp);
 	exp->exp_connect_data = *ocd;
 	imp->imp_obd->obd_self_export->exp_connect_data = *ocd;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 43931dd..dae1b09 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1116,6 +1116,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT_OBDOPACK);
 	LASSERTF(OBD_CONNECT_FLAGS2 == 0x8000000000000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_FLAGS2);
+	LASSERTF(OBD_CONNECT2_FILE_SECCTX == 0x1ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_FILE_SECCTX);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
-- 
1.8.3.1
