From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 21:37:18 -0400
Subject: [lustre-devel] [PATCH 09/12] staging: lustre: llite: check ret of
	ll_prep_md_op_data in ll_dir_filler
In-Reply-To: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
References: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461807441-3210-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Swapnil Pimpale <spimpale@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Swapnil Pimpale <spimpale@ddn.com>

ll_dir_filler() now checks the returned pointer from
ll_prep_md_op_data() using IS_ERR()

Signed-off-by: Swapnil Pimpale <spimpale@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4082
Reviewed-on: http://review.whamcloud.com/8073
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 09d3297..56aa7de 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -163,6 +163,11 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 
 	LASSERT(max_pages > 0 && max_pages <= MD_MAX_BRW_PAGES);
 
+	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, NULL);
+	if (IS_ERR(op_data))
+		return PTR_ERR(op_data);
+
 	page_pool = kcalloc(max_pages, sizeof(page), GFP_NOFS);
 	if (page_pool) {
 		page_pool[0] = page0;
@@ -177,8 +182,6 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 		page_pool[npages] = page;
 	}
 
-	op_data = ll_prep_md_op_data(NULL, inode, NULL, NULL, 0, 0,
-				     LUSTRE_OPC_ANY, NULL);
 	op_data->op_npages = npages;
 	op_data->op_offset = hash;
 	rc = md_readpage(exp, op_data, page_pool, &request);
-- 
2.7.4
