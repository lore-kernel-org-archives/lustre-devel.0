From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:44:44 -0400
Subject: [lustre-devel] [PATCH 03/37] lustre: sec: better struct
 sepol_downcall_data
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

struct sepol_downcall_data is badly formed for several reasons:
- it uses a __kernel_time_t field, which can be variably sized,
  depending on the size of __kernel_long_t. Replace it with a
  fixed-size __s64 type;
- it has __u32 sdd_magic that is immediately before a potentially
  64-bit field, whereas the 64-bit fields in a structure should
  always be naturally aligned on 64-bit boundaries to avoid potential
  incompatibility in the structure definition;
- it has __u16 sdd_sepol_len which may be followed by padding.

So create a better struct sepol_downcall_data, while maintaining
compatibility with 2.12 by keeping a struct sepol_downcall_data_old.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13525
Lustre-commit: 82b8cb5528f48 ("LU-13525 sec: better struct sepol_downcall_data")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/38580
Reviewed-by: Olaf Faaland-LLNL <faaland1@llnl.gov>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/sec_lproc.c            | 134 ++++++++++++++++++++++++++++----
 include/uapi/linux/lustre/lustre_user.h |  16 +++-
 2 files changed, 135 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/ptlrpc/sec_lproc.c b/fs/lustre/ptlrpc/sec_lproc.c
index 7db7e81..b34ced4 100644
--- a/fs/lustre/ptlrpc/sec_lproc.c
+++ b/fs/lustre/ptlrpc/sec_lproc.c
@@ -131,6 +131,86 @@ static int sptlrpc_ctxs_lprocfs_seq_show(struct seq_file *seq, void *v)
 
 LPROC_SEQ_FOPS_RO(sptlrpc_ctxs_lprocfs);
 
+#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(2, 16, 53, 0)
+static ssize_t sepol_seq_write_old(struct obd_device *obd,
+				   const char __user *buffer,
+				   size_t count)
+{
+	struct client_obd *cli = &obd->u.cli;
+	struct obd_import *imp = cli->cl_import;
+	struct sepol_downcall_data_old *param;
+	int size = sizeof(*param);
+	u16 len;
+	int rc = 0;
+
+	if (count < size) {
+		rc = -EINVAL;
+		CERROR("%s: invalid data count = %lu, size = %d: rc = %d\n",
+		       obd->obd_name, (unsigned long) count, size, rc);
+		return rc;
+	}
+
+	param = kmalloc(size, GFP_KERNEL);
+	if (!param)
+		return -ENOMEM;
+
+	if (copy_from_user(param, buffer, size)) {
+		rc = -EFAULT;
+		CERROR("%s: bad sepol data: rc = %d\n", obd->obd_name, rc);
+		goto out;
+	}
+
+	if (param->sdd_magic != SEPOL_DOWNCALL_MAGIC_OLD) {
+		rc = -EINVAL;
+		CERROR("%s: sepol downcall bad params: rc = %d\n",
+		       obd->obd_name, rc);
+		goto out;
+	}
+
+	if (param->sdd_sepol_len == 0 ||
+	    param->sdd_sepol_len >= sizeof(imp->imp_sec->ps_sepol)) {
+		rc = -EINVAL;
+		CERROR("%s: invalid sepol data returned: rc = %d\n",
+		       obd->obd_name, rc);
+		goto out;
+	}
+	len = param->sdd_sepol_len; /* save sdd_sepol_len */
+	kfree(param);
+	size = offsetof(struct sepol_downcall_data_old,
+			sdd_sepol[len]);
+
+	if (count < size) {
+		rc = -EINVAL;
+		CERROR("%s: invalid sepol count = %lu, size = %d: rc = %d\n",
+		       obd->obd_name, (unsigned long) count, size, rc);
+		return rc;
+	}
+
+	/* alloc again with real size */
+	param = kmalloc(size, GFP_KERNEL);
+	if (!param)
+		return -ENOMEM;
+
+	if (copy_from_user(param, buffer, size)) {
+		rc = -EFAULT;
+		CERROR("%s: cannot copy sepol data: rc = %d\n",
+		       obd->obd_name, rc);
+		goto out;
+	}
+
+	spin_lock(&imp->imp_sec->ps_lock);
+	snprintf(imp->imp_sec->ps_sepol, param->sdd_sepol_len + 1, "%s",
+		 param->sdd_sepol);
+	imp->imp_sec->ps_sepol_mtime = ktime_set(param->sdd_sepol_mtime, 0);
+	spin_unlock(&imp->imp_sec->ps_lock);
+
+out:
+	kfree(param);
+
+	return rc ? rc : count;
+}
+#endif
+
 static ssize_t
 lprocfs_wr_sptlrpc_sepol(struct file *file, const char __user *buffer,
 			 size_t count, void *data)
@@ -140,13 +220,41 @@ static int sptlrpc_ctxs_lprocfs_seq_show(struct seq_file *seq, void *v)
 	struct client_obd *cli = &obd->u.cli;
 	struct obd_import *imp = cli->cl_import;
 	struct sepol_downcall_data *param;
