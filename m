Return-Path: <SRS0=JyPa=L7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3356FC07E9C
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:48 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 14C4561A13
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14C4561A13
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2619F337DC1;
	Wed,  7 Jul 2021 12:11:36 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D2E5621F925
 for <lustre-devel@lists.lustre.org>; Wed,  7 Jul 2021 12:11:22 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 510B5100F362;
 Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4F19A9D8BD; Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  7 Jul 2021 15:11:12 -0400
Message-Id: <1625685076-1964-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
References: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/15] lustre: llite: parallelize direct i/o
 issuance
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Patrick Farrell <farr0186@gmail.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <farr0186@gmail.com>

Currently, the direct i/o code issues an i/o to a given
stripe, and then waits for that i/o to complete.  (This is
for i/os from a single process.)  This forces DIO to send
only one RPC at a time, serially.

In the case of multi-stripe files and larger i/os from
userspace, this means that i/o is serialized - so single
thread/single process direct i/o doesn't see any benefit
from the combination of extra stripes & larger i/os.

Using part of the AIO support, it is possible to move this
waiting up a level, so it happens after all the i/o is
issued.  (See LU-4198 for AIO support.)

This means we can issue many RPCs and then wait,
dramatically improving performance vs waiting for each RPC
serially.

This is referred to as 'parallel dio'.

Notes:
AIO is not supported on pipes, so we fall back to the old
sync behavior if the source or destination is a pipe.

Error handling is similar to buffered writes: We do not
wait for individual chunks, so we can get an error on an RPC
in the middle of an i/o.  The solution is to return an
error in this case, because we cannot know how many bytes
were written contiguously.  This is similar to buffered i/o
combined with fsync().

The performance improvement from this is dramatic, and
greater at larger sizes.

lfs setstripe -c 8 -S 4M .
mpirun -np 1  $IOR -w -r -t 64M -b 64G -o ./iorfile --posix.odirect
Without the patch:
write     764.85 MiB/s
read      682.87 MiB/s

With patch:
write     4030 MiB/s
read	  4468 MiB/s

WC-bug-id: https://jira.whamcloud.com/browse/LU-13798
Lustre-commit: cba07b68f9386b61 ("LU-13798 llite: parallelize direct i/o issuance")
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/39436
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h    | 10 +++++++-
 fs/lustre/include/lustre_osc.h   |  2 +-
 fs/lustre/llite/file.c           | 51 ++++++++++++++++++++++++++++++++++++----
 fs/lustre/llite/llite_internal.h |  9 +++++++
 fs/lustre/llite/llite_lib.c      |  1 +
 fs/lustre/llite/lproc_llite.c    | 37 +++++++++++++++++++++++++++++
 fs/lustre/llite/rw26.c           | 38 +++++++++---------------------
 fs/lustre/llite/vvp_io.c         |  1 +
 fs/lustre/obdclass/cl_io.c       | 29 +++++++++++++++++++++++
 fs/lustre/osc/osc_cache.c        | 12 +++++++++-
 10 files changed, 155 insertions(+), 35 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 1495949..61a14f4 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1996,7 +1996,13 @@ struct cl_io {
 	/**
 	 * Sequential read hints.
 	 */
-				ci_seq_read:1;
+				ci_seq_read:1,
+	/**
+	 * Do parallel (async) submission of DIO RPCs.  Note DIO is still sync
+	 * to userspace, only the RPCs are submitted async, then waited for at
+	 * the llite layer before returning.
+	 */
+				ci_parallel_dio:1;
 	/**
 	 * Bypass quota check
 	 */
@@ -2585,6 +2591,8 @@ int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
 		    long timeout);
 void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 		     int ioret);
+int cl_sync_io_wait_recycle(const struct lu_env *env, struct cl_sync_io *anchor,
+			    long timeout, int ioret);
 struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb);
 void cl_aio_free(struct cl_dio_aio *aio);
 
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 0947677..884ea59 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -602,7 +602,7 @@ int osc_teardown_async_page(const struct lu_env *env, struct osc_object *obj,
 			    struct osc_page *ops);
 int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 			 struct osc_page *ops);
