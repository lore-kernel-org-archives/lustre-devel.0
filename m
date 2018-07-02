From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:19 -0400
Subject: [lustre-devel] [PATCH 02/18] lustre: ladvise: Add feature of giving
 file access advices
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Xi <lixi@ddn.com>

The fadvise() system call provided by Linux kernel enables
applications to give advices or hints about how a file will be
accessed. However, It is only a client side mechanism which is
not enough for distributed file systems like Lustre, because in
order to tune system-wide cache or read-ahead policies, servers
need to understand the advices too.

This patch adds a new feature named ladvise which provides new
APIs and utils to give advices about the access pattern of Lustre
files with the purpose of performance improvement. It is similar
to Linux fadvise() system call, except it forwards the advices
directly from Lustre client to server. The server side codes will
apply appropriate read-ahead and caching techniques for the
corresponding files.

A typical workload for ladvise is e.g. a bunch of different
clients are doing small random reads of a file, so prefetching
pages into OSS cache with big linear reads before the random IO
is a net benefit. Fetching all that data into each client cache
with fadvise() may not be, due to much more data being sent to
the client.

Signed-off-by: Li Xi <lixi@ddn.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-4931
Reviewed-on: http://review.whamcloud.com/10029
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |   3 +-
 .../lustre/include/uapi/linux/lustre/lustre_user.h |  32 +++++++
 drivers/staging/lustre/lustre/include/cl_object.h  |  13 +++
 .../lustre/lustre/include/lustre_req_layout.h      |   4 +
 .../staging/lustre/lustre/include/lustre_swab.h    |   2 +
 drivers/staging/lustre/lustre/llite/file.c         | 106 +++++++++++++++++++++
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   3 +
 drivers/staging/lustre/lustre/lov/lov_io.c         |  28 ++++++
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |   2 +
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |   1 +
 drivers/staging/lustre/lustre/osc/osc_dev.c        |   1 +
 drivers/staging/lustre/lustre/osc/osc_internal.h   |   4 +
 drivers/staging/lustre/lustre/osc/osc_io.c         |  79 +++++++++++++++
 drivers/staging/lustre/lustre/osc/osc_request.c    |  94 ++++++++++++++++++
 drivers/staging/lustre/lustre/ptlrpc/layout.c      |  24 +++++
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |   1 +
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  19 ++++
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |  54 ++++++++++-
 18 files changed, 468 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index 3d77ed6..5fab107 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -812,7 +812,8 @@ enum ost_cmd {
 	OST_QUOTACHECK = 18, /* not used since 2.4 */
 	OST_QUOTACTL   = 19,
 	OST_QUOTA_ADJUST_QUNIT = 20, /* not used since 2.4 */
-	OST_LAST_OPC
+	OST_LADVISE		= 21,
+	OST_LAST_OPC /* must be < 33 to avoid MDS_GETATTR */
 };
 #define OST_FIRST_OPC  OST_REPLY
 
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index 69387f3..fc33a43 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -276,6 +276,7 @@ struct ost_id {
 #define LL_IOC_MIGRATE			_IOR('f', 247, int)
 #define LL_IOC_FID2MDTIDX		_IOWR('f', 248, struct lu_fid)
 #define LL_IOC_GETPARENT		_IOWR('f', 249, struct getparent)
+#define LL_IOC_LADVISE			_IOR('f', 250, struct lu_ladvise)
 
 /* Lease types for use as arg and return of LL_IOC_{GET,SET}_LEASE ioctl. */
 enum ll_lease_type {
@@ -1322,6 +1323,37 @@ struct hsm_copy {
 	struct hsm_action_item	hc_hai;
 };
 
+enum lu_ladvise_type {
+	LU_LADVISE_INVALID	= 0,
+};
+
+#define LU_LADVISE_NAMES { }
+
+struct lu_ladvise {
+	__u64			lla_advice;
+	__u64			lla_start;
+	__u64			lla_end;
+	__u64			lla_padding;
+};
+
+enum ladvise_flag {
+	LF_ASYNC	= 0x00000001,
+};
+
+#define LADVISE_MAGIC 0x1ADF1CE0
+#define LF_MASK LF_ASYNC
+
+struct ladvise_hdr {
+	__u32			lah_magic;	/* LADVISE_MAGIC */
+	__u32			lah_count;	/* number of advices */
+	__u64			lah_flags;	/* from enum ladvise_flag */
+	__u64			lah_padding1;	/* unused */
+	__u64			lah_padding2;	/* unused */
+	struct lu_ladvise	lah_advise[0];
+};
+
+#define LAH_COUNT_MAX		1024
+
 /** @} lustreuser */
 
 #endif /* _LUSTRE_USER_H */
diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 1491beb..58af22e 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1394,6 +1394,11 @@ enum cl_io_type {
 	 * cl_io_loop() is never called for it.
 	 */
 	CIT_MISC,
+	/**
+	 * ladvise handling
+	 * To give advice about access of a file
+	 */
+	CIT_LADVISE,
 	CIT_OP_NR
 };
 
@@ -1804,6 +1809,14 @@ struct cl_io {
 			/* how many pages were written/discarded */
 			unsigned int       fi_nr_written;
 		} ci_fsync;
+		struct cl_ladvise_io {
+			u64			li_start;
+			u64			li_end;
+			/** file system level fid */
+			struct lu_fid	       *li_fid;
+			enum lu_ladvise_type	li_advice;
+			u64			li_flags;
+		} ci_ladvise;
 	} u;
 	struct cl_2queue     ci_queue;
 	size_t	       ci_nob;
diff --git a/drivers/staging/lustre/lustre/include/lustre_req_layout.h b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
index 213d0a0..db6d8ed 100644
--- a/drivers/staging/lustre/lustre/include/lustre_req_layout.h
+++ b/drivers/staging/lustre/lustre/include/lustre_req_layout.h
@@ -190,6 +190,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_format RQF_OST_GET_INFO_LAST_FID;
 extern struct req_format RQF_OST_SET_INFO_LAST_FID;
 extern struct req_format RQF_OST_GET_INFO_FIEMAP;
+extern struct req_format RQF_OST_LADVISE;
 
 /* LDLM req_format */
 extern struct req_format RQF_LDLM_ENQUEUE;
@@ -299,6 +300,9 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_msg_field RMF_MGS_CONFIG_BODY;
 extern struct req_msg_field RMF_MGS_CONFIG_RES;
 
+extern struct req_msg_field RMF_OST_LADVISE_HDR;
+extern struct req_msg_field RMF_OST_LADVISE;
+
 /* generic uint32 */
 extern struct req_msg_field RMF_U32;
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_swab.h b/drivers/staging/lustre/lustre/include/lustre_swab.h
index 9d786bb..e09a3dc 100644
--- a/drivers/staging/lustre/lustre/include/lustre_swab.h
+++ b/drivers/staging/lustre/lustre/include/lustre_swab.h
@@ -99,6 +99,8 @@ void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
 void lustre_swab_swap_layouts(struct mdc_swap_layouts *msl);
 void lustre_swab_close_data(struct close_data *data);
 void lustre_swab_lmv_user_md(struct lmv_user_md *lum);
+void lustre_swab_ladvise(struct lu_ladvise *ladvise);
+void lustre_swab_ladvise_hdr(struct ladvise_hdr *ladvise_hdr);
 
 /* Functions for dumping PTLRPC fields */
 void dump_rniobuf(struct niobuf_remote *rnb);
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 59b5fbc..44bec1d 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1926,6 +1926,54 @@ static inline long ll_lease_type_from_fmode(fmode_t fmode)
 	       ((fmode & FMODE_WRITE) ? LL_LEASE_WRLCK : 0);
 }
 
