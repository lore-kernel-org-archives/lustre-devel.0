From: Nicholas Hanley <nicholasjhanley@gmail.com>
Date: Mon, 07 Nov 2016 19:06:06 -0000
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: use bool
	assignment to true/false
Message-ID: <20161107190138.5730-1-nicholasjhanley@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org, jsimmons@infradead.org
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Nicholas Hanley <nicholasjhanley@gmail.com>

Replace 0 with false in tx_pages_mapped = 0 to be consistent with
the rest of the lustre code.

Signed-off-by: Nicholas Hanley <nicholasjhanley@gmail.com>
---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 13235b0..e2fc65f 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1637,7 +1637,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 {
 	__u64 *pages = tx->tx_pages;
 	bool is_rx = (rd != tx->tx_rd);
-	bool tx_pages_mapped = 0;
+	bool tx_pages_mapped = false;
 	struct kib_fmr_pool *fpo;
 	int npages = 0;
 	__u64 version;
-- 
2.10.2
