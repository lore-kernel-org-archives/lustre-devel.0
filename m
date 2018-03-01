From: NeilBrown <neilb@suse.com>
Date: Fri, 02 Mar 2018 10:31:25 +1100
Subject: [lustre-devel] [PATCH 05/17] staging: lustre: lnet: keep
 ln_nportals consistent
In-Reply-To: <151994679573.7628.1024109499321778846.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
Message-ID: <151994708521.7628.13905456558048566520.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

ln_nportals should be zero when no portals have
been allocated.  This ensures that memory allocation failure
is handled correctly elsewhere.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/lib-ptl.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 471f2f6c86f4..fc47379c5938 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -841,6 +841,7 @@ lnet_portals_destroy(void)
 
 	cfs_array_free(the_lnet.ln_portals);
 	the_lnet.ln_portals = NULL;
+	the_lnet.ln_nportals = 0;
 }
 
 int
@@ -851,12 +852,12 @@ lnet_portals_create(void)
 
 	size = offsetof(struct lnet_portal, ptl_mt_maps[LNET_CPT_NUMBER]);
 
-	the_lnet.ln_nportals = MAX_PORTALS;
-	the_lnet.ln_portals = cfs_array_alloc(the_lnet.ln_nportals, size);
+	the_lnet.ln_portals = cfs_array_alloc(MAX_PORTALS, size);
 	if (!the_lnet.ln_portals) {
 		CERROR("Failed to allocate portals table\n");
 		return -ENOMEM;
 	}
+	the_lnet.ln_nportals = MAX_PORTALS;
 
 	for (i = 0; i < the_lnet.ln_nportals; i++) {
 		if (lnet_ptl_setup(the_lnet.ln_portals[i], i)) {
