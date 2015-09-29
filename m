From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:44:12 -0400
Subject: [lustre-devel] [PATCH 29/29] staging/lustre: Remove
	ccc_transient_page_* methods
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-30-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

All of them but the ccc_transient_page_prep are unused, so remove
the unused ones.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lclient.h    | 19 ---------
 drivers/staging/lustre/lustre/lclient/lcommon_cl.c | 48 ----------------------
 2 files changed, 67 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lclient.h b/drivers/staging/lustre/lustre/include/lclient.h
index 823be81..be5499c 100644
--- a/drivers/staging/lustre/lustre/include/lclient.h
+++ b/drivers/staging/lustre/lustre/include/lclient.h
@@ -233,8 +233,6 @@ static inline struct ccc_page *cl2ccc_page(const struct cl_page_slice *slice)
 	return container_of(slice, struct ccc_page, cpg_cl);
 }
 
-struct cl_page    *ccc_vmpage_page_transient(struct page *vmpage);
-
 struct ccc_device {
 	struct cl_device    cdv_cl;
 	struct super_block *cdv_sb;
@@ -296,22 +294,6 @@ struct page *ccc_page_vmpage(const struct lu_env *env,
 int ccc_page_is_under_lock(const struct lu_env *env,
 			   const struct cl_page_slice *slice, struct cl_io *io);
 int ccc_fail(const struct lu_env *env, const struct cl_page_slice *slice);
-void ccc_transient_page_verify(const struct cl_page *page);
-int  ccc_transient_page_own(const struct lu_env *env,
-			    const struct cl_page_slice *slice,
-			    struct cl_io *io, int nonblock);
-void ccc_transient_page_assume(const struct lu_env *env,
-			       const struct cl_page_slice *slice,
-			       struct cl_io *io);
-void ccc_transient_page_unassume(const struct lu_env *env,
-				 const struct cl_page_slice *slice,
-				 struct cl_io *io);
-void ccc_transient_page_disown(const struct lu_env *env,
-			       const struct cl_page_slice *slice,
-			       struct cl_io *io);
-void ccc_transient_page_discard(const struct lu_env *env,
-				const struct cl_page_slice *slice,
-				struct cl_io *io);
 int ccc_transient_page_prep(const struct lu_env *env,
 			    const struct cl_page_slice *slice,
 			    struct cl_io *io);
@@ -368,7 +350,6 @@ struct ccc_object  *cl_inode2ccc    (struct inode *inode);
 
 int cl_setattr_ost(struct inode *inode, const struct iattr *attr);
 
-struct cl_page *ccc_vmpage_page_transient(struct page *vmpage);
 int ccc_object_invariant(const struct cl_object *obj);
 int cl_file_inode_init(struct inode *inode, struct lustre_md *md);
 void cl_inode_fini(struct inode *inode);
diff --git a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
index eb43174..8764df9 100644
--- a/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/lclient/lcommon_cl.c
@@ -488,54 +488,6 @@ int ccc_fail(const struct lu_env *env, const struct cl_page_slice *slice)
 	return 0;
 }
 
-void ccc_transient_page_verify(const struct cl_page *page)
-{
-}
-
-int ccc_transient_page_own(const struct lu_env *env,
-				   const struct cl_page_slice *slice,
-				   struct cl_io *unused,
-				   int nonblock)
-{
-	ccc_transient_page_verify(slice->cpl_page);
-	return 0;
-}
-
-void ccc_transient_page_assume(const struct lu_env *env,
-				      const struct cl_page_slice *slice,
-				      struct cl_io *unused)
-{
-	ccc_transient_page_verify(slice->cpl_page);
-}
-
-void ccc_transient_page_unassume(const struct lu_env *env,
-					const struct cl_page_slice *slice,
-					struct cl_io *unused)
-{
-	ccc_transient_page_verify(slice->cpl_page);
-}
-
-void ccc_transient_page_disown(const struct lu_env *env,
-				      const struct cl_page_slice *slice,
-				      struct cl_io *unused)
-{
-	ccc_transient_page_verify(slice->cpl_page);
-}
-
-void ccc_transient_page_discard(const struct lu_env *env,
-				       const struct cl_page_slice *slice,
-				       struct cl_io *unused)
-{
-	struct cl_page *page = slice->cpl_page;
-
-	ccc_transient_page_verify(slice->cpl_page);
-
-	/*
-	 * For transient pages, remove it from the radix tree.
-	 */
-	cl_page_delete(env, page);
-}
-
 int ccc_transient_page_prep(const struct lu_env *env,
 				   const struct cl_page_slice *slice,
 				   struct cl_io *unused)
-- 
2.1.0
