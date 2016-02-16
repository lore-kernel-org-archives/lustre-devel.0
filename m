From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:10 -0500
Subject: [lustre-devel] [PATCH 38/45] staging/lustre/libcfs: Remove empty
	lines after/before braces
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-39-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

No need for an empty line after opening curvy brace and no need
for an empty line before the closing one too.
Remove them.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c    | 2 --
 drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c | 1 -
 drivers/staging/lustre/lustre/libcfs/module.c                | 1 -
 drivers/staging/lustre/lustre/libcfs/tracefile.c             | 4 ----
 4 files changed, 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c
index 140134d..b0b1244 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-crypto.c
@@ -125,7 +125,6 @@ struct cfs_crypto_hash_desc *
 	cfs_crypto_hash_init(unsigned char alg_id,
 			     unsigned char *key, unsigned int key_len)
 {
-
 	struct  hash_desc       *hdesc;
 	int		     err;
 	const struct cfs_crypto_hash_type       *type;
@@ -212,7 +211,6 @@ static void cfs_crypto_performance_test(unsigned char alg_id,
 					     hash, &hash_len);
 		if (err)
 			break;
-
 	}
 	end = jiffies;
 
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
index f0880a0..eccf048 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
@@ -65,7 +65,6 @@ int cfs_tracefile_init_arch(void)
 				num_possible_cpus(), GFP_KERNEL);
 		if (!cfs_trace_data[i])
 			goto out;
-
 	}
 
 	/* arch related info initialized */
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index b8b69bb..ea3dc9b 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -549,7 +549,6 @@ void lustre_insert_debugfs(struct ctl_table *table,
 	for (; symlinks && symlinks->name; symlinks++)
 		debugfs_create_symlink(symlinks->name, lnet_debugfs_root,
 				       symlinks->target);
-
 }
 EXPORT_SYMBOL_GPL(lustre_insert_debugfs);
 
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index b3abec6..53c1dd6 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -598,7 +598,6 @@ static void put_pages_back_on_all_cpus(struct page_collection *pc)
 
 			list_for_each_entry_safe(tage, tmp, &pc->pc_pages,
 						 linkage) {
-
 				__LASSERT_TAGE_INVARIANT(tage);
 
 				if (tage->cpu != cpu || tage->type != i)
@@ -629,7 +628,6 @@ static void put_pages_on_tcd_daemon_list(struct page_collection *pc,
 	struct cfs_trace_page *tmp;
 
 	list_for_each_entry_safe(tage, tmp, &pc->pc_pages, linkage) {
-
 		__LASSERT_TAGE_INVARIANT(tage);
 
 		if (tage->cpu != tcd->tcd_cpu || tage->type != tcd->tcd_type)
@@ -737,7 +735,6 @@ int cfs_tracefile_dump_all_pages(char *filename)
 	 */
 	MMSPACE_OPEN;
 	list_for_each_entry_safe(tage, tmp, &pc.pc_pages, linkage) {
-
 		__LASSERT_TAGE_INVARIANT(tage);
 
 		buf = kmap(tage->page);
@@ -775,7 +772,6 @@ void cfs_trace_flush_pages(void)
 	pc.pc_want_daemon_pages = 1;
 	collect_pages(&pc);
 	list_for_each_entry_safe(tage, tmp, &pc.pc_pages, linkage) {
-
 		__LASSERT_TAGE_INVARIANT(tage);
 
 		list_del(&tage->linkage);
-- 
2.1.0
