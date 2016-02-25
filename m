From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:58 -0500
Subject: [lustre-devel] [PATCH v2 75/84] staging/lustre/obdclass: Fix style
	vs open parenthesis alignment
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-76-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This mostly fixes checkpatch complaints about
"Alignment should match open parenthesis"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |  20 ++--
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |  21 ++--
 drivers/staging/lustre/lustre/obdclass/cl_object.c |  10 +-
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |  10 +-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |   3 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    |  26 ++---
 .../lustre/lustre/obdclass/linux/linux-sysctl.c    |   8 +-
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  |   4 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        | 125 ++++++++++-----------
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   3 +-
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |   2 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    |   6 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   8 +-
 13 files changed, 119 insertions(+), 127 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 191ec43..f5128b4 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -139,7 +139,7 @@ void cl_io_fini(const struct lu_env *env, struct cl_io *io)
 	case CIT_MISC:
 		/* Check ignore layout change conf */
 		LASSERT(ergo(io->ci_ignore_layout || !io->ci_verify_layout,
-				!io->ci_need_restart));
+			     !io->ci_need_restart));
 		break;
 	default:
 		LBUG();
@@ -291,11 +291,11 @@ static void cl_io_locks_sort(struct cl_io *io)
 		prev = NULL;
 
 		list_for_each_entry_safe(curr, temp,
-					     &io->ci_lockset.cls_todo,
-					     cill_linkage) {
+					 &io->ci_lockset.cls_todo,
+					 cill_linkage) {
 			if (prev) {
 				switch (cl_lock_descr_sort(&prev->cill_descr,
-							  &curr->cill_descr)) {
+							   &curr->cill_descr)) {
 				case 0:
 					/*
 					 * IMPOSSIBLE: Identical locks are
@@ -306,7 +306,7 @@ static void cl_io_locks_sort(struct cl_io *io)
 					LBUG();
 				case 1:
 					list_move_tail(&curr->cill_linkage,
-							   &prev->cill_linkage);
+						       &prev->cill_linkage);
 					done = 0;
 					continue; /* don't change prev: it's
 						   * still "previous"
@@ -385,8 +385,7 @@ static int cl_lockset_lock_one(const struct lu_env *env,
 		if (!(link->cill_descr.cld_enq_flags & CEF_ASYNC)) {
 			result = cl_wait(env, lock);
 			if (result == 0)
-				list_move(&link->cill_linkage,
-					      &set->cls_done);
+				list_move(&link->cill_linkage, &set->cls_done);
 		} else
 			result = 0;
 	} else
@@ -430,12 +429,11 @@ static int cl_lockset_lock(const struct lu_env *env, struct cl_io *io,
 	}
 	if (result == 0) {
 		list_for_each_entry_safe(link, temp,
-					     &set->cls_curr, cill_linkage) {
+					 &set->cls_curr, cill_linkage) {
 			lock = link->cill_lock;
 			result = cl_wait(env, lock);
 			if (result == 0)
-				list_move(&link->cill_linkage,
-					      &set->cls_done);
+				list_move(&link->cill_linkage, &set->cls_done);
 			else
 				break;
 		}
@@ -1354,7 +1352,7 @@ void cl_req_completion(const struct lu_env *env, struct cl_req *req, int rc)
 	 */
 	while (!list_empty(&req->crq_layers)) {
 		slice = list_entry(req->crq_layers.prev,
-				       struct cl_req_slice, crs_linkage);
+				   struct cl_req_slice, crs_linkage);
 		list_del_init(&slice->crs_linkage);
 		if (slice->crs_ops->cro_completion)
 			slice->crs_ops->cro_completion(env, slice, rc);
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index 7b7f344..6cf284b 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -259,7 +259,7 @@ static void cl_lock_free(const struct lu_env *env, struct cl_lock *lock)
 		struct cl_lock_slice *slice;
 
 		slice = list_entry(lock->cll_layers.next,
-				       struct cl_lock_slice, cls_linkage);
+				   struct cl_lock_slice, cls_linkage);
 		list_del_init(lock->cll_layers.next);
 		slice->cls_ops->clo_fini(env, slice);
 	}
