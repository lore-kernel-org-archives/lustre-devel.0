From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:10 -0400
Subject: [lustre-devel] [PATCH 18/31] lustre: libcfs: avoid overflow of
 crypto bandwidth calculation
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Gu Zheng <gzheng@ddn.com>

bcount and buf_len are both int, and no force convert in the
calculation code:

tmp = ((bcount * buf_len / jiffies_to_msecs(end - start)) *
       1000) / (1024 * 1024);
That may cause overflow in modern fast machine.

Signed-off-by: Gu Zheng <gzheng@ddn.com>
WC-id: https://jira.whamcloud.com/browse/LU-9116
Reviewed-on: https://review.whamcloud.com/25436
Reviewed-by: Andreas Dilger <adilger@whamclud.com>
Reviewed-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/linux-crypto.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
index 21ff9bf..cfff54d 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux-crypto.c
@@ -313,7 +313,8 @@ static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
 	int buf_len = max(PAGE_SIZE, 1048576UL);
 	void *buf;
 	unsigned long start, end;
-	int bcount, err = 0;
+	unsigned long bcount;
+	int err = 0;
 	struct page *page;
 	unsigned char hash[CFS_CRYPTO_HASH_DIGESTSIZE_MAX];
 	unsigned int hash_len = sizeof(hash);
-- 
1.8.3.1