+/*
+ * Give file access advices
+ *
+ * The ladvise interface is similar to Linux fadvise() system call, except it
+ * forwards the advices directly from Lustre client to server. The server side
+ * codes will apply appropriate read-ahead and caching techniques for the
+ * corresponding files.
+ *
+ * A typical workload for ladvise is e.g. a bunch of different clients are
+ * doing small random reads of a file, so prefetching pages into OSS cache
+ * with big linear reads before the random IO is a net benefit. Fetching
+ * all that data into each client cache with fadvise() may not be, due to
+ * much more data being sent to the client.
+ */
+static int ll_ladvise(struct inode *inode, struct file *file, __u64 flags,
+		      struct lu_ladvise *ladvise)
+{
+	struct cl_ladvise_io *lio;
+	struct lu_env *env;
+	struct cl_io *io;
+	u16 refcheck;
+	int rc;
+
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return PTR_ERR(env);
+
+	io = vvp_env_thread_io(env);
+	io->ci_obj = ll_i2info(inode)->lli_clob;
+
+	/* initialize parameters for ladvise */
+	lio = &io->u.ci_ladvise;
+	lio->li_start = ladvise->lla_start;
+	lio->li_end = ladvise->lla_end;
+	lio->li_fid = ll_inode2fid(inode);
+	lio->li_advice = ladvise->lla_advice;
+	lio->li_flags = flags;
+
+	if (!cl_io_init(env, io, CIT_LADVISE, io->ci_obj))
+		rc = cl_io_loop(env, io);
+	else
+		rc = io->ci_result;
+
+	cl_io_fini(env, io);
+	cl_env_put(env, &refcheck);
+	return rc;
+}
+
 static long
 ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
