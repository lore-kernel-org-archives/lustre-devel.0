From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:56 -0500
Subject: [lustre-devel] [PATCH 23/28] lustre: clio: SEEK_HOLE/SEEK_DATA on
 client side
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Patch introduces basic support for lseek SEEK_HOLE/SEEK_DATA
parameters in lustre client.

- introduce new IO type CIT_LSEEK in CLIO stack
- LOV splits request to all stripes involved and merges
  results back.
- OSC sends OST LSEEK RPC asynchronously
- if target doesn't support LSEEK RPC then OSC assumes
  whole related object is data with virtual hole at the end
- lseek restores released files assuming it is done prior
  the file copying.
- tool is added to request needed lseek on file
- basic tests are added in sanity, sanityn and sanity-hsm

WC-bug-id: https://jira.whamcloud.com/browse/LU-10810
Lustre-commit: cda353e6efae50 ("LU-10810 clio: SEEK_HOLE/SEEK_DATA on client side")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39708
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Tested-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h     |  10 +++
 fs/lustre/include/lustre_export.h |   5 ++
 fs/lustre/include/lustre_osc.h    |   4 ++
 fs/lustre/llite/file.c            |  61 ++++++++++++++++--
 fs/lustre/llite/llite_lib.c       |   4 +-
 fs/lustre/llite/vvp_io.c          |  53 +++++++++++++++-
 fs/lustre/lov/lov_io.c            |  99 ++++++++++++++++++++++++++++-
 fs/lustre/mdc/mdc_dev.c           |   4 ++
 fs/lustre/obdclass/cl_io.c        |   1 +
 fs/lustre/osc/osc_io.c            | 127 ++++++++++++++++++++++++++++++++++++++
 10 files changed, 358 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 56200d2..e17385c0 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1415,6 +1415,11 @@ enum cl_io_type {
 	 * To give advice about access of a file
 	 */
 	CIT_LADVISE,
+	/**
+	 * SEEK_HOLE/SEEK_DATA handling to search holes or data
+	 * across all file objects
+	 */
+	CIT_LSEEK,
 	CIT_OP_NR
 };
 
@@ -1892,6 +1897,11 @@ struct cl_io {
 			enum lu_ladvise_type	li_advice;
 			u64			li_flags;
 		} ci_ladvise;
+		struct cl_lseek_io {
+			loff_t			ls_start;
+			loff_t			ls_result;
+			int			ls_whence;
+		} ci_lseek;
 	} u;
 	struct cl_2queue	ci_queue;
 	size_t			ci_nob;
diff --git a/fs/lustre/include/lustre_export.h b/fs/lustre/include/lustre_export.h
index b5fdf8a..ed49a97 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -285,6 +285,11 @@ static inline int exp_connect_encrypt(struct obd_export *exp)
 	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_ENCRYPT);
 }
 