-	int size = sizeof(*param);
+	u32 magic;
+	int size = sizeof(magic);
+	u16 len;
 	int rc = 0;
 
 	if (count < size) {
-		CERROR("%s: invalid data count = %lu, size = %d\n",
-		       obd->obd_name, (unsigned long) count, size);
-		return -EINVAL;
+		rc = -EINVAL;
+		CERROR("%s: invalid buffer count = %lu, size = %d: rc = %d\n",
+		       obd->obd_name, (unsigned long) count, size, rc);
+		return rc;
+	}
+
+	if (copy_from_user(&magic, buffer, size)) {
+		rc = -EFAULT;
+		CERROR("%s: bad sepol magic: rc = %d\n", obd->obd_name, rc);
+		return rc;
+	}
+
+	if (magic != SEPOL_DOWNCALL_MAGIC) {
+#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(2, 16, 53, 0)
+		if (magic == SEPOL_DOWNCALL_MAGIC_OLD)
+			return sepol_seq_write_old(obd, buffer, count);
+#endif
+		rc = -EINVAL;
+		CERROR("%s: sepol downcall bad magic '%#08x': rc = %d\n",
+		       obd->obd_name, magic, rc);
+		return rc;
+	}
+
+	size = sizeof(*param);
+	if (count < size) {
+		rc = -EINVAL;
+		CERROR("%s: invalid data count = %lu, size = %d: rc = %d\n",
+		       obd->obd_name, (unsigned long) count, size, rc);
+		return rc;
 	}
 
 	param = kzalloc(size, GFP_KERNEL);
@@ -154,39 +262,39 @@ static int sptlrpc_ctxs_lprocfs_seq_show(struct seq_file *seq, void *v)
 		return -ENOMEM;
 
 	if (copy_from_user(param, buffer, size)) {
-		CERROR("%s: bad sepol data\n", obd->obd_name);
 		rc = -EFAULT;
+		CERROR("%s: bad sepol data: rc = %d\n", obd->obd_name, rc);
 		goto out;
 	}
 
 	if (param->sdd_magic != SEPOL_DOWNCALL_MAGIC) {
-		CERROR("%s: sepol downcall bad params\n",
-		       obd->obd_name);
 		rc = -EINVAL;
+		CERROR("%s: invalid sepol data returned: rc = %d\n",
+		       obd->obd_name, rc);
 		goto out;
 	}
 
 	if (param->sdd_sepol_len == 0 ||
 	    param->sdd_sepol_len >= sizeof(imp->imp_sec->ps_sepol)) {
-		CERROR("%s: invalid sepol data returned\n",
-		       obd->obd_name);
 		rc = -EINVAL;
+		CERROR("%s: invalid sepol data returned: rc = %d\n",
+		       obd->obd_name, rc);
 		goto out;
 	}
-	rc = param->sdd_sepol_len; /* save sdd_sepol_len */
+	len = param->sdd_sepol_len; /* save sdd_sepol_len */
 	kfree(param);
 	size = offsetof(struct sepol_downcall_data,
-			sdd_sepol[rc]);
+			sdd_sepol[len]);
 
 	/* alloc again with real size */
-	rc = 0;
 	param = kzalloc(size, GFP_KERNEL);
 	if (!param)
 		return -ENOMEM;
 
 	if (copy_from_user(param, buffer, size)) {
-		CERROR("%s: bad sepol data\n", obd->obd_name);
 		rc = -EFAULT;
+		CERROR("%s: cannot copy sepol data: rc = %d\n",
+		       obd->obd_name, rc);
 		goto out;
 	}
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 6a2d5f9..b0301e1 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -51,6 +51,7 @@
 #include <linux/types.h>
 #include <linux/unistd.h>
 #include <linux/lustre/lustre_fiemap.h>
+#include <linux/lustre/lustre_ver.h>
 
 #ifndef __KERNEL__
 # define __USE_ISOC99  1
@@ -980,7 +981,6 @@ static inline const char *qtype_name(int qtype)
 }
 
 #define IDENTITY_DOWNCALL_MAGIC 0x6d6dd629
-#define SEPOL_DOWNCALL_MAGIC 0x8b8bb842
 
 /* permission */
 #define N_PERMS_MAX	64
@@ -1002,13 +1002,25 @@ struct identity_downcall_data {
 	__u32			    idd_groups[0];
 };
 
-struct sepol_downcall_data {
+#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(2, 16, 53, 0)
+/* old interface struct is deprecated in 2.14 */
+#define SEPOL_DOWNCALL_MAGIC_OLD 0x8b8bb842
+struct sepol_downcall_data_old {
 	__u32		sdd_magic;
 	__s64		sdd_sepol_mtime;
 	__u16		sdd_sepol_len;
 	char		sdd_sepol[0];
 };
+#endif
 
+#define SEPOL_DOWNCALL_MAGIC 0x8b8bb843
+struct sepol_downcall_data {
+	__u32		sdd_magic;
+	__u16		sdd_sepol_len;
+	__u16		sdd_padding1;
+	__s64		sdd_sepol_mtime;
+	char		sdd_sepol[0];
+};
 
 /* lustre volatile file support
  * file name header: ".^L^S^T^R:volatile"
-- 
1.8.3.1