@@ -2248,6 +2296,64 @@ static inline long ll_lease_type_from_fmode(fmode_t fmode)
 		kfree(hui);
 		return rc;
 	}
+	case LL_IOC_LADVISE: {
+		struct ladvise_hdr *ladvise_hdr;
+		int alloc_size = sizeof(*ladvise_hdr);
+		int num_advise;
+		int i;
+
+		rc = 0;
+		ladvise_hdr = kzalloc(alloc_size, GFP_NOFS);
+		if (!ladvise_hdr)
+			return -ENOMEM;
+
+		if (copy_from_user(ladvise_hdr,
+				   (const struct ladvise_hdr __user *)arg,
+				   alloc_size)) {
+			rc = -EFAULT;
+			goto out_ladvise;
+		}
+
+		if (ladvise_hdr->lah_magic != LADVISE_MAGIC ||
+		    ladvise_hdr->lah_count < 1) {
+			rc = -EINVAL;
+			goto out_ladvise;
+		}
+
+		num_advise = ladvise_hdr->lah_count;
+		if (num_advise >= LAH_COUNT_MAX) {
+			rc = -EFBIG;
+			goto out_ladvise;
+		}
+
+		kfree(ladvise_hdr);
+		alloc_size = offsetof(typeof(*ladvise_hdr),
+				      lah_advise[num_advise]);
+		ladvise_hdr = kzalloc(alloc_size, GFP_NOFS);
+		if (!ladvise_hdr)
+			return -ENOMEM;
+
+		/*
+		 * TODO: submit multiple advices to one server in a single RPC
+		 */
+		if (copy_from_user(ladvise_hdr,
+				   (const struct ladvise_hdr __user *)arg,
+				   alloc_size)) {
+			rc = -EFAULT;
+			goto out_ladvise;
+		}
+
+		for (i = 0; i < num_advise; i++) {
+			rc = ll_ladvise(inode, file, ladvise_hdr->lah_flags,
+					&ladvise_hdr->lah_advise[i]);
+			if (rc)
+				break;
+		}
+
+out_ladvise:
+		kfree(ladvise_hdr);
+		return rc;
+	}
 	default: {
 		int err;
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index df47ed9..70d2387 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -1302,6 +1302,9 @@ static int vvp_io_read_ahead(const struct lu_env *env,
 		},
 		[CIT_MISC] = {
 			.cio_fini   = vvp_io_fini
+		},
+		[CIT_LADVISE] = {
+			.cio_fini	= vvp_io_fini
 		}
 	},
 	.cio_read_ahead	= vvp_io_read_ahead,
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 5098284..6537ba3 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -123,6 +123,14 @@ static void lov_io_sub_inherit(struct cl_io *io, struct lov_io *lio,
 		}
 		break;
 	}
+	case CIT_LADVISE: {
+		io->u.ci_ladvise.li_start = start;
+		io->u.ci_ladvise.li_end = end;
+		io->u.ci_ladvise.li_fid = parent->u.ci_ladvise.li_fid;
+		io->u.ci_ladvise.li_advice = parent->u.ci_ladvise.li_advice;
+		io->u.ci_ladvise.li_flags = parent->u.ci_ladvise.li_flags;
+		break;
+	}
 	default:
 		break;
 	}
@@ -315,6 +323,12 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 		break;
 	}
 
