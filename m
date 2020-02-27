From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:06 -0500
Subject: [lustre-devel] [PATCH 258/622] lustre: pcc: Reserve a new
 connection flag for PCC
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-259-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

Reserve OBD_CONNECT2_PCC connection flag that will be set
(in ocd_connect_flags2) if a Lustre server or a client supports
Persistent Client Cache (PCC).

WC-bug-id: https://jira.whamcloud.com/browse/LU-10092
Lustre-commit: 93aa68404669 ("LU-10092 pcc: Reserve a new connection flag for PCC")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/34356
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c    | 1 +
 fs/lustre/ptlrpc/wiretest.c            | 2 ++
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 3 files changed, 4 insertions(+)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index cdf25ed..254a600 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -123,6 +123,7 @@
 	"unknown",		/* 0x200 */
 	"selinux_policy",	/* 0x400 */
 	"lsom",			/* 0x800 */
+	"pcc",			/* 0x1000 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 7cb6d74..22447e2 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1148,6 +1148,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_SELINUX_POLICY);
 	LASSERTF(OBD_CONNECT2_LSOM == 0x800ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_LSOM);
+	LASSERTF(OBD_CONNECT2_PCC == 0x1000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_PCC);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 6b9a623..46c3369 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -807,6 +807,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_ARCHIVE_ID_ARRAY  0x100ULL	/* store HSM archive_id in array */
 #define OBD_CONNECT2_SELINUX_POLICY    0x400ULL	/* has client SELinux policy */
 #define OBD_CONNECT2_LSOM	       0x800ULL	/* LSOM support */
+#define OBD_CONNECT2_PCC	       0x1000ULL /* Persistent Client Cache */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
-- 
1.8.3.1
