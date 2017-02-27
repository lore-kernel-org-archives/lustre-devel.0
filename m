From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:33 -0500
Subject: [lustre-devel] [PATCH 08/34] staging: lustre: lnet: change
	lnet_eq_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_eq_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h  | 14 +++++++-------
 drivers/staging/lustre/include/linux/lnet/lib-types.h |  6 +++---
 drivers/staging/lustre/lnet/lnet/api-ni.c             |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-eq.c             |  8 ++++----
 4 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 1c147b3..9e33d0a 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -178,17 +178,17 @@ static inline int lnet_md_unlinkable(lnet_libmd_t *md)
 
 #define MAX_PORTALS		64
 
-static inline lnet_eq_t *
+static inline struct lnet_eq *
 lnet_eq_alloc(void)
 {
-	lnet_eq_t *eq;
+	struct lnet_eq *eq;
 
 	LIBCFS_ALLOC(eq, sizeof(*eq));
 	return eq;
 }
 
 static inline void
-lnet_eq_free(lnet_eq_t *eq)
+lnet_eq_free(struct lnet_eq *eq)
 {
 	LIBCFS_FREE(eq, sizeof(*eq));
 }
@@ -278,7 +278,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline void
-lnet_eq2handle(struct lnet_handle_eq *handle, lnet_eq_t *eq)
+lnet_eq2handle(struct lnet_handle_eq *handle, struct lnet_eq *eq)
 {
 	if (!eq) {
 		LNetInvalidateEQHandle(handle);
@@ -288,7 +288,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 	handle->cookie = eq->eq_lh.lh_cookie;
 }
 
-static inline lnet_eq_t *
+static inline struct lnet_eq *
 lnet_handle2eq(struct lnet_handle_eq *handle)
 {
 	struct lnet_libhandle *lh;
@@ -297,7 +297,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 	if (!lh)
 		return NULL;
 
-	return lh_entry(lh, lnet_eq_t, eq_lh);
+	return lh_entry(lh, struct lnet_eq, eq_lh);
 }
 
 static inline void
@@ -490,7 +490,7 @@ void lnet_msg_attach_md(struct lnet_msg *msg, lnet_libmd_t *md,
 void lnet_msg_commit(struct lnet_msg *msg, int cpt);
 void lnet_msg_decommit(struct lnet_msg *msg, int cpt, int status);
 
-void lnet_eq_enqueue_event(lnet_eq_t *eq, lnet_event_t *ev);
+void lnet_eq_enqueue_event(struct lnet_eq *eq, lnet_event_t *ev);
 void lnet_prep_send(struct lnet_msg *msg, int type, lnet_process_id_t target,
 		    unsigned int offset, unsigned int len);
 int lnet_send(lnet_nid_t nid, struct lnet_msg *msg, lnet_nid_t rtr_nid);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 9f301f4..19e01cc 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -116,7 +116,7 @@ struct lnet_libhandle {
 #define lh_entry(ptr, type, member) \
 	((type *)((char *)(ptr) - (char *)(&((type *)0)->member)))
 
-typedef struct lnet_eq {
+struct lnet_eq {
 	struct list_head	  eq_list;
 	struct lnet_libhandle	  eq_lh;
 	lnet_seq_t		  eq_enq_seq;
@@ -125,7 +125,7 @@ struct lnet_libhandle {
 	lnet_eq_handler_t	  eq_callback;
 	lnet_event_t		 *eq_events;
 	int			**eq_refs;	/* percpt refcount for EQ */
-} lnet_eq_t;
+};
 
 typedef struct lnet_me {
 	struct list_head	 me_list;
@@ -152,7 +152,7 @@ struct lnet_libhandle {
 	unsigned int		 md_options;
 	unsigned int		 md_flags;
 	void			*md_user_ptr;
-	lnet_eq_t		*md_eq;
+	struct lnet_eq		*md_eq;
 	unsigned int		 md_niov;	/* # frags */
 	union {
 		struct kvec	iov[LNET_MAX_IOV];
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 4c9a064..ee47ba9 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -383,7 +383,7 @@ static void lnet_assert_wire_constants(void)
 
 		list_del_init(e);
 		if (rec->rec_type == LNET_COOKIE_TYPE_EQ) {
-			lnet_eq_free(list_entry(e, lnet_eq_t, eq_list));
+			lnet_eq_free(list_entry(e, struct lnet_eq, eq_list));
 
 		} else if (rec->rec_type == LNET_COOKIE_TYPE_MD) {
 			lnet_md_free(list_entry(e, lnet_libmd_t, md_list));
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index 6645fdc..4369df3 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -66,7 +66,7 @@
 LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
 	    struct lnet_handle_eq *handle)
 {
-	lnet_eq_t *eq;
+	struct lnet_eq *eq;
 
 	LASSERT(the_lnet.ln_refcount > 0);
 
@@ -210,7 +210,7 @@
 EXPORT_SYMBOL(LNetEQFree);
 
 void
-lnet_eq_enqueue_event(lnet_eq_t *eq, lnet_event_t *ev)
+lnet_eq_enqueue_event(struct lnet_eq *eq, lnet_event_t *ev)
 {
 	/* MUST called with resource lock hold but w/o lnet_eq_wait_lock */
 	int index;
@@ -239,7 +239,7 @@
 }
 
 static int
-lnet_eq_dequeue_event(lnet_eq_t *eq, lnet_event_t *ev)
+lnet_eq_dequeue_event(struct lnet_eq *eq, lnet_event_t *ev)
 {
 	int new_index = eq->eq_deq_seq & (eq->eq_size - 1);
 	lnet_event_t *new_event = &eq->eq_events[new_index];
@@ -386,7 +386,7 @@
 
 	for (;;) {
 		for (i = 0; i < neq; i++) {
-			lnet_eq_t *eq = lnet_handle2eq(&eventqs[i]);
+			struct lnet_eq *eq = lnet_handle2eq(&eventqs[i]);
 
 			if (!eq) {
 				lnet_eq_wait_unlock();
-- 
1.8.3.1
