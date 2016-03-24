From: James Simmons <jsimmons@infradead.org>
Date: Thu, 24 Mar 2016 11:24:02 -0400
Subject: [lustre-devel] [PATCH v2] staging: lustre: lnet: revert commit
	4671a0266
Message-ID: <1458833042-23538-1-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Commit 4671a0266 change the parameter of the second parameter of
cfs_precpt_alloc() from a sizeof type to sizeof type *pointer.
This was incorrect in this case and it caused a crash when the LNet
layer was brought up in my testing. The reason is cfs_precpt_alloc()
creates an array of items where the arrays size is equal to the
number of CPTs that exist. Changing to type *pointer only had
cfs_precpt_alloc() create an array of pointers instead of an array
of actual data structures. This patch reverse this change and adds
comments to explain what cfs_precpt_alloc() is actually doing to
avoid potential issues like this again.

Changelog:

v1) Simple revert of the original patch

v2) Added in comments to explain why cfs_precpt_alloc() has the
    arguments it uses.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 89f9390..e89c2a1 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1965,10 +1965,13 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
 	/*
 	 * premapping can fail if ibd_nmr > 1, so we always create
 	 * FMR pool and map-on-demand if premapping failed
+	 *
+	 * cfs_precpt_alloc is creating an array of struct kib_fmr_poolset
+	 * The number of struct kib_fmr_poolsets create is equal to the
+	 * number of CPTs that exist, i.e net->ibn_fmr_ps[cpt].
 	 */
-
 	net->ibn_fmr_ps = cfs_percpt_alloc(lnet_cpt_table(),
-					   sizeof(*net->ibn_fmr_ps));
+					   sizeof(kib_fmr_poolset_t));
 	if (!net->ibn_fmr_ps) {
 		CERROR("Failed to allocate FMR pool array\n");
 		rc = -ENOMEM;
@@ -1991,8 +1994,13 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
 		LASSERT(i == ncpts);
 
  create_tx_pool:
+	/*
+	 * cfs_precpt_alloc is creating an array of struct kib_tx_poolset
+	 * The number of struct kib_tx_poolsets create is equal to the
+	 * number of CPTs that exist, i.e net->ibn_tx_ps[cpt].
+	 */
 	net->ibn_tx_ps = cfs_percpt_alloc(lnet_cpt_table(),
-					  sizeof(*net->ibn_tx_ps));
+					  sizeof(kib_tx_poolset_t));
 	if (!net->ibn_tx_ps) {
 		CERROR("Failed to allocate tx pool array\n");
 		rc = -ENOMEM;
-- 
1.7.1
