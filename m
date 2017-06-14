From: James Simmons <jsimmons@infradead.org>
Date: Wed, 14 Jun 2017 11:01:18 -0400
Subject: [lustre-devel] [PATCH 3/6] staging: lustre: lustre: fix all bare
	unsigned usage
In-Reply-To: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1497452481-31124-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Turn all bare unsigned usage in the lustre code to proper
unsigned int.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h | 4 ++--
 drivers/staging/lustre/lustre/include/lu_object.h | 4 ++--
 drivers/staging/lustre/lustre/llite/namei.c       | 2 +-
 drivers/staging/lustre/lustre/llite/rw26.c        | 2 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c     | 6 +++---
 drivers/staging/lustre/lustre/osc/osc_cache.c     | 6 +++---
 drivers/staging/lustre/lustre/osc/osc_internal.h  | 2 +-
 7 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 2bc3ee5..90a0c50 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1287,7 +1287,7 @@ struct cl_lock_operations {
  * @{
  */
 struct cl_page_list {
-	unsigned	     pl_nr;
+	unsigned int		 pl_nr;
 	struct list_head	   pl_pages;
 	struct task_struct	*pl_owner;
 };
@@ -1842,7 +1842,7 @@ struct cl_io {
 	/**
 	 * Number of pages owned by this IO. For invariant checking.
 	 */
-	unsigned	     ci_owned_nr;
+	unsigned int	     ci_owned_nr;
 };
 
 /** @} cl_io */
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 73ecc23..2e70602 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -968,11 +968,11 @@ struct lu_context {
 	 * Version counter used to skip calls to lu_context_refill() when no
 	 * keys were registered.
 	 */
-	unsigned	       lc_version;
+	unsigned int		lc_version;
 	/**
 	 * Debugging cookie.
 	 */
-	unsigned	       lc_cookie;
+	unsigned int		lc_cookie;
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 9f118a1..a208a8b 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -678,7 +678,7 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
  * together.
  */
 static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
-			  struct file *file, unsigned open_flags,
+			  struct file *file, unsigned int open_flags,
 			  umode_t mode, int *opened)
 {
 	struct lookup_intent *it;
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 22dc6a5..3619cd8 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -547,7 +547,7 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 }
 
 static int ll_write_end(struct file *file, struct address_space *mapping,
-			loff_t pos, unsigned len, unsigned copied,
+			loff_t pos, unsigned int len, unsigned int copied,
 			struct page *vmpage, void *fsdata)
 {
 	struct ll_cl_context *lcc = fsdata;
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 6cb2db2..8e45672 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -381,11 +381,11 @@ int cl_sb_fini(struct super_block *sb)
 #define PGC_DEPTH_SHIFT (32)
 
 struct vvp_pgcache_id {
-	unsigned		 vpi_bucket;
-	unsigned		 vpi_depth;
+	unsigned int		 vpi_bucket;
+	unsigned int		 vpi_depth;
 	uint32_t		 vpi_index;
 
-	unsigned		 vpi_curdep;
+	unsigned int		 vpi_curdep;
 	struct lu_object_header *vpi_obj;
 };
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 4db8116..d8a95f8 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1889,10 +1889,10 @@ struct extent_rpc_data {
 	unsigned int		erd_max_chunks;
 };
 
-static inline unsigned osc_extent_chunks(const struct osc_extent *ext)
+static inline unsigned int osc_extent_chunks(const struct osc_extent *ext)
 {
 	struct client_obd *cli = osc_cli(ext->oe_obj);
-	unsigned ppc_bits = cli->cl_chunkbits - PAGE_SHIFT;
+	unsigned int ppc_bits = cli->cl_chunkbits - PAGE_SHIFT;
 
 	return (ext->oe_end >> ppc_bits) - (ext->oe_start >> ppc_bits) + 1;
 }
@@ -1950,7 +1950,7 @@ static int try_to_add_extent_for_io(struct client_obd *cli,
 	return 1;
 }
 
-static inline unsigned osc_max_write_chunks(const struct client_obd *cli)
+static inline unsigned int osc_max_write_chunks(const struct client_obd *cli)
 {
 	/*
 	 * LU-8135:
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 845e795..13a40f6 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -62,7 +62,7 @@ struct osc_async_page {
 	struct list_head	      oap_rpc_item;
 
 	u64		 oap_obj_off;
-	unsigned		oap_page_off;
+	unsigned int		oap_page_off;
 	enum async_flags	oap_async_flags;
 
 	struct brw_page	 oap_brw_page;
-- 
1.8.3.1
