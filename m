From: Oleg Drokin <green@linuxhacker.ru>
Date: Mon, 20 Jun 2016 16:55:36 -0400
Subject: [lustre-devel] [PATCH v2 13/29] staging/lustre: LDLM_DEBUG()
	shouldn't be passed \n
In-Reply-To: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
References: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466456152-2199975-14-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alex Zhuravlev <alexey.zhuravlev@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Alex Zhuravlev <alexey.zhuravlev@intel.com>

as it adds own \n, so any extra \n break log format.

Signed-off-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-on: http://review.whamcloud.com/17494
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7521
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 3 ++-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 2 +-
 drivers/staging/lustre/lustre/lov/lov_object.c     | 4 ++--
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      | 2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      | 4 ++--
 drivers/staging/lustre/lustre/osc/osc_lock.c       | 2 +-
 8 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 1ecdfa2..b7254eb 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1440,7 +1440,7 @@ int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
 		memcpy(data, lvb, size);
 		break;
 	default:
-		LDLM_ERROR(lock, "Unknown LVB type: %d\n", lock->l_lvb_type);
+		LDLM_ERROR(lock, "Unknown LVB type: %d", lock->l_lvb_type);
 		dump_stack();
 		return -EINVAL;
 	}
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 3eab059..8294703 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -637,7 +637,8 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 		 */
 		if ((ldlm_is_canceling(lock) && ldlm_is_bl_done(lock)) ||
 		    ldlm_is_failed(lock)) {
-			LDLM_DEBUG(lock, "callback on lock %#llx - lock disappeared\n",
+			LDLM_DEBUG(lock,
+				   "callback on lock %#llx - lock disappeared",
 				   dlm_req->lock_handle[0].cookie);
 			unlock_res_and_lock(lock);
 			LDLM_LOCK_RELEASE(lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 471ab08..d3a376e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -711,7 +711,7 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 
 			lock->l_req_extent = policy->l_extent;
 		}
-		LDLM_DEBUG(lock, "client-side enqueue START, flags %llx\n",
+		LDLM_DEBUG(lock, "client-side enqueue START, flags %llx",
 			   *flags);
 	}
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index f7c95b7..51a28d9 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -1275,7 +1275,7 @@ void ldlm_resource_add_lock(struct ldlm_resource *res, struct list_head *head,
 {
 	check_res_locked(res);
 
-	LDLM_DEBUG(lock, "About to add this lock:\n");
+	LDLM_DEBUG(lock, "About to add this lock:");
 
 	if (ldlm_is_destroyed(lock)) {
 		CDEBUG(D_OTHER, "Lock destroyed, not adding to resource\n");
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index ec55b88..f9621b0 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -181,8 +181,8 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 		}
 
 		LU_OBJECT_DEBUG(mask, env, &stripe->co_lu,
-				"stripe %d is already owned.\n", idx);
-		LU_OBJECT_DEBUG(mask, env, old_obj, "owned.\n");
+				"stripe %d is already owned.", idx);
+		LU_OBJECT_DEBUG(mask, env, old_obj, "owned.");
 		LU_OBJECT_HEADER(mask, env, lov2lu(lov), "try to own.\n");
 		cl_object_put(env, stripe);
 	}
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index b395420..19b549c 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -711,7 +711,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 	if (lock && ldlm_has_layout(lock) && lvb_data) {
 		void *lmm;
 
-		LDLM_DEBUG(lock, "layout lock returned by: %s, lvb_len: %d\n",
+		LDLM_DEBUG(lock, "layout lock returned by: %s, lvb_len: %d",
 			   ldlm_it2str(it->it_op), lvb_len);
 
 		lmm = libcfs_kvzalloc(lvb_len, GFP_NOFS);
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 1a6df43..e3b9f9d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -123,9 +123,9 @@ static const char *oes_strings[] = {
 		/* ----- part 4 ----- */				      \
 		## __VA_ARGS__);					      \
 	if (lvl == D_ERROR && __ext->oe_dlmlock)			      \
-		LDLM_ERROR(__ext->oe_dlmlock, "extent: %p\n", __ext);	      \
+		LDLM_ERROR(__ext->oe_dlmlock, "extent: %p", __ext);	      \
 	else								      \
-		LDLM_DEBUG(__ext->oe_dlmlock, "extent: %p\n", __ext);	      \
+		LDLM_DEBUG(__ext->oe_dlmlock, "extent: %p", __ext);	      \
 } while (0)
 
 #undef EASSERTF
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 5455d9d..717d3ff 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -1168,7 +1168,7 @@ int osc_lock_init(const struct lu_env *env,
 		osc_lock_set_writer(env, io, obj, oscl);
 
 
-	LDLM_DEBUG_NOLOCK("lock %p, osc lock %p, flags %llx\n",
+	LDLM_DEBUG_NOLOCK("lock %p, osc lock %p, flags %llx",
 			  lock, oscl, oscl->ols_flags);
 
 	return 0;
-- 
2.7.4
