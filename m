From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed,  2 Nov 2016 21:25:02 -0400
Subject: [lustre-devel] [PATCH 12/14] staging/lustre/llite: update ras
	window correctly
In-Reply-To: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
References: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1478136304-867780-13-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Bobi Jam <bobijam.xu@intel.com>

When stride-RA hit case miss, we only reset normal sequential
read-ahead window, but not reset the stride IO to avoid the overhead
of re-detecting stride IO. While when the normal RA window is set
to not insect with the stride-RA window, when we try to increase
the stride-RA window length later, the presumption does not hold.

This patch resets the stride IO as well in this case.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Reviewed-on: http://review.whamcloud.com/23032
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8683
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/rw.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index d2515a8..e34017d 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -809,13 +809,20 @@ static void ras_update(struct ll_sb_info *sbi, struct inode *inode,
 		if (ra_miss) {
 			if (index_in_stride_window(ras, index) &&
 			    stride_io_mode(ras)) {
-				/*If stride-RA hit cache miss, the stride dector
-				 *will not be reset to avoid the overhead of
-				 *redetecting read-ahead mode
-				 */
 				if (index != ras->ras_last_readpage + 1)
 					ras->ras_consecutive_pages = 0;
 				ras_reset(inode, ras, index);
+
+				/* If stride-RA hit cache miss, the stride
+				 * detector will not be reset to avoid the
+				 * overhead of redetecting read-ahead mode,
+				 * but on the condition that the stride window
+				 * is still intersect with normal sequential
+				 * read-ahead window.
+				 */
+				if (ras->ras_window_start <
+				    ras->ras_stride_offset)
+					ras_stride_reset(ras);
 				RAS_CDEBUG(ras);
 			} else {
 				/* Reset both stride window and normal RA
-- 
2.7.4