+	case CIT_LADVISE: {
+		lio->lis_pos = io->u.ci_ladvise.li_start;
+		lio->lis_endpos = io->u.ci_ladvise.li_end;
+		break;
+	}
+
 	case CIT_MISC:
 		lio->lis_pos = 0;
 		lio->lis_endpos = OBD_OBJECT_EOF;
@@ -837,6 +851,15 @@ static void lov_io_fsync_end(const struct lu_env *env,
 			.cio_start     = lov_io_start,
 			.cio_end       = lov_io_fsync_end
 		},
+		[CIT_LADVISE] = {
+			.cio_fini	= lov_io_fini,
+			.cio_iter_init	= lov_io_iter_init,
+			.cio_iter_fini	= lov_io_iter_fini,
+			.cio_lock	= lov_io_lock,
+			.cio_unlock	= lov_io_unlock,
+			.cio_start	= lov_io_start,
+			.cio_end	= lov_io_end
+		},
 		[CIT_MISC] = {
 			.cio_fini   = lov_io_fini
 		}
@@ -908,6 +931,9 @@ static void lov_empty_impossible(const struct lu_env *env,
 		[CIT_FSYNC] = {
 			.cio_fini   = lov_empty_io_fini
 		},
+		[CIT_LADVISE] = {
+			.cio_fini	= lov_empty_io_fini
+		},
 		[CIT_MISC] = {
 			.cio_fini   = lov_empty_io_fini
 		}
@@ -950,6 +976,7 @@ int lov_io_init_empty(const struct lu_env *env, struct cl_object *obj,
 		result = 0;
 		break;
 	case CIT_FSYNC:
+	case CIT_LADVISE:
 	case CIT_SETATTR:
 	case CIT_DATA_VERSION:
 		result = 1;
@@ -989,6 +1016,7 @@ int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
 		break;
 	case CIT_MISC:
 	case CIT_FSYNC:
+	case CIT_LADVISE:
 	case CIT_DATA_VERSION:
 		result = 1;
 		break;
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index fcdae60..2c77e72 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -140,6 +140,8 @@ void cl_io_fini(const struct lu_env *env, struct cl_io *io)
 		LASSERT(ergo(io->ci_ignore_layout || !io->ci_verify_layout,
 			     !io->ci_need_restart));
 		break;
+	case CIT_LADVISE:
+		break;
 	default:
 		LBUG();
 	}
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 2d3cba1..d86d3f7 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -110,6 +110,7 @@ struct osc_thread_info {
 	pgoff_t			oti_fn_index; /* first non-overlapped index */
 	struct cl_sync_io	oti_anchor;
 	struct cl_req_attr	oti_req_attr;
+	struct lu_buf		oti_ladvise_buf;
 };
 
 struct osc_object {
diff --git a/drivers/staging/lustre/lustre/osc/osc_dev.c b/drivers/staging/lustre/lustre/osc/osc_dev.c
index 2b5f324..c767a3c 100644
--- a/drivers/staging/lustre/lustre/osc/osc_dev.c
+++ b/drivers/staging/lustre/lustre/osc/osc_dev.c
@@ -122,6 +122,7 @@ static void osc_key_fini(const struct lu_context *ctx,
 {
 	struct osc_thread_info *info = data;
 
+	kvfree(info->oti_ladvise_buf.lb_buf);
 	kmem_cache_free(osc_thread_kmem, info);
 }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 4ddba13..02e8318 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -129,6 +129,10 @@ int osc_sync_base(struct osc_object *exp, struct obdo *oa,
 		  obd_enqueue_update_f upcall, void *cookie,
 		  struct ptlrpc_request_set *rqset);
 
+int osc_ladvise_base(struct obd_export *exp, struct obdo *oa,
+		     struct ladvise_hdr *ladvise_hdr,
+		     obd_enqueue_update_f upcall, void *cookie,
+		     struct ptlrpc_request_set *rqset);
 int osc_process_config_base(struct obd_device *obd, struct lustre_cfg *cfg);
 int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		  struct list_head *ext_list, int cmd);
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 955525f..628743b 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -843,6 +843,80 @@ static void osc_io_fsync_end(const struct lu_env *env,
 	slice->cis_io->ci_result = result;
 }
 
+static int osc_io_ladvise_start(const struct lu_env *env,
+				const struct cl_io_slice *slice)
+{
+	struct cl_io *io = slice->cis_io;
+	struct osc_io *oio = cl2osc_io(env, slice);
+	struct cl_object *obj = slice->cis_obj;
+	struct lov_oinfo *loi = cl2osc(obj)->oo_oinfo;
+	struct cl_ladvise_io *lio = &io->u.ci_ladvise;
+	struct obdo *oa = &oio->oi_oa;
+	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
+	struct ladvise_hdr *ladvise_hdr;
+	struct lu_ladvise *ladvise;
+	int num_advise = 1;
+	int result = 0;
+	int buf_size;
+
+	/* TODO: add multiple ladvise support in CLIO */
+	buf_size = offsetof(typeof(*ladvise_hdr), lah_advise[num_advise]);
+	if (osc_env_info(env)->oti_ladvise_buf.lb_len < buf_size) {
+		kvfree(osc_env_info(env)->oti_ladvise_buf.lb_buf);
+		osc_env_info(env)->oti_ladvise_buf.lb_buf = kvzalloc(buf_size,
+								     GFP_NOFS);
+		if (likely(osc_env_info(env)->oti_ladvise_buf.lb_buf))
+			osc_env_info(env)->oti_ladvise_buf.lb_len = buf_size;
+	}
+
+	ladvise_hdr = osc_env_info(env)->oti_ladvise_buf.lb_buf;
+	if (!ladvise_hdr)
+		return -ENOMEM;
+
+	memset(ladvise_hdr, 0, buf_size);
+	ladvise_hdr->lah_magic = LADVISE_MAGIC;
+	ladvise_hdr->lah_count = num_advise;
+	ladvise_hdr->lah_flags = lio->li_flags;
+
+	memset(oa, 0, sizeof(*oa));
+	oa->o_oi = loi->loi_oi;
+	oa->o_valid = OBD_MD_FLID;
+	obdo_set_parent_fid(oa, lio->li_fid);
+
+	ladvise = ladvise_hdr->lah_advise;
+	ladvise->lla_start = lio->li_start;
+	ladvise->lla_end = lio->li_end;
+	ladvise->lla_advice = lio->li_advice;
+
+	if (lio->li_flags & LF_ASYNC) {
+		result = osc_ladvise_base(osc_export(cl2osc(obj)), oa,
+					  ladvise_hdr, NULL, NULL, NULL);
+	} else {
+		init_completion(&cbargs->opc_sync);
+		result = osc_ladvise_base(osc_export(cl2osc(obj)), oa,
+					  ladvise_hdr, osc_async_upcall,
+					  cbargs, PTLRPCD_SET);
+		cbargs->opc_rpc_sent = !result;
+	}
+	return result;
+}
+
+static void osc_io_ladvise_end(const struct lu_env *env,
+			       const struct cl_io_slice *slice)
+{
+	struct cl_io *io = slice->cis_io;
+	struct osc_io *oio = cl2osc_io(env, slice);
+	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
+	struct cl_ladvise_io *lio = &io->u.ci_ladvise;
+	int result = 0;
+
+	if ((!(lio->li_flags & LF_ASYNC)) && cbargs->opc_rpc_sent) {
+		wait_for_completion(&cbargs->opc_sync);
+		result = cbargs->opc_rc;
+	}
+	slice->cis_io->ci_result = result;
+}
+
 static void osc_io_end(const struct lu_env *env,
 		       const struct cl_io_slice *slice)
 {
@@ -891,6 +965,11 @@ static void osc_io_end(const struct lu_env *env,
 			.cio_end    = osc_io_fsync_end,
 			.cio_fini   = osc_io_fini
 		},
+		[CIT_LADVISE] = {
+			.cio_start	= osc_io_ladvise_start,
+			.cio_end	= osc_io_ladvise_end,
+			.cio_fini	= osc_io_fini
+		},
 		[CIT_MISC] = {
 			.cio_fini   = osc_io_fini
 		}
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index ce073b6..0286f25 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -91,6 +91,12 @@ struct osc_fsync_args {
 	void		*fa_cookie;
 };
 
+struct osc_ladvise_args {
+	struct obdo		*la_oa;
+	obd_enqueue_update_f	 la_upcall;
+	void			*la_cookie;
+};
+
 struct osc_enqueue_args {
 	struct obd_export	*oa_exp;
 	enum ldlm_type		oa_type;
@@ -269,6 +275,94 @@ int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
 	return 0;
 }
 
+static int osc_ladvise_interpret(const struct lu_env *env,
+				 struct ptlrpc_request *req,
+				 void *arg, int rc)
+{
+	struct osc_ladvise_args *la = arg;
+	struct ost_body *body;
+
+	if (rc)
+		goto out;
+
+	body = req_capsule_server_get(&req->rq_pill, &RMF_OST_BODY);
+	if (!body) {
+		rc = -EPROTO;
+		goto out;
+	}
+
+	*la->la_oa = body->oa;
+out:
+	rc = la->la_upcall(la->la_cookie, rc);
+	return rc;
+}
+
+/**
+ * If rqset is NULL, do not wait for response. Upcall and cookie could also
+ * be NULL in this case
+ */
+int osc_ladvise_base(struct obd_export *exp, struct obdo *oa,
+		     struct ladvise_hdr *ladvise_hdr,
+		     obd_enqueue_update_f upcall, void *cookie,
+		     struct ptlrpc_request_set *rqset)
+{
+	struct lu_ladvise *ladvise = ladvise_hdr->lah_advise;
+	int num_advise = ladvise_hdr->lah_count;
+	struct ladvise_hdr *req_ladvise_hdr;
+	struct lu_ladvise *req_ladvise;
+	struct osc_ladvise_args *la;
+	struct ptlrpc_request *req;
+	struct ost_body *body;
+	int rc;
+
+	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_LADVISE);
+	if (!req)
+		return -ENOMEM;
+
+	req_capsule_set_size(&req->rq_pill, &RMF_OST_LADVISE, RCL_CLIENT,
+			     num_advise * sizeof(*ladvise));
+	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_LADVISE);
+	if (rc) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
+	req->rq_request_portal = OST_IO_PORTAL;
+	ptlrpc_at_set_req_timeout(req);
+
+	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
+	LASSERT(body);
+	lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa,
+			     oa);
+
+	req_ladvise_hdr = req_capsule_client_get(&req->rq_pill,
+						 &RMF_OST_LADVISE_HDR);
+	memcpy(req_ladvise_hdr, ladvise_hdr, sizeof(*ladvise_hdr));
+
+	req_ladvise = req_capsule_client_get(&req->rq_pill, &RMF_OST_LADVISE);
+	memcpy(req_ladvise, ladvise, sizeof(*ladvise) * num_advise);
+	ptlrpc_request_set_replen(req);
+
+	if (!rqset) {
+		/* Do not wait for response. */
+		ptlrpcd_add_req(req);
+		return 0;
+	}
+
+	req->rq_interpret_reply = osc_ladvise_interpret;
+	BUILD_BUG_ON(sizeof(*la) > sizeof(req->rq_async_args));
+	la = ptlrpc_req_async_args(req);
+	la->la_oa = oa;
+	la->la_upcall = upcall;
+	la->la_cookie = cookie;
+
+	if (rqset == PTLRPCD_SET)
+		ptlrpcd_add_req(req);
+	else
+		ptlrpc_set_add_req(rqset, req);
+
+	return 0;
+}
+
 static int osc_create(const struct lu_env *env, struct obd_export *exp,
 		      struct obdo *oa)
 {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 417d4a1..6ef8789 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -605,6 +605,13 @@
 	&RMF_FIEMAP_VAL
 };
 
