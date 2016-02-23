From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:34 -0500
Subject: [lustre-devel] [PATCH 56/56] staging/lustre: Fix indentation
	mistakes
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-57-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

none look like bugs or bugs-inducing, mostly just
off by a couple of spaces all around.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lprocfs_status.h |  2 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |  8 ++--
 .../lustre/lustre/include/lustre/lustre_user.h     |  2 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |  2 +-
 drivers/staging/lustre/lustre/llite/rw.c           |  4 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |  2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  8 ++--
 drivers/staging/lustre/lustre/lov/lov_pool.c       |  2 +-
 drivers/staging/lustre/lustre/obdclass/cl_io.c     | 45 +++++++++++-----------
 .../lustre/lustre/obdclass/lprocfs_status.c        |  2 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |  2 +-
 drivers/staging/lustre/lustre/osc/lproc_osc.c      |  4 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  2 +-
 13 files changed, 42 insertions(+), 43 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index eb693a1..0d98111 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -276,7 +276,7 @@ static inline int opcode_offset(__u32 opc)
 			OPC_RANGE(OST));
 	} else if (opc < FLD_LAST_OPC) {
 		/* FLD opcode */
-		 return (opc - FLD_FIRST_OPC +
+		return (opc - FLD_FIRST_OPC +
 			OPC_RANGE(SEC) +
 			OPC_RANGE(SEQ) +
 			OPC_RANGE(QUOTA) +
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index e32163b..284affb 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -700,9 +700,9 @@ static inline int ostid_to_fid(struct lu_fid *fid, struct ost_id *ostid,
 		 * of 1M objects/s/OST for 9 years, or combinations thereof.
 		 */
 		if (ostid_id(ostid) >= IDIF_MAX_OID) {
-			 CERROR("bad MDT0 id, "DOSTID" ost_idx:%u\n",
-				POSTID(ostid), ost_idx);
-			 return -EBADF;
+			CERROR("bad MDT0 id, " DOSTID " ost_idx:%u\n",
+			       POSTID(ostid), ost_idx);
+			return -EBADF;
 		}
 		fid->f_seq = fid_idif_seq(ostid_id(ostid), ost_idx);
 		/* truncate to 32 bits by assignment */
@@ -3154,7 +3154,7 @@ static inline void lustre_get_wire_obdo(struct obd_connect_data *ocd,
 	__u32 local_flags = 0;
 
 	if (lobdo->o_valid & OBD_MD_FLFLAGS)
-		 local_flags = lobdo->o_flags & OBD_FL_LOCAL_MASK;
+		local_flags = lobdo->o_flags & OBD_FL_LOCAL_MASK;
 
 	*lobdo = *wobdo;
 	if (local_flags != 0) {
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 60c40ca..2e9f025 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -473,7 +473,7 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 	buf[buflen - 1] = '\0';
 	p = strrchr(buf, '-');
 	if (p)
-	   *p = '\0';
+		*p = '\0';
 }
 
 /* printf display format
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index d8c39fb..31abdb7f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -119,7 +119,7 @@ ll_fault_io_init(struct vm_area_struct *vma, struct lu_env **env_ret,
 	 */
 	env = cl_env_nested_get(nest);
 	if (IS_ERR(env))
-		 return ERR_PTR(-EINVAL);
+		return ERR_PTR(-EINVAL);
 
 	*env_ret = env;
 
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index d685c8f..0e5bd4f 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -381,9 +381,9 @@ static int index_in_window(unsigned long index, unsigned long point,
 	unsigned long start = point - before, end = point + after;
 
 	if (start > point)
-	       start = 0;
+		start = 0;
 	if (end < point)
-	       end = ~0;
+		end = ~0;
 
 	return start <= index && index <= end;
 }
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 89fd513..b0f7ffa 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -248,7 +248,7 @@ ssize_t ll_direct_rw_pages(const struct lu_env *env, struct cl_io *io,
 	cl_2queue_init(queue);
 	for (i = 0; i < page_count; i++) {
 		if (pv->ldp_offsets)
-		    file_offset = pv->ldp_offsets[i];
+			file_offset = pv->ldp_offsets[i];
 
 		LASSERT(!(file_offset & (page_size - 1)));
 		clp = cl_page_find(env, obj, cl_index(obj, file_offset),
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index b1ac13a..6122d16 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -779,9 +779,9 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 
 	if (desc->ld_magic != LOV_DESC_MAGIC) {
 		if (desc->ld_magic == __swab32(LOV_DESC_MAGIC)) {
-			    CDEBUG(D_OTHER, "%s: Swabbing lov desc %p\n",
-				   obd->obd_name, desc);
-			    lustre_swab_lov_desc(desc);
+			CDEBUG(D_OTHER, "%s: Swabbing lov desc %p\n",
+			       obd->obd_name, desc);
+			lustre_swab_lov_desc(desc);
 		} else {
 			CERROR("%s: Bad lov desc magic: %#x\n",
 			       obd->obd_name, desc->ld_magic);
@@ -1051,7 +1051,7 @@ static int lov_create(const struct lu_env *env, struct obd_export *exp,
 	/* Recreate a specific object id at the given OST index */
 	if ((src_oa->o_valid & OBD_MD_FLFLAGS) &&
 	    (src_oa->o_flags & OBD_FL_RECREATE_OBJS)) {
-		 rc = lov_recreate(exp, src_oa, ea, oti);
+		rc = lov_recreate(exp, src_oa, ea, oti);
 	}
 
 	obd_putref(exp->exp_obd);
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 14e920b..210304f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -228,7 +228,7 @@ static void *pool_proc_start(struct seq_file *s, loff_t *pos)
 
 		i = 0;
 		do {
-		     ptr = pool_proc_next(s, &iter, &i);
+			ptr = pool_proc_next(s, &iter, &i);
 		} while ((i < *pos) && ptr);
 		return ptr;
 	}
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 8cc7aa1..191ec43 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -329,32 +329,31 @@ static void cl_io_locks_sort(struct cl_io *io)
 int cl_queue_match(const struct list_head *queue,
 		   const struct cl_lock_descr *need)
 {
-       struct cl_io_lock_link *scan;
+	struct cl_io_lock_link *scan;
 
-       list_for_each_entry(scan, queue, cill_linkage) {
-	       if (cl_lock_descr_match(&scan->cill_descr, need))
-		       return 1;
-       }
-       return 0;
+	list_for_each_entry(scan, queue, cill_linkage) {
+		if (cl_lock_descr_match(&scan->cill_descr, need))
+			return 1;
+	}
+	return 0;
 }
 EXPORT_SYMBOL(cl_queue_match);
 
 static int cl_queue_merge(const struct list_head *queue,
 			  const struct cl_lock_descr *need)
 {
-       struct cl_io_lock_link *scan;
-
-       list_for_each_entry(scan, queue, cill_linkage) {
-	       if (cl_lock_descr_cmp(&scan->cill_descr, need))
-		       continue;
-	       cl_lock_descr_merge(&scan->cill_descr, need);
-	       CDEBUG(D_VFSTRACE, "lock: %d: [%lu, %lu]\n",
-		      scan->cill_descr.cld_mode, scan->cill_descr.cld_start,
-		      scan->cill_descr.cld_end);
-	       return 1;
-       }
-       return 0;
+	struct cl_io_lock_link *scan;
 
+	list_for_each_entry(scan, queue, cill_linkage) {
+		if (cl_lock_descr_cmp(&scan->cill_descr, need))
+			continue;
+		cl_lock_descr_merge(&scan->cill_descr, need);
+		CDEBUG(D_VFSTRACE, "lock: %d: [%lu, %lu]\n",
+		       scan->cill_descr.cld_mode, scan->cill_descr.cld_start,
+		       scan->cill_descr.cld_end);
+		return 1;
+	}
+	return 0;
 }
 
 static int cl_lockset_match(const struct cl_lockset *set,
@@ -916,14 +915,14 @@ int cl_io_submit_sync(const struct lu_env *env, struct cl_io *io,
 		 * clean pages), count them as completed to avoid infinite
 		 * wait.
 		 */
-		 cl_page_list_for_each(pg, &queue->c2_qin) {
+		cl_page_list_for_each(pg, &queue->c2_qin) {
 			pg->cp_sync_io = NULL;
 			cl_sync_io_note(anchor, 1);
-		 }
+		}
 
-		 /* wait for the IO to be finished. */
-		 rc = cl_sync_io_wait(env, io, &queue->c2_qout,
-				      anchor, timeout);
+		/* wait for the IO to be finished. */
+		rc = cl_sync_io_wait(env, io, &queue->c2_qout,
+				     anchor, timeout);
 	} else {
 		LASSERT(list_empty(&queue->c2_qout.pl_pages));
 		cl_page_list_for_each(pg, &queue->c2_qin)
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 16b1c70..28bb4e5 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -577,7 +577,7 @@ EXPORT_SYMBOL(lprocfs_stats_collect);
 #define flag2str(flag, first)						\
 	do {								\
 		if (imp->imp_##flag)					\
-		     seq_printf(m, "%s" #flag, first ? "" : ", ");	\
+			seq_printf(m, "%s" #flag, first ? "" : ", ");	\
 	} while (0)
 static int obd_import_flags2str(struct obd_import *imp, struct seq_file *m)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 885f266..2134b60 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1038,7 +1038,7 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 			 * can pass it down the stack
 			 */
 			if (strnchr(key, keylen, '.'))
-			    return -ENOSYS;
+				return -ENOSYS;
 			CERROR("%s: unknown param %s\n",
 			       (char *)lustre_cfg_string(lcfg, 0), key);
 			/* rc = -EINVAL;	continue parsing other params */
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index cb9edaf..b5df5e6 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -422,8 +422,8 @@ static ssize_t osc_checksum_type_seq_write(struct file *file,
 		if (((1 << i) & obd->u.cli.cl_supp_cksum_types) == 0)
 			continue;
 		if (!strcmp(kernbuf, cksum_name[i])) {
-		       obd->u.cli.cl_cksum_type = 1 << i;
-		       return count;
+			obd->u.cli.cl_cksum_type = 1 << i;
+			return count;
 		}
 	}
 	return -EINVAL;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 6f0c4e0..53668e2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2435,7 +2435,7 @@ static int osc_statfs_interpret(const struct lu_env *env,
 		 * aware of the problem and takes care
 		 * of the clean up
 		 */
-		 return rc;
+		return rc;
 
 	if ((rc == -ENOTCONN || rc == -EAGAIN) &&
 	    (aa->aa_oi->oi_flags & OBD_STATFS_NODELAY)) {
-- 
2.1.0
