From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Sun,  5 Jun 2016 23:28:50 -0400
Subject: [lustre-devel] [PATCH 1/4] staging/lustre/lov: calculate file
	offset correctly
In-Reply-To: <1465183733-3147667-1-git-send-email-green@linuxhacker.ru>
References: <1465183733-3147667-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465183733-3147667-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Oleg Drokin <oleg.drokin@intel.com>

From: Jinshan Xiong <jinshan.xiong@intel.com>

In lov_stripe_pgoff(), it calls lov_stripe_size() to calculate the
file size by ost_size, which will be wrong if the stripe_index
happens to be stripe aligned.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-on: http://review.whamcloud.com/14462
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6482
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lustre/lov/lov_offset.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index 9302f06..7636bfa 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -74,7 +74,7 @@ pgoff_t lov_stripe_pgoff(struct lov_stripe_md *lsm, pgoff_t stripe_index,
 {
 	loff_t offset;
 
-	offset = lov_stripe_size(lsm, stripe_index << PAGE_SHIFT, stripe);
+	offset = lov_stripe_size(lsm, (stripe_index << PAGE_SHIFT) + 1, stripe);
 	return offset >> PAGE_SHIFT;
 }
 
-- 
2.7.4
