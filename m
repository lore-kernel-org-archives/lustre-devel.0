From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 21:59:44 -0500
Subject: [lustre-devel] [PATCH v2 01/84] staging/lustre/ldlm: Remove unused
	lr_most_restr from struct ldlm_resource
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This member comes from the dawn of time and is no longer needed

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 3 ---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 3 ---
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 1 -
 3 files changed, 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 51f416d..4aeaac9 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -847,9 +847,6 @@ struct ldlm_resource {
 	struct list_head		lr_waiting;
 	/** @} */
 
-	/* XXX No longer needed? Remove ASAP */
-	ldlm_mode_t		lr_most_restr;
-
 	/** Type of locks this resource can hold. Only one type per resource. */
 	ldlm_type_t		lr_type; /* LDLM_{PLAIN,EXTENT,FLOCK,IBITS} */
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 4fd735f..8f75139 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1033,9 +1033,6 @@ void ldlm_grant_lock(struct ldlm_lock *lock, struct list_head *work_list)
 	else
 		ldlm_resource_add_lock(res, &res->lr_granted, lock);
 
-	if (lock->l_granted_mode < res->lr_most_restr)
-		res->lr_most_restr = lock->l_granted_mode;
-
 	if (work_list && lock->l_completion_ast)
 		ldlm_add_ast_work_item(lock, NULL, work_list);
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 6ae8c60..fede185 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -1110,7 +1110,6 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 	res->lr_ns_bucket  = cfs_hash_bd_extra_get(ns->ns_rs_hash, &bd);
 	res->lr_name       = *name;
 	res->lr_type       = type;
-	res->lr_most_restr = LCK_NL;
 
 	cfs_hash_bd_lock(ns->ns_rs_hash, &bd, 1);
 	hnode = (version == cfs_hash_bd_version_get(&bd)) ?  NULL :
-- 
2.1.0
