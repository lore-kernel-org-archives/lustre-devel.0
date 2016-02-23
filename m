From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:23 -0500
Subject: [lustre-devel] [PATCH 45/56] staging/lustre/lclient: Adjust
	comments to better conform to coding style
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-46-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patch fixes "Block comments use a trailing */ on a separate line"
warnings from checkpatch.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lclient/glimpse.c    |  3 ++-
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c | 24 ++++++++++++++--------
 .../staging/lustre/lustre/lclient/lcommon_misc.c   |  6 ++++--
 3 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lclient/glimpse.c b/drivers/staging/lustre/lustre/lclient/glimpse.c
index 8533a1e..c4e8a08 100644
--- a/drivers/staging/lustre/lustre/lclient/glimpse.c
+++ b/drivers/staging/lustre/lustre/lclient/glimpse.c
@@ -109,7 +109,8 @@ int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 			 *       if there were no conflicting locks. If there
 			 *       were conflicting locks, enqueuing or waiting
 			 *       fails with -ENAVAIL, but valid inode
-			 *       attributes are returned anyway. */
+			 *       attributes are returned anyway.
+			 */
 			*descr = whole_file;
 			descr->cld_obj   = clob;
 			descr->cld_mode  = CLM_PHANTOM;
diff --git a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
index efa6e2e..30651f2 100644
--- a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
@@ -613,7 +613,8 @@ void ccc_lock_state(const struct lu_env *env,
 		 * stale i_size when doing appending writes and effectively
 		 * cancel the result of the truncate.  Getting the
 		 * ll_inode_size_lock() after the enqueue maintains the DLM
-		 * -> ll_inode_size_lock() acquiring order. */
+		 * -> ll_inode_size_lock() acquiring order.
+		 */
 		if (lock->cll_descr.cld_start == 0 &&
 		    lock->cll_descr.cld_end == CL_PAGE_EOF)
 			cl_merge_lvb(env, inode);
@@ -754,7 +755,8 @@ int ccc_prep_size(const struct lu_env *env, struct cl_object *obj,
 				 * page index, return directly. Do not expect
 				 * kernel will check such case correctly.
 				 * linux-2.6.18-128.1.1 miss to do that.
-				 * --bug 17336 */
+				 * --bug 17336
+				 */
 				loff_t size = cl_isize_read(inode);
 				loff_t cur_index = start >> PAGE_CACHE_SHIFT;
 				loff_t size_index = (size - 1) >>
@@ -884,7 +886,8 @@ again:
 
 		if (attr->ia_valid & ATTR_FILE)
 			/* populate the file descriptor for ftruncate to honor
-			 * group lock - see LU-787 */
+			 * group lock - see LU-787
+			 */
 			cio->cui_fd = cl_iattr2fd(inode, attr);
 
 		result = cl_io_loop(env, io);
@@ -896,7 +899,8 @@ again:
 		goto again;
 	/* HSM import case: file is released, cannot be restored
 	 * no need to fail except if restore registration failed
-	 * with -ENODATA */
+	 * with -ENODATA
+	 */
 	if (result == -ENODATA && io->ci_restore_needed &&
 	    io->ci_result != -ENODATA)
 		result = 0;
@@ -1026,7 +1030,8 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 		/* clob is slave of inode, empty lli_clob means for new inode,
 		 * there is no clob in cache with the given fid, so it is
 		 * unnecessary to perform lookup-alloc-lookup-insert, just
-		 * alloc and insert directly. */
+		 * alloc and insert directly.
+		 */
 		LASSERT(inode->i_state & I_NEW);
 		conf.coc_lu.loc_flags = LOC_F_NEW;
 		clob = cl_object_find(env, lu2cl_dev(site->ls_top_dev),
@@ -1151,7 +1156,8 @@ __u16 ll_dirent_type_get(struct lu_dirent *ent)
 }
 
 /**
- * build inode number from passed @fid */
+ * build inode number from passed @fid
+ */
 __u64 cl_fid_build_ino(const struct lu_fid *fid, int api32)
 {
 	if (BITS_PER_LONG == 32 || api32)
@@ -1162,7 +1168,8 @@ __u64 cl_fid_build_ino(const struct lu_fid *fid, int api32)
 
 /**
  * build inode generation from passed @fid.  If our FID overflows the 32-bit
- * inode number then return a non-zero generation to distinguish them. */
+ * inode number then return a non-zero generation to distinguish them.
+ */
 __u32 cl_fid_build_gen(const struct lu_fid *fid)
 {
 	__u32 gen;
@@ -1183,7 +1190,8 @@ __u32 cl_fid_build_gen(const struct lu_fid *fid)
  * have to wait for the refcount to become zero to destroy the older layout.
  *
  * Notice that the lsm returned by this function may not be valid unless called
- * inside layout lock - MDS_INODELOCK_LAYOUT. */
+ * inside layout lock - MDS_INODELOCK_LAYOUT.
+ */
 struct lov_stripe_md *ccc_inode_lsm_get(struct inode *inode)
 {
 	return lov_lsm_get(cl_i2info(inode)->lli_clob);
diff --git a/drivers/staging/lustre/lustre/lclient/lcommon_misc.c b/drivers/staging/lustre/lustre/lclient/lcommon_misc.c
index 8389a0e..d80bcedd 100644
--- a/drivers/staging/lustre/lustre/lclient/lcommon_misc.c
+++ b/drivers/staging/lustre/lustre/lclient/lcommon_misc.c
@@ -48,7 +48,8 @@
 /* Initialize the default and maximum LOV EA and cookie sizes.  This allows
  * us to make MDS RPCs with large enough reply buffers to hold the
  * maximum-sized (= maximum striped) EA and cookie without having to
- * calculate this (via a call into the LOV + OSCs) each time we make an RPC. */
+ * calculate this (via a call into the LOV + OSCs) each time we make an RPC.
+ */
 int cl_init_ea_size(struct obd_export *md_exp, struct obd_export *dt_exp)
 {
 	struct lov_stripe_md lsm = { .lsm_magic = LOV_MAGIC_V3 };
@@ -74,7 +75,8 @@ int cl_init_ea_size(struct obd_export *md_exp, struct obd_export *dt_exp)
 	cookiesize = stripes * sizeof(struct llog_cookie);
 
 	/* default cookiesize is 0 because from 2.4 server doesn't send
-	 * llog cookies to client. */
+	 * llog cookies to client.
+	 */
 	CDEBUG(D_HA,
 	       "updating def/max_easize: %d/%d def/max_cookiesize: 0/%d\n",
 	       def_easize, easize, cookiesize);
-- 
2.1.0
