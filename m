From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:05 -0500
Subject: [lustre-devel] [PATCH 197/622] lustre: cfg: reserve flags for
 SELinux status checking
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-198-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Reserve LCFG_NODEMAP_SET_SEPOL config flag that will be used to
define sepol parameter on nodemap entries.
Reserve OBD_CONNECT2_SELINUX_POLICY connection flag that will be set
(in ocd_connect_flags2) if a client supports sending the SELinux
policy status info.
Add checks for all lcfg_command_type constants, along with lustre_cfg
and cfg_record_type.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8955
Lustre-commit: e71a77ba8d47 ("LU-8955 cfg: reserve flags for SELinux status checking")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/33797
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <farr0186@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c    |   1 +
 fs/lustre/ptlrpc/wiretest.c            | 115 +++++++++++++++++++++++++++++++--
 include/uapi/linux/lustre/lustre_cfg.h |   1 +
 include/uapi/linux/lustre/lustre_idl.h |   1 +
 4 files changed, 112 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index cce9bec..7701bc3 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -120,6 +120,7 @@
 	"wbc",		/* 0x40 */
 	"lock_convert",	/* 0x80 */
 	"archive_id_array",	/* 0x100 */
+	"selinux_policy",	/* 0x200 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 66dce80..bf79b8b 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -41,6 +41,7 @@
 #include <lustre_net.h>
 #include <lustre_disk.h>
 #include <uapi/linux/lustre/lustre_idl.h>
+#include <uapi/linux/lustre/lustre_cfg.h>
 
 #include "ptlrpc_internal.h"
 
@@ -1143,6 +1144,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_LOCK_CONVERT);
 	LASSERTF(OBD_CONNECT2_ARCHIVE_ID_ARRAY == 0x100ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_ARCHIVE_ID_ARRAY);
+	LASSERTF(OBD_CONNECT2_SELINUX_POLICY == 0x400ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_SELINUX_POLICY);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
@@ -1150,17 +1153,17 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(OBD_CKSUM_CRC32C == 0x00000004UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32C);
 	LASSERTF(OBD_CKSUM_RESERVED == 0x00000008UL, "found 0x%.8xUL\n",
-		(unsigned int)OBD_CKSUM_RESERVED);
+		 (unsigned int)OBD_CKSUM_RESERVED);
 	LASSERTF(OBD_CKSUM_T10IP512 == 0x00000010UL, "found 0x%.8xUL\n",
-		(unsigned int)OBD_CKSUM_T10IP512);
+		 (unsigned int)OBD_CKSUM_T10IP512);
 	LASSERTF(OBD_CKSUM_T10IP4K == 0x00000020UL, "found 0x%.8xUL\n",
-		(unsigned int)OBD_CKSUM_T10IP4K);
+		 (unsigned int)OBD_CKSUM_T10IP4K);
 	LASSERTF(OBD_CKSUM_T10CRC512 == 0x00000040UL, "found 0x%.8xUL\n",
-		(unsigned int)OBD_CKSUM_T10CRC512);
+		 (unsigned int)OBD_CKSUM_T10CRC512);
 	LASSERTF(OBD_CKSUM_T10CRC4K == 0x00000080UL, "found 0x%.8xUL\n",
-		(unsigned int)OBD_CKSUM_T10CRC4K);
+		 (unsigned int)OBD_CKSUM_T10CRC4K);
 	LASSERTF(OBD_CKSUM_T10_TOP == 0x00000002UL, "found 0x%.8xUL\n",
-		(unsigned int)OBD_CKSUM_T10_TOP);
+		 (unsigned int)OBD_CKSUM_T10_TOP);
 
 	/* Checks for struct ost_layout */
 	LASSERTF((int)sizeof(struct ost_layout) == 28, "found %lld\n",
@@ -4633,4 +4636,104 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)sizeof(((struct ladvise_hdr *)0)->lah_advise));
 	LASSERTF(LF_ASYNC == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)LF_ASYNC);