-int osc_queue_sync_pages(const struct lu_env *env, const struct cl_io *io,
+int osc_queue_sync_pages(const struct lu_env *env, struct cl_io *io,
 			 struct osc_object *obj, struct list_head *list,
 			 int brw_flags);
 int osc_cache_truncate_start(const struct lu_env *env, struct osc_object *obj,
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 2dcf25f..54e343f 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1619,12 +1619,15 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct vvp_io *vio = vvp_env_io(env);
 	struct range_lock range;
+	bool range_locked = false;
 	struct cl_io *io;
 	ssize_t result = 0;
 	int rc = 0;
+	int rc2 = 0;
 	unsigned int retried = 0;
 	unsigned int dio_lock = 0;
 	bool is_aio = false;
+	bool is_parallel_dio = false;
 	struct cl_dio_aio *ci_aio = NULL;
 	size_t per_bytes;
 	bool partial_io = false;
@@ -1642,6 +1645,17 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	if (file->f_flags & O_DIRECT) {
 		if (!is_sync_kiocb(args->u.normal.via_iocb))
 			is_aio = true;
+
+		/* the kernel does not support AIO on pipes, and parallel DIO
+		 * uses part of the AIO path, so we must not do parallel dio
+		 * to pipes
+		 */
+		is_parallel_dio = !iov_iter_is_pipe(args->u.normal.via_iter) &&
+			       !is_aio;
+
+		if (!ll_sbi_has_parallel_dio(sbi))
+			is_parallel_dio = false;
+
 		ci_aio = cl_aio_alloc(args->u.normal.via_iocb);
 		if (!ci_aio) {
 			rc = -ENOMEM;
@@ -1665,10 +1679,9 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	io->ci_aio = ci_aio;
 	io->ci_dio_lock = dio_lock;
 	io->ci_ndelay_tried = retried;
+	io->ci_parallel_dio = is_parallel_dio;
 
 	if (cl_io_rw_init(env, io, iot, *ppos, per_bytes) == 0) {
-		bool range_locked = false;
-
 		if (file->f_flags & O_APPEND)
 			range_lock_init(&range, 0, LUSTRE_EOF);
 		else
@@ -1697,17 +1710,41 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		ll_cl_add(file, env, io, LCC_RW);
 		rc = cl_io_loop(env, io);
 		ll_cl_remove(file, env);
-		if (range_locked) {
+		if (range_locked && !is_parallel_dio) {
 			CDEBUG(D_VFSTRACE, "Range unlock [%llu, %llu]\n",
 			       range.rl_start,
 			       range.rl_last);
 			range_unlock(&lli->lli_write_tree, &range);
+			range_locked = false;
 		}
 	} else {
 		/* cl_io_rw_init() handled IO */
 		rc = io->ci_result;
 	}
 
+	/* N/B: parallel DIO may be disabled during i/o submission;
+	 * if that occurs, async RPCs are resolved before we get here, and this
+	 * wait call completes immediately.
+	 */
+	if (is_parallel_dio) {
+		struct cl_sync_io *anchor = &io->ci_aio->cda_sync;
+
+		/* for dio, EIOCBQUEUED is an implementation detail,
+		 * and we don't return it to userspace
+		 */
+		if (rc == -EIOCBQUEUED)
+			rc = 0;
+
+		rc2 = cl_sync_io_wait_recycle(env, anchor, 0, 0);
+		if (rc2 < 0)
+			rc = rc2;
+
+		if (range_locked) {
+			range_unlock(&lli->lli_write_tree, &range);
+			range_locked = false;
+		}
+	}
+
 	/*
 	 * In order to move forward AIO, ci_nob was increased,
 	 * but that doesn't mean io have been finished, it just
@@ -1717,8 +1754,12 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	 */
 	if (io->ci_nob > 0) {
 		if (!is_aio) {
-			result += io->ci_nob;
-			*ppos = io->u.ci_wr.wr.crw_pos; /* for splice */
+			if (rc2 == 0) {
+				result += io->ci_nob;
+				*ppos = io->u.ci_wr.wr.crw_pos; /* for splice */
+			} else if (rc2) {
+				result = 0;
+			}
 		}
 		count -= io->ci_nob;
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 3674af9..a073d6d 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -631,6 +631,9 @@ enum stats_track_type {
 #define LL_SBI_FOREIGN_SYMLINK	0x20000000 /* foreign fake-symlink support */
 /* foreign fake-symlink upcall registered */
 #define LL_SBI_FOREIGN_SYMLINK_UPCALL	0x40000000
+#define LL_SBI_PARALLEL_DIO     0x80000000 /* parallel (async) submission of
+					    * RPCs for DIO
+					    */
 
 #define LL_SBI_FLAGS {	\
 	"nolck",	\
@@ -664,6 +667,7 @@ enum stats_track_type {
 	"noencrypt",	\
 	"foreign_symlink",	\
 	"foreign_symlink_upcall",	\
+	"parallel_dio",	\
 }
 
 /*
@@ -1001,6 +1005,11 @@ static inline bool ll_sbi_has_foreign_symlink(struct ll_sb_info *sbi)
 	return !!(sbi->ll_flags & LL_SBI_FOREIGN_SYMLINK);
 }
 
+static inline bool ll_sbi_has_parallel_dio(struct ll_sb_info *sbi)
+{
+	return !!(sbi->ll_flags & LL_SBI_PARALLEL_DIO);
+}
+
 void ll_ras_enter(struct file *f, loff_t pos, size_t count);
 
 /* llite/lcommon_misc.c */
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index b131edd..153d34e 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -179,6 +179,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 	sbi->ll_flags |= LL_SBI_AGL_ENABLED;
 	sbi->ll_flags |= LL_SBI_FAST_READ;
 	sbi->ll_flags |= LL_SBI_TINY_WRITE;
+	sbi->ll_flags |= LL_SBI_PARALLEL_DIO;
 	ll_sbi_set_encrypt(sbi, true);
 
 	/* root squash */
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index cd8394c..3b4f60c 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1100,6 +1100,42 @@ static ssize_t tiny_write_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(tiny_write);
 
+static ssize_t parallel_dio_show(struct kobject *kobj,
+				 struct attribute *attr,
+				 char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	return snprintf(buf, PAGE_SIZE, "%u\n",
+		       !!(sbi->ll_flags & LL_SBI_PARALLEL_DIO));
+}
+
+static ssize_t parallel_dio_store(struct kobject *kobj,
+				  struct attribute *attr,
+				  const char *buffer,
+				  size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	bool val;
+	int rc;
+
+	rc = kstrtobool(buffer, &val);
+	if (rc)
+		return rc;
+
+	spin_lock(&sbi->ll_lock);
+	if (val)
+		sbi->ll_flags |= LL_SBI_PARALLEL_DIO;
+	else
+		sbi->ll_flags &= ~LL_SBI_PARALLEL_DIO;
+	spin_unlock(&sbi->ll_lock);
+
+	return count;
+}
+LUSTRE_RW_ATTR(parallel_dio);
+
 static ssize_t max_read_ahead_async_active_show(struct kobject *kobj,
 					       struct attribute *attr,
 					       char *buf)
@@ -1685,6 +1721,7 @@ struct ldebugfs_vars lprocfs_llite_obd_vars[] = {
 	&lustre_attr_xattr_cache.attr,
 	&lustre_attr_fast_read.attr,
 	&lustre_attr_tiny_write.attr,
+	&lustre_attr_parallel_dio.attr,
 	&lustre_attr_file_heat.attr,
 	&lustre_attr_heat_decay_percentage.attr,
 	&lustre_attr_heat_period_second.attr,
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 2de956d..6a1b5bb 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -404,39 +404,23 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 out:
 	aio->cda_bytes += tot_bytes;
 
-	if (is_sync_kiocb(iocb)) {
-		struct cl_sync_io *anchor = &aio->cda_sync;
-		ssize_t rc2;
+	if (rw == WRITE)
+		vio->u.readwrite.vui_written += tot_bytes;
+	else
+		vio->u.readwrite.vui_read += tot_bytes;
 
-		/**
-		 * @anchor was inited as 1 to prevent end_io to be
-		 * called before we add all pages for IO, so drop
-		 * one extra reference to make sure we could wait
-		 * count to be zero.
-		 */
-		cl_sync_io_note(env, anchor, result);
+	/* If async dio submission is not allowed, we must wait here. */
+	if (is_sync_kiocb(iocb) && !io->ci_parallel_dio) {
+		ssize_t rc2;
 
-		rc2 = cl_sync_io_wait(env, anchor, 0);
+		rc2 = cl_sync_io_wait_recycle(env, &aio->cda_sync, 0, 0);
 		if (result == 0 && rc2)
 			result = rc2;
 
-		/**
-		 * One extra reference again, as if @anchor is
-		 * reused we assume it as 1 before using.
-		 */
-		atomic_add(1, &anchor->csi_sync_nr);
-		if (result == 0) {
-			/* no commit async for direct IO */
-			vio->u.readwrite.vui_written += tot_bytes;
-			result = tot_bytes;
-		}
-	} else {
-		if (rw == WRITE)
-			vio->u.readwrite.vui_written += tot_bytes;
-		else
-			vio->u.readwrite.vui_read += tot_bytes;
 		if (result == 0)
-			result = -EIOCBQUEUED;
+			result = tot_bytes;
+	} else if (result == 0) {
+		result = -EIOCBQUEUED;
 	}
 
 	return result;
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 12314fd..0e54f46 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -526,6 +526,7 @@ static void vvp_io_advance(const struct lu_env *env,
 	 * of relying on VFS, we move iov iter by ourselves.
 	 */
 	iov_iter_advance(vio->vui_iter, nob);
+	CDEBUG(D_VFSTRACE, "advancing %ld bytes\n", nob);
 	vio->vui_tot_count -= nob;
 	iov_iter_reexpand(vio->vui_iter, vio->vui_tot_count);
 }
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 6c22137..beda7fc 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1202,3 +1202,32 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 	}
 }
 EXPORT_SYMBOL(cl_sync_io_note);
+
+
+int cl_sync_io_wait_recycle(const struct lu_env *env, struct cl_sync_io *anchor,
+			    long timeout, int ioret)
+{
+	int rc = 0;
+
+	/*
+	 * @anchor was inited as 1 to prevent end_io to be
+	 * called before we add all pages for IO, so drop
+	 * one extra reference to make sure we could wait
+	 * count to be zero.
+	 */
+	cl_sync_io_note(env, anchor, ioret);
+	/* Wait for completion of normal dio.
+	 * This replaces the EIOCBQEUED return from the DIO/AIO
+	 * path, and this is where AIO and DIO implementations
+	 * split.
+	 */
+	rc = cl_sync_io_wait(env, anchor, timeout);
+	/**
+	 * One extra reference again, as if @anchor is
+	 * reused we assume it as 1 before using.
+	 */
+	atomic_add(1, &anchor->csi_sync_nr);
+
+	return rc;
+}
+EXPORT_SYMBOL(cl_sync_io_wait_recycle);
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 0f0daa1..e37c034 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -2640,7 +2640,7 @@ int osc_flush_async_page(const struct lu_env *env, struct cl_io *io,
 	return rc;
 }
 
-int osc_queue_sync_pages(const struct lu_env *env, const struct cl_io *io,
+int osc_queue_sync_pages(const struct lu_env *env, struct cl_io *io,
 			 struct osc_object *obj, struct list_head *list,
 			 int brw_flags)
 {
@@ -2701,6 +2701,7 @@ int osc_queue_sync_pages(const struct lu_env *env, const struct cl_io *io,
 		grants += (1 << cli->cl_chunkbits) *
 			  ((page_count + ppc - 1) / ppc);
 
+		CDEBUG(D_CACHE, "requesting %d bytes grant\n", grants);
 		spin_lock(&cli->cl_loi_list_lock);
 		if (osc_reserve_grant(cli, grants) == 0) {
 			list_for_each_entry(oap, list, oap_pending_item) {
@@ -2710,6 +2711,15 @@ int osc_queue_sync_pages(const struct lu_env *env, const struct cl_io *io,
 			}
 			osc_unreserve_grant_nolock(cli, grants, 0);
 			ext->oe_grants = grants;
+		} else {
+			/* We cannot report ENOSPC correctly if we do parallel
+			 * DIO (async RPC submission), so turn off parallel dio
+			 * if there is not sufficient grant available.  This
+			 * makes individual RPCs synchronous.
+			 */
+			io->ci_parallel_dio = false;
+			CDEBUG(D_CACHE,
+			"not enough grant available, switching to sync for this i/o\n");
 		}
 		spin_unlock(&cli->cl_loi_list_lock);
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
