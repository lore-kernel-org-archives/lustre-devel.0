From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:05 -0500
Subject: [lustre-devel] [PATCH 257/622] lustre: lsom: Add an
 OBD_CONNECT2_LSOM connect flag
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-258-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

Add an OBD_CONNECT2_LSOM connect flag so that clients do not send
MDS_ATTR_LSIZE and MDS_ATTR_LBLOCKS flags to the old servers that
do not support them.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12021
Lustre-commit: fdd2c5d3a6e5 ("LU-12021 lsom: Add an OBD_CONNECT2_LSOM connect flag")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/34343
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Aurelien Degremont <degremoa@amazon.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c            | 3 ++-
 fs/lustre/mdc/mdc_request.c            | 4 ++++
 fs/lustre/obdclass/lprocfs_status.c    | 4 +++-
 fs/lustre/ptlrpc/wiretest.c            | 2 ++
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 5 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 57486b4..347bdd6 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -216,7 +216,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT2_LOCK_CONVERT |
 				   OBD_CONNECT2_DIR_MIGRATE |
 				   OBD_CONNECT2_SUM_STATFS |
-				   OBD_CONNECT2_ARCHIVE_ID_ARRAY;
+				   OBD_CONNECT2_ARCHIVE_ID_ARRAY |
+				   OBD_CONNECT2_LSOM;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index f197abc..5931bc1 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -945,6 +945,10 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 	req->rq_request_portal = MDS_READPAGE_PORTAL;
 	ptlrpc_at_set_req_timeout(req);
 
+	if (!(exp_connect_flags2(exp) & OBD_CONNECT2_LSOM))
+		op_data->op_xvalid &= ~(OP_XVALID_LAZYSIZE |
+					OP_XVALID_LAZYBLOCKS);
+
 	mdc_close_pack(req, op_data);
 
 	req_capsule_set_size(&req->rq_pill, &RMF_MDT_MD, RCL_SERVER,
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 7701bc3..cdf25ed 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -120,7 +120,9 @@
 	"wbc",		/* 0x40 */
 	"lock_convert",	/* 0x80 */
 	"archive_id_array",	/* 0x100 */
-	"selinux_policy",	/* 0x200 */
+	"unknown",		/* 0x200 */
+	"selinux_policy",	/* 0x400 */
+	"lsom",			/* 0x800 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index bf79b8b..7cb6d74 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1146,6 +1146,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_ARCHIVE_ID_ARRAY);
 	LASSERTF(OBD_CONNECT2_SELINUX_POLICY == 0x400ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_SELINUX_POLICY);
+	LASSERTF(OBD_CONNECT2_LSOM == 0x800ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_LSOM);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 1a1b6c6..6b9a623 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -806,6 +806,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_LOCK_CONVERT	0x80ULL /* IBITS lock convert support */
 #define OBD_CONNECT2_ARCHIVE_ID_ARRAY  0x100ULL	/* store HSM archive_id in array */
 #define OBD_CONNECT2_SELINUX_POLICY    0x400ULL	/* has client SELinux policy */
+#define OBD_CONNECT2_LSOM	       0x800ULL	/* LSOM support */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
-- 
1.8.3.1
