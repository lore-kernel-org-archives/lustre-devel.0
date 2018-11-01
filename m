From: James Simmons <jsimmons@infradead.org>
Date: Thu, 1 Nov 2018 20:55:37 +0000 (GMT)
Subject: [lustre-devel] [PATCH RFC] lustre: obd: convert obd_nid_hash to
 rhashtable
Message-ID: <alpine.LFD.2.21.1811011955300.11470@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


This patch converts the struct obd_export obd_nid_hash used by the servr
to use rhltables. The reason is that the NID hash can have multiple obd 
exports using the same NID key. In the process we gain lockless lookup 
which  should improve performance. This should also address the rare 
crashes:

[<ffffffffc0913388>] ? cfs_hash_bd_from_key+0x38/0xb0 [libcfs]
[74844.507416]  [<ffffffffc0913425>] cfs_hash_bd_get+0x25/0x70 [libcfs]
[74844.516384]  [<ffffffffc09166d2>] cfs_hash_add+0x52/0x1a0 [libcfs]
[74844.525211]  [<ffffffffc0d8a765>] target_handle_connect+0x1fe5/0x29b0 [ptlrpc]

Pre 4.8 kernels do not support rhltables so wrappers have been created.

***
My testing has been positive so far but I do need to figure out the 
debugfs file mapping from the old libcfs hash to rhashtables.

***

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
---
 libcfs/autoconf/lustre-libcfs.m4         |  21 +++
 libcfs/include/libcfs/linux/linux-hash.h |  88 ++++++++++++
 lustre/include/lustre_export.h           |   2 +-
 lustre/include/obd.h                     |   8 +-
 lustre/include/obd_support.h             |   3 -
 lustre/ldlm/ldlm_flock.c                 |  18 ++-
 lustre/ldlm/ldlm_lib.c                   |  14 +-
 lustre/mdt/mdt_lproc.c                   |  21 ++-
 lustre/obdclass/genops.c                 |  76 ++++++-----
 lustre/obdclass/lprocfs_status_server.c  | 133 +++++++++++-------
 lustre/obdclass/obd_config.c             | 225 ++++++++++++++++++-------------
 11 files changed, 394 insertions(+), 215 deletions(-)

diff --git a/libcfs/autoconf/lustre-libcfs.m4 b/libcfs/autoconf/lustre-libcfs.m4
index d437331..147ecb3 100644
--- a/libcfs/autoconf/lustre-libcfs.m4
+++ b/libcfs/autoconf/lustre-libcfs.m4
@@ -761,6 +761,26 @@ LB_CHECK_LINUX_HEADER([linux/stringhash.h], [
 ]) # LIBCFS_STRINGHASH
 
 #
+# LIBCFS_RHLTABLE
+# Kernel version 4.8 commit ca26893f05e86497a86732768ec53cd38c0819ca
+# created the rhlist interface to allow inserting duplicate objects
+# into the same table.
+#
+AC_DEFUN([LIBCFS_RHLTABLE], [
+LB_CHECK_COMPILE([if 'struct rhltable' exist],
+rhtable, [
+	#include <linux/rhashtable.h>
+],[
+	struct rhltable *hlt = NULL;
+
+	rhltable_destroy(hlt);
+],[
+	AC_DEFINE(HAVE_RHLTABLE, 1,
+		  [struct rhltable exist])
+])
+]) # LIBCFS_RHLTABLE
+
+#
 # LIBCFS_STACKTRACE_OPS
 #
 # Kernel version 4.8 commit c8fe4609827aedc9c4b45de80e7cdc8ccfa8541b
@@ -999,6 +1019,7 @@ LIBCFS_STACKTRACE_OPS_ADDRESS_RETURN_INT
 LIBCFS_GET_USER_PAGES_6ARG
 LIBCFS_STRINGHASH
 # 4.8
+LIBCFS_RHLTABLE
 LIBCFS_STACKTRACE_OPS
 # 4.9
 LIBCFS_GET_USER_PAGES_GUP_FLAGS
diff --git a/libcfs/include/libcfs/linux/linux-hash.h b/libcfs/include/libcfs/linux/linux-hash.h
index 1227ec8..0453cd9 100644
--- a/libcfs/include/libcfs/linux/linux-hash.h
+++ b/libcfs/include/libcfs/linux/linux-hash.h
@@ -38,6 +38,94 @@ u64 cfs_hashlen_string(const void *salt, const char *name);
 #endif
 #endif /* !HAVE_STRINGHASH */
 
