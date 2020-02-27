From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:52 -0500
Subject: [lustre-devel] [PATCH 544/622] lustre: uapi: introduce
 OBD_CONNECT2_CRUSH
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-545-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Introduce a new connect flag OBD_CONNECT2_CRUSH to indicate whether
client or server supports new directory hash type 'crush'.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11025
Lustre-commit: dbafa9df0f8f ("LU-11025 uapi: introduce OBD_CONNECT2_CRUSH")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36774
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Olaf Faaland-LLNL <faaland1@llnl.gov>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c    | 2 +-
 fs/lustre/ptlrpc/wiretest.c            | 2 ++
 include/uapi/linux/lustre/lustre_idl.h | 2 ++
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 893f06d..9772194 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -124,7 +124,7 @@
 	"selinux_policy",	/* 0x400 */
 	"lsom",			/* 0x800 */
 	"pcc",			/* 0x1000 */
-	"plain_layout",		/* 0x2000 */
+	"crush",		/* 0x2000 */
 	"async_discard",	/* 0x4000 */
 	"client_encryption",	/* 0x8000 */
 	NULL
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 9fc7a5b..6c66815 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1158,6 +1158,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_LSOM);
 	LASSERTF(OBD_CONNECT2_PCC == 0x1000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_PCC);
+	LASSERTF(OBD_CONNECT2_CRUSH == 0x2000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_CRUSH);
 	LASSERTF(OBD_CONNECT2_ASYNC_DISCARD == 0x4000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_ASYNC_DISCARD);
 	LASSERTF(OBD_CONNECT2_ENCRYPT == 0x8000ULL, "found 0x%.16llxULL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index a74d979..a69d49a 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -810,6 +810,8 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_SELINUX_POLICY    0x400ULL	/* has client SELinux policy */
 #define OBD_CONNECT2_LSOM	       0x800ULL	/* LSOM support */
 #define OBD_CONNECT2_PCC	       0x1000ULL /* Persistent Client Cache */
+#define OBD_CONNECT2_CRUSH	       0x2000ULL /* crush hash striped directory
+						  */
 #define OBD_CONNECT2_ASYNC_DISCARD     0x4000ULL /* support async DoM data
 						  * discard
 						  */
-- 
1.8.3.1
