From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:52 -0400
Subject: [lustre-devel] [PATCH 13/42] lustre: ptlrpc: prefer crc32_le() over
 CryptoAPI
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Prefer to call the crc32_le() library function directly if available,
instead of cfs_crypto_hash(CFS_HASH_ALG_CRC32). It is about 10x faster
for the 156-byte struct ptlrpc_body being checked in this function.
A test of small buffers in that compares the two implementations, run
on a 2.9GHz Core i7-7820 shows the difference is significant here:

  buffer size   156 bytes   1536 bytes   4096 bytes     1 MiB
  -----------+------------+------------+-----------+-----------
  cfs_crypto |  182 MiB/s | 1794 MiB/s | 4163 MB/s | 9631 MiB/s
  crc32_le   | 1947 MiB/s | 1871 MiB/s | 1867 MB/s | 1823 MiB/s

This corresponds to 10x faster or 1/10 as many cycles for ptlrpc_body.
The CryptoAPI speed crosses over around 1536 bytes, which is still 10x
larger than the ptlrpc_body size, so it is unlikely to be faster here.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13127
Lustre-commit: 1dda0ef6a70b2 ("LU-13127 ptlrpc: prefer crc32_le() over CryptoAPI")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39614
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/pack_generic.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index cbb65ce..fbed952 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -41,9 +41,7 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
-#ifndef CONFIG_CRYPTO_CRC32
 #include <linux/crc32.h>
-#endif
 
 #include <uapi/linux/lustre/lustre_fiemap.h>
 
@@ -1240,15 +1238,16 @@ u32 lustre_msg_calc_cksum(struct lustre_msg *msg, u32 buf)
 		struct ptlrpc_body *pb = lustre_msg_buf_v2(msg, buf, 0);
 		u32 len = lustre_msg_buflen(msg, buf);
 		u32 crc;
-#ifdef CONFIG_CRYPTO_CRC32
+
+#if IS_ENABLED(CONFIG_CRC32)
+		/* about 10x faster than crypto_hash for small buffers */
+		crc = crc32_le(~(__u32)0, (unsigned char *)pb, len);
+#elif IS_ENABLED(CONFIG_CRYPTO_CRC32)
 		unsigned int hsize = 4;
 
 		cfs_crypto_hash_digest(CFS_HASH_ALG_CRC32, (unsigned char *)pb,
-				       lustre_msg_buflen(msg,
-							 MSG_PTLRPC_BODY_OFF),
-				       NULL, 0, (unsigned char *)&crc, &hsize);
-#else
-		crc = crc32_le(~(__u32)0, (unsigned char *)pb, len);
+				       len, NULL, 0, (unsigned char *)&crc,
+				       &hsize);
 #endif
 		return crc;
 	}
-- 
1.8.3.1
