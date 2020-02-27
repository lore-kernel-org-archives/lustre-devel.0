From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:18 -0500
Subject: [lustre-devel] [PATCH 210/622] lustre: Ensure crc-t10pi is enabled.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-211-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Also simplify check_write_checksum code a little - the var isn't needed.

Fixes: 86e186db3ed ("lustre: osc: T10PI between RPC and BIO")
WC-bug-id: https://jira.whamcloud.com/browse/LU-11770
Lustre-commit: e0fb3133372e ("LU-11770 osc: allow build without blk_integrity or crc-t10pi")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33923
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/Kconfig           |  1 +
 fs/lustre/osc/osc_request.c | 14 +++-----------
 2 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/Kconfig b/fs/lustre/Kconfig
index 2eb7e45..bc89565 100644
--- a/fs/lustre/Kconfig
+++ b/fs/lustre/Kconfig
@@ -9,6 +9,7 @@ config LUSTRE_FS
 	select CRYPTO_SHA1
 	select CRYPTO_SHA256
 	select CRYPTO_SHA512
+	select CRC_T10DIF
 	select DEBUG_FS
 	select FHANDLE
 	select QUOTA
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index ba84bd1..6ce22c3 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1638,7 +1638,6 @@ static int check_write_checksum(struct obdo *oa,
 	const char *obd_name = aa->aa_cli->cl_import->imp_obd->obd_name;
 	obd_dif_csum_fn *fn = NULL;
 	int sector_size = 0;
-	bool t10pi = false;
 	u32 new_cksum;
 	char *msg;
 	enum cksum_type cksum_type;
@@ -1658,22 +1657,18 @@ static int check_write_checksum(struct obdo *oa,
 
 	switch (cksum_type) {
 	case OBD_CKSUM_T10IP512:
-		t10pi = true;
 		fn = obd_dif_ip_fn;
 		sector_size = 512;
 		break;
 	case OBD_CKSUM_T10IP4K:
-		t10pi = true;
 		fn = obd_dif_ip_fn;
 		sector_size = 4096;
 		break;
 	case OBD_CKSUM_T10CRC512:
-		t10pi = true;
 		fn = obd_dif_crc_fn;
 		sector_size = 512;
 		break;
 	case OBD_CKSUM_T10CRC4K:
-		t10pi = true;
 		fn = obd_dif_crc_fn;
 		sector_size = 4096;
 		break;
@@ -1681,13 +1676,10 @@ static int check_write_checksum(struct obdo *oa,
 		break;
 	}
 
-	if (t10pi)
+	if (fn)
 		rc = osc_checksum_bulk_t10pi(obd_name, aa->aa_requested_nob,
-					     aa->aa_page_count,
-					     aa->aa_ppga,
-					     OST_WRITE,
-					     fn,
-					     sector_size,
+					     aa->aa_page_count, aa->aa_ppga,
+					     OST_WRITE, fn, sector_size,
 					     &new_cksum);
 	else
 		rc = osc_checksum_bulk(aa->aa_requested_nob, aa->aa_page_count,
-- 
1.8.3.1
