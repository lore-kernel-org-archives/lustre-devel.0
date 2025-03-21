Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 26BBFC36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:31:29 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2sV5fHjz1xsl;
	Fri, 21 Mar 2025 06:11:58 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2nB6n5Bz1xf1
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:08:14 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm4-e204-208.ccs.ornl.gov [160.91.203.22])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 845D317B5A7;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 836EC106BE14; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:58 -0400
Message-ID: <20250321130711.3257092-16-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 15/27] lustre: convert mdc,
 mgc functions to static
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Timothy Day <timday@amazon.com>

Static analysis shows that a number of functions
could be made static. This patch declares several
functions in mdc, and mgc static.

Also, remove mgs_client_add() since it was unused, and
move a declaration from a c-file to the proper header file.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8191
Lustre-commit: 38d151f2f65d76fc3 ("LU-8191 lustre: convert mdc,mdd,mdt,mgc functions to static")
Signed-off-by: Timothy Day <timday@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51478
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_dev.c     | 67 +++++++++++++++++++------------------
 fs/lustre/mdc/mdc_request.c |  5 +--
 fs/lustre/mgc/lproc_mgc.c   |  8 ++---
 3 files changed, 42 insertions(+), 38 deletions(-)

diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index eccd9819ca56..672015546f3a 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -93,12 +93,13 @@ static int mdc_set_dom_lock_data(struct ldlm_lock *lock, void *data)
 	return set;
 }
 
-int mdc_dom_lock_match(const struct lu_env *env, struct obd_export *exp,
-		       struct ldlm_res_id *res_id, enum ldlm_type type,
-		       union ldlm_policy_data *policy, enum ldlm_mode mode,
-		       u64 *flags, struct osc_object *obj,
-		       struct lustre_handle *lockh,
-		       enum ldlm_match_flags match_flags)
+static int mdc_dom_lock_match(const struct lu_env *env, struct obd_export *exp,
+			      struct ldlm_res_id *res_id, enum ldlm_type type,
+			      union ldlm_policy_data *policy,
+			      enum ldlm_mode mode, u64 *flags,
+			      struct osc_object *obj,
+			      struct lustre_handle *lockh,
+			      enum ldlm_match_flags match_flags)
 {
 	struct obd_device *obd = exp->exp_obd;
 	u64 lflags = *flags;
@@ -135,9 +136,10 @@ int mdc_dom_lock_match(const struct lu_env *env, struct obd_export *exp,
  * Finds an existing lock covering a page with given index.
  * Copy of osc_obj_dlmlock_at_pgoff() but for DoM IBITS lock.
  */
-struct ldlm_lock *mdc_dlmlock_at_pgoff(const struct lu_env *env,
-				       struct osc_object *obj, pgoff_t index,
-				       enum osc_dap_flags dap_flags)
+static struct ldlm_lock *mdc_dlmlock_at_pgoff(const struct lu_env *env,
+					      struct osc_object *obj,
+					      pgoff_t index,
+					      enum osc_dap_flags dap_flags)
 {
 	struct osc_thread_info *info = osc_env_info(env);
 	struct ldlm_res_id *resname = &info->oti_resname;
@@ -278,8 +280,8 @@ static int mdc_lock_flush(const struct lu_env *env, struct osc_object *obj,
 	return result;
 }
 
-void mdc_lock_lockless_cancel(const struct lu_env *env,
-			      const struct cl_lock_slice *slice)
+static void mdc_lock_lockless_cancel(const struct lu_env *env,
+				     const struct cl_lock_slice *slice)
 {
 	struct osc_lock *ols = cl2osc_lock(slice);
 	struct osc_object *osc = cl2osc(slice->cls_obj);
@@ -570,10 +572,10 @@ int mdc_fill_lvb(struct req_capsule *pill, struct ost_lvb *lvb)
 	return 0;
 }
 
-int mdc_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
-		     osc_enqueue_upcall_f upcall, void *cookie,
-		     struct lustre_handle *lockh, enum ldlm_mode mode,
-		     u64 *flags, int errcode)
+static int mdc_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
+			    osc_enqueue_upcall_f upcall, void *cookie,
+			    struct lustre_handle *lockh, enum ldlm_mode mode,
+			    u64 *flags, int errcode)
 {
 	struct osc_lock *ols = cookie;
 	bool glimpse = *flags & LDLM_FL_HAS_INTENT;
@@ -627,8 +629,9 @@ int mdc_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	return rc;
 }
 
-int mdc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
-			  void *args, int rc)
+static int mdc_enqueue_interpret(const struct lu_env *env,
+				 struct ptlrpc_request *req,
+				 void *args, int rc)
 {
 	struct osc_enqueue_args *aa = args;
 	struct ldlm_lock *lock;
@@ -685,11 +688,11 @@ int mdc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
  * is excluded from the cluster -- such scenarious make the life difficult, so
  * release locks just after they are obtained.
  */
-int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
-		     struct ldlm_res_id *res_id, u64 *flags,
-		     union ldlm_policy_data *policy, struct ost_lvb *lvb,
-		     osc_enqueue_upcall_f upcall, void *cookie,
-		     struct ldlm_enqueue_info *einfo, int async)
+static int mdc_enqueue_send(const struct lu_env *env, struct obd_export *exp,
+			    struct ldlm_res_id *res_id, u64 *flags,
+			    union ldlm_policy_data *policy, struct ost_lvb *lvb,
+			    osc_enqueue_upcall_f upcall, void *cookie,
+			    struct ldlm_enqueue_info *einfo, int async)
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lustre_handle lockh = { 0 };
@@ -930,8 +933,8 @@ static const struct cl_lock_operations mdc_lock_ops = {
 	.clo_print	= osc_lock_print,
 };
 
