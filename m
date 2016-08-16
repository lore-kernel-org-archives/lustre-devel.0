From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:19:13 -0400
Subject: [lustre-devel] [PATCH 60/80] staging: lustre: ldlm: improve
	ldlm_lock_create() return value
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-61-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Emoly Liu <emoly.liu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Emoly Liu <emoly.liu@intel.com>

ldlm_lock_create() and ldlm_resource_get() always return NULL as
error reporting and "NULL" is interpretted as ENOMEM incorrectly
sometimes. This patch fixes this problem by using ERR_PTR() rather
than NULL.

Signed-off-by: Emoly Liu <emoly.liu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4524
Reviewed-on: http://review.whamcloud.com/9004
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |    4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |   28 ++++++++++++--------
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   13 +++-----
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   25 +++++------------
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_reint.c      |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 +-
 7 files changed, 34 insertions(+), 42 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 65e8e14..61d649f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -339,10 +339,10 @@ reprocess:
 						lock->l_granted_mode, &null_cbs,
 						NULL, 0, LVB_T_NONE);
 			lock_res_and_lock(req);
-			if (!new2) {
+			if (IS_ERR(new2)) {
 				ldlm_flock_destroy(req, lock->l_granted_mode,
 						   *flags);
-				*err = -ENOLCK;
+				*err = PTR_ERR(new2);
 				return LDLM_ITER_STOP;
 			}
 			goto reprocess;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 1a0fce1..a91cdb4 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -481,8 +481,8 @@ int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
 	unlock_res_and_lock(lock);
 
 	newres = ldlm_resource_get(ns, NULL, new_resid, type, 1);
-	if (!newres)
-		return -ENOMEM;
+	if (IS_ERR(newres))
+		return PTR_ERR(newres);
 
 	lu_ref_add(&newres->lr_reference, "lock", lock);
 	/*
@@ -1227,7 +1227,7 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
 	}
 
 	res = ldlm_resource_get(ns, NULL, res_id, type, 0);
-	if (!res) {
+	if (IS_ERR(res)) {
 		LASSERT(!old_lock);
 		return 0;
 	}
@@ -1475,15 +1475,15 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 {
 	struct ldlm_lock *lock;
 	struct ldlm_resource *res;
+	int rc;
 
 	res = ldlm_resource_get(ns, NULL, res_id, type, 1);
-	if (!res)
-		return NULL;
+	if (IS_ERR(res))
+		return ERR_CAST(res);
 
 	lock = ldlm_lock_new(res);
-
 	if (!lock)
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 
 	lock->l_req_mode = mode;
 	lock->l_ast_data = data;
@@ -1497,27 +1497,33 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 	lock->l_tree_node = NULL;
 	/* if this is the extent lock, allocate the interval tree node */
 	if (type == LDLM_EXTENT) {
-		if (!ldlm_interval_alloc(lock))
+		if (!ldlm_interval_alloc(lock)) {
+			rc = -ENOMEM;
 			goto out;
+		}
 	}
 
 	if (lvb_len) {
 		lock->l_lvb_len = lvb_len;
 		lock->l_lvb_data = kzalloc(lvb_len, GFP_NOFS);
-		if (!lock->l_lvb_data)
+		if (!lock->l_lvb_data) {
+			rc = -ENOMEM;
 			goto out;
+		}
 	}
 
 	lock->l_lvb_type = lvb_type;
-	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_NEW_LOCK))
+	if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_NEW_LOCK)) {
+		rc = -ENOENT;
 		goto out;
+	}
 
 	return lock;
 
 out:
 	ldlm_lock_destroy(lock);
 	LDLM_LOCK_RELEASE(lock);
-	return NULL;
+	return ERR_PTR(rc);
 }
 
 /**
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 984a460..048214c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -694,8 +694,8 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 		lock = ldlm_lock_create(ns, res_id, einfo->ei_type,
 					einfo->ei_mode, &cbs, einfo->ei_cbdata,
 					lvb_len, lvb_type);
-		if (!lock)
-			return -ENOMEM;
+		if (IS_ERR(lock))
+			return PTR_ERR(lock);
 		/* for the local lock, add the reference */
 		ldlm_lock_addref_internal(lock, einfo->ei_mode);
 		ldlm_lock2handle(lock, lockh);
@@ -1658,7 +1658,7 @@ int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
 	int rc;
 
 	res = ldlm_resource_get(ns, NULL, res_id, 0, 0);
