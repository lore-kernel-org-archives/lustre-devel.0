From: NeilBrown <neilb@suse.com>
Date: Fri, 11 Jan 2019 11:00:46 +1100
Subject: [lustre-devel] [PATCH 2/4] lustre: llite: change some foo0() to
 __foo()
In-Reply-To: <154716475327.28978.3817067697027604609.stgit@noble>
References: <154716475327.28978.3817067697027604609.stgit@noble>
Message-ID: <154716484597.28978.7362652816645934722.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Change:
  cl_glimpse_size0 -> __cl_glimpse_size
  ll_page_mkwrite0 -> __ll_page_mkwrite
  ll_fault0 -> __ll_fault
  vvp_object_init0 -> __vvp_object_init

This is more consistent with Linux naming style.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/glimpse.c      |    2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |    6 +++---
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   11 +++++------
 drivers/staging/lustre/lustre/llite/vvp_object.c   |    8 ++++----
 4 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index ce0d51767da3..d8712a392e58 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -163,7 +163,7 @@ static int cl_io_get(struct inode *inode, struct lu_env **envout,
 	return result;
 }
 
-int cl_glimpse_size0(struct inode *inode, int agl)
+int __cl_glimpse_size(struct inode *inode, int agl)
 {
 	/*
 	 * We don't need ast_flags argument to cl_glimpse_size(), because
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index b2a1f54ab228..c680a49d900c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1161,18 +1161,18 @@ void ll_deauthorize_statahead(struct inode *dir, void *key);
 
 blkcnt_t dirty_cnt(struct inode *inode);
 
-int cl_glimpse_size0(struct inode *inode, int agl);
+int __cl_glimpse_size(struct inode *inode, int agl);
 int cl_glimpse_lock(const struct lu_env *env, struct cl_io *io,
 		    struct inode *inode, struct cl_object *clob, int agl);
 
 static inline int cl_glimpse_size(struct inode *inode)
 {
-	return cl_glimpse_size0(inode, 0);
+	return __cl_glimpse_size(inode, 0);
 }
 
 static inline int cl_agl(struct inode *inode)
 {
-	return cl_glimpse_size0(inode, 1);
+	return __cl_glimpse_size(inode, 1);
 }
 
 static inline int ll_glimpse_size(struct inode *inode)
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 023d62e53051..33e23ee4aff4 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -143,9 +143,8 @@ ll_fault_io_init(struct lu_env *env, struct vm_area_struct *vma,
 	return io;
 }
 
-/* Sharing code of page_mkwrite method for rhel5 and rhel6 */
-static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
-			    bool *retry)
+static int __ll_page_mkwrite(struct vm_area_struct *vma, struct page *vmpage,
+			     bool *retry)
 {
 	struct lu_env	   *env;
 	struct cl_io	    *io;
@@ -262,7 +261,7 @@ static inline vm_fault_t to_fault_error(int result)
  * \retval VM_FAULT_ERROR on general error
  * \retval NOPAGE_OOM not have memory for allocate new page
  */
-static vm_fault_t ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
+static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct lu_env	   *env;
 	struct cl_io	    *io;
@@ -365,7 +364,7 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
 			   LPROC_LL_FAULT, 1);
 
 restart:
-	result = ll_fault0(vmf->vma, vmf);
+	result = __ll_fault(vmf->vma, vmf);
 	if (!(result & (VM_FAULT_RETRY | VM_FAULT_ERROR | VM_FAULT_LOCKED))) {
 		struct page *vmpage = vmf->page;
 
@@ -406,7 +405,7 @@ static vm_fault_t ll_page_mkwrite(struct vm_fault *vmf)
 	file_update_time(vma->vm_file);
 	do {
 		retry = false;
-		err = ll_page_mkwrite0(vma, vmf->page, &retry);
+		err = __ll_page_mkwrite(vma, vmf->page, &retry);
 
 		if (!printed && ++count > 16) {
 			const struct dentry *de = vma->vm_file->f_path.dentry;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index e1000f6b7f22..86e077bd516b 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -220,9 +220,9 @@ static const struct cl_object_operations vvp_ops = {
 	.coo_req_attr_set	= vvp_req_attr_set
 };
 
-static int vvp_object_init0(const struct lu_env *env,
-			    struct vvp_object *vob,
-			    const struct cl_object_conf *conf)
+static int __vvp_object_init(const struct lu_env *env,
+			     struct vvp_object *vob,
+			     const struct cl_object_conf *conf)
 {
 	vob->vob_inode = conf->coc_inode;
 	atomic_set(&vob->vob_transient_pages, 0);
@@ -246,7 +246,7 @@ static int vvp_object_init(const struct lu_env *env, struct lu_object *obj,
 
 		cconf = lu2cl_conf(conf);
 		lu_object_add(obj, below);
-		result = vvp_object_init0(env, vob, cconf);
+		result = __vvp_object_init(env, vob, cconf);
 	} else {
 		result = -ENOMEM;
 	}
