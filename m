From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:23 -0500
Subject: [lustre-devel] [PATCH 275/622] lustre: obd: Add overstriping
 CONNECT flag
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-276-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

This patch reserves the OBD_CONNECT flag for overstriping,
and also does some cleanup of OBD_CONNECT flags, putting
them in the correct order and adding some missing ones in
proc and the wire{test,check} checks.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9846
Lustre-commit: 5d085745af43 ("LU-9846 obd: Add overstriping CONNECT flag")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34743
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_export.h      | 5 +++++
 fs/lustre/llite/llite_lib.c            | 6 +++---
 fs/lustre/obdclass/lprocfs_status.c    | 4 ++--
 fs/lustre/ptlrpc/wiretest.c            | 4 ++++
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 5 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/include/lustre_export.h b/fs/lustre/include/lustre_export.h
index c94efb0..967ce37 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -264,6 +264,11 @@ static inline int exp_connect_lockahead(struct obd_export *exp)
 	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_LOCKAHEAD);
 }
 
+static inline int exp_connect_overstriping(struct obd_export *exp)
+{
+	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_OVERSTRIPING);
+}
+
 static inline int exp_connect_flr(struct obd_export *exp)
 {
 	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_FLR);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 8e5cf0a..fd19035 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -212,10 +212,10 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_GRANT_PARAM |
 				  OBD_CONNECT_SHORTIO | OBD_CONNECT_FLAGS2;
 
-	data->ocd_connect_flags2 = OBD_CONNECT2_FLR |
-				   OBD_CONNECT2_LOCK_CONVERT |
-				   OBD_CONNECT2_DIR_MIGRATE |
+	data->ocd_connect_flags2 = OBD_CONNECT2_DIR_MIGRATE |
 				   OBD_CONNECT2_SUM_STATFS |
+				   OBD_CONNECT2_FLR |
+				   OBD_CONNECT2_LOCK_CONVERT |
 				   OBD_CONNECT2_ARCHIVE_ID_ARRAY |
 				   OBD_CONNECT2_LSOM;
 
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index a7c274a..55057cf 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -114,8 +114,8 @@
 	"file_secctx",	/* 0x01 */
 	"lockaheadv2",	/* 0x02 */
 	"dir_migrate",	/* 0x04 */
-	"unknown",	/* 0x08 */
-	"unknown",	/* 0x10 */
+	"sum_statfs",	/* 0x08 */
+	"overstriping",	/* 0x10 */
 	"flr",		/* 0x20 */
 	"wbc",		/* 0x40 */
 	"lock_convert",	/* 0x80 */
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 4a268f6..fb57def 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1136,6 +1136,10 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_LOCKAHEAD);
 	LASSERTF(OBD_CONNECT2_DIR_MIGRATE == 0x4ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_DIR_MIGRATE);
+	LASSERTF(OBD_CONNECT2_SUM_STATFS == 0x8ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_SUM_STATFS);
+	LASSERTF(OBD_CONNECT2_OVERSTRIPING == 0x10ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_OVERSTRIPING);
 	LASSERTF(OBD_CONNECT2_FLR == 0x20ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_FLR);
 	LASSERTF(OBD_CONNECT2_WBC_INTENTS == 0x40ULL, "found 0x%.16llxULL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 3a2a093..bba3a77 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -797,6 +797,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_DIR_MIGRATE	0x4ULL		/* migrate striped dir
 							 */
 #define OBD_CONNECT2_SUM_STATFS		0x8ULL /* MDT return aggregated stats */
+#define OBD_CONNECT2_OVERSTRIPING	0x10ULL /* OST overstriping support */
 #define OBD_CONNECT2_FLR		0x20ULL		/* FLR support */
 #define OBD_CONNECT2_WBC_INTENTS	0x40ULL /* create/unlink/... intents
 						 * for wbc, also operations
-- 
1.8.3.1