-	if (!res) {
+	if (IS_ERR(res)) {
 		/* This is not a problem. */
 		CDEBUG(D_INFO, "No resource %llu\n", res_id->name[0]);
 		return 0;
@@ -1809,13 +1809,10 @@ int ldlm_resource_iterate(struct ldlm_namespace *ns,
 	struct ldlm_resource *res;
 	int rc;
 
-	if (!ns) {
-		CERROR("must pass in namespace\n");
-		LBUG();
-	}
+	LASSERTF(ns, "must pass in namespace\n");
 
 	res = ldlm_resource_get(ns, NULL, res_id, 0, 0);
-	if (!res)
+	if (IS_ERR(res))
 		return 0;
 
 	LDLM_RESOURCE_ADDREF(res);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 5866b00..c37a7b0 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -1088,7 +1088,7 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 		  int create)
 {
 	struct hlist_node     *hnode;
-	struct ldlm_resource *res;
+	struct ldlm_resource *res = NULL;
 	struct cfs_hash_bd	 bd;
 	__u64		 version;
 	int		      ns_refcount = 0;
@@ -1101,31 +1101,20 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 	hnode = cfs_hash_bd_lookup_locked(ns->ns_rs_hash, &bd, (void *)name);
 	if (hnode) {
 		cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 0);
-		res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
-		/* Synchronize with regard to resource creation. */
-		if (ns->ns_lvbo && ns->ns_lvbo->lvbo_init) {
-			mutex_lock(&res->lr_lvb_mutex);
-			mutex_unlock(&res->lr_lvb_mutex);
-		}
-
-		if (unlikely(res->lr_lvb_len < 0)) {
-			ldlm_resource_putref(res);
-			res = NULL;
-		}
-		return res;
+		goto lvbo_init;
 	}
 
 	version = cfs_hash_bd_version_get(&bd);
 	cfs_hash_bd_unlock(ns->ns_rs_hash, &bd, 0);
 
 	if (create == 0)
-		return NULL;
+		return ERR_PTR(-ENOENT);
 
 	LASSERTF(type >= LDLM_MIN_TYPE && type < LDLM_MAX_TYPE,
 		 "type: %d\n", type);
 	res = ldlm_resource_new();
 	if (!res)
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 
 	res->lr_ns_bucket  = cfs_hash_bd_extra_get(ns->ns_rs_hash, &bd);
 	res->lr_name       = *name;
@@ -1143,7 +1132,7 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 		/* We have taken lr_lvb_mutex. Drop it. */
 		mutex_unlock(&res->lr_lvb_mutex);
 		kmem_cache_free(ldlm_resource_slab, res);
-
+lvbo_init:
 		res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
 		/* Synchronize with regard to resource creation. */
 		if (ns->ns_lvbo && ns->ns_lvbo->lvbo_init) {
@@ -1153,7 +1142,7 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 
 		if (unlikely(res->lr_lvb_len < 0)) {
 			ldlm_resource_putref(res);
-			res = NULL;
+			res = ERR_PTR(res->lr_lvb_len);
 		}
 		return res;
 	}
@@ -1175,7 +1164,7 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 			res->lr_lvb_len = rc;
 			mutex_unlock(&res->lr_lvb_mutex);
 			ldlm_resource_putref(res);
-			return NULL;
+			return ERR_PTR(rc);
 		}
 	}
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 3291201..fab83dd 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -174,7 +174,7 @@ int mdc_null_inode(struct obd_export *exp,
 	fid_build_reg_res_name(fid, &res_id);
 
 	res = ldlm_resource_get(ns, NULL, &res_id, 0, 0);
-	if (!res)
+	if (IS_ERR(res))
 		return 0;
 
 	lock_res(res);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index 9bec049..0f71392 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -86,7 +86,7 @@ int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 	fid_build_reg_res_name(fid, &res_id);
 	res = ldlm_resource_get(exp->exp_obd->obd_namespace,
 				NULL, &res_id, 0, 0);
-	if (!res)
+	if (IS_ERR(res))
 		return 0;
 	LDLM_RESOURCE_ADDREF(res);
 	/* Initialize ibits lock policy. */
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index e5669e2..90c8416 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -650,7 +650,7 @@ static int osc_resource_get_unused(struct obd_export *exp, struct obdo *oa,
 
 	ostid_build_res_name(&oa->o_oi, &res_id);
 	res = ldlm_resource_get(ns, NULL, &res_id, 0, 0);
-	if (!res)
+	if (IS_ERR(res))
 		return 0;
 
 	LDLM_RESOURCE_ADDREF(res);
-- 
1.7.1
