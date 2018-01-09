From: NeilBrown <neilb@suse.com>
Date: Tue, 09 Jan 2018 12:19:38 +1100
Subject: [lustre-devel] [PATCH 09/14] staging: lustre: lnet-route: use
 kmalloc for small allocation
In-Reply-To: <151546052331.9776.7408338350463291753.stgit@noble>
References: <151546052331.9776.7408338350463291753.stgit@noble>
Message-ID: <151546077849.9776.5734351152485517837.stgit@noble>
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
index 409244e57a31..476d6d296037 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -884,8 +884,7 @@ lnet_destroy_rc_data(struct lnet_rc_data *rcd)
 		lnet_net_unlock(cpt);
 	}
 
-	if (rcd->rcd_pinginfo)
-		LIBCFS_FREE(rcd->rcd_pinginfo, LNET_PINGINFO_SIZE);
+	kfree(rcd->rcd_pinginfo);
 
 	kfree(rcd);
 }
@@ -908,7 +907,7 @@ lnet_create_rc_data_locked(struct lnet_peer *gateway)
 	LNetInvalidateMDHandle(&rcd->rcd_mdh);
 	INIT_LIST_HEAD(&rcd->rcd_list);
 
-	LIBCFS_ALLOC(pi, LNET_PINGINFO_SIZE);
+	pi = kzalloc(LNET_PINGINFO_SIZE, GFP_NOFS);
 	if (!pi)
 		goto out;
 
