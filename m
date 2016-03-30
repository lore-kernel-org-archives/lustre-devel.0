From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 30 Mar 2016 12:48:10 -0400
Subject: [lustre-devel] [PATCH 38/43] staging/lustre/llite: Move
	ll_dirent_type_get and make it static
In-Reply-To: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
References: <1459356495-2794775-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459356495-2794775-39-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

ll_dirent_type_get is only used in one place in llite/dir.c,
so move it there.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/dir.c          | 22 ++++++++++++++++++++++
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   | 22 ----------------------
 drivers/staging/lustre/lustre/llite/vvp_internal.h |  1 -
 3 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 2ca4b0e..b085fb4 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -469,6 +469,28 @@ fail:
 	goto out_unlock;
 }
 
+/**
+ * return IF_* type for given lu_dirent entry.
+ * IF_* flag shld be converted to particular OS file type in
+ * platform llite module.
+ */
+static __u16 ll_dirent_type_get(struct lu_dirent *ent)
+{
+	__u16 type = 0;
+	struct luda_type *lt;
+	int len = 0;
+
+	if (le32_to_cpu(ent->lde_attrs) & LUDA_TYPE) {
+		const unsigned int align = sizeof(struct luda_type) - 1;
+
+		len = le16_to_cpu(ent->lde_namelen);
+		len = (len + align) & ~align;
+		lt = (void *)ent->lde_name + len;
+		type = IFTODT(le16_to_cpu(lt->lt_type));
+	}
+	return type;
+}
+
 int ll_dir_read(struct inode *inode, struct dir_context *ctx)
 {
 	struct ll_inode_info *info       = ll_i2info(inode);
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 164737a..6c00715 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -280,28 +280,6 @@ void cl_inode_fini(struct inode *inode)
 }
 
 /**
- * return IF_* type for given lu_dirent entry.
- * IF_* flag shld be converted to particular OS file type in
- * platform llite module.
- */
-__u16 ll_dirent_type_get(struct lu_dirent *ent)
-{
-	__u16 type = 0;
-	struct luda_type *lt;
-	int len = 0;
-
-	if (le32_to_cpu(ent->lde_attrs) & LUDA_TYPE) {
-		const unsigned int align = sizeof(struct luda_type) - 1;
-
-		len = le16_to_cpu(ent->lde_namelen);
-		len = (len + align) & ~align;
-		lt = (void *)ent->lde_name + len;
-		type = IFTODT(le16_to_cpu(lt->lt_type));
-	}
-	return type;
-}
-
-/**
  * build inode number from passed @fid
  */
 __u64 cl_fid_build_ino(const struct lu_fid *fid, int api32)
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index fe29fb5..06e2726 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -376,7 +376,6 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md);
 void cl_inode_fini(struct inode *inode);
 int cl_local_size(struct inode *inode);
 
-__u16 ll_dirent_type_get(struct lu_dirent *ent);
 __u64 cl_fid_build_ino(const struct lu_fid *fid, int api32);
 __u32 cl_fid_build_gen(const struct lu_fid *fid);
 
-- 
2.1.0
