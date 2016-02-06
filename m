From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Sat,  6 Feb 2016 02:01:51 -0500
Subject: [lustre-devel] [PATCH 2/2] staging/lustre/obdclass: export debugfs
	functionality for GPL only.
In-Reply-To: <1454742111-2231460-1-git-send-email-green@linuxhacker.ru>
References: <1454742111-2231460-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1454742111-2231460-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Turns out we mistakenly export some pretty-wide-reaching debugfs
functions as EXPORT_SYMBOL instead of EXPORT_SYMBOL_GPL as we should,
so this patch rectifies the situation.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/obdclass/lprocfs_status.c    | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index b65ad93..9a1434d 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -261,7 +261,7 @@ struct dentry *ldebugfs_add_simple(struct dentry *root,
 	}
 	return entry;
 }
-EXPORT_SYMBOL(ldebugfs_add_simple);
+EXPORT_SYMBOL_GPL(ldebugfs_add_simple);
 
 static struct file_operations lprocfs_generic_fops = { };
 
@@ -294,14 +294,14 @@ int ldebugfs_add_vars(struct dentry *parent,
 	}
 	return 0;
 }
-EXPORT_SYMBOL(ldebugfs_add_vars);
+EXPORT_SYMBOL_GPL(ldebugfs_add_vars);
 
 void ldebugfs_remove(struct dentry **entryp)
 {
 	debugfs_remove_recursive(*entryp);
 	*entryp = NULL;
 }
-EXPORT_SYMBOL(ldebugfs_remove);
+EXPORT_SYMBOL_GPL(ldebugfs_remove);
 
 struct dentry *ldebugfs_register(const char *name,
 				 struct dentry *parent,
@@ -327,7 +327,7 @@ struct dentry *ldebugfs_register(const char *name,
 out:
 	return entry;
 }
-EXPORT_SYMBOL(ldebugfs_register);
+EXPORT_SYMBOL_GPL(ldebugfs_register);
 
 /* Generic callbacks */
 int lprocfs_rd_uint(struct seq_file *m, void *data)
@@ -942,7 +942,7 @@ int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
 
 	return rc;
 }
-EXPORT_SYMBOL(lprocfs_obd_setup);
+EXPORT_SYMBOL_GPL(lprocfs_obd_setup);
 
 int lprocfs_obd_cleanup(struct obd_device *obd)
 {
@@ -957,7 +957,7 @@ int lprocfs_obd_cleanup(struct obd_device *obd)
 
 	return 0;
 }
-EXPORT_SYMBOL(lprocfs_obd_cleanup);
+EXPORT_SYMBOL_GPL(lprocfs_obd_cleanup);
 
 int lprocfs_stats_alloc_one(struct lprocfs_stats *stats, unsigned int cpuid)
 {
@@ -1219,7 +1219,7 @@ int ldebugfs_register_stats(struct dentry *parent, const char *name,
 
 	return 0;
 }
-EXPORT_SYMBOL(ldebugfs_register_stats);
+EXPORT_SYMBOL_GPL(ldebugfs_register_stats);
 
 void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 			  unsigned conf, const char *name, const char *units)
@@ -1446,7 +1446,7 @@ int ldebugfs_seq_create(struct dentry *parent,
 
 	return 0;
 }
-EXPORT_SYMBOL(ldebugfs_seq_create);
+EXPORT_SYMBOL_GPL(ldebugfs_seq_create);
 
 int ldebugfs_obd_seq_create(struct obd_device *dev,
 			    const char *name,
@@ -1457,7 +1457,7 @@ int ldebugfs_obd_seq_create(struct obd_device *dev,
 	return ldebugfs_seq_create(dev->obd_debugfs_entry, name,
 				   mode, seq_fops, data);
 }
-EXPORT_SYMBOL(ldebugfs_obd_seq_create);
+EXPORT_SYMBOL_GPL(ldebugfs_obd_seq_create);
 
 void lprocfs_oh_tally(struct obd_histogram *oh, unsigned int value)
 {
-- 
2.1.0
