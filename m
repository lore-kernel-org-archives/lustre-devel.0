From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:34 -0500
Subject: [lustre-devel] [PATCH 09/34] staging: lustre: lnet: change
	lnet_me_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_me_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h  | 18 +++++++++---------
 drivers/staging/lustre/include/linux/lnet/lib-types.h |  6 +++---
 drivers/staging/lustre/lnet/lnet/lib-md.c             |  2 +-
 drivers/staging/lustre/lnet/lnet/lib-me.c             |  4 ++--
 drivers/staging/lustre/lnet/lnet/lib-ptl.c            | 14 +++++++-------
 5 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 9e33d0a..a82bb3c 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -233,17 +233,17 @@ static inline int lnet_md_unlinkable(lnet_libmd_t *md)
 	LIBCFS_FREE(md, size);
 }
 
-static inline lnet_me_t *
+static inline struct lnet_me *
 lnet_me_alloc(void)
 {
-	lnet_me_t *me;
+	struct lnet_me *me;
 
 	LIBCFS_ALLOC(me, sizeof(*me));
 	return me;
 }
 
 static inline void
-lnet_me_free(lnet_me_t *me)
+lnet_me_free(struct lnet_me *me)
 {
 	LIBCFS_FREE(me, sizeof(*me));
 }
@@ -342,12 +342,12 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline void
-lnet_me2handle(struct lnet_handle_me *handle, lnet_me_t *me)
+lnet_me2handle(struct lnet_handle_me *handle, struct lnet_me *me)
 {
 	handle->cookie = me->me_lh.lh_cookie;
 }
 
-static inline lnet_me_t *
+static inline struct lnet_me *
 lnet_handle2me(struct lnet_handle_me *handle)
 {
 	/* ALWAYS called with resource lock held */
@@ -360,7 +360,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 	if (!lh)
 		return NULL;
 
-	return lh_entry(lh, lnet_me_t, me_lh);
+	return lh_entry(lh, struct lnet_me, me_lh);
 }
 
 static inline void
@@ -542,9 +542,9 @@ int lnet_mt_match_md(struct lnet_match_table *mtable,
 		     struct lnet_match_info *info, struct lnet_msg *msg);
 
 /* portals match/attach functions */
-void lnet_ptl_attach_md(lnet_me_t *me, lnet_libmd_t *md,
+void lnet_ptl_attach_md(struct lnet_me *me, lnet_libmd_t *md,
 			struct list_head *matches, struct list_head *drops);
-void lnet_ptl_detach_md(lnet_me_t *me, lnet_libmd_t *md);
+void lnet_ptl_detach_md(struct lnet_me *me, lnet_libmd_t *md);
 int lnet_ptl_match_md(struct lnet_match_info *info, struct lnet_msg *msg);
 
 /* initialized and finalize portals */
@@ -623,7 +623,7 @@ void lnet_copy_kiov2iter(struct iov_iter *to,
 			 unsigned int nkiov, const lnet_kiov_t *kiov,
 			 unsigned int kiovoffset, unsigned int nob);
 
-void lnet_me_unlink(lnet_me_t *me);
+void lnet_me_unlink(struct lnet_me *me);
 
 void lnet_md_unlink(lnet_libmd_t *md);
 void lnet_md_deconstruct(lnet_libmd_t *lmd, lnet_md_t *umd);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 19e01cc..3384860 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -127,7 +127,7 @@ struct lnet_eq {
 	int			**eq_refs;	/* percpt refcount for EQ */
 };
 
-typedef struct lnet_me {
+struct lnet_me {
 	struct list_head	 me_list;
 	struct lnet_libhandle	 me_lh;
 	lnet_process_id_t	 me_match_id;
@@ -137,12 +137,12 @@ struct lnet_eq {
 	__u64			 me_ignore_bits;
 	lnet_unlink_t		 me_unlink;
 	struct lnet_libmd	*me_md;
-} lnet_me_t;
+};
 
 typedef struct lnet_libmd {
 	struct list_head	 md_list;
 	struct lnet_libhandle	 md_lh;
-	lnet_me_t		*md_me;
+	struct lnet_me		*md_me;
 	char			*md_start;
 	unsigned int		 md_offset;
 	unsigned int		 md_length;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index 4f2700e..dd3cdda 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -44,7 +44,7 @@
 {
 	if (!(md->md_flags & LNET_MD_FLAG_ZOMBIE)) {
 		/* first unlink attempt... */
-		lnet_me_t *me = md->md_me;
+		struct lnet_me *me = md->md_me;
 
 		md->md_flags |= LNET_MD_FLAG_ZOMBIE;
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index 0ea64f6..20cc8f8 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -222,7 +222,7 @@
 int
 LNetMEUnlink(struct lnet_handle_me meh)
 {
-	lnet_me_t *me;
+	struct lnet_me *me;
 	lnet_libmd_t *md;
 	lnet_event_t ev;
 	int cpt;
@@ -256,7 +256,7 @@
 
 /* call with lnet_res_lock please */
 void
-lnet_me_unlink(lnet_me_t *me)
+lnet_me_unlink(struct lnet_me *me)
 {
 	list_del(&me->me_list);
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 891d028..b538939 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -140,7 +140,7 @@
 	 */
 	unsigned int offset;
 	unsigned int mlength;
-	lnet_me_t *me = md->md_me;
+	struct lnet_me *me = md->md_me;
 
 	/* MD exhausted */
 	if (lnet_md_exhausted(md))
@@ -376,8 +376,8 @@ struct list_head *
 		 struct lnet_match_info *info, struct lnet_msg *msg)
 {
 	struct list_head *head;
-	lnet_me_t *me;
-	lnet_me_t *tmp;
+	struct lnet_me *me;
+	struct lnet_me *tmp;
 	int exhausted = 0;
 	int rc;
 
@@ -641,7 +641,7 @@ struct list_head *
 }
 
 void
-lnet_ptl_detach_md(lnet_me_t *me, lnet_libmd_t *md)
+lnet_ptl_detach_md(struct lnet_me *me, lnet_libmd_t *md)
 {
 	LASSERT(me->me_md == md && md->md_me == me);
 
@@ -651,7 +651,7 @@ struct list_head *
 
 /* called with lnet_res_lock held */
 void
-lnet_ptl_attach_md(lnet_me_t *me, lnet_libmd_t *md,
+lnet_ptl_attach_md(struct lnet_me *me, lnet_libmd_t *md,
 		   struct list_head *matches, struct list_head *drops)
 {
 	struct lnet_portal *ptl = the_lnet.ln_portals[me->me_portal];
@@ -756,7 +756,7 @@ struct list_head *
 	LASSERT(list_empty(&ptl->ptl_msg_stealing));
 	cfs_percpt_for_each(mtable, i, ptl->ptl_mtables) {
 		struct list_head *mhash;
-		lnet_me_t *me;
+		struct lnet_me *me;
 		int j;
 
 		if (!mtable->mt_mhash) /* uninitialized match-table */
@@ -767,7 +767,7 @@ struct list_head *
 		for (j = 0; j < LNET_MT_HASH_SIZE + 1; j++) {
 			while (!list_empty(&mhash[j])) {
 				me = list_entry(mhash[j].next,
-						lnet_me_t, me_list);
+						struct lnet_me, me_list);
 				CERROR("Active ME %p on exit\n", me);
 				list_del(&me->me_list);
 				lnet_me_free(me);
-- 
1.8.3.1
