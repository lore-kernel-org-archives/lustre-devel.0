From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:35 -0500
Subject: [lustre-devel] [PATCH 10/34] staging: lustre: lnet: change
	lnet_libmd_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_libmd_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   | 40 +++++++++++-----------
 .../staging/lustre/include/linux/lnet/lib-types.h  |  4 +--
 drivers/staging/lustre/lnet/lnet/api-ni.c          |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-md.c          | 12 +++----
 drivers/staging/lustre/lnet/lnet/lib-me.c          |  4 +--
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  6 ++--
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |  6 ++--
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |  6 ++--
 8 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index a82bb3c..685c5d4 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -84,14 +84,14 @@ static inline int lnet_is_wire_handle_none(struct lnet_handle_wire *wh)
 		wh->wh_object_cookie == LNET_WIRE_HANDLE_COOKIE_NONE);
 }
 
-static inline int lnet_md_exhausted(lnet_libmd_t *md)
+static inline int lnet_md_exhausted(struct lnet_libmd *md)
 {
 	return (!md->md_threshold ||
 		((md->md_options & LNET_MD_MAX_SIZE) &&
 		 md->md_offset + md->md_max_size > md->md_length));
 }
 
-static inline int lnet_md_unlinkable(lnet_libmd_t *md)
+static inline int lnet_md_unlinkable(struct lnet_libmd *md)
 {
 	/*
 	 * Should unlink md when its refcount is 0 and either:
@@ -193,19 +193,19 @@ static inline int lnet_md_unlinkable(lnet_libmd_t *md)
 	LIBCFS_FREE(eq, sizeof(*eq));
 }
 
-static inline lnet_libmd_t *
+static inline struct lnet_libmd *
 lnet_md_alloc(lnet_md_t *umd)
 {
-	lnet_libmd_t *md;
+	struct lnet_libmd *md;
 	unsigned int size;
 	unsigned int niov;
 
 	if (umd->options & LNET_MD_KIOV) {
 		niov = umd->length;
-		size = offsetof(lnet_libmd_t, md_iov.kiov[niov]);
+		size = offsetof(struct lnet_libmd, md_iov.kiov[niov]);
 	} else {
 		niov = umd->options & LNET_MD_IOVEC ? umd->length : 1;
-		size = offsetof(lnet_libmd_t, md_iov.iov[niov]);
+		size = offsetof(struct lnet_libmd, md_iov.iov[niov]);
 	}
 
 	LIBCFS_ALLOC(md, size);
@@ -221,14 +221,14 @@ static inline int lnet_md_unlinkable(lnet_libmd_t *md)
 }
 
 static inline void
-lnet_md_free(lnet_libmd_t *md)
+lnet_md_free(struct lnet_libmd *md)
 {
 	unsigned int size;
 
 	if (md->md_options & LNET_MD_KIOV)
-		size = offsetof(lnet_libmd_t, md_iov.kiov[md->md_niov]);
+		size = offsetof(struct lnet_libmd, md_iov.kiov[md->md_niov]);
 	else
-		size = offsetof(lnet_libmd_t, md_iov.iov[md->md_niov]);
+		size = offsetof(struct lnet_libmd, md_iov.iov[md->md_niov]);
 
 	LIBCFS_FREE(md, size);
 }
@@ -301,12 +301,12 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline void
-lnet_md2handle(struct lnet_handle_md *handle, lnet_libmd_t *md)
+lnet_md2handle(struct lnet_handle_md *handle, struct lnet_libmd *md)
 {
 	handle->cookie = md->md_lh.lh_cookie;
 }
 
-static inline lnet_libmd_t *
+static inline struct lnet_libmd *
 lnet_handle2md(struct lnet_handle_md *handle)
 {
 	/* ALWAYS called with resource lock held */
@@ -319,10 +319,10 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 	if (!lh)
 		return NULL;
 
-	return lh_entry(lh, lnet_libmd_t, md_lh);
+	return lh_entry(lh, struct lnet_libmd, md_lh);
 }
 
-static inline lnet_libmd_t *
+static inline struct lnet_libmd *
 lnet_wire_handle2md(struct lnet_handle_wire *wh)
 {
 	/* ALWAYS called with resource lock held */
@@ -338,7 +338,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 	if (!lh)
 		return NULL;
 
-	return lh_entry(lh, lnet_libmd_t, md_lh);
+	return lh_entry(lh, struct lnet_libmd, md_lh);
 }
 
 static inline void
