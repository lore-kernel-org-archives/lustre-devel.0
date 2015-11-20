From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:36:14 -0500
Subject: [lustre-devel] [PATCH 38/40] staging: lustre: Allocate the correct
	number of rtr buffers
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-39-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

This patch ensures that the correct number of router buffers are
allocated.  It keeps a count that keeps track of the number of
buffers allocated.  Another count keeps the number of buffers
requested. The number of buffers allocated is set when creating
new buffers and reduced when buffers are freed.

The number of requested buffer is set when the buffers are
allocated and is checked when credits are returned to determine
whether the buffer should be freed or kept.

In lnet_rtrpool_adjust_bufs() grab lnet_net_lock() before using
rbp_nbuffers to ensure that it doesn't change by
lnet_return_rx_credits_locked() during the process of allocating
new buffers.  All other access to rbp_nbuffers is already being
protected by lnet_net_lock().

This avoids the case where we allocate less than the desired
number of buffers.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6122
Reviewed-on: http://review.whamcloud.com/13519
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    5 ++-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    3 +-
 drivers/staging/lustre/lnet/lnet/router.c          |   32 +++++++++++++++-----
 3 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 695b5be..24b3c1a 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -386,7 +386,10 @@ typedef struct {
 	struct list_head	rbp_msgs;	/* messages blocking
 						   for a buffer */
 	int			rbp_npages;	/* # pages in each buffer */
-	int			rbp_nbuffers;	/* # buffers */
+	/* requested number of buffers */
+	int			rbp_req_nbuffers;
+	/* # buffers actually allocated */
+	int			rbp_nbuffers;
 	int			rbp_credits;	/* # free buffers /
 						     blocked messages */
 	int			rbp_mincredits;	/* low water mark */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 430cb9a..21a7c6f 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1101,9 +1101,10 @@ lnet_return_rx_credits_locked(lnet_msg_t *msg)
 		 * buffers in this pool.  Make sure we never put back
 		 * more buffers than the stated number.
 		 */
-		if (rbp->rbp_credits >= rbp->rbp_nbuffers) {
+		if (unlikely(rbp->rbp_credits >= rbp->rbp_req_nbuffers)) {
 			/* Discard this buffer so we don't have too many. */
 			lnet_destroy_rtrbuf(rb, rbp->rbp_npages);
+			rbp->rbp_nbuffers--;
 		} else {
 			list_add(&rb->rb_list, &rbp->rbp_bufs);
 			rbp->rbp_credits++;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 91f3f09..35cfced 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1352,6 +1352,7 @@ lnet_rtrpool_free_bufs(lnet_rtrbufpool_t *rbp, int cpt)
 	lnet_net_lock(cpt);
 	lnet_drop_routed_msgs_locked(&rbp->rbp_msgs, cpt);
 	list_splice_init(&rbp->rbp_bufs, &tmp);
+	rbp->rbp_req_nbuffers = 0;
 	rbp->rbp_nbuffers = 0;
 	rbp->rbp_credits = 0;
 	rbp->rbp_mincredits = 0;
@@ -1372,20 +1373,33 @@ lnet_rtrpool_adjust_bufs(lnet_rtrbufpool_t *rbp, int nbufs, int cpt)
 	lnet_rtrbuf_t *rb;
 	int num_rb;
 	int num_buffers = 0;
+	int old_req_nbufs;
 	int npages = rbp->rbp_npages;
 
+	lnet_net_lock(cpt);
 	/*
 	 * If we are called for less buffers than already in the pool, we
-	 * just lower the nbuffers number and excess buffers will be
+	 * just lower the req_nbuffers number and excess buffers will be
 	 * thrown away as they are returned to the free list.  Credits
 	 * then get adjusted as well.
+	 * If we already have enough buffers allocated to serve the
+	 * increase requested, then we can treat that the same way as we
+	 * do the decrease.
 	 */
-	if (nbufs <= rbp->rbp_nbuffers) {
-		lnet_net_lock(cpt);
-		rbp->rbp_nbuffers = nbufs;
+	num_rb = nbufs - rbp->rbp_nbuffers;
+	if (nbufs <= rbp->rbp_req_nbuffers || num_rb <= 0) {
+		rbp->rbp_req_nbuffers = nbufs;
 		lnet_net_unlock(cpt);
 		return 0;
 	}
+	/*
+	 * store the older value of rbp_req_nbuffers and then set it to
+	 * the new request to prevent lnet_return_rx_credits_locked() from
+	 * freeing buffers that we need to keep around
+	 */
+	old_req_nbufs = rbp->rbp_req_nbuffers;
+	rbp->rbp_req_nbuffers = nbufs;
+	lnet_net_unlock(cpt);
 
 	INIT_LIST_HEAD(&rb_list);
 
@@ -1394,19 +1408,21 @@ lnet_rtrpool_adjust_bufs(lnet_rtrbufpool_t *rbp, int nbufs, int cpt)
 	 * allocated successfully then join this list to the rbp buffer
 	 * list. If not then free all allocated buffers.
 	 */
-	num_rb = rbp->rbp_nbuffers;
-
-	while (num_rb < nbufs) {
+	while (num_rb-- > 0) {
 		rb = lnet_new_rtrbuf(rbp, cpt);
 		if (rb == NULL) {
 			CERROR("Failed to allocate %d route bufs of %d pages\n",
 			       nbufs, npages);
+
+			lnet_net_lock(cpt);
+			rbp->rbp_req_nbuffers = old_req_nbufs;
+			lnet_net_unlock(cpt);
+
 			goto failed;
 		}
 
 		list_add(&rb->rb_list, &rb_list);
 		num_buffers++;
-		num_rb++;
 	}
 
 	lnet_net_lock(cpt);
-- 
1.7.1
