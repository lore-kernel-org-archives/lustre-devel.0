From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 29 May 2018 16:29:39 +0200
Subject: [lustre-devel] [PATCH 05/13] staging: lustre: no need to check
 debugfs return values
In-Reply-To: <20180529142947.3250-1-gregkh@linuxfoundation.org>
References: <20180529142947.3250-1-gregkh@linuxfoundation.org>
Message-ID: <20180529142947.3250-5-gregkh@linuxfoundation.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

When calling debugfs functions, there is no need to ever check the
return value.  The function can work or not, but the code logic should
never do something different based on this.

Clean up the lustre core code by not caring about the value of debugfs
calls.  This ends up removing a number of lines of code that are not
needed.

Note, more work is needed to remove the unneeded debugfs wrapper
functions in the future.

Cc: Oleg Drokin <oleg.drokin@intel.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>
Cc: James Simmons <jsimmons@infradead.org>
Cc: NeilBrown <neilb@suse.com>
Cc: Ben Evans <bevans@cray.com>
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: "John L. Hammond" <john.hammond@intel.com>
Cc: Dafna Hirschfeld <dafna3@gmail.com>
Cc: Mathias Rav <mathiasrav@gmail.com>
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: lustre-devel at lists.lustre.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 .../lustre/obdclass/linux/linux-module.c      | 19 ++-----------------
 .../lustre/lustre/obdclass/lprocfs_status.c   | 11 -----------
 2 files changed, 2 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index d3196439985b..9c800580053b 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -481,7 +481,6 @@ static const struct attribute_group lustre_attr_group = {
 int class_procfs_init(void)
 {
 	int rc = -ENOMEM;
-	struct dentry *file;
 
 	lustre_kobj = kobject_create_and_add("lustre", fs_kobj);
 	if (!lustre_kobj)
@@ -495,23 +494,9 @@ int class_procfs_init(void)
 	}
 
 	debugfs_lustre_root = debugfs_create_dir("lustre", NULL);
-	if (IS_ERR_OR_NULL(debugfs_lustre_root)) {
-		rc = debugfs_lustre_root ? PTR_ERR(debugfs_lustre_root)
-					 : -ENOMEM;
-		debugfs_lustre_root = NULL;
-		sysfs_remove_group(lustre_kobj, &lustre_attr_group);
-		kobject_put(lustre_kobj);
-		goto out;
-	}
 
-	file = debugfs_create_file("devices", 0444, debugfs_lustre_root, NULL,
-				   &obd_device_list_fops);
-	if (IS_ERR_OR_NULL(file)) {
-		rc = file ? PTR_ERR(file) : -ENOMEM;
-		sysfs_remove_group(lustre_kobj, &lustre_attr_group);
-		kobject_put(lustre_kobj);
-		goto out;
-	}
+	debugfs_create_file("devices", 0444, debugfs_lustre_root, NULL,
+			    &obd_device_list_fops);
 out:
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index eb6396add78d..c3f57b025f10 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -315,10 +315,6 @@ struct dentry *ldebugfs_add_simple(struct dentry *root,
 	if (fops->write)
 		mode |= 0200;
 	entry = debugfs_create_file(name, mode, root, data, fops);
-	if (IS_ERR_OR_NULL(entry)) {
-		CERROR("LprocFS: No memory to create <debugfs> entry %s\n", name);
-		return entry ?: ERR_PTR(-ENOMEM);
-	}
 	return entry;
 }
 EXPORT_SYMBOL_GPL(ldebugfs_add_simple);
@@ -348,8 +344,6 @@ int ldebugfs_add_vars(struct dentry *parent,
 					    list->data ?: data,
 					    list->fops ?: &lprocfs_generic_fops
 					   );
-		if (IS_ERR_OR_NULL(entry))
-			return entry ? PTR_ERR(entry) : -ENOMEM;
 		list++;
 	}
 	return 0;
@@ -1358,9 +1352,6 @@ int ldebugfs_register_stats(struct dentry *parent, const char *name,
 
 	entry = debugfs_create_file(name, 0644, parent, stats,
 				    &lprocfs_stats_seq_fops);
-	if (IS_ERR_OR_NULL(entry))
-		return entry ? PTR_ERR(entry) : -ENOMEM;
-
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ldebugfs_register_stats);
@@ -1588,8 +1579,6 @@ int ldebugfs_seq_create(struct dentry *parent, const char *name,
 	LASSERT((!seq_fops->write) == ((mode & 0222) == 0));
 
 	entry = debugfs_create_file(name, mode, parent, data, seq_fops);
-	if (IS_ERR_OR_NULL(entry))
-		return entry ? PTR_ERR(entry) : -ENOMEM;
 
 	return 0;
 }
-- 
2.17.0