-int mdc_lock_init(const struct lu_env *env, struct cl_object *obj,
-		  struct cl_lock *lock, const struct cl_io *io)
+static int mdc_lock_init(const struct lu_env *env, struct cl_object *obj,
+			 struct cl_lock *lock, const struct cl_io *io)
 {
 	struct osc_lock *ols;
 	u32 enqflags = lock->cll_descr.cld_enq_flags;
@@ -1150,8 +1153,8 @@ static int mdc_io_read_ahead(const struct lu_env *env,
 	return 0;
 }
 
-int mdc_io_fsync_start(const struct lu_env *env,
-		       const struct cl_io_slice *slice)
+static int mdc_io_fsync_start(const struct lu_env *env,
+			      const struct cl_io_slice *slice)
 {
 	struct cl_io *io = slice->cis_io;
 	struct cl_fsync_io *fio = &io->u.ci_fsync;
@@ -1345,8 +1348,8 @@ static const struct cl_io_operations mdc_io_ops = {
 	.cio_extent_release	= osc_io_extent_release,
 };
 
-int mdc_io_init(const struct lu_env *env, struct cl_object *obj,
-		struct cl_io *io)
+static int mdc_io_init(const struct lu_env *env, struct cl_object *obj,
+		       struct cl_io *io)
 {
 	struct osc_io *oio = osc_env_io(env);
 
@@ -1445,7 +1448,7 @@ static int mdc_object_ast_clear(struct ldlm_lock *lock, void *data)
 	return LDLM_ITER_CONTINUE;
 }
 
-int mdc_object_prune(const struct lu_env *env, struct cl_object *obj)
+static int mdc_object_prune(const struct lu_env *env, struct cl_object *obj)
 {
 	struct osc_object *osc = cl2osc(obj);
 	struct ldlm_res_id *resname = &osc_env_info(env)->oti_resname;
@@ -1514,9 +1517,9 @@ static const struct lu_object_operations mdc_lu_obj_ops = {
 	.loo_object_invariant	= NULL
 };
 
-struct lu_object *mdc_object_alloc(const struct lu_env *env,
-				   const struct lu_object_header *unused,
-				   struct lu_device *dev)
+static struct lu_object *mdc_object_alloc(const struct lu_env *env,
+					  const struct lu_object_header *unused,
+					  struct lu_device *dev)
 {
 	struct osc_object *osc;
 	struct lu_object *obj;
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index b9b962c6f723..ad625fbbd666 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2660,8 +2660,9 @@ struct mdc_rmfid_args {
 	int mra_nr;
 };
 
-int mdc_rmfid_interpret(const struct lu_env *env, struct ptlrpc_request *req,
-			  void *args, int rc)
+static int mdc_rmfid_interpret(const struct lu_env *env,
+			       struct ptlrpc_request *req,
+			       void *args, int rc)
 {
 	struct mdc_rmfid_args *aa;
 	int *rcs, size;
diff --git a/fs/lustre/mgc/lproc_mgc.c b/fs/lustre/mgc/lproc_mgc.c
index 6a945c5b9b93..7bda1e289eb5 100644
--- a/fs/lustre/mgc/lproc_mgc.c
+++ b/fs/lustre/mgc/lproc_mgc.c
@@ -70,8 +70,8 @@ LUSTRE_RO_ATTR(conn_uuid);
 
 LUSTRE_RW_ATTR(ping);
 
-ssize_t dynamic_nids_show(struct kobject *kobj, struct attribute *attr,
-			  char *buf)
+static ssize_t dynamic_nids_show(struct kobject *kobj, struct attribute *attr,
+				 char *buf)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
@@ -79,8 +79,8 @@ ssize_t dynamic_nids_show(struct kobject *kobj, struct attribute *attr,
 	return scnprintf(buf, PAGE_SIZE, "%u\n", obd->obd_dynamic_nids);
 }
 
-ssize_t dynamic_nids_store(struct kobject *kobj, struct attribute *attr,
-			   const char *buffer, size_t count)
+static ssize_t dynamic_nids_store(struct kobject *kobj, struct attribute *attr,
+				  const char *buffer, size_t count)
 {
 	struct obd_device *obd = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
