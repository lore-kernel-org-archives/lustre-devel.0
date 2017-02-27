From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:44 -0500
Subject: [lustre-devel] [PATCH 19/34] staging: lustre: lnet: change
	lnet_rtrbuf_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_rtrbuf_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h  |  2 +-
 drivers/staging/lustre/include/linux/lnet/lib-types.h |  4 ++--
 drivers/staging/lustre/lnet/lnet/lib-move.c           |  8 ++++----
 drivers/staging/lustre/lnet/lnet/router.c             | 18 +++++++++---------
 4 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 61a911a..223e5a3 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -468,7 +468,7 @@ int lnet_get_route(int idx, __u32 *net, __u32 *hops,
 void lnet_router_debugfs_init(void);
 void lnet_router_debugfs_fini(void);
 int  lnet_rtrpools_alloc(int im_a_router);
-void lnet_destroy_rtrbuf(lnet_rtrbuf_t *rb, int npages);
+void lnet_destroy_rtrbuf(struct lnet_rtrbuf *rb, int npages);
 int lnet_rtrpools_adjust(int tiny, int small, int large);
 int lnet_rtrpools_enable(void);
 void lnet_rtrpools_disable(void);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index b654ab6..f939492 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -410,11 +410,11 @@ struct lnet_rtrbufpool {
 	int			rbp_mincredits;	/* low water mark */
 };
 
-typedef struct {
+struct lnet_rtrbuf {
 	struct list_head	 rb_list;	/* chain on rbp_bufs */
 	struct lnet_rtrbufpool	*rb_pool;	/* owning pool */
 	lnet_kiov_t		 rb_kiov[0];	/* the buffer space */
-} lnet_rtrbuf_t;
+};
 
 #define LNET_PEER_HASHSIZE	503	/* prime! */
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 2d31e1f..aea899e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -711,7 +711,7 @@
 	 */
 	struct lnet_peer *lp = msg->msg_rxpeer;
 	struct lnet_rtrbufpool *rbp;
-	lnet_rtrbuf_t *rb;
+	struct lnet_rtrbuf *rb;
 
 	LASSERT(!msg->msg_iov);
 	LASSERT(!msg->msg_kiov);
@@ -759,7 +759,7 @@
 	}
 
 	LASSERT(!list_empty(&rbp->rbp_bufs));
-	rb = list_entry(rbp->rbp_bufs.next, lnet_rtrbuf_t, rb_list);
+	rb = list_entry(rbp->rbp_bufs.next, struct lnet_rtrbuf, rb_list);
 	list_del(&rb->rb_list);
 
 	msg->msg_niov = rbp->rbp_npages;
@@ -879,7 +879,7 @@
 
 	if (msg->msg_rtrcredit) {
 		/* give back global router credits */
-		lnet_rtrbuf_t *rb;
+		struct lnet_rtrbuf *rb;
 		struct lnet_rtrbufpool *rbp;
 
 		/*
@@ -889,7 +889,7 @@
 		 */
 		LASSERT(msg->msg_kiov);
 
-		rb = list_entry(msg->msg_kiov, lnet_rtrbuf_t, rb_kiov[0]);
+		rb = list_entry(msg->msg_kiov, struct lnet_rtrbuf, rb_kiov[0]);
 		rbp = rb->rb_pool;
 
 		msg->msg_kiov = NULL;
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index a5f1f85..effa0fe 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1305,9 +1305,9 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 void
-lnet_destroy_rtrbuf(lnet_rtrbuf_t *rb, int npages)
+lnet_destroy_rtrbuf(struct lnet_rtrbuf *rb, int npages)
 {
-	int sz = offsetof(lnet_rtrbuf_t, rb_kiov[npages]);
+	int sz = offsetof(struct lnet_rtrbuf, rb_kiov[npages]);
 
 	while (--npages >= 0)
 		__free_page(rb->rb_kiov[npages].bv_page);
@@ -1315,13 +1315,13 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	LIBCFS_FREE(rb, sz);
 }
 
-static lnet_rtrbuf_t *
+static struct lnet_rtrbuf *
 lnet_new_rtrbuf(struct lnet_rtrbufpool *rbp, int cpt)
 {
 	int npages = rbp->rbp_npages;
-	int sz = offsetof(lnet_rtrbuf_t, rb_kiov[npages]);
+	int sz = offsetof(struct lnet_rtrbuf, rb_kiov[npages]);
 	struct page *page;
-	lnet_rtrbuf_t *rb;
+	struct lnet_rtrbuf *rb;
 	int i;
 
 	LIBCFS_CPT_ALLOC(rb, lnet_cpt_table(), cpt, sz);
@@ -1355,8 +1355,8 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 {
 	int npages = rbp->rbp_npages;
 	struct list_head tmp;
-	lnet_rtrbuf_t *rb;
-	lnet_rtrbuf_t *temp;
+	struct lnet_rtrbuf *rb;
+	struct lnet_rtrbuf *temp;
 
 	if (!rbp->rbp_nbuffers) /* not initialized or already freed */
 		return;
@@ -1383,7 +1383,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 lnet_rtrpool_adjust_bufs(struct lnet_rtrbufpool *rbp, int nbufs, int cpt)
 {
 	struct list_head rb_list;
-	lnet_rtrbuf_t *rb;
+	struct lnet_rtrbuf *rb;
 	int num_rb;
 	int num_buffers = 0;
 	int old_req_nbufs;
@@ -1458,7 +1458,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 
 failed:
 	while (!list_empty(&rb_list)) {
-		rb = list_entry(rb_list.next, lnet_rtrbuf_t, rb_list);
+		rb = list_entry(rb_list.next, struct lnet_rtrbuf, rb_list);
 		list_del(&rb->rb_list);
 		lnet_destroy_rtrbuf(rb, npages);
 	}
-- 
1.8.3.1
