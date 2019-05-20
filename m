From: James Simmons <jsimmons@infradead.org>
Date: Mon, 20 May 2019 08:50:47 -0400
Subject: [lustre-devel] [PATCH v2 05/29] lustre: llite: don't use
 class_setup_tunables()
In-Reply-To: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1558356671-29599-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

llite is very different from the other types of lustre devices.
Since this is the case llite should register independently. Doing
this allows us to cleanup the debugfs registering in the release
function of struct kobj_type.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/34292
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/lproc_llite.c | 41 ++++++++++++++++++++++++++++++-----------
 1 file changed, 30 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 5de8462..91b0a50 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -42,18 +42,40 @@
 static struct kobject *llite_kobj;
 static struct dentry *llite_root;
 
+static void llite_kobj_release(struct kobject *kobj)
+{
+	if (!IS_ERR_OR_NULL(llite_root)) {
+		debugfs_remove(llite_root);
+		llite_root = NULL;
+	}
+
+	kfree(kobj);
+}
+
+static struct kobj_type llite_kobj_ktype = {
+	.release	= llite_kobj_release,
+	.sysfs_ops	= &lustre_sysfs_ops,
+};
+
 int llite_tunables_register(void)
 {
-	int rc = 0;
+	int rc;
+
+	llite_kobj = kzalloc(sizeof(*llite_kobj), GFP_KERNEL);
+	if (!llite_kobj)
+		return -ENOMEM;
 
-	llite_kobj = class_setup_tunables("llite");
-	if (IS_ERR(llite_kobj))
-		return PTR_ERR(llite_kobj);
+	llite_kobj->kset = lustre_kset;
+	rc = kobject_init_and_add(llite_kobj, &llite_kobj_ktype,
+				  &lustre_kset->kobj, "%s", "llite");
+	if (rc)
+		goto free_kobj;
 
 	llite_root = debugfs_create_dir("llite", debugfs_lustre_root);
 	if (IS_ERR_OR_NULL(llite_root)) {
 		rc = llite_root ? PTR_ERR(llite_root) : -ENOMEM;
 		llite_root = NULL;
+free_kobj:
 		kobject_put(llite_kobj);
 		llite_kobj = NULL;
 	}
@@ -65,9 +87,6 @@ void llite_tunables_unregister(void)
 {
 	kobject_put(llite_kobj);
 	llite_kobj = NULL;
-
-	debugfs_remove(llite_root);
-	llite_root = NULL;
 }
 
 /* debugfs llite mount point registration */
@@ -1216,17 +1235,17 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 	NULL,
 };
 
-static void llite_kobj_release(struct kobject *kobj)
+static void sbi_kobj_release(struct kobject *kobj)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
 					      ll_kset.kobj);
 	complete(&sbi->ll_kobj_unregister);
 }
 
-static struct kobj_type llite_ktype = {
+static struct kobj_type sbi_ktype = {
 	.default_attrs	= llite_attrs,
 	.sysfs_ops	= &lustre_sysfs_ops,
-	.release	= llite_kobj_release,
+	.release	= sbi_kobj_release,
 };
 
 static const struct llite_file_opcode {
@@ -1384,7 +1403,7 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 out_ll_kset:
 	/* Yes we also register sysfs mount kset here as well */
 	sbi->ll_kset.kobj.parent = llite_kobj;
-	sbi->ll_kset.kobj.ktype = &llite_ktype;
+	sbi->ll_kset.kobj.ktype = &sbi_ktype;
 	init_completion(&sbi->ll_kobj_unregister);
 	err = kobject_set_name(&sbi->ll_kset.kobj, "%s", name);
 	if (err)
-- 
1.8.3.1
