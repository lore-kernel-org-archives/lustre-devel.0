From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:52 -0500
Subject: [lustre-devel] [PATCH 14/19] staging: lustre: libcfs: fix
	misspelling of descriptor
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Fix typo for correct spelling.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 53b1bf7..68e34b4 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -177,7 +177,7 @@ int cfs_crypto_hash_digest(enum cfs_crypto_hash_alg hash_alg,
 EXPORT_SYMBOL(cfs_crypto_hash_digest);
 
 /**
- * Allocate and initialize desriptor for hash algorithm.
+ * Allocate and initialize descriptor for hash algorithm.
  *
  * This should be used to initialize a hash descriptor for multiple calls
  * to a single hash function when computing the hash across multiple
-- 
1.7.1
