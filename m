From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 12 Apr 2016 21:11:08 -0400
Subject: [lustre-devel] [PATCH 1/2] staging/lustre: Fix blank line
	after/before {/} style
In-Reply-To: <1460509869-3288664-1-git-send-email-green@linuxhacker.ru>
References: <1460509869-3288664-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1460509869-3288664-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patch fixes all checkpatch occurences of
CHECK: Blank lines aren't necessary after an open brace '{'
CHECK: Blank lines aren't necessary before a close brace '}'
in Lustre code.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/fld/fld_request.c     | 1 -
 drivers/staging/lustre/lustre/include/lu_object.h   | 1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c       | 1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c      | 1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c   | 1 -
 drivers/staging/lustre/lustre/llite/dir.c           | 2 --
 drivers/staging/lustre/lustre/llite/lproc_llite.c   | 1 -
 drivers/staging/lustre/lustre/llite/xattr.c         | 1 -
 drivers/staging/lustre/lustre/llite/xattr_cache.c   | 1 -
 drivers/staging/lustre/lustre/lov/lov_io.c          | 1 -
 drivers/staging/lustre/lustre/lov/lov_obd.c         | 1 -
 drivers/staging/lustre/lustre/lov/lov_pack.c        | 1 -
 drivers/staging/lustre/lustre/lov/lov_request.c     | 1 -
 drivers/staging/lustre/lustre/lov/lovsub_object.c   | 1 -
 drivers/staging/lustre/lustre/mdc/mdc_lib.c         | 1 -
 drivers/staging/lustre/lustre/mdc/mdc_locks.c       | 1 -
 drivers/staging/lustre/lustre/mgc/mgc_request.c     | 1 -
 drivers/staging/lustre/lustre/obdclass/class_obd.c  | 1 -
 drivers/staging/lustre/lustre/obdclass/genops.c     | 1 -
 drivers/staging/lustre/lustre/obdclass/llog.c       | 1 -
 drivers/staging/lustre/lustre/obdclass/lu_object.c  | 2 --
 drivers/staging/lustre/lustre/obdclass/obd_config.c | 1 -
 drivers/staging/lustre/lustre/obdecho/echo_client.c | 2 --
 drivers/staging/lustre/lustre/osc/osc_cache.c       | 1 -
 drivers/staging/lustre/lustre/osc/osc_io.c          | 1 -
 drivers/staging/lustre/lustre/osc/osc_page.c        | 1 -
 drivers/staging/lustre/lustre/osc/osc_request.c     | 1 -
 drivers/staging/lustre/lustre/ptlrpc/client.c       | 1 -
 drivers/staging/lustre/lustre/ptlrpc/events.c       | 1 -
 drivers/staging/lustre/lustre/ptlrpc/import.c       | 3 ---
 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c | 1 -
 drivers/staging/lustre/lustre/ptlrpc/nrs.c          | 1 -
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c | 3 ---
 33 files changed, 40 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 2dfdb51..64c387e 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -95,7 +95,6 @@ static void fld_exit_request(struct client_obd *cli)
 	spin_lock(&cli->cl_loi_list_lock);
 	cli->cl_r_in_flight--;
 	list_for_each_safe(l, tmp, &cli->cl_cache_waiters) {
-
 		if (cli->cl_r_in_flight >= cli->cl_max_rpcs_in_flight) {
 			/* No free request slots anymore */
 			break;
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 0f70acd..b5b0c81 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -198,7 +198,6 @@ typedef int (*lu_printer_t)(const struct lu_env *env,
  * Operations specific for particular lu_object.
  */
 struct lu_object_operations {
-
 	/**
 	 * Allocate lower-layer parts of the object by calling
 	 * lu_device_operations::ldo_object_alloc() of the corresponding
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 9e58b1c..bc951c0 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -429,7 +429,6 @@ err_ldlm:
 	ldlm_put_ref();
 err:
 	return rc;
-
 }
 EXPORT_SYMBOL(client_obd_setup);
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 3f9b8526..6c27b23 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -810,7 +810,6 @@ void ldlm_lock_decref_internal(struct ldlm_lock *lock, __u32 mode)
 	} else if (!lock->l_readers && !lock->l_writers &&
 		   !(lock->l_flags & LDLM_FL_NO_LRU) &&
 		   !(lock->l_flags & LDLM_FL_BL_AST)) {
-
 		LDLM_DEBUG(lock, "add lock into lru list");
 
 		/* If this is a client-side namespace and this was the last
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 880efdc..861e4be 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1803,7 +1803,6 @@ static void ldlm_namespace_foreach(struct ldlm_namespace *ns,
 
 	cfs_hash_for_each_nolock(ns->ns_rs_hash,
 				 ldlm_res_iter_helper, &helper);
-
 }
 
 /* non-blocking function to manipulate a lock whose cb_data is being put away.
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 2f0873e..1d5366b 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1059,7 +1059,6 @@ static int ll_ioc_copy_end(struct super_block *sb, struct hsm_copy *copy)
 			/* hpk_errval must be >= 0 */
 			hpk.hpk_errval = EBUSY;
 		}
-
 	}
 
 progress:
@@ -1388,7 +1387,6 @@ out_free:
 lmv_out_free:
 		obd_ioctl_freedata(buf, len);
 		return rc;
-
 	}
 	case LL_IOC_LOV_SETSTRIPE: {
 		struct lov_user_md_v3 lumv3;
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index d99d8c3..4a9f669 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -254,7 +254,6 @@ static ssize_t max_read_ahead_mb_store(struct kobject *kobj,
 	pages_number *= 1 << (20 - PAGE_SHIFT); /* MB -> pages */
 
 	if (pages_number > totalram_pages / 2) {
-
 		CERROR("can't set file readahead more than %lu MB\n",
 		       totalram_pages >> (20 - PAGE_SHIFT + 1)); /*1/2 of RAM*/
 		return -ERANGE;
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 9f6fcfe..43b2d08 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -339,7 +339,6 @@ int ll_getxattr_common(struct inode *inode, const char *name,
 	 */
 	if (xattr_type == XATTR_ACL_ACCESS_T &&
 	    !(sbi->ll_flags & LL_SBI_RMT_CLIENT)) {
-
 		struct posix_acl *acl;
 
 		spin_lock(&lli->lli_lock);
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index 3480ce2..d7e17ab 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -229,7 +229,6 @@ static int ll_xattr_cache_valid(struct ll_inode_info *lli)
  */
 static int ll_xattr_cache_destroy_locked(struct ll_inode_info *lli)
 {
-
 	if (!ll_xattr_cache_valid(lli))
 		return 0;
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index da4784b..86cb3f8 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -442,7 +442,6 @@ static int lov_io_rw_iter_init(const struct lu_env *env,
 
 	/* fast path for common case. */
 	if (lio->lis_nr_subios != 1 && !cl_io_is_append(io)) {
-
 		lov_do_div64(start, ssize);
 		next = (start + 1) * ssize;
 		if (next <= start * ssize)
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 1a9e3e8..6d02914 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -964,7 +964,6 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
 		CERROR("Unknown command: %d\n", lcfg->lcfg_command);
 		rc = -EINVAL;
 		goto out;
-
 	}
 	}
 out:
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index d983a30..0215ea5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -136,7 +136,6 @@ int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
 		CERROR("bad mem LOV MAGIC: 0x%08X != 0x%08X nor 0x%08X\n",
 		       lmm_magic, LOV_MAGIC_V1, LOV_MAGIC_V3);
 		return -EINVAL;
-
 	}
 
 	if (lsm) {
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 7178a02..8226ab2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -235,7 +235,6 @@ out:
 	if (tmp_oa)
 		kmem_cache_free(obdo_cachep, tmp_oa);
 	return rc;
-
 }
 
 int lov_fini_getattr_set(struct lov_request_set *set)
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index 3f51f0d..bcaae1e 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -71,7 +71,6 @@ int lovsub_object_init(const struct lu_env *env, struct lu_object *obj,
 		result = -ENOMEM;
 	}
 	return result;
-
 }
 
 static void lovsub_object_free(const struct lu_env *env, struct lu_object *obj)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 53cd56f..856c54e 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -438,7 +438,6 @@ void mdc_getattr_pack(struct ptlrpc_request *req, __u64 valid, int flags,
 		char *tmp = req_capsule_client_get(&req->rq_pill, &RMF_NAME);
 
 		LOGL0(op_data->op_name, op_data->op_namelen, tmp);
-
 	}
 }
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 958a164..9e970ab 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -963,7 +963,6 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 	if (fid_is_sane(&op_data->op_fid2) &&
 	    it->it_create_mode & M_CHECK_STALE &&
 	    it->it_op != IT_GETATTR) {
-
 		/* Also: did we find the same inode? */
 		/* sever can return one of two fids:
 		 * op_fid2 - new allocated fid - if file is created.
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 3924b09..0c3bd16 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1720,7 +1720,6 @@ static int mgc_process_config(struct obd_device *obd, u32 len, void *buf)
 		CERROR("Unknown command: %d\n", lcfg->lcfg_command);
 		rc = -EINVAL;
 		goto out;
-
 	}
 	}
 out:
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 799e558..a3c7e7b 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -335,7 +335,6 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 		err = 0;
 		goto out;
 	}
-
 	}
 
 	if (data->ioc_dev == OBD_DEV_BY_DEVNAME) {
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index cf97b8f0..d95f11d 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -604,7 +604,6 @@ int obd_init_caches(void)
  out:
 	obd_cleanup_caches();
 	return -ENOMEM;
-
 }
 
 /* map connection to client */
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 992573e..79194d8 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -265,7 +265,6 @@ repeat:
 		for (rec = (struct llog_rec_hdr *)buf;
 		     (char *)rec < buf + LLOG_CHUNK_SIZE;
 		     rec = (struct llog_rec_hdr *)((char *)rec + rec->lrh_len)) {
-
 			CDEBUG(D_OTHER, "processing rec 0x%p type %#x\n",
 			       rec, rec->lrh_type);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 990e939..e043857 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -104,7 +104,6 @@ void lu_object_put(const struct lu_env *env, struct lu_object *o)
 
 	if (!cfs_hash_bd_dec_and_lock(site->ls_obj_hash, &bd, &top->loh_ref)) {
 		if (lu_object_is_dying(top)) {
-
 			/*
 			 * somebody may be waiting for this, currently only
 			 * used for cl_object, see cl_object_put_last().
@@ -358,7 +357,6 @@ int lu_site_purge(const struct lu_env *env, struct lu_site *s, int nr)
 
 			if (count > 0 && --count == 0)
 				break;
-
 		}
 		cfs_hash_bd_unlock(s->ls_obj_hash, &bd, 1);
 		cond_resched();
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 5395e99..318a2e3 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -961,7 +961,6 @@ int class_process_config(struct lustre_cfg *lcfg)
 	default: {
 		err = obd_process_config(obd, sizeof(*lcfg), lcfg);
 		goto out;
-
 	}
 	}
 out:
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index b271895..6aa6d86 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1354,7 +1354,6 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 	for (i = 0, pgp = pga, off = offset;
 	     i < npages;
 	     i++, pgp++, off += PAGE_SIZE) {
-
 		LASSERT(!pgp->pg);      /* for cleanup */
 
 		rc = -ENOMEM;
@@ -1831,7 +1830,6 @@ static int __init obdecho_init(void)
 static void /*__exit*/ obdecho_exit(void)
 {
 	echo_client_exit();
-
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index ef68821..de8c825 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1820,7 +1820,6 @@ static void osc_process_ar(struct osc_async_rc *ar, __u64 xid,
 		ar->ar_force_sync = 1;
 		ar->ar_min_xid = ptlrpc_sample_next_xid();
 		return;
-
 	}
 
 	if (ar->ar_force_sync && (xid >= ar->ar_min_xid))
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index c1efcb3..9d67fca2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -782,7 +782,6 @@ static void osc_req_attr_set(const struct lu_env *env,
 		oa->o_valid |= OBD_MD_FLID;
 	}
 	if (flags & OBD_MD_FLHANDLE) {
-
 		clerq = slice->crs_req;
 		LASSERT(!list_empty(&clerq->crq_pages));
 		apage = container_of(clerq->crq_pages.next,
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index b55f467..5ec5508 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -759,7 +759,6 @@ static int osc_lru_reserve(const struct lu_env *env, struct osc_object *obj,
 
 	LASSERT(atomic_read(cli->cl_lru_left) >= 0);
 	while (!atomic_add_unless(cli->cl_lru_left, -1, 0)) {
-
 		/* run out of LRU spaces, try to drop some by itself */
 		rc = osc_lru_reclaim(cli);
 		if (rc < 0)
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 4d0f831..e5794fb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -837,7 +837,6 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 	spin_unlock(&cli->cl_loi_list_lock);
 	CDEBUG(D_CACHE, "dirty: %llu undirty: %u dropped %u grant: %llu\n",
 	       oa->o_dirty, oa->o_undirty, oa->o_dropped, oa->o_grant);
-
 }
 
 void osc_update_next_shrink(struct client_obd *cli)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index e02d95d1..4b7912a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1082,7 +1082,6 @@ static int ptlrpc_console_allow(struct ptlrpc_request *req)
 	 */
 	if ((lustre_handle_is_used(&req->rq_import->imp_remote_handle)) &&
 	    (opc == OST_CONNECT || opc == MDS_CONNECT || opc == MGS_CONNECT)) {
-
 		/* Suppress timed out reconnect requests */
 		if (req->rq_timedout)
 			return 0;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index 47be21a..fdcde9b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -69,7 +69,6 @@ void request_out_callback(lnet_event_t *ev)
 		req->rq_req_unlink = 0;
 
 	if (ev->type == LNET_EVENT_UNLINK || ev->status != 0) {
-
 		/* Failed send: make it seem like the reply timed out, just
 		 * like failing sends in client.c does currently...
 		 */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index cd94fed..bf7b9d2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -1001,7 +1001,6 @@ finish:
 			return 0;
 		}
 	} else {
-
 		spin_lock(&imp->imp_lock);
 		list_del(&imp->imp_conn_current->oic_item);
 		list_add(&imp->imp_conn_current->oic_item, &imp->imp_conn_list);
@@ -1370,7 +1369,6 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 			if (rc)
 				goto out;
 		}
-
 	}
 
 	if (imp->imp_state == LUSTRE_IMP_REPLAY_WAIT) {
@@ -1453,7 +1451,6 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
 				       back_to_sleep, LWI_ON_SIGNAL_NOOP, NULL);
 		rc = l_wait_event(imp->imp_recovery_waitq,
 				  !ptlrpc_import_in_recovery(imp), &lwi);
-
 	}
 
 	spin_lock(&imp->imp_lock);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index a35b56e..6dba4ee 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -1321,6 +1321,5 @@ int lprocfs_wr_pinger_recov(struct file *file, const char __user *buffer,
 	up_read(&obd->u.cli.cl_sem);
 
 	return count;
-
 }
 EXPORT_SYMBOL(lprocfs_wr_pinger_recov);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index 710fb80..99ff6e8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -1038,7 +1038,6 @@ static int nrs_policy_unregister_locked(struct ptlrpc_nrs_pol_desc *desc)
 	LASSERT(mutex_is_locked(&ptlrpc_all_services_mutex));
 
 	list_for_each_entry(svc, &ptlrpc_all_services, srv_list) {
-
 		if (!nrs_policy_compatible(svc, desc) ||
 		    unlikely(svc->srv_is_stopping))
 			continue;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 492d63f..811acf6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1160,7 +1160,6 @@ __u32 lustre_msg_get_timeout(struct lustre_msg *msg)
 		if (!pb) {
 			CERROR("invalid msg %p: no ptlrpc body!\n", msg);
 			return 0;
-
 		}
 		return pb->pb_timeout;
 	}
@@ -1179,7 +1178,6 @@ __u32 lustre_msg_get_service_time(struct lustre_msg *msg)
 		if (!pb) {
 			CERROR("invalid msg %p: no ptlrpc body!\n", msg);
 			return 0;
-
 		}
 		return pb->pb_service_time;
 	}
@@ -1572,7 +1570,6 @@ static void lustre_swab_obdo(struct obdo *o)
 	CLASSERT(offsetof(typeof(*o), o_padding_4) != 0);
 	CLASSERT(offsetof(typeof(*o), o_padding_5) != 0);
 	CLASSERT(offsetof(typeof(*o), o_padding_6) != 0);
-
 }
 
 void lustre_swab_obd_statfs(struct obd_statfs *os)
-- 
2.1.0
