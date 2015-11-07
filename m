From: Shraddha Barke <shraddha.6596@gmail.com>
Date: Sat,  7 Nov 2015 11:16:39 +0530
Subject: [lustre-devel] [PATCH] Staging: lustre: obd_cksum.h: Remove unused
	cksum_types_supported_server
Message-ID: <1446875199-15537-1-git-send-email-shraddha.6596@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

cksum_types_supported_server is defined in header file but not used
anywhere. Hence remove it.

Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
---
 drivers/staging/lustre/lustre/include/obd_cksum.h | 23 -----------------------
 1 file changed, 23 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_cksum.h b/drivers/staging/lustre/lustre/include/obd_cksum.h
index a0099d7..01db604 100644
--- a/drivers/staging/lustre/lustre/include/obd_cksum.h
+++ b/drivers/staging/lustre/lustre/include/obd_cksum.h
@@ -133,29 +133,6 @@ static inline cksum_type_t cksum_types_supported_client(void)
 	return ret;
 }
 
-/* Server uses algos that perform at 50% or better of the Adler */
-static inline cksum_type_t cksum_types_supported_server(void)
-{
-	int	     base_speed;
-	cksum_type_t    ret = OBD_CKSUM_ADLER;
-
-	CDEBUG(D_INFO, "Crypto hash speed: crc %d, crc32c %d, adler %d\n",
-	       cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32)),
-	       cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32C)),
-	       cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_ADLER)));
-
-	base_speed = cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_ADLER)) / 2;
-
-	if (cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32C)) >=
-	    base_speed)
-		ret |= OBD_CKSUM_CRC32C;
-	if (cfs_crypto_hash_speed(cksum_obd2cfs(OBD_CKSUM_CRC32)) >=
-	    base_speed)
-		ret |= OBD_CKSUM_CRC32;
-
-	return ret;
-}
-
 /* Select the best checksum algorithm among those supplied in the cksum_types
  * input.
  *
-- 
2.1.4
