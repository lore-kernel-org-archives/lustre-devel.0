From: James Simmons <jsimmons@infradead.org>
Date: Sat,  2 Mar 2019 14:12:19 -0500
Subject: [lustre-devel] [PATCH 2/7] lustre: move header file comments to
 sphinix format
In-Reply-To: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
References: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1551553944-6419-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre comments was written for DocBook which is no longer used
by the Linux kernel. Move all the DocBook handling to sphinix.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_fid.h  |  20 ++--
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |   2 +-
 .../lustre/include/uapi/linux/lustre/lustre_user.h |  13 +--
 drivers/staging/lustre/lustre/include/cl_object.h  |  91 ++++++++--------
 drivers/staging/lustre/lustre/include/lu_object.h  |   8 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  10 +-
 .../staging/lustre/lustre/include/lustre_import.h  |   4 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h |   4 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |  76 ++++++-------
 drivers/staging/lustre/lustre/include/lustre_nrs.h | 118 ++++++++++-----------
 drivers/staging/lustre/lustre/include/lustre_sec.h |  83 ++++++++-------
 drivers/staging/lustre/lustre/include/obd_class.h  |   9 +-
 drivers/staging/lustre/lustre/include/seq_range.h  |  32 +++---
 13 files changed, 240 insertions(+), 230 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