+static inline int exp_connect_lseek(struct obd_export *exp)
+{
+	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_LSEEK);
+}
+
 enum {
 	/* archive_ids in array format */
 	KKUC_CT_DATA_ARRAY_MAGIC	= 0x092013cea,
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 24cfec8..ef5237b 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -704,6 +704,10 @@ int osc_fsync_ost(const struct lu_env *env, struct osc_object *obj,
 void osc_io_fsync_end(const struct lu_env *env,
 		      const struct cl_io_slice *slice);
 void osc_read_ahead_release(const struct lu_env *env, void *cbdata);
+int osc_io_lseek_start(const struct lu_env *env,
+		       const struct cl_io_slice *slice);
+void osc_io_lseek_end(const struct lu_env *env,
+		      const struct cl_io_slice *slice);
 
 /* osc_lock.c */
 void osc_lock_to_lockless(const struct lu_env *env, struct osc_lock *ols,
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 3ba9152..4a3c534 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3984,26 +3984,75 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 	}
 }
 
+loff_t ll_lseek(struct inode *inode, loff_t offset, int whence)
+{
+	struct lu_env *env;
+	struct cl_io *io;
+	struct cl_lseek_io *lsio;
+	u16 refcheck;
+	int rc;
+	loff_t retval;
+
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return PTR_ERR(env);
+
+	io = vvp_env_thread_io(env);
+	io->ci_obj = ll_i2info(inode)->lli_clob;
+
+	lsio = &io->u.ci_lseek;
+	lsio->ls_start = offset;
+	lsio->ls_whence = whence;
+	lsio->ls_result = -ENXIO;
+
+	do {
+		rc = cl_io_init(env, io, CIT_LSEEK, io->ci_obj);
+		if (!rc)
+			rc = cl_io_loop(env, io);
+		else
+			rc = io->ci_result;
+		retval = rc ? : lsio->ls_result;
+		cl_io_fini(env, io);
+	} while (unlikely(io->ci_need_restart));
+
+	cl_env_put(env, &refcheck);
+
+	return retval;
+}
+
 static loff_t ll_file_seek(struct file *file, loff_t offset, int origin)
 {
 	struct inode *inode = file_inode(file);
-	loff_t retval, eof = 0;
+	loff_t retval = offset, eof = 0;
 	ktime_t kstart = ktime_get();
 
-	retval = offset + ((origin == SEEK_END) ? i_size_read(inode) :
-			   (origin == SEEK_CUR) ? file->f_pos : 0);
 	CDEBUG(D_VFSTRACE, "VFS Op:inode=" DFID "(%p), to=%llu=%#llx(%d)\n",
 	       PFID(ll_inode2fid(inode)), inode, retval, retval, origin);
 
-	if (origin == SEEK_END || origin == SEEK_HOLE || origin == SEEK_DATA) {
+	if (origin == SEEK_END) {
 		retval = ll_glimpse_size(inode);
 		if (retval != 0)
 			return retval;
 		eof = i_size_read(inode);
 	}
 
-	retval = generic_file_llseek_size(file, offset, origin,
-					  ll_file_maxbytes(inode), eof);
+	if (origin == SEEK_HOLE || origin == SEEK_DATA) {
+		if (offset < 0)
+			return -ENXIO;
+
+		/* flush local cache first if any */
+		cl_sync_file_range(inode, offset, OBD_OBJECT_EOF,
+				   CL_FSYNC_LOCAL, 0);
+
+		retval = ll_lseek(inode, offset, origin);
+		if (retval < 0)
+			return retval;
+
+		retval = vfs_setpos(file, retval, ll_file_maxbytes(inode));
+	} else {
+		retval = generic_file_llseek_size(file, offset, origin,
+						  ll_file_maxbytes(inode), eof);
+	}
 	if (retval >= 0)
 		ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_LLSEEK,
 				   ktime_us_delta(ktime_get(), kstart));
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index d94c6ca..a4042b8 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -263,7 +263,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT2_LSOM |
 				   OBD_CONNECT2_ASYNC_DISCARD |
 				   OBD_CONNECT2_PCC |
-				   OBD_CONNECT2_CRUSH |
+				   OBD_CONNECT2_CRUSH | OBD_CONNECT2_LSEEK |
 				   OBD_CONNECT2_GETATTR_PFID;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
@@ -473,7 +473,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_FLAGS2 | OBD_CONNECT_GRANT_SHRINK;
 
 	data->ocd_connect_flags2 = OBD_CONNECT2_LOCKAHEAD |
-				   OBD_CONNECT2_INC_XID;
+				   OBD_CONNECT2_INC_XID | OBD_CONNECT2_LSEEK;
 
 	if (!OBD_FAIL_CHECK(OBD_FAIL_OSC_CONNECT_GRANT_PARAM))
 		data->ocd_connect_flags |= OBD_CONNECT_GRANT_PARAM;
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 3a2e1cc..d6ca267 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -1531,6 +1531,51 @@ static int vvp_io_read_ahead(const struct lu_env *env,
 	return result;
 }
 
+static int vvp_io_lseek_lock(const struct lu_env *env,
+			     const struct cl_io_slice *ios)
+{
+	struct cl_io *io = ios->cis_io;
+	u64 lock_start = io->u.ci_lseek.ls_start;
+	u64 lock_end = OBD_OBJECT_EOF;
+	u32 enqflags = CEF_MUST; /* always take client lock */
+
+	return vvp_io_one_lock(env, io, enqflags, CLM_READ,
+			       lock_start, lock_end);
+}
+
+static int vvp_io_lseek_start(const struct lu_env *env,
+			      const struct cl_io_slice *ios)
+{
+	struct cl_io *io = ios->cis_io;
+	struct inode *inode = vvp_object_inode(io->ci_obj);
+	u64 start = io->u.ci_lseek.ls_start;
+
+	inode_lock(inode);
+	inode_dio_wait(inode);
+
+	/* At the moment we have DLM lock so just update inode
+	 * to know the file size.
+	 */
+	ll_merge_attr(env, inode);
+	if (start >= i_size_read(inode)) {
+		io->u.ci_lseek.ls_result = -ENXIO;
+		return -ENXIO;
+	}
+	return 0;
+}
+
+static void vvp_io_lseek_end(const struct lu_env *env,
+			     const struct cl_io_slice *ios)
+{
+	struct cl_io *io = ios->cis_io;
+	struct inode *inode = vvp_object_inode(io->ci_obj);
+
+	if (io->u.ci_lseek.ls_result > i_size_read(inode))
+		io->u.ci_lseek.ls_result = -ENXIO;
+
+	inode_unlock(inode);
+}
+
 static const struct cl_io_operations vvp_io_ops = {
 	.op = {
 		[CIT_READ] = {
@@ -1576,7 +1621,13 @@ static int vvp_io_read_ahead(const struct lu_env *env,
 		},
 		[CIT_LADVISE] = {
 			.cio_fini	= vvp_io_fini
-		}
+		},
+		[CIT_LSEEK] = {
+			.cio_fini	= vvp_io_fini,
+			.cio_lock	= vvp_io_lseek_lock,
+			.cio_start	= vvp_io_lseek_start,
+			.cio_end	= vvp_io_lseek_end,
+		},
 	},
 	.cio_read_ahead	= vvp_io_read_ahead,
 };
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index af79d20..20fcde1 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -529,6 +529,12 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 		break;
 	}
 
+	case CIT_LSEEK: {
+		lio->lis_pos = io->u.ci_lseek.ls_start;
+		lio->lis_endpos = OBD_OBJECT_EOF;
+		break;
+	}
+
 	case CIT_GLIMPSE:
 		lio->lis_pos = 0;
 		lio->lis_endpos = OBD_OBJECT_EOF;
@@ -715,6 +721,12 @@ static void lov_io_sub_inherit(struct lov_io_sub *sub, struct lov_io *lio,
 		io->u.ci_ladvise.li_flags = parent->u.ci_ladvise.li_flags;
 		break;
 	}
+	case CIT_LSEEK: {
+		io->u.ci_lseek.ls_start = start;
+		io->u.ci_lseek.ls_whence = parent->u.ci_lseek.ls_whence;
+		io->u.ci_lseek.ls_result = parent->u.ci_lseek.ls_result;
+		break;
+	}
 	case CIT_GLIMPSE:
 	case CIT_MISC:
 	default:
@@ -1265,6 +1277,80 @@ static void lov_io_fsync_end(const struct lu_env *env,
 	}
 }
 