@@ -382,8 +382,7 @@ static struct cl_lock *cl_lock_alloc(const struct lu_env *env,
 		CS_LOCK_INC(obj, total);
 		CS_LOCK_INC(obj, create);
 		cl_lock_lockdep_init(lock);
-		list_for_each_entry(obj, &head->loh_layers,
-					co_lu.lo_linkage) {
+		list_for_each_entry(obj, &head->loh_layers, co_lu.lo_linkage) {
 			int err;
 
 			err = obj->co_ops->coo_lock_init(env, obj, lock, io);
@@ -534,7 +533,7 @@ static struct cl_lock *cl_lock_find(const struct lu_env *env,
 			if (!ghost) {
 				cl_lock_get_trust(lock);
 				list_add_tail(&lock->cll_linkage,
-						  &head->coh_locks);
+					      &head->coh_locks);
 				spin_unlock(&head->coh_lock_guard);
 				CS_LOCK_INC(obj, busy);
 			} else {
@@ -774,7 +773,7 @@ static void cl_lock_cancel0(const struct lu_env *env, struct cl_lock *lock)
 
 		lock->cll_flags |= CLF_CANCELLED;
 		list_for_each_entry_reverse(slice, &lock->cll_layers,
-						cls_linkage) {
+					    cls_linkage) {
 			if (slice->cls_ops->clo_cancel)
 				slice->cls_ops->clo_cancel(env, slice);
 		}
@@ -811,7 +810,7 @@ static void cl_lock_delete0(const struct lu_env *env, struct cl_lock *lock)
 		 * by cl_lock_lookup().
 		 */
 		list_for_each_entry_reverse(slice, &lock->cll_layers,
-						cls_linkage) {
+					    cls_linkage) {
 			if (slice->cls_ops->clo_delete)
 				slice->cls_ops->clo_delete(env, slice);
 		}
@@ -1040,7 +1039,7 @@ static int cl_unuse_try_internal(const struct lu_env *env, struct cl_lock *lock)
 
 		result = -ENOSYS;
 		list_for_each_entry_reverse(slice, &lock->cll_layers,
-						cls_linkage) {
+					    cls_linkage) {
 			if (slice->cls_ops->clo_unuse) {
 				result = slice->cls_ops->clo_unuse(env, slice);
 				if (result != 0)
@@ -1658,7 +1657,7 @@ void cl_lock_disclosure(const struct lu_env *env,
 
 	cl_lock_trace(D_DLMTRACE, env, "disclosure lock", closure->clc_origin);
 	list_for_each_entry_safe(scan, temp, &closure->clc_list,
-				     cll_inclosure){
+				 cll_inclosure) {
 		list_del_init(&scan->cll_inclosure);
 		cl_lock_mutex_put(env, scan);
 		lu_ref_del(&scan->cll_reference, "closure", closure);
@@ -1845,7 +1844,7 @@ static int check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 
 		/* refresh non-overlapped index */
 		tmp = cl_lock_at_pgoff(env, lock->cll_descr.cld_obj, index,
-					lock, 1, 0);
+				       lock, 1, 0);
 		if (tmp) {
 			/* Cache the first-non-overlapped index so as to skip
 			 * all pages within [index, clt_fn_index). This
@@ -2173,8 +2172,8 @@ EXPORT_SYMBOL(cl_lock_mode_name);
  * Prints human readable representation of a lock description.
  */
 void cl_lock_descr_print(const struct lu_env *env, void *cookie,
-		       lu_printer_t printer,
-		       const struct cl_lock_descr *descr)
+			 lu_printer_t printer,
+			 const struct cl_lock_descr *descr)
 {
 	const struct lu_fid  *fid;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index b626914..e7c570a 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -247,8 +247,7 @@ int cl_object_attr_set(const struct lu_env *env, struct cl_object *obj,
 
 	top = obj->co_lu.lo_header;
 	result = 0;
-	list_for_each_entry_reverse(obj, &top->loh_layers,
-					co_lu.lo_linkage) {
+	list_for_each_entry_reverse(obj, &top->loh_layers, co_lu.lo_linkage) {
 		if (obj->co_ops->coo_attr_set) {
 			result = obj->co_ops->coo_attr_set(env, obj, attr, v);
 			if (result != 0) {
@@ -278,8 +277,7 @@ int cl_object_glimpse(const struct lu_env *env, struct cl_object *obj,
 
 	top = obj->co_lu.lo_header;
 	result = 0;
-	list_for_each_entry_reverse(obj, &top->loh_layers,
-					co_lu.lo_linkage) {
+	list_for_each_entry_reverse(obj, &top->loh_layers, co_lu.lo_linkage) {
 		if (obj->co_ops->coo_glimpse) {
 			result = obj->co_ops->coo_glimpse(env, obj, lvb);
 			if (result != 0)
@@ -457,13 +455,13 @@ locks: ...... ...... ...... ...... ...... [...... ...... ...... ...... ......]
 	seq_printf(m, " [");
 	for (i = 0; i < ARRAY_SIZE(site->cs_pages_state); ++i)
 		seq_printf(m, "%s: %u ", pstate[i],
-				atomic_read(&site->cs_pages_state[i]));
+			   atomic_read(&site->cs_pages_state[i]));
 	seq_printf(m, "]\n");
 	cache_stats_print(&site->cs_locks, m, 0);
 	seq_printf(m, " [");
 	for (i = 0; i < ARRAY_SIZE(site->cs_locks_state); ++i)
 		seq_printf(m, "%s: %u ", lstate[i],
-				atomic_read(&site->cs_locks_state[i]));
+			   atomic_read(&site->cs_locks_state[i]));
 	seq_printf(m, "]\n");
 	cache_stats_print(&cl_env_stats, m, 0);
 	seq_printf(m, "\n");
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 72f9924..231a2f2 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -255,7 +255,7 @@ static void cl_page_free(const struct lu_env *env, struct cl_page *page)
 		struct cl_page_slice *slice;
 
 		slice = list_entry(page->cp_layers.next,
-				       struct cl_page_slice, cpl_linkage);
+				   struct cl_page_slice, cpl_linkage);
 		list_del_init(page->cp_layers.next);
 		slice->cpl_ops->cpo_fini(env, slice);
 	}
@@ -277,8 +277,9 @@ static inline void cl_page_state_set_trust(struct cl_page *page,
 }
 
 static struct cl_page *cl_page_alloc(const struct lu_env *env,
-		struct cl_object *o, pgoff_t ind, struct page *vmpage,
-		enum cl_page_type type)
+				     struct cl_object *o, pgoff_t ind,
+				     struct page *vmpage,
+				     enum cl_page_type type)
 {
 	struct cl_page	  *page;
 	struct lu_object_header *head;
@@ -303,8 +304,7 @@ static struct cl_page *cl_page_alloc(const struct lu_env *env,
 		mutex_init(&page->cp_mutex);
 		lu_ref_init(&page->cp_reference);
 		head = o->co_lu.lo_header;
-		list_for_each_entry(o, &head->loh_layers,
-					co_lu.lo_linkage) {
+		list_for_each_entry(o, &head->loh_layers, co_lu.lo_linkage) {
 			if (o->co_ops->coo_page_init) {
 				result = o->co_ops->coo_page_init(env, o,
 								  page, vmpage);
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index c1310c2..06b04d2 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -199,8 +199,7 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 			err = -ENOMEM;
 			goto out;
 		}
-		err = copy_from_user(lcfg, data->ioc_pbuf1,
-					 data->ioc_plen1);
+		err = copy_from_user(lcfg, data->ioc_pbuf1, data->ioc_plen1);
 		if (!err)
 			err = lustre_cfg_sanity_check(lcfg, data->ioc_plen1);
 		if (!err)
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 9042632..65f2c62 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -461,8 +461,8 @@ EXPORT_SYMBOL(class_num2obd);
  * otherwise any client connected to the tgt is returned.
  */
 struct obd_device *class_find_client_obd(struct obd_uuid *tgt_uuid,
-					  const char *typ_name,
-					  struct obd_uuid *grp_uuid)
+					 const char *typ_name,
+					 struct obd_uuid *grp_uuid)
 {
 	int i;
 
@@ -582,21 +582,21 @@ int obd_init_caches(void)
 {
 	LASSERT(!obd_device_cachep);
 	obd_device_cachep = kmem_cache_create("ll_obd_dev_cache",
-						 sizeof(struct obd_device),
-						 0, 0, NULL);
+					      sizeof(struct obd_device),
+					      0, 0, NULL);
 	if (!obd_device_cachep)
 		goto out;
 
 	LASSERT(!obdo_cachep);
 	obdo_cachep = kmem_cache_create("ll_obdo_cache", sizeof(struct obdo),
-					   0, 0, NULL);
+					0, 0, NULL);
 	if (!obdo_cachep)
 		goto out;
 
 	LASSERT(!import_cachep);
 	import_cachep = kmem_cache_create("ll_import_cache",
-					     sizeof(struct obd_import),
-					     0, 0, NULL);
+					  sizeof(struct obd_import),
+					  0, 0, NULL);
 	if (!import_cachep)
 		goto out;
 
@@ -828,7 +828,7 @@ EXPORT_SYMBOL(class_unlink_export);
 static void class_import_destroy(struct obd_import *imp)
 {
 	CDEBUG(D_IOCTL, "destroying import %p for %s\n", imp,
-		imp->imp_obd->obd_name);
+	       imp->imp_obd->obd_name);
 
 	LASSERT_ATOMIC_ZERO(&imp->imp_refcount);
 
@@ -838,7 +838,7 @@ static void class_import_destroy(struct obd_import *imp)
 		struct obd_import_conn *imp_conn;
 
 		imp_conn = list_entry(imp->imp_conn_list.next,
-					  struct obd_import_conn, oic_item);
+				      struct obd_import_conn, oic_item);
 		list_del_init(&imp_conn->oic_item);
 		ptlrpc_put_connection_superhack(imp_conn->oic_conn);
 		kfree(imp_conn);
@@ -1125,16 +1125,16 @@ static void obd_zombie_impexp_cull(void)
 		import = NULL;
 		if (!list_empty(&obd_zombie_imports)) {
 			import = list_entry(obd_zombie_imports.next,
-						struct obd_import,
-						imp_zombie_chain);
+					    struct obd_import,
+					    imp_zombie_chain);
 			list_del_init(&import->imp_zombie_chain);
 		}
 
 		export = NULL;
 		if (!list_empty(&obd_zombie_exports)) {
 			export = list_entry(obd_zombie_exports.next,
-						struct obd_export,
-						exp_obd_chain);
+					    struct obd_export,
+					    exp_obd_chain);
 			list_del_init(&export->exp_obd_chain);
 		}
 
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
index 42fc26f..fd333b9 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
@@ -62,8 +62,8 @@ struct static_lustre_uintvalue_attr {
 };
 
 static ssize_t static_uintvalue_show(struct kobject *kobj,
-				    struct attribute *attr,
-				    char *buf)
+				     struct attribute *attr,
+				     char *buf)
 {
 	struct static_lustre_uintvalue_attr *lattr = (void *)attr;
 
@@ -71,8 +71,8 @@ static ssize_t static_uintvalue_show(struct kobject *kobj,
 }
 
 static ssize_t static_uintvalue_store(struct kobject *kobj,
-				     struct attribute *attr,
-				     const char *buffer, size_t count)
+				      struct attribute *attr,
+				      const char *buffer, size_t count)
 {
 	struct static_lustre_uintvalue_attr *lattr  = (void *)attr;
 	int rc;
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
index b88ccba..c27d4ec 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_cat.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
@@ -74,7 +74,7 @@ static int llog_cat_id2handle(const struct lu_env *env,
 
 	down_write(&cathandle->lgh_lock);
 	list_for_each_entry(loghandle, &cathandle->u.chd.chd_head,
-				u.phd.phd_entry) {
+			    u.phd.phd_entry) {
 		struct llog_logid *cgl = &loghandle->lgh_id;
 
 		if (ostid_id(&cgl->lgl_oi) == ostid_id(&logid->lgl_oi) &&
@@ -130,7 +130,7 @@ int llog_cat_close(const struct lu_env *env, struct llog_handle *cathandle)
 	int			 rc;
 
 	list_for_each_entry_safe(loghandle, n, &cathandle->u.chd.chd_head,
-				     u.phd.phd_entry) {
+				 u.phd.phd_entry) {
 		/* unlink open-not-created llogs */
 		list_del_init(&loghandle->u.phd.phd_entry);
 		llog_close(env, loghandle);
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 28bb4e5..3c895be 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -607,13 +607,13 @@ static void obd_connect_seq_flags2str(struct seq_file *m, __u64 flags, char *sep
 	for (i = 0; obd_connect_names[i]; i++, mask <<= 1) {
 		if (flags & mask) {
 			seq_printf(m, "%s%s",
-					first ? sep : "", obd_connect_names[i]);
+				   first ? sep : "", obd_connect_names[i]);
 			first = false;
 		}
 	}
 	if (flags & ~(mask - 1))
 		seq_printf(m, "%sunknown flags %#llx",
-				first ? sep : "", flags & ~(mask - 1));
+			   first ? sep : "", flags & ~(mask - 1));
 }
 
 int lprocfs_rd_import(struct seq_file *m, void *data)
@@ -637,26 +637,27 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 	imp = obd->u.cli.cl_import;
 
 	seq_printf(m,
-		     "import:\n"
-		     "    name: %s\n"
-		     "    target: %s\n"
-		     "    state: %s\n"
-		     "    instance: %u\n"
-		     "    connect_flags: [ ",
-		     obd->obd_name,
-		     obd2cli_tgt(obd),
-		     ptlrpc_import_state_name(imp->imp_state),
-		     imp->imp_connect_data.ocd_instance);
-	obd_connect_seq_flags2str(m, imp->imp_connect_data.ocd_connect_flags, ", ");
+		   "import:\n"
+		   "    name: %s\n"
+		   "    target: %s\n"
+		   "    state: %s\n"
+		   "    instance: %u\n"
+		   "    connect_flags: [ ",
+		   obd->obd_name,
+		   obd2cli_tgt(obd),
+		   ptlrpc_import_state_name(imp->imp_state),
+		   imp->imp_connect_data.ocd_instance);
+	obd_connect_seq_flags2str(m, imp->imp_connect_data.ocd_connect_flags,
+				  ", ");
 	seq_printf(m,
-		      " ]\n"
-		      "    import_flags: [ ");
+		   " ]\n"
+		   "    import_flags: [ ");
 	obd_import_flags2str(imp, m);
 
 	seq_printf(m,
-		      " ]\n"
-		      "    connection:\n"
-		      "       failover_nids: [ ");
+		   " ]\n"
+		   "    connection:\n"
+		   "       failover_nids: [ ");
 	spin_lock(&imp->imp_lock);
 	j = 0;
 	list_for_each_entry(conn, &imp->imp_conn_list, oic_item) {
@@ -671,15 +672,15 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 	else
 		strncpy(nidstr, "<none>", sizeof(nidstr));
 	seq_printf(m,
-		      " ]\n"
-		      "       current_connection: %s\n"
-		      "       connection_attempts: %u\n"
-		      "       generation: %u\n"
-		      "       in-progress_invalidations: %u\n",
-		      nidstr,
-		      imp->imp_conn_cnt,
-		      imp->imp_generation,
-		      atomic_read(&imp->imp_inval_count));
+		   " ]\n"
+		   "       current_connection: %s\n"
+		   "       connection_attempts: %u\n"
+		   "       generation: %u\n"
+		   "       in-progress_invalidations: %u\n",
+		   nidstr,
+		   imp->imp_conn_cnt,
+		   imp->imp_generation,
+		   atomic_read(&imp->imp_inval_count));
 	spin_unlock(&imp->imp_lock);
 
 	if (!obd->obd_svc_stats)
@@ -696,15 +697,15 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 	} else
 		ret.lc_sum = 0;
 	seq_printf(m,
-		      "    rpcs:\n"
-		      "       inflight: %u\n"
-		      "       unregistering: %u\n"
-		      "       timeouts: %u\n"
-		      "       avg_waittime: %llu %s\n",
-		      atomic_read(&imp->imp_inflight),
-		      atomic_read(&imp->imp_unregistering),
-		      atomic_read(&imp->imp_timeouts),
-		      ret.lc_sum, header->lc_units);
+		   "    rpcs:\n"
+		   "       inflight: %u\n"
+		   "       unregistering: %u\n"
+		   "       timeouts: %u\n"
+		   "       avg_waittime: %llu %s\n",
+		   atomic_read(&imp->imp_inflight),
+		   atomic_read(&imp->imp_unregistering),
+		   atomic_read(&imp->imp_timeouts),
+		   ret.lc_sum, header->lc_units);
 
 	k = 0;
 	for (j = 0; j < IMP_AT_MAX_PORTALS; j++) {
@@ -714,20 +715,20 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 			  at_get(&imp->imp_at.iat_service_estimate[j]));
 	}
 	seq_printf(m,
-		      "    service_estimates:\n"
-		      "       services: %u sec\n"
-		      "       network: %u sec\n",
-		      k,
-		      at_get(&imp->imp_at.iat_net_latency));
+		   "    service_estimates:\n"
+		   "       services: %u sec\n"
+		   "       network: %u sec\n",
+		   k,
+		   at_get(&imp->imp_at.iat_net_latency));
 
 	seq_printf(m,
-		      "    transactions:\n"
-		      "       last_replay: %llu\n"
-		      "       peer_committed: %llu\n"
-		      "       last_checked: %llu\n",
-		      imp->imp_last_replay_transno,
-		      imp->imp_peer_committed_transno,
-		      imp->imp_last_transno_checked);
+		   "    transactions:\n"
+		   "       last_replay: %llu\n"
+		   "       peer_committed: %llu\n"
+		   "       last_checked: %llu\n",
+		   imp->imp_last_replay_transno,
+		   imp->imp_peer_committed_transno,
+		   imp->imp_last_transno_checked);
 
 	/* avg data rates */
 	for (rw = 0; rw <= 1; rw++) {
@@ -741,10 +742,10 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 			do_div(sum, ret.lc_count);
 			ret.lc_sum = sum;
 			seq_printf(m,
-				      "    %s_data_averages:\n"
-				      "       bytes_per_rpc: %llu\n",
-				      rw ? "write" : "read",
-				      ret.lc_sum);
+				   "    %s_data_averages:\n"
+				   "       bytes_per_rpc: %llu\n",
+				   rw ? "write" : "read",
+				   ret.lc_sum);
 		}
 		k = (int)ret.lc_sum;
 		j = opcode_offset(OST_READ + rw) + EXTRA_MAX_OPCODES;
@@ -757,13 +758,13 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 			do_div(sum, ret.lc_count);
 			ret.lc_sum = sum;
 			seq_printf(m,
-				      "       %s_per_rpc: %llu\n",
-				      header->lc_units, ret.lc_sum);
+				   "       %s_per_rpc: %llu\n",
+				   header->lc_units, ret.lc_sum);
 			j = (int)ret.lc_sum;
 			if (j > 0)
 				seq_printf(m,
-					      "       MB_per_sec: %u.%.02u\n",
-					      k / j, (100 * k / j) % 100);
+					   "       MB_per_sec: %u.%.02u\n",
+					   k / j, (100 * k / j) % 100);
 		}
 	}
 
