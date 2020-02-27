From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:25 -0500
Subject: [lustre-devel] [PATCH 457/622] lustre: lustre: remove ldt_obd_type
 field of lu_device_type
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-458-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This field is never set, so it is always NULL.
So remove it,
 and the one place it is used,
 and a variable that now will now never be set.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 5274e833f5e6 ("LU-6142 lustre: remove ldt_obd_type field of lu_device_type")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35876
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h  | 5 +----
 fs/lustre/obdclass/lu_object.c | 6 ------
 2 files changed, 1 insertion(+), 10 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index b00fad8..aed0d4b 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -43,6 +43,7 @@
 struct seq_file;
 struct lustre_cfg;
 struct lprocfs_stats;
+struct obd_type;
 
 /** \defgroup lu lu
  * lu_* data-types represent server-side entities shared by data and meta-data
@@ -319,10 +320,6 @@ struct lu_device_type {
 	 */
 	const struct lu_device_type_operations	*ldt_ops;
 	/**
-	 * \todo XXX: temporary pointer to associated obd_type.
-	 */
-	struct obd_type				*ldt_obd_type;
-	/**
 	 * \todo XXX: temporary: context tags used by obd_*() calls.
 	 */
 	u32					ldt_ctx_tags;
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index dccff91..38c04c7 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -1336,14 +1336,8 @@ void lu_stack_fini(const struct lu_env *env, struct lu_device *top)
 
 	for (scan = top; scan; scan = next) {
 		const struct lu_device_type *ldt = scan->ld_type;
-		struct obd_type *type;
 
 		next = ldt->ldt_ops->ldto_device_free(env, scan);
-		type = ldt->ldt_obd_type;
-		if (type) {
-			atomic_dec(&type->typ_refcnt);
-			class_put_type(type);
-		}
 	}
 }
 
-- 
1.8.3.1
