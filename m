From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:43 -0500
Subject: [lustre-devel] [PATCH 18/34] staging: lustre: lnet: change
	lnet_rtrbufpool_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_rtrbufpool_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h  |  2 +-
 drivers/staging/lustre/include/linux/lnet/lib-types.h |  8 ++++----
 drivers/staging/lustre/lnet/lnet/lib-move.c           | 10 +++++-----
 drivers/staging/lustre/lnet/lnet/router.c             | 18 +++++++++---------
 drivers/staging/lustre/lnet/lnet/router_proc.c        |  2 +-
 5 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 8483a4a..61a911a 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -496,7 +496,7 @@ void lnet_prep_send(struct lnet_msg *msg, int type, lnet_process_id_t target,
 int lnet_send(lnet_nid_t nid, struct lnet_msg *msg, lnet_nid_t rtr_nid);
 void lnet_return_tx_credits_locked(struct lnet_msg *msg);
 void lnet_return_rx_credits_locked(struct lnet_msg *msg);
-void lnet_schedule_blocked_locked(lnet_rtrbufpool_t *rbp);
+void lnet_schedule_blocked_locked(struct lnet_rtrbufpool *rbp);
 void lnet_drop_routed_msgs_locked(struct list_head *list, int cpt);
 
 /* portals functions */
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 04ad728..b654ab6 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -396,7 +396,7 @@ struct lnet_remotenet {
 /** lnet message is waiting for credit */
 #define LNET_CREDIT_WAIT	1
 
-typedef struct {
+struct lnet_rtrbufpool {
 	struct list_head	rbp_bufs;	/* my free buffer pool */
 	struct list_head	rbp_msgs;	/* messages blocking
 						   for a buffer */
@@ -408,11 +408,11 @@ struct lnet_remotenet {
 	int			rbp_credits;	/* # free buffers /
 						     blocked messages */
 	int			rbp_mincredits;	/* low water mark */
-} lnet_rtrbufpool_t;
+};
 
 typedef struct {
 	struct list_head	 rb_list;	/* chain on rbp_bufs */
-	lnet_rtrbufpool_t	*rb_pool;	/* owning pool */
+	struct lnet_rtrbufpool	*rb_pool;	/* owning pool */
 	lnet_kiov_t		 rb_kiov[0];	/* the buffer space */
 } lnet_rtrbuf_t;
 
@@ -596,7 +596,7 @@ struct lnet_msg_container {
 	/* validity stamp */
 	__u64				  ln_routers_version;
 	/* percpt router buffer pools */
-	lnet_rtrbufpool_t		**ln_rtrpools;
+	struct lnet_rtrbufpool		**ln_rtrpools;
 
 	struct lnet_handle_md		  ln_ping_target_md;
 	struct lnet_handle_eq		  ln_ping_target_eq;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 3581100..2d31e1f 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -680,10 +680,10 @@
 	return LNET_CREDIT_OK;
 }
 
-static lnet_rtrbufpool_t *
+static struct lnet_rtrbufpool *
 lnet_msg2bufpool(struct lnet_msg *msg)
 {
-	lnet_rtrbufpool_t *rbp;
+	struct lnet_rtrbufpool *rbp;
 	int cpt;
 
 	LASSERT(msg->msg_rx_committed);
@@ -710,7 +710,7 @@
 	 * received or OK to receive
 	 */
 	struct lnet_peer *lp = msg->msg_rxpeer;
-	lnet_rtrbufpool_t *rbp;
+	struct lnet_rtrbufpool *rbp;
 	lnet_rtrbuf_t *rb;
 
 	LASSERT(!msg->msg_iov);
@@ -835,7 +835,7 @@
 }
 
 void
-lnet_schedule_blocked_locked(lnet_rtrbufpool_t *rbp)
+lnet_schedule_blocked_locked(struct lnet_rtrbufpool *rbp)
 {
 	struct lnet_msg *msg;
 
@@ -880,7 +880,7 @@
 	if (msg->msg_rtrcredit) {
 		/* give back global router credits */
 		lnet_rtrbuf_t *rb;
-		lnet_rtrbufpool_t *rbp;
+		struct lnet_rtrbufpool *rbp;
 
 		/*
 		 * NB If a msg ever blocks for a buffer in rbp_msgs, it stays
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 9a5faba..a5f1f85 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -558,7 +558,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 		return rc;
 
 	for (i = 0; i < LNET_NRBPOOLS; i++) {
-		lnet_rtrbufpool_t *rbp;
+		struct lnet_rtrbufpool *rbp;
 
 		lnet_net_lock(LNET_LOCK_EX);
 		cfs_percpt_for_each(rbp, j, the_lnet.ln_rtrpools) {
@@ -1316,7 +1316,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 static lnet_rtrbuf_t *
-lnet_new_rtrbuf(lnet_rtrbufpool_t *rbp, int cpt)
+lnet_new_rtrbuf(struct lnet_rtrbufpool *rbp, int cpt)
 {
 	int npages = rbp->rbp_npages;
 	int sz = offsetof(lnet_rtrbuf_t, rb_kiov[npages]);
@@ -1351,7 +1351,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 static void
-lnet_rtrpool_free_bufs(lnet_rtrbufpool_t *rbp, int cpt)
+lnet_rtrpool_free_bufs(struct lnet_rtrbufpool *rbp, int cpt)
 {
 	int npages = rbp->rbp_npages;
 	struct list_head tmp;
@@ -1380,7 +1380,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 static int
-lnet_rtrpool_adjust_bufs(lnet_rtrbufpool_t *rbp, int nbufs, int cpt)
+lnet_rtrpool_adjust_bufs(struct lnet_rtrbufpool *rbp, int nbufs, int cpt)
 {
 	struct list_head rb_list;
 	lnet_rtrbuf_t *rb;
@@ -1467,7 +1467,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 static void
-lnet_rtrpool_init(lnet_rtrbufpool_t *rbp, int npages)
+lnet_rtrpool_init(struct lnet_rtrbufpool *rbp, int npages)
 {
 	INIT_LIST_HEAD(&rbp->rbp_msgs);
 	INIT_LIST_HEAD(&rbp->rbp_bufs);
@@ -1480,7 +1480,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 void
 lnet_rtrpools_free(int keep_pools)
 {
-	lnet_rtrbufpool_t *rtrp;
+	struct lnet_rtrbufpool *rtrp;
 	int i;
 
 	if (!the_lnet.ln_rtrpools) /* uninitialized or freed */
@@ -1558,7 +1558,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 int
 lnet_rtrpools_alloc(int im_a_router)
 {
-	lnet_rtrbufpool_t *rtrp;
+	struct lnet_rtrbufpool *rtrp;
 	int nrb_tiny;
 	int nrb_small;
 	int nrb_large;
@@ -1593,7 +1593,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 
 	the_lnet.ln_rtrpools = cfs_percpt_alloc(lnet_cpt_table(),
 						LNET_NRBPOOLS *
-						sizeof(lnet_rtrbufpool_t));
+						sizeof(struct lnet_rtrbufpool));
 	if (!the_lnet.ln_rtrpools) {
 		LCONSOLE_ERROR_MSG(0x10c,
 				   "Failed to initialize router buffe pool\n");
@@ -1639,7 +1639,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	int nrb = 0;
 	int rc = 0;
 	int i;
-	lnet_rtrbufpool_t *rtrp;
+	struct lnet_rtrbufpool *rtrp;
 
 	/*
 	 * If the provided values for each buffer pool are different than the
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 779ec69..0065cc1 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -592,7 +592,7 @@ static int __proc_lnet_buffers(void *data, int write,
 		goto out; /* I'm not a router */
 
 	for (idx = 0; idx < LNET_NRBPOOLS; idx++) {
-		lnet_rtrbufpool_t *rbp;
+		struct lnet_rtrbufpool *rbp;
 
 		lnet_net_lock(LNET_LOCK_EX);
 		cfs_percpt_for_each(rbp, i, the_lnet.ln_rtrpools) {
-- 
1.8.3.1
