From: NeilBrown <neilb@suse.com>
Date: Fri, 07 Sep 2018 10:49:32 +1000
Subject: [lustre-devel] [PATCH 23/34] lnet: don't need lock to test
 ln_shutdown.
In-Reply-To: <153628058697.8267.6056114844033479774.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
Message-ID: <153628137216.8267.15666994772553520296.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

ln_shutdown returns -ESHUTDOWN if ln_shutdown
is already set.
The lock is always taken to set ln_shutdown, but apparently
we don't need to hold the lock for this test.
I guess if it is set immediately after the test, and before
we take the lock then.... can anything bad happen?

This is part of
    8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
       LU-7734 lnet: Multi-Rail local NI split

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 60f34c4b85d3..46e593fbb44f 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1099,12 +1099,9 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
 	cpt = lnet_cpt_of_nid(rtr_nid == LNET_NID_ANY ? dst_nid : rtr_nid,
 			      local_ni);
  again:
-	lnet_net_lock(cpt);
-
-	if (the_lnet.ln_shutdown) {
-		lnet_net_unlock(cpt);
+	if (the_lnet.ln_shutdown)
 		return -ESHUTDOWN;
-	}
+	lnet_net_lock(cpt);
 
 	if (src_nid == LNET_NID_ANY) {
 		src_ni = NULL;
