From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:59 -0400
Subject: [lustre-devel] [PATCH 46/80] staging: lustre: llite: Change readdir
	BRW metrics
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-47-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

To simplify the code, change the metrics from bytes to pages.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5034
Reviewed-on: http://review.whamcloud.com/10275
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c          |    2 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 47fbcd2..924b5df 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -148,7 +148,7 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 	struct page **page_pool;
 	struct page *page;
 	struct lu_dirpage *dp;
-	int max_pages = ll_i2sbi(inode)->ll_md_brw_size >> PAGE_SHIFT;
+	int max_pages = ll_i2sbi(inode)->ll_md_brw_pages;
 	int nrdpgs = 0; /* number of pages read actually */
 	int npages;
 	int i;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 500b5ec..3d7fa9a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -474,7 +474,7 @@ struct ll_sb_info {
 	unsigned int	      ll_namelen;
 	struct file_operations   *ll_fop;
 
-	unsigned int	      ll_md_brw_size; /* used by readdir */
+	unsigned int		  ll_md_brw_pages; /* readdir pages per RPC */
 
 	struct lu_site	   *ll_site;
 	struct cl_device	 *ll_cl;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 0a28925..ac59cd6 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -319,9 +319,9 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 		sbi->ll_flags |= LL_SBI_64BIT_HASH;
 
 	if (data->ocd_connect_flags & OBD_CONNECT_BRW_SIZE)
-		sbi->ll_md_brw_size = data->ocd_brw_size;
+		sbi->ll_md_brw_pages = data->ocd_brw_size >> PAGE_SHIFT;
 	else
-		sbi->ll_md_brw_size = PAGE_SIZE;
+		sbi->ll_md_brw_pages = 1;
 
 	if (data->ocd_connect_flags & OBD_CONNECT_LAYOUTLOCK)
 		sbi->ll_flags |= LL_SBI_LAYOUT_LOCK;
-- 
1.7.1