index 746bf7a..9f7959c 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
@@ -137,8 +137,9 @@ static inline bool fid_is_mdt0(const struct lu_fid *fid)
 
 /**
  * Check if a fid is igif or not.
- * \param fid the fid to be tested.
- * \return true if the fid is an igif; otherwise false.
+ *
+ * @fid		the fid to be tested.
+ * Return:	true if the fid is an igif; otherwise false.
  */
 static inline bool fid_seq_is_igif(__u64 seq)
 {
@@ -152,8 +153,9 @@ static inline bool fid_is_igif(const struct lu_fid *fid)
 
 /**
  * Check if a fid is idif or not.
- * \param fid the fid to be tested.
- * \return true if the fid is an idif; otherwise false.
+ *
+ * @fid		the fid to be tested.
+ * Return:	true if the fid is an idif; otherwise false.
  */
 static inline bool fid_seq_is_idif(__u64 seq)
 {
@@ -205,8 +207,9 @@ static inline __u32 fid_idif_ost_idx(const struct lu_fid *fid)
 
 /**
  * Get inode number from an igif.
- * \param fid an igif to get inode number from.
- * \return inode number for the igif.
+ *
+ * @fid		an igif to get inode number from.
+ * Return:	inode number for the igif.
  */
 static inline ino_t lu_igif_ino(const struct lu_fid *fid)
 {
@@ -215,8 +218,9 @@ static inline ino_t lu_igif_ino(const struct lu_fid *fid)
 
 /**
  * Get inode generation from an igif.
- * \param fid an igif to get inode generation from.
- * \return inode generation for the igif.
+ *
+ * @fid		an igif to get inode generation from.
+ * Return:	inode generation for the igif.
  */
 static inline __u32 lu_igif_gen(const struct lu_fid *fid)
 {
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index bffe62e..a86190d 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -2746,7 +2746,7 @@ struct lustre_capa_key {
 	__u8    lk_key[CAPA_HMAC_KEY_MAX_LEN];    /**< key */
 } __packed;
 
-/** The link ea holds 1 \a link_ea_entry for each hardlink */
+/** The link ea holds 1 @link_ea_entry for each hardlink */
 #define LINK_EA_MAGIC 0x11EAF1DFUL
 struct link_ea_header {
 	__u32 leh_magic;
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index 178837c..8bc756f 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -1018,8 +1018,8 @@ static inline char *changelog_rec_sname(struct changelog_rec *rec)
  *	- CLF_RENAME will not be removed
  *	- CLF_JOBID will not be added without CLF_RENAME being added too
  *
- * @param[in,out]  rec		The record to remap.
- * @param[in]	   crf_wanted	Flags describing the desired extensions.
+ * @rec			The record to remap.
+ * @crf_wanted		Flags describing the desired extensions.
  */
 static inline void changelog_remap_rec(struct changelog_rec *rec,
 				       enum changelog_rec_flags crf_wanted)
@@ -1297,10 +1297,11 @@ struct hsm_action_item {
 /*
  * helper function which print in hexa the first bytes of
  * hai opaque field
- * \param hai [IN] record to print
- * \param buffer [OUT] output buffer
- * \param len [IN] max buffer len
- * \retval buffer
+ *
+ * @hai		record to print
+ * @buffer	output buffer
+ * @len		max buffer len
+ * Return:	buffer
  */
 static inline char *hai_dump_data_field(struct hsm_action_item *hai,
 					char *buffer, size_t len)
diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 05be853..691c2f5 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -303,15 +303,15 @@ struct cl_object_operations {
 	 * every object layer when a new cl_page is instantiated. Layer
 	 * keeping private per-page data, or requiring its own page operations
 	 * vector should allocate these data here, and attach then to the page
-	 * by calling cl_page_slice_add(). \a vmpage is locked (in the VM
+	 * by calling cl_page_slice_add(). @vmpage is locked (in the VM
 	 * sense). Optional.
 	 *
-	 * \retval NULL success.
+	 * Return:	NULL success.
 	 *
-	 * \retval ERR_PTR(errno) failure code.
+	 *		ERR_PTR(errno) failure code.
 	 *
-	 * \retval valid-pointer pointer to already existing referenced page
-	 *	 to be used instead of newly created.
+	 *		valid-pointer pointer to already existing referenced
+	 *		page to be used instead of newly created.
 	 */
 	int  (*coo_page_init)(const struct lu_env *env, struct cl_object *obj,
 			      struct cl_page *page, pgoff_t index);
@@ -337,27 +337,27 @@ struct cl_object_operations {
 	int  (*coo_io_init)(const struct lu_env *env,
 			    struct cl_object *obj, struct cl_io *io);
 	/**
-	 * Fill portion of \a attr that this layer controls. This method is
+	 * Fill portion of @attr that this layer controls. This method is
 	 * called top-to-bottom through all object layers.
 	 *
 	 * \pre cl_object_header::coh_attr_guard of the top-object is locked.
 	 *
-	 * \return   0: to continue
-	 * \return +ve: to stop iterating through layers (but 0 is returned
-	 * from enclosing cl_object_attr_get())
-	 * \return -ve: to signal error
+	 * Return:	0 to continue
+	 *		+ve to stop iterating through layers (but 0 is returned
+	 *		from enclosing cl_object_attr_get())
+	 *		-ve to signal error
 	 */
 	int (*coo_attr_get)(const struct lu_env *env, struct cl_object *obj,
 			    struct cl_attr *attr);
 	/**
 	 * Update attributes.
 	 *
-	 * \a valid is a bitmask composed from enum #cl_attr_valid, and
+	 * @valid is a bitmask composed from enum #cl_attr_valid, and
 	 * indicating what attributes are to be set.
 	 *
 	 * \pre cl_object_header::coh_attr_guard of the top-object is locked.
 	 *
-	 * \return the same convention as for
+	 * Return:	the same convention as for
 	 * cl_object_operations::coo_attr_get() is used.
 	 */
 	int (*coo_attr_update)(const struct lu_env *env, struct cl_object *obj,
@@ -372,7 +372,7 @@ struct cl_object_operations {
 			    const struct cl_object_conf *conf);
 	/**
 	 * Glimpse ast. Executed when glimpse ast arrives for a lock on this
-	 * object. Layers are supposed to fill parts of \a lvb that will be
+	 * object. Layers are supposed to fill parts of @lvb that will be
 	 * shipped to the glimpse originator as a glimpse result.
 	 *
 	 * \see vvp_object_glimpse(), lovsub_object_glimpse(),
@@ -451,16 +451,16 @@ struct cl_object_header {
 };
 
 /**
- * Helper macro: iterate over all layers of the object \a obj, assigning every
- * layer top-to-bottom to \a slice.
+ * Helper macro: iterate over all layers of the object @obj, assigning every
+ * layer top-to-bottom to @slice.
  */
 #define cl_object_for_each(slice, obj)					\
 	list_for_each_entry((slice),					\
 			    &(obj)->co_lu.lo_header->loh_layers,	\
 			    co_lu.lo_linkage)
 /**
- * Helper macro: iterate over all layers of the object \a obj, assigning every
- * layer bottom-to-top to \a slice.
+ * Helper macro: iterate over all layers of the object @obj, assigning every
+ * layer bottom-to-top to @slice.
  */
 #define cl_object_for_each_reverse(slice, obj)				\
 	list_for_each_entry_reverse((slice),				\
@@ -793,8 +793,8 @@ enum cl_req_type {
 /**
  * Per-layer page operations.
  *
- * Methods taking an \a io argument are for the activity happening in the
- * context of given \a io. Page is assumed to be owned by that io, except for
+ * Methods taking an @io argument are for the activity happening in the
+ * context of given @io. Page is assumed to be owned by that io, except for
  * the obvious cases (like cl_page_operations::cpo_own()).
  *
  * \see vvp_page_ops, lov_page_ops, osc_page_ops
@@ -807,7 +807,7 @@ struct cl_page_operations {
 	 */
 
 	/**
-	 * Called when \a io acquires this page into the exclusive
+	 * Called when @io acquires this page into the exclusive
 	 * ownership. When this method returns, it is guaranteed that the is
 	 * not owned by other io, and no transfer is going on against
 	 * it. Optional.
@@ -826,7 +826,7 @@ struct cl_page_operations {
 	void (*cpo_disown)(const struct lu_env *env,
 			   const struct cl_page_slice *slice, struct cl_io *io);
 	/**
-	 * Called for a page that is already "owned" by \a io from VM point of
+	 * Called for a page that is already "owned" by @io from VM point of
 	 * view. Optional.
 	 *
 	 * \see cl_page_assume()
@@ -845,7 +845,7 @@ struct cl_page_operations {
 			     const struct cl_page_slice *slice,
 			     struct cl_io *io);
 	/**
-	 * Announces whether the page contains valid data or not by \a uptodate.
+	 * Announces whether the page contains valid data or not by @uptodate.
 	 *
 	 * \see cl_page_export()
 	 * \see vvp_page_export()
@@ -856,9 +856,10 @@ struct cl_page_operations {
 	 * Checks whether underlying VM page is locked (in the suitable
 	 * sense). Used for assertions.
 	 *
-	 * \retval    -EBUSY: page is protected by a lock of a given mode;
-	 * \retval  -ENODATA: page is not protected by a lock;
-	 * \retval	 0: this layer cannot decide. (Should never happen.)
+	 * Return:	-EBUSY means page is protected by a lock of a given
+	 *		mode;
+	 *		-ENODATA when page is not protected by a lock;
+	 *		0 this layer cannot decide. (Should never happen.)
 	 */
 	int (*cpo_is_vmlocked)(const struct lu_env *env,
 			       const struct cl_page_slice *slice);
@@ -918,9 +919,9 @@ struct cl_page_operations {
 		 * Called when a page is submitted for a transfer as a part of
 		 * cl_page_list.
 		 *
-		 * \return    0	 : page is eligible for submission;
-		 * \return    -EALREADY : skip this page;
-		 * \return    -ve       : error.
+		 * Return:	0 if page is eligible for submission;
+		 *		-EALREADY skip this page;
+		 *		-ve if error.
 		 *
 		 * \see cl_page_prep()
 		 */
@@ -946,9 +947,9 @@ struct cl_page_operations {
 		 * Called when cached page is about to be added to the
 		 * ptlrpc request as a part of req formation.
 		 *
-		 * \return    0       : proceed with this page;
-		 * \return    -EAGAIN : skip this page;
-		 * \return    -ve     : error.
+		 * Return	0 proceed with this page;
+		 *		-EAGAIN skip this page;
+		 *		-ve error.
 		 *
 		 * \see cl_page_make_ready()
 		 */
@@ -984,7 +985,7 @@ struct cl_page_operations {
 };
 
 /**
- * Helper macro, dumping detailed information about \a page into a log.
+ * Helper macro, dumping detailed information about @page into a log.
  */
 #define CL_PAGE_DEBUG(mask, env, page, format, ...)			\
 do {									\
@@ -996,7 +997,7 @@ struct cl_page_operations {
 } while (0)
 
 /**
- * Helper macro, dumping shorter information about \a page into a log.
+ * Helper macro, dumping shorter information about @page into a log.
  */
 #define CL_PAGE_HEADER(mask, env, page, format, ...)			\
 do {									\
@@ -1203,10 +1204,10 @@ struct cl_lock_operations {
 	/**
 	 * Attempts to enqueue the lock. Called top-to-bottom.
 	 *
-	 * \retval 0	this layer has enqueued the lock successfully
-	 * \retval >0	this layer has enqueued the lock, but need to wait on
-	 *		@anchor for resources
-	 * \retval -ve	failure
+	 * Return:	0 this layer has enqueued the lock successfully
+	 *		>0 this layer has enqueued the lock, but need to
+	 *		wait on @anchor for resources
+	 *		-ve for failure
 	 *
 	 * \see vvp_lock_enqueue(), lov_lock_enqueue(), lovsub_lock_enqueue(),
 	 * \see osc_lock_enqueue()
@@ -1537,7 +1538,7 @@ struct cl_io_operations {
 				const struct cl_io_slice *slice);
 		/**
 		 * Called bottom-to-top to notify layers that read/write IO
-		 * iteration finished, with \a nob bytes transferred.
+		 * iteration finished, with @nob bytes transferred.
 		 */
 		void (*cio_advance)(const struct lu_env *env,
 				    const struct cl_io_slice *slice,
@@ -1550,11 +1551,11 @@ struct cl_io_operations {
 	} op[CIT_OP_NR];
 
 		/**
-		 * Submit pages from \a queue->c2_qin for IO, and move
-		 * successfully submitted pages into \a queue->c2_qout. Return
+		 * Submit pages from @queue->c2_qin for IO, and move
+		 * successfully submitted pages into @queue->c2_qout. Return
 		 * non-zero if failed to submit even the single page. If
-		 * submission failed after some pages were moved into \a
-		 * queue->c2_qout, completion callback with non-zero ioret is
+		 * submission failed after some pages were moved into
+		 * @queue->c2_qout, completion callback with non-zero ioret is
 		 * executed on them.
 		 */
 		int  (*cio_submit)(const struct lu_env *env,
@@ -2049,7 +2050,7 @@ int cl_object_layout_get(const struct lu_env *env, struct cl_object *obj,
 loff_t cl_object_maxbytes(struct cl_object *obj);
 
 /**
- * Returns true, iff \a o0 and \a o1 are slices of the same object.
+ * Returns true, iff @o0 and @o1 are slices of the same object.
  */
 static inline int cl_object_same(struct cl_object *o0, struct cl_object *o1)
 {
@@ -2280,7 +2281,7 @@ int cl_io_read_ahead(const struct lu_env *env, struct cl_io *io,
 		     pgoff_t start, struct cl_read_ahead *ra);
 
 /**
- * True, iff \a io is an O_APPEND write(2).
+ * True, if @io is an O_APPEND write(2).
  */
 static inline int cl_io_is_append(const struct cl_io *io)
 {
@@ -2298,7 +2299,7 @@ static inline int cl_io_is_mkwrite(const struct cl_io *io)
 }
 
 /**
- * True, iff \a io is a truncate(2).
+ * True, if @io is a truncate(2).
  */
 static inline int cl_io_is_trunc(const struct cl_io *io)
 {
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 68aa0d0..8137628 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -739,7 +739,7 @@ static inline const struct lu_fid *lu_object_fid(const struct lu_object *o)
 
 /**
  * Given a compound object, find its slice, corresponding to the device type
- * \a dtype.
+ * @dtype.
  */
 struct lu_object *lu_object_locate(struct lu_object_header *h,
 				   const struct lu_device_type *dtype);
@@ -1058,7 +1058,7 @@ struct lu_context_key {
 			   struct lu_context_key *key);
 	/**
 	 * Value destructor. Called when context with previously allocated
-	 * value of this slot is destroyed. \a data is a value that was returned
+	 * value of this slot is destroyed. @data is a value that was returned
 	 * by a matching call to lu_context_key::lct_init().
 	 */
 	void   (*lct_fini)(const struct lu_context *ctx,
@@ -1247,8 +1247,8 @@ struct lu_name {
 /**
  * Validate names (path components)
  *
- * To be valid \a name must be non-empty, '\0' terminated of length \a
- * name_len, and not contain '/'. The maximum length of a name (before
+ * To be valid @name must be non-empty, '\0' terminated of length
+ * @name_len, and not contain '/'. The maximum length of a name (before
  * say -ENAMETOOLONG will be returned) is really controlled by llite
  * and the server. We only check for something insane coming from bad
  * integer handling here.
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index c561d61..1bd5119 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -203,9 +203,9 @@ static inline int lockmode_compat(enum ldlm_mode exist_mode,
  * can trigger freeing of locks from the pool
  */
 struct ldlm_pool_ops {
-	/** Recalculate pool \a pl usage */
+	/** Recalculate pool @pl usage */
 	int (*po_recalc)(struct ldlm_pool *pl);
-	/** Cancel at least \a nr locks from pool \a pl */
+	/** Cancel at least @nr locks from pool @pl */
 	int (*po_shrink)(struct ldlm_pool *pl, int nr,
 			 gfp_t gfp_mask);
 };
@@ -429,7 +429,7 @@ struct ldlm_namespace {
 
 	/**
 	 * Used by filter code to store pointer to OBD of the service.
-	 * Should be dropped in favor of \a ns_obd
+	 * Should be dropped in favor of @ns_obd
 	 */
 	void			*ns_lvbp;
 
@@ -466,7 +466,7 @@ struct ldlm_namespace {
 };
 
 /**
- * Returns 1 if namespace \a ns supports early lock cancel (ELC).
+ * Returns 1 if namespace @ns supports early lock cancel (ELC).
  */
 static inline int ns_connect_cancelset(struct ldlm_namespace *ns)
 {
@@ -1082,7 +1082,7 @@ static inline struct ldlm_lock *ldlm_handle2lock(const struct lustre_handle *h)
 
 /**
  * Update Lock Value Block Operations (LVBO) on a resource taking into account
- * data from request \a r
+ * data from request @r
  */
 static inline int ldlm_res_lvbo_update(struct ldlm_resource *res,
 				       struct ptlrpc_request *r, int increase)
diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index 7d52665..0c78708 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -98,7 +98,7 @@ enum lustre_imp_state {
 	LUSTRE_IMP_EVICTED	= 10,
 };
 
-/** Returns test string representation of numeric import state \a state */
+/** Returns test string representation of numeric import state @state */
 static inline char *ptlrpc_import_state_name(enum lustre_imp_state state)
 {
 	static char *import_state_names[] = {
@@ -257,7 +257,7 @@ struct obd_import {
 	/** List of all possible connection for import. */
 	struct list_head		imp_conn_list;
 	/**
-	 * Current connection. \a imp_connection is imp_conn_current->oic_conn
+	 * Current connection. @imp_connection is imp_conn_current->oic_conn
 	 */
 	struct obd_import_conn	       *imp_conn_current;
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index 90fcbae..63a7413 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -190,8 +190,8 @@ static inline void mdc_put_mod_rpc_slot(struct ptlrpc_request *req,
  *
  * \see client_obd::cl_default_mds_easize
  *
- * \param[in] exp	export for MDC device
- * \param[in] body	body of ptlrpc reply from MDT
+ * @exp:	export for MDC device
+ * @body:	body of ptlrpc reply from MDT
  *
  */
 static inline void mdc_update_max_ea_from_body(struct obd_export *exp,
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 47b9632..f6d1be1 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -358,16 +358,16 @@ struct ptlrpc_request_set {
 	struct list_head	set_requests;
 	/**
 	 * List of completion callbacks to be called when the set is completed
-	 * This is only used if \a set_interpret is NULL.
+	 * This is only used if @set_interpret is NULL.
 	 * Links struct ptlrpc_set_cbdata.
 	 */
 	struct list_head	set_cblist;
 	/** Completion callback, if only one. */
 	set_interpreter_func	set_interpret;
-	/** opaq argument passed to completion \a set_interpret callback. */
+	/** opaq argument passed to completion @set_interpret callback. */
 	void			*set_arg;
 	/**
-	 * Lock for \a set_new_requests manipulations
+	 * Lock for @set_new_requests manipulations
 	 * locked so that any old caller can communicate requests to
 	 * the set holder who can then fold them into the lock-free set
 	 */
@@ -476,13 +476,13 @@ struct ptlrpc_reply_state {
 	/**
 	 * Actual reply message. Its content is encrypted (if needed) to
 	 * produce reply buffer for actual sending. In simple case
-	 * of no network encryption we just set \a rs_repbuf to \a rs_msg
+	 * of no network encryption we just set @rs_repbuf to @rs_msg
 	 */
 	struct lustre_msg	*rs_msg;	/* reply message */
 
 	/** Handles of locks awaiting client reply ACK */
 	struct lustre_handle	rs_locks[RS_MAX_LOCKS];
-	/** Lock modes of locks in \a rs_locks */
+	/** Lock modes of locks in @rs_locks */
 	enum ldlm_mode		rs_modes[RS_MAX_LOCKS];
 };
 
@@ -818,7 +818,7 @@ struct ptlrpc_request {
 	/**
 	 * List item to for replay list. Not yet committed requests get linked
 	 * there.
-	 * Also see \a rq_replay comment above.
+	 * Also see @rq_replay comment above.
 	 * It's also link chain on obd_export::exp_req_replay_queue
 	 */
 	struct list_head		rq_replay_list;
@@ -941,7 +941,7 @@ static inline bool ptlrpc_nrs_req_can_move(struct ptlrpc_request *req)
 /** @} nrs */
 
 /**
- * Returns 1 if request buffer at offset \a index was already swabbed
+ * Returns 1 if request buffer at offset @index was already swabbed
  */
 static inline int lustre_req_swabbed(struct ptlrpc_request *req, size_t index)
 {
@@ -950,7 +950,7 @@ static inline int lustre_req_swabbed(struct ptlrpc_request *req, size_t index)
 }
 
 /**
- * Returns 1 if request reply buffer at offset \a index was already swabbed
+ * Returns 1 if request reply buffer at offset @index was already swabbed
  */
 static inline int lustre_rep_swabbed(struct ptlrpc_request *req, size_t index)
 {
@@ -975,7 +975,7 @@ static inline int ptlrpc_rep_need_swab(struct ptlrpc_request *req)
 }
 
 /**
- * Mark request buffer at offset \a index that it was already swabbed
+ * Mark request buffer at offset @index that it was already swabbed
  */
 static inline void lustre_set_req_swabbed(struct ptlrpc_request *req,
 					  size_t index)
@@ -986,7 +986,7 @@ static inline void lustre_set_req_swabbed(struct ptlrpc_request *req,
 }
 
 /**
- * Mark request reply buffer at offset \a index that it was already swabbed
+ * Mark request reply buffer at offset @index that it was already swabbed
  */
 static inline void lustre_set_rep_swabbed(struct ptlrpc_request *req,
 					  size_t index)
@@ -997,7 +997,7 @@ static inline void lustre_set_rep_swabbed(struct ptlrpc_request *req,
 }
 
 /**
- * Convert numerical request phase value \a phase into text string description
+ * Convert numerical request phase value @phase into text string description
  */
 static inline const char *
 ptlrpc_phase2str(enum rq_phase phase)
@@ -1023,7 +1023,7 @@ static inline void lustre_set_rep_swabbed(struct ptlrpc_request *req,
 }
 
 /**
- * Convert numerical request phase of the request \a req into text stringi
+ * Convert numerical request phase of the request @req into text stringi
  * description
  */
 static inline const char *
@@ -1096,7 +1096,7 @@ struct ptlrpc_bulk_page {
 	/** Linkage to list of pages in a bulk */
 	struct list_head	bp_link;
 	/**
-	 * Number of bytes in a page to transfer starting from \a bp_pageoffset
+	 * Number of bytes in a page to transfer starting from @bp_pageoffset
 	 */
 	int			bp_buflen;
 	/** offset within a page */
@@ -1169,22 +1169,22 @@ static inline bool ptlrpc_is_bulk_op_passive(enum ptlrpc_bulk_op_type type)
 
 struct ptlrpc_bulk_frag_ops {
 	/**
-	 * Add a page \a page to the bulk descriptor \a desc
-	 * Data to transfer in the page starts at offset \a pageoffset and
-	 * amount of data to transfer from the page is \a len
+	 * Add a page @page to the bulk descriptor @desc
+	 * Data to transfer in the page starts at offset @pageoffset and
+	 * amount of data to transfer from the page is @len
 	 */
 	void (*add_kiov_frag)(struct ptlrpc_bulk_desc *desc,
 			      struct page *page, int pageoffset, int len);
 
 	/*
-	 * Add a \a fragment to the bulk descriptor \a desc.
-	 * Data to transfer in the fragment is pointed to by \a frag
-	 * The size of the fragment is \a len
+	 * Add a @fragment to the bulk descriptor @desc.
+	 * Data to transfer in the fragment is pointed to by @frag
+	 * The size of the fragment is @len
 	 */
 	int (*add_iov_frag)(struct ptlrpc_bulk_desc *desc, void *frag, int len);
 
 	/**
-	 * Uninitialize and free bulk descriptor \a desc.
+	 * Uninitialize and free bulk descriptor @desc.
 	 * Works on bulk descriptors both from server and client side.
 	 */
 	void (*release_frags)(struct ptlrpc_bulk_desc *desc);
@@ -1499,14 +1499,14 @@ struct ptlrpc_service {
  * will have multiple instances very soon (instance per CPT).
  *
  * it has four locks:
- * \a scp_lock
- *    serialize operations on rqbd and requests waiting for preprocess
- * \a scp_req_lock
- *    serialize operations active requests sent to this portal
- * \a scp_at_lock
- *    serialize adaptive timeout stuff
- * \a scp_rep_lock
- *    serialize operations on RS list (reply states)
+ * @scp_lock
+ *  serialize operations on rqbd and requests waiting for preprocess
+ * @scp_req_lock
+ *  serialize operations active requests sent to this portal
+ * @scp_at_lock
+ *  serialize adaptive timeout stuff
+ * @scp_rep_lock
+ *  serialize operations on RS list (reply states)
  *
  * We don't have any use-case to take two or more locks at the same time
  * for now, so there is no lock order issue.
@@ -1708,10 +1708,10 @@ enum ptlrpcd_ctl_flags {
  *
  * Service compatibility function; the policy is compatible with all services.
  *
- * \param[in] svc  The service the policy is attempting to register with.
- * \param[in] desc The policy descriptor
+ * @svc:	The service the policy is attempting to register with.
+ * @desc:	The policy descriptor
  *
- * \retval true The policy is compatible with the service
+ * Returns:	true The policy is compatible with the service
  *
  * \see ptlrpc_nrs_pol_desc::pd_compat()
  */
@@ -1726,11 +1726,11 @@ static inline bool nrs_policy_compat_all(const struct ptlrpc_service *svc,
  * service which is identified by its human-readable name at
  * ptlrpc_service::srv_name.
  *
- * \param[in] svc  The service the policy is attempting to register with.
- * \param[in] desc The policy descriptor
+ * @svc:	The service the policy is attempting to register with.
+ * @desc:	The policy descriptor
  *
- * \retval false The policy is not compatible with the service
- * \retval true	 The policy is compatible with the service
+ * Returns:	false	The policy is not compatible with the service
+ *		true	The policy is compatible with the service
  *
  * \see ptlrpc_nrs_pol_desc::pd_compat()
  */
@@ -2130,7 +2130,7 @@ static inline int ptlrpc_status_ntoh(int n)
 #endif
 /** @} */
 
-/** Change request phase of \a req to \a new_phase */
+/** Change request phase of @req to @new_phase */
 static inline void
 ptlrpc_rqphase_move(struct ptlrpc_request *req, enum rq_phase new_phase)
 {
@@ -2162,7 +2162,7 @@ static inline int ptlrpc_status_ntoh(int n)
 }
 
 /**
- * Returns true if request \a req got early reply and hard deadline is not met
+ * Returns true if request @req got early reply and hard deadline is not met
  */
 static inline int
 ptlrpc_client_early(struct ptlrpc_request *req)
@@ -2181,7 +2181,7 @@ static inline int ptlrpc_status_ntoh(int n)
 	return req->rq_replied;
 }
 
-/** Returns true if request \a req is in process of receiving server reply */
+/** Returns true if request @req is in process of receiving server reply */
 static inline int
 ptlrpc_client_recv(struct ptlrpc_request *req)
 {
diff --git a/drivers/staging/lustre/lustre/include/lustre_nrs.h b/drivers/staging/lustre/lustre/include/lustre_nrs.h
index 822eeb3..f57756a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_nrs.h
+++ b/drivers/staging/lustre/lustre/include/lustre_nrs.h
@@ -77,20 +77,20 @@ struct ptlrpc_nrs_pol_ops {
 	/**
 	 * Called during policy registration; this operation is optional.
 	 *
-	 * \param[in,out] policy The policy being initialized
+	 * @policy:	The policy being initialized
 	 */
 	int	(*op_policy_init)(struct ptlrpc_nrs_policy *policy);
 	/**
 	 * Called during policy unregistration; this operation is optional.
 	 *
-	 * \param[in,out] policy The policy being unregistered/finalized
+	 * @policy:	The policy being unregistered/finalized
 	 */
 	void	(*op_policy_fini)(struct ptlrpc_nrs_policy *policy);
 	/**
 	 * Called when activating a policy via lprocfs; policies allocate and
 	 * initialize their resources here; this operation is optional.
 	 *
-	 * \param[in,out] policy The policy being started
+	 * @policy:	The policy being started
 	 *
 	 * \see nrs_policy_start_locked()
 	 */
@@ -99,7 +99,7 @@ struct ptlrpc_nrs_pol_ops {
 	 * Called when deactivating a policy via lprocfs; policies deallocate
 	 * their resources here; this operation is optional
 	 *
-	 * \param[in,out] policy The policy being stopped
+	 * @policy:	The policy being stopped
 	 *
 	 * \see __nrs_policy_stop()
 	 */
@@ -109,13 +109,13 @@ struct ptlrpc_nrs_pol_ops {
 	 * \e PTLRPC_NRS_CTL_START and \e PTLRPC_NRS_CTL_GET_INFO; analogous
 	 * to an ioctl; this operation is optional.
 	 *
-	 * \param[in,out]	 policy The policy carrying out operation \a opc
-	 * \param[in]	  opc	 The command operation being carried out
-	 * \param[in,out] arg	 An generic buffer for communication between the
-	 *			 user and the control operation
+	 * @policy:	The policy carrying out operation opc
+	 * @opc:	The command operation being carried out
+	 * @arg:	An generic buffer for communication between the
+	 *		user and the control operation
 	 *
-	 * \retval -ve error
-	 * \retval   0 success
+	 * Return:	-ve error
+	 *		0 success
 	 *
 	 * \see ptlrpc_nrs_policy_control()
 	 */
@@ -128,31 +128,31 @@ struct ptlrpc_nrs_pol_ops {
 	 * service. Policies should return -ve for requests they do not wish
 	 * to handle. This operation is mandatory.
 	 *
-	 * \param[in,out] policy  The policy we're getting resources for.
-	 * \param[in,out] nrq	  The request we are getting resources for.
-	 * \param[in]	  parent  The parent resource of the resource being
-	 *			  requested; set to NULL if none.
-	 * \param[out]	  resp	  The resource is to be returned here; the
-	 *			  fallback policy in an NRS head should
-	 *			  \e always return a non-NULL pointer value.
-	 * \param[in]  moving_req When set, signifies that this is an attempt
-	 *			  to obtain resources for a request being moved
-	 *			  to the high-priority NRS head by
-	 *			  ldlm_lock_reorder_req().
-	 *			  This implies two things:
-	 *			  1. We are under obd_export::exp_rpc_lock and
-	 *			  so should not sleep.
-	 *			  2. We should not perform non-idempotent or can
-	 *			  skip performing idempotent operations that
-	 *			  were carried out when resources were first
-	 *			  taken for the request when it was initialized
-	 *			  in ptlrpc_nrs_req_initialize().
-	 *
-	 * \retval 0, +ve The level of the returned resource in the resource
-	 *		  hierarchy; currently only 0 (for a non-leaf resource)
-	 *		  and 1 (for a leaf resource) are supported by the
-	 *		  framework.
-	 * \retval -ve	  error
+	 * @policy:	The policy we're getting resources for.
+	 * @nrq:	The request we are getting resources for.
+	 * @parent:	The parent resource of the resource being
+	 *		requested; set to NULL if none.
+	 * @resp:	The resource is to be returned here; the
+	 *		fallback policy in an NRS head should
+	 *		\e always return a non-NULL pointer value.
+	 * @moving_req:	When set, signifies that this is an attempt
+	 *		to obtain resources for a request being moved
+	 *		to the high-priority NRS head by
+	 *		ldlm_lock_reorder_req().
+	 *		This implies two things:
+	 *		1. We are under obd_export::exp_rpc_lock and
+	 *		   so should not sleep.
+	 *		2. We should not perform non-idempotent or can
+	 *		   skip performing idempotent operations that
+	 *		   were carried out when resources were first
+	 *		   taken for the request when it was initialized
+	 *		   in ptlrpc_nrs_req_initialize().
+	 *
+	 * Return:	0, +ve The level of the returned resource in the resource
+	 *		hierarchy; currently only 0 (for a non-leaf resource)
+	 *		and 1 (for a leaf resource) are supported by the
+	 *		framework.
+	 *		-ve error
 	 *
 	 * \see ptlrpc_nrs_req_initialize()
 	 * \see ptlrpc_nrs_hpreq_add_nolock()
@@ -167,8 +167,8 @@ struct ptlrpc_nrs_pol_ops {
 	 * Called when releasing references taken for resources in the resource
 	 * hierarchy for the request; this operation is optional.
 	 *
-	 * \param[in,out] policy The policy the resource belongs to
-	 * \param[in] res	 The resource to be freed
+	 * @policy:	The policy the resource belongs to
+	 * @res:	The resource to be freed
 	 *
 	 * \see ptlrpc_nrs_req_finalize()
 	 * \see ptlrpc_nrs_hpreq_add_nolock()
@@ -181,15 +181,15 @@ struct ptlrpc_nrs_pol_ops {
 	 * Obtains a request for handling from the policy, and optionally
 	 * removes the request from the policy; this operation is mandatory.
 	 *
-	 * \param[in,out] policy The policy to poll
-	 * \param[in]	  peek	 When set, signifies that we just want to
-	 *			 examine the request, and not handle it, so the
-	 *			 request is not removed from the policy.
-	 * \param[in]	  force  When set, it will force a policy to return a
-	 *			 request if it has one queued.
+	 * @policy:	The policy to poll
+	 * @peek:	When set, signifies that we just want to
+	 *		examine the request, and not handle it, so the
+	 *		request is not removed from the policy.
+	 * @force:	When set, it will force a policy to return a
+	 *		request if it has one queued.
 	 *
-	 * \retval NULL No request available for handling
-	 * \retval valid-pointer The request polled for handling
+	 * Return:	NULL No request available for handling
+	 *		valid-pointer The request polled for handling
 	 *
 	 * \see ptlrpc_nrs_req_get_nolock()
 	 */
@@ -200,11 +200,11 @@ struct ptlrpc_nrs_pol_ops {
 	 * Called when attempting to add a request to a policy for later
 	 * handling; this operation is mandatory.
 	 *
-	 * \param[in,out] policy  The policy on which to enqueue \a nrq
-	 * \param[in,out] nrq The request to enqueue
+	 * @policy:	The policy on which to enqueue @nrq
+	 * @nrq:	The request to enqueue
 	 *
-	 * \retval 0	success
-	 * \retval != 0 error
+	 * Return:	0 on success
+	 *		!= 0 error
 	 *
 	 * \see ptlrpc_nrs_req_add_nolock()
 	 */
@@ -215,8 +215,8 @@ struct ptlrpc_nrs_pol_ops {
 	 * called after a request has been polled successfully from the policy
 	 * for handling; this operation is mandatory.
 	 *
-	 * \param[in,out] policy The policy the request \a nrq belongs to
-	 * \param[in,out] nrq	 The request to dequeue
+	 * @policy:	The policy the request @nrq belongs to
+	 * @nrq:	The request to dequeue
 	 *
 	 * \see ptlrpc_nrs_req_del_nolock()
 	 */
@@ -226,9 +226,9 @@ struct ptlrpc_nrs_pol_ops {
 	 * Called after the request being carried out. Could be used for
 	 * job/resource control; this operation is optional.
 	 *
-	 * \param[in,out] policy The policy which is stopping to handle request
-	 *			 \a nrq
-	 * \param[in,out] nrq	 The request
+	 * @policy:	The policy which is stopping to handle request @nrq
+	 *
+	 * @nrq:	The request
 	 *
 	 * \pre assert_spin_locked(&svcpt->scp_req_lock)
 	 *
@@ -239,10 +239,10 @@ struct ptlrpc_nrs_pol_ops {
 	/**
 	 * Registers the policy's lprocfs interface with a PTLRPC service.
 	 *
-	 * \param[in] svc The service
+	 * @svc:	The service
 	 *
-	 * \retval 0	success
-	 * \retval != 0 error
+	 * Return:	0 success
+	 *		!= 0 error
 	 */
 	int	(*op_lprocfs_init)(struct ptlrpc_service *svc);
 	/**
@@ -254,7 +254,7 @@ struct ptlrpc_nrs_pol_ops {
 	 * implementations of this method should make sure their operations are
 	 * safe in such cases.
 	 *
-	 * \param[in] svc The service
+	 * @svc:	The service
 	 */
 	void	(*op_lprocfs_fini)(struct ptlrpc_service *svc);
 };
@@ -410,7 +410,7 @@ struct ptlrpc_nrs_pol_conf {
 	nrs_pol_desc_compat_t		   nc_compat;
 	/**
 	 * Set for policies that support a single ptlrpc service, i.e. ones that
-	 * have \a pd_compat set to nrs_policy_compat_one(). The variable value
+	 * have @pd_compat set to nrs_policy_compat_one(). The variable value
 	 * depicts the name of the single service that such policies are
 	 * compatible with.
 	 */
diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
index 5a5625e..66054d5 100644
--- a/drivers/staging/lustre/lustre/include/lustre_sec.h
+++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
@@ -350,28 +350,28 @@ struct vfs_cred {
 
 struct ptlrpc_ctx_ops {
 	/**
-	 * To determine whether it's suitable to use the \a ctx for \a vcred.
+	 * To determine whether it's suitable to use the @ctx for @vcred.
 	 */
 	int (*match)(struct ptlrpc_cli_ctx *ctx, struct vfs_cred *vcred);
 
 	/**
-	 * To bring the \a ctx uptodate.
+	 * To bring the @ctx uptodate.
 	 */
 	int (*refresh)(struct ptlrpc_cli_ctx *ctx);
 
 	/**
-	 * Validate the \a ctx.
+	 * Validate the @ctx.
 	 */
 	int (*validate)(struct ptlrpc_cli_ctx *ctx);
 
 	/**
-	 * Force the \a ctx to die.
+	 * Force the @ctx to die.
 	 */
 	void (*force_die)(struct ptlrpc_cli_ctx *ctx, int grace);
 	int (*display)(struct ptlrpc_cli_ctx *ctx, char *buf, int bufsize);
 
 	/**
-	 * Sign the request message using \a ctx.
+	 * Sign the request message using @ctx.
 	 *
 	 * \pre req->rq_reqmsg point to request message.
 	 * \pre req->rq_reqlen is the request message length.
@@ -383,7 +383,7 @@ struct ptlrpc_ctx_ops {
 	int (*sign)(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req);
 
 	/**
-	 * Verify the reply message using \a ctx.
+	 * Verify the reply message using @ctx.
 	 *
 	 * \pre req->rq_repdata point to reply message with signature.
 	 * \pre req->rq_repdata_len is the total reply message length.
@@ -395,7 +395,7 @@ struct ptlrpc_ctx_ops {
 	int (*verify)(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req);
 
 	/**
-	 * Encrypt the request message using \a ctx.
+	 * Encrypt the request message using @ctx.
 	 *
 	 * \pre req->rq_reqmsg point to request message in clear text.
 	 * \pre req->rq_reqlen is the request message length.
@@ -407,7 +407,7 @@ struct ptlrpc_ctx_ops {
 	int (*seal)(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req);
 
 	/**
-	 * Decrypt the reply message using \a ctx.
+	 * Decrypt the reply message using @ctx.
 	 *
 	 * \pre req->rq_repdata point to encrypted reply message.
 	 * \pre req->rq_repdata_len is the total cipher text length.
@@ -498,11 +498,11 @@ struct ptlrpc_cli_ctx {
  */
 struct ptlrpc_sec_cops {
 	/**
-	 * Given an \a imp, create and initialize a ptlrpc_sec structure.
-	 * \param ctx service context:
-	 * - regular import: \a ctx should be NULL;
-	 * - reverse import: \a ctx is obtained from incoming request.
-	 * \param flavor specify what flavor to use.
+	 * Given an @imp, create and initialize a ptlrpc_sec structure.
+	 * @ctx service context:
+	 * - regular import: @ctx should be NULL;
+	 * - reverse import: @ctx is obtained from incoming request.
+	 * @flavor specify what flavor to use.
 	 *
 	 * When necessary, policy module is responsible for taking reference
 	 * on the import.
@@ -531,9 +531,9 @@ struct ptlrpc_sec_cops {
 	void (*kill_sec)(struct ptlrpc_sec *sec);
 
 	/**
-	 * Given \a vcred, lookup and/or create its context. The policy module
+	 * Given @vcred, lookup and/or create its context. The policy module
 	 * is supposed to maintain its own context cache.
-	 * XXX currently \a create and \a remove_dead is always 1, perhaps
+	 * XXX currently @create and @remove_dead is always 1, perhaps
 	 * should be removed completely.
 	 *
 	 * \see null_lookup_ctx(), plain_lookup_ctx(), gss_sec_lookup_ctx_kr().
@@ -543,11 +543,11 @@ struct ptlrpc_sec_cops {
 					     int create, int remove_dead);
 
 	/**
-	 * Called then the reference of \a ctx dropped to 0. The policy module
+	 * Called then the reference of @ctx dropped to 0. The policy module
 	 * is supposed to destroy this context or whatever else according to
 	 * its cache maintenance mechanism.
 	 *
-	 * \param sync if zero, we shouldn't wait for the context being
+	 * @sync if zero, we shouldn't wait for the context being
 	 * destroyed completely.
 	 *
 	 * \see plain_release_ctx(), gss_sec_release_ctx_kr().
@@ -558,10 +558,10 @@ struct ptlrpc_sec_cops {
 	/**
 	 * Flush the context cache.
 	 *
-	 * \param uid context of which user, -1 means all contexts.
-	 * \param grace if zero, the PTLRPC_CTX_UPTODATE_BIT of affected
+	 * @uid context of which user, -1 means all contexts.
+	 * @grace if zero, the PTLRPC_CTX_UPTODATE_BIT of affected
 	 * contexts should be cleared immediately.
-	 * \param force if zero, only idle contexts will be flushed.
+	 * @force if zero, only idle contexts will be flushed.
 	 *
 	 * \see plain_flush_ctx_cache(), gss_sec_flush_ctx_cache_kr().
 	 */
@@ -577,7 +577,7 @@ struct ptlrpc_sec_cops {
 	void (*gc_ctx)(struct ptlrpc_sec *sec);
 
 	/**
-	 * Given an context \a ctx, install a corresponding reverse service
+	 * Given an context @ctx, install a corresponding reverse service
 	 * context on client side.
 	 * XXX currently it's only used by GSS module, maybe we should remove
 	 * this from general API.
@@ -586,13 +586,13 @@ struct ptlrpc_sec_cops {
 			    struct ptlrpc_cli_ctx *ctx);
 
 	/**
-	 * To allocate request buffer for \a req.
+	 * To allocate request buffer for @req.
 	 *
 	 * \pre req->rq_reqmsg == NULL.
 	 * \pre req->rq_reqbuf == NULL, otherwise it must be pre-allocated,
 	 * we are not supposed to free it.
 	 * \post if success, req->rq_reqmsg point to a buffer with size
-	 * at least \a lustre_msg_size.
+	 * at least @lustre_msg_size.
 	 *
 	 * \see null_alloc_reqbuf(), plain_alloc_reqbuf(), gss_alloc_reqbuf().
 	 */
@@ -600,7 +600,7 @@ struct ptlrpc_sec_cops {
 			    int lustre_msg_size);
 
 	/**
-	 * To free request buffer for \a req.
+	 * To free request buffer for @req.
 	 *
 	 * \pre req->rq_reqbuf != NULL.
 	 *
@@ -609,12 +609,12 @@ struct ptlrpc_sec_cops {
 	void (*free_reqbuf)(struct ptlrpc_sec *sec, struct ptlrpc_request *req);
 
 	/**
-	 * To allocate reply buffer for \a req.
+	 * To allocate reply buffer for @req.
 	 *
 	 * \pre req->rq_repbuf == NULL.
 	 * \post if success, req->rq_repbuf point to a buffer with size
 	 * req->rq_repbuf_len, the size should be large enough to receive
-	 * reply which be transformed from \a lustre_msg_size of clear text.
+	 * reply which be transformed from @lustre_msg_size of clear text.
 	 *
 	 * \see null_alloc_repbuf(), plain_alloc_repbuf(), gss_alloc_repbuf().
 	 */
@@ -622,7 +622,7 @@ struct ptlrpc_sec_cops {
 			    int lustre_msg_size);
 
 	/**
-	 * To free reply buffer for \a req.
+	 * To free reply buffer for @req.
 	 *
 	 * \pre req->rq_repbuf != NULL.
 	 * \post req->rq_repbuf == NULL.
@@ -633,9 +633,9 @@ struct ptlrpc_sec_cops {
 	void (*free_repbuf)(struct ptlrpc_sec *sec, struct ptlrpc_request *req);
 
 	/**
-	 * To expand the request buffer of \a req, thus the \a segment in
+	 * To expand the request buffer of @req, thus the @segment in
 	 * the request message pointed by req->rq_reqmsg can accommodate
-	 * at least \a newsize of data.
+	 * at least @newsize of data.
 	 *
 	 * \pre req->rq_reqmsg->lm_buflens[segment] < newsize.
 	 *
@@ -662,13 +662,16 @@ struct ptlrpc_sec_sops {
 	 * req->rq_reqdata_len; and the message has been unpacked to
 	 * host byte order.
 	 *
-	 * \retval SECSVC_OK success, req->rq_reqmsg point to request message
-	 * in clear text, size is req->rq_reqlen; req->rq_svc_ctx is set;
-	 * req->rq_sp_from is decoded from request.
-	 * \retval SECSVC_COMPLETE success, the request has been fully
-	 * processed, and reply message has been prepared; req->rq_sp_from is
-	 * decoded from request.
-	 * \retval SECSVC_DROP failed, this request should be dropped.
+	 * Return:	SECSVC_OK success, req->rq_reqmsg point to request
+	 *		message in clear text, size is req->rq_reqlen;
+	 *		req->rq_svc_ctx is set; req->rq_sp_from is decoded
+	 *		from request.
+	 *
+	 *		SECSVC_COMPLETE success, the request has been fully
+	 *		processed, and reply message has been prepared;
+	 *		req->rq_sp_from is decoded from request.
+	 *
+	 *		SECSVC_DROP failed, this request should be dropped.
 	 *
 	 * \see null_accept(), plain_accept(), gss_svc_accept_kr().
 	 */
@@ -687,7 +690,7 @@ struct ptlrpc_sec_sops {
 	int (*authorize)(struct ptlrpc_request *req);
 
 	/**
-	 * Invalidate server context \a ctx.
+	 * Invalidate server context @ctx.
 	 *
 	 * \see gss_svc_invalidate_ctx().
 	 */
@@ -696,7 +699,7 @@ struct ptlrpc_sec_sops {
 	/**
 	 * Allocate a ptlrpc_reply_state.
 	 *
-	 * \param msgsize size of the reply message in clear text.
+	 * @msgsize size of the reply message in clear text.
 	 * \pre if req->rq_reply_state != NULL, then it's pre-allocated, we
 	 * should simply use it; otherwise we'll responsible for allocating
 	 * a new one.
@@ -713,14 +716,14 @@ struct ptlrpc_sec_sops {
 	void (*free_rs)(struct ptlrpc_reply_state *rs);
 
 	/**
-	 * Release the server context \a ctx.
+	 * Release the server context @ctx.
 	 *
 	 * \see gss_svc_free_ctx().
 	 */
 	void (*free_ctx)(struct ptlrpc_svc_ctx *ctx);
 
 	/**
-	 * Install a reverse context based on the server context \a ctx.
+	 * Install a reverse context based on the server context @ctx.
 	 *
 	 * \see gss_svc_install_rctx_kr().
 	 */
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 32d4ab6..e4cde19 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -677,10 +677,11 @@ static inline struct obd_uuid *obd_get_uuid(struct obd_export *exp)
 }
 
 /*
- * Create a new /a exp on device /a obd for the uuid /a cluuid
- * @param exp New export handle
- * @param d Connect data, supported flags are set, flags also understood
- *    by obd are returned.
+ * Create a new @exp on device @obd for the uuid @cluuid
+ *
+ * @exp:	New export handle
+ * @d:		Connect data, supported flags are set, flags also understood
+ *		by obd are returned.
  */
 static inline int obd_connect(const struct lu_env *env,
 			      struct obd_export **exp, struct obd_device *obd,
diff --git a/drivers/staging/lustre/lustre/include/seq_range.h b/drivers/staging/lustre/lustre/include/seq_range.h
index 884d4d4..dbf73ea 100644
--- a/drivers/staging/lustre/lustre/include/seq_range.h
+++ b/drivers/staging/lustre/lustre/include/seq_range.h
@@ -38,7 +38,7 @@
 #include <uapi/linux/lustre/lustre_idl.h>
 
 /**
- * computes the sequence range type \a range
+ * computes the sequence range type @range
  */
 
 static inline unsigned int fld_range_type(const struct lu_seq_range *range)
@@ -47,7 +47,7 @@ static inline unsigned int fld_range_type(const struct lu_seq_range *range)
 }
 
 /**
- *  Is this sequence range an OST? \a range
+ *  Is this sequence range an OST? @range
  */
 
 static inline bool fld_range_is_ost(const struct lu_seq_range *range)
@@ -56,7 +56,7 @@ static inline bool fld_range_is_ost(const struct lu_seq_range *range)
 }
 
 /**
- *  Is this sequence range an MDT? \a range
+ *  Is this sequence range an MDT? @range
  */
 
 static inline bool fld_range_is_mdt(const struct lu_seq_range *range)
@@ -68,7 +68,7 @@ static inline bool fld_range_is_mdt(const struct lu_seq_range *range)
  * ANY range is only used when the fld client sends a fld query request,
  * but it does not know whether the seq is an MDT or OST, so it will send the
  * request with ANY type, which means any seq type from the lookup can be
- * expected. /a range
+ * expected. @range
  */
 static inline unsigned int fld_range_is_any(const struct lu_seq_range *range)
 {
@@ -76,7 +76,7 @@ static inline unsigned int fld_range_is_any(const struct lu_seq_range *range)
 }
 
 /**
- * Apply flags to range \a range \a flags
+ * Apply flags @flasg to range @range
  */
 
 static inline void fld_range_set_type(struct lu_seq_range *range,
@@ -86,7 +86,7 @@ static inline void fld_range_set_type(struct lu_seq_range *range,
 }
 
 /**
- * Add MDT to range type \a range
+ * Add MDT to range type @range
  */
 
 static inline void fld_range_set_mdt(struct lu_seq_range *range)
@@ -95,7 +95,7 @@ static inline void fld_range_set_mdt(struct lu_seq_range *range)
 }
 
 /**
- * Add OST to range type \a range
+ * Add OST to range type @range
  */
 
 static inline void fld_range_set_ost(struct lu_seq_range *range)
@@ -104,7 +104,7 @@ static inline void fld_range_set_ost(struct lu_seq_range *range)
 }
 
 /**
- * Add ANY to range type \a range
+ * Add ANY to range type @range
  */
 
 static inline void fld_range_set_any(struct lu_seq_range *range)
@@ -113,7 +113,7 @@ static inline void fld_range_set_any(struct lu_seq_range *range)
 }
 
 /**
- * computes width of given sequence range \a range
+ * computes width of given sequence range @range
  */
 
 static inline u64 lu_seq_range_space(const struct lu_seq_range *range)
@@ -122,7 +122,7 @@ static inline u64 lu_seq_range_space(const struct lu_seq_range *range)
 }
 
 /**
- * initialize range to zero \a range
+ * initialize range to zero @range
  */
 
 static inline void lu_seq_range_init(struct lu_seq_range *range)
@@ -131,7 +131,7 @@ static inline void lu_seq_range_init(struct lu_seq_range *range)
 }
 
 /**
- * check if given seq id \a s is within given range \a range
+ * check if given seq id @s is within given range @range
  */
 
 static inline bool lu_seq_range_within(const struct lu_seq_range *range,
@@ -141,7 +141,7 @@ static inline bool lu_seq_range_within(const struct lu_seq_range *range,
 }
 
 /**
- * Is the range sane?  Is the end after the beginning? \a range
+ * Is the range sane?  Is the end after the beginning? @range
  */
 
 static inline bool lu_seq_range_is_sane(const struct lu_seq_range *range)
@@ -150,7 +150,7 @@ static inline bool lu_seq_range_is_sane(const struct lu_seq_range *range)
 }
 
 /**
- * Is the range 0? \a range
+ * Is the range 0? @range
  */
 
 static inline bool lu_seq_range_is_zero(const struct lu_seq_range *range)
@@ -159,7 +159,7 @@ static inline bool lu_seq_range_is_zero(const struct lu_seq_range *range)
 }
 
 /**
- * Is the range out of space? \a range
+ * Is the range out of space? @range
  */
 
 static inline bool lu_seq_range_is_exhausted(const struct lu_seq_range *range)
@@ -169,7 +169,7 @@ static inline bool lu_seq_range_is_exhausted(const struct lu_seq_range *range)
 
 /**
  * return 0 if two ranges have the same location, nonzero if they are
- * different \a r1 \a r2
+ * different @r1 @r2
  */
 
 static inline int lu_seq_range_compare_loc(const struct lu_seq_range *r1,
@@ -181,7 +181,7 @@ static inline int lu_seq_range_compare_loc(const struct lu_seq_range *r1,
 
 #if !defined(__REQ_LAYOUT_USER__)
 /**
- * byte swap range structure \a range
+ * byte swap range structure @range
  */
 
 void lustre_swab_lu_seq_range(struct lu_seq_range *range);
-- 
1.8.3.1
