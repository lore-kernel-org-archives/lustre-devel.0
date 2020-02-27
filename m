From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:16 -0500
Subject: [lustre-devel] [PATCH 508/622] lustre: sec: reserve flags for
 client side encryption
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-509-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Reserve OBD_CONNECT2_ENC connection flag so that 'encrypt' or
'test_dummy_encryption' client mount options can only be used if
server side knows how to handle encrypted object size properly.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: 4f9632f97011 ("LU-12275 sec: reserve flags for client side encryption")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/36360
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c    | 1 +
 fs/lustre/ptlrpc/wiretest.c            | 2 ++
 include/uapi/linux/lustre/lustre_idl.h | 8 ++++----
 3 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index ca169ec..98d1e3b 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -126,6 +126,7 @@
 	"pcc",			/* 0x1000 */
 	"plain_layout",		/* 0x2000 */
 	"async_discard",	/* 0x4000 */
+	"client_encryption",	/* 0x8000 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index c0b4ad9..da51dc1 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1160,6 +1160,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_PCC);
 	LASSERTF(OBD_CONNECT2_ASYNC_DISCARD == 0x4000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_ASYNC_DISCARD);
+	LASSERTF(OBD_CONNECT2_ENCRYPT == 0x8000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_ENCRYPT);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index d4b29d8..4277ac6 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -813,15 +813,15 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_ASYNC_DISCARD     0x4000ULL /* support async DoM data
 						  * discard
 						  */
-
+#define OBD_CONNECT2_ENCRYPT	       0x8000ULL /* client-to-disk encrypt */
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
  * flag value is not in use on some other branch.  Please clear any such
  * changes with senior engineers before starting to use a new flag.  Then,
  * submit a small patch against EVERY branch that ONLY adds the new flag,
- * updates obd_connect_names[] for lprocfs_rd_connect_flags(), adds the
- * flag to check_obd_connect_data(), and updates wiretests accordingly, so it
- * can be approved and landed easily to reserve the flag for future use.
+ * updates obd_connect_names[], adds the flag to check_obd_connect_data(),
+ * and updates wiretests accordingly, so it can be approved and landed easily
+ * to reserve the flag for future use.
  */
 
 /* The MNE_SWAB flag is overloading the MDS_MDS bit only for the MGS
-- 
1.8.3.1
