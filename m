From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:23 -0400
Subject: [lustre-devel] [PATCH 064/151] lustre: clio: introduce CIT_GLIMPSE
 for glimpse
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-65-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

It turned out that it's better to have a standaline I/O context
for glimpse request. In that case, it's easier for glimpse to try
a new mirror if the current one is out of access.

Another problem in this patch is to zero cl_io data structure if
the I/O starts from OSC layer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: d8638fd870ec ("LU-9771 clio: introduce CIT_GLIMPSE for glimpse")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/29082
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  6 ++++--
 fs/lustre/llite/glimpse.c     | 16 +++++++++-------
 fs/lustre/llite/vvp_io.c      |  4 ++++
 fs/lustre/lov/lov_io.c        | 12 ++++++++++++
 fs/lustre/obdclass/cl_io.c    |  2 ++
 fs/lustre/osc/osc_cache.c     |  4 ++--
 fs/lustre/osc/osc_internal.h  |  8 ++++++++
 fs/lustre/osc/osc_lock.c      |  2 +-
 fs/lustre/osc/osc_page.c      |  2 +-
 9 files changed, 43 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index c0d6452..81190ba 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1367,6 +1367,10 @@ enum cl_io_type {
 	 */
 	CIT_FSYNC,
 	/**
+	 * glimpse. An io context to acquire glimpse lock.
+	 */
+	CIT_GLIMPSE,
+	/**
 	 * Miscellaneous io. This is used for occasional io activity that
 	 * doesn't fit into other types. Currently this is used for:
 	 *
@@ -1377,8 +1381,6 @@ enum cl_io_type {
 	 *     - VM induced page write-out. An io context for writing page out
 	 *     for memory cleansing;
 	 *
-	 *     - glimpse. An io context to acquire glimpse lock.
-	 *
 	 *     - grouplock. An io context to acquire group lock.
 	 *
 	 * CIT_MISC io is used simply as a context in which locks and pages
diff --git a/fs/lustre/llite/glimpse.c b/fs/lustre/llite/glimpse.c
index ed5164a..f2f4e4e 100644
--- a/fs/lustre/llite/glimpse.c
+++ b/fs/lustre/llite/glimpse.c
@@ -189,10 +189,13 @@ int __cl_glimpse_size(struct inode *inode, int agl)
 	u16 refcheck;
 
 	result = cl_io_get(inode, &env, &io, &refcheck);
-	if (result > 0) {
-again:
+	if (result <= 0)
+		return result;
+
+	do {
+		io->ci_need_restart = 0;
 		io->ci_verify_layout = 1;
-		result = cl_io_init(env, io, CIT_MISC, io->ci_obj);
+		result = cl_io_init(env, io, CIT_GLIMPSE, io->ci_obj);
 		if (result > 0)
 			/*
 			 * nothing to do for this io. This currently happens
@@ -205,9 +208,8 @@ int __cl_glimpse_size(struct inode *inode, int agl)
 
 		OBD_FAIL_TIMEOUT(OBD_FAIL_GLIMPSE_DELAY, 2);
 		cl_io_fini(env, io);
-		if (unlikely(io->ci_need_restart))
-			goto again;
-		cl_env_put(env, &refcheck);
-	}
+	} while (unlikely(io->ci_need_restart));
+
+	cl_env_put(env, &refcheck);
 	return result;
 }
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index dea820e..3479f7a 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -1352,6 +1352,9 @@ static int vvp_io_read_ahead(const struct lu_env *env,
 			.cio_start	= vvp_io_fsync_start,
 			.cio_fini	= vvp_io_fini
 		},
+		[CIT_GLIMPSE] = {
+			.cio_fini	= vvp_io_fini
+		},
 		[CIT_MISC] = {
 			.cio_fini	= vvp_io_fini
 		},
@@ -1425,5 +1428,6 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 			       PFID(lu_object_fid(&obj->co_lu)), result);
 	}
 
+	io->ci_result = result < 0 ? result : 0;
 	return result;
 }
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index c7fe4a2..1415702 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -256,6 +256,7 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 		break;
 	}
 
+	case CIT_GLIMPSE:
 	case CIT_MISC:
 		lio->lis_pos = 0;
 		lio->lis_endpos = OBD_OBJECT_EOF;
@@ -362,6 +363,8 @@ static void lov_io_sub_inherit(struct lov_io_sub *sub, struct lov_io *lio,
 		io->u.ci_ladvise.li_flags = parent->u.ci_ladvise.li_flags;
 		break;
 	}
+	case CIT_GLIMPSE:
+	case CIT_MISC:
 	default:
 		break;
 	}
@@ -972,6 +975,9 @@ static void lov_io_fsync_end(const struct lu_env *env,
 			.cio_start	= lov_io_start,
 			.cio_end	= lov_io_end
 		},
+		[CIT_GLIMPSE] = {
+			.cio_fini      = lov_io_fini,
+		},
 		[CIT_MISC] = {
 			.cio_fini	= lov_io_fini
 		}
@@ -1046,6 +1052,9 @@ static void lov_empty_impossible(const struct lu_env *env,
 		[CIT_LADVISE] = {
 			.cio_fini	= lov_empty_io_fini
 		},
+		[CIT_GLIMPSE] = {
+			.cio_fini      = lov_empty_io_fini
+		},
 		[CIT_MISC] = {
 			.cio_fini	= lov_empty_io_fini
 		}
@@ -1084,7 +1093,9 @@ int lov_io_init_empty(const struct lu_env *env, struct cl_object *obj,
 	switch (io->ci_type) {
 	default:
 		LBUG();
+		break;
 	case CIT_MISC:
+	case CIT_GLIMPSE:
 	case CIT_READ:
 		result = 0;
 		break;
@@ -1128,6 +1139,7 @@ int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
 		result = -EOPNOTSUPP;
 		break;
 	case CIT_MISC:
+	case CIT_GLIMPSE:
 	case CIT_FSYNC:
 	case CIT_LADVISE:
 	case CIT_DATA_VERSION:
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 1f1579b..3dc5c87 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -124,6 +124,8 @@ void cl_io_fini(const struct lu_env *env, struct cl_io *io)
 		LASSERT(ergo(io->ci_ignore_layout || !io->ci_verify_layout,
 			     !io->ci_need_restart));
 		break;
+	case CIT_GLIMPSE:
+		break;
 	case CIT_LADVISE:
 		break;
 	default:
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index 32785e4..7a707a1 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -1005,7 +1005,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	io  = &osc_env_info(env)->oti_io;
+	io  = osc_env_thread_io(env);
 	io->ci_obj = cl_object_top(osc2cl(obj));
 	io->ci_ignore_layout = 1;
 	rc = cl_io_init(env, io, CIT_MISC, io->ci_obj);
@@ -3180,7 +3180,7 @@ int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 			   pgoff_t start, pgoff_t end, bool discard)
 {
 	struct osc_thread_info *info = osc_env_info(env);
-	struct cl_io *io = &info->oti_io;
+	struct cl_io *io = osc_env_thread_io(env);
 	osc_page_gang_cbt cb;
 	int result;
 
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 65f52f9..2e0c521 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -89,6 +89,14 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 
 extern struct lu_device_type osc_device_type;
 
+static inline struct cl_io *osc_env_thread_io(const struct lu_env *env)
+{
+	struct cl_io *io = &osc_env_info(env)->oti_io;
+
+	memset(io, 0, sizeof(*io));
+	return io;
+}
+
 static inline int osc_is_object(const struct lu_object *obj)
 {
 	return obj->lo_dev->ld_type == &osc_device_type;
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 42dd654..84dda93 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -618,7 +618,7 @@ static unsigned long osc_lock_weight(const struct lu_env *env,
 				     struct osc_object *oscobj,
 				     struct ldlm_extent *extent)
 {
-	struct cl_io *io = &osc_env_info(env)->oti_io;
+	struct cl_io *io = osc_env_thread_io(env);
 	struct cl_object *obj = cl_object_top(&oscobj->oo_cl);
 	pgoff_t page_index;
 	int result;
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 836cb14..6e49cf4 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -560,7 +560,7 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
 	}
 
 	pvec = (struct cl_page **)osc_env_info(env)->oti_pvec;
-	io = &osc_env_info(env)->oti_io;
+	io = osc_env_thread_io(env);
 
 	spin_lock(&cli->cl_lru_list_lock);
 	if (force)
-- 
1.8.3.1
