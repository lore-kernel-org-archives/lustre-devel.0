From: James Simmons <jsimmons@infradead.org>
Date: Sat, 21 Jan 2017 19:40:27 -0500
Subject: [lustre-devel] [PATCH 3/8] staging: lustre: lnet: change
	lnet_ni_status_t to proper structure
In-Reply-To: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
References: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485045632-5886-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_ni_status_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24566
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-types.h | 2 +-
 drivers/staging/lustre/include/linux/lnet/types.h     | 6 +++---
 drivers/staging/lustre/lnet/lnet/api-ni.c             | 2 +-
 drivers/staging/lustre/lnet/lnet/router.c             | 4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index a1957b1..942549b 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -270,7 +270,7 @@ struct lnet_tx_queue {
 	struct lnet_tx_queue	**ni_tx_queues;	/* percpt TX queues */
 	int			**ni_refs;	/* percpt reference count */
 	time64_t		  ni_last_alive;/* when I was last alive */
-	lnet_ni_status_t	 *ni_status;	/* my health status */
+	struct lnet_ni_status	 *ni_status;	/* my health status */
 	/* per NI LND tunables */
 	struct lnet_ioctl_config_lnd_tunables *ni_lnd_tunables;
 	/* equivalent interfaces to use */
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 0c5d84e..405bbc6 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -236,18 +236,18 @@ struct lnet_handle_wire {
 
 #define LNET_PROTO_ACCEPTOR_VERSION	1
 
-typedef struct {
+struct lnet_ni_status {
 	lnet_nid_t	ns_nid;
 	__u32		ns_status;
 	__u32		ns_unused;
-} WIRE_ATTR lnet_ni_status_t;
+} WIRE_ATTR;
 
 struct lnet_ping_info {
 	__u32			pi_magic;
 	__u32			pi_features;
 	lnet_pid_t		pi_pid;
 	__u32			pi_nnis;
-	lnet_ni_status_t	pi_ni[0];
+	struct lnet_ni_status	pi_ni[0];
 } WIRE_ATTR;
 
 typedef struct lnet_counters {
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index ae388b2..3b2488f 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -981,7 +981,7 @@ static void lnet_assert_wire_constants(void)
 static void
 lnet_ping_info_install_locked(struct lnet_ping_info *ping_info)
 {
-	lnet_ni_status_t *ns;
+	struct lnet_ni_status *ns;
 	lnet_ni_t *ni;
 	int i = 0;
 
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 269b5e7..cf22525 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -624,7 +624,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 lnet_swap_pinginfo(struct lnet_ping_info *info)
 {
 	int i;
-	lnet_ni_status_t *stat;
+	struct lnet_ni_status *stat;
 
 	__swab32s(&info->pi_magic);
 	__swab32s(&info->pi_features);
@@ -683,7 +683,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 		}
 
 		for (i = 0; i < info->pi_nnis && i < LNET_MAX_RTR_NIS; i++) {
-			lnet_ni_status_t *stat = &info->pi_ni[i];
+			struct lnet_ni_status *stat = &info->pi_ni[i];
 			lnet_nid_t nid = stat->ns_nid;
 
 			if (nid == LNET_NID_ANY) {
-- 
1.8.3.1
