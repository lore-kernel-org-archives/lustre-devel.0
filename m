From: James Simmons <jsimmons@infradead.org>
Date: Sun, 25 Nov 2018 21:48:20 -0500
Subject: [lustre-devel] [PATCH 04/12] lustre: llite: remove llite_loop left
 overs
In-Reply-To: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1543200508-6838-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

With the removal of llite_loop several pieces of code are still
present in the llite layer that were only used by the lloop device.
We can remove these no longer used pieces.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8958
Reviewed-on: https://review.whamcloud.com/26795
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c         | 107 +--------------------
 .../staging/lustre/lustre/llite/llite_internal.h   |  64 ------------
 drivers/staging/lustre/lustre/llite/rw26.c         |  51 +++-------
 3 files changed, 15 insertions(+), 207 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 68f88cf..15910ff 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -56,10 +56,6 @@
 static int ll_lease_close(struct obd_client_handle *och, struct inode *inode,
 			  bool *lease_broken);
 
-static enum llioc_iter
-ll_iocontrol_call(struct inode *inode, struct file *file,
-		  unsigned int cmd, unsigned long arg, int *rcp);
-
 static struct ll_file_data *ll_file_data_get(void)
 {
 	struct ll_file_data *fd;
@@ -2620,17 +2616,10 @@ int ll_ioctl_fssetxattr(struct inode *inode, unsigned int cmd,
 		return ll_ioctl_fssetxattr(inode, cmd, arg);
 	case BLKSSZGET:
 		return put_user(PAGE_SIZE, (int __user *)arg);
-	default: {
-		int err;
-
-		if (ll_iocontrol_call(inode, file, cmd, arg, &err) ==
-		     LLIOC_STOP)
-			return err;
-
+	default:
 		return obd_iocontrol(cmd, ll_i2dtexp(inode), 0, NULL,
 				     (void __user *)arg);
 	}
-	}
 }
 
 static loff_t ll_file_seek(struct file *file, loff_t offset, int origin)
@@ -3543,100 +3532,6 @@ int ll_inode_permission(struct inode *inode, int mask)
 	.get_acl	= ll_get_acl,
 };
 
-/* dynamic ioctl number support routines */
-static struct llioc_ctl_data {
-	struct rw_semaphore	ioc_sem;
-	struct list_head	      ioc_head;
-} llioc = {
-	__RWSEM_INITIALIZER(llioc.ioc_sem),
-	LIST_HEAD_INIT(llioc.ioc_head)
-};
-
-struct llioc_data {
-	struct list_head	      iocd_list;
-	unsigned int	    iocd_size;
-	llioc_callback_t	iocd_cb;
-	unsigned int	    iocd_count;
-	unsigned int	    iocd_cmd[0];
-};
-
-void *ll_iocontrol_register(llioc_callback_t cb, int count, unsigned int *cmd)
-{
-	unsigned int size;
-	struct llioc_data *in_data = NULL;
-
-	if (!cb || !cmd || count > LLIOC_MAX_CMD || count < 0)
-		return NULL;
-
-	size = sizeof(*in_data) + count * sizeof(unsigned int);
-	in_data = kzalloc(size, GFP_KERNEL);
-	if (!in_data)
-		return NULL;
-
-	in_data->iocd_size = size;
-	in_data->iocd_cb = cb;
-	in_data->iocd_count = count;
-	memcpy(in_data->iocd_cmd, cmd, sizeof(unsigned int) * count);
-
-	down_write(&llioc.ioc_sem);
-	list_add_tail(&in_data->iocd_list, &llioc.ioc_head);
-	up_write(&llioc.ioc_sem);
-
-	return in_data;
-}
-EXPORT_SYMBOL(ll_iocontrol_register);
-
-void ll_iocontrol_unregister(void *magic)
-{
-	struct llioc_data *tmp;
-
-	if (!magic)
-		return;
-
-	down_write(&llioc.ioc_sem);
-	list_for_each_entry(tmp, &llioc.ioc_head, iocd_list) {
-		if (tmp == magic) {
-			list_del(&tmp->iocd_list);
-			up_write(&llioc.ioc_sem);
-
-			kfree(tmp);
-			return;
-		}
-	}
-	up_write(&llioc.ioc_sem);
-
-	CWARN("didn't find iocontrol register block with magic: %p\n", magic);
-}
-EXPORT_SYMBOL(ll_iocontrol_unregister);
-
-static enum llioc_iter
-ll_iocontrol_call(struct inode *inode, struct file *file,
-		  unsigned int cmd, unsigned long arg, int *rcp)
-{
-	enum llioc_iter ret = LLIOC_CONT;
-	struct llioc_data *data;
-	int rc = -EINVAL, i;
-
-	down_read(&llioc.ioc_sem);
-	list_for_each_entry(data, &llioc.ioc_head, iocd_list) {
-		for (i = 0; i < data->iocd_count; i++) {
-			if (cmd != data->iocd_cmd[i])
-				continue;
-
-			ret = data->iocd_cb(inode, file, cmd, arg, data, &rc);
-			break;
-		}
-
-		if (ret == LLIOC_STOP)
-			break;
-	}
-	up_read(&llioc.ioc_sem);
-
-	if (rcp)
-		*rcp = rc;
-	return ret;
-}
-
 int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 8c703e6..48424a4 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1234,73 +1234,9 @@ static inline int ll_glimpse_size(struct inode *inode)
 	return true;
 }
 
