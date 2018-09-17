From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:23 -0400
Subject: [lustre-devel] [PATCH 13/30] lustre: ldlm: GPF in _ldlm_lock_debug()
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

Lock's resource can change on a client. Take a resource reference
under spinlock to print debug information.

Signed-off-by: Andriy Skulysh <c17819@cray.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7062
Xyratex-bug-id: MRP-2760
Reviewed-on: https://review.whamcloud.com/16139
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 11 +++++++++--
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |  2 +-
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 2a05ab8..a68c7a4 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1186,6 +1186,7 @@ struct ldlm_resource *ldlm_resource_get(struct ldlm_namespace *ns,
 					struct ldlm_resource *parent,
 					const struct ldlm_res_id *,
 					enum ldlm_type type, int create);
+struct ldlm_resource *ldlm_resource_getref(struct ldlm_resource *res);
 void ldlm_resource_putref(struct ldlm_resource *res);
 void ldlm_resource_add_lock(struct ldlm_resource *res,
 			    struct list_head *head,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 2fb2e08..3cbdc81 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1981,10 +1981,16 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 		      struct libcfs_debug_msg_data *msgdata,
 		      const char *fmt, ...)
 {
-	va_list args;
 	struct obd_export *exp = lock->l_export;
-	struct ldlm_resource *resource = lock->l_resource;
+	struct ldlm_resource *resource = NULL;
 	char *nid = "local";
+	va_list args;
+
+	if (spin_trylock(&lock->l_lock)) {
+		if (lock->l_resource)
+			resource = ldlm_resource_getref(lock->l_resource);
+		spin_unlock(&lock->l_lock);
+	}
 
 	va_start(args, fmt);
 
@@ -2099,5 +2105,6 @@ void _ldlm_lock_debug(struct ldlm_lock *lock,
 		break;
 	}
 	va_end(args);
+	ldlm_resource_putref(resource);
 }
 EXPORT_SYMBOL(_ldlm_lock_debug);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 33d73fa..1907a5a 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -402,7 +402,7 @@ static int ldlm_namespace_debugfs_register(struct ldlm_namespace *ns)
 
 #undef MAX_STRING_SIZE
 
-static struct ldlm_resource *ldlm_resource_getref(struct ldlm_resource *res)
+struct ldlm_resource *ldlm_resource_getref(struct ldlm_resource *res)
 {
 	LASSERT(res);
 	LASSERT(res != LP_POISON);
-- 
1.8.3.1
