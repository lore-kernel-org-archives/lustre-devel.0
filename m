From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:28 -0400
Subject: [lustre-devel] [PATCH 32/41] staging: lustre: llite: restart short
	read/write for normal IO
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-33-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

If normal IO got short read/write, we'd restart the IO from where
we've accomplished until we meet EOF or error happens.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6389
Reviewed-on: http://review.whamcloud.com/14123
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/fail.c          |    1 +
 .../staging/lustre/lustre/include/obd_support.h    |    2 +
 drivers/staging/lustre/lustre/llite/file.c         |   41 ++++++++++++--------
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   19 ++++++++-
 4 files changed, 45 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/fail.c b/drivers/staging/lustre/lnet/libcfs/fail.c
index e4b1a0a..3a9c8dd 100644
--- a/drivers/staging/lustre/lnet/libcfs/fail.c
+++ b/drivers/staging/lustre/lnet/libcfs/fail.c
@@ -113,6 +113,7 @@ int __cfs_fail_check_set(__u32 id, __u32 value, int set)
 		break;
 	case CFS_FAIL_LOC_RESET:
 		cfs_fail_loc = value;
+		atomic_set(&cfs_fail_count, 0);
 		break;
 	default:
 		LASSERTF(0, "called with bad set %u\n", set);
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 1233c34..7f3f8cd 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -458,6 +458,8 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_LOV_INIT			    0x1403
 #define OBD_FAIL_GLIMPSE_DELAY			    0x1404
 #define OBD_FAIL_LLITE_XATTR_ENOMEM		    0x1405
+#define OBD_FAIL_MAKE_LOVEA_HOLE		    0x1406
+#define OBD_FAIL_LLITE_LOST_LAYOUT		    0x1407
 #define OBD_FAIL_GETATTR_DELAY			    0x1409
 
 #define OBD_FAIL_FID_INDIR	0x1501
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 94caf4f..9bf50bf 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -972,9 +972,11 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
 {
 	struct ll_inode_info *lli = ll_i2info(file_inode(file));
 	struct ll_file_data  *fd  = LUSTRE_FPRIVATE(file);
+	struct vvp_io *vio = vvp_env_io(env);
 	struct range_lock range;
 	struct cl_io	 *io;
-	ssize_t	       result;
+	ssize_t result = 0;
+	int rc = 0;
 
 	CDEBUG(D_VFSTRACE, "file: %s, type: %d ppos: %llu, count: %zu\n",
 	       file->f_path.dentry->d_name.name, iot, *ppos, count);
@@ -1010,9 +1012,8 @@ restart:
 				CDEBUG(D_VFSTRACE, "Range lock [%llu, %llu]\n",
 				       range.rl_node.in_extent.start,
 				       range.rl_node.in_extent.end);
-				result = range_lock(&lli->lli_write_tree,
-						    &range);
-				if (result < 0)
+				rc = range_lock(&lli->lli_write_tree, &range);
+				if (rc < 0)
 					goto out;
 
 				range_locked = true;
@@ -1028,7 +1029,7 @@ restart:
 			LBUG();
 		}
 		ll_cl_add(file, env, io);
-		result = cl_io_loop(env, io);
+		rc = cl_io_loop(env, io);
 		ll_cl_remove(file, env);
 		if (args->via_io_subtype == IO_NORMAL)
 			up_read(&lli->lli_trunc_sem);
@@ -1040,24 +1041,26 @@ restart:
 		}
 	} else {
 		/* cl_io_rw_init() handled IO */
-		result = io->ci_result;
+		rc = io->ci_result;
 	}
 
 	if (io->ci_nob > 0) {
 		result = io->ci_nob;
+		count -= io->ci_nob;
 		*ppos = io->u.ci_wr.wr.crw_pos;
+
+		/* prepare IO restart */
+		if (count > 0 && args->via_io_subtype == IO_NORMAL)
+			args->u.normal.via_iter = vio->vui_iter;
 	}
-	goto out;
 out:
 	cl_io_fini(env, io);
-	/* If any bit been read/written (result != 0), we just return
-	 * short read/write instead of restart io.
-	 */
-	if ((result == 0 || result == -ENODATA) && io->ci_need_restart) {
-		CDEBUG(D_VFSTRACE, "Restart %s on %pD from %lld, count:%zu\n",
+
+	if ((!rc || rc == -ENODATA) && count > 0 && io->ci_need_restart) {
+		CDEBUG(D_VFSTRACE, "%s: restart %s from %lld, count:%zu, result: %zd\n",
+		       file_dentry(file)->d_name.name,
 		       iot == CIT_READ ? "read" : "write",
-		       file, *ppos, count);
-		LASSERTF(io->ci_nob == 0, "%zd\n", io->ci_nob);
+		       *ppos, count, result);
 		goto restart;
 	}
 
@@ -1070,13 +1073,19 @@ out:
 			ll_stats_ops_tally(ll_i2sbi(file_inode(file)),
 					   LPROC_LL_WRITE_BYTES, result);
 			fd->fd_write_failed = false;
-		} else if (result != -ERESTARTSYS) {
+		} else if (!result && !rc) {
+			rc = io->ci_result;
+			if (rc < 0)
+				fd->fd_write_failed = true;
+			else
+				fd->fd_write_failed = false;
+		} else if (rc != -ERESTARTSYS) {
 			fd->fd_write_failed = true;
 		}
 	}
 	CDEBUG(D_VFSTRACE, "iot: %d, result: %zd\n", iot, result);
 
-	return result;
+	return result > 0 ? result : rc;
 }
 
 static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 8f1964f..5f93db8 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -84,9 +84,10 @@ static bool can_populate_pages(const struct lu_env *env, struct cl_io *io,
 		/* don't need lock here to check lli_layout_gen as we have held
 		 * extent lock and GROUP lock has to hold to swap layout
 		 */
-		if (ll_layout_version_get(lli) != vio->vui_layout_gen) {
+		if (ll_layout_version_get(lli) != vio->vui_layout_gen ||
+		    OBD_FAIL_CHECK_RESET(OBD_FAIL_LLITE_LOST_LAYOUT, 0)) {
 			io->ci_need_restart = 1;
-			/* this will return application a short read/write */
+			/* this will cause a short read/write */
 			io->ci_continue = 0;
 			rc = false;
 		}
@@ -960,6 +961,20 @@ static int vvp_io_write_start(const struct lu_env *env,
 
 	CDEBUG(D_VFSTRACE, "write: [%lli, %lli)\n", pos, pos + (long long)cnt);
 
+	/*
+	 * The maximum Lustre file size is variable, based on the OST maximum
+	 * object size and number of stripes.  This needs another check in
+	 * addition to the VFS checks earlier.
+	 */
+	if (pos + cnt > ll_file_maxbytes(inode)) {
+		CDEBUG(D_INODE,
+		       "%s: file " DFID " offset %llu > maxbytes %llu\n",
+		       ll_get_fsname(inode->i_sb, NULL, 0),
+		       PFID(ll_inode2fid(inode)), pos + cnt,
+		       ll_file_maxbytes(inode));
+		return -EFBIG;
+	}
+
 	if (!vio->vui_iter) {
 		/* from a temp io in ll_cl_init(). */
 		result = 0;
-- 
1.7.1