+static const struct req_msg_field *ost_ladvise[] = {
+	&RMF_PTLRPC_BODY,
+	&RMF_OST_BODY,
+	&RMF_OST_LADVISE_HDR,
+	&RMF_OST_LADVISE,
+};
+
 static const struct req_msg_field *ost_get_fiemap_server[] = {
 	&RMF_PTLRPC_BODY,
 	&RMF_FIEMAP_VAL
@@ -716,6 +723,7 @@
 	&RQF_OST_GET_INFO_LAST_FID,
 	&RQF_OST_SET_INFO_LAST_FID,
 	&RQF_OST_GET_INFO_FIEMAP,
+	&RQF_OST_LADVISE,
 	&RQF_LDLM_ENQUEUE,
 	&RQF_LDLM_ENQUEUE_LVB,
 	&RQF_LDLM_CONVERT,
@@ -1110,6 +1118,18 @@ struct req_msg_field RMF_SWAP_LAYOUTS =
 	DEFINE_MSGF("swap_layouts", 0, sizeof(struct  mdc_swap_layouts),
 		    lustre_swab_swap_layouts, NULL);
 EXPORT_SYMBOL(RMF_SWAP_LAYOUTS);
+
+struct req_msg_field RMF_OST_LADVISE_HDR =
+	DEFINE_MSGF("ladvise_request", 0, sizeof(struct ladvise_hdr),
+		    lustre_swab_ladvise_hdr, NULL);
+EXPORT_SYMBOL(RMF_OST_LADVISE_HDR);
+
+struct req_msg_field RMF_OST_LADVISE =
+	DEFINE_MSGF("ladvise_request", RMF_F_STRUCT_ARRAY,
+		    sizeof(struct lu_ladvise),
+		    lustre_swab_ladvise, NULL);
+EXPORT_SYMBOL(RMF_OST_LADVISE);
+
 /*
  * Request formats.
  */
@@ -1552,6 +1572,10 @@ struct req_format RQF_OST_GET_INFO_FIEMAP =
 			ost_get_fiemap_server);
 EXPORT_SYMBOL(RQF_OST_GET_INFO_FIEMAP);
 
