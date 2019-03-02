From: James Simmons <jsimmons@infradead.org>
Date: Sat,  2 Mar 2019 14:12:22 -0500
Subject: [lustre-devel] [PATCH 5/7] llite: move comments to sphinix format
In-Reply-To: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
References: <1551553944-6419-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1551553944-6419-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre comments was written for DocBook which is no longer used
by the Linux kernel. Move all the DocBook handling to sphinix.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c          | 14 ++---
 drivers/staging/lustre/lustre/llite/file.c         | 62 +++++++++++-----------
 drivers/staging/lustre/lustre/llite/glimpse.c      |  4 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  5 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 48 ++++++++---------
 drivers/staging/lustre/lustre/llite/llite_mmap.c   | 19 +++----
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |  4 +-
 drivers/staging/lustre/lustre/llite/lproc_llite.c  | 22 ++++----
 drivers/staging/lustre/lustre/llite/range_lock.c   | 20 +++----
 drivers/staging/lustre/lustre/llite/rw.c           | 14 ++---
 drivers/staging/lustre/lustre/llite/statahead.c    | 59 ++++++++++----------
 drivers/staging/lustre/lustre/llite/super25.c      |  3 +-
 drivers/staging/lustre/lustre/llite/vvp_io.c       |  2 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |  8 +--
 drivers/staging/lustre/lustre/llite/xattr_cache.c  | 44 +++++++--------
 .../staging/lustre/lustre/llite/xattr_security.c   | 12 ++---
 16 files changed, 174 insertions(+), 166 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 17bb618..1fbfc3a 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -393,13 +393,13 @@ static int ll_send_mgc_param(struct obd_export *mgc, char *string)
 /**
  * Create striped directory with specified stripe(@lump)
  *
- * param[in] dparent	the parent of the directory.
- * param[in] lump	the specified stripes.
- * param[in] dirname	the name of the directory.
- * param[in] mode	the specified mode of the directory.
+ * @dparent:	the parent of the directory.
+ * @lump:	the specified stripes.
+ * @dirname:	the name of the directory.
+ * @mode:	the specified mode of the directory.
  *
- * retval		=0 if striped directory is being created successfully.
- *			<0 if the creation is failed.
+ * Returns:	=0 if striped directory is being created successfully.
+ *		<0 if the creation is failed.
  */
 static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 			       const char *dirname, umode_t mode)
@@ -738,7 +738,7 @@ int ll_get_mdt_idx(struct inode *inode)
  * first information for it that real work has started.
  *
  * Moreover, for a ARCHIVE request, it will sample the file data version and
