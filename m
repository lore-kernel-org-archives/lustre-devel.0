From: James Simmons <jsimmons@infradead.org>
Date: Mon,  9 May 2016 10:53:47 -0400
Subject: [lustre-devel] [PATCH 3/4] staging: lustre: libcfs: fix memort leak
	in libcfs crypto layer
In-Reply-To: <1462805628-23403-1-git-send-email-jsimmons@infradead.org>
References: <1462805628-23403-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462805628-23403-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

During code review Boyko discovered a memory leak. This
patch fixes that leak.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4423
Reviewed-on: http://review.whamcloud.com/19716
Reviewed-by: Alexander Boyko <alexander.boyko@seagate.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 84f9b7b..5c0116a 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -99,6 +99,7 @@ static int cfs_crypto_hash_alloc(enum cfs_crypto_hash_alg hash_alg,
 					 (*type)->cht_size);
 
 	if (err != 0) {
+		ahash_request_free(*req);
 		crypto_free_ahash(tfm);
 		return err;
 	}
-- 
1.7.1
