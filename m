From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:45 -0400
Subject: [lustre-devel] [PATCH 046/124] staging: lustre: llite: handle
	concurrent use of cob_transient_pages
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-47-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Stephen Champion <schamp@sgi.com>, James Simmons <jsimmons@infradead.org>

From: Stephen Champion <schamp@sgi.com>

With the lockless __generic_file_aio_write introduced in LU-1669,
ll_direct_IO_26 is no longer protected by the inode i_isem.

This renders obsoltete checks that all transient pages have been
handled before and after entry, and requires atomic access to their
counter.

Signed-off-by: Stephen Champion <schamp@sgi.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5700
Reviewed-on: http://review.whamcloud.com/12179
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/rw26.c         |    4 ----
 drivers/staging/lustre/lustre/llite/vvp_internal.h |    9 +++++----
 drivers/staging/lustre/lustre/llite/vvp_object.c   |    6 +++---
 drivers/staging/lustre/lustre/llite/vvp_page.c     |    4 ++--
 4 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 6df89b0..f35eb2e 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -345,7 +345,6 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter)
 	struct cl_io *io;
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = file->f_mapping->host;
-	struct vvp_object *obj = cl_inode2vvp(inode);
 	loff_t file_offset = iocb->ki_pos;
 	ssize_t count = iov_iter_count(iter);
 	ssize_t tot_bytes = 0, result = 0;
@@ -374,7 +373,6 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter)
 	io = vvp_env_io(env)->vui_cl.cis_io;
 	LASSERT(io);
 
-	LASSERT(obj->vob_transient_pages == 0);
 	while (iov_iter_count(iter)) {
 		struct page **pages;
 		size_t offs;
@@ -422,8 +420,6 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter)
 		file_offset += result;
 	}
 out:
-	LASSERT(obj->vob_transient_pages == 0);
-
 	if (tot_bytes > 0) {
 		struct vvp_io *vio = vvp_env_io(env);
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index 99437b8..5802da8 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -217,11 +217,12 @@ struct vvp_object {
 	struct list_head	vob_pending_list;
 
 	/**
-	 * Access this counter is protected by inode->i_sem. Now that
-	 * the lifetime of transient pages must be covered by inode sem,
-	 * we don't need to hold any lock..
+	 * Number of transient pages.  This is no longer protected by i_sem,
+	 * and needs to be atomic.  This is not actually used for anything,
+	 * and can probably be removed.
 	 */
-	int			vob_transient_pages;
+	atomic_t		vob_transient_pages;
+
 	/**
 	 * Number of outstanding mmaps on this file.
 	 *
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 01725fb..6b6a63d 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -67,8 +67,8 @@ static int vvp_object_print(const struct lu_env *env, void *cookie,
 
 	(*p)(env, cookie, "(%s %d %d) inode: %p ",
 	     list_empty(&obj->vob_pending_list) ? "-" : "+",
-	     obj->vob_transient_pages, atomic_read(&obj->vob_mmap_cnt),
-	     inode);
+	     atomic_read(&obj->vob_transient_pages),
+	     atomic_read(&obj->vob_mmap_cnt), inode);
 	if (inode) {
 		lli = ll_i2info(inode);
 		(*p)(env, cookie, "%lu/%u %o %u %d %p "DFID,
@@ -220,7 +220,7 @@ static int vvp_object_init0(const struct lu_env *env,
 			    const struct cl_object_conf *conf)
 {
 	vob->vob_inode = conf->coc_inode;
-	vob->vob_transient_pages = 0;
+	atomic_set(&vob->vob_transient_pages, 0);
 	cl_object_page_init(&vob->vob_cl, sizeof(struct vvp_page));
 	return 0;
 }
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index e763e7f..5d79efc 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -506,7 +506,7 @@ static void vvp_transient_page_fini(const struct lu_env *env,
 	struct vvp_object *clobj = cl2vvp(clp->cp_obj);
 
 	vvp_page_fini_common(vpg);
-	clobj->vob_transient_pages--;
+	atomic_dec(&clobj->vob_transient_pages);
 }
 
 static const struct cl_page_operations vvp_transient_page_ops = {
@@ -555,7 +555,7 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 
 		cl_page_slice_add(page, &vpg->vpg_cl, obj, index,
 				  &vvp_transient_page_ops);
-		clobj->vob_transient_pages++;
+		atomic_inc(&clobj->vob_transient_pages);
 	}
 	return 0;
 }
-- 
1.7.1
