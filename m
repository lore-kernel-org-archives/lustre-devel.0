From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:49 -0500
Subject: [lustre-devel] [PATCH 16/28] lustre: ldlm: group locks for DOM IBIT
 lock
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vitaly Fertman <c17818@cray.com>

Group lock is supposed to be taken on such operations as layout swap
used for e.g. HSM, and is to be taken for DOM locks as well.

HPE-bug-id: LUS-8987
WC-bug-id: https://jira.whamcloud.com/browse/LU-13645
Lustre-commit: 06740440363424 (LU-13645 ldlm: group locks for DOM IBIT lock")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Reviewed-on: https://review.whamcloud.com/39406
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_inodebits.c        |  2 ++
 fs/lustre/ldlm/ldlm_lock.c             | 12 ++++++++++--
 fs/lustre/mdc/mdc_dev.c                | 10 ++++++++--
 fs/lustre/ptlrpc/wiretest.c            |  6 +++++-
 include/uapi/linux/lustre/lustre_idl.h |  1 +
 5 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_inodebits.c b/fs/lustre/ldlm/ldlm_inodebits.c
index 2288eb5..a367ff1 100644
--- a/fs/lustre/ldlm/ldlm_inodebits.c
+++ b/fs/lustre/ldlm/ldlm_inodebits.c
@@ -59,6 +59,7 @@ void ldlm_ibits_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				     union ldlm_policy_data *lpolicy)
 {
 	lpolicy->l_inodebits.bits = wpolicy->l_inodebits.bits;
+	lpolicy->l_inodebits.li_gid = wpolicy->l_inodebits.li_gid;
 }
 
 void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
@@ -66,6 +67,7 @@ void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
 {
 	memset(wpolicy, 0, sizeof(*wpolicy));
 	wpolicy->l_inodebits.bits = lpolicy->l_inodebits.bits;
+	wpolicy->l_inodebits.li_gid = lpolicy->l_inodebits.li_gid;
 }
 
 /**
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 0dbd4f3..56f1550 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -1111,6 +1111,12 @@ static bool lock_matches(struct ldlm_lock *lock, void *vdata)
 		     data->lmd_policy->l_inodebits.bits) !=
 		    data->lmd_policy->l_inodebits.bits)
 			return false;
+
+		if (unlikely(match == LCK_GROUP) &&
+		    data->lmd_policy->l_inodebits.li_gid != LDLM_GID_ANY &&
+		    lpol->l_inodebits.li_gid !=
+		    data->lmd_policy->l_inodebits.li_gid)
+			return false;
 		break;
 	default:
 		break;
@@ -1903,7 +1909,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 	switch (resource->lr_type) {
 	case LDLM_EXTENT:
 		libcfs_debug_msg(msgdata,
-				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s [%llu->%llu] (req %llu->%llu) flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lld lvb_type: %d\n",
+				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " rrc: %d type: %s [%llu->%llu] (req %llu->%llu) gid %llu flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lld lvb_type: %d\n",
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock), lock,
 				 lock->l_handle.h_cookie,
@@ -1918,6 +1924,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 lock->l_policy_data.l_extent.end,
 				 lock->l_req_extent.start,
 				 lock->l_req_extent.end,
+				 lock->l_req_extent.gid,
 				 lock->l_flags, nid,
 				 lock->l_remote_handle.cookie,
 				 exp ? refcount_read(&exp->exp_handle.h_ref) : -99,
@@ -1949,7 +1956,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 
 	case LDLM_IBITS:
 		libcfs_debug_msg(msgdata,
-				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " bits %#llx rrc: %d type: %s flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lld lvb_type: %d\n",
+				 "%pV ns: %s lock: %p/%#llx lrc: %d/%d,%d mode: %s/%s res: " DLDLMRES " bits %#llx rrc: %d type: %s gid %llu flags: %#llx nid: %s remote: %#llx expref: %d pid: %u timeout: %lld lvb_type: %d\n",
 				 &vaf,
 				 ldlm_lock_to_ns_name(lock),
 				 lock, lock->l_handle.h_cookie,
@@ -1961,6 +1968,7 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 				 lock->l_policy_data.l_inodebits.bits,
 				 atomic_read(&resource->lr_refcount),
 				 ldlm_typename[resource->lr_type],
+				 lock->l_policy_data.l_inodebits.li_gid,
 				 lock->l_flags, nid,
 				 lock->l_remote_handle.cookie,
 				 exp ? refcount_read(&exp->exp_handle.h_ref) : -99,
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 329371b..90b60f5 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -40,10 +40,13 @@
 #include "mdc_internal.h"
 
 static void mdc_lock_build_policy(const struct lu_env *env,
+				  const struct cl_lock *lock,
 				  union ldlm_policy_data *policy)
 {
 	memset(policy, 0, sizeof(*policy));
 	policy->l_inodebits.bits = MDS_INODELOCK_DOM;
+	if (lock)
+		policy->l_inodebits.li_gid = lock->cll_descr.cld_gid;
 }
 
 int mdc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
@@ -144,7 +147,8 @@ struct ldlm_lock *mdc_dlmlock_at_pgoff(const struct lu_env *env,
 	enum ldlm_match_flags match_flags = 0;
 
 	fid_build_reg_res_name(lu_object_fid(osc2lu(obj)), resname);
-	mdc_lock_build_policy(env, policy);
+	mdc_lock_build_policy(env, NULL, policy);
+	policy->l_inodebits.li_gid = LDLM_GID_ANY;
 
 	flags = LDLM_FL_BLOCK_GRANTED | LDLM_FL_CBPENDING;
 	if (dap_flags & OSC_DAP_FL_TEST_LOCK)
@@ -867,7 +871,7 @@ static int mdc_lock_enqueue(const struct lu_env *env,
 	 * osc_lock.
 	 */
 	fid_build_reg_res_name(lu_object_fid(osc2lu(osc)), resname);
