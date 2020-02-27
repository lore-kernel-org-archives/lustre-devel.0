From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:43 -0500
Subject: [lustre-devel] [PATCH 115/622] lustre: obdclass: remove unused
 ll_import_cachep
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-116-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

The ll_import_cache is not used anywhere, and can be removed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10899
Lustre-commit: e23250110729 ("LU-10899 obdclass: remove unused ll_import_cachep")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33119
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/genops.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index fc50aba..a122332 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -48,7 +48,6 @@
 static struct kmem_cache *obd_device_cachep;
 struct kmem_cache *obdo_cachep;
 EXPORT_SYMBOL(obdo_cachep);
-static struct kmem_cache *import_cachep;
 
 static struct kobj_type class_ktype;
 static struct workqueue_struct *zombie_wq;
@@ -648,8 +647,6 @@ void obd_cleanup_caches(void)
 	obd_device_cachep = NULL;
 	kmem_cache_destroy(obdo_cachep);
 	obdo_cachep = NULL;
-	kmem_cache_destroy(import_cachep);
-	import_cachep = NULL;
 }
 
 int obd_init_caches(void)
@@ -667,13 +664,6 @@ int obd_init_caches(void)
 	if (!obdo_cachep)
 		goto out;
 
-	LASSERT(!import_cachep);
-	import_cachep = kmem_cache_create("ll_import_cache",
-					  sizeof(struct obd_import),
-					  0, 0, NULL);
-	if (!import_cachep)
-		goto out;
-
 	return 0;
 out:
 	obd_cleanup_caches();
-- 
1.8.3.1
