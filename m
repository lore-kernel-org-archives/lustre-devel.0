From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:07:55 -0500
Subject: [lustre-devel] [PATCH 007/622] lustre: llite: limit smallest
 max_cached_mb value
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Nunez <jnunez@whamcloud.com>

Currently, ost-survey hangs due to calling
'lfs setstripe' in an old (positional) style and
setting max_cached_mb to zero.

In ll_max_cached_mb_seq_write(), the number of
pages requested is set to the max of pages requested
or PTLRPC_MAX_BRW_PAGES to allow the client to make
well formed RPCs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-4768
Lustre-commit: 46bec835ac72 ("LU-4768 tests: Update ost-survey script")
Signed-off-by: James Nunez <jnunez@whamcloud.com>
Reviewed-on: http://review.whamcloud.com/11971
Reviewed-by: Nathaniel Clark <nclark@whamcloud.com>
Reviewed-by: Cliff White <cliff.white@intel.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/lproc_llite.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index e108326..5ac6689 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -527,6 +527,8 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 		       totalram_pages() >> (20 - PAGE_SHIFT));
 		return -ERANGE;
 	}
+	/* Allow enough cache so clients can make well-formed RPCs */
+	pages_number = max_t(long, pages_number, PTLRPC_MAX_BRW_PAGES);
 
 	spin_lock(&sbi->ll_lock);
 	diff = pages_number - cache->ccc_lru_max;
-- 
1.8.3.1