+static void lov_io_lseek_end(const struct lu_env *env,
+			     const struct cl_io_slice *ios)
+{
+	struct lov_io *lio = cl2lov_io(env, ios);
+	struct cl_io *io = lio->lis_cl.cis_io;
+	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
+	struct lov_io_sub *sub;
+	loff_t offset = -ENXIO;
+	bool seek_hole = io->u.ci_lseek.ls_whence == SEEK_HOLE;
+
+	list_for_each_entry(sub, &lio->lis_active, sub_linkage) {
+		struct cl_io *subio = &sub->sub_io;
+		int index = lov_comp_entry(sub->sub_subio_index);
+		int stripe = lov_comp_stripe(sub->sub_subio_index);
+		loff_t sub_off, lov_off;
+
+		lov_io_end_wrapper(sub->sub_env, subio);
+
+		if (io->ci_result == 0)
+			io->ci_result = sub->sub_io.ci_result;
+
+		if (io->ci_result)
+			continue;
+
+		CDEBUG(D_INFO, DFID ": entry %x stripe %u: SEEK_%s from %lld\n",
+		       PFID(lu_object_fid(lov2lu(lio->lis_object))),
+		       index, stripe, seek_hole ? "HOLE" : "DATA",
+		       subio->u.ci_lseek.ls_start);
+
+		/* first subio with positive result is what we need */
+		sub_off = subio->u.ci_lseek.ls_result;
+		/* Expected error, offset is out of stripe file size */
+		if (sub_off == -ENXIO)
+			continue;
+		/* Any other errors are not expected with ci_result == 0 */
+		if (sub_off < 0) {
+			CDEBUG(D_INFO, "unexpected error: rc = %lld\n",
+			       sub_off);
+			io->ci_result = sub_off;
+			continue;
+		}
+		lov_off = lov_stripe_size(lsm, index, sub_off + 1, stripe) - 1;
+		if (lov_off < 0) {
+			/* the only way to get negatove lov_off here is too big
+			 * result. Return -EOVERFLOW then.
+			 */
+			io->ci_result = -EOVERFLOW;
+			CDEBUG(D_INFO, "offset %llu is too big: rc = %d\n",
+			       (u64)lov_off, io->ci_result);
+			continue;
+		}
+		if (lov_off < io->u.ci_lseek.ls_start) {
+			io->ci_result = -EINVAL;
+			CDEBUG(D_INFO, "offset %lld < start %lld: rc = %d\n",
+			       sub_off, io->u.ci_lseek.ls_start, io->ci_result);
+			continue;
+		}
+		/* resulting offset can be out of component range if stripe
+		 * object is full and its file size was returned as virtual
+		 * hole start. Skip this result, the next component will give
+		 * us correct lseek result.
+		 */
+		if (lov_off >= lsm->lsm_entries[index]->lsme_extent.e_end)
+			continue;
+
+		CDEBUG(D_INFO, "SEEK_%s: %lld->%lld/%lld: rc = %d\n",
+		       seek_hole ? "HOLE" : "DATA",
+		       subio->u.ci_lseek.ls_start, sub_off, lov_off,
+		       sub->sub_io.ci_result);
+		offset = min_t(u64, offset, lov_off);
+	}
+	io->u.ci_lseek.ls_result = offset;
+}
+
 static const struct cl_io_operations lov_io_ops = {
 	.op = {
 		[CIT_READ] = {
@@ -1330,8 +1416,17 @@ static void lov_io_fsync_end(const struct lu_env *env,
 			.cio_start	= lov_io_start,
 			.cio_end	= lov_io_end
 		},
+		[CIT_LSEEK] = {
+			.cio_fini	= lov_io_fini,
+			.cio_iter_init	= lov_io_iter_init,
+			.cio_iter_fini	= lov_io_iter_fini,
+			.cio_lock	= lov_io_lock,
+			.cio_unlock	= lov_io_unlock,
+			.cio_start	= lov_io_start,
+			.cio_end	= lov_io_lseek_end
+		},
 		[CIT_GLIMPSE] = {
-			.cio_fini      = lov_io_fini,
+			.cio_fini	= lov_io_fini,
 		},
 		[CIT_MISC] = {
 			.cio_fini	= lov_io_fini
@@ -1459,6 +1554,7 @@ int lov_io_init_empty(const struct lu_env *env, struct cl_object *obj,
 		break;
 	case CIT_FSYNC:
 	case CIT_LADVISE:
+	case CIT_LSEEK:
 	case CIT_SETATTR:
 	case CIT_DATA_VERSION:
 		result = 1;
@@ -1522,6 +1618,7 @@ int lov_io_init_released(const struct lu_env *env, struct cl_object *obj,
 	case CIT_READ:
 	case CIT_WRITE:
 	case CIT_FAULT:
+	case CIT_LSEEK:
 		io->ci_restore_needed = 1;
 		result = -ENODATA;
 		break;
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 90b60f5..214fd31 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -1297,6 +1297,10 @@ static void mdc_io_data_version_end(const struct lu_env *env,
 			.cio_start	= mdc_io_fsync_start,
 			.cio_end	= osc_io_fsync_end,
 		},
+		[CIT_LSEEK] = {
+			.cio_start	= osc_io_lseek_start,
+			.cio_end	= osc_io_lseek_end,
+		},
 	},
 	.cio_read_ahead		= mdc_io_read_ahead,
 	.cio_submit		= osc_io_submit,
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index aa3cb17..c57a3766 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -127,6 +127,7 @@ void cl_io_fini(const struct lu_env *env, struct cl_io *io)
 	case CIT_GLIMPSE:
 		break;
 	case CIT_LADVISE:
+	case CIT_LSEEK:
 		break;
 	default:
 		LBUG();
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 6121f39..a0537b8 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -1042,6 +1042,128 @@ void osc_io_end(const struct lu_env *env, const struct cl_io_slice *slice)
 }
 EXPORT_SYMBOL(osc_io_end);
 
+struct osc_lseek_args {
+	struct osc_io *lsa_oio;
+};
+
+static int osc_lseek_interpret(const struct lu_env *env,
+			       struct ptlrpc_request *req,
+			       void *arg, int rc)
+{
+	struct ost_body *reply;
+	struct osc_lseek_args *lsa = arg;
+	struct osc_io *oio = lsa->lsa_oio;
+	struct cl_io *io = oio->oi_cl.cis_io;
+	struct cl_lseek_io *lsio = &io->u.ci_lseek;
+
+	if (rc != 0)
+		goto out;
+
+	reply = req_capsule_server_get(&req->rq_pill, &RMF_OST_BODY);
+	if (!reply) {
+		rc = -EPROTO;
+		goto out;
+	}
+
+	lsio->ls_result = reply->oa.o_size;
+out:
+	osc_async_upcall(&oio->oi_cbarg, rc);
+	return rc;
+}
+
+int osc_io_lseek_start(const struct lu_env *env,
+		       const struct cl_io_slice *slice)
+{
+	struct cl_io *io = slice->cis_io;
+	struct osc_io *oio = cl2osc_io(env, slice);
+	struct cl_object *obj = slice->cis_obj;
+	struct lov_oinfo *loi = cl2osc(obj)->oo_oinfo;
+	struct cl_lseek_io *lsio = &io->u.ci_lseek;
+	struct obdo *oa = &oio->oi_oa;
+	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
+	struct obd_export *exp = osc_export(cl2osc(obj));
+	struct ptlrpc_request *req;
+	struct ost_body *body;
+	struct osc_lseek_args *lsa;
+	int rc = 0;
+
+	/* No negative values at this point */
+	LASSERT(lsio->ls_start >= 0);
+	LASSERT(lsio->ls_whence == SEEK_HOLE || lsio->ls_whence == SEEK_DATA);
+
+	/* with IO lock taken we have object size in LVB and can check
+	 * boundaries prior sending LSEEK RPC
+	 */
+	if (lsio->ls_start >= loi->loi_lvb.lvb_size) {
+		/* consider area beyond end of object as hole */
+		if (lsio->ls_whence == SEEK_HOLE)
+			lsio->ls_result = lsio->ls_start;
+		else
+			lsio->ls_result = -ENXIO;
+		return 0;
+	}
+
+	/* if LSEEK RPC is not supported by server, consider whole stripe
+	 * object is data with hole after end of object
+	 */
+	if (!exp_connect_lseek(exp)) {
+		if (lsio->ls_whence == SEEK_HOLE)
+			lsio->ls_result = loi->loi_lvb.lvb_size;
+		else
+			lsio->ls_result = lsio->ls_start;
+		return 0;
+	}
+
+	memset(oa, 0, sizeof(*oa));
+	oa->o_oi = loi->loi_oi;
+	oa->o_valid = OBD_MD_FLID | OBD_MD_FLGROUP;
+	oa->o_size = lsio->ls_start;
+	oa->o_mode = lsio->ls_whence;
+	if (oio->oi_lockless) {
+		oa->o_flags = OBD_FL_SRVLOCK;
+		oa->o_valid |= OBD_MD_FLFLAGS;
+	}
+
+	init_completion(&cbargs->opc_sync);
+	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_SEEK);
+	if (!req)
+		return -ENOMEM;
+
+	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_SEEK);
+	if (rc < 0) {
+		ptlrpc_request_free(req);
+		return rc;
+	}
+
+	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
+	lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa, oa);
+	ptlrpc_request_set_replen(req);
+	req->rq_interpret_reply = osc_lseek_interpret;
+	lsa = ptlrpc_req_async_args(lsa, req);
+	lsa->lsa_oio = oio;
+
+	ptlrpcd_add_req(req);
+	cbargs->opc_rpc_sent = 1;
+
+	return 0;
+}
+EXPORT_SYMBOL(osc_io_lseek_start);
+
+void osc_io_lseek_end(const struct lu_env *env,
+		      const struct cl_io_slice *slice)
+{
+	struct osc_io *oio = cl2osc_io(env, slice);
+	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
+	int rc = 0;
+
+	if (cbargs->opc_rpc_sent) {
+		wait_for_completion(&cbargs->opc_sync);
+		rc = cbargs->opc_rc;
+	}
+	slice->cis_io->ci_result = rc;
+}
+EXPORT_SYMBOL(osc_io_lseek_end);
+
 static const struct cl_io_operations osc_io_ops = {
 	.op = {
 		[CIT_READ] = {
@@ -1084,6 +1206,11 @@ void osc_io_end(const struct lu_env *env, const struct cl_io_slice *slice)
 			.cio_end	= osc_io_ladvise_end,
 			.cio_fini	= osc_io_fini
 		},
+		[CIT_LSEEK] = {
+			.cio_start	= osc_io_lseek_start,
+			.cio_end	= osc_io_lseek_end,
+			.cio_fini	= osc_io_fini
+		},
 		[CIT_MISC] = {
 			.cio_fini	= osc_io_fini
 		}
-- 
1.8.3.1