@@ -787,7 +788,7 @@ int lprocfs_rd_state(struct seq_file *m, void *data)
 	imp = obd->u.cli.cl_import;
 
 	seq_printf(m, "current_state: %s\n",
-		     ptlrpc_import_state_name(imp->imp_state));
+		   ptlrpc_import_state_name(imp->imp_state));
 	seq_printf(m, "state_history:\n");
 	k = imp->imp_state_hist_idx;
 	for (j = 0; j < IMP_STATE_HIST_LEN; j++) {
@@ -1206,7 +1207,7 @@ struct file_operations lprocfs_stats_seq_fops = {
 };
 
 int ldebugfs_register_stats(struct dentry *parent, const char *name,
-			   struct lprocfs_stats *stats)
+			    struct lprocfs_stats *stats)
 {
 	struct dentry *entry;
 
@@ -1427,11 +1428,9 @@ char *lprocfs_find_named_value(const char *buffer, const char *name,
 }
 EXPORT_SYMBOL(lprocfs_find_named_value);
 
-int ldebugfs_seq_create(struct dentry *parent,
-		       const char *name,
-		       umode_t mode,
-		       const struct file_operations *seq_fops,
-		       void *data)
+int ldebugfs_seq_create(struct dentry *parent, const char *name,
+			umode_t mode, const struct file_operations *seq_fops,
+			void *data)
 {
 	struct dentry *entry;
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 0fa4bac..09832ff 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1473,8 +1473,7 @@ void lu_context_key_quiesce(struct lu_context_key *key)
 		 * XXX memory barrier has to go here.
 		 */
 		spin_lock(&lu_keys_guard);
-		list_for_each_entry(ctx, &lu_context_remembered,
-					lc_remember)
+		list_for_each_entry(ctx, &lu_context_remembered, lc_remember)
 			key_fini(ctx, key->lct_index);
 		spin_unlock(&lu_keys_guard);
 		++key_set_version;
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
index b10ea31..5c38c83 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
@@ -173,7 +173,7 @@ int class_del_uuid(const char *uuid)
 
 	while (!list_empty(&deathrow)) {
 		data = list_entry(deathrow.next, struct uuid_nid_data,
-				      un_list);
+				  un_list);
 		list_del(&data->un_list);
 
 		CDEBUG(D_INFO, "del uuid %s %s/%d\n",
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 2134b60..5395e99 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1049,9 +1049,9 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 			rc = 0;
 		} else {
 			CDEBUG(D_CONFIG, "%s.%.*s: Set parameter %.*s=%s\n",
-					 lustre_cfg_string(lcfg, 0),
-					 (int)strlen(prefix) - 1, prefix,
-					 (int)(sval - key - 1), key, sval);
+			       lustre_cfg_string(lcfg, 0),
+			       (int)strlen(prefix) - 1, prefix,
+			       (int)(sval - key - 1), key, sval);
 		}
 	}
 
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index d138e05..d3e28a3 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -72,7 +72,7 @@ static void (*kill_super_cb)(struct super_block *sb);
  *   this log, and is added to the mgc's list of logs to follow.
  */
 int lustre_process_log(struct super_block *sb, char *logname,
-		     struct config_llog_instance *cfg)
+		      struct config_llog_instance *cfg)
 {
 	struct lustre_cfg *lcfg;
 	struct lustre_cfg_bufs *bufs;
@@ -114,7 +114,7 @@ EXPORT_SYMBOL(lustre_process_log);
 
 /* Stop watching this config log for updates */
 int lustre_end_log(struct super_block *sb, char *logname,
-		       struct config_llog_instance *cfg)
+		   struct config_llog_instance *cfg)
 {
 	struct lustre_cfg *lcfg;
 	struct lustre_cfg_bufs bufs;
@@ -340,7 +340,7 @@ int lustre_start_mgc(struct super_block *sb)
 	/* Add any failover MGS nids */
 	i = 1;
 	while (ptr && ((*ptr == ':' ||
-	       class_find_param(ptr, PARAM_MGSNODE, &ptr) == 0))) {
+			class_find_param(ptr, PARAM_MGSNODE, &ptr) == 0))) {
 		/* New failover node */
 		sprintf(niduuid, "%s_%x", mgcname, i);
 		j = 0;
@@ -1181,7 +1181,7 @@ EXPORT_SYMBOL(lustre_register_kill_super_cb);
 
 /***************** FS registration ******************/
 static struct dentry *lustre_mount(struct file_system_type *fs_type, int flags,
-				const char *devname, void *data)
+				   const char *devname, void *data)
 {
 	struct lustre_mount_data2 lmd2 = {
 		.lmd2_data = data,
-- 
2.1.0
