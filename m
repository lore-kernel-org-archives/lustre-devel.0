From: James Simmons <jsimmons@infradead.org>
Date: Sat,  2 Mar 2019 14:12:24 -0500
Subject: [lustre-devel] [PATCH 7/7] lustre: move remaining comments to
 sphinix format
In-Reply-To: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
References: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1551553944-6419-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre comments was written for DocBook which is no longer used
by the Linux kernel. Move all the remaining lustre DocBook
handling to sphinix.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/fld/fld_cache.c     |   4 +-
 drivers/staging/lustre/lustre/fld/fld_internal.h  |   2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c       | 119 +++++++++++-----------
 drivers/staging/lustre/lustre/lov/lov_io.c        |   2 +-
 drivers/staging/lustre/lustre/lov/lov_object.c    |  47 ++++-----
 drivers/staging/lustre/lustre/lov/lov_pack.c      |   4 +-
 drivers/staging/lustre/lustre/mdc/mdc_changelog.c |  91 +++++++++--------
 drivers/staging/lustre/lustre/mdc/mdc_lib.c       |  12 +--
 drivers/staging/lustre/lustre/mdc/mdc_request.c   |  34 ++++---
 drivers/staging/lustre/lustre/mgc/mgc_request.c   |   8 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c     |  12 +--
 drivers/staging/lustre/lustre/osc/osc_lock.c      |  10 +-
 drivers/staging/lustre/lustre/osc/osc_request.c   |   4 +-
 13 files changed, 182 insertions(+), 167 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index b4baa53..d289c29 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -468,7 +468,7 @@ struct fld_cache_entry
 }
 
 /**
- * lookup \a seq sequence for range in fld cache.
+ * lookup @seq sequence for range in fld cache.
  */
 struct fld_cache_entry
 *fld_cache_entry_lookup(struct fld_cache *cache, struct lu_seq_range *range)
@@ -482,7 +482,7 @@ struct fld_cache_entry
 }
 
 /**
- * lookup \a seq sequence for range in fld cache.
+ * lookup @seq sequence for range in fld cache.
  */
 int fld_cache_lookup(struct fld_cache *cache,
 		     const u64 seq, struct lu_seq_range *range)
diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index 76666a4..e2eda59 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -94,7 +94,7 @@ struct fld_cache {
 	/** Preferred number of cached entries */
 	int			fci_cache_size;
 
-	/** Current number of cached entries. Protected by \a fci_lock */
+	/** Current number of cached entries. Protected by @fci_lock */
 	int			fci_cache_count;
 
 	/** LRU list fld entries. */
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 1c7379b..fe1c14c 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1520,13 +1520,14 @@ static int lmv_close(struct obd_export *exp, struct md_op_data *op_data,
  * walk through all of stripes to locate the entry.
  *
  * For normal direcotry, it will locate MDS by FID directly.
- * \param[in] lmv	LMV device
- * \param[in] op_data	client MD stack parameters, name, namelen
- *			mds_num etc.
- * \param[in] fid	object FID used to locate MDS.
  *
- * retval		pointer to the lmv_tgt_desc if succeed.
- *			ERR_PTR(errno) if failed.
+ * @lmv:	LMV device
+ * @op_data:	client MD stack parameters, name, namelen
+ *		mds_num etc.
+ * @fid:	object FID used to locate MDS.
+ *
+ * Returns:	pointer to the lmv_tgt_desc if succeed.
+ *		ERR_PTR(errno) if failed.
  */
 struct lmv_tgt_desc*
 lmv_locate_mds(struct lmv_obd *lmv, struct md_op_data *op_data,
@@ -2005,26 +2006,26 @@ static int lmv_fsync(struct obd_export *exp, const struct lu_fid *fid,
  * closest(>=) to @hash_offset, from all of sub-stripes, and it is
  * only being called for striped directory.
  *
- * \param[in] exp		export of LMV
- * \param[in] op_data		parameters transferred beween client MD stack
- *				stripe_information will be included in this
- *				parameter
- * \param[in] cb_op		ldlm callback being used in enqueue in
- *				mdc_read_page
- * \param[in] hash_offset	the hash value, which is used to locate
- *				minum(closet) dir entry
- * \param[in|out] stripe_offset	the caller use this to indicate the stripe
- *				index of last entry, so to avoid hash conflict
- *				between stripes. It will also be used to
- *				return the stripe index of current dir entry.
- * \param[in|out] entp		the minum entry and it also is being used
- *				to input the last dir entry to resolve the
- *				hash conflict
+ * @exp:		export of LMV
+ * @op_data:		parameters transferred beween client MD stack
+ *			stripe_information will be included in this
+ *			parameter
+ * @cb_op:		ldlm callback being used in enqueue in
+ *			mdc_read_page
+ * @hash_offset:	the hash value, which is used to locate
+ *			minum(closet) dir entry
+ * @stripe_offset:	the caller use this to indicate the stripe
+ *			index of last entry, so to avoid hash conflict
+ *			between stripes. It will also be used to
+ *			return the stripe index of current dir entry.
+ * @entp:		the minum entry and it also is being used
+ *			to input the last dir entry to resolve the
+ *			hash conflict
  *
- * \param[out] ppage		the page which holds the minum entry
+ * @ppage:		the page which holds the minum entry
  *
- * \retval			= 0 get the entry successfully
- *				negative errno (< 0) does not get the entry
+ * Return:		= 0 get the entry successfully
+ *			negative errno (< 0) does not get the entry
  */
 static int lmv_get_min_striped_entry(struct obd_export *exp,
 				     struct md_op_data *op_data,
@@ -2152,17 +2153,17 @@ static int lmv_get_min_striped_entry(struct obd_export *exp,
  * one, so need to restore before reusing.
  * 3. release the entry page if that is not being chosen.
  *
- * \param[in] exp	obd export refer to LMV
- * \param[in] op_data	hold those MD parameters of read_entry
- * \param[in] cb_op	ldlm callback being used in enqueue in mdc_read_entry
- * \param[out] ldp	the entry being read
- * \param[out] ppage	the page holding the entry. Note: because the entry
- *			will be accessed in upper layer, so we need hold the
- *			page until the usages of entry is finished, see
- *			ll_dir_entry_next.
+ * @exp:	obd export refer to LMV
+ * @op_data:	hold those MD parameters of read_entry
+ * @cb_op:	ldlm callback being used in enqueue in mdc_read_entry
+ * @ldp:	the entry being read
+ * @ppage:	the page holding the entry. Note: because the entry
+ *		will be accessed in upper layer, so we need hold the
+ *		page until the usages of entry is finished, see
+ *		ll_dir_entry_next.
  *
- * retval		=0 if get entry successfully
- *			<0 cannot get entry
+ * Returns:	=0 if get entry successfully
+ *		<0 cannot get entry
  */
 static int lmv_read_striped_page(struct obd_export *exp,
 				 struct md_op_data *op_data,
@@ -2327,15 +2328,15 @@ static int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
  * it will walk through all of sub-stripes until the child is being
  * unlinked finally.
  *
- * \param[in] exp	export refer to LMV
- * \param[in] op_data	different parameters transferred beween client
- *			MD stacks, name, namelen, FIDs etc.
- *			op_fid1 is the parent FID, op_fid2 is the child
- *			FID.
- * \param[out] request point to the request of unlink.
+ * @exp:	export refer to LMV
+ * @op_data:	different parameters transferred beween client
+ *		MD stacks, name, namelen, FIDs etc.
+ *		op_fid1 is the parent FID, op_fid2 is the child
+ *		FID.
+ * @request:	point to the request of unlink.
  *
- * retval		0 if succeed
- *			negative errno if failed.
+ * Return:	0 if succeed
+ *		negative errno if failed.
  */
 static int lmv_unlink(struct obd_export *exp, struct md_op_data *op_data,
 		      struct ptlrpc_request **request)
@@ -2506,15 +2507,15 @@ static int lmv_precleanup(struct obd_device *obd)
  *
  * Dispatch request to lower-layer devices as needed.
  *
- * \param[in]  env	execution environment for this thread
- * \param[in]  exp	export for the LMV device
- * \param[in]  keylen	length of key identifier
- * \param[in]  key	identifier of key to get value for
- * \param[in]  vallen	size of \a val
- * \param[out] val	pointer to storage location for value
+ * @env:	execution environment for this thread
+ * @exp:	export for the LMV device
+ * @keylen:	length of key identifier
+ * @key:	identifier of key to get value for
+ * @vallen:	size of @val
+ * @val:	pointer to storage location for value
  *
- * \retval 0		on success
- * \retval negative	negated errno on failure
+ * Return:	0 on success
+ *		negated errno on failure
  */
 static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 			u32 keylen, void *key, u32 *vallen, void *val)
@@ -2575,16 +2576,16 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
  *
  * Dispatch request to lower-layer devices as needed.
  *
- * \param[in] env	execution environment for this thread
- * \param[in] exp	export for the LMV device
- * \param[in] keylen	length of key identifier
- * \param[in] key	identifier of key to store value for
- * \param[in] vallen	size of value to store
- * \param[in] val	pointer to data to be stored
- * \param[in] set	optional list of related ptlrpc requests
+ * @env:	execution environment for this thread
+ * @exp:	export for the LMV device
+ * @keylen:	length of key identifier
+ * @key:	identifier of key to store value for
+ * @vallen:	size of value to store
+ * @val:	pointer to data to be stored
+ * @set:	optional list of related ptlrpc requests
  *
- * \retval 0		on success
- * \retval negative	negated errno on failure
+ * Returs:	0 on success
+ *		negative negated errno on failure
  */
 static int lmv_set_info_async(const struct lu_env *env, struct obd_export *exp,
 			      u32 keylen, void *key, u32 vallen,
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 77efb86..02bc4e6 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -722,7 +722,7 @@ static int lov_io_read_ahead(const struct lu_env *env,
 
 /**
  * lov implementation of cl_operations::cio_submit() method. It takes a list
- * of pages in \a queue, splits it into per-stripe sub-lists, invokes
+ * of pages in @queue, splits it into per-stripe sub-lists, invokes
  * cl_io_submit() on underlying devices to submit sub-lists, and then splices
  * everything back.
  *
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 397ecc1..2058275 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -1085,14 +1085,14 @@ int lov_lock_init(const struct lu_env *env, struct cl_object *obj,
  * This function returns the last_stripe and also sets the stripe_count
  * over which the mapping is spread
  *
- * \param lsm [in]		striping information for the file
+ * @lsm				striping information for the file
  * @index			stripe component index
  * @ext				logical extent of mapping
- * \param start_stripe [in]	starting stripe of the mapping
- * \param stripe_count [out]	the number of stripes across which to map is
+ * @start_stripe		starting stripe of the mapping
+ * @stripe_count		the number of stripes across which to map is
  *				returned
  *
- * \retval last_stripe		return the last stripe of the mapping
+ * Return:			return the last stripe of the mapping
  */
 static int fiemap_calc_last_stripe(struct lov_stripe_md *lsm, int index,
 				   struct lu_extent *ext,
@@ -1126,12 +1126,12 @@ static int fiemap_calc_last_stripe(struct lov_stripe_md *lsm, int index,
 /**
  * Set fe_device and copy extents from local buffer into main return buffer.
  *
- * \param fiemap [out]		fiemap to hold all extents
- * \param lcl_fm_ext [in]	array of fiemap extents get from OSC layer
- * \param ost_index [in]	OST index to be written into the fm_device
- *				field for each extent
- * \param ext_count [in]	number of extents to be copied
- * \param current_extent [in]	where to start copying in the extent array
+ * @fiemap		fiemap to hold all extents
+ * @lcl_fm_ext		array of fiemap extents get from OSC layer
+ * @ost_index		OST index to be written into the fm_device
+ *			field for each extent
+ * @ext_count		number of extents to be copied
+ * @current_extent	where to start copying in the extent array
  */
 static void fiemap_prepare_and_copy_exts(struct fiemap *fiemap,
 					 struct fiemap_extent *lcl_fm_ext,
@@ -1164,11 +1164,11 @@ static void fiemap_prepare_and_copy_exts(struct fiemap *fiemap,
  * will re-calculate proper offset in next stripe.
  * Note that the first extent is passed to lov_get_info via the value field.
  *
- * \param fiemap [in]		fiemap request header
- * \param lsm [in]		striping information for the file
- * @index			stripe component index
- * @ext				logical extent of mapping
- * \param start_stripe [out]	starting stripe will be returned in this
+ * @fiemap		fiemap request header
+ * @lsm			striping information for the file
+ * @index		stripe component index
+ * @ext			logical extent of mapping
+ * @start_stripe	starting stripe will be returned in this
  */
 static u64 fiemap_calc_fm_end_offset(struct fiemap *fiemap,
 				     struct lov_stripe_md *lsm,
@@ -1411,14 +1411,15 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
  * This also handles the restarting of FIEMAP calls in case mapping overflows
  * the available number of extents in single call.
  *
- * \param env [in]		lustre environment
- * \param obj [in]		file object
- * \param fmkey [in]		fiemap request header and other info
- * \param fiemap [out]		fiemap buffer holding retrived map extents
- * \param buflen [in/out]	max buffer length of @fiemap, when iterate
- *				each OST, it is used to limit max map needed
- * \retval 0	success
- * \retval < 0	error
+ * @env		lustre environment
+ * @obj		file object
+ * @fmkey	fiemap request header and other info
+ * @fiemap	fiemap buffer holding retrived map extents
+ * @buflen	max buffer length of @fiemap, when iterate
+ *		each OST, it is used to limit max map needed
+ *
+ * Return:	0 success
+ *		< 0 error
  */
 static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
 			     struct ll_fiemap_info_key *fmkey,
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 18ce9f9..269e61c 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -103,8 +103,8 @@ void lov_dump_lmm_v3(int level, struct lov_mds_md_v3 *lmm)
  * Pack LOV striping metadata for disk storage format (in little
  * endian byte order).
  *
- * This follows the getxattr() conventions. If \a buf_size is zero
- * then return the size needed. If \a buf_size is too small then
+ * This follows the getxattr() conventions. If @buf_size is zero
+ * then return the size needed. If @buf_size is too small then
  * return -ERANGE. Otherwise return the size of the result.
  */
 ssize_t lov_lsm_pack_v1v3(const struct lov_stripe_md *lsm, void *buf,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_changelog.c b/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
index ea6dda7..45aef9c 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_changelog.c
@@ -107,12 +107,12 @@ enum {
  * If the current record is eligible to userland delivery, push
  * it into the crs_rec_queue where the consumer code will fetch it.
  *
- * @param[in]     env  (unused)
- * @param[in]     llh  Client-side handle used to identify the llog
- * @param[in]     hdr  Header of the current llog record
- * @param[in,out] data chlg_reader_state passed from caller
+ * @env:	(unused)
+ * @llh:	Client-side handle used to identify the llog
+ * @hdr:	Header of the current llog record
+ * @data:	chlg_reader_state passed from caller
  *
- * @return 0 or LLOG_PROC_* control code on success, negated error on failure.
+ * Returns:	0 or LLOG_PROC_* control code on success, negated error on failure.
  */
 static int chlg_read_cat_process_cb(const struct lu_env *env,
 				    struct llog_handle *llh,
@@ -198,8 +198,9 @@ static inline struct obd_device *chlg_obd_get(struct chlg_registered_dev *dev)
  * Record prefetch thread entry point. Opens the changelog catalog and starts
  * reading records.
  *
- * @param[in,out]  args  chlg_reader_state passed from caller.
- * @return 0 on success, negated error code on failure.
+ * @args:	chlg_reader_state passed from caller.
+ *
+ * Returns:	0 on success, negated error code on failure.
  */
 static int chlg_load(void *args)
 {
@@ -269,12 +270,13 @@ static int chlg_load(void *args)
  * No partial records are copied to userland so this function can return less
  * data than required (short read).
  *
- * @param[in]   file   File pointer to the character device.
- * @param[out]  buff   Userland buffer where to copy the records.
- * @param[in]   count  Userland buffer size.
- * @param[out]  ppos   File position, updated with the index number of the next
- *		       record to read.
- * @return number of copied bytes on success, negated error code on failure.
+ * @file:	File pointer to the character device.
+ * @buff:	Userland buffer where to copy the records.
+ * @count:	Userland buffer size.
+ * @ppos:	File position, updated with the index number of the next
+ *		record to read.
+ *
+ * Returns:	number of copied bytes on success, negated error code on failure.
  */
 static ssize_t chlg_read(struct file *file, char __user *buff, size_t count,
 			 loff_t *ppos)
@@ -336,9 +338,10 @@ static ssize_t chlg_read(struct file *file, char __user *buff, size_t count,
 /**
  * Jump to a given record index. Helper for chlg_llseek().
  *
- * @param[in,out]  crs     Internal reader state.
- * @param[in]      offset  Desired offset (index record).
- * @return 0 on success, negated error code on failure.
+ * @crs:	Internal reader state.
+ * @offset:	Desired offset (index record).
+ *
+ * Returns:	0 on success, negated error code on failure.
  */
 static int chlg_set_start_offset(struct chlg_reader_state *crs, u64 offset)
 {
@@ -370,10 +373,11 @@ static int chlg_set_start_offset(struct chlg_reader_state *crs, u64 offset)
 /**
  * Move read pointer to a certain record index, encoded as an offset.
  *
- * @param[in,out] file   File pointer to the changelog character device
- * @param[in]	  off    Offset to skip, actually a record index, not byte count
- * @param[in]	  whence Relative/Absolute interpretation of the offset
- * @return the resulting position on success or negated error code on failure.
+ * @file:	File pointer to the changelog character device
+ * @off:	Offset to skip, actually a record index, not byte count
+ * @whence:	Relative/Absolute interpretation of the offset
+ *
+ * Returns:	the resulting position on success or negated error code on failure.
  */
 static loff_t chlg_llseek(struct file *file, loff_t off, int whence)
 {
@@ -408,10 +412,11 @@ static loff_t chlg_llseek(struct file *file, loff_t off, int whence)
 /**
  * Clear record range for a given changelog reader.
  *
- * @param[in]  crs     Current internal state.
- * @param[in]  reader  Changelog reader ID (cl1, cl2...)
- * @param[in]  record  Record index up which to clear
- * @return 0 on success, negated error code on failure.
+ * @crs:	Current internal state.
+ * @reader:	Changelog reader ID (cl1, cl2...)
+ * @record:	Record index up which to clear
+ *
+ * Returns:	0 on success, negated error code on failure.
  */
 static int chlg_clear(struct chlg_reader_state *crs, u32 reader, u64 record)
 {
@@ -441,11 +446,12 @@ static int chlg_clear(struct chlg_reader_state *crs, u32 reader, u64 record)
  * Handle writes() into the changelog character device. Write() can be used
  * to request special control operations.
  *
- * @param[in]  file  File pointer to the changelog character device
- * @param[in]  buff  User supplied data (written data)
- * @param[in]  count Number of written bytes
- * @param[in]  off   (unused)
- * @return number of written bytes on success, negated error code on failure.
+ * @file:	File pointer to the changelog character device
+ * @buff:	User supplied data (written data)
+ * @count:	Number of written bytes
+ * @off:	(unused)
+ *
+ * Returns:	number of written bytes on success, negated error code on failure.
  */
 static ssize_t chlg_write(struct file *file, const char __user *buff,
 			  size_t count, loff_t *off)
@@ -483,9 +489,11 @@ static ssize_t chlg_write(struct file *file, const char __user *buff,
 /**
  * Open handler, initialize internal CRS state and spawn prefetch thread if
  * needed.
- * @param[in]  inode  Inode struct for the open character device.
- * @param[in]  file   Corresponding file pointer.
- * @return 0 on success, negated error code on failure.
+ *
+ * @inode:	Inode struct for the open character device.
+ * @file:	Corresponding file pointer.
+ *
+ * Returns:	0 on success, negated error code on failure.
  */
 static int chlg_open(struct inode *inode, struct file *file)
 {
@@ -532,9 +540,10 @@ static int chlg_open(struct inode *inode, struct file *file)
 /**
  * Close handler, release resources.
  *
- * @param[in]  inode  Inode struct for the open character device.
- * @param[in]  file   Corresponding file pointer.
- * @return 0 on success, negated error code on failure.
+ * @inode:	Inode struct for the open character device.
+ * @file:	Corresponding file pointer.
+ *
+ * Returns:	0 on success, negated error code on failure.
  */
 static int chlg_release(struct inode *inode, struct file *file)
 {
@@ -557,9 +566,10 @@ static int chlg_release(struct inode *inode, struct file *file)
  * Poll handler, indicates whether the device is readable (new records) and
  * writable (always).
  *
- * @param[in]  file   Device file pointer.
- * @param[in]  wait   (opaque)
- * @return combination of the poll status flags.
+ * @file:	Device file pointer.
+ * @wait:	(opaque)
+ *
+ * Returns:	combination of the poll status flags.
  */
 static unsigned int chlg_poll(struct file *file, poll_table *wait)
 {
@@ -649,8 +659,9 @@ static void get_chlg_name(char *name, size_t name_len, struct obd_device *obd)
  * Register a misc character device with a dynamic minor number, under a name
  * of the form: 'changelog-fsname-MDTxxxx'. Reference this OBD device with it.
  *
- * @param[in] obd  This MDC obd_device.
- * @return 0 on success, negated error code on failure.
+ * @obd:	This MDC obd_device.
+ *
+ * Returns:	0 on success, negated error code on failure.
  */
 int mdc_changelog_cdev_init(struct obd_device *obd)
 {
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 55d2ea1..7680346 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -82,14 +82,14 @@ void mdc_pack_body(struct ptlrpc_request *req, const struct lu_fid *fid,
 /**
  * Pack a name (path component) into a request
  *
- * \param[in] req	request
- * \param[in] field	request field (usually RMF_NAME)
- * \param[in] name	path component
- * \param[in] name_len	length of path component
+ * @req:	request
+ * @field:	request field (usually RMF_NAME)
+ * @name:	path component
+ * @name_len:	length of path component
  *
- * \a field must be present in \a req and of size \a name_len + 1.
+ * @field must be present in @req and of size @name_len + 1.
  *
- * \a name must be '\0' terminated of length \a name_len and represent
+ * @name must be '\0' terminated of length @name_len and represent
  * a single path component (not contain '/').
  */
 static void mdc_pack_name(struct ptlrpc_request *req,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 3eb89ec..bc764f9 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -81,16 +81,16 @@ static inline int mdc_queue_wait(struct ptlrpc_request *req)
 /*
  * Send MDS_GET_ROOT RPC to fetch root FID.
  *
- * If \a fileset is not NULL it should contain a subdirectory off
+ * If @fileset is not NULL it should contain a subdirectory off
  * the ROOT/ directory to be mounted on the client. Return the FID
  * of the subdirectory to the client to mount onto its mountpoint.
  *
- * \param[in]  imp	MDC import
- * \param[in]  fileset	fileset name, which could be NULL
- * \param[out] rootfid	root FID of this mountpoint
- * \param[out] pc	root capa will be unpacked and saved in this pointer
+ * @imp:	MDC import
+ * @fileset:	fileset name, which could be NULL
+ * @rootfid:	root FID of this mountpoint
+ * @pc:		root capa will be unpacked and saved in this pointer
  *
- * \retval     0 on success, negative errno on failure
+ * Returns:	0 on success, negative errno on failure
  */
 static int mdc_get_root(struct obd_export *exp, const char *fileset,
 			struct lu_fid *rootfid)
@@ -1273,15 +1273,15 @@ static int mdc_read_page_remote(void *data, struct page *page0)
  * Read dir page from cache first, if it can not find it, read it from
  * server and add into the cache.
  *
- * \param[in] exp	MDC export
- * \param[in] op_data	client MD stack parameters, transferring parameters
+ * @exp:		MDC export
+ * @op_data:		client MD stack parameters, transferring parameters
  *			between different layers on client MD stack.
- * \param[in] cb_op	callback required for ldlm lock enqueue during
+ * @cb_op:		callback required for ldlm lock enqueue during
  *			read page
- * \param[in] hash_offset the hash offset of the page to be read
- * \param[in] ppage	the page to be read
+ * @hash_offset:	the hash offset of the page to be read
+ * @ppage		the page to be read
  *
- * retval		= 0 get the page successfully
+ * Return:		= 0 get the page successfully
  *			errno(<0) get the page failed
  */
 static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
@@ -2151,8 +2151,9 @@ static int mdc_ioc_hsm_ct_start(struct obd_export *exp,
 
 /**
  * Send a message to any listening copytools
- * @param val KUC message (kuc_hdr + hsm_action_list)
- * @param len total length of message
+ *
+ * @val:	KUC message (kuc_hdr + hsm_action_list)
+ * @len:	total length of message
  */
 static int mdc_hsm_copytool_send(size_t len, void *val)
 {
@@ -2184,8 +2185,9 @@ static int mdc_hsm_copytool_send(size_t len, void *val)
 /**
  * callback function passed to kuc for re-registering each HSM copytool
  * running on MDC, after MDT shutdown/recovery.
- * @param data copytool registration data
- * @param cb_arg callback argument (obd_import)
+ *
+ * @data:	copytool registration data
+ * @cb_arg:	callback argument (obd_import)
  */
 static int mdc_hsm_ct_reregister(void *data, void *cb_arg)
 {
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index a4dfdc0..bb837ef 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1589,11 +1589,11 @@ static bool mgc_import_in_recovery(struct obd_import *imp)
  * trying to update from the same log simultaneously, in which case we
  * should use a per-log semaphore instead of cld_lock.
  *
- * \param[in] mgc	MGC device by which to fetch the configuration log
- * \param[in] cld	log processing state (stored in lock callback data)
+ * @mgc:	MGC device by which to fetch the configuration log
+ * @cld:	log processing state (stored in lock callback data)
  *
- * \retval		0 on success
- * \retval		negative errno on failure
+ * Returns:	0 on success
+ *		negative errno on failure
  */
 int mgc_process_log(struct obd_device *mgc, struct config_llog_data *cld)
 {
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 4359a93..fa554dd 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2105,12 +2105,12 @@ static unsigned int get_write_extents(struct osc_object *obj,
 /**
  * prepare pages for ASYNC io and put pages in send queue.
  *
- * \param cmd OBD_BRW_* macroses
- * \param lop pending pages
+ * @cmd		OBD_BRW_* macroses
+ * @lop		pending pages
  *
- * \return zero if no page added to send queue.
- * \return 1 if pages successfully added to send queue.
- * \return negative on errors.
+ * Return:	zero if no page added to send queue.
+ *		1 if pages successfully added to send queue.
+ *		negative on errors.
  */
 static int
 osc_send_read_rpc(const struct lu_env *env, struct client_obd *cli,
@@ -3021,7 +3021,7 @@ int osc_cache_writeback_range(const struct lu_env *env, struct osc_object *obj,
 }
 
 /**
- * Returns a list of pages by a given [start, end] of \a obj.
+ * Returns a list of pages by a given [start, end] of @obj.
  *
  * Gang tree lookup (radix_tree_gang_lookup()) optimization is absolutely
  * crucial in the face of [offset, EOF] locks.
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index bfc1abb..612305a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -485,14 +485,14 @@ static int __osc_dlm_blocking_ast(const struct lu_env *env,
  * Control flow is tricky, because ldlm uses the same call-back
  * (ldlm_lock::l_blocking_ast()) for both blocking and cancellation ast's.
  *
- * \param dlmlock lock for which ast occurred.
+ * @dlmlock	lock for which ast occurred.
  *
- * \param new description of a conflicting lock in case of blocking ast.
+ * @new		description of a conflicting lock in case of blocking ast.
  *
- * \param data value of dlmlock->l_ast_data
+ * @data	value of dlmlock->l_ast_data
  *
- * \param flag LDLM_CB_BLOCKING or LDLM_CB_CANCELING. Used to distinguish
- *	     cancellation and blocking ast's.
+ * @flag	LDLM_CB_BLOCKING or LDLM_CB_CANCELING. Used to distinguish
+ *		cancellation and blocking ast's.
  *
  * Possible use cases:
  *
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 3fedfaf..1a82e85 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2807,8 +2807,8 @@ static int osc_import_event(struct obd_device *obd,
  * Determine whether the lock can be canceled before replaying the lock
  * during recovery, see bug16774 for detailed information.
  *
- * \retval zero the lock can't be canceled
- * \retval other ok to cancel
+ * Return:	zero the lock can't be canceled
+ *		other ok to cancel
  */
 static int osc_cancel_weight(struct ldlm_lock *lock)
 {
-- 
1.8.3.1
