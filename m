From: James Simmons <jsimmons@infradead.org>
Date: Sun, 10 Apr 2016 09:13:30 -0400
Subject: [lustre-devel] [PATCH 07/17] staging: lustre: llite: error setting
	max_cache_mb at mount time
In-Reply-To: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
References: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460294020-2111-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

The root cause is that when max_cache_mb conf parameter is applied,
the client isn't connected to the OST yet so that sbi->ll_dt_exp is
NULL. However, it's not necessary to shrink the cache memory in this
case so success should be returned.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3676
Reviewed-on: http://review.whamcloud.com/7194
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/lproc_llite.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 091144f..6947913 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -461,8 +461,8 @@ static ssize_t ll_max_cached_mb_seq_write(struct file *file,
 			break;
 
 		if (!sbi->ll_dt_exp) { /* being initialized */
-			rc = -ENODEV;
-			break;
+			rc = 0;
+			goto out;
 		}
 
 		/* difficult - have to ask OSCs to drop LRU slots. */
-- 
1.7.1
