From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:52:16 -0400
Subject: [lustre-devel] [PATCH 09/11] lustre: obdclass: checkpatch cleanup
In-Reply-To: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
References: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563760338-806-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Many checkpatch errors exist in the obdclass layer. This address
a good chuck of them. Other are left since future patches will
cleanup those areas. Others will need more code rework so this
patch handles the simple cases. This is a good step forward
toward proper kernel code style compliance.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/cl_io.c          | 16 +++++++++++-----
 fs/lustre/obdclass/cl_lock.c        |  8 ++++++--
 fs/lustre/obdclass/cl_object.c      | 12 ++++++------
 fs/lustre/obdclass/cl_page.c        |  9 +++++----
 fs/lustre/obdclass/class_obd.c      |  3 ++-
 fs/lustre/obdclass/genops.c         |  9 ++++++---
 fs/lustre/obdclass/llog.c           |  3 ++-
 fs/lustre/obdclass/llog_obd.c       |  8 ++++----
 fs/lustre/obdclass/llog_swab.c      |  6 ++++--
 fs/lustre/obdclass/lprocfs_status.c |  4 ++--
 fs/lustre/obdclass/lu_object.c      |  3 ++-
 fs/lustre/obdclass/obd_config.c     | 12 ++++++++----
 fs/lustre/obdclass/obd_mount.c      |  3 ++-
 fs/lustre/obdecho/debug.c           | 12 ++++++++----
 14 files changed, 68 insertions(+), 40 deletions(-)

diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index eef0dd8..1f1579b 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -217,11 +217,16 @@ int cl_io_rw_init(const struct lu_env *env, struct cl_io *io,
 static int cl_lock_descr_cmp(void *priv,
 			     struct list_head *a, struct list_head *b)
 {
-	const struct cl_io_lock_link *l0 = list_entry(a, struct cl_io_lock_link, cill_linkage);
-	const struct cl_io_lock_link *l1 = list_entry(b, struct cl_io_lock_link, cill_linkage);
+	const struct cl_io_lock_link *l0;
+	const struct cl_io_lock_link *l1;
+	const struct cl_lock_descr *d0;
+	const struct cl_lock_descr *d1;
 
-	const struct cl_lock_descr *d0 = &l0->cill_descr;
-	const struct cl_lock_descr *d1 = &l1->cill_descr;
+	l0 = list_entry(a, struct cl_io_lock_link, cill_linkage);
+	l1 = list_entry(b, struct cl_io_lock_link, cill_linkage);
+
+	d0 = &l0->cill_descr;
+	d1 = &l1->cill_descr;
 
 	return lu_fid_cmp(lu_object_fid(&d0->cld_obj->co_lu),
 			  lu_object_fid(&d1->cld_obj->co_lu));
@@ -334,7 +339,8 @@ void cl_io_unlock(const struct lu_env *env, struct cl_io *io)
 	const struct cl_io_slice *scan;
 
 	LASSERT(cl_io_is_loopable(io));
-	LASSERT(CIS_IT_STARTED <= io->ci_state && io->ci_state < CIS_UNLOCKED);
+	LASSERT(CIS_IT_STARTED <= io->ci_state &&
+		io->ci_state < CIS_UNLOCKED);
 	LINVRNT(cl_io_invariant(io));
 
 	set = &io->ci_lockset;
diff --git a/fs/lustre/obdclass/cl_lock.c b/fs/lustre/obdclass/cl_lock.c
index 797302c..af88383 100644
--- a/fs/lustre/obdclass/cl_lock.c
+++ b/fs/lustre/obdclass/cl_lock.c
@@ -80,6 +80,7 @@ void cl_lock_slice_add(struct cl_lock *lock, struct cl_lock_slice *slice,
 void cl_lock_fini(const struct lu_env *env, struct cl_lock *lock)
 {
 	struct cl_lock_slice *slice;
+
 	cl_lock_trace(D_DLMTRACE, env, "destroy lock", lock);
 
 	while ((slice = list_first_entry_or_null(&lock->cll_layers,
@@ -158,7 +159,7 @@ int cl_lock_enqueue(const struct lu_env *env, struct cl_io *io,
 		    struct cl_lock *lock, struct cl_sync_io *anchor)
 {
 	const struct cl_lock_slice *slice;
-	int rc = -ENOSYS;
+	int rc = -EBUSY;
 
 	list_for_each_entry(slice, &lock->cll_layers, cls_linkage) {
 		if (!slice->cls_ops->clo_enqueue)
@@ -246,7 +247,10 @@ void cl_lock_descr_print(const struct lu_env *env, void *cookie,
 	const struct lu_fid *fid;
 
 	fid = lu_object_fid(&descr->cld_obj->co_lu);
-	(*printer)(env, cookie, DDESCR "@" DFID, PDESCR(descr), PFID(fid));
+	(*printer)(env, cookie, DDESCR "@" DFID,
+		   cl_lock_mode_name(descr->cld_mode), descr->cld_mode,
+		   descr->cld_start, descr->cld_end, descr->cld_enq_flags,
+		   PFID(fid));
 }
 EXPORT_SYMBOL(cl_lock_descr_print);
 
diff --git a/fs/lustre/obdclass/cl_object.c b/fs/lustre/obdclass/cl_object.c
index 6c084bc..b4ea585 100644
--- a/fs/lustre/obdclass/cl_object.c
+++ b/fs/lustre/obdclass/cl_object.c
@@ -427,7 +427,7 @@ static int cache_stats_print(const struct cache_stats *cs,
 		seq_printf(m, "%6s", " ");
 		for (i = 0; i < CS_NR; i++)
 			seq_printf(m, "%8s", names[i]);
-		seq_printf(m, "\n");
+		seq_puts(m, "\n");
 	}
 
 	seq_printf(m, "%5.5s:", cs->cs_name);
@@ -489,10 +489,10 @@ int cl_site_stats_print(const struct cl_site *site, struct seq_file *m)
 		[CPS_FREEING]	= "f"
 	};
 /*
-       lookup    hit  total   busy create
-pages: ...... ...... ...... ...... ...... [...... ...... ...... ......]
-locks: ...... ...... ...... ...... ...... [...... ...... ...... ...... ......]
-  env: ...... ...... ...... ...... ......
+ *	lookup    hit  total   busy create
+ * pages: ...... ...... ...... ...... ...... [..... ..... ..... .....]
+ * locks: ...... ...... ...... ...... ...... [..... ..... ..... ..... .....]
+ * env:   ...... ...... ...... ...... ......
  */
 	lu_site_stats_print(&site->cs_lu, m);
 	cache_stats_print(&site->cs_pages, m, 1);
@@ -722,7 +722,7 @@ unsigned int cl_env_cache_purge(unsigned int nr)
 
 	for_each_possible_cpu(i) {
 		write_lock(&cl_envs[i].cec_guard);
-		for (; nr >0 &&
+		for (; nr > 0 &&
 			     (cle = list_first_entry_or_null(
 				     &cl_envs[i].cec_envs,
 				     struct cl_env,
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 349f19e..163f4de 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -148,8 +148,8 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
 		lu_ref_init(&page->cp_reference);
 		cl_object_for_each(o2, o) {
 			if (o2->co_ops->coo_page_init) {
-				result = o2->co_ops->coo_page_init(env, o2, page,
-								   ind);
+				result = o2->co_ops->coo_page_init(env, o2,
+								   page, ind);
 				if (result != 0) {
 					__cl_page_delete(env, page);
 					cl_page_free(env, page);
@@ -418,8 +418,9 @@ int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io)
  * Return:	0 success
  *
  *		-ve failure, e.g., page was destroyed (and landed in
- *		cl_page_state::CPS_FREEING instead of cl_page_state::CPS_CACHED).
- *		or, page was owned by another thread, or in IO.
+ *		cl_page_state::CPS_FREEING instead of
+ *		cl_page_state::CPS_CACHED). or, page was owned by
+ *		another thread, or in IO.
  *
  * \see cl_page_disown()
  * \see cl_page_operations::cpo_own()
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index b8fc740..d8fc0db 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -364,7 +364,8 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 		 * Today that information is in the sysfs tree so we can in the
 		 * future remove this.
 		 */
-		BUILD_BUG_ON(OBD_OCD_VERSION(3, 0, 53, 0) <= LUSTRE_VERSION_CODE);
+		BUILD_BUG_ON(OBD_OCD_VERSION(3, 0, 53, 0) <=
+			     LUSTRE_VERSION_CODE);
 
 		if (!data->ioc_inlbuf1) {
 			CERROR("No buffer passed in ioctl\n");
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 2d12717..9a9de35 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -74,7 +74,8 @@ static struct obd_device *obd_device_alloc(void)
 
 static void obd_device_free(struct obd_device *obd)
 {
-	LASSERTF(obd->obd_magic == OBD_DEVICE_MAGIC, "obd %p obd_magic %08x != %08x\n",
+	LASSERTF(obd->obd_magic == OBD_DEVICE_MAGIC,
+		 "obd %p obd_magic %08x != %08x\n",
 		 obd, obd->obd_magic, OBD_DEVICE_MAGIC);
 	if (obd->obd_namespace) {
 		CERROR("obd %p: namespace %p was not properly cleaned up (obd_force=%d)!\n",
@@ -801,7 +802,8 @@ void class_export_put(struct obd_export *exp)
 
 static void obd_zombie_exp_cull(struct work_struct *ws)
 {
-	struct obd_export *export = container_of(ws, struct obd_export, exp_zombie_work);
+	struct obd_export *export = container_of(ws, struct obd_export,
+						 exp_zombie_work);
 
 	class_export_destroy(export);
 }
@@ -998,7 +1000,8 @@ static void init_imp_at(struct imp_at *at)
 
 static void obd_zombie_imp_cull(struct work_struct *ws)
 {
-	struct obd_import *import = container_of(ws, struct obd_import, imp_zombie_work);
+	struct obd_import *import = container_of(ws, struct obd_import,
+						 imp_zombie_work);
 
 	class_import_destroy(import);
 }
diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index a34b1a7..e9a6514 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -327,7 +327,8 @@ static int llog_process_thread(void *arg)
 					rc = 0;
 					goto out;
 				}
-				CDEBUG(D_OTHER, "Re-read last llog buffer for new records, index %u, last %u\n",
+				CDEBUG(D_OTHER,
+				       "Re-read last llog buffer for new records, index %u, last %u\n",
 				       index, loghandle->lgh_last_idx);
 				/* save offset inside buffer for the re-read */
 				buf_offset = (char *)rec - (char *)buf;
diff --git a/fs/lustre/obdclass/llog_obd.c b/fs/lustre/obdclass/llog_obd.c
index a89ec81..f652eed 100644
--- a/fs/lustre/obdclass/llog_obd.c
+++ b/fs/lustre/obdclass/llog_obd.c
@@ -127,7 +127,7 @@ int llog_cleanup(const struct lu_env *env, struct llog_ctxt *ctxt)
 		       rc, ctxt);
 
 	l_wait_event_abortable(olg->olg_waitq,
-			     llog_group_ctxt_null(olg, idx));
+			       llog_group_ctxt_null(olg, idx));
 
 	return rc;
 }
@@ -165,9 +165,9 @@ int llog_setup(const struct lu_env *env, struct obd_device *obd,
 			ctxt = llog_group_get_ctxt(olg, index);
 			if (ctxt) {
 				/*
-				 * mds_lov_update_desc() might call here multiple
-				 * times. So if the llog is already set up then
-				 * don't to do it again.
+				 * mds_lov_update_desc() might call here
+				 * multiple times. So if the llog is already
+				 * set up then don't to do it again.
 				 */
 				CDEBUG(D_CONFIG, "obd %s ctxt %d already set up\n",
 				       obd->obd_name, index);
diff --git a/fs/lustre/obdclass/llog_swab.c b/fs/lustre/obdclass/llog_swab.c
index 57dadec..49024fd 100644
--- a/fs/lustre/obdclass/llog_swab.c
+++ b/fs/lustre/obdclass/llog_swab.c
@@ -321,7 +321,8 @@ void print_lustre_cfg(struct lustre_cfg *lcfg)
 	CDEBUG(D_OTHER, "\tlcfg->lcfg_command: %#x\n", lcfg->lcfg_command);
 	CDEBUG(D_OTHER, "\tlcfg->lcfg_num: %#x\n", lcfg->lcfg_num);
 	CDEBUG(D_OTHER, "\tlcfg->lcfg_flags: %#x\n", lcfg->lcfg_flags);
-	CDEBUG(D_OTHER, "\tlcfg->lcfg_nid: %s\n", libcfs_nid2str(lcfg->lcfg_nid));
+	CDEBUG(D_OTHER, "\tlcfg->lcfg_nid: %s\n",
+	       libcfs_nid2str(lcfg->lcfg_nid));
 
 	CDEBUG(D_OTHER, "\tlcfg->lcfg_bufcount: %d\n", lcfg->lcfg_bufcount);
 	if (lcfg->lcfg_bufcount < LUSTRE_CFG_MAX_BUFCOUNT)
@@ -407,7 +408,8 @@ void lustre_swab_cfg_marker(struct cfg_marker *marker, int swab, int size)
 		}
 		marker->cm_createtime = createtime;
 		marker->cm_canceltime = canceltime;
-		CDEBUG(D_CONFIG, "Find old cfg_marker(Srv32b,Clt64b) for target %s, converting\n",
+		CDEBUG(D_CONFIG,
+		       "Find old cfg_marker(Srv32b,Clt64b) for target %s, converting\n",
 		       marker->cm_tgtname);
 	} else if (swab) {
 		__swab64s(&marker->cm_createtime);
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 71bf409..c5f5807 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -330,7 +330,6 @@ void ldebugfs_add_vars(struct dentry *parent, struct lprocfs_vars *list,
 				    list->fops ?: &lprocfs_generic_fops);
 		list++;
 	}
-	return;
 }
 EXPORT_SYMBOL_GPL(ldebugfs_add_vars);
 
@@ -558,7 +557,8 @@ int lprocfs_rd_conn_uuid(struct seq_file *m, void *data)
  * @flags:	CPU interrupt saved state for IRQ-safe locking
  *
  * Returns:	cpuid of current thread or number of allocated structs
- *		negative on error (only for opc LPROCFS_GET_SMP_ID + per-CPU stats)
+ *		negative on error (only for opc LPROCFS_GET_SMP_ID +
+ *				   per-CPU stats)
  */
 int lprocfs_stats_lock(struct lprocfs_stats *stats,
 		       enum lprocfs_stats_lock_ops opc,
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index 6f778eb..4302482 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -498,7 +498,8 @@ struct lu_cdebug_data {
 	.lct_tags	= LCT_MD_THREAD | LCT_DT_THREAD |
 			  LCT_MG_THREAD | LCT_CL_THREAD | LCT_LOCAL,
 	.lct_init	= lu_global_key_init,
-	.lct_fini	= lu_global_key_fini
+	.lct_fini	= lu_global_key_fini,
+	.lct_owner	= THIS_MODULE,
 };
 
 /**
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 0cdadea4..73264fd 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -509,7 +509,8 @@ static int class_cleanup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		       obd->obd_name, err);
 
 	/* destroy an uuid-export hash body */
-	rhashtable_free_and_destroy(&obd->obd_uuid_hash, uuid_export_exit, NULL);
+	rhashtable_free_and_destroy(&obd->obd_uuid_hash, uuid_export_exit,
+				    NULL);
 
 	class_decref(obd, "setup", obd);
 	obd->obd_set_up = 0;
@@ -831,11 +832,13 @@ int class_process_config(struct lustre_cfg *lcfg)
 		goto out;
 	}
 	case LCFG_ADD_UUID: {
-		CDEBUG(D_IOCTL, "adding mapping from uuid %s to nid %#llx (%s)\n",
+		CDEBUG(D_IOCTL,
+		       "adding mapping from uuid %s to nid %#llx (%s)\n",
 		       lustre_cfg_string(lcfg, 1), lcfg->lcfg_nid,
 		       libcfs_nid2str(lcfg->lcfg_nid));
 
-		err = class_add_uuid(lustre_cfg_string(lcfg, 1), lcfg->lcfg_nid);
+		err = class_add_uuid(lustre_cfg_string(lcfg, 1),
+				     lcfg->lcfg_nid);
 		goto out;
 	}
 	case LCFG_DEL_UUID: {
@@ -893,7 +896,8 @@ int class_process_config(struct lustre_cfg *lcfg)
 
 		marker = lustre_cfg_buf(lcfg, 1);
 		CDEBUG(D_IOCTL, "marker %d (%#x) %.16s %s\n", marker->cm_step,
-		       marker->cm_flags, marker->cm_tgtname, marker->cm_comment);
+		       marker->cm_flags, marker->cm_tgtname,
+		       marker->cm_comment);
 		err = 0;
 		goto out;
 	}
diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index 104e64b..de81baa 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -1187,7 +1187,8 @@ int lmd_parse(char *options, struct lustre_mount_data *lmd)
 	}
 
 	if (!devname) {
-		LCONSOLE_ERROR_MSG(0x164, "Can't find the device name (need mount option 'device=...')\n");
+		LCONSOLE_ERROR_MSG(0x164,
+				   "Can't find the device name (need mount option 'device=...')\n");
 		goto invalid;
 	}
 
diff --git a/fs/lustre/obdecho/debug.c b/fs/lustre/obdecho/debug.c
index 149aca5..a8f773a 100644
--- a/fs/lustre/obdecho/debug.c
+++ b/fs/lustre/obdecho/debug.c
@@ -68,24 +68,28 @@ int block_debug_check(char *who, void *addr, int end, u64 off, u64 id)
 	ne_off = le64_to_cpu(off);
 	id = le64_to_cpu(id);
 	if (memcmp(addr, (char *)&ne_off, LPDS)) {
-		CDEBUG(D_ERROR, "%s: id %#llx offset %llu off: %#llx != %#llx\n",
+		CDEBUG(D_ERROR,
+		       "%s: id %#llx offset %llu off: %#llx != %#llx\n",
 		       who, id, off, *(u64 *)addr, ne_off);
 		err = -EINVAL;
 	}
 	if (memcmp(addr + LPDS, (char *)&id, LPDS)) {
-		CDEBUG(D_ERROR, "%s: id %#llx offset %llu id: %#llx != %#llx\n",
+		CDEBUG(D_ERROR,
+		       "%s: id %#llx offset %llu id: %#llx != %#llx\n",
 		       who, id, off, *(u64 *)(addr + LPDS), id);
 		err = -EINVAL;
 	}
 
 	addr += end - LPDS - LPDS;
 	if (memcmp(addr, (char *)&ne_off, LPDS)) {
-		CDEBUG(D_ERROR, "%s: id %#llx offset %llu end off: %#llx != %#llx\n",
+		CDEBUG(D_ERROR,
+		       "%s: id %#llx offset %llu end off: %#llx != %#llx\n",
 		       who, id, off, *(u64 *)addr, ne_off);
 		err = -EINVAL;
 	}
 	if (memcmp(addr + LPDS, (char *)&id, LPDS)) {
-		CDEBUG(D_ERROR, "%s: id %#llx offset %llu end id: %#llx != %#llx\n",
+		CDEBUG(D_ERROR,
+		       "%s: id %#llx offset %llu end id: %#llx != %#llx\n",
 		       who, id, off, *(u64 *)(addr + LPDS), id);
 		err = -EINVAL;
 	}
-- 
1.8.3.1
