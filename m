From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:36 -0500
Subject: [lustre-devel] [PATCH 408/622] lustre: llite: release active extent
 on sync write commit
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-409-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Ann Koehler <amk@cray.com>

Processes can wait forever in osc_extent_wait() for the extent state
to change because the extent write is not started before the wait
begins. A 4.7 kernel change to generic_write_sync() modified it to
check IOCB_DSYNC instead of O_SYNC. Thus an active extent is not
released (written) in osc_io_commit_async() in the synchronous case.

Cray-bug-id: LUS-7435
WC-bug-id: https://jira.whamcloud.com/browse/LU-12536
Lustre-commit: a9af7100ce72 ("LU-12536 llite: release active extent on sync write commit")
Signed-off-by: Ann Koehler <amk@cray.com>
Reviewed-on: https://review.whamcloud.com/35472
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c           | 9 +++++++--
 fs/lustre/llite/llite_internal.h | 4 +++-
 fs/lustre/llite/rw.c             | 2 +-
 3 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 5a3e80e..6f418e0 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1407,7 +1407,8 @@ static bool file_is_noatime(const struct file *file)
 	return false;
 }
 
-void ll_io_init(struct cl_io *io, const struct file *file, int write)
+void ll_io_init(struct cl_io *io, const struct file *file, int write,
+		struct vvp_io_args *args)
 {
 	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 	struct inode *inode = file_inode(file);
@@ -1420,7 +1421,11 @@ void ll_io_init(struct cl_io *io, const struct file *file, int write)
 		io->u.ci_wr.wr_sync = file->f_flags & O_SYNC ||
 				      file->f_flags & O_DIRECT ||
 				      IS_SYNC(inode);
+		io->u.ci_wr.wr_sync |= !!(args &&
+					  (args->u.normal.via_iocb->ki_flags &
+					   IOCB_DSYNC));
 	}
+
 	io->ci_obj = ll_i2info(inode)->lli_clob;
 	io->ci_lockreq = CILR_MAYBE;
 	if (ll_file_nolock(file)) {
@@ -1491,7 +1496,7 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 
 restart:
 	io = vvp_env_thread_io(env);
-	ll_io_init(io, file, iot == CIT_WRITE);
+	ll_io_init(io, file, iot == CIT_WRITE, args);
 	io->ci_ndelay_tried = retried;
 
 	if (cl_io_rw_init(env, io, iot, *ppos, count) == 0) {
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index a0d631d..49c0c78 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -786,7 +786,6 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
 void ll_rw_stats_tally(struct ll_sb_info *sbi, pid_t pid,
 		       struct ll_file_data *file, loff_t pos,
 		       size_t count, int rw);
-void ll_io_init(struct cl_io *io, const struct file *file, int write);
 
 enum {
 	LPROC_LL_READ_BYTES,
@@ -1056,6 +1055,9 @@ static inline struct vvp_io_args *ll_env_args(const struct lu_env *env)
 	return &ll_env_info(env)->lti_args;
 }
 
+void ll_io_init(struct cl_io *io, const struct file *file, int write,
+		struct vvp_io_args *args);
+
 /* llite/llite_mmap.c */
 
 int ll_teardown_mmaps(struct address_space *mapping, u64 first, u64 last);
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index fe9a2b0..9c4b89f 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -503,7 +503,7 @@ static void ll_readahead_handle_work(struct work_struct *wq)
 	}
 
 	io = vvp_env_thread_io(env);
-	ll_io_init(io, file, 0);
+	ll_io_init(io, file, 0, NULL);
 
 	rc = ll_readahead_file_kms(env, io, &kms);
 	if (rc != 0)
-- 
1.8.3.1
