From: Joe Perches <joe@perches.com>
Date: Fri,  1 Apr 2016 06:02:10 -0700
Subject: [lustre-devel] [RFC PATCH 2/3] staging: lustre: Remove typedef lnd_t
In-Reply-To: <cover.1459515208.git.joe@perches.com>
References: <cover.1459515208.git.joe@perches.com>
Message-ID: <314e44c510821a87827ccc248e64a70a0da260ce.1459515208.git.joe@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org

Just use struct lnet_lnd instead.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h  |  6 +++---
 drivers/staging/lustre/include/linux/lnet/lib-types.h |  6 +++---
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c   |  4 ++--
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c   |  2 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c             | 14 +++++++-------
 drivers/staging/lustre/lnet/lnet/lo.c                 |  2 +-
 6 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index ea29cb9..2390d94 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -439,7 +439,7 @@ lnet_net2rnethash(__u32 net)
 		((1U << the_lnet.ln_remote_nets_hbits) - 1)];
 }
 
-extern lnd_t the_lolnd;
+extern struct lnet_lnd the_lolnd;
 extern int avoid_asym_router_failure;
 
 int lnet_cpt_of_nid_locked(lnet_nid_t nid);
@@ -683,8 +683,8 @@ void lnet_me_unlink(lnet_me_t *me);
 void lnet_md_unlink(lnet_libmd_t *md);
 void lnet_md_deconstruct(lnet_libmd_t *lmd, lnet_md_t *umd);
 
-void lnet_register_lnd(lnd_t *lnd);
-void lnet_unregister_lnd(lnd_t *lnd);
+void lnet_register_lnd(struct lnet_lnd *lnd);
+void lnet_unregister_lnd(struct lnet_lnd *lnd);
 
 int lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 		 __u32 local_ip, __u32 peer_ip, int peer_port);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index d223de5..62baaca 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -178,7 +178,7 @@ typedef struct {
 
 struct lnet_ni;			/* forward ref */
 
-typedef struct lnet_lnd {
+struct lnet_lnd {
 	/* fields managed by portals */
 	struct list_head	lnd_list;	/* stash in the LND table */
 	int			lnd_refcount;	/* # active instances */
@@ -244,7 +244,7 @@ typedef struct lnet_lnd {
 
 	/* accept a new connection */
 	int (*lnd_accept)(struct lnet_ni *ni, struct socket *sock);
-} lnd_t;
+};
 
 struct lnet_tx_queue {
 	int			tq_credits;	/* # tx credits free */
@@ -268,7 +268,7 @@ typedef struct lnet_ni {
 	__u32			 *ni_cpts;	/* bond NI on some CPTs */
 	lnet_nid_t		  ni_nid;	/* interface's NID */
 	void			 *ni_data;	/* instance-specific data */
-	lnd_t			 *ni_lnd;	/* procedural interface */
+	struct lnet_lnd		 *ni_lnd;	/* procedural interface */
 	struct lnet_tx_queue	**ni_tx_queues;	/* percpt TX queues */
 	int			**ni_refs;	/* percpt reference count */
 	time64_t		  ni_last_alive;/* when I was last alive */
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index e89c2a1..3e3d92c 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -42,7 +42,7 @@
 #include <asm/page.h>
 #include "o2iblnd.h"
 
-static lnd_t the_o2iblnd;
+static struct lnet_lnd the_o2iblnd;
 
 kib_data_t kiblnd_data;
 
@@ -2770,7 +2770,7 @@ net_failed:
 	return -ENETDOWN;
 }
 
-static lnd_t the_o2iblnd = {
+static struct lnet_lnd the_o2iblnd = {
 	.lnd_type	= O2IBLND,
 	.lnd_startup	= kiblnd_startup,
 	.lnd_shutdown	= kiblnd_shutdown,
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 406c0e7..3cfdc17 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -43,7 +43,7 @@
 
 #include "socklnd.h"
 
-static lnd_t the_ksocklnd;
+static struct lnet_lnd the_ksocklnd;
 ksock_nal_data_t ksocknal_data;
 
 static ksock_interface_t *
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index f825784..19ad5a3 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -269,15 +269,15 @@ static void lnet_assert_wire_constants(void)
 	CLASSERT((int)sizeof(((lnet_hdr_t *)0)->msg.hello.type) == 4);
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
@@ -287,7 +287,7 @@ lnet_find_lnd_by_type(__u32 type)
 }
 
 void
-lnet_register_lnd(lnd_t *lnd)
+lnet_register_lnd(struct lnet_lnd *lnd)
 {
 	mutex_lock(&the_lnet.ln_lnd_mutex);
 
@@ -304,7 +304,7 @@ lnet_register_lnd(lnd_t *lnd)
 EXPORT_SYMBOL(lnet_register_lnd);
 
 void
-lnet_unregister_lnd(lnd_t *lnd)
+lnet_unregister_lnd(struct lnet_lnd *lnd)
 {
 	mutex_lock(&the_lnet.ln_lnd_mutex);
 
@@ -1220,7 +1220,7 @@ lnet_startup_lndni(struct lnet_ni *ni, __s32 peer_timeout,
 {
 	int rc = -EINVAL;
 	int lnd_type;
-	lnd_t *lnd;
+	struct lnet_lnd *lnd;
 	struct lnet_tx_queue *tq;
 	int i;
 
@@ -1460,7 +1460,7 @@ void lnet_lib_exit(void)
 
 	while (!list_empty(&the_lnet.ln_lnds))
 		lnet_unregister_lnd(list_entry(the_lnet.ln_lnds.next,
-					       lnd_t, lnd_list));
+					       struct lnet_lnd, lnd_list));
 	lnet_destroy_locks();
 }
 
diff --git a/drivers/staging/lustre/lnet/lnet/lo.c b/drivers/staging/lustre/lnet/lnet/lo.c
index 468eda6..2216301 100644
--- a/drivers/staging/lustre/lnet/lnet/lo.c
+++ b/drivers/staging/lustre/lnet/lnet/lo.c
@@ -105,7 +105,7 @@ lolnd_startup(lnet_ni_t *ni)
 	return 0;
 }
 
-lnd_t the_lolnd = {
+struct lnet_lnd the_lolnd = {
 	/* .lnd_list       = */ {&the_lolnd.lnd_list, &the_lolnd.lnd_list},
 	/* .lnd_refcount   = */ 0,
 	/* .lnd_type       = */ LOLND,
-- 
2.8.0.rc4.16.g56331f8
