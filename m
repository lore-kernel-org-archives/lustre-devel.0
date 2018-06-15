From: NeilBrown <neilb@suse.com>
Date: Fri, 15 Jun 2018 17:11:30 +1000
Subject: [lustre-devel] [PATCH 15/24] lustre: centralize TIMES_SET_FLAGS
In-Reply-To: <152904663333.10587.10934053155404014785.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
Message-ID: <152904669060.10587.11467294807244836929.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This macro is only used in llite, so move both definitions to
llite_internal.h.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_compat.h  |    2 --
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 ++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    2 --
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
index 534846f5561d..6d659b696b5f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_compat.h
+++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
@@ -49,6 +49,4 @@
 #define module_init(a)     late_initcall(a)
 #endif
 
-#define TIMES_SET_FLAGS (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)
-
 #endif /* _LUSTRE_COMPAT_H */
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 0ae5185a4998..91212e608c0b 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -69,6 +69,8 @@
 #define LL_IT2STR(it) ((it) ? ldlm_it2str((it)->it_op) : "0")
 #define LUSTRE_FPRIVATE(file) ((file)->private_data)
 
+#define TIMES_SET_FLAGS (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)
+
 struct ll_dentry_data {
 	struct lookup_intent		*lld_it;
 	unsigned int			lld_sa_generation;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index d72674873a70..e6e02fe7703b 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1353,8 +1353,6 @@ void ll_clear_inode(struct inode *inode)
 	cl_inode_fini(inode);
 }
 
-#define TIMES_SET_FLAGS (ATTR_MTIME_SET | ATTR_ATIME_SET | ATTR_TIMES_SET)
-
 static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data)
 {
 	struct lustre_md md;
