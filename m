From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:55 -0500
Subject: [lustre-devel] [PATCH 22/28] lustre: ptlrpc: introduce OST_SEEK RPC
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

For the purposes of SEEK_HOLE/SEEK_DATA support introduce
new OST_SEEK RPC.

Patch add RPC layout, unified handler and connect flag for
compatibility needs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10810
Lustre-commit: 6d5fe29066af5f ("LU-10810 ptlrpc: introduce OST_SEEK RPC")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39707
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_req_layout.h  | 1 +
 fs/lustre/obdclass/lprocfs_status.c    | 1 +
 fs/lustre/ptlrpc/layout.c              | 5 +++++
 fs/lustre/ptlrpc/lproc_ptlrpc.c        | 3 ++-
 fs/lustre/ptlrpc/wiretest.c            | 6 +++++-
 include/uapi/linux/lustre/lustre_idl.h | 2 ++
 6 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 54041b0..434bb08 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -199,6 +199,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_format RQF_OST_SET_INFO_LAST_FID;
 extern struct req_format RQF_OST_GET_INFO_FIEMAP;
 extern struct req_format RQF_OST_LADVISE;
+extern struct req_format RQF_OST_SEEK;
 
 /* LDLM req_format */
 extern struct req_format RQF_LDLM_ENQUEUE;
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index a3c5657..6ce0a5d 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -129,6 +129,7 @@
 	"client_encryption",	/* 0x8000 */
 	"fidmap",		/* 0x10000 */
 	"getattr_pfid",		/* 0x20000 */
+	"lseek",		/* 0x40000 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 4e37bbb..11c0d50 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -777,6 +777,7 @@
 	&RQF_OST_SET_INFO_LAST_FID,
 	&RQF_OST_GET_INFO_FIEMAP,
 	&RQF_OST_LADVISE,
+	&RQF_OST_SEEK,
 	&RQF_LDLM_ENQUEUE,
 	&RQF_LDLM_ENQUEUE_LVB,
 	&RQF_LDLM_CONVERT,
@@ -1611,6 +1612,10 @@ struct req_format RQF_OST_FALLOCATE =
 	DEFINE_REQ_FMT0("OST_FALLOCATE", ost_body_capa, ost_body_only);
 EXPORT_SYMBOL(RQF_OST_FALLOCATE);
 
+struct req_format RQF_OST_SEEK =
+	DEFINE_REQ_FMT0("OST_SEEK", ost_body_only, ost_body_only);
+EXPORT_SYMBOL(RQF_OST_SEEK);
+
 struct req_format RQF_OST_SYNC =
 	DEFINE_REQ_FMT0("OST_SYNC", ost_body_capa, ost_body_only);
 EXPORT_SYMBOL(RQF_OST_SYNC);
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 7276f81..26ca55e 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -67,7 +67,8 @@
 	{ OST_QUOTACTL,				"ost_quotactl" },
 	{ OST_QUOTA_ADJUST_QUNIT,		"ost_quota_adjust_qunit" },
 	{ OST_LADVISE,				"ost_ladvise" },
-	{ OST_FALLOCATE,			"ost_fallocate"},
+	{ OST_FALLOCATE,			"ost_fallocate" },
+	{ OST_SEEK,				"ost_seek" },
 	{ MDS_GETATTR,				"mds_getattr" },
 	{ MDS_GETATTR_NAME,			"mds_getattr_lock" },
 	{ MDS_CLOSE,				"mds_close" },
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 9b1caf4..ba19b78 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -108,7 +108,9 @@ void lustre_assert_wire_constants(void)
 		 (long long)OST_LADVISE);
 	LASSERTF(OST_FALLOCATE == 22, "found %lld\n",
 		 (long long)OST_FALLOCATE);
-	LASSERTF(OST_LAST_OPC == 23, "found %lld\n",
+	LASSERTF(OST_SEEK == 23, "found %lld\n",
+		 (long long)OST_SEEK);
+	LASSERTF(OST_LAST_OPC == 24, "found %lld\n",
 		 (long long)OST_LAST_OPC);
 	LASSERTF(OBD_OBJECT_EOF == 0xffffffffffffffffULL, "found 0x%.16llxULL\n",
 		 OBD_OBJECT_EOF);
@@ -1245,6 +1247,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_FIDMAP);
 	LASSERTF(OBD_CONNECT2_GETATTR_PFID == 0x20000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_GETATTR_PFID);
+	LASSERTF(OBD_CONNECT2_LSEEK == 0x40000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_LSEEK);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 34b2367..f56b3c5 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -838,6 +838,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_ENCRYPT	       0x8000ULL /* client-to-disk encrypt */
 #define OBD_CONNECT2_FIDMAP	      0x10000ULL /* FID map */
 #define OBD_CONNECT2_GETATTR_PFID     0x20000ULL /* pack parent FID in getattr */
+#define OBD_CONNECT2_LSEEK	      0x40000ULL /* SEEK_HOLE/DATA RPC */
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
  * flag value is not in use on some other branch.  Please clear any such
@@ -972,6 +973,7 @@ enum ost_cmd {
 	OST_QUOTA_ADJUST_QUNIT = 20, /* not used since 2.4 */
 	OST_LADVISE	= 21,
 	OST_FALLOCATE	= 22,
+	OST_SEEK	= 23,
 	OST_LAST_OPC /* must be < 33 to avoid MDS_GETATTR */
 };
 #define OST_FIRST_OPC  OST_REPLY
-- 
1.8.3.1
