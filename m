From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:01:04 -0500
Subject: [lustre-devel] [PATCH v2 81/84] staging/lustre: Fix lines that
	start with spaces
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-82-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Found with checkpatch.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_cfg.h |  2 +-
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  4 ++--
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |  6 +++---
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |  2 +-
 drivers/staging/lustre/lustre/llite/rw26.c         | 17 +++++++++--------
 5 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_cfg.h b/drivers/staging/lustre/lustre/include/lustre_cfg.h
index 23ae832..bb16ae9 100644
--- a/drivers/staging/lustre/lustre/include/lustre_cfg.h
+++ b/drivers/staging/lustre/lustre/include/lustre_cfg.h
@@ -50,7 +50,7 @@
 #define LUSTRE_CFG_MAX_BUFCOUNT 8
 
 #define LCFG_HDR_SIZE(count) \
-    cfs_size_round(offsetof (struct lustre_cfg, lcfg_buflens[(count)]))
+	cfs_size_round(offsetof(struct lustre_cfg, lcfg_buflens[(count)]))
 
 /** If the LCFG_REQUIRED bit is set in a configuration command,
  * then the client is required to understand this parameter
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 144b5af..8b0364f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -149,13 +149,13 @@ extern enum ldlm_mode lck_compat_array[];
 
 static inline void lockmode_verify(enum ldlm_mode mode)
 {
-       LASSERT(mode > LCK_MINMODE && mode < LCK_MAXMODE);
+	LASSERT(mode > LCK_MINMODE && mode < LCK_MAXMODE);
 }
 
 static inline int lockmode_compat(enum ldlm_mode exist_mode,
 				  enum ldlm_mode new_mode)
 {
-       return (lck_compat_array[exist_mode] & new_mode);
+	return (lck_compat_array[exist_mode] & new_mode);
 }
 
 /*
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 69d30aa..193aab8 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -330,9 +330,9 @@ static struct dentry *ll_get_parent(struct dentry *dchild)
 }
 
 const struct export_operations lustre_export_operations = {
-       .get_parent = ll_get_parent,
-       .encode_fh  = ll_encode_fh,
-       .get_name   = ll_get_name,
+	.get_parent = ll_get_parent,
+	.encode_fh  = ll_encode_fh,
+	.get_name   = ll_get_name,
 	.fh_to_dentry = ll_fh_to_dentry,
 	.fh_to_parent = ll_fh_to_parent,
 };
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 8a27f69..45941a6 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1504,5 +1504,5 @@ LPROC_SEQ_FOPS(ll_rw_offset_stats);
 
 void lprocfs_llite_init_vars(struct lprocfs_static_vars *lvars)
 {
-    lvars->obd_vars     = lprocfs_llite_obd_vars;
+	lvars->obd_vars = lprocfs_llite_obd_vars;
 }
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 6a5762e..b9d8e73 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -339,14 +339,15 @@ static ssize_t ll_direct_IO_26_seg(const struct lu_env *env, struct cl_io *io,
 				   size_t size, loff_t file_offset,
 				   struct page **pages, int page_count)
 {
-    struct ll_dio_pages pvec = { .ldp_pages	= pages,
-				 .ldp_nr	   = page_count,
-				 .ldp_size	 = size,
-				 .ldp_offsets      = NULL,
-				 .ldp_start_offset = file_offset
-			       };
-
-    return ll_direct_rw_pages(env, io, rw, inode, &pvec);
+	struct ll_dio_pages pvec = {
+		.ldp_pages	= pages,
+		.ldp_nr		= page_count,
+		.ldp_size	= size,
+		.ldp_offsets	= NULL,
+		.ldp_start_offset = file_offset
+	};
+
+	return ll_direct_rw_pages(env, io, rw, inode, &pvec);
 }
 
 #ifdef KMALLOC_MAX_SIZE
-- 
2.1.0