+struct req_format RQF_OST_LADVISE =
+	DEFINE_REQ_FMT0("OST_LADVISE", ost_ladvise, ost_body_only);
+EXPORT_SYMBOL(RQF_OST_LADVISE);
+
 /* Convenience macro */
 #define FMT_FIELD(fmt, i, j) ((fmt)->rf_fields[(i)].d[(j)])
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index a61e800..52b980c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -66,6 +66,7 @@
 	{ OST_QUOTACHECK,   "ost_quotacheck" },
 	{ OST_QUOTACTL,     "ost_quotactl" },
 	{ OST_QUOTA_ADJUST_QUNIT, "ost_quota_adjust_qunit" },
+	{ OST_LADVISE,			"ost_ladvise" },
 	{ MDS_GETATTR,      "mds_getattr" },
 	{ MDS_GETATTR_NAME, "mds_getattr_lock" },
 	{ MDS_CLOSE,	"mds_close" },
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 0337b33..468fa69 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -2309,3 +2309,22 @@ void lustre_swab_close_data(struct close_data *cd)
 	lustre_swab_lu_fid(&cd->cd_fid);
 	__swab64s(&cd->cd_data_version);
 }
+
+void lustre_swab_ladvise(struct lu_ladvise *ladvise)
+{
+	swab64s(&ladvise->lla_start);
+	swab64s(&ladvise->lla_end);
+	swab64s(&ladvise->lla_advice);
+	BUILD_BUG_ON(!offsetof(typeof(*ladvise), lla_padding));
+}
+EXPORT_SYMBOL(lustre_swab_ladvise);
+
+void lustre_swab_ladvise_hdr(struct ladvise_hdr *ladvise_hdr)
+{
+	swab32s(&ladvise_hdr->lah_magic);
+	swab32s(&ladvise_hdr->lah_count);
+	swab64s(&ladvise_hdr->lah_flags);
+	BUILD_BUG_ON(!offsetof(typeof(*ladvise_hdr), lah_padding1));
+	BUILD_BUG_ON(!offsetof(typeof(*ladvise_hdr), lah_padding2));
+}
+EXPORT_SYMBOL(lustre_swab_ladvise_hdr);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 2b3608c..5a68de5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -101,7 +101,9 @@ void lustre_assert_wire_constants(void)
 		 (long long)OST_QUOTACTL);
 	LASSERTF(OST_QUOTA_ADJUST_QUNIT == 20, "found %lld\n",
 		 (long long)OST_QUOTA_ADJUST_QUNIT);