-/* llite ioctl register support routine */
-enum llioc_iter {
-	LLIOC_CONT = 0,
-	LLIOC_STOP
-};
-
-#define LLIOC_MAX_CMD	   256
-
-/*
- * Rules to write a callback function:
- *
- * Parameters:
- *  @magic: Dynamic ioctl call routine will feed this value with the pointer
- *      returned to ll_iocontrol_register.  Callback functions should use this
- *      data to check the potential collasion of ioctl cmd. If collasion is
- *      found, callback function should return LLIOC_CONT.
- *  @rcp: The result of ioctl command.
- *
- *  Return values:
- *      If @magic matches the pointer returned by ll_iocontrol_data, the
- *      callback should return LLIOC_STOP; return LLIOC_STOP otherwise.
- */
-typedef enum llioc_iter (*llioc_callback_t)(struct inode *inode,
-		struct file *file, unsigned int cmd, unsigned long arg,
-		void *magic, int *rcp);
-
-/* export functions */
-/* Register ioctl block dynamatically for a regular file.
- *
- * @cmd: the array of ioctl command set
- * @count: number of commands in the @cmd
- * @cb: callback function, it will be called if an ioctl command is found to
- *      belong to the command list @cmd.
- *
- * Return value:
- *      A magic pointer will be returned if success;
- *      otherwise, NULL will be returned.
- */
-void *ll_iocontrol_register(llioc_callback_t cb, int count, unsigned int *cmd);
-void ll_iocontrol_unregister(void *magic);
-
 int cl_sync_file_range(struct inode *inode, loff_t start, loff_t end,
 		       enum cl_fsync_mode mode, int ignore_layout);
 
-/** direct write pages */
-struct ll_dio_pages {
-	/** page array to be written. we don't support
-	 * partial pages except the last one.
-	 */
-	struct page **ldp_pages;
-	/* offset of each page */
-	loff_t       *ldp_offsets;
-	/** if ldp_offsets is NULL, it means a sequential
-	 * pages to be written, then this is the file offset
-	 * of the first page.
-	 */
-	loff_t	ldp_start_offset;
-	/** how many bytes are to be written. */
-	size_t	ldp_size;
-	/** # of pages in the array. */
-	int	   ldp_nr;
-};
-
-ssize_t ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io,
-			   int rw, struct inode *inode,
-			   struct ll_dio_pages *pv);
-
 static inline int ll_file_nolock(const struct file *file)
 {
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 722e5ea..9843c9e 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -172,32 +172,27 @@ static void ll_free_user_pages(struct page **pages, int npages, int do_dirty)
 	kvfree(pages);
 }
 
