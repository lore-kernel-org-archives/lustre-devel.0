From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:07 -0400
Subject: [lustre-devel] [PATCH 04/38] lustre: llite: remove ll_sb
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The only user of ll_sb in struct ll_sb_info is used to query the
name locate in the file_system_type. We can get that information
from using the super block located in struct path instead. This
enables us to use struct ll_sb_info directly for every sysfs or
debugfs entry.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24031
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_internal.h | 1 -
 drivers/staging/lustre/lustre/llite/llite_lib.c      | 6 ++----
 drivers/staging/lustre/lustre/llite/lproc_llite.c    | 3 ++-
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 2719bc53..92dc05d 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -524,7 +524,6 @@ struct ll_sb_info {
 
 	__kernel_fsid_t		  ll_fsid;
 	struct kobject		 ll_kobj; /* sysfs object */
-	struct super_block	*ll_sb; /* struct super_block (for sysfs code)*/
 	struct completion	 ll_kobj_unregister;
 };
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index d16f5d1..d352287 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -62,7 +62,7 @@
 #define log2(n) ffz(~(n))
 #endif
 
-static struct ll_sb_info *ll_init_sbi(struct super_block *sb)
+static struct ll_sb_info *ll_init_sbi(void)
 {
 	struct ll_sb_info *sbi = NULL;
 	unsigned long pages;
@@ -129,8 +129,6 @@ static struct ll_sb_info *ll_init_sbi(struct super_block *sb)
 	INIT_LIST_HEAD(&sbi->ll_squash.rsi_nosquash_nids);
 	init_rwsem(&sbi->ll_squash.rsi_sem);
 
-	sbi->ll_sb = sb;
-
 	return sbi;
 }
 
@@ -912,7 +910,7 @@ int ll_fill_super(struct super_block *sb)
 	try_module_get(THIS_MODULE);
 
 	/* client additional sb info */
-	sbi = ll_init_sbi(sb);
+	sbi = ll_init_sbi();
 	lsi->lsi_llsbi = sbi;
 	if (!sbi) {
 		module_put(THIS_MODULE);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index a9ad328..8e418ba 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -33,6 +33,7 @@
 #define DEBUG_SUBSYSTEM S_LLITE
 
 #include <lprocfs_status.h>
+#include <linux/mount.h>
 #include <linux/seq_file.h>
 #include <obd_support.h>
 
@@ -215,7 +216,7 @@ static ssize_t fstype_show(struct kobject *kobj, struct attribute *attr,
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kobj);
 
-	return sprintf(buf, "%s\n", sbi->ll_sb->s_type->name);
+	return sprintf(buf, "%s\n", sbi->ll_mnt.mnt->mnt_sb->s_type->name);
 }
 LUSTRE_RO_ATTR(fstype);
 
-- 
1.8.3.1
