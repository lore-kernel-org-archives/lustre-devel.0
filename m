From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:57 -0500
Subject: [lustre-devel] [PATCH 489/622] lustre: obdecho: avoid panic with
 partially object init
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-490-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

in some cases (like ENOMEM) init function can't called, so
any init related code should placed in the object delete handler,
not in the object free.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12707
Lustre-commit: 1a9ca8417c60 ("LU-12707 obdecho: avoid panic with partially object init")
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/35950
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdecho/echo_client.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 84823ec..172fe11 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -444,10 +444,16 @@ static int echo_object_init(const struct lu_env *env, struct lu_object *obj,
 	return 0;
 }
 
-static void echo_object_free(const struct lu_env *env, struct lu_object *obj)
+static void echo_object_delete(const struct lu_env *env, struct lu_object *obj)
 {
 	struct echo_object *eco = cl2echo_obj(lu2cl(obj));
-	struct echo_client_obd *ec = eco->eo_dev->ed_ec;
+	struct echo_client_obd *ec;
+
+	/* object delete called unconditolally - layer init or not */
+	if (!eco->eo_dev)
+		return;
+
+	ec = eco->eo_dev->ed_ec;
 
 	LASSERT(atomic_read(&eco->eo_npages) == 0);
 
@@ -455,10 +461,16 @@ static void echo_object_free(const struct lu_env *env, struct lu_object *obj)
 	list_del_init(&eco->eo_obj_chain);
 	spin_unlock(&ec->ec_lock);
 
+	kfree(eco->eo_oinfo);
+}
+
+static void echo_object_free(const struct lu_env *env, struct lu_object *obj)
+{
+	struct echo_object *eco    = cl2echo_obj(lu2cl(obj));
+
 	lu_object_fini(obj);
 	lu_object_header_fini(obj->lo_header);
 
-	kfree(eco->eo_oinfo);
 	kmem_cache_free(echo_object_kmem, eco);
 }
 
@@ -472,7 +484,7 @@ static int echo_object_print(const struct lu_env *env, void *cookie,
 
 static const struct lu_object_operations echo_lu_obj_ops = {
 	.loo_object_init	= echo_object_init,
-	.loo_object_delete	= NULL,
+	.loo_object_delete	= echo_object_delete,
 	.loo_object_release	= NULL,
 	.loo_object_free	= echo_object_free,
 	.loo_object_print	= echo_object_print,
-- 
1.8.3.1
