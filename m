From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:11 -0400
Subject: [lustre-devel] [PATCH 15/41] staging: lustre: osc: fix bug when
	setting max_pages_per_rpc
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Wu Libin <lwu@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Wu Libin <lwu@ddn.com>

After setting like "lctl set_param -P osc.*.max_pages_per_rpc", it
is possible that the function osc_obd_max_pages_per_rpc_seq_write
will be called before ocd_brw_size has been set when mount.
ocd_brw_size is meaningless when it is zero. So it should not be
the limit at that time.

Signed-off-by: Wu Libin <lwu@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6421
Reviewed-on: http://review.whamcloud.com/14333
Reviewed-by: Emoly Liu <emoly.liu@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/lproc_osc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index f0062d4..a837362 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -585,7 +585,8 @@ static ssize_t max_pages_per_rpc_store(struct kobject *kobj,
 	chunk_mask = ~((1 << (cli->cl_chunkbits - PAGE_SHIFT)) - 1);
 	/* max_pages_per_rpc must be chunk aligned */
 	val = (val + ~chunk_mask) & chunk_mask;
-	if (val == 0 || val > ocd->ocd_brw_size >> PAGE_SHIFT) {
+	if (!val || (ocd->ocd_brw_size &&
+		     val > ocd->ocd_brw_size >> PAGE_SHIFT)) {
 		return -ERANGE;
 	}
 	spin_lock(&cli->cl_loi_list_lock);
-- 
1.7.1