-	mdc_lock_build_policy(env, policy);
+	mdc_lock_build_policy(env, lock, policy);
 	LASSERT(!oscl->ols_speculative);
 	result = mdc_enqueue_send(env, osc_export(osc), resname,
 				  &oscl->ols_flags, policy,
@@ -931,6 +935,8 @@ int mdc_lock_init(const struct lu_env *env, struct cl_object *obj,
 
 	ols->ols_flags = flags;
 	ols->ols_speculative = !!(enqflags & CEF_SPECULATIVE);
+	if (lock->cll_descr.cld_mode == CLM_GROUP)
+		ols->ols_flags |= LDLM_FL_ATOMIC_CB;
 
 	if (ols->ols_flags & LDLM_FL_HAS_INTENT) {
 		ols->ols_flags |= LDLM_FL_BLOCK_GRANTED;
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 556aaff..9b1caf4 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -3249,12 +3249,16 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)sizeof(((struct ldlm_extent *)0)->gid));
 
 	/* Checks for struct ldlm_inodebits */
-	LASSERTF((int)sizeof(struct ldlm_inodebits) == 16, "found %lld\n",
+	LASSERTF((int)sizeof(struct ldlm_inodebits) == 24, "found %lld\n",
 		 (long long)(int)sizeof(struct ldlm_inodebits));
 	LASSERTF((int)offsetof(struct ldlm_inodebits, bits) == 0, "found %lld\n",
 		 (long long)(int)offsetof(struct ldlm_inodebits, bits));
 	LASSERTF((int)sizeof(((struct ldlm_inodebits *)0)->bits) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct ldlm_inodebits *)0)->bits));
+	LASSERTF((int)offsetof(struct ldlm_inodebits, li_gid) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct ldlm_inodebits, li_gid));
+	LASSERTF((int)sizeof(((struct ldlm_inodebits *)0)->li_gid) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct ldlm_inodebits *)0)->li_gid));
 
 	/* Checks for struct ldlm_flock_wire */
 	LASSERTF((int)sizeof(struct ldlm_flock_wire) == 32, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index fda56d8..34b2367 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2206,6 +2206,7 @@ static inline bool ldlm_extent_equal(const struct ldlm_extent *ex1,
 struct ldlm_inodebits {
 	__u64 bits;
 	__u64 cancel_bits; /* for lock convert */
+	__u64 li_gid;
 };
 
 struct ldlm_flock_wire {
-- 
1.8.3.1
