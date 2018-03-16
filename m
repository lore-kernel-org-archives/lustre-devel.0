From: Doug Oucharek <dougso@me.com>
Date: Fri, 16 Mar 2018 16:40:21 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: Stop MLX5
 triggering a dump_cqe
Message-ID: <B7D07263-126A-4156-AD60-3A58E8852865@me.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, "Drokin, Oleg" <oleg.drokin@intel.com>, "Dilger, Andreas" <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

We have found that MLX5 will trigger a dump_cqe if we don't
invalidate the rkey on a newly alloated MR for FastReg usage.

This fix just tags the MR as invalid on its creation if we are
using FastReg and that will force it to do an invalidate of the
rkey on first usage.

Signed-off-by: Doug Oucharek <doug.s.oucharek@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8752
Reviewed-on: https://review.whamcloud.com/24306
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: Doug Oucharek <dougso@me.com>
---
drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c | 5 ++++-
1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 7ae2955..00ebc61 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1384,7 +1384,10 @@ static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps, struct kib_fmr_po
			goto out_middle;
		}

-		frd->frd_valid = true;
+		/* There appears to be a bug in MLX5 code where you must
+		 * invalidate the rkey of a new FastReg pool before first
+		 * using it. Thus, I am marking the FRD invalid here. */
+		frd->frd_valid = false;

		list_add_tail(&frd->frd_list, &fpo->fast_reg.fpo_pool_list);
		fpo->fast_reg.fpo_pool_size++;
-- 
1.8.3.1
