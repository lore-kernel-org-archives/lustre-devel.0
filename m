From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 11:46:30 +1100
Subject: [lustre-devel] [PATCH 11/15] staging: lustre: lnet-route: use
 kmalloc for small allocation
In-Reply-To: <151355781721.6200.2136335532722530242.stgit@noble>
References: <151355781721.6200.2136335532722530242.stgit@noble>
Message-ID: <151355799060.6200.12666775662373842922.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

This allocation is reasonably small.
As the function is called "*_locked", it might not be safe
to perform a GFP_KERNEL allocation, so be safe and
use GFP_NOFS.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/router.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 86f28152f7b3..c40aa79baf5c 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -889,8 +889,7 @@ lnet_destroy_rc_data(struct lnet_rc_data *rcd)
 		lnet_net_unlock(cpt);
 	}
 
-	if (rcd->rcd_pinginfo)
-		LIBCFS_FREE(rcd->rcd_pinginfo, LNET_PINGINFO_SIZE);
+	kfree(rcd->rcd_pinginfo);
 
 	kfree(rcd);
 }
@@ -913,7 +912,7 @@ lnet_create_rc_data_locked(struct lnet_peer *gateway)
 	LNetInvalidateMDHandle(&rcd->rcd_mdh);
 	INIT_LIST_HEAD(&rcd->rcd_list);
 
-	LIBCFS_ALLOC(pi, LNET_PINGINFO_SIZE);
+	pi = kzalloc(LNET_PINGINFO_SIZE, GFP_NOFS);
 	if (!pi)
 		goto out;
 
