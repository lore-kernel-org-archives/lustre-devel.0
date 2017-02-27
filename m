From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:37 -0500
Subject: [lustre-devel] [PATCH 12/34] staging: lustre: lnet: change lnd_t to
	proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnd_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h  |  6 +++---
 drivers/staging/lustre/include/linux/lnet/lib-types.h |  6 +++---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c   |  4 ++--
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c   |  2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c             | 14 +++++++-------
 drivers/staging/lustre/lnet/lnet/lo.c                 |  2 +-
 6 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 685c5d4..9a29769 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -439,7 +439,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 		((1U << the_lnet.ln_remote_nets_hbits) - 1)];
 }
 
-extern lnd_t the_lolnd;
+extern struct lnet_lnd the_lolnd;
 extern int avoid_asym_router_failure;
 
 int lnet_cpt_of_nid_locked(lnet_nid_t nid);
@@ -628,8 +628,8 @@ void lnet_copy_kiov2iter(struct iov_iter *to,
 void lnet_md_unlink(struct lnet_libmd *md);
 void lnet_md_deconstruct(struct lnet_libmd *lmd, lnet_md_t *umd);
 
-void lnet_register_lnd(lnd_t *lnd);
-void lnet_unregister_lnd(lnd_t *lnd);
+void lnet_register_lnd(struct lnet_lnd *lnd);
+void lnet_unregister_lnd(struct lnet_lnd *lnd);
 
 int lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 		 __u32 local_ip, __u32 peer_ip, int peer_port);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 59d7143..8a65db2 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -179,7 +179,7 @@ struct lnet_test_peer {
 
 struct lnet_ni;			/* forward ref */
 
-typedef struct lnet_lnd {
+struct lnet_lnd {
 	/* fields managed by portals */
 	struct list_head	lnd_list;	/* stash in the LND table */
 	int			lnd_refcount;	/* # active instances */
@@ -243,7 +243,7 @@ struct lnet_test_peer {
 
 	/* accept a new connection */
 	int (*lnd_accept)(struct lnet_ni *ni, struct socket *sock);
-} lnd_t;
+};
 
 struct lnet_tx_queue {
 	int			tq_credits;	/* # tx credits free */
@@ -267,7 +267,7 @@ struct lnet_tx_queue {
 	__u32			 *ni_cpts;	/* bond NI on some CPTs */
 	lnet_nid_t		  ni_nid;	/* interface's NID */
 	void			 *ni_data;	/* instance-specific data */
-	lnd_t			 *ni_lnd;	/* procedural interface */
+	struct lnet_lnd		 *ni_lnd;	/* procedural interface */
 	struct lnet_tx_queue	**ni_tx_queues;	/* percpt TX queues */
 	int			**ni_refs;	/* percpt reference count */
 	time64_t		  ni_last_alive;/* when I was last alive */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 6f73454..29a5263 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -38,7 +38,7 @@
 #include <asm/page.h>
 #include "o2iblnd.h"
 
-static lnd_t the_o2iblnd;
+static struct lnet_lnd the_o2iblnd;
 
 struct kib_data kiblnd_data;
 
@@ -2938,7 +2938,7 @@ static int kiblnd_startup(lnet_ni_t *ni)
 	return -ENETDOWN;
 }
 
-static lnd_t the_o2iblnd = {
+static struct lnet_lnd the_o2iblnd = {
 	.lnd_type	= O2IBLND,
 	.lnd_startup	= kiblnd_startup,
 	.lnd_shutdown	= kiblnd_shutdown,
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 3b08aff..258507f 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -39,7 +39,7 @@
 
 #include "socklnd.h"
 
-static lnd_t the_ksocklnd;
+static struct lnet_lnd the_ksocklnd;
 struct ksock_nal_data ksocknal_data;
 
 static struct ksock_interface *
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index aeb9e6f..d31a50b 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -265,15 +265,15 @@ static void lnet_assert_wire_constants(void)
 	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.hello.type) != 4);
 }
 
-static lnd_t *
+static struct lnet_lnd *
 lnet_find_lnd_by_type(__u32 type)
 {
-	lnd_t *lnd;
+	struct lnet_lnd *lnd;
 	struct list_head *tmp;
 
 	/* holding lnd mutex */
 	list_for_each(tmp, &the_lnet.ln_lnds) {
-		lnd = list_entry(tmp, lnd_t, lnd_list);
+		lnd = list_entry(tmp, struct lnet_lnd, lnd_list);
 
 		if (lnd->lnd_type == type)
 			return lnd;
@@ -283,7 +283,7 @@ static void lnet_assert_wire_constants(void)
 }
 
 void
-lnet_register_lnd(lnd_t *lnd)
+lnet_register_lnd(struct lnet_lnd *lnd)
 {
 	mutex_lock(&the_lnet.ln_lnd_mutex);
 
@@ -300,7 +300,7 @@ static void lnet_assert_wire_constants(void)
 EXPORT_SYMBOL(lnet_register_lnd);
 
 void
-lnet_unregister_lnd(lnd_t *lnd)
+lnet_unregister_lnd(struct lnet_lnd *lnd)
 {
 	mutex_lock(&the_lnet.ln_lnd_mutex);
 
@@ -1220,7 +1220,7 @@ struct lnet_libhandle *
 	struct lnet_ioctl_config_lnd_tunables *lnd_tunables = NULL;
 	int rc = -EINVAL;
 	int lnd_type;
-	lnd_t *lnd;
+	struct lnet_lnd *lnd;
 	struct lnet_tx_queue *tq;
 	int i;
 
@@ -1475,7 +1475,7 @@ void lnet_lib_exit(void)
 
 	while (!list_empty(&the_lnet.ln_lnds))
 		lnet_unregister_lnd(list_entry(the_lnet.ln_lnds.next,
-					       lnd_t, lnd_list));
+					       struct lnet_lnd, lnd_list));
 	lnet_destroy_locks();
 }
 
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index 12b6b3a..d11b4f9 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -88,7 +88,7 @@
 	return 0;
 }
 
-lnd_t the_lolnd = {
+struct lnet_lnd the_lolnd = {
 	/* .lnd_list       = */ {&the_lolnd.lnd_list, &the_lolnd.lnd_list},
 	/* .lnd_refcount   = */ 0,
 	/* .lnd_type       = */ LOLND,
-- 
1.8.3.1
