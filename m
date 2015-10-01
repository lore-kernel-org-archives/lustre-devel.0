From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:28 -0400
Subject: [lustre-devel] [PATCH 18/32] staging/lustre/ldlm: Remove
	ldlm_namespace_free()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-19-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

It was directly used only on the server. Client side part
was split into smaller chunks to avoid deadlocks.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  2 --
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 27 ----------------------
 2 files changed, 29 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index cc5ad4c1..4d81e73 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1236,8 +1236,6 @@ ldlm_namespace_new(struct obd_device *obd, char *name,
 		   ldlm_side_t client, ldlm_appetite_t apt,
 		   ldlm_ns_type_t ns_type);
 int ldlm_namespace_cleanup(struct ldlm_namespace *ns, __u64 flags);
-void ldlm_namespace_free(struct ldlm_namespace *ns,
-			 struct obd_import *imp, int force);
 void ldlm_namespace_register(struct ldlm_namespace *ns, ldlm_side_t client);
 void ldlm_namespace_unregister(struct ldlm_namespace *ns, ldlm_side_t client);
 void ldlm_namespace_get(struct ldlm_namespace *ns);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index dac2ec2..cd65efe 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -948,33 +948,6 @@ void ldlm_namespace_free_post(struct ldlm_namespace *ns)
 	ldlm_put_ref();
 }
 
-/**
- * Cleanup the resource, and free namespace.
- * bug 12864:
- * Deadlock issue:
- * proc1: destroy import
- *	class_disconnect_export(grab cl_sem) ->
- *	      -> ldlm_namespace_free ->
- *	      -> ldebugfs_remove(grab _lprocfs_lock).
- * proc2: read proc info
- *	lprocfs_fops_read(grab _lprocfs_lock) ->
- *	      -> osc_rd_active, etc(grab cl_sem).
- *
- * So that I have to split the ldlm_namespace_free into two parts - the first
- * part ldlm_namespace_free_prior is used to cleanup the resource which is
- * being used; the 2nd part ldlm_namespace_free_post is used to unregister the
- * lprocfs entries, and then free memory. It will be called w/o cli->cl_sem
- * held.
- */
-void ldlm_namespace_free(struct ldlm_namespace *ns,
-			 struct obd_import *imp,
-			 int force)
-{
-	ldlm_namespace_free_prior(ns, imp, force);
-	ldlm_namespace_free_post(ns);
-}
-EXPORT_SYMBOL(ldlm_namespace_free);
-
 void ldlm_namespace_get(struct ldlm_namespace *ns)
 {
 	atomic_inc(&ns->ns_bref);
-- 
2.1.0
