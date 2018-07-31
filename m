From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:12 -0400
Subject: [lustre-devel] [PATCH 20/31] lustre: llite: Remove
 OBD_FAIL_OSC_CONNECT_CKSUM
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Abrarahmed Momin <abrar.habib@seagate.com>

Remove OBD_FAIL_OSC_CONNECT_CKSUM as all clients and servers
since 1.8 support OBD_CONNECT_CKSUM. No reason to check
interoperability with older servers anymore.

Signed-off-by: Abrarahmed Momin <abrar.habib@seagate.com>
Seagate-bug-id: MRP-1421
WC-id: https://jira.whamcloud.com/browse/LU-5361
Reviewed-on: https://review.whamcloud.com/23644
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/obd_support.h    |  2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 22 ++++++++++------------
 drivers/staging/lustre/lustre/ptlrpc/import.c      |  5 ++---
 3 files changed, 13 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 726cc4d..80b9935 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -312,7 +312,7 @@
 #define OBD_FAIL_OSC_CHECKSUM_RECEIVE    0x408
 #define OBD_FAIL_OSC_CHECKSUM_SEND       0x409
 #define OBD_FAIL_OSC_BRW_PREP_REQ2       0x40a
-#define OBD_FAIL_OSC_CONNECT_CKSUM       0x40b
+/* #define OBD_FAIL_OSC_CONNECT_CKSUM	 0x40b Obsolete since 2.9 */
 #define OBD_FAIL_OSC_CKSUM_ADLER_ONLY    0x40c
 #define OBD_FAIL_OSC_DIO_PAUSE	   0x40d
 #define OBD_FAIL_OSC_OBJECT_CONTENTION   0x40e
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index ccb5bda..cd5b064 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -395,19 +395,17 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	if (!OBD_FAIL_CHECK(OBD_FAIL_OSC_CONNECT_GRANT_PARAM))
 		data->ocd_connect_flags |= OBD_CONNECT_GRANT_PARAM;
 
-	if (!OBD_FAIL_CHECK(OBD_FAIL_OSC_CONNECT_CKSUM)) {
-		/* OBD_CONNECT_CKSUM should always be set, even if checksums are
-		 * disabled by default, because it can still be enabled on the
-		 * fly via /sys. As a consequence, we still need to come to an
-		 * agreement on the supported algorithms at connect time
-		 */
-		data->ocd_connect_flags |= OBD_CONNECT_CKSUM;
+	/* OBD_CONNECT_CKSUM should always be set, even if checksums are
+	 * disabled by default, because it can still be enabled on the
+	 * fly via /sys. As a consequence, we still need to come to an
+	 * agreement on the supported algorithms at connect time
+	 */
+	data->ocd_connect_flags |= OBD_CONNECT_CKSUM;
 
-		if (OBD_FAIL_CHECK(OBD_FAIL_OSC_CKSUM_ADLER_ONLY))
-			data->ocd_cksum_types = OBD_CKSUM_ADLER;
-		else
-			data->ocd_cksum_types = cksum_types_supported_client();
-	}
+	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_CKSUM_ADLER_ONLY))
+		data->ocd_cksum_types = OBD_CKSUM_ADLER;
+	else
+		data->ocd_cksum_types = cksum_types_supported_client();
 
 	data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 4db0d89..07dc87d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -814,12 +814,11 @@ static int ptlrpc_connect_set_flags(struct obd_import *imp,
 		 * the checksum types it doesn't support
 		 */
 		if (!(ocd->ocd_cksum_types & cksum_types_supported_client())) {
-			LCONSOLE_WARN("The negotiation of the checksum algorithm to use with server %s failed (%x/%x), disabling checksums\n",
+			LCONSOLE_ERROR("The negotiation of the checksum algorithm to use with server %s failed (%x/%x), disabling checksums\n",
 				      obd2cli_tgt(imp->imp_obd),
 				      ocd->ocd_cksum_types,
 				      cksum_types_supported_client());
-			cli->cl_checksum = 0;
-			cli->cl_supp_cksum_types = OBD_CKSUM_ADLER;
+			return -EPROTO;
 		} else {
 			cli->cl_supp_cksum_types = ocd->ocd_cksum_types;
 		}
-- 
1.8.3.1
