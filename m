From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 4 Nov 2015 01:16:16 +0300
Subject: [lustre-devel] [patch] staging: lustre: remove unused variable
Message-ID: <20151103221616.GD19280@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The "->lr_lvb_data" struct member is never used.  Delete it.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
I have compile tested this.  I looked through the history and it seems
to never have been used.  I wonder if we can remove the locking as well.

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 0e75a15..138479a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -872,8 +872,6 @@ struct ldlm_resource {
 	 */
 	struct mutex		lr_lvb_mutex;
 	int			lr_lvb_len;
-	/** protected by lr_lock */
-	void			*lr_lvb_data;
 
 	/** When the resource was considered as contended. */
 	unsigned long		lr_contention_time;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index c0a54bf..b55a4f0 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -1154,8 +1154,6 @@ ldlm_resource_get(struct ldlm_namespace *ns, struct ldlm_resource *parent,
 			CERROR("%s: lvbo_init failed for resource %#llx:%#llx: rc = %d\n",
 			       ns->ns_obd->obd_name, name->name[0],
 			       name->name[1], rc);
-			kfree(res->lr_lvb_data);
-			res->lr_lvb_data = NULL;
 			res->lr_lvb_len = rc;
 			mutex_unlock(&res->lr_lvb_mutex);
 			ldlm_resource_putref(res);