@@ -482,10 +482,10 @@ int lnet_dyn_add_ni(lnet_pid_t requested_pid,
 int lnet_islocalnid(lnet_nid_t nid);
 int lnet_islocalnet(__u32 net);
 
-void lnet_msg_attach_md(struct lnet_msg *msg, lnet_libmd_t *md,
+void lnet_msg_attach_md(struct lnet_msg *msg, struct lnet_libmd *md,
 			unsigned int offset, unsigned int mlen);
 void lnet_msg_detach_md(struct lnet_msg *msg, int status);
-void lnet_build_unlink_event(lnet_libmd_t *md, lnet_event_t *ev);
+void lnet_build_unlink_event(struct lnet_libmd *md, lnet_event_t *ev);
 void lnet_build_msg_event(struct lnet_msg *msg, lnet_event_kind_t ev_type);
 void lnet_msg_commit(struct lnet_msg *msg, int cpt);
 void lnet_msg_decommit(struct lnet_msg *msg, int cpt, int status);
@@ -542,9 +542,9 @@ int lnet_mt_match_md(struct lnet_match_table *mtable,
 		     struct lnet_match_info *info, struct lnet_msg *msg);
 
 /* portals match/attach functions */
-void lnet_ptl_attach_md(struct lnet_me *me, lnet_libmd_t *md,
+void lnet_ptl_attach_md(struct lnet_me *me, struct lnet_libmd *md,
 			struct list_head *matches, struct list_head *drops);
-void lnet_ptl_detach_md(struct lnet_me *me, lnet_libmd_t *md);
+void lnet_ptl_detach_md(struct lnet_me *me, struct lnet_libmd *md);
 int lnet_ptl_match_md(struct lnet_match_info *info, struct lnet_msg *msg);
 
 /* initialized and finalize portals */
@@ -625,8 +625,8 @@ void lnet_copy_kiov2iter(struct iov_iter *to,
 
 void lnet_me_unlink(struct lnet_me *me);
 
-void lnet_md_unlink(lnet_libmd_t *md);
-void lnet_md_deconstruct(lnet_libmd_t *lmd, lnet_md_t *umd);
+void lnet_md_unlink(struct lnet_libmd *md);
+void lnet_md_deconstruct(struct lnet_libmd *lmd, lnet_md_t *umd);
 
 void lnet_register_lnd(lnd_t *lnd);
 void lnet_unregister_lnd(lnd_t *lnd);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 3384860..6dd7edd 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -139,7 +139,7 @@ struct lnet_me {
 	struct lnet_libmd	*me_md;
 };
 
-typedef struct lnet_libmd {
+struct lnet_libmd {
 	struct list_head	 md_list;
 	struct lnet_libhandle	 md_lh;
 	struct lnet_me		*md_me;
@@ -158,7 +158,7 @@ struct lnet_me {
 		struct kvec	iov[LNET_MAX_IOV];
 		lnet_kiov_t	kiov[LNET_MAX_IOV];
 	} md_iov;
-} lnet_libmd_t;
+};
 
 #define LNET_MD_FLAG_ZOMBIE		(1 << 0)
 #define LNET_MD_FLAG_AUTO_UNLINK	(1 << 1)
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index ee47ba9..aeb9e6f 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -386,7 +386,7 @@ static void lnet_assert_wire_constants(void)
 			lnet_eq_free(list_entry(e, struct lnet_eq, eq_list));
 
 		} else if (rec->rec_type == LNET_COOKIE_TYPE_MD) {
-			lnet_md_free(list_entry(e, lnet_libmd_t, md_list));
+			lnet_md_free(list_entry(e, struct lnet_libmd, md_list));
 
 		} else { /* NB: Active MEs should be attached on portals */
 			LBUG();
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index dd3cdda..bb832c5 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -40,7 +40,7 @@
 
 /* must be called with lnet_res_lock held */
 void
-lnet_md_unlink(lnet_libmd_t *md)
+lnet_md_unlink(struct lnet_libmd *md)
 {
 	if (!(md->md_flags & LNET_MD_FLAG_ZOMBIE)) {
 		/* first unlink attempt... */
@@ -84,7 +84,7 @@
 }
 
 static int
-lnet_md_build(lnet_libmd_t *lmd, lnet_md_t *umd, int unlink)
+lnet_md_build(struct lnet_libmd *lmd, lnet_md_t *umd, int unlink)
 {
 	int i;
 	unsigned int niov;
@@ -165,7 +165,7 @@
 
 /* must be called with resource lock held */
 static int
-lnet_md_link(lnet_libmd_t *md, struct lnet_handle_eq eq_handle, int cpt)
+lnet_md_link(struct lnet_libmd *md, struct lnet_handle_eq eq_handle, int cpt)
 {
 	struct lnet_res_container *container = the_lnet.ln_md_containers[cpt];
 
@@ -204,7 +204,7 @@
 
 /* must be called with lnet_res_lock held */
 void
-lnet_md_deconstruct(lnet_libmd_t *lmd, lnet_md_t *umd)
+lnet_md_deconstruct(struct lnet_libmd *lmd, lnet_md_t *umd)
 {
 	/* NB this doesn't copy out all the iov entries so when a
 	 * discontiguous MD is copied out, the target gets to know the
@@ -353,7 +353,7 @@
 LNetMDBind(lnet_md_t umd, lnet_unlink_t unlink,
 	   struct lnet_handle_md *handle)
 {
-	lnet_libmd_t *md;
+	struct lnet_libmd *md;
 	int cpt;
 	int rc;
 
@@ -429,7 +429,7 @@
 LNetMDUnlink(struct lnet_handle_md mdh)
 {
 	lnet_event_t ev;
-	lnet_libmd_t *md;
+	struct lnet_libmd *md;
 	int cpt;
 
 	LASSERT(the_lnet.ln_refcount > 0);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index 20cc8f8..75922a5 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -223,7 +223,7 @@
 LNetMEUnlink(struct lnet_handle_me meh)
 {
 	struct lnet_me *me;
-	lnet_libmd_t *md;
+	struct lnet_libmd *md;
 	lnet_event_t ev;
 	int cpt;
 
@@ -261,7 +261,7 @@
 	list_del(&me->me_list);
 
 	if (me->me_md) {
-		lnet_libmd_t *md = me->me_md;
+		struct lnet_libmd *md = me->me_md;
 
 		/* detach MD from portal of this ME */
 		lnet_ptl_detach_md(me, md);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index a789d7e..a55b58e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -412,7 +412,7 @@
 static void
 lnet_setpayloadbuffer(struct lnet_msg *msg)
 {
-	lnet_libmd_t *md = msg->msg_md;
+	struct lnet_libmd *md = msg->msg_md;
 
 	LASSERT(msg->msg_len > 0);
 	LASSERT(!msg->msg_routing);
@@ -1392,7 +1392,7 @@
 	void *private = msg->msg_private;
 	struct lnet_hdr *hdr = &msg->msg_hdr;
 	lnet_process_id_t src = {0};
-	lnet_libmd_t *md;
+	struct lnet_libmd *md;
 	int rlength;
 	int mlength;
 	int cpt;
@@ -1456,7 +1456,7 @@
 {
 	struct lnet_hdr *hdr = &msg->msg_hdr;
 	lnet_process_id_t src = {0};
-	lnet_libmd_t *md;
+	struct lnet_libmd *md;
 	int cpt;
 
 	src.nid = hdr->src_nid;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index d35d28b..bcb5e24 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -39,7 +39,7 @@
 #include "../../include/linux/lnet/lib-lnet.h"
 
 void
-lnet_build_unlink_event(lnet_libmd_t *md, lnet_event_t *ev)
+lnet_build_unlink_event(struct lnet_libmd *md, lnet_event_t *ev)
 {
 	memset(ev, 0, sizeof(*ev));
 
@@ -306,7 +306,7 @@
 }
 
 void
-lnet_msg_attach_md(struct lnet_msg *msg, lnet_libmd_t *md,
+lnet_msg_attach_md(struct lnet_msg *msg, struct lnet_libmd *md,
 		   unsigned int offset, unsigned int mlen)
 {
 	/* NB: @offset and @len are only useful for receiving */
@@ -338,7 +338,7 @@
 void
 lnet_msg_detach_md(struct lnet_msg *msg, int status)
 {
-	lnet_libmd_t *md = msg->msg_md;
+	struct lnet_libmd *md = msg->msg_md;
 	int unlink;
 
 	/* Now it's safe to drop my caller's ref */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index b538939..9ea3c08 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -131,7 +131,7 @@
 }
 
 static int
-lnet_try_match_md(lnet_libmd_t *md,
+lnet_try_match_md(struct lnet_libmd *md,
 		  struct lnet_match_info *info, struct lnet_msg *msg)
 {
 	/*
@@ -641,7 +641,7 @@ struct list_head *
 }
 
 void
-lnet_ptl_detach_md(struct lnet_me *me, lnet_libmd_t *md)
+lnet_ptl_detach_md(struct lnet_me *me, struct lnet_libmd *md)
 {
 	LASSERT(me->me_md == md && md->md_me == me);
 
@@ -651,7 +651,7 @@ struct list_head *
 
 /* called with lnet_res_lock held */
 void
-lnet_ptl_attach_md(struct lnet_me *me, lnet_libmd_t *md,
+lnet_ptl_attach_md(struct lnet_me *me, struct lnet_libmd *md,
 		   struct list_head *matches, struct list_head *drops)
 {
 	struct lnet_portal *ptl = the_lnet.ln_portals[me->me_portal];
-- 
1.8.3.1
