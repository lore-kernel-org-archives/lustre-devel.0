From: Tabrez khan <khan.tabrez21@gmail.com>
Date: Thu, 29 Dec 2016 17:50:48 +0530
Subject: [lustre-devel] [PATCH] staging : lustre : Remove braces from single
	line body.
Message-ID: <1483014048-3262-1-git-send-email-khan.tabrez21@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: andreas.dilger@intel.com, jsimmons@infradead.org, oleg.drokin@intel.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Remove unnecessary braces from single line if statement.
This warning is found using checkpatch.pl.

Signed-off-by: Tabrez khan <khan.tabrez21@gmail.com>
---
 drivers/staging/lustre/lustre/osc/lproc_osc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index f0062d4..098ef1e 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -585,9 +585,9 @@ static ssize_t max_pages_per_rpc_store(struct kobject *kobj,
 	chunk_mask = ~((1 << (cli->cl_chunkbits - PAGE_SHIFT)) - 1);
 	/* max_pages_per_rpc must be chunk aligned */
 	val = (val + ~chunk_mask) & chunk_mask;
-	if (val == 0 || val > ocd->ocd_brw_size >> PAGE_SHIFT) {
+	if (val == 0 || val > ocd->ocd_brw_size >> PAGE_SHIFT)
 		return -ERANGE;
-	}
+
 	spin_lock(&cli->cl_loi_list_lock);
 	cli->cl_max_pages_per_rpc = val;
 	client_adjust_max_dirty(cli);
-- 
2.7.4
