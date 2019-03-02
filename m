From: James Simmons <jsimmons@infradead.org>
Date: Sat,  2 Mar 2019 14:12:23 -0500
Subject: [lustre-devel] [PATCH 6/7] obdclass: move comments to sphinix format
In-Reply-To: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
References: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1551553944-6419-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre comments was written for DocBook which is no longer used
by the Linux kernel. Move all the DocBook handling to sphinix.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/cl_io.c     | 12 +++---
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   | 11 ++---
 drivers/staging/lustre/lustre/obdclass/cl_object.c | 44 ++++++++++----------
 drivers/staging/lustre/lustre/obdclass/cl_page.c   | 30 +++++++-------
 drivers/staging/lustre/lustre/obdclass/genops.c    | 22 +++++-----
 .../staging/lustre/lustre/obdclass/kernelcomm.c    | 23 ++++++-----
 drivers/staging/lustre/lustre/obdclass/linkea.c    | 15 +++----
 .../lustre/lustre/obdclass/lprocfs_status.c        | 30 +++++++-------
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 44 ++++++++++----------
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 47 ++++++++++++----------
 10 files changed, 143 insertions(+), 135 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 3b4aca4..eef0dd8 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -83,7 +83,7 @@ static int cl_io_invariant(const struct cl_io *io)
 }
 
 /**
- * Finalize \a io, by calling cl_io_operations::cio_fini() bottom-to-top.
+ * Finalize @io, by calling cl_io_operations::cio_fini() bottom-to-top.
  */
 void cl_io_fini(const struct lu_env *env, struct cl_io *io)
 {
@@ -175,7 +175,7 @@ int cl_io_sub_init(const struct lu_env *env, struct cl_io *io,
 EXPORT_SYMBOL(cl_io_sub_init);
 
 /**
- * Initialize \a io, by calling cl_io_operations::cio_init() top-to-bottom.
+ * Initialize @io, by calling cl_io_operations::cio_init() top-to-bottom.
  *
  * Caller has to call cl_io_fini() after a call to cl_io_init(), no matter
  * what the latter returned.
@@ -413,7 +413,7 @@ void cl_io_iter_fini(const struct lu_env *env, struct cl_io *io)
 EXPORT_SYMBOL(cl_io_iter_fini);
 
 /**
- * Records that read or write io progressed \a nob bytes forward.
+ * Records that read or write io progressed @nob bytes forward.
  */
 static void cl_io_rw_advance(const struct lu_env *env, struct cl_io *io,
 			     size_t nob)
@@ -618,7 +618,7 @@ static void cl_page_list_assume(const struct lu_env *env,
 
 /**
  * Submit a sync_io and wait for the IO to be finished, or error happens.
- * If \a timeout is zero, it means to wait for the IO unconditionally.
+ * If @timeout is zero, it means to wait for the IO unconditionally.
  */
 int cl_io_submit_sync(const struct lu_env *env, struct cl_io *io,
 		      enum cl_req_type iot, struct cl_2queue *queue,
@@ -962,7 +962,7 @@ void cl_2queue_fini(const struct lu_env *env, struct cl_2queue *queue)
 EXPORT_SYMBOL(cl_2queue_fini);
 
 /**
- * Initialize a 2-queue to contain \a page in its incoming page list.
+ * Initialize a 2-queue to contain @page in its incoming page list.
  */
 void cl_2queue_init_page(struct cl_2queue *queue, struct cl_page *page)
 {
@@ -989,7 +989,7 @@ struct cl_io *cl_io_top(struct cl_io *io)
 
 /**
  * Fills in attributes that are passed to server together with transfer. Only
- * attributes from \a flags may be touched. This can be called multiple times
+ * attributes from @flags may be touched. This can be called multiple times
  * for the same request.
  */
 void cl_req_attr_set(const struct lu_env *env, struct cl_object *obj,
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index fc5976d..797302c 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -148,10 +148,11 @@ void cl_lock_cancel(const struct lu_env *env, struct cl_lock *lock)
 
 /**
  * Enqueue a lock.
- * \param anchor: if we need to wait for resources before getting the lock,
- *		  use @anchor for the purpose.
- * \retval 0  enqueue successfully
- * \retval <0 error code
+ * @anchor	if we need to wait for resources before getting the lock,
+ *		use @anchor for the purpose.
+ *
+ * Return:	0 enqueue successfully
+ *		<0 error code
  */
 int cl_lock_enqueue(const struct lu_env *env, struct cl_io *io,
 		    struct cl_lock *lock, struct cl_sync_io *anchor)
@@ -250,7 +251,7 @@ void cl_lock_descr_print(const struct lu_env *env, void *cookie,
 EXPORT_SYMBOL(cl_lock_descr_print);
 
 /**
- * Prints human readable representation of \a lock to the \a f.
+ * Prints human readable representation of @lock to the @f.
  */
 void cl_lock_print(const struct lu_env *env, void *cookie,
 		   lu_printer_t printer, const struct cl_lock *lock)
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index b09621f..6c084bc 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -79,7 +79,7 @@ int cl_object_header_init(struct cl_object_header *h)
 EXPORT_SYMBOL(cl_object_header_init);
 
 /**
- * Returns a cl_object with a given \a fid.
+ * Returns a cl_object with a given @fid.
  *
  * Returns either cached or newly created object. Additional reference on the
  * returned object is acquired.
@@ -96,7 +96,7 @@ struct cl_object *cl_object_find(const struct lu_env *env,
 EXPORT_SYMBOL(cl_object_find);
 
 /**
- * Releases a reference on \a o.
+ * Releases a reference on @o.
  *
  * When last reference is released object is returned to the cache, unless
  * lu_object_header_flags::LU_OBJECT_HEARD_BANSHEE bit is set in its header.
@@ -110,10 +110,10 @@ void cl_object_put(const struct lu_env *env, struct cl_object *o)
 EXPORT_SYMBOL(cl_object_put);
 
 /**
- * Acquire an additional reference to the object \a o.
+ * Acquire an additional reference to the object @o.
  *
  * This can only be used to acquire _additional_ reference, i.e., caller
- * already has to possess at least one reference to \a o before calling this.
+ * already has to possess at least one reference to @o before calling this.
  *
  * \see cl_page_get(), cl_lock_get().
  */
@@ -124,7 +124,7 @@ void cl_object_get(struct cl_object *o)
 EXPORT_SYMBOL(cl_object_get);
 
 /**
- * Returns the top-object for a given \a o.
+ * Returns the top-object for a given @o.
  *
  * \see cl_io_top()
  */
@@ -144,7 +144,7 @@ struct cl_object *cl_object_top(struct cl_object *o)
 
 /**
  * Returns pointer to the lock protecting data-attributes for the given object
- * \a o.
+ * @o.
  *
  * Data-attributes are protected by the cl_object_header::coh_attr_guard
  * spin-lock in the top-object.
@@ -181,10 +181,10 @@ void cl_object_attr_unlock(struct cl_object *o)
 EXPORT_SYMBOL(cl_object_attr_unlock);
 
 /**
- * Returns data-attributes of an object \a obj.
+ * Returns data-attributes of an object @obj.
  *
  * Every layer is asked (by calling cl_object_operations::coo_attr_get())
- * top-to-bottom to fill in parts of \a attr that this layer is responsible
+ * top-to-bottom to fill in parts of @attr that this layer is responsible
  * for.
  */
 int cl_object_attr_get(const struct lu_env *env, struct cl_object *obj,
@@ -210,9 +210,9 @@ int cl_object_attr_get(const struct lu_env *env, struct cl_object *obj,
 EXPORT_SYMBOL(cl_object_attr_get);
 
 /**
- * Updates data-attributes of an object \a obj.
+ * Updates data-attributes of an object @obj.
  *
- * Only attributes, mentioned in a validness bit-mask \a v are
+ * Only attributes, mentioned in a validness bit-mask @v are
  * updated. Calls cl_object_operations::coo_attr_update() on every layer,
  * bottom to top.
  */
@@ -242,7 +242,7 @@ int cl_object_attr_update(const struct lu_env *env, struct cl_object *obj,
 /**
  * Notifies layers (bottom-to-top) that glimpse AST was received.
  *
- * Layers have to fill \a lvb fields with information that will be shipped
+ * Layers have to fill @lvb fields with information that will be shipped
  * back to glimpse issuer.
  *
  * \see cl_lock_operations::clo_glimpse()
@@ -269,7 +269,7 @@ int cl_object_glimpse(const struct lu_env *env, struct cl_object *obj,
 EXPORT_SYMBOL(cl_object_glimpse);
 
 /**
- * Updates a configuration of an object \a obj.
+ * Updates a configuration of an object @obj.
  */
 int cl_conf_set(const struct lu_env *env, struct cl_object *obj,
 		const struct cl_object_conf *conf)
@@ -332,14 +332,14 @@ int cl_object_getstripe(const struct lu_env *env, struct cl_object *obj,
 /**
  * Get fiemap extents from file object.
  *
- * \param env [in]	lustre environment
- * \param obj [in]	file object
- * \param key [in]	fiemap request argument
- * \param fiemap [out]	fiemap extents mapping retrived
- * \param buflen [in]	max buffer length of @fiemap
+ * @env		lustre environment
+ * @obj		file object
+ * @key		fiemap request argument
+ * @fiemap	fiemap extents mapping retrived
+ * @buflen	max buffer length of @fiemap
  *
- * \retval 0	success
- * \retval < 0	error
+ * Return:	0 success
+ *		< 0 error
  */
 int cl_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 		     struct ll_fiemap_info_key *key,
@@ -660,9 +660,9 @@ static inline struct cl_env *cl_env_container(struct lu_env *env)
  *
  * Allocations are amortized through the global cache of environments.
  *
- * \param refcheck pointer to a counter used to detect environment leaks. In
+ * @refcheck pointer to a counter used to detect environment leaks. In
  * the usual case cl_env_get() and cl_env_put() are called in the same lexical
- * scope and pointer to the same integer is passed as \a refcheck. This is
+ * scope and pointer to the same integer is passed as @refcheck. This is
  * used to detect missed cl_env_put().
  *
  * \see cl_env_put()
@@ -747,7 +747,7 @@ unsigned int cl_env_cache_purge(unsigned int nr)
 /**
  * Release an environment.
  *
- * Decrement \a env reference counter. When counter drops to 0, nothing in
+ * Decrement @env reference counter. When counter drops to 0, nothing in
  * this thread is using environment and it is returned to the allocation
  * cache, or freed straight away, if cache is large enough.
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 7dcd3af..349f19e 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -61,7 +61,7 @@
  * This function can be used to obtain initial reference to previously
  * unreferenced cached object. It can be called only if concurrent page
  * reclamation is somehow prevented, e.g., by keeping a lock on a VM page,
- * associated with \a page.
+ * associated with @page.
  *
  * Use with care! Not exported.
  */
@@ -165,8 +165,8 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
 }
 
 /**
- * Returns a cl_page with index \a idx at the object \a o, and associated with
- * the VM page \a vmpage.
+ * Returns a cl_page with index @idx@the object @o, and associated with
+ * the VM page @vmpage.
  *
  * This is the main entry point into the cl_page caching interface. First, a
  * cache (implemented as a per-object radix tree) is consulted. If page is
@@ -287,8 +287,8 @@ static void cl_page_state_set(const struct lu_env *env,
 /**
  * Acquires an additional reference to a page.
  *
- * This can be called only by caller already possessing a reference to \a
- * page.
+ * This can be called only by caller already possessing a reference to
+ * @page.
  *
  * \see cl_object_get(), cl_lock_get().
  */
@@ -415,11 +415,11 @@ int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io)
  * \pre  !cl_page_is_owned(pg, io)
  * \post result == 0 iff cl_page_is_owned(pg, io)
  *
- * \retval 0   success
+ * Return:	0 success
  *
- * \retval -ve failure, e.g., page was destroyed (and landed in
- *	     cl_page_state::CPS_FREEING instead of cl_page_state::CPS_CACHED).
- *	     or, page was owned by another thread, or in IO.
+ *		-ve failure, e.g., page was destroyed (and landed in
+ *		cl_page_state::CPS_FREEING instead of cl_page_state::CPS_CACHED).
+ *		or, page was owned by another thread, or in IO.
  *
  * \see cl_page_disown()
  * \see cl_page_operations::cpo_own()
@@ -642,7 +642,7 @@ void cl_page_delete(const struct lu_env *env, struct cl_page *pg)
  *
  * Call cl_page_operations::cpo_export() through all layers top-to-bottom. The
  * layer responsible for VM interaction has to mark/clear page as up-to-date
- * by the \a uptodate argument.
+ * by the @uptodate argument.
  *
  * \see cl_page_operations::cpo_export()
  */
@@ -658,7 +658,7 @@ void cl_page_export(const struct lu_env *env, struct cl_page *pg, int uptodate)
 EXPORT_SYMBOL(cl_page_export);
 
 /**
- * Returns true, iff \a pg is VM locked in a suitable sense by the calling
+ * Returns true, if @pg is VM locked in a suitable sense by the calling
  * thread.
  */
 int cl_page_is_vmlocked(const struct lu_env *env, const struct cl_page *pg)
@@ -862,7 +862,7 @@ void cl_page_clip(const struct lu_env *env, struct cl_page *pg,
 EXPORT_SYMBOL(cl_page_clip);
 
 /**
- * Prints human readable representation of \a pg to the \a f.
+ * Prints human readable representation of @pg to the @f.
  */
 void cl_page_header_print(const struct lu_env *env, void *cookie,
 			  lu_printer_t printer, const struct cl_page *pg)
@@ -876,7 +876,7 @@ void cl_page_header_print(const struct lu_env *env, void *cookie,
 EXPORT_SYMBOL(cl_page_header_print);
 
 /**
- * Prints human readable representation of \a pg to the \a f.
+ * Prints human readable representation of @pg to the @f.
  */
 void cl_page_print(const struct lu_env *env, void *cookie,
 		   lu_printer_t printer, const struct cl_page *pg)
@@ -898,7 +898,7 @@ void cl_page_print(const struct lu_env *env, void *cookie,
 EXPORT_SYMBOL(cl_page_print);
 
 /**
- * Converts a byte offset within object \a obj into a page index.
+ * Converts a byte offset within object @obj into a page index.
  */
 loff_t cl_offset(const struct cl_object *obj, pgoff_t idx)
 {
@@ -910,7 +910,7 @@ loff_t cl_offset(const struct cl_object *obj, pgoff_t idx)
 EXPORT_SYMBOL(cl_offset);
 
 /**
- * Converts a page index into a byte offset within object \a obj.
+ * Converts a page index into a byte offset within object @obj.
  */
 pgoff_t cl_index(const struct cl_object *obj, loff_t offset)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 39919f1..80cb7b9 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -291,12 +291,12 @@ int class_unregister_type(const char *name)
  *
  * Allocate the new obd_device and initialize it.
  *
- * \param[in] type_name obd device type string.
- * \param[in] name      obd device name.
- * @uuid		obd device UUID.
+ * @type_name:		obd device type string.
+ * @name:		obd device name.
+ * @uuid:		obd device UUID.
  *
- * RETURN newdev	 pointer to created obd_device
- * RETURN ERR_PTR(errno) on error
+ * Returns:		newdev pointer to created obd_device
+ *			ERR_PTR(errno) on error
  */
 struct obd_device *class_newdev(const char *type_name, const char *name,
 				const char *uuid)
@@ -407,7 +407,7 @@ void class_free_dev(struct obd_device *obd)
 /**
  * Unregister obd device.
  *
- * Free slot in obd_dev[] used by \a obd.
+ * Free slot in obd_dev[] used by @obd.
  *
  * @new_obd	obd_device to be unregistered
  *
@@ -427,7 +427,7 @@ void class_unregister_device(struct obd_device *obd)
 /**
  * Register obd device.
  *
- * Find free slot in obd_devs[], fills it with \a new_obd.
+ * Find free slot in obd_devs[], fills it with @new_obd.
  *
  * @new_obd	obd_device to be registered
  *
@@ -538,10 +538,10 @@ int class_uuid2dev(struct obd_uuid *uuid)
 /**
  * Get obd device from ::obd_devs[]
  *
- * \param num [in] array index
+ * @num		array index
  *
- * \retval NULL if ::obd_devs[\a num] does not contains an obd device
- *	 otherwise return the obd device there.
+ * Return:	NULL if ::obd_devs[@num] does not contains an obd device
+ *		otherwise return the obd device there.
  */
 struct obd_device *class_num2obd(int num)
 {
@@ -632,7 +632,7 @@ struct obd_device *class_devices_in_group(struct obd_uuid *grp_uuid, int *next)
 EXPORT_SYMBOL(class_devices_in_group);
 
 /**
- * to notify sptlrpc log for \a fsname has changed, let every relevant OBD
+ * to notify sptlrpc log for @fsname has changed, let every relevant OBD
  * adjust sptlrpc settings accordingly.
  */
 int class_notify_sptlrpc_conf(const char *fsname, int namelen)
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index 925ba52..49d4717 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -45,9 +45,10 @@
 
 /**
  * libcfs_kkuc_msg_put - send an message from kernel to userspace
- * @param fp to send the message to
- * @param payload Payload data.  First field of payload is always
- *   struct kuc_hdr
+ *
+ * @fp:		to send the message to
+ * @payload:	Payload data. First field of payload is always
+ *		struct kuc_hdr
  */
 int libcfs_kkuc_msg_put(struct file *filp, void *payload)
 {
@@ -113,10 +114,11 @@ void libcfs_kkuc_init(void)
 }
 
 /** Add a receiver to a broadcast group
- * @param filp pipe to write into
- * @param uid identifier for this receiver
- * @param group group number
- * @param data user data
+ *
+ * @filp:	pipe to write into
+ * @uid:	identifier for this receiver
+ * @group:	group number
+ * @data:	user data
  */
 int libcfs_kkuc_group_add(struct file *filp, int uid, unsigned int group,
 			  void *data, size_t data_len)
@@ -234,9 +236,10 @@ int libcfs_kkuc_group_put(unsigned int group, void *payload)
 
 /**
  * Calls a callback function for each link of the given kuc group.
- * @param group the group to call the function on.
- * @param cb_func the function to be called.
- * @param cb_arg extra argument to be passed to the callback function.
+ *
+ * @group:	the group to call the function on.
+ * @cb_func:	the function to be called.
+ * @cb_arg:	extra argument to be passed to the callback function.
  */
 int libcfs_kkuc_group_foreach(unsigned int group, libcfs_kkuc_cb_t cb_func,
 			      void *cb_arg)
diff --git a/drivers/staging/lustre/lustre/obdclass/linkea.c b/drivers/staging/lustre/lustre/obdclass/linkea.c
index 33594bd..7e42e3a 100644
--- a/drivers/staging/lustre/lustre/obdclass/linkea.c
+++ b/drivers/staging/lustre/lustre/obdclass/linkea.c
@@ -90,7 +90,8 @@ int linkea_init_with_rec(struct linkea_data *ldata)
  * Pack a link_ea_entry.
  * All elements are stored as chars to avoid alignment issues.
  * Numbers are always big-endian
- * \retval record length
+ *
+ * Return:	record length
  */
 int linkea_entry_pack(struct link_ea_entry *lee, const struct lu_name *lname,
 		      const struct lu_fid *pfid)
@@ -204,13 +205,13 @@ void linkea_del_buf(struct linkea_data *ldata, const struct lu_name *lname)
 /**
  * Check if such a link exists in linkEA.
  *
- * \param ldata link data the search to be done on
- * \param lname name in the parent's directory entry pointing to this object
- * \param pfid parent fid the link to be found for
+ * @ldata	link data the search to be done on
+ * @lname	name in the parent's directory entry pointing to this object
+ * @pfid	parent fid the link to be found for
  *
- * \retval   0 success
- * \retval -ENOENT link does not exist
- * \retval -ve on error
+ * Return:	0 success
+ *		-ENOENT link does not exist
+ *		-ve on error
  */
 int linkea_links_find(struct linkea_data *ldata, const struct lu_name *lname,
 		      const struct lu_fid  *pfid)
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index e1ac610..72d504c 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -563,16 +563,16 @@ int lprocfs_rd_conn_uuid(struct seq_file *m, void *data)
  *
  * For global statistics, lock the stats structure to prevent concurrent update.
  *
- * \param[in] stats    statistics structure to lock
- * \param[in] opc      type of operation:
- *                     LPROCFS_GET_SMP_ID: "lock" and return current CPU index
- *                             for incrementing statistics for that CPU
- *                     LPROCFS_GET_NUM_CPU: "lock" and return number of used
- *                             CPU indices to iterate over all indices
- * \param[out] flags   CPU interrupt saved state for IRQ-safe locking
+ * @stats:	statistics structure to lock
+ * @opc:	type of operation:
+ *		LPROCFS_GET_SMP_ID: "lock" and return current CPU index
+ *				    for incrementing statistics for that CPU
+ *		LPROCFS_GET_NUM_CPU: "lock" and return number of used
+ *				     CPU indices to iterate over all indices
+ * @flags:	CPU interrupt saved state for IRQ-safe locking
  *
- * \retval cpuid of current thread or number of allocated structs
- * \retval negative on error (only for opc LPROCFS_GET_SMP_ID + per-CPU stats)
+ * Returns:	cpuid of current thread or number of allocated structs
+ *		negative on error (only for opc LPROCFS_GET_SMP_ID + per-CPU stats)
  */
 int lprocfs_stats_lock(struct lprocfs_stats *stats,
 		       enum lprocfs_stats_lock_ops opc,
@@ -616,9 +616,9 @@ int lprocfs_stats_lock(struct lprocfs_stats *stats,
  * This function must be called using the same arguments as used when calling
  * lprocfs_stats_lock() so that the correct operation can be performed.
  *
- * \param[in] stats    statistics structure to unlock
- * \param[in] opc      type of operation (current cpuid or number of structs)
- * \param[in] flags    CPU interrupt saved state for IRQ-safe locking
+ * @stats:	statistics structure to unlock
+ * @opc:	type of operation (current cpuid or number of structs)
+ * @flags:	CPU interrupt saved state for IRQ-safe locking
  */
 void lprocfs_stats_unlock(struct lprocfs_stats *stats,
 			  enum lprocfs_stats_lock_ops opc,
@@ -1614,9 +1614,9 @@ static char *lprocfs_strnstr(const char *s1, const char *s2, size_t len)
 }
 
 /**
- * Find the string \a name in the input \a buffer, and return a pointer to the
- * value immediately following \a name, reducing \a count appropriately.
- * If \a name is not found the original \a buffer is returned.
+ * Find the string @name in the input @buffer, and return a pointer to the
+ * value immediately following @name, reducing @count appropriately.
+ * If @name is not found the original @buffer is returned.
  */
 char *lprocfs_find_named_value(const char *buffer, const char *name,
 			       size_t *count)
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 639c298..8a78470 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -359,7 +359,7 @@ static void lu_object_free(const struct lu_env *env, struct lu_object *o)
 }
 
 /**
- * Free \a nr objects from the cold end of the site LRU list.
+ * Free @nr objects from the cold end of the site LRU list.
  * if canblock is false, then don't block awaiting for another
  * instance of lu_site_purge() to complete
  */
@@ -552,7 +552,7 @@ void lu_object_header_print(const struct lu_env *env, void *cookie,
 EXPORT_SYMBOL(lu_object_header_print);
 
 /**
- * Print human readable representation of the \a o to the \a printer.
+ * Print human readable representation of the @o to the @printer.
  */
 void lu_object_print(const struct lu_env *env, void *cookie,
 		     lu_printer_t printer, const struct lu_object *o)
@@ -567,7 +567,7 @@ void lu_object_print(const struct lu_env *env, void *cookie,
 
 	list_for_each_entry(o, &top->loh_layers, lo_linkage) {
 		/*
-		 * print `.' \a depth times followed by type name and address
+		 * print `.' @depth times followed by type name and address
 		 */
 		(*printer)(env, cookie, "%*.*s%s@%p", depth, depth, ruler,
 			   o->lo_dev->ld_type->ldt_name, o);
@@ -621,7 +621,7 @@ static struct lu_object *htable_lookup(struct lu_site *s,
 }
 
 /**
- * Search cache for an object with the fid \a f. If such object is found,
+ * Search cache for an object with the fid @f. If such object is found,
  * return it. Otherwise, create new object, insert it into cache and return
  * it. In any case, additional reference is acquired on the returned object.
  */
@@ -661,7 +661,7 @@ static void lu_object_limit(const struct lu_env *env, struct lu_device *dev)
  * Core logic of lu_object_find*() functions.
  *
  * Much like lu_object_find(), but top level device of object is specifically
- * \a dev rather than top level device of the site. This interface allows
+ * @dev rather than top level device of the site. This interface allows
  * objects of different "stacking" to be created within the same site.
  */
 struct lu_object *lu_object_find_at(const struct lu_env *env,
@@ -821,7 +821,7 @@ struct lu_site_print_arg {
 }
 
 /**
- * Print all objects in \a s.
+ * Print all objects in @s.
  */
 void lu_site_print(const struct lu_env *env, struct lu_site *s, void *cookie,
 		   lu_printer_t printer)
@@ -950,7 +950,7 @@ static void lu_dev_add_linkage(struct lu_site *s, struct lu_device *d)
 }
 
 /**
- * Initialize site \a s, with \a d as the top level device.
+ * Initialize site @s, with @d as the top level device.
  */
 int lu_site_init(struct lu_site *s, struct lu_device *top)
 {
@@ -1030,7 +1030,7 @@ int lu_site_init(struct lu_site *s, struct lu_device *top)
 EXPORT_SYMBOL(lu_site_init);
 
 /**
- * Finalize \a s and release its resources.
+ * Finalize @s and release its resources.
  */
 void lu_site_fini(struct lu_site *s)
 {
@@ -1074,7 +1074,7 @@ int lu_site_init_finish(struct lu_site *s)
 EXPORT_SYMBOL(lu_site_init_finish);
 
 /**
- * Acquire additional reference on device \a d
+ * Acquire additional reference on device @d
  */
 void lu_device_get(struct lu_device *d)
 {
@@ -1083,7 +1083,7 @@ void lu_device_get(struct lu_device *d)
 EXPORT_SYMBOL(lu_device_get);
 
 /**
- * Release reference on device \a d.
+ * Release reference on device @d.
  */
 void lu_device_put(struct lu_device *d)
 {
@@ -1093,7 +1093,7 @@ void lu_device_put(struct lu_device *d)
 EXPORT_SYMBOL(lu_device_put);
 
 /**
- * Initialize device \a d of type \a t.
+ * Initialize device @d of type @t.
  */
 int lu_device_init(struct lu_device *d, struct lu_device_type *t)
 {
@@ -1111,7 +1111,7 @@ int lu_device_init(struct lu_device *d, struct lu_device_type *t)
 EXPORT_SYMBOL(lu_device_init);
 
 /**
- * Finalize device \a d.
+ * Finalize device @d.
  */
 void lu_device_fini(struct lu_device *d)
 {
@@ -1134,8 +1134,8 @@ void lu_device_fini(struct lu_device *d)
 EXPORT_SYMBOL(lu_device_fini);
 
 /**
- * Initialize object \a o that is part of compound object \a h and was created
- * by device \a d.
+ * Initialize object @o that is part of compound object @h and was created
+ * by device @d.
  */
 int lu_object_init(struct lu_object *o, struct lu_object_header *h,
 		   struct lu_device *d)
@@ -1170,7 +1170,7 @@ void lu_object_fini(struct lu_object *o)
 EXPORT_SYMBOL(lu_object_fini);
 
 /**
- * Add object \a o as first layer of compound object \a h
+ * Add object @o as first layer of compound object @h
  *
  * This is typically called by the ->ldo_object_alloc() method of top-level
  * device.
@@ -1182,10 +1182,10 @@ void lu_object_add_top(struct lu_object_header *h, struct lu_object *o)
 EXPORT_SYMBOL(lu_object_add_top);
 
 /**
- * Add object \a o as a layer of compound object, going after \a before.
+ * Add object @o as a layer of compound object, going after @before.
  *
- * This is typically called by the ->ldo_object_alloc() method of \a
- * before->lo_dev.
+ * This is typically called by the ->ldo_object_alloc() method of
+ * @before->lo_dev.
  */
 void lu_object_add(struct lu_object *before, struct lu_object *o)
 {
@@ -1222,7 +1222,7 @@ void lu_object_header_fini(struct lu_object_header *h)
 
 /**
  * Given a compound object, find its slice, corresponding to the device type
- * \a dtype.
+ * @dtype.
  */
 struct lu_object *lu_object_locate(struct lu_object_header *h,
 				   const struct lu_device_type *dtype)
@@ -1452,7 +1452,7 @@ void lu_context_key_quiesce_many(struct lu_context_key *k, ...)
 EXPORT_SYMBOL(lu_context_key_quiesce_many);
 
 /**
- * Return value associated with key \a key in context \a ctx.
+ * Return value associated with key @key in context @ctx.
  */
 void *lu_context_key_get(const struct lu_context *ctx,
 			 const struct lu_context_key *key)
@@ -1471,7 +1471,7 @@ void *lu_context_key_get(const struct lu_context *ctx,
 static DEFINE_SPINLOCK(lu_context_remembered_guard);
 
 /**
- * Destroy \a key in all remembered contexts. This is used to destroy key
+ * Destroy @key in all remembered contexts. This is used to destroy key
  * values in "shared" contexts (like service threads), when a module owning
  * the key is about to be unloaded.
  */
@@ -1646,7 +1646,7 @@ void lu_context_enter(struct lu_context *ctx)
 EXPORT_SYMBOL(lu_context_enter);
 
 /**
- * Called after exiting from \a ctx
+ * Called after exiting from @ctx
  */
 void lu_context_exit(struct lu_context *ctx)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 33aa790..104e64b 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -56,12 +56,13 @@
  * Continue to process new statements appended to the logs
  * (whenever the config lock is revoked) until lustre_end_log
  * is called.
- * @param sb The superblock is used by the MGC to write to the local copy of
- *   the config log
- * @param logname The name of the llog to replicate from the MGS
- * @param cfg Since the same mgc may be used to follow multiple config logs
- *   (e.g. ost1, ost2, client), the config_llog_instance keeps the state for
- *   this log, and is added to the mgc's list of logs to follow.
+ * @sb:		The superblock is used by the MGC to write to the local copy of
+ *		the config log
+ * @logname:	The name of the llog to replicate from the MGS
+ * @cfg:	Since the same mgc may be used to follow multiple config logs
+ *		(e.g. ost1, ost2, client), the config_llog_instance keeps the
+ *		state for this log, and is added to the mgc's list of logs to
+ *		follow.
  */
 int lustre_process_log(struct super_block *sb, char *logname,
 		       struct config_llog_instance *cfg)
@@ -204,9 +205,9 @@ static int lustre_start_simple(char *obdname, char *type, char *uuid,
 
 /** Set up a mgc obd to process startup logs
  *
- * \param sb [in] super block of the mgc obd
+ * @sb:		super block of the mgc obd
  *
- * \retval 0 success, otherwise error code
+ * Returns:	0 success, otherwise error code
  */
 int lustre_start_mgc(struct super_block *sb)
 {
@@ -588,11 +589,13 @@ int lustre_put_lsi(struct super_block *sb)
  */
 
 /** Get the fsname ("lustre") from the server name ("lustre-OST003F").
- * @param [in] svname server name including type and index
- * @param [out] fsname Buffer to copy filesystem name prefix into.
- *  Must have at least 'strlen(fsname) + 1' chars.
- * @param [out] endptr if endptr isn't NULL it is set to end of fsname
- * rc < 0  on error
+ *
+ * @svname:	server name including type and index
+ * @fsname:	Buffer to copy filesystem name prefix into.
+ *		Must have@least 'strlen(fsname) + 1' chars.
+ * @endptr:	if endptr isn't NULL it is set to end of fsname
+ *
+ * Returns:	rc < 0  on error
  */
 static int server_name2fsname(const char *svname, char *fsname,
 			      const char **endptr)
@@ -910,15 +913,15 @@ static int lmd_parse_mgs(struct lustre_mount_data *lmd, char **ptr)
 }
 
 /**
- * Find the first delimiter (comma or colon) from the specified \a buf and
- * make \a *endh point to the string starting with the delimiter. The commas
+ * Find the first delimiter (comma or colon) from the specified @buf and
+ * make @*endh point to the string starting with the delimiter. The commas
  * in expression list [...] will be skipped.
  *
  * @buf		a delimiter-separated string
  * @endh	a pointer to a pointer that will point to the string
  *		starting with the delimiter
  *
- * RETURNS	true if delimiter is found, false if delimiter is not found
+ * Returns:	true if delimiter is found, false if delimiter is not found
  */
 static bool lmd_find_delimiter(char *buf, char **endh)
 {
@@ -964,15 +967,15 @@ static bool lmd_find_delimiter(char *buf, char **endh)
 
 /**
  * Find the first valid string delimited by comma or colon from the specified
- * \a buf and parse it to see whether it's a valid nid list. If yes, \a *endh
+ * @buf and parse it to see whether it's a valid nid list. If yes, @*endh
  * will point to the next string starting with the delimiter.
  *
- * \param[in] buf	a delimiter-separated string
- * \param[in] endh	a pointer to a pointer that will point to the string
- *			starting with the delimiter
+ * @buf:	a delimiter-separated string
+ * @endh:	a pointer to a pointer that will point to the string
+ *		starting with the delimiter
  *
- * \retval 0		if the string is a valid nid list
- * \retval 1		if the string is not a valid nid list
+ * Returns:	0	if the string is a valid nid list
+ *		1	if the string is not a valid nid list
  */
 static int lmd_parse_nidlist(char *buf, char **endh)
 {
-- 
1.8.3.1
