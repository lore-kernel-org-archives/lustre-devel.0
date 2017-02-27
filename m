From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:39 -0500
Subject: [lustre-devel] [PATCH 14/34] staging: lustre: lnet: change
	lnet_rc_data_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_rc_data_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-types.h |  6 +++---
 drivers/staging/lustre/lnet/lnet/router.c             | 18 +++++++++---------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index bcfb0c7..10bf60f 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -297,13 +297,13 @@ struct lnet_ni {
 /* router checker data, per router */
 #define LNET_MAX_RTR_NIS   16
 #define LNET_PINGINFO_SIZE offsetof(struct lnet_ping_info, pi_ni[LNET_MAX_RTR_NIS])
-typedef struct {
+struct lnet_rc_data {
 	/* chain on the_lnet.ln_zombie_rcd or ln_deathrow_rcd */
 	struct list_head	 rcd_list;
 	struct lnet_handle_md	 rcd_mdh;	/* ping buffer MD */
 	struct lnet_peer	*rcd_gateway;	/* reference to gateway */
 	struct lnet_ping_info	*rcd_pinginfo;	/* ping buffer */
-} lnet_rc_data_t;
+};
 
 typedef struct lnet_peer {
 	struct list_head	 lp_hashlist;	/* chain on peer hash */
@@ -345,7 +345,7 @@ struct lnet_ni {
 	/* returned RC ping features */
 	unsigned int		 lp_ping_feats;
 	struct list_head	 lp_routes;	/* routers on this peer */
-	lnet_rc_data_t		*lp_rcd;	/* router checker state */
+	struct lnet_rc_data	*lp_rcd;	/* router checker state */
 } lnet_peer_t;
 
 /* peer hash size */
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 85fdd08..c73d7a0 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -642,7 +642,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
  * networks on that router.
  */
 static void
-lnet_parse_rc_info(lnet_rc_data_t *rcd)
+lnet_parse_rc_info(struct lnet_rc_data *rcd)
 {
 	struct lnet_ping_info *info = rcd->rcd_pinginfo;
 	struct lnet_peer *gw = rcd->rcd_gateway;
@@ -733,7 +733,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 static void
 lnet_router_checker_event(lnet_event_t *event)
 {
-	lnet_rc_data_t *rcd = event->md.user_ptr;
+	struct lnet_rc_data *rcd = event->md.user_ptr;
 	struct lnet_peer *lp;
 
 	LASSERT(rcd);
@@ -878,7 +878,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 static void
-lnet_destroy_rc_data(lnet_rc_data_t *rcd)
+lnet_destroy_rc_data(struct lnet_rc_data *rcd)
 {
 	LASSERT(list_empty(&rcd->rcd_list));
 	/* detached from network */
@@ -898,10 +898,10 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	LIBCFS_FREE(rcd, sizeof(*rcd));
 }
 
-static lnet_rc_data_t *
+static struct lnet_rc_data *
 lnet_create_rc_data_locked(lnet_peer_t *gateway)
 {
-	lnet_rc_data_t *rcd = NULL;
+	struct lnet_rc_data *rcd = NULL;
 	struct lnet_ping_info *pi;
 	lnet_md_t md;
 	int rc;
@@ -984,7 +984,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 static void
 lnet_ping_router_locked(lnet_peer_t *rtr)
 {
-	lnet_rc_data_t *rcd = NULL;
+	struct lnet_rc_data *rcd = NULL;
 	unsigned long now = cfs_time_current();
 	int secs;
 
@@ -1124,8 +1124,8 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 static void
 lnet_prune_rc_data(int wait_unlink)
 {
-	lnet_rc_data_t *rcd;
-	lnet_rc_data_t *tmp;
+	struct lnet_rc_data *rcd;
+	struct lnet_rc_data *tmp;
 	lnet_peer_t *lp;
 	struct list_head head;
 	int i = 2;
@@ -1182,7 +1182,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 
 		while (!list_empty(&head)) {
 			rcd = list_entry(head.next,
-					 lnet_rc_data_t, rcd_list);
+					 struct lnet_rc_data, rcd_list);
 			list_del_init(&rcd->rcd_list);
 			lnet_destroy_rc_data(rcd);
 		}
-- 
1.8.3.1
