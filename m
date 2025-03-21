Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A7C17C36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:08:30 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2mb511Zz1xfB;
	Fri, 21 Mar 2025 06:07:43 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2m526mVz1xNs
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:07:17 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 60FD817D1DE;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 5D14C106BE16; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:48 -0400
Message-ID: <20250321130711.3257092-6-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 05/27] lustre: nrs: Fix console messages
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Etienne AUJAMES <eaujames@ddn.com>

Fix format of console messages and missing end-of-line.

CERROR("%s.%d NRS: ....", service_name, cpt, ...);

Fixes: f5e513a ("lustre: nrs: change nrs policies at run time")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16846
Lustre-commit: c1915c5f0dd865c13 ("LU-16846 nrs: Fix console messages")
Signed-off-by: Etienne AUJAMES <eaujames@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51121
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Timothy Day <timday@amazon.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/nrs.c | 70 +++++++++++++++++++++++++-----------------
 1 file changed, 42 insertions(+), 28 deletions(-)

diff --git a/fs/lustre/ptlrpc/nrs.c b/fs/lustre/ptlrpc/nrs.c
index 661bba7a0f06..eb0e65b6ddb7 100644
--- a/fs/lustre/ptlrpc/nrs.c
+++ b/fs/lustre/ptlrpc/nrs.c
@@ -209,6 +209,8 @@ static void nrs_policy_stop_primary(struct ptlrpc_nrs *nrs)
 static int nrs_policy_start_locked(struct ptlrpc_nrs_policy *policy, char *arg)
 {
 	struct ptlrpc_nrs *nrs = policy->pol_nrs;
+	struct ptlrpc_service_part *svcpt = nrs->nrs_svcpt;
+	char *srv_name = svcpt->scp_service->srv_name;
 	int rc = 0;
 
 	/**
@@ -224,8 +226,10 @@ static int nrs_policy_start_locked(struct ptlrpc_nrs_policy *policy, char *arg)
 		return -EAGAIN;
 
 	if (arg && strlen(arg) >= sizeof(policy->pol_arg)) {
-		CWARN("NRS: arg '%s' is too long\n", arg);
-		return -EINVAL;
+		rc = -EINVAL;
+		CWARN("%s.%d NRS: arg '%s' is too long: rc = %d\n",
+		      srv_name, svcpt->scp_cpt, arg, rc);
+		return rc;
 	}
 
 	if (policy->pol_flags & PTLRPC_NRS_FL_FALLBACK) {
@@ -277,9 +281,10 @@ static int nrs_policy_start_locked(struct ptlrpc_nrs_policy *policy, char *arg)
 	if (atomic_inc_return(&policy->pol_desc->pd_refs) == 1 &&
 	    !try_module_get(policy->pol_desc->pd_owner)) {
 		atomic_dec(&policy->pol_desc->pd_refs);
-		CERROR("NRS: cannot get module for policy %s; is it alive?\n",
-		       policy->pol_desc->pd_name);
-		return -ENODEV;
+		rc = -ENODEV;
+		CERROR("%s.%d NRS: cannot get module for policy %s (is it alive?): rc = %d\n",
+		       srv_name, svcpt->scp_cpt, policy->pol_desc->pd_name, rc);
+		return rc;
 	}
 
 	/**
@@ -713,6 +718,8 @@ static int nrs_policy_ctl(struct ptlrpc_nrs *nrs, char *name,
 static int nrs_policy_unregister(struct ptlrpc_nrs *nrs, char *name)
 {
 	struct ptlrpc_nrs_policy *policy = NULL;
+	struct ptlrpc_service_part *svcpt = nrs->nrs_svcpt;
+	char *srv_name = svcpt->scp_service->srv_name;
 	int rc = 0;
 
 	spin_lock(&nrs->nrs_lock);
@@ -720,14 +727,15 @@ static int nrs_policy_unregister(struct ptlrpc_nrs *nrs, char *name)
 	policy = nrs_policy_find_locked(nrs, name);
 	if (!policy) {
 		rc = -ENOENT;
-		CERROR("NRS: cannot find policy '%s': rc = %d\n", name, rc);
+		CERROR("%s.%d NRS: cannot find policy '%s': rc = %d\n",
+		       srv_name, svcpt->scp_cpt, name, rc);
 		goto out_unlock;
 	}
 
 	if (policy->pol_ref > 1) {
 		rc = -EBUSY;
-		CERROR("NRS: policy '%s' is busy with %ld references: rc = %d",
-		       name, policy->pol_ref, rc);
+		CERROR("%s.%d NRS: policy '%s' is busy with %ld references: rc = %d\n",
+			srv_name, svcpt->scp_cpt, name, policy->pol_ref, rc);
 		goto out_put;
 	}
 
@@ -737,8 +745,9 @@ static int nrs_policy_unregister(struct ptlrpc_nrs *nrs, char *name)
 	if (policy->pol_state != NRS_POL_STATE_STOPPED) {
 		rc = nrs_policy_stop_locked(policy);
 		if (rc) {
-			CERROR("NRS: failed to stop policy '%s' with refcount %d: rc = %d\n",
-			       name, refcount_read(&policy->pol_start_ref), rc);
+			CERROR("%s.%d NRS: failed to stop policy '%s' with refcount %d: rc = %d\n",
+			       srv_name, svcpt->scp_cpt, name,
+			       refcount_read(&policy->pol_start_ref), rc);
 			goto out_put;
 		}
 	}
@@ -775,6 +784,7 @@ static int nrs_policy_register(struct ptlrpc_nrs *nrs,
 	struct ptlrpc_nrs_policy *policy;
 	struct ptlrpc_nrs_policy *tmp;
 	struct ptlrpc_service_part *svcpt = nrs->nrs_svcpt;
+	char *srv_name = svcpt->scp_service->srv_name;
 	int rc;
 
 	LASSERT(desc->pd_ops->op_res_get);
@@ -809,16 +819,17 @@ static int nrs_policy_register(struct ptlrpc_nrs *nrs,
 
 	tmp = nrs_policy_find_locked(nrs, policy->pol_desc->pd_name);
 	if (tmp) {
-		CERROR("NRS policy %s has been registered, can't register it for %s\n",
-		       policy->pol_desc->pd_name,
-		       svcpt->scp_service->srv_name);
+		rc = -EEXIST;
+		CERROR("%s.%d NRS: policy %s has been registered, can't register it: rc = %d\n",
+		       srv_name, svcpt->scp_cpt, policy->pol_desc->pd_name,
+		       rc);
 		nrs_policy_put_locked(tmp);
 
 		spin_unlock(&nrs->nrs_lock);
 		nrs_policy_fini(policy);
 		kfree(policy);
 
-		return -EEXIST;
+		return rc;
 	}
 
 	list_add_tail(&policy->pol_list, &nrs->nrs_policy_list);
@@ -921,9 +932,9 @@ static int nrs_register_policies_locked(struct ptlrpc_nrs *nrs)
 		if (nrs_policy_compatible(svc, desc)) {
 			rc = nrs_policy_register(nrs, desc);
 			if (rc != 0) {
-				CERROR("Failed to register NRS policy %s for partition %d of service %s: %d\n",
-				       desc->pd_name, svcpt->scp_cpt,
-				       svc->srv_name, rc);
+				CERROR("%s.%d NRS: Failed to register policy %s: rc = %d\n",
+				       svc->srv_name, svcpt->scp_cpt,
+				       desc->pd_name, rc);
 				/**
 				 * Fail registration if any of the policies'
 				 * registration fails.
@@ -1108,6 +1119,7 @@ static int nrs_policy_unregister_locked(struct ptlrpc_nrs_pol_desc *desc)
 			continue;
 
 		ptlrpc_service_for_each_part(svcpt, i, svc) {
+			char *srv_name = svcpt->scp_service->srv_name;
 			bool hp = false;
 
 again:
@@ -1120,9 +1132,9 @@ static int nrs_policy_unregister_locked(struct ptlrpc_nrs_pol_desc *desc)
 			if (rc == -ENOENT) {
 				rc = 0;
 			} else if (rc != 0) {
-				CERROR("Failed to unregister NRS policy %s for partition %d of service %s: %d\n",
-				       desc->pd_name, svcpt->scp_cpt,
-				       svcpt->scp_service->srv_name, rc);
+				CERROR("%s.%d NRS: Failed to unregister policy %s: rc = %d\n",
+				       srv_name, svcpt->scp_cpt, desc->pd_name,
+				       rc);
 				return rc;
 			}
 
@@ -1182,17 +1194,18 @@ static int ptlrpc_nrs_policy_register(struct ptlrpc_nrs_pol_conf *conf)
 	if ((conf->nc_flags & PTLRPC_NRS_FL_REG_EXTERN) &&
 	    (conf->nc_flags & (PTLRPC_NRS_FL_FALLBACK |
 			       PTLRPC_NRS_FL_REG_START))) {
-		CERROR("NRS: failing to register policy %s. Please check policy flags; external policies cannot act as fallback policies, or be started immediately upon registration without interaction with lprocfs\n",
-		       conf->nc_name);
-		return -EINVAL;
+		rc = -EINVAL;
+		CERROR("NRS: failing to register policy %s. Please check policy flags; external policies cannot act as fallback policies, or be started immediately upon registration without interaction with lprocfs: rc = %d\n",
+		       conf->nc_name, rc);
+		return rc;
 	}
 
 	mutex_lock(&nrs_core.nrs_mutex);
 
 	if (nrs_policy_find_desc_locked(conf->nc_name)) {
-		CERROR("NRS: failing to register policy %s which has already been registered with NRS core!\n",
-		       conf->nc_name);
 		rc = -EEXIST;
+		CERROR("NRS: failing to register policy %s which has already been registered with NRS core: rc = %d\n",
+		       conf->nc_name, rc);
 		goto fail;
 	}
 
@@ -1243,14 +1256,15 @@ static int ptlrpc_nrs_policy_register(struct ptlrpc_nrs_pol_conf *conf)
 
 		ptlrpc_service_for_each_part(svcpt, i, svc) {
 			struct ptlrpc_nrs *nrs;
+			char *srv_name = svcpt->scp_service->srv_name;
 			bool hp = false;
 again:
 			nrs = nrs_svcpt2nrs(svcpt, hp);
 			rc = nrs_policy_register(nrs, desc);
 			if (rc != 0) {
-				CERROR("Failed to register NRS policy %s for partition %d of service %s: %d\n",
-				       desc->pd_name, svcpt->scp_cpt,
-				       svcpt->scp_service->srv_name, rc);
+				CERROR("%s.%d NRS: Failed to register policy %s: rc = %d\n",
+				       srv_name, svcpt->scp_cpt,
+				       desc->pd_name, rc);
 
 				rc2 = nrs_policy_unregister_locked(desc);
 				/**
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
