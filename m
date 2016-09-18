From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:30 -0400
Subject: [lustre-devel] [PATCH 031/124] staging: lustre: vvp: Use lockless
	__generic_file_aio_write
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Prakash Surya <surya1@llnl.gov>, James Simmons <jsimmons@infradead.org>

From: Prakash Surya <surya1@llnl.gov>

Testing multi-threaded single shard file write performance has shown
the inode mutex to be a limiting factor when using the
generic_file_write_iter function. To work around this bottle neck, this
change replaces the locked version of that call with the lock less
version, specifically, __generic_file_write_iter.

In order to maintain posix consistency, Lustre must now employ it's
own locking mechanism in the higher layers. Currently writes are
protected using the lli_write_mutex in the ll_inode_info structure.
To protect against simultaneous write and truncate operations, since
we no longer take the inode mutex during writes, we must down the
lli_trunc_sem semaphore.

Unfortunately, this change by itself does not garner any performance
benefits. Using FIO on a single machine with 32 GB of RAM, write
performance tests were ran with and without this change applied; the
results are below:

    +---------+-----------+---------+--------+--------+
    |     fio v2.0.13     |   Write Bandwidth (KB/s)  |
    +---------+-----------+---------+--------+--------+
    | # Tasks | GB / Task | Test 1  | Test 2 | Test 3 |
    +---------+-----------+---------+--------+--------+
    |    1    |    64     |  452446 | 454623 | 457653 |
    |    2    |    32     |  850318 | 565373 | 602498 |
    |    4    |    16     | 1058900 | 463546 | 529107 |
    |    8    |     8     | 1026300 | 468190 | 576451 |
    |   16    |     4     | 1065500 | 503160 | 462902 |
    |   32    |     2     | 1068600 | 462228 | 466963 |
    |   64    |     1     |  991830 | 556618 | 557863 |
    +---------+-----------+---------+--------+--------+

 * Test 1: Lustre client running 04ec54f. File per process write
           workload. This test was used as a baseline for what we
           _could_ achieve in the single shared file tests if the
           bottle necks were removed.

 * Test 2: Lustre client running 04ec54f. Single shared file
           workload, each task writing to a unique region.

 * Test 3: Lustre client running 04ec54f + this patch. Single shared
           file workload, each task writing to a unique region.

In order to garner any real performance benefits out of a single
shared file workload, the lli_write_mutex needs to be broken up into a
range lock. That would allow write operations to unique regions of a
file to be executed concurrently. This work is left to be done in a
follow up patch.

Signed-off-by: Prakash Surya <surya1@llnl.gov>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1669
Reviewed-on: http://review.whamcloud.com/6672
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/rw26.c       |    9 -------
 drivers/staging/lustre/lustre/llite/vvp_io.c     |   26 +++++++++++++++++++--
 drivers/staging/lustre/lustre/llite/vvp_page.c   |   16 -------------
 drivers/staging/lustre/lustre/obdclass/cl_page.c |    6 -----
 4 files changed, 23 insertions(+), 34 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 2f8ef54..66dba04 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -375,13 +375,6 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter)
 	io = vvp_env_io(env)->vui_cl.cis_io;
 	LASSERT(io);
 
-	/* 0. Need locking between buffered and direct access. and race with
-	 *    size changing by concurrent truncates and writes.
-	 * 1. Need inode mutex to operate transient pages.
-	 */
-	if (iov_iter_rw(iter) == READ)
-		inode_lock(inode);
-
 	LASSERT(obj->vob_transient_pages == 0);
 	while (iov_iter_count(iter)) {
 		struct page **pages;
@@ -431,8 +424,6 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter)
 	}
 out:
 	LASSERT(obj->vob_transient_pages == 0);