- * store it in \a copy.
+ * store it in @copy.
  *
  * \return 0 on success.
  */
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 6afaa90..4c13a1d 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -112,8 +112,8 @@ static void ll_prepare_close(struct inode *inode, struct md_op_data *op_data,
  * Perform a close, possibly with a bias.
  * The meaning of "data" depends on the value of "bias".
  *
- * If \a bias is MDS_HSM_RELEASE then \a data is a pointer to the data version.
- * If \a bias is MDS_CLOSE_LAYOUT_SWAP then \a data is a pointer to the inode to
+ * If @bias is MDS_HSM_RELEASE then @data is a pointer to the data version.
+ * If @bias is MDS_CLOSE_LAYOUT_SWAP then @data is a pointer to the inode to
  * swap layouts with.
  */
 static int ll_close_inode_openhandle(struct inode *inode,
@@ -923,11 +923,12 @@ static int ll_lease_och_release(struct inode *inode, struct file *file)
 /**
  * Check whether a layout swap can be done between two inodes.
  *
- * \param[in] inode1  First inode to check
- * \param[in] inode2  Second inode to check
+ * @inode1:	First inode to check
+ * @inode2:	Second inode to check
  *
- * \retval 0 on success, layout swap can be performed between both inodes
- * \retval negative error code if requirements are not met
+ * Return:	0 on success, layout swap can be performed between
+ *		both inodes
+ *		negative error code if requirements are not met
  */
 static int ll_check_swap_layouts_validity(struct inode *inode1,
 					  struct inode *inode2)
@@ -1268,11 +1269,11 @@ static void ll_io_init(struct cl_io *io, const struct file *file, int write)
  * doesn't make the situation worse on single node but it may interleave write
  * results from multiple nodes due to short read handling in ll_file_aio_read().
  *
- * @env   - lu_env
- * @iocb  - kiocb from kernel
- * @iter  - user space buffers where the data will be copied
+ * @env:	lu_env
+ * @iocb:	kiocb from kernel
+ * @iter:	user space buffers where the data will be copied
  *
- * RETURN - number of bytes have been read, or error code if error occurred.
+ * Returns:	number of bytes have been read, or error code if error occurred.
  */
 static ssize_t
 ll_do_fast_read(const struct lu_env *env, struct kiocb *iocb,
@@ -1667,11 +1668,11 @@ static int ll_put_grouplock(struct inode *inode, struct file *file,
 /**
  * Close inode open handle
  *
- * \param inode  [in]     inode in question
- * \param it     [in,out] intent which contains open info and result
+ * @inode:	inode in question
+ * @it:		intent which contains open info and result
  *
- * \retval 0     success
- * \retval <0    failure
+ * Returns:	0     success
+ *		<0    failure
  */
 int ll_release_openhandle(struct inode *inode, struct lookup_intent *it)
 {
@@ -1712,8 +1713,8 @@ int ll_release_openhandle(struct inode *inode, struct lookup_intent *it)
  * Get size for inode for which FIEMAP mapping is requested.
  * Make the FIEMAP get_info call and returns the result.
  *
- * \param fiemap	kernel buffer to hold extens
- * \param num_bytes	kernel buffer size
+ * @fiemap:	kernel buffer to hold extens
+ * @num_bytes:	kernel buffer size
  */
 static int ll_do_fiemap(struct inode *inode, struct fiemap *fiemap,
 			size_t num_bytes)
@@ -1823,7 +1824,7 @@ int ll_fid2path(struct inode *inode, void __user *arg)
  * This value is computed using stripe object version on OST.
  * Version is computed using server side locking.
  *
- * @param flags if do sync on the OST side;
+ * @flags:	if do sync on the OST side;
  *		0: no sync
  *		LL_DV_RD_FLUSH: flush dirty pages, LCK_PR on OSTs
  *		LL_DV_WR_FLUSH: drop all caching pages, LCK_PW on OSTs
@@ -3174,10 +3175,12 @@ int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
  * - bits can be in different locks
  * - if found clear the common lock bits in *bits
  * - the bits not found, are kept in *bits
- * \param inode [IN]
- * \param bits [IN] searched lock bits [IN]
- * \param l_req_mode [IN] searched lock mode
- * \retval boolean, true iff all bits are found
+ *
+ * @inode:		inode
+ * @bits:		searched lock bits [IN]
+ * @l_req_mode:		searched lock mode
+ *
+ * Returns:		boolean, true iff all bits are found
  */
 int ll_have_md_lock(struct inode *inode, u64 *bits,
 		    enum ldlm_mode l_req_mode)
@@ -3828,9 +3831,8 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
  * @inode	file inode
  * @intent	layout intent
  *
- * RETURNS:
- * 0		on success
- * retval < 0	error code
+ * Returns:	0 on success
+ *		< 0 error code
  */
 static int ll_layout_intent(struct inode *inode, struct layout_intent *intent)
 {
@@ -3938,13 +3940,13 @@ int ll_layout_refresh(struct inode *inode, u32 *gen)
 /**
  * Issue layout intent RPC indicating where in a file an IO is about to write.
  *
- * \param[in] inode    file inode.
- * \param[in] start    start offset of fille in bytes where an IO is about to
- *                     write.
- * \param[in] end      exclusive end offset in bytes of the write range.
+ * @inode:	file inode.
+ * @start:	start offset of fille in bytes where an IO is about to
+ *		write.
+ * @end:	exclusive end offset in bytes of the write range.
  *
- * \retval 0   on success
- * \retval < 0 error code
+ * Returns:	0 on success
+ *		< 0 error code
  */
 int ll_layout_write_intent(struct inode *inode, u64 start, u64 end)
 {
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index 27c233d..05c267f 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -58,8 +58,8 @@
 /*
  * Check whether file has possible unwriten pages.
  *
- * \retval 1    file is mmap-ed or has dirty pages
- *	 0    otherwise
+ * Return:	1 if file is mmap-ed or has dirty pages
+ *		0 otherwise
  */
 blkcnt_t dirty_cnt(struct inode *inode)
 {
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index afcaa5e..cc8d1b2 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -130,8 +130,9 @@ int cl_setattr_ost(struct cl_object *obj, const struct iattr *attr,
  * Initialize or update CLIO structures for regular files when new
  * meta-data arrives from the server.
  *
- * \param inode regular file inode
- * \param md    new file metadata from MDS
+ * @inode	regular file inode
+ * @md		new file metadata from MDS
+ *
  * - allocates cl_object if necessary,
  * - updated layout, if object was already here.
  */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index e2417cd..43f5fc7 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -638,11 +638,11 @@ int ll_get_max_mdsize(struct ll_sb_info *sbi, int *lmmsize)
  *
  * \see client_obd::cl_default_mds_easize
  *
- * \param[in]  sbi	superblock info for this filesystem
- * \param[out] lmmsize	pointer to storage location for value
+ * @sbi:	superblock info for this filesystem
+ * @lmmsize:	pointer to storage location for value
  *
- * \retval 0		on success
- * \retval negative	negated errno on failure
+ * Returns:	0 on success
+ *		negated errno on failure
  */
 int ll_get_default_mdsize(struct ll_sb_info *sbi, int *lmmsize)
 {
@@ -662,11 +662,11 @@ int ll_get_default_mdsize(struct ll_sb_info *sbi, int *lmmsize)
  *
  * \see client_obd::cl_default_mds_easize
  *
- * \param[in] sbi	superblock info for this filesystem
- * \param[in] lmmsize	the size to set
+ * @sbi:	superblock info for this filesystem
+ * @lmmsize:	the size to set
  *
- * \retval 0		on success
- * \retval negative	negated errno on failure
+ * Return:	0 on success
+ *		negated errno on failure
  */
 int ll_set_default_mdsize(struct ll_sb_info *sbi, int lmmsize)
 {
@@ -2181,8 +2181,8 @@ int ll_remount_fs(struct super_block *sb, int *flags, char *data)
  * holds the reference on such file/object, then it will block the
  * subsequent threads that want to locate such object via FID.
  *
- * \param[in] sb	super block for this file-system
- * \param[in] open_req	pointer to the original open request
+ * @sb:		super block for this file-system
+ * @open_req:	pointer to the original open request
  */
 void ll_open_cleanup(struct super_block *sb, struct ptlrpc_request *open_req)
 {
@@ -2475,7 +2475,7 @@ int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg)
 }
 
 /**
- * Get lustre file system name by \a sbi. If \a buf is provided(non-NULL), the
+ * Get lustre file system name by @sbi. If @buf is provided(non-NULL), the
  * fsname will be returned in this buffer; otherwise, a static buffer will be
  * used to store the fsname and returned to caller.
  */
@@ -2612,13 +2612,13 @@ void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 /**
  * Parse linkea content to extract information about a given hardlink
  *
- * \param[in]	ldata		- Initialized linkea data
- * \param[in]	linkno		- Link identifier
- * \param[out]	parent_fid	- The entry's parent FID
- * \param[in]	size		- Entry name destination buffer
+ * @ldata:		- Initialized linkea data
+ * @linkno:		- Link identifier
+ * @parent_fid:		- The entry's parent FID
+ * @size:		- Entry name destination buffer
  *
- * \retval 0 on success
- * \retval Appropriate negative error code on failure
+ * Returns:		0 on success
+ *			Appropriate negative error code on failure
  */
 static int ll_linkea_decode(struct linkea_data *ldata, unsigned int linkno,
 			    struct lu_fid *parent_fid, struct lu_name *ln)
@@ -2655,14 +2655,14 @@ static int ll_linkea_decode(struct linkea_data *ldata, unsigned int linkno,
  * a given link number, letting the caller iterate over linkno to list one or
  * all links of an entry.
  *
- * \param[in]	  file	- File descriptor against which to perform the operation
- * \param[in,out] arg	- User-filled structure containing the linkno to operate
- *			  on and the available size. It is eventually filled
- *			  with the requested information or left untouched on
- *			  error
+ * @file:	- File descriptor against which to perform the operation
+ * @arg:	- User-filled structure containing the linkno to operate
+ *		  on and the available size. It is eventually filled
+ *		  with the requested information or left untouched on
+ *		  error
  *
- * \retval - 0 on success
- * \retval - Appropriate negative error code on failure
+ * Returns:	- 0 on success
+ *		- Appropriate negative error code on failure
  */
 int ll_getparent(struct file *file, struct getparent __user *arg)
 {
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index f5aaaf7..1865db1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -79,10 +79,11 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 
 /**
  * API independent part for page fault initialization.
- * \param vma - virtual memory area addressed to page fault
- * \param env - corespondent lu_env to processing
- * \param index - page index corespondent to fault.
- * \parm ra_flags - vma readahead flags.
+ *
+ * @vma		virtual memory area addressed to page fault
+ * @env		corespondent lu_env to processing
+ * @index	page index corespondent to fault.
+ * @ra_flags	vma readahead flags.
  *
  * \return error codes from cl_io_init.
  */
@@ -254,12 +255,12 @@ static inline vm_fault_t to_fault_error(int result)
  * Lustre implementation of a vm_operations_struct::fault() method, called by
  * VM to server page fault (both in kernel and user space).
  *
- * \param vma - is virtual area struct related to page fault
- * \param vmf - structure which describe type and address where hit fault
+ * @vma		is virtual area struct related to page fault
+ * @vmf		structure which describe type and address where hit fault
  *
- * \return allocated and filled _locked_ page for address
- * \retval VM_FAULT_ERROR on general error
- * \retval NOPAGE_OOM not have memory for allocate new page
+ * Return:	allocated and filled _locked_ page for address
+ *		VM_FAULT_ERROR on general error
+ *		NOPAGE_OOM not have memory for allocate new page
  */
 static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 3f34073..9129f47 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -178,8 +178,8 @@ struct lustre_nfs_fid {
 }
 
 /**
- * \a connectable - is nfsd will connect himself or this should be done
- *		    at lustre
+ * @connectable - is nfsd will connect himself or this should be done
+ *		 @lustre
  *
  * The return value is file handle type:
  * 1 -- contains child file handle;
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 8215296..dc6494a 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -893,12 +893,12 @@ static ssize_t max_easize_show(struct kobject *kobj,
  *
  * \see client_obd::cl_default_mds_easize
  *
- * \param[in] kobj	kernel object for sysfs tree
- * \param[in] attr	attribute of this kernel object
- * \param[in] buf	buffer to write data into
+ * @kobj:	kernel object for sysfs tree
+ * @attr:	attribute of this kernel object
+ * @buf:	buffer to write data into
  *
- * \retval positive	\a count on success
- * \retval negative	negated errno on failure
+ * Returns:	positive @count on success
+ *		negated errno on failure
  */
 static ssize_t default_easize_show(struct kobject *kobj,
 				   struct attribute *attr,
@@ -924,13 +924,13 @@ static ssize_t default_easize_show(struct kobject *kobj,
  *
  * \see client_obd::cl_default_mds_easize
  *
- * \param[in] kobj	kernel object for sysfs tree
- * \param[in] attr	attribute of this kernel object
- * \param[in] buffer	string passed from user space
- * \param[in] count	\a buffer length
+ * @kobj:	kernel object for sysfs tree
+ * @attr:	attribute of this kernel object
+ * @buffer:	string passed from user space
+ * @count:	@buffer length
  *
- * \retval positive	\a count on success
- * \retval negative	negated errno on failure
+ * Returns:	positive @count on success
+ *		negated errno on failure
  */
 static ssize_t default_easize_store(struct kobject *kobj,
 				    struct attribute *attr,
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.c b/drivers/staging/lustre/lustre/llite/range_lock.c
index c1f0e1e..4cd21b8 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.c
+++ b/drivers/staging/lustre/lustre/llite/range_lock.c
@@ -47,7 +47,7 @@
 /**
  * Initialize a range lock tree
  *
- * \param tree [in]	an empty range lock tree
+ * @tree	an empty range lock tree
  *
  * Pre:  Caller should have allocated the range lock tree.
  * Post: The range lock tree is ready to function.
@@ -62,9 +62,9 @@ void range_lock_tree_init(struct range_lock_tree *tree)
 /**
  * Initialize a range lock node
  *
- * \param lock  [in]	an empty range lock node
- * \param start [in]	start of the covering region
- * \param end   [in]	end of the covering region
+ * @lock	an empty range lock node
+ * @start	start of the covering region
+ * @end		end of the covering region
  *
  * Pre:  Caller should have allocated the range lock node.
  * Post: The range lock node is meant to cover [start, end] region
@@ -89,8 +89,8 @@ int range_lock_init(struct range_lock *lock, u64 start, u64 end)
 /**
  * Unlock a range lock, wake up locks blocked by this lock.
  *
- * \param tree [in]	range lock tree
- * \param lock [in]	range lock to be deleted
+ * @tree	range lock tree
+ * @lock	range lock to be deleted
  *
  * If this lock has been granted, relase it; if not, just delete it from
  * the tree or the same region lock list. Wake up those locks only blocked
@@ -120,11 +120,11 @@ void range_unlock(struct range_lock_tree *tree, struct range_lock *lock)
 /**
  * Lock a region
  *
- * \param tree [in]	range lock tree
- * \param lock [in]	range lock node containing the region span
+ * @tree	range lock tree
+ * @lock	range lock node containing the region span
  *
- * \retval 0	get the range lock
- * \retval <0	error code while not getting the range lock
+ * Return:	0 get the range lock
+ *		<0 error code while not getting the range lock
  *
  * If there exists overlapping range lock, the new lock will wait and
  * retry, if later it find that it is not the chosen one to wake up,
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index af983ee..e66aa67 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -62,9 +62,9 @@
  * Get readahead pages from the filesystem readahead pool of the client for a
  * thread.
  *
- * /param sbi superblock for filesystem readahead state ll_ra_info
- * /param ria per-thread readahead state
- * /param pages number of pages requested for readahead for the thread.
+ * @sbi:	superblock for filesystem readahead state ll_ra_info
+ * @ria:	per-thread readahead state
+ * @pages:	number of pages requested for readahead for the thread.
  *
  * WARNING: This algorithm is used to reduce contention on sbi->ll_lock.
  * It should work well if the ra_max_pages is much greater than the single
@@ -73,7 +73,7 @@
  *
  * TODO: There may be a 'global sync problem' if many threads are trying
  * to get an ra budget that is larger than the remaining readahead pages
- * and reach here at exactly the same time. They will compute /a ret to
+ * and reach here at exactly the same time. They will compute @ret to
  * consume the remaining pages, but will fail at atomic_add_return() and
  * get a zero ra window, although there is still ra space remaining. - Jay
  */
@@ -168,10 +168,10 @@ void ll_ras_enter(struct file *f)
 /**
  * Initiates read-ahead of a page with given index.
  *
- * \retval +ve:	page was already uptodate so it will be skipped
+ * Return:	+ve if page was already uptodate so it will be skipped
  *		from being added;
- * \retval -ve:	page wasn't added to \a queue for error;
- * \retval   0:	page was added into \a queue for read ahead.
+ *		-ve if page wasn't added to @queue for error;
+ *		0 if page was added into @queue for read ahead.
  */
 static int ll_read_ahead_page(const struct lu_env *env, struct cl_io *io,
 			      struct cl_page_list *queue, pgoff_t index)
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index de7586d..53bab47 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -792,9 +792,9 @@ static int sa_lookup(struct inode *dir, struct sa_entry *entry)
 /**
  * async stat for file found in dcache, similar to .revalidate
  *
- * \retval	1 dentry valid, no RPC sent
- * \retval	0 dentry invalid, will send async stat RPC
- * \retval	negative number upon error
+ * Return:	1 dentry valid, no RPC sent
+ *		0 dentry invalid, will send async stat RPC
+ *		negative number upon error
  */
 static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 			 struct dentry *dentry)
@@ -1342,14 +1342,15 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
 /**
  * revalidate @dentryp from statahead cache
  *
- * \param[in]  dir	parent directory
- * \param[in]  sai	sai structure
- * \param[out] dentryp	pointer to dentry which will be revalidated
- * \param[in]  unplug	unplug statahead window only (normally for negative
- *			dentry)
- * \retval		1 on success, dentry is saved in @dentryp
- * \retval		0 if revalidation failed (no proper lock on client)
- * \retval		negative number upon error
+ * @dir:	parent directory
+ * @sai:	sai structure
+ * @dentryp:	pointer to dentry which will be revalidated
+ * @unplug:	unplug statahead window only (normally for negative
+ *		dentry)
+ *
+ * Return:	1 on success, dentry is saved in @dentryp
+ *		0 if revalidation failed (no proper lock on client)
+ *		negative number upon error
  */
 static int revalidate_statahead_dentry(struct inode *dir,
 				       struct ll_statahead_info *sai,
@@ -1487,14 +1488,16 @@ static int revalidate_statahead_dentry(struct inode *dir,
 /**
  * start statahead thread
  *
- * \param[in] dir	parent directory
- * \param[in] dentry	dentry that triggers statahead, normally the first
- *			dirent under @dir
- * \retval		-EAGAIN on success, because when this function is
- *			called, it's already in lookup call, so client should
- *			do it itself instead of waiting for statahead thread
- *			to do it asynchronously.
- * \retval		negative number upon error
+ * @dir:	parent directory
+ * @dentry:	dentry that triggers statahead, normally the first
+ *		dirent under @dir
+ *
+ * Returns:	-EAGAIN on success, because when this function is
+ *		called, it's already in lookup call, so client should
+ *		do it itself instead of waiting for statahead thread
+ *		to do it asynchronously.
+ *
+ *		negative number upon error
  */
 static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
 {
@@ -1594,15 +1597,15 @@ static int start_statahead_thread(struct inode *dir, struct dentry *dentry)
  * will start statahead thread if this is the first dir entry, else revalidate
  * dentry from statahead cache.
  *
- * \param[in]  dir	parent directory
- * \param[out] dentryp	dentry to getattr
- * \param[in]  unplug	unplug statahead window only (normally for negative
- *			dentry)
- * \retval		1 on success
- * \retval		0 revalidation from statahead cache failed, caller needs
- *			to getattr from server directly
- * \retval		negative number on error, caller often ignores this and
- *			then getattr from server
+ * @dir:	parent directory
+ * @dentryp:	dentry to getattr
+ * @unplug:	unplug statahead window only (normally for negative
+ *		dentry)
+ * Returns:	1 on success
+ *		0 revalidation from statahead cache failed, caller needs
+ *		to getattr from server directly
+ *		negative number on error, caller often ignores this and
+ *		then getattr from server
  */
 int ll_statahead(struct inode *dir, struct dentry **dentryp, bool unplug)
 {
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index c2b1668..a25d03c 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -86,7 +86,8 @@ struct super_operations lustre_super_operations = {
 /** This is the entry point for the mount call into Lustre.
  * This is called when a server or client is mounted,
  * and this is where we start setting things up.
- * @param data Mount options (e.g. -o flock,abort_recov)
+ *
+ * @data:	Mount options (e.g. -o flock,abort_recov)
  */
 static int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent)
 {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 593b10c..225a858 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -107,7 +107,7 @@ static void vvp_object_size_unlock(struct cl_object *obj)
 
 /**
  * Helper function that if necessary adjusts file size (inode->i_size), when
- * position at the offset \a pos is accessed. File size can be arbitrary stale
+ * position at the offset @pos is accessed. File size can be arbitrary stale
  * on a Lustre client, but client at least knows KMS. If accessed area is
  * inside [0, KMS], set file size to KMS, otherwise glimpse file size.
  *
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index ec0d933..590e5f5 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -227,7 +227,7 @@ static int vvp_page_prep_write(const struct lu_env *env,
  * Handles page transfer errors at VM level.
  *
  * This takes inode as a separate argument, because inode on which error is to
- * be set can be different from \a vmpage inode in case of direct-io.
+ * be set can be different from @vmpage inode in case of direct-io.
  */
 static void vvp_vmpage_error(struct inode *inode, struct page *vmpage,
 			     int ioret)
@@ -309,10 +309,10 @@ static void vvp_page_completion_write(const struct lu_env *env,
  * but hopefully rare situation, as it usually results in transfer being
  * shorter than possible).
  *
- * \retval 0      success, page can be placed into transfer
+ * Return:	0 success, page can be placed into transfer
  *
- * \retval -EAGAIN page is either used by concurrent IO has been
- * truncated. Skip it.
+ *		-EAGAIN page is either used by concurrent IO has been
+ *		truncated. Skip it.
  */
 static int vvp_page_make_ready(const struct lu_env *env,
 			       const struct cl_page_slice *slice)
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index bb235e0..001bdba 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -69,8 +69,8 @@ static void ll_xattr_cache_init(struct ll_inode_info *lli)
  *  Find in @cache and return @xattr_name attribute in @xattr,
  *  for the NULL @xattr_name return the first cached @xattr.
  *
- *  \retval 0        success
- *  \retval -ENODATA if not found
+ *  Return:	0 success
+ *		-ENODATA if not found
  */
 static int ll_xattr_cache_find(struct list_head *cache,
 			       const char *xattr_name,
@@ -97,9 +97,9 @@ static int ll_xattr_cache_find(struct list_head *cache,
  *
  * Add @xattr_name attr with @xattr_val value and @xattr_val_len length,
  *
- * \retval 0       success
- * \retval -ENOMEM if no memory could be allocated for the cached attr
- * \retval -EPROTO if duplicate xattr is being added
+ * Return:	0 success
+ *		-ENOMEM if no memory could be allocated for the cached attr
+ *		-EPROTO if duplicate xattr is being added
  */
 static int ll_xattr_cache_add(struct list_head *cache,
 			      const char *xattr_name,
@@ -151,8 +151,8 @@ static int ll_xattr_cache_add(struct list_head *cache,
  *
  * Remove @xattr_name attribute from @cache.
  *
- * \retval 0        success
- * \retval -ENODATA if @xattr_name is not cached
+ * Return:	0 success
+ *		-ENODATA if @xattr_name is not cached
  */
 static int ll_xattr_cache_del(struct list_head *cache,
 			      const char *xattr_name)
@@ -180,8 +180,8 @@ static int ll_xattr_cache_del(struct list_head *cache,
  * fill in @xld_buffer or only calculate buffer
  * size if @xld_buffer is NULL.
  *
- * \retval >= 0     buffer list size
- * \retval -ENODATA if the list cannot fit @xld_size buffer
+ * Return:	>= 0 buffer list size
+ *		-ENODATA if the list cannot fit @xld_size buffer
  */
 static int ll_xattr_cache_list(struct list_head *cache,
 			       char *xld_buffer,
@@ -213,8 +213,8 @@ static int ll_xattr_cache_list(struct list_head *cache,
 /**
  * Check if the xattr cache is initialized (filled).
  *
- * \retval 0 @cache is not initialized
- * \retval 1 @cache is initialized
+ * Return:	0 @cache is not initialized
+ *		1 @cache is initialized
  */
 static int ll_xattr_cache_valid(struct ll_inode_info *lli)
 {
@@ -226,7 +226,7 @@ static int ll_xattr_cache_valid(struct ll_inode_info *lli)
  *
  * Free all xattr memory. @lli is the inode info pointer.
  *
- * \retval 0 no error occurred
+ * Return:	0 no error occurred
  */
 static int ll_xattr_cache_destroy_locked(struct ll_inode_info *lli)
 {
@@ -261,8 +261,8 @@ int ll_xattr_cache_destroy(struct inode *inode)
  * the function handles it with a separate enq lock.
  * If successful, the function exits with the list lock held.
  *
- * \retval 0       no error occurred
- * \retval -ENOMEM not enough memory
+ * Return:	0 no error occurred
+ *		-ENOMEM not enough memory
  */
 static int ll_xattr_find_get_lock(struct inode *inode,
 				  struct lookup_intent *oit,
@@ -326,9 +326,9 @@ static int ll_xattr_find_get_lock(struct inode *inode,
  *
  * Fetch and cache the whole of xattrs for @inode, acquiring a read lock.
  *
- * \retval 0       no error occurred
- * \retval -EPROTO network protocol error
- * \retval -ENOMEM not enough memory for the cache
+ * Return:		0 no error occurred
+ *			-EPROTO network protocol error
+ *			-ENOMEM not enough memory for the cache
  */
 static int ll_xattr_cache_refill(struct inode *inode)
 {
@@ -451,11 +451,11 @@ static int ll_xattr_cache_refill(struct inode *inode)
  * The resulting value/list is stored in @buffer if the former
  * is not larger than @size.
  *
- * \retval 0        no error occurred
- * \retval -EPROTO  network protocol error
- * \retval -ENOMEM  not enough memory for the cache
- * \retval -ERANGE  the buffer is not large enough
- * \retval -ENODATA no such attr or the list is empty
+ * Return:	0 no error occurred
+ *		-EPROTO network protocol error
+ *		-ENOMEM not enough memory for the cache
+ *		-ERANGE the buffer is not large enough
+ *		-ENODATA no such attr or the list is empty
  */
 int ll_xattr_cache_get(struct inode *inode, const char *name, char *buffer,
 		       size_t size, u64 valid)
diff --git a/drivers/staging/lustre/lustre/llite/xattr_security.c b/drivers/staging/lustre/lustre/llite/xattr_security.c
index b419d8f..f1c011e 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_security.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_security.c
@@ -79,9 +79,9 @@ int ll_dentry_init_security(struct dentry *dentry, int mode, struct qstr *name,
  * and put it in 'security.xxx' xattr of dentry
  * stored in @fs_info.
  *
- * \retval 0        success
- * \retval -ENOMEM  if no memory could be allocated for xattr name
- * \retval < 0      failure to set xattr
+ * Return:	0 success
+ *		-ENOMEM if no memory could be allocated for xattr name
+ *		< 0 failure to set xattr
  */
 static int
 ll_initxattrs(struct inode *inode, const struct xattr *xattr_array,
@@ -116,9 +116,9 @@ int ll_dentry_init_security(struct dentry *dentry, int mode, struct qstr *name,
  * Get security context of @inode in @dir,
  * and put it in 'security.xxx' xattr of @dentry.
  *
- * \retval 0        success, or SELinux is disabled
- * \retval -ENOMEM  if no memory could be allocated for xattr name
- * \retval < 0      failure to get security context or set xattr
+ * Return:	0 success, or SELinux is disabled
+ *		-ENOMEM if no memory could be allocated for xattr name
+ *		< 0 failure to get security context or set xattr
  */
 int
 ll_inode_init_security(struct dentry *dentry, struct inode *inode,
-- 
1.8.3.1