-	LASSERTF(OST_LAST_OPC == 21, "found %lld\n",
+	LASSERTF(OST_LADVISE == 21, "found %lld\n",
+		 (long long)OST_LADVISE);
+	LASSERTF(OST_LAST_OPC == 22, "found %lld\n",
 		 (long long)OST_LAST_OPC);
 	LASSERTF(OBD_OBJECT_EOF == 0xffffffffffffffffULL, "found 0x%.16llxULL\n",
 		 OBD_OBJECT_EOF);
@@ -4207,4 +4209,54 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(sizeof(((struct hsm_user_import *)0)->hui_archive_id) == 4,
 		 "found %lld\n",
 	      (long long)sizeof(((struct hsm_user_import *)0)->hui_archive_id));
+
+	/* Checks for struct lu_ladvise */
+	LASSERTF((int)sizeof(struct lu_ladvise) == 32, "found %lld\n",
+		 (long long)(int)sizeof(struct lu_ladvise));
+	LASSERTF((int)offsetof(struct lu_ladvise, lla_advice) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct lu_ladvise, lla_advice));
+	LASSERTF((int)sizeof(((struct lu_ladvise *)0)->lla_advice) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct lu_ladvise *)0)->lla_advice));
+	LASSERTF((int)offsetof(struct lu_ladvise, lla_start) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct lu_ladvise, lla_start));
+	LASSERTF((int)sizeof(((struct lu_ladvise *)0)->lla_start) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct lu_ladvise *)0)->lla_start));
+	LASSERTF((int)offsetof(struct lu_ladvise, lla_end) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct lu_ladvise, lla_end));
+	LASSERTF((int)sizeof(((struct lu_ladvise *)0)->lla_end) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct lu_ladvise *)0)->lla_end));
+	LASSERTF((int)offsetof(struct lu_ladvise, lla_padding) == 24, "found %lld\n",
+		 (long long)(int)offsetof(struct lu_ladvise, lla_padding));
+	LASSERTF((int)sizeof(((struct lu_ladvise *)0)->lla_padding) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct lu_ladvise *)0)->lla_padding));
+
+	/* Checks for struct ladvise_hdr */
+	LASSERTF(LADVISE_MAGIC == 0x1ADF1CE0, "found 0x%.8x\n",
+		 LADVISE_MAGIC);
+	LASSERTF((int)sizeof(struct ladvise_hdr) == 32, "found %lld\n",
+		 (long long)(int)sizeof(struct ladvise_hdr));
+	LASSERTF((int)offsetof(struct ladvise_hdr, lah_magic) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct ladvise_hdr, lah_magic));
+	LASSERTF((int)sizeof(((struct ladvise_hdr *)0)->lah_magic) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct ladvise_hdr *)0)->lah_magic));
+	LASSERTF((int)offsetof(struct ladvise_hdr, lah_count) == 4, "found %lld\n",
+		 (long long)(int)offsetof(struct ladvise_hdr, lah_count));
+	LASSERTF((int)sizeof(((struct ladvise_hdr *)0)->lah_count) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct ladvise_hdr *)0)->lah_count));
+	LASSERTF((int)offsetof(struct ladvise_hdr, lah_flags) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct ladvise_hdr, lah_flags));
+	LASSERTF((int)sizeof(((struct ladvise_hdr *)0)->lah_flags) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct ladvise_hdr *)0)->lah_flags));
+	LASSERTF((int)offsetof(struct ladvise_hdr, lah_padding1) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct ladvise_hdr, lah_padding1));
+	LASSERTF((int)sizeof(((struct ladvise_hdr *)0)->lah_padding1) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct ladvise_hdr *)0)->lah_padding1));
+	LASSERTF((int)offsetof(struct ladvise_hdr, lah_padding2) == 24, "found %lld\n",
+		 (long long)(int)offsetof(struct ladvise_hdr, lah_padding2));
+	LASSERTF((int)sizeof(((struct ladvise_hdr *)0)->lah_padding2) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct ladvise_hdr *)0)->lah_padding2));
+	LASSERTF((int)offsetof(struct ladvise_hdr, lah_advise) == 32, "found %lld\n",
+		 (long long)(int)offsetof(struct ladvise_hdr, lah_advise));
+	LASSERTF((int)sizeof(((struct ladvise_hdr *)0)->lah_advise) == 0, "found %lld\n",
+		 (long long)(int)sizeof(((struct ladvise_hdr *)0)->lah_advise));
 }
-- 
1.8.3.1
