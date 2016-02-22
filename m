From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Feb 2016 17:29:17 -0500
Subject: [lustre-devel] [PATCH 16/24] staging: lustre: assume a kernel build
In-Reply-To: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
References: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456180165-1105-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>

From: John L. Hammond <john.hammond@intel.com>

In lnet/lnet/ and lnet/selftest/ assume a kernel build (assume that
 __KERNEL__ is defined). Remove some common code only needed for user
space LNet.

Only part of the work of this patch got merged. This is the final
bits.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/13121
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |    4 --
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 -
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   39 ++------------------
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |    3 --
 drivers/staging/lustre/lnet/lnet/lib-md.c          |    3 --
 drivers/staging/lustre/lnet/lnet/lib-me.c          |    3 --
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    5 ---
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   20 +----------
 drivers/staging/lustre/lnet/lnet/router.c          |   11 ++----
 9 files changed, 7 insertions(+), 83 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 06d4656..f588e06 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -577,8 +577,6 @@ typedef struct {
 	/* dying LND instances */
 	struct list_head		  ln_nis_zombie;
 	lnet_ni_t			 *ln_loni;	/* the loopback NI */
-	/* NI to wait for events in */
-	lnet_ni_t			 *ln_eq_waitni;
 
 	/* remote networks with routes to them */
 	struct list_head		 *ln_remote_nets_hash;
@@ -608,8 +606,6 @@ typedef struct {
 
 	struct mutex			  ln_api_mutex;
 	struct mutex			  ln_lnd_mutex;
-	int				  ln_init;	/* lnet_init()
-							   called? */
 	/* Have I called LNetNIInit myself? */
 	int				  ln_niinit_self;
 	/* LNetNIInit/LNetNIFini counter */
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 9fe3ff7..8f9876b 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -206,8 +206,6 @@ lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 }
 EXPORT_SYMBOL(lnet_connect);
 
-/* Below is the code common for both kernel and MT user-space */
-
 static int
 lnet_accept(struct socket *sock, __u32 magic)
 {
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 0ec656a..0c7db19 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -291,7 +291,6 @@ lnet_register_lnd(lnd_t *lnd)
 {
 	mutex_lock(&the_lnet.ln_lnd_mutex);
 
-	LASSERT(the_lnet.ln_init);
 	LASSERT(libcfs_isknown_lnd(lnd->lnd_type));
 	LASSERT(!lnet_find_lnd_by_type(lnd->lnd_type));
 
@@ -309,7 +308,6 @@ lnet_unregister_lnd(lnd_t *lnd)
 {
 	mutex_lock(&the_lnet.ln_lnd_mutex);
 
-	LASSERT(the_lnet.ln_init);
 	LASSERT(lnet_find_lnd_by_type(lnd->lnd_type) == lnd);
 	LASSERT(!lnd->lnd_refcount);
 
@@ -1166,12 +1164,6 @@ lnet_shutdown_lndnis(void)
 		lnet_ni_unlink_locked(ni);
 	}
 
-	/* Drop the cached eqwait NI. */
-	if (the_lnet.ln_eq_waitni) {
-		lnet_ni_decref_locked(the_lnet.ln_eq_waitni, 0);
-		the_lnet.ln_eq_waitni = NULL;
-	}
-
 	/* Drop the cached loopback NI. */
 	if (the_lnet.ln_loni) {
 		lnet_ni_decref_locked(the_lnet.ln_loni, 0);
@@ -1364,7 +1356,6 @@ lnet_startup_lndnis(struct list_head *nilist)
 {
 	struct lnet_ni *ni;
 	int rc;
-	int lnd_type;
 	int ni_count = 0;
 
 	while (!list_empty(nilist)) {
@@ -1378,14 +1369,6 @@ lnet_startup_lndnis(struct list_head *nilist)
 		ni_count++;
 	}
 
-	if (the_lnet.ln_eq_waitni && ni_count > 1) {
-		lnd_type = the_lnet.ln_eq_waitni->ni_lnd->lnd_type;
-		LCONSOLE_ERROR_MSG(0x109, "LND %s can only run single-network\n",
-				   libcfs_lnd2str(lnd_type));
-		rc = -EINVAL;
-		goto failed;
-	}
-
 	return ni_count;
 failed:
 	lnet_shutdown_lndnis();
@@ -1396,10 +1379,9 @@ failed:
 /**
  * Initialize LNet library.
  *
- * Only userspace program needs to call this function - it's automatically
- * called in the kernel at module loading time. Caller has to call lnet_fini()
- * after a call to lnet_init(), if and only if the latter returned 0. It must
- * be called exactly once.
+ * Automatically called at module loading time. Caller has to call
+ * lnet_exit() after a call to lnet_init(), if and only if the
+ * latter returned 0. It must be called exactly once.
  *
  * \return 0 on success, and -ve on failures.
  */
@@ -1409,7 +1391,6 @@ lnet_init(void)
 	int rc;
 
 	lnet_assert_wire_constants();
-	LASSERT(!the_lnet.ln_init);
 
 	memset(&the_lnet, 0, sizeof(the_lnet));
 
@@ -1435,7 +1416,6 @@ lnet_init(void)
 	}
 
 	the_lnet.ln_refcount = 0;
-	the_lnet.ln_init = 1;
 	LNetInvalidateHandle(&the_lnet.ln_rc_eqh);
 	INIT_LIST_HEAD(&the_lnet.ln_lnds);
 	INIT_LIST_HEAD(&the_lnet.ln_rcd_zombie);
@@ -1465,30 +1445,23 @@ lnet_init(void)
 /**
  * Finalize LNet library.
  *
- * Only userspace program needs to call this function. It can be called
- * at most once.
- *
  * \pre lnet_init() called with success.
  * \pre All LNet users called LNetNIFini() for matching LNetNIInit() calls.
  */
 void
 lnet_fini(void)
 {
-	LASSERT(the_lnet.ln_init);
 	LASSERT(!the_lnet.ln_refcount);
 
 	while (!list_empty(&the_lnet.ln_lnds))
 		lnet_unregister_lnd(list_entry(the_lnet.ln_lnds.next,
 					       lnd_t, lnd_list));
 	lnet_destroy_locks();
-
-	the_lnet.ln_init = 0;
 }
 
 /**
  * Set LNet PID and start LNet interfaces, routing, and forwarding.
  *
- * Userspace program should call this after a successful call to lnet_init().
  * Users must call this function at least once before any other functions.
  * For each successful call there must be a corresponding call to
  * LNetNIFini(). For subsequent calls to LNetNIInit(), \a requested_pid is
@@ -1515,7 +1488,6 @@ LNetNIInit(lnet_pid_t requested_pid)
 
 	mutex_lock(&the_lnet.ln_api_mutex);
 
-	LASSERT(the_lnet.ln_init);
 	CDEBUG(D_OTHER, "refs %d\n", the_lnet.ln_refcount);
 
 	if (the_lnet.ln_refcount > 0) {
@@ -1632,7 +1604,6 @@ LNetNIFini(void)
 {
 	mutex_lock(&the_lnet.ln_api_mutex);
 
-	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	if (the_lnet.ln_refcount != 1) {
@@ -1886,8 +1857,6 @@ LNetCtl(unsigned int cmd, void *arg)
 	int rc;
 	unsigned long secs_passed;
 
-	LASSERT(the_lnet.ln_init);
-
 	switch (cmd) {
 	case IOC_LIBCFS_GET_NI:
 		rc = LNetGetId(data->ioc_count, &id);
@@ -2107,8 +2076,6 @@ LNetGetId(unsigned int index, lnet_process_id_t *id)
 	int cpt;
 	int rc = -ENOENT;
 
-	LASSERT(the_lnet.ln_init);
-
 	/* LNetNI initilization failed? */
 	if (!the_lnet.ln_refcount)
 		return rc;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index b8f248e..042e974 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -72,7 +72,6 @@ LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
 {
 	lnet_eq_t *eq;
 
-	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	/*
@@ -167,7 +166,6 @@ LNetEQFree(lnet_handle_eq_t eqh)
 	int size = 0;
 	int i;
 
-	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	lnet_res_lock(LNET_LOCK_EX);
@@ -383,7 +381,6 @@ LNetEQPoll(lnet_handle_eq_t *eventqs, int neq, int timeout_ms,
 	int rc;
 	int i;
 
-	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	if (neq < 1)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index f26bb03..c74514f 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -281,7 +281,6 @@ LNetMDAttach(lnet_handle_me_t meh, lnet_md_t umd,
 	int cpt;
 	int rc;
 
-	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	if (lnet_md_validate(&umd))
@@ -360,7 +359,6 @@ LNetMDBind(lnet_md_t umd, lnet_unlink_t unlink, lnet_handle_md_t *handle)
 	int cpt;
 	int rc;
 
-	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	if (lnet_md_validate(&umd))
@@ -435,7 +433,6 @@ LNetMDUnlink(lnet_handle_md_t mdh)
 	lnet_libmd_t *md;
 	int cpt;
 
-	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	cpt = lnet_cpt_of_cookie(mdh.cookie);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index 3c59c88..e671aed 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -83,7 +83,6 @@ LNetMEAttach(unsigned int portal,
 	struct lnet_me *me;
 	struct list_head *head;
 
-	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	if ((int)portal >= the_lnet.ln_nportals)
@@ -156,7 +155,6 @@ LNetMEInsert(lnet_handle_me_t current_meh,
 	struct lnet_portal *ptl;
 	int cpt;
 
-	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	if (pos == LNET_INS_LOCAL)
@@ -233,7 +231,6 @@ LNetMEUnlink(lnet_handle_me_t meh)
 	lnet_event_t ev;
 	int cpt;
 
-	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	cpt = lnet_cpt_of_cookie(meh.cookie);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index a342ce0..e5a8dbc 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -59,8 +59,6 @@ lnet_fail_nid(lnet_nid_t nid, unsigned int threshold)
 	struct list_head *next;
 	struct list_head cull;
 
-	LASSERT(the_lnet.ln_init);
-
 	/* NB: use lnet_net_lock(0) to serialize operations on test peers */
 	if (threshold) {
 		/* Adding a new entry */
@@ -2162,7 +2160,6 @@ LNetPut(lnet_nid_t self, lnet_handle_md_t mdh, lnet_ack_req_t ack,
 	int cpt;
 	int rc;
 
-	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	if (!list_empty(&the_lnet.ln_test_peers) && /* normally we don't */
@@ -2367,7 +2364,6 @@ LNetGet(lnet_nid_t self, lnet_handle_md_t mdh,
 	int cpt;
 	int rc;
 
-	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	if (!list_empty(&the_lnet.ln_test_peers) && /* normally we don't */
@@ -2467,7 +2463,6 @@ LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
 	 * keep order 0 free for 0 at lo and order 1 free for a local NID
 	 * match
 	 */
-	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	cpt = lnet_net_lock_current();
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 749e76a..c372390 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -571,35 +571,17 @@ lnet_msg_container_cleanup(struct lnet_msg_container *container)
 			    sizeof(*container->msc_finalizers));
 		container->msc_finalizers = NULL;
 	}
-#ifdef LNET_USE_LIB_FREELIST
-	lnet_freelist_fini(&container->msc_freelist);
-#endif
 	container->msc_init = 0;
 }
 
 int
 lnet_msg_container_setup(struct lnet_msg_container *container, int cpt)
 {
-	int rc;
-
 	container->msc_init = 1;
 
 	INIT_LIST_HEAD(&container->msc_active);
 	INIT_LIST_HEAD(&container->msc_finalizing);
 
-#ifdef LNET_USE_LIB_FREELIST
-	memset(&container->msc_freelist, 0, sizeof(lnet_freelist_t));
-
-	rc = lnet_freelist_init(&container->msc_freelist,
-				LNET_FL_MAX_MSGS, sizeof(lnet_msg_t));
-	if (rc) {
-		CERROR("Failed to init freelist for message container\n");
-		lnet_msg_container_cleanup(container);
-		return rc;
-	}
-#else
-	rc = 0;
-#endif
 	/* number of CPUs */
 	container->msc_nfinalizers = cfs_cpt_weight(lnet_cpt_table(), cpt);
 
@@ -613,7 +595,7 @@ lnet_msg_container_setup(struct lnet_msg_container *container, int cpt)
 		return -ENOMEM;
 	}
 
-	return rc;
+	return 0;
 }
 
 void
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index ad9cd44..c1e7bc5 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1049,7 +1049,7 @@ lnet_router_checker_start(void)
 {
 	struct task_struct *task;
 	int rc;
-	int eqsz;
+	int eqsz = 0;
 
 	LASSERT(the_lnet.ln_rc_state == LNET_RC_STATE_SHUTDOWN);
 
@@ -1060,13 +1060,8 @@ lnet_router_checker_start(void)
 	}
 
 	sema_init(&the_lnet.ln_rc_signal, 0);
-	/*
-	 * EQ size doesn't matter; the callback is guaranteed to get every
-	 * event
-	 */
-	eqsz = 0;
-	rc = LNetEQAlloc(eqsz, lnet_router_checker_event,
-			 &the_lnet.ln_rc_eqh);
+
+	rc = LNetEQAlloc(0, lnet_router_checker_event, &the_lnet.ln_rc_eqh);
 	if (rc) {
 		CERROR("Can't allocate EQ(%d): %d\n", eqsz, rc);
 		return -ENOMEM;
-- 
1.7.1