-ssize_t ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io,
-			   int rw, struct inode *inode,
-			   struct ll_dio_pages *pv)
+static ssize_t ll_direct_IO_seg(const struct lu_env *env, struct cl_io *io,
+				int rw, struct inode *inode, size_t size,
+				loff_t file_offset, struct page **pages,
+				int page_count)
 {
 	struct cl_page    *clp;
 	struct cl_2queue  *queue;
 	struct cl_object  *obj = io->ci_obj;
 	int i;
 	ssize_t rc = 0;
-	loff_t file_offset  = pv->ldp_start_offset;
-	size_t size = pv->ldp_size;
-	int page_count      = pv->ldp_nr;
-	struct page **pages = pv->ldp_pages;
 	size_t page_size = cl_page_size(obj);
+	size_t orig_size = size;
 	bool do_io;
-	int  io_pages       = 0;
+	int io_pages = 0;
 
 	queue = &io->ci_queue;
 	cl_2queue_init(queue);
 	for (i = 0; i < page_count; i++) {
-		if (pv->ldp_offsets)
-			file_offset = pv->ldp_offsets[i];
-
 		LASSERT(!(file_offset & (page_size - 1)));
 		clp = cl_page_find(env, obj, cl_index(obj, file_offset),
-				   pv->ldp_pages[i], CPT_TRANSIENT);
+				   pages[i], CPT_TRANSIENT);
 		if (IS_ERR(clp)) {
 			rc = PTR_ERR(clp);
 			break;
@@ -274,31 +269,13 @@ ssize_t ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io,
 				       queue, 0);
 	}
 	if (rc == 0)
-		rc = pv->ldp_size;
+		rc = orig_size;
 
 	cl_2queue_discard(env, io, queue);
 	cl_2queue_disown(env, io, queue);
 	cl_2queue_fini(env, queue);
 	return rc;
 }
-EXPORT_SYMBOL(ll_direct_rw_pages);
-
-static ssize_t ll_direct_IO_26_seg(const struct lu_env *env, struct cl_io *io,
-				   int rw, struct inode *inode,
-				   struct address_space *mapping,
-				   size_t size, loff_t file_offset,
-				   struct page **pages, int page_count)
-{
-	struct ll_dio_pages pvec = {
-		.ldp_pages	= pages,
-		.ldp_nr		= page_count,
-		.ldp_size	= size,
-		.ldp_offsets	= NULL,
-		.ldp_start_offset = file_offset
-	};
-
-	return ll_direct_rw_pages(env, io, rw, inode, &pvec);
-}
 
 /* This is the maximum size of a single O_DIRECT request, based on the
  * kmalloc limit.  We need to fit all of the brw_page structs, each one
@@ -308,7 +285,8 @@ static ssize_t ll_direct_IO_26_seg(const struct lu_env *env, struct cl_io *io,
  */
 #define MAX_DIO_SIZE ((KMALLOC_MAX_SIZE / sizeof(struct brw_page) *	  \
 		       PAGE_SIZE) & ~(DT_MAX_BRW_SIZE - 1))
-static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter)
+
+static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 {
 	struct ll_cl_context *lcc;
 	const struct lu_env *env;
@@ -362,10 +340,9 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter)
 		if (likely(result > 0)) {
 			int n = DIV_ROUND_UP(result + offs, PAGE_SIZE);
 
-			result = ll_direct_IO_26_seg(env, io, iov_iter_rw(iter),
-						     inode, file->f_mapping,
-						     result, file_offset, pages,
-						     n);
+			result = ll_direct_IO_seg(env, io, iov_iter_rw(iter),
+						  inode, result, file_offset,
+						  pages, n);
 			ll_free_user_pages(pages, n, iov_iter_rw(iter) == READ);
 		}
 		if (unlikely(result <= 0)) {
@@ -627,7 +604,7 @@ static int ll_migratepage(struct address_space *mapping,
 
 const struct address_space_operations ll_aops = {
 	.readpage	= ll_readpage,
-	.direct_IO      = ll_direct_IO_26,
+	.direct_IO      = ll_direct_IO,
 	.writepage      = ll_writepage,
 	.writepages     = ll_writepages,
 	.set_page_dirty = __set_page_dirty_nobuffers,
-- 
1.8.3.1
