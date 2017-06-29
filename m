From: Dmitriy Cherkasov <dmitriy@oss-tech.org>
Date: Wed, 28 Jun 2017 21:42:36 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: remove dead code
Message-ID: <1498711356-14270-1-git-send-email-dmitriy@oss-tech.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitriy Cherkasov <dmitriy@oss-tech.org>

Remove code which was permanently disabled with ifdefs.

This also resolves the following checkpatch warning which was
triggered by the dead code:

WARNING: space prohibited before semicolon

Signed-off-by: Dmitriy Cherkasov <dmitriy@oss-tech.org>
---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 5540de6..7c487fa 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -521,13 +521,7 @@ struct ksock_proto {
 
 static inline __u32 ksocknal_csum(__u32 crc, unsigned char const *p, size_t len)
 {
-#if 1
 	return crc32_le(crc, p, len);
-#else
-	while (len-- > 0)
-		crc = ((crc + 0x100) & ~0xff) | ((crc + *p++) & 0xff) ;
-	return crc;
-#endif
 }
 
 static inline int
-- 
1.9.1