+#ifndef HAVE_RHLTABLE
+struct rhlist_head {
+	struct rhash_head		rhead;
+	struct rhlist_head __rcu	*next;
+};
+
+struct rhltable {
+	struct rhashtable ht;
+};
+
+#define rhl_for_each_entry_rcu(tpos, pos, list, member)                 \
+	for (pos = list; pos && rht_entry(tpos, pos, member);           \
+		pos = rcu_dereference_raw(pos->next))
+
+static inline int rhltable_init(struct rhltable *hlt, const struct rhashtable_params *params)
+{
+	return rhashtable_init(&hlt->ht, params);
+}
+
+static inline struct rhlist_head *rhltable_lookup(
+	struct rhltable *hlt, const void *key,
+	const struct rhashtable_params params)
+{
+	struct rhashtable *ht = &hlt->ht;
+	struct rhashtable_compare_arg arg = {
+		.ht = ht,
+		.key = key,
+	};
+	struct bucket_table *tbl;
+	struct rhash_head *he;
+	unsigned int hash;
+
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+restart:
+	hash = rht_key_hashfn(ht, tbl, key, params);
+	rht_for_each_rcu(he, tbl, hash) {
+		if (params.obj_cmpfn ?
+		    params.obj_cmpfn(&arg, rht_obj(ht, he)) :
+		    rhashtable_compare(&arg, rht_obj(ht, he)))
+			continue;
+		return he ? container_of(he, struct rhlist_head, rhead) : NULL;
+	}
+
+	/* Ensure we see any new tables. */
+	smp_rmb();
+
+	tbl = rht_dereference_rcu(tbl->future_tbl, ht);
+	if (unlikely(tbl))
+		goto restart;
+
+	return NULL;
+}
+
+static inline int rhltable_insert_key(
+	struct rhltable *hlt, const void *key, struct rhlist_head *list,
+	const struct rhashtable_params params)
+{
+	return PTR_ERR(__rhashtable_insert_fast(&hlt->ht, key, &list->rhead,
+						params));
+}
+
+static inline int rhltable_remove(
+	struct rhltable *hlt, struct rhlist_head *list,
+	const struct rhashtable_params params)
+{
+	return rhashtable_remove_fast(&hlt->ht, &list->rhead, params);
+}
+
+static inline void rhltable_free_and_destroy(struct rhltable *hlt,
+					     void (*free_fn)(void *ptr,
+							     void *arg),
+					     void *arg)
+{
+	return rhashtable_free_and_destroy(&hlt->ht, free_fn, arg);
+}
+
+static inline void rhltable_destroy(struct rhltable *hlt)
+{
+	return rhltable_free_and_destroy(hlt, NULL, NULL);
+}
+
+static inline void rhltable_walk_enter(struct rhltable *hlt,
+				       struct rhashtable_iter *iter)
+{
+	rhashtable_walk_init(&hlt->ht, iter);
+}
+#endif /* !HAVE_RHLTABLE */
+
 #ifndef HAVE_RHASHTABLE_LOOKUP_GET_INSERT_FAST
 /**
  * rhashtable_lookup_get_insert_fast - lookup and insert object into hash table
diff --git a/lustre/include/lustre_export.h b/lustre/include/lustre_export.h
index 5ead593..54887c9 100644
--- a/lustre/include/lustre_export.h
+++ b/lustre/include/lustre_export.h
@@ -209,7 +209,7 @@ struct obd_export {
 	/* Unlinked export list */
 	struct list_head	exp_stale_list;
 	struct hlist_node	exp_uuid_hash;	/** uuid-export hash*/
-	struct hlist_node	exp_nid_hash;	/** nid-export hash */
+	struct rhlist_head	exp_nid_hash;	/** nid-export hash */
 	struct hlist_node	exp_gen_hash;   /** last_rcvd clt gen hash */
         /**
          * All exports eligible for ping evictor are linked into a list
diff --git a/lustre/include/obd.h b/lustre/include/obd.h
index 1fcf0a2..8219710 100644
--- a/lustre/include/obd.h
+++ b/lustre/include/obd.h
@@ -639,7 +639,7 @@ struct obd_device {
         /* uuid-export hash body */
 	struct cfs_hash             *obd_uuid_hash;
         /* nid-export hash body */
-	struct cfs_hash             *obd_nid_hash;
+	struct rhltable			obd_nid_hash;
 	/* nid stats body */
 	struct cfs_hash             *obd_nid_stats_hash;
 	/* client_generation-export hash body */
@@ -750,6 +750,12 @@ struct obd_device {
 	struct completion		obd_kobj_unregister;
 };
 
+int obd_nid_export_for_each(struct obd_device *obd, lnet_nid_t nid,
+			    int cb(struct obd_export *exp, void *data),
+			    void *data);
+int obd_nid_add(struct obd_device *obd, struct obd_export *exp);
+void obd_nid_del(struct obd_device *obd, struct obd_export *exp);
+
 /* get/set_info keys */
 #define KEY_ASYNC               "async"
 #define KEY_CHANGELOG_CLEAR     "changelog_clear"
diff --git a/lustre/include/obd_support.h b/lustre/include/obd_support.h
index e9dd33e..0175cf8 100644
--- a/lustre/include/obd_support.h
+++ b/lustre/include/obd_support.h
@@ -78,9 +78,6 @@ extern char obd_jobid_var[];
 #define HASH_UUID_BKT_BITS 5
 #define HASH_UUID_CUR_BITS 7
 #define HASH_UUID_MAX_BITS 12
-#define HASH_NID_BKT_BITS 5
-#define HASH_NID_CUR_BITS 7
-#define HASH_NID_MAX_BITS 12
 #define HASH_NID_STATS_BKT_BITS 5
 #define HASH_NID_STATS_CUR_BITS 7
 #define HASH_NID_STATS_MAX_BITS 12
