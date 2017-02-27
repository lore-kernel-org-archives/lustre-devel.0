From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:27 -0500
Subject: [lustre-devel] [PATCH 02/34] staging: lustre: lnet: change
	lnet_handle_eq_t to proper struct
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_handle_eq_t from a typedef of another typedef into
a proper stand alone structure. Create the inline functions
LNetInvalidateEQHandle and LNetEQHandleIsInvalid to handle this
new piece of data.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h    |  8 +++----
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |  6 +++---
 .../staging/lustre/include/linux/lnet/lib-types.h  |  4 ++--
 drivers/staging/lustre/include/linux/lnet/types.h  | 25 ++++++++++++++++++++--
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  4 ++--
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |  6 +++---
 drivers/staging/lustre/lnet/lnet/lib-md.c          |  4 ++--
 drivers/staging/lustre/lnet/lnet/router.c          |  2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         |  4 ++--
 drivers/staging/lustre/lustre/include/lustre_net.h |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/events.c      |  2 +-
 11 files changed, 44 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index cb0d6b4..1db4e00 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -147,7 +147,7 @@ int LNetMDBind(lnet_md_t	   md_in,
  * associated with it. If an event handler exists, it will be run for each
  * event that is deposited into the EQ.
  *
- * In addition to the lnet_handle_eq_t, the LNet API defines two types
+ * In addition to the lnet_handle_eq, the LNet API defines two types
  * associated with events: The ::lnet_event_kind_t defines the kinds of events
  * that can be stored in an EQ. The lnet_event_t defines a structure that
  * holds the information about with an event.
@@ -162,11 +162,11 @@ int LNetMDBind(lnet_md_t	   md_in,
  */
 int LNetEQAlloc(unsigned int       count_in,
 		lnet_eq_handler_t  handler,
-		lnet_handle_eq_t  *handle_out);
+		struct lnet_handle_eq *handle_out);
 
-int LNetEQFree(lnet_handle_eq_t eventq_in);
+int LNetEQFree(struct lnet_handle_eq eventq_in);
 
-int LNetEQPoll(lnet_handle_eq_t *eventqs_in,
+int LNetEQPoll(struct lnet_handle_eq *eventqs_in,
 	       int		 neq_in,
 	       int		 timeout_ms,
 	       lnet_event_t     *event_out,
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 3d19402..808d886 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -278,10 +278,10 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline void
-lnet_eq2handle(lnet_handle_eq_t *handle, lnet_eq_t *eq)
+lnet_eq2handle(struct lnet_handle_eq *handle, lnet_eq_t *eq)
 {
 	if (!eq) {
-		LNetInvalidateHandle(handle);
+		LNetInvalidateEQHandle(handle);
 		return;
 	}
 
@@ -289,7 +289,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline lnet_eq_t *
-lnet_handle2eq(lnet_handle_eq_t *handle)
+lnet_handle2eq(struct lnet_handle_eq *handle)
 {
 	lnet_libhandle_t *lh;
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 9850398..199e194 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -598,13 +598,13 @@ struct lnet_msg_container {
 	lnet_rtrbufpool_t		**ln_rtrpools;
 
 	lnet_handle_md_t		  ln_ping_target_md;
-	lnet_handle_eq_t		  ln_ping_target_eq;
+	struct lnet_handle_eq		  ln_ping_target_eq;
 	struct lnet_ping_info		 *ln_ping_info;
 
 	/* router checker startup/shutdown state */
 	int				  ln_rc_state;
 	/* router checker's event queue */
-	lnet_handle_eq_t		  ln_rc_eqh;
+	struct lnet_handle_eq		  ln_rc_eqh;
 	/* rcd still pending on net */
 	struct list_head		  ln_rcd_deathrow;
 	/* rcd ready for free */
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 1c8de72..ebf87cd 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -284,7 +284,6 @@ struct lnet_ping_info {
 	__u64	 cookie;
 } lnet_handle_any_t;
 
-typedef lnet_handle_any_t lnet_handle_eq_t;
 typedef lnet_handle_any_t lnet_handle_md_t;
 typedef lnet_handle_any_t lnet_handle_me_t;
 
@@ -318,6 +317,28 @@ static inline int LNetHandleIsInvalid(lnet_handle_any_t h)
 	return h.cookie == LNET_WIRE_HANDLE_COOKIE_NONE;
 }
 
+struct lnet_handle_eq {
+	u64	cookie;
+};
+
+/**
+ * Invalidate eq handle @h.
+ */
+static inline void LNetInvalidateEQHandle(struct lnet_handle_eq *h)
+{
+	h->cookie = LNET_WIRE_HANDLE_COOKIE_NONE;
+}
+
+/**
+ * Check whether eq handle @h is invalid.
+ *
+ * @return 1 if handle is invalid, 0 if valid.
+ */
+static inline int LNetEQHandleIsInvalid(struct lnet_handle_eq h)
+{
+	return (LNET_WIRE_HANDLE_COOKIE_NONE == h.cookie);
+}
+
 /**
  * Global process ID.
  */
@@ -461,7 +482,7 @@ static inline int LNetHandleIsInvalid(lnet_handle_any_t h)
 	 * by LNetInvalidateHandle()), operations performed on this memory
 	 * descriptor are not logged.
 	 */
-	lnet_handle_eq_t eq_handle;
+	struct lnet_handle_eq eq_handle;
 } lnet_md_t;
 
 /*
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 08b38ef..0564e93 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1433,7 +1433,7 @@ int lnet_lib_init(void)
 	}
 
 	the_lnet.ln_refcount = 0;
-	LNetInvalidateHandle(&the_lnet.ln_rc_eqh);
+	LNetInvalidateEQHandle(&the_lnet.ln_rc_eqh);
 	INIT_LIST_HEAD(&the_lnet.ln_lnds);
 	INIT_LIST_HEAD(&the_lnet.ln_rcd_zombie);
 	INIT_LIST_HEAD(&the_lnet.ln_rcd_deathrow);
@@ -2138,7 +2138,7 @@ void LNetDebugPeer(lnet_process_id_t id)
 static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 		     lnet_process_id_t __user *ids, int n_ids)
 {
-	lnet_handle_eq_t eqh;
+	struct lnet_handle_eq eqh;
 	lnet_handle_md_t mdh;
 	lnet_event_t event;
 	lnet_md_t md = { NULL };
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index d05c6cc..6645fdc 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -64,7 +64,7 @@
  */
 int
 LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
-	    lnet_handle_eq_t *handle)
+	    struct lnet_handle_eq *handle)
 {
 	lnet_eq_t *eq;
 
@@ -152,7 +152,7 @@
  * \retval -EBUSY  If the EQ is still in use by some MDs.
  */
 int
-LNetEQFree(lnet_handle_eq_t eqh)
+LNetEQFree(struct lnet_handle_eq eqh)
 {
 	struct lnet_eq *eq;
 	lnet_event_t *events = NULL;
@@ -370,7 +370,7 @@
  * \retval -ENOENT    If there's an invalid handle in \a eventqs.
  */
 int
-LNetEQPoll(lnet_handle_eq_t *eventqs, int neq, int timeout_ms,
+LNetEQPoll(struct lnet_handle_eq *eventqs, int neq, int timeout_ms,
 	   lnet_event_t *event, int *which)
 {
 	int wait = 1;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index eab53cd..d97e046 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -165,7 +165,7 @@
 
 /* must be called with resource lock held */
 static int
-lnet_md_link(lnet_libmd_t *md, lnet_handle_eq_t eq_handle, int cpt)
+lnet_md_link(lnet_libmd_t *md, struct lnet_handle_eq eq_handle, int cpt)
 {
 	struct lnet_res_container *container = the_lnet.ln_md_containers[cpt];
 
@@ -185,7 +185,7 @@
 	 * maybe there we shouldn't even allow LNET_EQ_NONE!)
 	 * LASSERT(!eq);
 	 */
-	if (!LNetHandleIsInvalid(eq_handle)) {
+	if (!LNetEQHandleIsInvalid(eq_handle)) {
 		md->md_eq = lnet_handle2eq(&eq_handle);
 
 		if (!md->md_eq)
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index cf22525..ba80221 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -933,7 +933,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	md.options = LNET_MD_TRUNCATE;
 	md.eq_handle = the_lnet.ln_rc_eqh;
 
-	LASSERT(!LNetHandleIsInvalid(the_lnet.ln_rc_eqh));
+	LASSERT(!LNetEQHandleIsInvalid(the_lnet.ln_rc_eqh));
 	rc = LNetMDBind(md, LNET_UNLINK, &rcd->rcd_mdh);
 	if (rc < 0) {
 		CERROR("Can't bind MD: %d\n", rc);
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 92cd411..3f070eb 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -53,7 +53,7 @@ enum srpc_state {
 static struct smoketest_rpc {
 	spinlock_t	 rpc_glock;	/* global lock */
 	struct srpc_service	*rpc_services[SRPC_SERVICE_MAX_ID + 1];
-	lnet_handle_eq_t rpc_lnet_eq;	/* _the_ LNet event queue */
+	struct lnet_handle_eq	 rpc_lnet_eq;	/* _the_ LNet event queue */
 	enum srpc_state	 rpc_state;
 	struct srpc_counters	 rpc_counters;
 	__u64		 rpc_matchbits;	/* matchbits counter */
@@ -1622,7 +1622,7 @@ struct srpc_client_rpc *
 
 	srpc_data.rpc_state = SRPC_STATE_NI_INIT;
 
-	LNetInvalidateHandle(&srpc_data.rpc_lnet_eq);
+	LNetInvalidateEQHandle(&srpc_data.rpc_lnet_eq);
 	rc = LNetEQAlloc(0, srpc_lnet_ev_handler, &srpc_data.rpc_lnet_eq);
 	if (rc) {
 		CERROR("LNetEQAlloc() has failed: %d\n", rc);
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 1b48df0..7955cbf 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1749,7 +1749,7 @@ static inline bool nrs_policy_compat_one(const struct ptlrpc_service *svc,
 /** @} nrs */
 
 /* ptlrpc/events.c */
-extern lnet_handle_eq_t ptlrpc_eq_h;
+extern struct lnet_handle_eq ptlrpc_eq_h;
 int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 			lnet_process_id_t *peer, lnet_nid_t *self);
 /**
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index dc0fe9d..ca11b03 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -42,7 +42,7 @@
 #include "../include/lustre_sec.h"
 #include "ptlrpc_internal.h"
 
-lnet_handle_eq_t   ptlrpc_eq_h;
+struct lnet_handle_eq ptlrpc_eq_h;
 
 /*
  *  Client's outgoing request callback
-- 
1.8.3.1
