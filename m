From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:44:10 -0400
Subject: [lustre-devel] [PATCH 27/29] staging/lustre: Remove
	ccc_attr/conf_set()
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-28-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

These seem to be unused.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lclient.h    |  4 ----
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c | 15 ---------------
 2 files changed, 19 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lclient.h b/drivers/staging/lustre/lustre/include/lclient.h
index 67d41bb..d09d005 100644
--- a/drivers/staging/lustre/lustre/include/lclient.h
+++ b/drivers/staging/lustre/lustre/include/lclient.h
@@ -289,12 +289,8 @@ void ccc_object_free(const struct lu_env *env, struct lu_object *obj);
 int ccc_lock_init(const struct lu_env *env, struct cl_object *obj,
 		  struct cl_lock *lock, const struct cl_io *io,
 		  const struct cl_lock_operations *lkops);
-int ccc_attr_set(const struct lu_env *env, struct cl_object *obj,
-		 const struct cl_attr *attr, unsigned valid);
 int ccc_object_glimpse(const struct lu_env *env,
 		       const struct cl_object *obj, struct ost_lvb *lvb);
-int ccc_conf_set(const struct lu_env *env, struct cl_object *obj,
-		 const struct cl_object_conf *conf);
 struct page *ccc_page_vmpage(const struct lu_env *env,
 			    const struct cl_page_slice *slice);
 int ccc_page_is_under_lock(const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
index f049d55..98a2e0e 100644
--- a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
@@ -406,12 +406,6 @@ int ccc_lock_init(const struct lu_env *env,
 	return result;
 }
 
-int ccc_attr_set(const struct lu_env *env, struct cl_object *obj,
-		 const struct cl_attr *attr, unsigned valid)
-{
-	return 0;
-}
-
 int ccc_object_glimpse(const struct lu_env *env,
 		       const struct cl_object *obj, struct ost_lvb *lvb)
 {
@@ -430,15 +424,6 @@ int ccc_object_glimpse(const struct lu_env *env,
 	return 0;
 }
 
-
-
-int ccc_conf_set(const struct lu_env *env, struct cl_object *obj,
-			const struct cl_object_conf *conf)
-{
-	/* TODO: destroy all pages attached to this object. */
-	return 0;
-}
-
 static void ccc_object_size_lock(struct cl_object *obj)
 {
 	struct inode *inode = ccc_object_inode(obj);
-- 
2.1.0
