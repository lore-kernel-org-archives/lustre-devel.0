Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 91C6CECAAA1
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:55:58 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7lK5tKjz1y7R;
	Mon,  5 Sep 2022 18:55:57 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7l32DXDz1y4v
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:43 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id AA038100AFF7;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9C12B58999; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:16 -0400
Message-Id: <1662429337-18737-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/24] lustre: ldlm: rid of obsolete param of
 ldlm_resource_get()
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Bobi Jam <bobijam@whamcloud.com>

The second parameter @parent of ldlm_resource_get() is obsolete, just
remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8238
Lustre-commit: bab7c8998a6539c0d ("LU-8238 ldlm: rid of obsolete param of ldlm_resource_get()")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/20631
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h | 1 -
 fs/lustre/ldlm/ldlm_lock.c     | 6 +++---
 fs/lustre/ldlm/ldlm_request.c  | 4 ++--
 fs/lustre/ldlm/ldlm_resource.c | 6 ++----
 fs/lustre/mdc/mdc_dev.c        | 5 +++--
 fs/lustre/mdc/mdc_locks.c      | 2 +-
 fs/lustre/mdc/mdc_reint.c      | 2 +-
 fs/lustre/osc/osc_object.c     | 6 +++---
 fs/lustre/osc/osc_request.c    | 2 +-
 9 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 9286bec..6053e01 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -1287,7 +1287,6 @@ static inline void ldlm_svc_get_eopc(const struct ldlm_request *dlm_req,
 
 /* resource.c - internal */
 struct ldlm_resource *ldlm_resource_get(struct ldlm_namespace *ns,
-					struct ldlm_resource *parent,
 					const struct ldlm_res_id *,
 					enum ldlm_type type, int create);
 struct ldlm_resource *ldlm_resource_getref(struct ldlm_resource *res);
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 4225c0b..39ab2a0 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -447,7 +447,7 @@ int ldlm_lock_change_resource(struct ldlm_namespace *ns, struct ldlm_lock *lock,
 	type = oldres->lr_type;
 	unlock_res_and_lock(lock);
 
-	newres = ldlm_resource_get(ns, NULL, new_resid, type, 1);
+	newres = ldlm_resource_get(ns, new_resid, type, 1);
 	if (IS_ERR(newres))
 		return PTR_ERR(newres);
 
@@ -1308,7 +1308,7 @@ enum ldlm_mode ldlm_lock_match_with_skip(struct ldlm_namespace *ns,
 		*data.lmd_mode = data.lmd_old->l_req_mode;
 	}
 
-	res = ldlm_resource_get(ns, NULL, res_id, type, 0);
+	res = ldlm_resource_get(ns, res_id, type, 0);
 	if (IS_ERR(res)) {
 		LASSERT(!data.lmd_old);
 		return 0;
@@ -1537,7 +1537,7 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 	struct ldlm_resource *res;
 	int rc;
 
-	res = ldlm_resource_get(ns, NULL, res_id, type, 1);
+	res = ldlm_resource_get(ns, res_id, type, 1);
 	if (IS_ERR(res))
 		return ERR_CAST(res);
 
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 4ba64b1..f59778e 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1887,7 +1887,7 @@ int ldlm_cli_cancel_unused_resource(struct ldlm_namespace *ns,
 	int count;
 	int rc;
 
-	res = ldlm_resource_get(ns, NULL, res_id, 0, 0);
+	res = ldlm_resource_get(ns, res_id, 0, 0);
 	if (IS_ERR(res)) {
 		/* This is not a problem. */
 		CDEBUG(D_INFO, "No resource %llu\n", res_id->name[0]);
@@ -2039,7 +2039,7 @@ int ldlm_resource_iterate(struct ldlm_namespace *ns,
 
 	LASSERTF(ns, "must pass in namespace\n");
 
-	res = ldlm_resource_get(ns, NULL, res_id, 0, 0);
+	res = ldlm_resource_get(ns, res_id, 0, 0);
 	if (IS_ERR(res))
 		return 0;
 
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index d4b6e41..a189dbd 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -1105,9 +1105,8 @@ static struct ldlm_resource *ldlm_resource_new(enum ldlm_type ldlm_type)
  * Returns: referenced, unlocked ldlm_resource or NULL
  */
 struct ldlm_resource *
-ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
-		  const struct ldlm_res_id *name, enum ldlm_type type,
-		  int create)
+ldlm_resource_get(struct ldlm_namespace *ns, const struct ldlm_res_id *name,
+		  enum ldlm_type type, int create)
 {
 	struct hlist_node *hnode;
 	struct ldlm_resource *res = NULL;
@@ -1116,7 +1115,6 @@ struct ldlm_resource *
 	int ns_refcount = 0;
 	int hash;
 
-	LASSERT(!parent);
 	LASSERT(ns->ns_rs_hash);
 	LASSERT(name->name[0] != 0);
 
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index de67720..fd0e362 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -998,13 +998,14 @@ static int mdc_get_lock_handle(const struct lu_env *env, struct osc_object *osc,
 				    OSC_DAP_FL_TEST_LOCK |
 				    OSC_DAP_FL_CANCELING);
 	if (!lock) {
+		struct ldlm_namespace *ns;
 		struct ldlm_resource *res;
 		struct ldlm_res_id *resname;
 
 		resname = &osc_env_info(env)->oti_resname;
 		fid_build_reg_res_name(lu_object_fid(osc2lu(osc)), resname);
-		res = ldlm_resource_get(osc_export(osc)->exp_obd->obd_namespace,
-					NULL, resname, LDLM_IBITS, 0);
+		ns = osc_export(osc)->exp_obd->obd_namespace;
+		res = ldlm_resource_get(ns, resname, LDLM_IBITS, 0);
 		ldlm_resource_dump(D_ERROR, res);
 		libcfs_debug_dumpstack(NULL);
 		rc = -ENOENT;
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 2a9b9a8..ae55cc3 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -177,7 +177,7 @@ int mdc_null_inode(struct obd_export *exp,
 
 	fid_build_reg_res_name(fid, &res_id);
 
-	res = ldlm_resource_get(ns, NULL, &res_id, 0, 0);
+	res = ldlm_resource_get(ns, &res_id, 0, 0);
 	if (IS_ERR(res))
 		return 0;
 
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index 3f4e28a..4d33655 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -81,7 +81,7 @@ int mdc_resource_get_unused_res(struct obd_export *exp,
 	if (exp_connect_cancelset(exp) && !ns_connect_cancelset(ns))
 		return 0;
 
-	res = ldlm_resource_get(ns, NULL, res_id, 0, 0);
+	res = ldlm_resource_get(ns, res_id, 0, 0);
 	if (IS_ERR(res))
 		return 0;
 	LDLM_RESOURCE_ADDREF(res);
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index 517ce5c..efb0533 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -389,6 +389,7 @@ static void osc_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 		lock = osc_dlmlock_at_pgoff(env, cl2osc(obj), osc_index(opg),
 					    OSC_DAP_FL_TEST_LOCK | OSC_DAP_FL_CANCELING);
 		if (!lock && !opg->ops_srvlock) {
+			struct ldlm_namespace *ns;
 			struct ldlm_resource *res;
 			struct ldlm_res_id *resname;
 
@@ -397,9 +398,8 @@ static void osc_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 
 			resname = &osc_env_info(env)->oti_resname;
 			ostid_build_res_name(&oinfo->loi_oi, resname);
-			res = ldlm_resource_get(
-				osc_export(cl2osc(obj))->exp_obd->obd_namespace,
-				NULL, resname, LDLM_EXTENT, 0);
+			ns = osc_export(cl2osc(obj))->exp_obd->obd_namespace;
+			res = ldlm_resource_get(ns, resname, LDLM_EXTENT, 0);
 			ldlm_resource_dump(D_ERROR, res);
 			libcfs_debug_dumpstack(NULL);
 			LBUG();
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 21e036e..5a4db29 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -587,7 +587,7 @@ static int osc_resource_get_unused(struct obd_export *exp, struct obdo *oa,
 		return 0;
 
 	ostid_build_res_name(&oa->o_oi, &res_id);
-	res = ldlm_resource_get(ns, NULL, &res_id, 0, 0);
+	res = ldlm_resource_get(ns, &res_id, 0, 0);
 	if (IS_ERR(res))
 		return 0;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
