From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:32 -0500
Subject: [lustre-devel] [PATCH 07/34] staging: lustre: lnet: change
	lnet_libhandle_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_libhandle_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h  | 16 ++++++++--------
 drivers/staging/lustre/include/linux/lnet/lib-types.h | 10 +++++-----
 drivers/staging/lustre/lnet/lnet/api-ni.c             |  7 ++++---
 3 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index e894990..1c147b3 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -266,12 +266,12 @@ static inline int lnet_md_unlinkable(lnet_libmd_t *md)
 	LIBCFS_FREE(msg, sizeof(*msg));
 }
 
-lnet_libhandle_t *lnet_res_lh_lookup(struct lnet_res_container *rec,
-				     __u64 cookie);
+struct lnet_libhandle *lnet_res_lh_lookup(struct lnet_res_container *rec,
+					  __u64 cookie);
 void lnet_res_lh_initialize(struct lnet_res_container *rec,
-			    lnet_libhandle_t *lh);
+			    struct lnet_libhandle *lh);
 static inline void
-lnet_res_lh_invalidate(lnet_libhandle_t *lh)
+lnet_res_lh_invalidate(struct lnet_libhandle *lh)
 {
 	/* NB: cookie is still useful, don't reset it */
 	list_del(&lh->lh_hash_chain);
@@ -291,7 +291,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 static inline lnet_eq_t *
 lnet_handle2eq(struct lnet_handle_eq *handle)
 {
-	lnet_libhandle_t *lh;
+	struct lnet_libhandle *lh;
 
 	lh = lnet_res_lh_lookup(&the_lnet.ln_eq_container, handle->cookie);
 	if (!lh)
@@ -310,7 +310,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 lnet_handle2md(struct lnet_handle_md *handle)
 {
 	/* ALWAYS called with resource lock held */
-	lnet_libhandle_t *lh;
+	struct lnet_libhandle *lh;
 	int cpt;
 
 	cpt = lnet_cpt_of_cookie(handle->cookie);
@@ -326,7 +326,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 lnet_wire_handle2md(struct lnet_handle_wire *wh)
 {
 	/* ALWAYS called with resource lock held */
-	lnet_libhandle_t *lh;
+	struct lnet_libhandle *lh;
 	int cpt;
 
 	if (wh->wh_interface_cookie != the_lnet.ln_interface_cookie)
@@ -351,7 +351,7 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 lnet_handle2me(struct lnet_handle_me *handle)
 {
 	/* ALWAYS called with resource lock held */
-	lnet_libhandle_t *lh;
+	struct lnet_libhandle *lh;
 	int cpt;
 
 	cpt = lnet_cpt_of_cookie(handle->cookie);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index e3cb795..9f301f4 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -108,17 +108,17 @@ struct lnet_msg {
 	struct lnet_hdr		 msg_hdr;
 };
 
-typedef struct lnet_libhandle {
+struct lnet_libhandle {
 	struct list_head	lh_hash_chain;
 	__u64			lh_cookie;
-} lnet_libhandle_t;
+};
 
 #define lh_entry(ptr, type, member) \
 	((type *)((char *)(ptr) - (char *)(&((type *)0)->member)))
 
 typedef struct lnet_eq {
 	struct list_head	  eq_list;
-	lnet_libhandle_t	  eq_lh;
+	struct lnet_libhandle	  eq_lh;
 	lnet_seq_t		  eq_enq_seq;
 	lnet_seq_t		  eq_deq_seq;
 	unsigned int		  eq_size;
@@ -129,7 +129,7 @@ struct lnet_msg {
 
 typedef struct lnet_me {
 	struct list_head	 me_list;
-	lnet_libhandle_t	 me_lh;
+	struct lnet_libhandle	 me_lh;
 	lnet_process_id_t	 me_match_id;
 	unsigned int		 me_portal;
 	unsigned int		 me_pos;	/* hash offset in mt_hash */
@@ -141,7 +141,7 @@ struct lnet_msg {
 
 typedef struct lnet_libmd {
 	struct list_head	 md_list;
-	lnet_libhandle_t	 md_lh;
+	struct lnet_libhandle	 md_lh;
 	lnet_me_t		*md_me;
 	char			*md_start;
 	unsigned int		 md_offset;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 5161b8a..4c9a064 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -483,12 +483,12 @@ static void lnet_assert_wire_constants(void)
 	return recs;
 }
 
-lnet_libhandle_t *
+struct lnet_libhandle *
 lnet_res_lh_lookup(struct lnet_res_container *rec, __u64 cookie)
 {
 	/* ALWAYS called with lnet_res_lock held */
 	struct list_head *head;
-	lnet_libhandle_t *lh;
+	struct lnet_libhandle *lh;
 	unsigned int hash;
 
 	if ((cookie & LNET_COOKIE_MASK) != rec->rec_type)
@@ -506,7 +506,8 @@ static void lnet_assert_wire_constants(void)
 }
 
 void
-lnet_res_lh_initialize(struct lnet_res_container *rec, lnet_libhandle_t *lh)
+lnet_res_lh_initialize(struct lnet_res_container *rec,
+		       struct lnet_libhandle *lh)
 {
 	/* ALWAYS called with lnet_res_lock held */
 	unsigned int ibits = LNET_COOKIE_TYPE_BITS + LNET_CPT_BITS;
-- 
1.8.3.1