diff --git a/lustre/ldlm/ldlm_flock.c b/lustre/ldlm/ldlm_flock.c
index f848a36..4c1603a 100644
--- a/lustre/ldlm/ldlm_flock.c
+++ b/lustre/ldlm/ldlm_flock.c
@@ -161,20 +161,18 @@ ldlm_flock_destroy(struct ldlm_lock *lock, enum ldlm_mode mode, __u64 flags)
  */
 
 struct ldlm_flock_lookup_cb_data {
-	__u64 *bl_owner;
+	u64 *bl_owner;
 	struct ldlm_lock *lock;
 	struct obd_export *exp;
 };
 
-static int ldlm_flock_lookup_cb(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-				struct hlist_node *hnode, void *data)
+static int ldlm_flock_lookup_cb(struct obd_export *exp, void *data)
 {
 	struct ldlm_flock_lookup_cb_data *cb_data = data;
-	struct obd_export *exp = cfs_hash_object(hs, hnode);
 	struct ldlm_lock *lock;
 
 	lock = cfs_hash_lookup(exp->exp_flock_hash, cb_data->bl_owner);
-	if (lock == NULL)
+	if (!lock)
 		return 0;
 
 	/* Stop on first found lock. Same process can't sleep twice */
@@ -206,13 +204,13 @@ ldlm_flock_deadlock(struct ldlm_lock *req, struct ldlm_lock *bl_lock)
 		struct ldlm_lock *lock = NULL;
 		struct ldlm_flock *flock;
 
-		if (bl_exp->exp_flock_hash != NULL) {
-			cfs_hash_for_each_key(bl_exp->exp_obd->obd_nid_hash,
-				&bl_exp->exp_connection->c_peer.nid,
-				ldlm_flock_lookup_cb, &cb_data);
+		if (bl_exp->exp_flock_hash) {
+			obd_nid_export_for_each(bl_exp->exp_obd,
+						bl_exp->exp_connection->c_peer.nid,
+						ldlm_flock_lookup_cb, &cb_data);
 			lock = cb_data.lock;
 		}
-		if (lock == NULL)
+		if (!lock)
 			break;
 
 		class_export_put(bl_exp);
diff --git a/lustre/ldlm/ldlm_lib.c b/lustre/ldlm/ldlm_lib.c
index de66aa3..b62e785 100644
--- a/lustre/ldlm/ldlm_lib.c
+++ b/lustre/ldlm/ldlm_lib.c
@@ -1337,11 +1337,9 @@ dont_check_exports:
 
 	if (export->exp_connection != NULL) {
 		/* Check to see if connection came from another NID. */
-		if ((export->exp_connection->c_peer.nid != req->rq_peer.nid) &&
-		    !hlist_unhashed(&export->exp_nid_hash))
-			cfs_hash_del(export->exp_obd->obd_nid_hash,
-				     &export->exp_connection->c_peer.nid,
-				     &export->exp_nid_hash);
+		if (export->exp_connection->c_peer.nid != req->rq_peer.nid &&
+		    export != export->exp_obd->obd_self_export)
+			obd_nid_del(export->exp_obd, export);
 
 		ptlrpc_connection_put(export->exp_connection);
 	}
@@ -1349,10 +1347,8 @@ dont_check_exports:
 	export->exp_connection = ptlrpc_connection_get(req->rq_peer,
 						       req->rq_self,
 						       &cluuid);
-	if (hlist_unhashed(&export->exp_nid_hash))
-		cfs_hash_add(export->exp_obd->obd_nid_hash,
-			     &export->exp_connection->c_peer.nid,
-			     &export->exp_nid_hash);
+	if (export != export->exp_obd->obd_self_export)
+		obd_nid_add(export->exp_obd, export);
 
 	lustre_msg_set_handle(req->rq_repmsg, &conn);
 
diff --git a/lustre/mdt/mdt_lproc.c b/lustre/mdt/mdt_lproc.c
index b41eeee..61b11ad 100644
--- a/lustre/mdt/mdt_lproc.c
+++ b/lustre/mdt/mdt_lproc.c
@@ -1009,19 +1009,17 @@ static struct lprocfs_vars lprocfs_mdt_obd_vars[] = {
 };
 
 static int
-lprocfs_mdt_print_open_files(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-			     struct hlist_node *hnode, void *v)
+lprocfs_mdt_print_open_files(struct obd_export *exp, void *v)
 {
-	struct obd_export	*exp = cfs_hash_object(hs, hnode);
-	struct seq_file		*seq = v;
+	struct seq_file	*seq = v;
 
-	if (exp->exp_lock_hash != NULL) {
-		struct mdt_export_data  *med = &exp->exp_mdt_data;
-		struct mdt_file_data	*mfd;
+	if (exp->exp_lock_hash) {
+		struct mdt_export_data *med = &exp->exp_mdt_data;
+		struct mdt_file_data *mfd;
 
 		spin_lock(&med->med_open_lock);
 		list_for_each_entry(mfd, &med->med_open_head, mfd_list) {
-			seq_printf(seq, DFID"\n",
+			seq_printf(seq, DFID "\n",
 				   PFID(mdt_object_fid(mfd->mfd_object)));
 		}
 		spin_unlock(&med->med_open_lock);
@@ -1033,12 +1031,9 @@ lprocfs_mdt_print_open_files(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 static int lprocfs_mdt_open_files_seq_show(struct seq_file *seq, void *v)
 {
 	struct nid_stat *stats = seq->private;
-	struct obd_device *obd = stats->nid_obd;
 
-	cfs_hash_for_each_key(obd->obd_nid_hash, &stats->nid,
-			      lprocfs_mdt_print_open_files, seq);
-
-	return 0;
+	return obd_nid_export_for_each(stats->nid_obd, stats->nid,
+				       lprocfs_mdt_print_open_files, seq);
 }
 
 int lprocfs_mdt_open_files_seq_open(struct inode *inode, struct file *file)
diff --git a/lustre/obdclass/genops.c b/lustre/obdclass/genops.c
index 84a8ce1..d7a65ec 100644
--- a/lustre/obdclass/genops.c
+++ b/lustre/obdclass/genops.c
@@ -1114,7 +1114,6 @@ struct obd_export *__class_new_export(struct obd_device *obd,
 	spin_lock_init(&export->exp_lock);
 	spin_lock_init(&export->exp_rpc_lock);
 	INIT_HLIST_NODE(&export->exp_uuid_hash);
-	INIT_HLIST_NODE(&export->exp_nid_hash);
 	INIT_HLIST_NODE(&export->exp_gen_hash);
 	spin_lock_init(&export->exp_bl_list_lock);
 	INIT_LIST_HEAD(&export->exp_bl_list);
@@ -1518,20 +1517,17 @@ int class_disconnect(struct obd_export *export)
 	export->exp_disconnected = 1;
 	/*  We hold references of export for uuid hash
 	 *  and nid_hash and export link at least. So
-	 *  it is safe to call cfs_hash_del in there.  */
-	if (!hlist_unhashed(&export->exp_nid_hash))
-		cfs_hash_del(export->exp_obd->obd_nid_hash,
-			     &export->exp_connection->c_peer.nid,
-			     &export->exp_nid_hash);
+	 *  it is safe to call cfs_hash_del in there.
+	 */
+	if (export != export->exp_obd->obd_self_export)
+		obd_nid_del(export->exp_obd, export);
 	spin_unlock(&export->exp_lock);
 
         /* class_cleanup(), abort_recovery(), and class_fail_export()
          * all end up in here, and if any of them race we shouldn't
          * call extra class_export_puts(). */
-        if (already_disconnected) {
-		LASSERT(hlist_unhashed(&export->exp_nid_hash));
+	if (already_disconnected)
                 GOTO(no_disconn, already_disconnected);
-        }
 
 	CDEBUG(D_IOCTL, "disconnect: cookie %#llx\n",
                export->exp_handle.h_cookie);
@@ -1719,11 +1715,10 @@ EXPORT_SYMBOL(class_fail_export);
 
 int obd_export_evict_by_nid(struct obd_device *obd, const char *nid)
 {
-	struct cfs_hash *nid_hash;
-	struct obd_export *doomed_exp = NULL;
-	int exports_evicted = 0;
-
 	lnet_nid_t nid_key = libcfs_str2nid((char *)nid);
+	struct obd_export *doomed_exp;
+	struct rhashtable_iter iter;
+	int exports_evicted = 0;
 
 	spin_lock(&obd->obd_dev_lock);
 	/* umount has run already, so evict thread should leave
@@ -1732,36 +1727,45 @@ int obd_export_evict_by_nid(struct obd_device *obd, const char *nid)
 		spin_unlock(&obd->obd_dev_lock);
 		return exports_evicted;
 	}
-	nid_hash = obd->obd_nid_hash;
-	cfs_hash_getref(nid_hash);
 	spin_unlock(&obd->obd_dev_lock);
 
-	do {
-		doomed_exp = cfs_hash_lookup(nid_hash, &nid_key);
-                if (doomed_exp == NULL)
-                        break;
+	rhltable_walk_enter(&obd->obd_nid_hash, &iter);
+	rhashtable_walk_start(&iter);
+	while ((doomed_exp = rhashtable_walk_next(&iter)) != NULL) {
+		if (IS_ERR(doomed_exp))
+			continue;
 
-                LASSERTF(doomed_exp->exp_connection->c_peer.nid == nid_key,
-                         "nid %s found, wanted nid %s, requested nid %s\n",
-                         obd_export_nid2str(doomed_exp),
-                         libcfs_nid2str(nid_key), nid);
-                LASSERTF(doomed_exp != obd->obd_self_export,
-                         "self-export is hashed by NID?\n");
-                exports_evicted++;
-		LCONSOLE_WARN("%s: evicting %s (at %s) by administrative "
-			      "request\n", obd->obd_name,
+		if (!doomed_exp->exp_connection ||
+		    doomed_exp->exp_connection->c_peer.nid != nid_key)
+			continue;
+
+		rhashtable_walk_stop(&iter);
+
+		LASSERTF(doomed_exp != obd->obd_self_export,
+			 "self-export is hashed by NID?\n");
+
+		LCONSOLE_WARN("%s: evicting %s (at %s) by administrative request\n",
+			      obd->obd_name,
 			      obd_uuid2str(&doomed_exp->exp_client_uuid),
 			      obd_export_nid2str(doomed_exp));
-                class_fail_export(doomed_exp);
-                class_export_put(doomed_exp);
-        } while (1);
 
-	cfs_hash_putref(nid_hash);
+		class_fail_export(doomed_exp);
+		class_export_put(doomed_exp);
+		obd_nid_del(obd, doomed_exp);
+		exports_evicted++;
 
-        if (!exports_evicted)
-                CDEBUG(D_HA,"%s: can't disconnect NID '%s': no exports found\n",
-                       obd->obd_name, nid);
-        return exports_evicted;
+		rhashtable_walk_start(&iter);
+	}
+
+	rhashtable_walk_stop(&iter);
+	rhashtable_walk_exit(&iter);
+
+	if (!exports_evicted) {
+		CDEBUG(D_HA,
+		      "%s: can't disconnect NID '%s': no exports found\n",
+		       obd->obd_name, nid);
+	}
+	return exports_evicted;
 }
 EXPORT_SYMBOL(obd_export_evict_by_nid);
 
diff --git a/lustre/obdclass/lprocfs_status_server.c b/lustre/obdclass/lprocfs_status_server.c
index f878de0..38f74b7 100644
--- a/lustre/obdclass/lprocfs_status_server.c
+++ b/lustre/obdclass/lprocfs_status_server.c
@@ -172,12 +172,10 @@ static int obd_export_flags2str(struct obd_export *exp, struct seq_file *m)
 }
 
 static int
-lprocfs_exp_print_export_seq(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-			     struct hlist_node *hnode, void *cb_data)
+lprocfs_exp_print_export_seq(struct obd_export *exp, void *cb_data)
 {
-	struct seq_file		*m = cb_data;
-	struct obd_export	*exp = cfs_hash_object(hs, hnode);
-	struct obd_device	*obd;
+	struct seq_file	*m = cb_data;
+	struct obd_device *obd;
 	struct obd_connect_data	*ocd;
 
 	LASSERT(exp != NULL);
@@ -231,11 +229,9 @@ out:
 static int lprocfs_exp_export_seq_show(struct seq_file *m, void *data)
 {
 	struct nid_stat *stats = m->private;
-	struct obd_device *obd = stats->nid_obd;
 
-	cfs_hash_for_each_key(obd->obd_nid_hash, &stats->nid,
-			      lprocfs_exp_print_export_seq, m);
-	return 0;
+	return obd_nid_export_for_each(stats->nid_obd, stats->nid,
+				       lprocfs_exp_print_export_seq, m);
 }
 LPROC_SEQ_FOPS_RO(lprocfs_exp_export);
 
@@ -281,64 +277,103 @@ void lprocfs_free_per_client_stats(struct obd_device *obd)
 EXPORT_SYMBOL(lprocfs_free_per_client_stats);
 
 static int
-lprocfs_exp_print_uuid_seq(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-			   struct hlist_node *hnode, void *cb_data)
+lprocfs_exp_print_nodemap_seq(struct obd_export *exp, void *cb_data)
 {
+	struct lu_nodemap *nodemap = exp->exp_target_data.ted_nodemap;
 	struct seq_file *m = cb_data;
-	struct obd_export *exp = cfs_hash_object(hs, hnode);
 
-	if (exp->exp_nid_stats != NULL)
-		seq_printf(m, "%s\n", obd_uuid2str(&exp->exp_client_uuid));
+	if (nodemap)
+		seq_printf(m, "%s\n", nodemap->nm_name);
 	return 0;
 }
 
 static int
-lprocfs_exp_print_nodemap_seq(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-			      struct hlist_node *hnode, void *cb_data)
+lprocfs_exp_nodemap_seq_show(struct seq_file *m, void *data)
 {
-	struct seq_file *m = cb_data;
-	struct obd_export *exp = cfs_hash_object(hs, hnode);
-	struct lu_nodemap *nodemap = exp->exp_target_data.ted_nodemap;
+	struct nid_stat *stats = m->private;
 
-	if (nodemap != NULL)
-		seq_printf(m, "%s\n", nodemap->nm_name);
-	return 0;
+	return obd_nid_export_for_each(stats->nid_obd, stats->nid,
+				       lprocfs_exp_print_nodemap_seq, m);
 }
+LPROC_SEQ_FOPS_RO(lprocfs_exp_nodemap);
 
 static int
-lprocfs_exp_nodemap_seq_show(struct seq_file *m, void *data)
+lprocfs_exp_print_uuid_seq(struct obd_export *exp, void *cb_data)
 {
-	struct nid_stat *stats = m->private;
-	struct obd_device *obd = stats->nid_obd;
+	struct seq_file *m = cb_data;
 
-	cfs_hash_for_each_key(obd->obd_nid_hash, &stats->nid,
-			      lprocfs_exp_print_nodemap_seq, m);
+	if (exp->exp_nid_stats)
+		seq_printf(m, "%s\n", obd_uuid2str(&exp->exp_client_uuid));
 	return 0;
 }
-LPROC_SEQ_FOPS_RO(lprocfs_exp_nodemap);
 
 static int lprocfs_exp_uuid_seq_show(struct seq_file *m, void *data)
 {
 	struct nid_stat *stats = m->private;
-	struct obd_device *obd = stats->nid_obd;
 
-	cfs_hash_for_each_key(obd->obd_nid_hash, &stats->nid,
-				lprocfs_exp_print_uuid_seq, m);
-	return 0;
+	return obd_nid_export_for_each(stats->nid_obd, stats->nid,
+				       lprocfs_exp_print_uuid_seq, m);
 }
 LPROC_SEQ_FOPS_RO(lprocfs_exp_uuid);
 
+static void ldebugfs_rhash_seq_show(const char *name, struct rhashtable *ht,
+				    struct seq_file *m)
+{
+/*	int dist[8] = { 0, };
+	int maxdep = -1;
+	int maxdepb = -1;
+	int total = 0;
+	int theta;
+	int i;
+
+	theta = __cfs_hash_theta(hs);
+
+*/
+	seq_printf(m, "%-*s %5d %5d %5d\n",
+		   CFS_HASH_BIGNAME_LEN, name, atomic_read(&ht->nelems),
+		   ht->p.min_size, ht->p.max_size);
+/*
+	seq_printf(m, "%-*s %5d %5d %5d %d.%03d %d.%03d %d.%03d  0x%02x %6d ",
+		   CFS_HASH_BIGNAME_LEN, hs->hs_name,
+		   1 << hs->hs_cur_bits, 1 << hs->hs_min_bits,
+		   1 << hs->hs_max_bits,
+		   __cfs_hash_theta_int(theta), __cfs_hash_theta_frac(theta),
+		   __cfs_hash_theta_int(hs->hs_min_theta),
+		   __cfs_hash_theta_frac(hs->hs_min_theta),
+		   __cfs_hash_theta_int(hs->hs_max_theta),
+		   __cfs_hash_theta_frac(hs->hs_max_theta),
+		   hs->hs_flags, hs->hs_rehash_count);
+
+	for (i = 0; i < cfs_hash_full_nbkt(hs); i++) {
+		struct cfs_hash_bd bd;
+
+		bd.bd_bucket = cfs_hash_full_bkts(hs)[i];
+		cfs_hash_bd_lock(hs, &bd, 0);
+		if (maxdep < bd.bd_bucket->hsb_depmax) {
+			maxdep  = bd.bd_bucket->hsb_depmax;
+			maxdepb = ffz(~maxdep);
+		}
+		total += bd.bd_bucket->hsb_count;
+		dist[min(fls(bd.bd_bucket->hsb_count / max(theta, 1)), 7)]++;
+		cfs_hash_bd_unlock(hs, &bd, 0);
+	}
+
+	seq_printf(m, "%7d %7d %7d ", total, maxdep, maxdepb);
+	for (i = 0; i < 8; i++)
+		seq_printf(m, "%d%c",  dist[i], (i == 7) ? '\n' : '/');
+*/
+}
+
 static int
-lprocfs_exp_print_hash_seq(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-			   struct hlist_node *hnode, void *cb_data)
+lprocfs_exp_print_hash_seq(struct obd_export *exp, void *cb_data)
 
 {
+	struct obd_device *obd = exp->exp_obd;
 	struct seq_file *m = cb_data;
-	struct obd_export *exp = cfs_hash_object(hs, hnode);
 
-	if (exp->exp_lock_hash != NULL) {
+	if (exp->exp_lock_hash) {
 		cfs_hash_debug_header(m);
-		cfs_hash_debug_str(hs, m);
+		ldebugfs_rhash_seq_show("NID_HASH", &obd->obd_nid_hash.ht, m);
 	}
 	return 0;
 }
@@ -346,26 +381,22 @@ lprocfs_exp_print_hash_seq(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 static int lprocfs_exp_hash_seq_show(struct seq_file *m, void *data)
 {
 	struct nid_stat *stats = m->private;
-	struct obd_device *obd = stats->nid_obd;
 
-	cfs_hash_for_each_key(obd->obd_nid_hash, &stats->nid,
-				lprocfs_exp_print_hash_seq, m);
-	return 0;
+	return obd_nid_export_for_each(stats->nid_obd, stats->nid,
+				       lprocfs_exp_print_hash_seq, m);
 }
 LPROC_SEQ_FOPS_RO(lprocfs_exp_hash);
 
-int lprocfs_exp_print_replydata_seq(struct cfs_hash *hs, struct cfs_hash_bd *bd,
-				    struct hlist_node *hnode, void *cb_data)
+int lprocfs_exp_print_replydata_seq(struct obd_export *exp, void *cb_data)
 
 {
-	struct obd_export *exp = cfs_hash_object(hs, hnode);
 	struct seq_file *m = cb_data;
 	struct tg_export_data *ted = &exp->exp_target_data;
 
 	seq_printf(m, "reply_cnt: %d\n"
-		   "reply_max: %d\n"
-		   "reply_released_by_xid: %d\n"
-		   "reply_released_by_tag: %d\n\n",
+		      "reply_max: %d\n"
+		      "reply_released_by_xid: %d\n"
+		      "reply_released_by_tag: %d\n\n",
 		   ted->ted_reply_cnt,
 		   ted->ted_reply_max,
 		   ted->ted_release_xid,
@@ -376,11 +407,9 @@ int lprocfs_exp_print_replydata_seq(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 int lprocfs_exp_replydata_seq_show(struct seq_file *m, void *data)
 {
 	struct nid_stat *stats = m->private;
-	struct obd_device *obd = stats->nid_obd;
 
-	cfs_hash_for_each_key(obd->obd_nid_hash, &stats->nid,
-				lprocfs_exp_print_replydata_seq, m);
-	return 0;
+	return obd_nid_export_for_each(stats->nid_obd, stats->nid,
+				       lprocfs_exp_print_replydata_seq, m);
 }
 LPROC_SEQ_FOPS_RO(lprocfs_exp_replydata);
 
@@ -624,7 +653,7 @@ int lprocfs_hash_seq_show(struct seq_file *m, void *data)
 
 	cfs_hash_debug_header(m);
 	cfs_hash_debug_str(obd->obd_uuid_hash, m);
-	cfs_hash_debug_str(obd->obd_nid_hash, m);
+	ldebugfs_rhash_seq_show("NID_HASH", &obd->obd_nid_hash.ht, m);
 	cfs_hash_debug_str(obd->obd_nid_stats_hash, m);
 	return 0;
 }
diff --git a/lustre/obdclass/obd_config.c b/lustre/obdclass/obd_config.c
index c4a20e6..448e7d8 100644
--- a/lustre/obdclass/obd_config.c
+++ b/lustre/obdclass/obd_config.c
@@ -50,10 +50,132 @@
 #include "llog_internal.h"
 
 static struct cfs_hash_ops uuid_hash_ops;
-static struct cfs_hash_ops nid_hash_ops;
 static struct cfs_hash_ops nid_stat_hash_ops;
 static struct cfs_hash_ops gen_hash_ops;
 
+/*
+ * nid<->export hash operations
+ */
+static u32 nid_keyhash(const void *data, u32 key_len, u32 seed)
+{
+	const struct obd_export *exp = data;
+	void *key;
+
+	if (!exp->exp_connection)
+		return 0;
+
+	key = &exp->exp_connection->c_peer.nid;
+	return jhash2(key, key_len / sizeof(u32), seed);
+}
+
+/*
+ * NOTE: It is impossible to find an export that is in failed
+ *       state with this function
+ */
+static int
+nid_keycmp(struct rhashtable_compare_arg *arg, const void *obj)
+{
+	const lnet_nid_t *nid = arg->key;
+	const struct obd_export *exp = obj;
+
+	if (exp->exp_connection->c_peer.nid == *nid && !exp->exp_failed)
+		return 0;
+
+	return -ESRCH;
+}
+
+static void
+nid_export_exit(void *vexport, void *data)
+{
+	struct obd_export *exp = vexport;
+
+	class_export_put(exp);
+}
+
+const struct rhashtable_params nid_hash_params = {
+	.key_len		= sizeof(lnet_nid_t),
+	.head_offset		= offsetof(struct obd_export, exp_nid_hash),
+	.obj_hashfn		= nid_keyhash,
+	.obj_cmpfn		= nid_keycmp,
+	.min_size		= 128,
+	.max_size		= 4096,
+	.automatic_shrinking	= true,
+};
+
+int obd_nid_add(struct obd_device *obd, struct obd_export *exp)
+{
+	struct rhlist_head *exp_list;
+	int rc;
+
+	rcu_read_lock();
+	exp_list = rhltable_lookup(&obd->obd_nid_hash,
+				   &exp->exp_connection->c_peer.nid,
+				   nid_hash_params);
+	if (exp_list) {
+		struct rhlist_head *pos;
+		struct obd_export *tmp;
+
+		rhl_for_each_entry_rcu(tmp, pos, exp_list, exp_nid_hash) {
+			if (tmp == exp) {
+				rcu_read_unlock();
+				return -EALREADY;
+			}
+		}
+	}
+	rcu_read_unlock();
+
+	rc = rhltable_insert_key(&obd->obd_nid_hash,
+				 &exp->exp_connection->c_peer.nid,
+				 &exp->exp_nid_hash,
+				 nid_hash_params);
+	if (rc == 0)
+		class_export_get(exp);
+	else
+		/* map obscure error codes to -ENOMEM */
+		rc = -ENOMEM;
+	return rc;
+}
+EXPORT_SYMBOL(obd_nid_add);
+
+void obd_nid_del(struct obd_device *obd, struct obd_export *exp)
+{
+	int rc;
+
+	rc = rhltable_remove(&obd->obd_nid_hash, &exp->exp_nid_hash,
+			     nid_hash_params);
+	if (rc == 0)
+		class_export_put(exp);
+}
+EXPORT_SYMBOL(obd_nid_del);
+
+int obd_nid_export_for_each(struct obd_device *obd, lnet_nid_t nid,
+			    int cb(struct obd_export *exp, void *data),
+			    void *data)
+{
+	struct rhlist_head *exports, *tmp;
+	struct obd_export *exp;
+	int err_cnt = 0;
+
+	rcu_read_lock();
+	exports = rhltable_lookup(&obd->obd_nid_hash, &nid, nid_hash_params);
+	if (!exports) {
+		err_cnt = -ENODEV;
+		goto out_unlock;
+	}
+
+	rhl_for_each_entry_rcu(exp,  tmp, exports, exp_nid_hash) {
+		if (cb(exp, data)) {
+			err_cnt++;
+			continue;
+		}
+	}
+
+out_unlock:
+	rcu_read_unlock();
+	return err_cnt;
+}
+EXPORT_SYMBOL(obd_nid_export_for_each);
+
 /*********** string parsing utils *********/
 
 /* returns 0 if we find this key in the buffer, else 1 */
@@ -474,7 +596,6 @@ int class_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
            other fns check that status, and we're not actually set up yet. */
         obd->obd_starting = 1;
         obd->obd_uuid_hash = NULL;
-        obd->obd_nid_hash = NULL;
         obd->obd_nid_stats_hash = NULL;
 	obd->obd_gen_hash = NULL;
 	spin_unlock(&obd->obd_dev_lock);
@@ -490,16 +611,10 @@ int class_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
         if (!obd->obd_uuid_hash)
 		GOTO(err_exit, err = -ENOMEM);
 
-        /* create a nid-export lustre hash */
-        obd->obd_nid_hash = cfs_hash_create("NID_HASH",
-                                            HASH_NID_CUR_BITS,
-                                            HASH_NID_MAX_BITS,
-                                            HASH_NID_BKT_BITS, 0,
-                                            CFS_HASH_MIN_THETA,
-                                            CFS_HASH_MAX_THETA,
-                                            &nid_hash_ops, CFS_HASH_DEFAULT);
-        if (!obd->obd_nid_hash)
-		GOTO(err_exit, err = -ENOMEM);
+	/* create a nid-export lustre hash */
+	err = rhltable_init(&obd->obd_nid_hash, &nid_hash_params);
+	if (err)
+		GOTO(err_exit, err);
 
         /* create a nid-stats lustre hash */
         obd->obd_nid_stats_hash = cfs_hash_create("NID_STATS",
@@ -543,10 +658,9 @@ err_exit:
                 cfs_hash_putref(obd->obd_uuid_hash);
                 obd->obd_uuid_hash = NULL;
         }
-        if (obd->obd_nid_hash) {
-                cfs_hash_putref(obd->obd_nid_hash);
-                obd->obd_nid_hash = NULL;
-        }
+
+	rhltable_destroy(&obd->obd_nid_hash);
+
         if (obd->obd_nid_stats_hash) {
                 cfs_hash_putref(obd->obd_nid_stats_hash);
                 obd->obd_nid_stats_hash = NULL;
@@ -673,10 +787,7 @@ int class_cleanup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	}
 
 	/* destroy a nid-export hash body */
-	if (obd->obd_nid_hash) {
-		cfs_hash_putref(obd->obd_nid_hash);
-		obd->obd_nid_hash = NULL;
-	}
+	rhltable_free_and_destroy(&obd->obd_nid_hash, nid_export_exit, NULL);
 
 	/* destroy a nid-stats hash body */
 	if (obd->obd_nid_stats_hash) {
@@ -2220,81 +2331,15 @@ static struct cfs_hash_ops uuid_hash_ops = {
         .hs_put_locked  = uuid_export_put_locked,
 };
 
-
 /*
- * nid<->export hash operations
+ * nid<->nidstats hash operations
  */
-
 static unsigned
-nid_hash(struct cfs_hash *hs, const void *key, unsigned mask)
-{
-        return cfs_hash_djb2_hash(key, sizeof(lnet_nid_t), mask);
-}
-
-static void *
-nid_key(struct hlist_node *hnode)
-{
-        struct obd_export *exp;
-
-	exp = hlist_entry(hnode, struct obd_export, exp_nid_hash);
-
-        RETURN(&exp->exp_connection->c_peer.nid);
-}
-
-/*
- * NOTE: It is impossible to find an export that is in failed
- *       state with this function
- */
-static int
-nid_kepcmp(const void *key, struct hlist_node *hnode)
-{
-        struct obd_export *exp;
-
-        LASSERT(key);
-	exp = hlist_entry(hnode, struct obd_export, exp_nid_hash);
-
-        RETURN(exp->exp_connection->c_peer.nid == *(lnet_nid_t *)key &&
-               !exp->exp_failed);
-}
-
-static void *
-nid_export_object(struct hlist_node *hnode)
-{
-	return hlist_entry(hnode, struct obd_export, exp_nid_hash);
-}
-
-static void
-nid_export_get(struct cfs_hash *hs, struct hlist_node *hnode)
+nidstats_hash(struct cfs_hash *hs, const void *key, unsigned int mask)
 {
-        struct obd_export *exp;
-
-	exp = hlist_entry(hnode, struct obd_export, exp_nid_hash);
-        class_export_get(exp);
+	return cfs_hash_djb2_hash(key, sizeof(lnet_nid_t), mask);
 }
 
-static void
-nid_export_put_locked(struct cfs_hash *hs, struct hlist_node *hnode)
-{
-        struct obd_export *exp;
-
-	exp = hlist_entry(hnode, struct obd_export, exp_nid_hash);
-        class_export_put(exp);
-}
-
-static struct cfs_hash_ops nid_hash_ops = {
-        .hs_hash        = nid_hash,
-        .hs_key         = nid_key,
-        .hs_keycmp      = nid_kepcmp,
-        .hs_object      = nid_export_object,
-        .hs_get         = nid_export_get,
-        .hs_put_locked  = nid_export_put_locked,
-};
-
-
-/*
- * nid<->nidstats hash operations
- */
-
 static void *
 nidstats_key(struct hlist_node *hnode)
 {
@@ -2336,7 +2381,7 @@ nidstats_put_locked(struct cfs_hash *hs, struct hlist_node *hnode)
 }
 
 static struct cfs_hash_ops nid_stat_hash_ops = {
-        .hs_hash        = nid_hash,
+	.hs_hash	= nidstats_hash,
         .hs_key         = nidstats_key,
         .hs_keycmp      = nidstats_keycmp,
         .hs_object      = nidstats_object,
-- 
1.8.3.1
