From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:16 -0400
Subject: [lustre-devel] [PATCH 06/32] staging/lustre/lov: Remove unused
	lov_lsm_decref()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-7-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Also lov_lsm_addref is only used in the file it is defined,
so make it static

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/lov/lov_cl_internal.h |  3 ---
 drivers/staging/lustre/lustre/lov/lov_object.c      | 13 +------------
 2 files changed, 1 insertion(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index 314ce85..9a9156e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -637,9 +637,6 @@ struct lov_io_sub    *lov_page_subio(const struct lu_env *env,
 					 struct lov_io *lio,
 					 const struct cl_page_slice *slice);
 
-void lov_lsm_decref(struct lov_object *lov, struct lov_stripe_md *lsm);
-struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov);
-
 #define lov_foreach_target(lov, var)		    \
 	for (var = 0; var < lov_targets_nr(lov); ++var)
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 4d7cd92..e67df64 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -909,7 +909,7 @@ struct lu_object *lov_object_alloc(const struct lu_env *env,
 	return obj;
 }
 
-struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov)
+static struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov)
 {
 	struct lov_stripe_md *lsm = NULL;
 
@@ -924,17 +924,6 @@ struct lov_stripe_md *lov_lsm_addref(struct lov_object *lov)
 	return lsm;
 }
 
-void lov_lsm_decref(struct lov_object *lov, struct lov_stripe_md *lsm)
-{
-	if (lsm == NULL)
-		return;
-
-	CDEBUG(D_INODE, "lsm %p decref %d by %p.\n",
-		lsm, atomic_read(&lsm->lsm_refc), current);
-
-	lov_free_memmd(&lsm);
-}
-
 struct lov_stripe_md *lov_lsm_get(struct cl_object *clobj)
 {
 	struct lu_object *luobj;
-- 
2.1.0
