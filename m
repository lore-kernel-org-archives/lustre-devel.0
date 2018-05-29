From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 29 May 2018 16:29:40 +0200
Subject: [lustre-devel] [PATCH 06/13] staging: lustre: remove
 ldebugfs_add_simple() wrapper
In-Reply-To: <20180529142947.3250-1-gregkh@linuxfoundation.org>
References: <20180529142947.3250-1-gregkh@linuxfoundation.org>
Message-ID: <20180529142947.3250-6-gregkh@linuxfoundation.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

It was only being called in one place, and is an unneeded wrapper
function around debugfs_create_file() so just call the real debugfs
function instead.  This ends up cleaning up some unneeded error handling
logic that was never needed as well.

Cc: Oleg Drokin <oleg.drokin@intel.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>
Cc: James Simmons <jsimmons@infradead.org>
Cc: Quentin Bouget <quentin.bouget@cea.fr>
Cc: Ben Evans <bevans@cray.com>
Cc: NeilBrown <neilb@suse.com>
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: Dafna Hirschfeld <dafna3@gmail.com>
Cc: Mathias Rav <mathiasrav@gmail.com>
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: lustre-devel at lists.lustre.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 .../lustre/lustre/include/lprocfs_status.h    |  5 -----
 drivers/staging/lustre/lustre/lov/lov_pool.c  | 21 +++++--------------
 .../lustre/lustre/obdclass/lprocfs_status.c   | 19 -----------------
 3 files changed, 5 insertions(+), 40 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 1322ecffda13..9eac7dac8c7b 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -447,11 +447,6 @@ void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 			  const char *units);
 struct obd_export;
 int lprocfs_exp_cleanup(struct obd_export *exp);
-struct dentry *ldebugfs_add_simple(struct dentry *root,
-				   char *name,
-				   void *data,
-				   const struct file_operations *fops);
-
 int ldebugfs_register_stats(struct dentry *parent,
 			    const char *name,
 			    struct lprocfs_stats *stats);
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 6d2dec9266b6..9ce7038c9b0e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -80,7 +80,6 @@ void lov_pool_putref(struct pool_desc *pool)
 	CDEBUG(D_INFO, "pool %p\n", pool);
 	if (atomic_dec_and_test(&pool->pool_refcount)) {
 		LASSERT(list_empty(&pool->pool_list));
-		LASSERT(!pool->pool_debugfs_entry);
 		lov_ost_pool_free(&pool->pool_obds);
 		kfree_rcu(pool, rcu);
 	}
@@ -377,18 +376,11 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 
 	/* get ref for debugfs file */
 	lov_pool_getref(new_pool);
-	new_pool->pool_debugfs_entry = ldebugfs_add_simple(
+
+	new_pool->pool_debugfs_entry = debugfs_create_file(poolname, 0444,
 						lov->lov_pool_debugfs_entry,
-						poolname, new_pool,
+						new_pool,
 						&pool_proc_operations);
-	if (IS_ERR_OR_NULL(new_pool->pool_debugfs_entry)) {
-		CWARN("Cannot add debugfs pool entry " LOV_POOLNAMEF "\n",
-		      poolname);
-		new_pool->pool_debugfs_entry = NULL;
-		lov_pool_putref(new_pool);
-	}
-	CDEBUG(D_INFO, "pool %p - proc %p\n",
-	       new_pool, new_pool->pool_debugfs_entry);
 
 	spin_lock(&obd->obd_dev_lock);
 	list_add_tail(&new_pool->pool_list, &lov->lov_pool_list);
@@ -443,11 +435,8 @@ int lov_pool_del(struct obd_device *obd, char *poolname)
 	if (!pool)
 		return -ENOENT;
 
-	if (!IS_ERR_OR_NULL(pool->pool_debugfs_entry)) {
-		CDEBUG(D_INFO, "proc entry %p\n", pool->pool_debugfs_entry);
-		ldebugfs_remove(&pool->pool_debugfs_entry);
-		lov_pool_putref(pool);
-	}
+	ldebugfs_remove(&pool->pool_debugfs_entry);
+	lov_pool_putref(pool);
 
 	spin_lock(&obd->obd_dev_lock);
 	list_del_init(&pool->pool_list);
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index c3f57b025f10..68e85f46a146 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -300,25 +300,6 @@ EXPORT_SYMBOL(lprocfs_seq_release);
 
 /* lprocfs API calls */
 
-struct dentry *ldebugfs_add_simple(struct dentry *root,
-				   char *name, void *data,
-				   const struct file_operations *fops)
-{
-	struct dentry *entry;
-	umode_t mode = 0;
-
-	if (!root || !name || !fops)
-		return ERR_PTR(-EINVAL);
-
-	if (fops->read)
-		mode = 0444;
-	if (fops->write)
-		mode |= 0200;
-	entry = debugfs_create_file(name, mode, root, data, fops);
-	return entry;
-}
-EXPORT_SYMBOL_GPL(ldebugfs_add_simple);
-
 static const struct file_operations lprocfs_generic_fops = { };
 
 int ldebugfs_add_vars(struct dentry *parent,
-- 
2.17.0
