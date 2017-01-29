From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:13 -0500
Subject: [lustre-devel] [PATCH 45/60] staging: lustre: libcfs: Change
	positional struct initializers to C99
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-46-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Steve Guminski <stephenx.guminski@intel.com>, James Simmons <jsimmons@infradead.org>

From: Steve Guminski <stephenx.guminski@intel.com>

This patch makes no functional changes. Struct initializers in the
libcfs directory that use C89 or GCC-only syntax are updated to C99
syntax.

The C99 syntax prevents incorrect initialization if values are
accidently placed in the wrong position, allows changes in the struct
definition, and clears any members that are not given an explicit
value.

The following struct initializers have been updated:

libcfs/include/libcfs/libcfs_crypto.h:
        static struct cfs_crypto_hash_type hash_types[]

Signed-off-by: Steve Guminski <stephenx.guminski@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6210
Reviewed-on: https://review.whamcloud.com/23332
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_crypto.h    | 60 ++++++++++++++++++----
 1 file changed, 50 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
index 8f34c5d..3f773a4 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
@@ -53,16 +53,56 @@ enum cfs_crypto_hash_alg {
 };
 
 static struct cfs_crypto_hash_type hash_types[] = {
-	[CFS_HASH_ALG_NULL]    = { "null",     0,      0 },
-	[CFS_HASH_ALG_ADLER32] = { "adler32",  1,      4 },
-	[CFS_HASH_ALG_CRC32]   = { "crc32",   ~0,      4 },
-	[CFS_HASH_ALG_CRC32C]  = { "crc32c",  ~0,      4 },
-	[CFS_HASH_ALG_MD5]     = { "md5",      0,     16 },
-	[CFS_HASH_ALG_SHA1]    = { "sha1",     0,     20 },
-	[CFS_HASH_ALG_SHA256]  = { "sha256",   0,     32 },
-	[CFS_HASH_ALG_SHA384]  = { "sha384",   0,     48 },
-	[CFS_HASH_ALG_SHA512]  = { "sha512",   0,     64 },
-	[CFS_HASH_ALG_MAX]	= { NULL,	0,	64 },
+	[CFS_HASH_ALG_NULL] = {
+		.cht_name	= "null",
+		.cht_key	= 0,
+		.cht_size	= 0
+	},
+	[CFS_HASH_ALG_ADLER32] = {
+		.cht_name	= "adler32",
+		.cht_key	= 1,
+		.cht_size	= 4
+	},
+	[CFS_HASH_ALG_CRC32] = {
+		.cht_name	= "crc32",
+		.cht_key	= ~0,
+		.cht_size	= 4
+	},
+	[CFS_HASH_ALG_CRC32C] = {
+		.cht_name	= "crc32c",
+		.cht_key	= ~0,
+		.cht_size	= 4
+	},
+	[CFS_HASH_ALG_MD5] = {
+		.cht_name	= "md5",
+		.cht_key	= 0,
+		.cht_size	= 16
+	},
+	[CFS_HASH_ALG_SHA1] = {
+		.cht_name	= "sha1",
+		.cht_key	= 0,
+		.cht_size	= 20
+	},
+	[CFS_HASH_ALG_SHA256] = {
+		.cht_name	= "sha256",
+		.cht_key	= 0,
+		.cht_size	= 32
+	},
+	[CFS_HASH_ALG_SHA384] = {
+		.cht_name	= "sha384",
+		.cht_key	= 0,
+		.cht_size	= 48
+	},
+	[CFS_HASH_ALG_SHA512] = {
+		.cht_name	= "sha512",
+		.cht_key	= 0,
+		.cht_size	= 64
+	},
+	[CFS_HASH_ALG_MAX] = {
+		.cht_name	= NULL,
+		.cht_key	= 0,
+		.cht_size	= 64
+	},
 };
 
 /* Maximum size of hash_types[].cht_size */
-- 
1.8.3.1
