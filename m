From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri, 26 Feb 2016 01:50:12 -0500
Subject: [lustre-devel] [PATCH 24/25] staging/lustre: Remove unneeded {} in
	lprocfs_stats_unlock()
In-Reply-To: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
References: <1456469413-931943-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456469413-931943-25-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Since there's only one call in those if () else branches, the
braces are not really necessary.

Highlighted by checkpatch.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lprocfs_status.h | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 89052b2..4146c9c 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -426,11 +426,10 @@ static inline void lprocfs_stats_unlock(struct lprocfs_stats *stats, int opc,
 
 	case LPROCFS_GET_SMP_ID:
 		if (stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) {
-			if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE) {
+			if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE)
 				spin_unlock_irqrestore(&stats->ls_lock, *flags);
-			} else {
+			else
 				spin_unlock(&stats->ls_lock);
-			}
 		} else {
 			put_cpu();
 		}
@@ -438,11 +437,10 @@ static inline void lprocfs_stats_unlock(struct lprocfs_stats *stats, int opc,
 
 	case LPROCFS_GET_NUM_CPU:
 		if (stats->ls_flags & LPROCFS_STATS_FLAG_NOPERCPU) {
-			if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE) {
+			if (stats->ls_flags & LPROCFS_STATS_FLAG_IRQ_SAFE)
 				spin_unlock_irqrestore(&stats->ls_lock, *flags);
-			} else {
+			else
 				spin_unlock(&stats->ls_lock);
-			}
 		}
 		return;
 	}
-- 
2.1.0