+
+	/* Checks for struct lustre_cfg */
+	LASSERTF((int)sizeof(struct lustre_cfg) == 32, "found %lld\n",
+		 (long long)(int)sizeof(struct lustre_cfg));
+	LASSERTF((int)offsetof(struct lustre_cfg, lcfg_version) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct lustre_cfg, lcfg_version));
+	LASSERTF((int)sizeof(((struct lustre_cfg *)0)->lcfg_version) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lustre_cfg *)0)->lcfg_version));
+	LASSERTF((int)offsetof(struct lustre_cfg, lcfg_command) == 4, "found %lld\n",
+		 (long long)(int)offsetof(struct lustre_cfg, lcfg_command));
+	LASSERTF((int)sizeof(((struct lustre_cfg *)0)->lcfg_command) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lustre_cfg *)0)->lcfg_command));
+	LASSERTF((int)offsetof(struct lustre_cfg, lcfg_num) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct lustre_cfg, lcfg_num));
+	LASSERTF((int)sizeof(((struct lustre_cfg *)0)->lcfg_num) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lustre_cfg *)0)->lcfg_num));
+	LASSERTF((int)offsetof(struct lustre_cfg, lcfg_flags) == 12, "found %lld\n",
+		 (long long)(int)offsetof(struct lustre_cfg, lcfg_flags));
+	LASSERTF((int)sizeof(((struct lustre_cfg *)0)->lcfg_flags) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lustre_cfg *)0)->lcfg_flags));
+	LASSERTF((int)offsetof(struct lustre_cfg, lcfg_nid) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct lustre_cfg, lcfg_nid));
+	LASSERTF((int)sizeof(((struct lustre_cfg *)0)->lcfg_nid) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct lustre_cfg *)0)->lcfg_nid));
+	LASSERTF((int)offsetof(struct lustre_cfg, lcfg_nal) == 24, "found %lld\n",
+		 (long long)(int)offsetof(struct lustre_cfg, lcfg_nal));
+	LASSERTF((int)sizeof(((struct lustre_cfg *)0)->lcfg_nal) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lustre_cfg *)0)->lcfg_nal));
+	LASSERTF((int)offsetof(struct lustre_cfg, lcfg_bufcount) == 28, "found %lld\n",
+		 (long long)(int)offsetof(struct lustre_cfg, lcfg_bufcount));
+	LASSERTF((int)sizeof(((struct lustre_cfg *)0)->lcfg_bufcount) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lustre_cfg *)0)->lcfg_bufcount));
+	LASSERTF((int)offsetof(struct lustre_cfg, lcfg_buflens[0]) == 32, "found %lld\n",
+		 (long long)(int)offsetof(struct lustre_cfg, lcfg_buflens[0]));
+	LASSERTF((int)sizeof(((struct lustre_cfg *)0)->lcfg_buflens[0]) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lustre_cfg *)0)->lcfg_buflens[0]));
+	LASSERTF(LCFG_ATTACH == 0x000cf001UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_ATTACH);
+	LASSERTF(LCFG_DETACH == 0x000cf002UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_DETACH);
+	LASSERTF(LCFG_SETUP == 0x000cf003UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_SETUP);
+	LASSERTF(LCFG_CLEANUP == 0x000cf004UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_CLEANUP);
+	LASSERTF(LCFG_ADD_UUID == 0x000cf005UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_ADD_UUID);
+	LASSERTF(LCFG_DEL_UUID == 0x000cf006UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_DEL_UUID);
+	LASSERTF(LCFG_MOUNTOPT == 0x000cf007UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_MOUNTOPT);
+	LASSERTF(LCFG_DEL_MOUNTOPT == 0x000cf008UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_DEL_MOUNTOPT);
+	LASSERTF(LCFG_SET_TIMEOUT == 0x000cf009UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_SET_TIMEOUT);
+	LASSERTF(LCFG_SET_UPCALL == 0x000cf00aUL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_SET_UPCALL);
+	LASSERTF(LCFG_ADD_CONN == 0x000cf00bUL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_ADD_CONN);
+	LASSERTF(LCFG_DEL_CONN == 0x000cf00cUL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_DEL_CONN);
+	LASSERTF(LCFG_LOV_ADD_OBD == 0x000cf00dUL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_LOV_ADD_OBD);
+	LASSERTF(LCFG_LOV_DEL_OBD == 0x000cf00eUL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_LOV_DEL_OBD);
+	LASSERTF(LCFG_PARAM == 0x000cf00fUL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_PARAM);
+	LASSERTF(LCFG_MARKER == 0x000cf010UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_MARKER);
+	LASSERTF(LCFG_LOG_START == 0x000ce011UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_LOG_START);
+	LASSERTF(LCFG_LOG_END == 0x000ce012UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_LOG_END);
+	LASSERTF(LCFG_LOV_ADD_INA == 0x000ce013UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_LOV_ADD_INA);
+	LASSERTF(LCFG_ADD_MDC == 0x000cf014UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_ADD_MDC);
+	LASSERTF(LCFG_DEL_MDC == 0x000cf015UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_DEL_MDC);
+	LASSERTF(LCFG_SPTLRPC_CONF == 0x000ce016UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_SPTLRPC_CONF);
+	LASSERTF(LCFG_POOL_NEW == 0x000ce020UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_POOL_NEW);
+	LASSERTF(LCFG_POOL_ADD == 0x000ce021UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_POOL_ADD);
+	LASSERTF(LCFG_POOL_REM == 0x000ce022UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_POOL_REM);
+	LASSERTF(LCFG_POOL_DEL == 0x000ce023UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_POOL_DEL);
+	LASSERTF(LCFG_SET_LDLM_TIMEOUT == 0x000ce030UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_SET_LDLM_TIMEOUT);
+	LASSERTF(LCFG_PRE_CLEANUP == 0x000cf031UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_PRE_CLEANUP);
+	LASSERTF(LCFG_SET_PARAM == 0x000ce032UL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_SET_PARAM);
+	LASSERTF(LCFG_NODEMAP_SET_SEPOL == 0x000ce05bUL, "found 0x%.8xUL\n",
+		(unsigned int)LCFG_NODEMAP_SET_SEPOL);
+	LASSERTF(PORTALS_CFG_TYPE == 1, "found %lld\n",
+		 (long long)PORTALS_CFG_TYPE);
+	LASSERTF(LUSTRE_CFG_TYPE == 123, "found %lld\n",
+		 (long long)LUSTRE_CFG_TYPE);
 }
diff --git a/include/uapi/linux/lustre/lustre_cfg.h b/include/uapi/linux/lustre/lustre_cfg.h
index 0620e49..5d6b585 100644
--- a/include/uapi/linux/lustre/lustre_cfg.h
+++ b/include/uapi/linux/lustre/lustre_cfg.h
@@ -107,6 +107,7 @@ enum lcfg_command_type {
 	LCFG_SET_PARAM		  = 0x00ce032, /**< use set_param syntax to set
 						 * a proc parameters
 						 */
+	LCFG_NODEMAP_SET_SEPOL	  = 0x00ce05b, /**< set SELinux policy */
 };
 
 struct lustre_cfg_bufs {
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 4236a43..f723d7b 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -805,6 +805,7 @@ struct ptlrpc_body_v2 {
 						 */
 #define OBD_CONNECT2_LOCK_CONVERT	0x80ULL /* IBITS lock convert support */
 #define OBD_CONNECT2_ARCHIVE_ID_ARRAY  0x100ULL	/* store HSM archive_id in array */
+#define OBD_CONNECT2_SELINUX_POLICY    0x400ULL	/* has client SELinux policy */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
-- 
1.8.3.1