-	if (iov_iter_rw(iter) == READ)
-		inode_unlock(inode);
 
 	if (tot_bytes > 0) {
 		struct vvp_io *vio = vvp_env_io(env);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 09ccd1f..f6dacee 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -959,10 +959,30 @@ static int vvp_io_write_start(const struct lu_env *env,
 
 	CDEBUG(D_VFSTRACE, "write: [%lli, %lli)\n", pos, pos + (long long)cnt);
 
-	if (!vio->vui_iter) /* from a temp io in ll_cl_init(). */
+	if (!vio->vui_iter) {
+		/* from a temp io in ll_cl_init(). */
 		result = 0;
-	else
-		result = generic_file_write_iter(vio->vui_iocb, vio->vui_iter);
+	} else {
+		/*
+		 * When using the locked AIO function (generic_file_aio_write())
+		 * testing has shown the inode mutex to be a limiting factor
+		 * with multi-threaded single shared file performance. To get
+		 * around this, we now use the lockless version. To maintain
+		 * consistency, proper locking to protect against writes,
+		 * trucates, etc. is handled in the higher layers of lustre.
+		 */
+		bool lock_node = !IS_NOSEC(inode);
+
+		if (lock_node)
+			inode_lock(inode);
+		result = __generic_file_write_iter(vio->vui_iocb,
+						   vio->vui_iter);
+		if (lock_node)
+			inode_unlock(inode);
+
+		if (result > 0 || result == -EIOCBQUEUED)
+			result = generic_write_sync(vio->vui_iocb, result);
+	}
 
 	if (result > 0) {
 		result = vvp_io_write_commit(env, io);
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 2818a68..bbbb0f1 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -444,18 +444,10 @@ static int vvp_transient_page_prep(const struct lu_env *env,
 	return 0;
 }
 
-static void vvp_transient_page_verify(const struct cl_page *page)
-{
-	struct inode *inode = vvp_object_inode(page->cp_obj);
-
-	LASSERT(!inode_trylock(inode));
-}
-
 static int vvp_transient_page_own(const struct lu_env *env,
 				  const struct cl_page_slice *slice,
 				  struct cl_io *unused, int nonblock)
 {
-	vvp_transient_page_verify(slice->cpl_page);
 	return 0;
 }
 
@@ -463,21 +455,18 @@ static void vvp_transient_page_assume(const struct lu_env *env,
 				      const struct cl_page_slice *slice,
 				      struct cl_io *unused)
 {
-	vvp_transient_page_verify(slice->cpl_page);
 }
 
 static void vvp_transient_page_unassume(const struct lu_env *env,
 					const struct cl_page_slice *slice,
 					struct cl_io *unused)
 {
-	vvp_transient_page_verify(slice->cpl_page);
 }
 
 static void vvp_transient_page_disown(const struct lu_env *env,
 				      const struct cl_page_slice *slice,
 				      struct cl_io *unused)
 {
-	vvp_transient_page_verify(slice->cpl_page);
 }
 
 static void vvp_transient_page_discard(const struct lu_env *env,
@@ -486,8 +475,6 @@ static void vvp_transient_page_discard(const struct lu_env *env,
 {
 	struct cl_page *page = slice->cpl_page;
 
-	vvp_transient_page_verify(slice->cpl_page);
-
 	/*
 	 * For transient pages, remove it from the radix tree.
 	 */
@@ -511,7 +498,6 @@ vvp_transient_page_completion(const struct lu_env *env,
 			      const struct cl_page_slice *slice,
 			      int ioret)
 {
-	vvp_transient_page_verify(slice->cpl_page);
 }
 
 static void vvp_transient_page_fini(const struct lu_env *env,
@@ -522,7 +508,6 @@ static void vvp_transient_page_fini(const struct lu_env *env,
 	struct vvp_object *clobj = cl2vvp(clp->cp_obj);
 
 	vvp_page_fini_common(vpg);
-	LASSERT(!inode_trylock(clobj->vob_inode));
 	clobj->vob_transient_pages--;
 }
 
@@ -570,7 +555,6 @@ int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
 	} else {
 		struct vvp_object *clobj = cl2vvp(obj);
 
-		LASSERT(!inode_trylock(clobj->vob_inode));
 		cl_page_slice_add(page, &vpg->vpg_cl, obj, index,
 				  &vvp_transient_page_ops);
 		clobj->vob_transient_pages++;
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 80c6e0e..cae8d21 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -228,11 +228,6 @@ EXPORT_SYMBOL(cl_page_find);
 
 static inline int cl_page_invariant(const struct cl_page *pg)
 {
-	/*
-	 * Page invariant is protected by a VM lock.
-	 */
-	LINVRNT(cl_page_is_vmlocked(NULL, pg));
-
 	return cl_page_in_use_noref(pg);
 }
 
@@ -864,7 +859,6 @@ void cl_page_completion(const struct lu_env *env,
 			       (const struct lu_env *,
 				const struct cl_page_slice *, int), ioret);
 	if (anchor) {
-		LASSERT(cl_page_is_vmlocked(env, pg));
 		LASSERT(pg->cp_sync_io == anchor);
 		pg->cp_sync_io = NULL;
 	}
-- 
1.7.1
