From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:23 -0400
Subject: [lustre-devel] [PATCH 084/124] staging: lustre: fiemap: set
	FIEMAP_EXTENT_LAST correctly
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-85-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

When we've collected enough extents as user requested, we'd check one
further to decide whether we've reached the last extent of the file.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5933
Reviewed-on: http://review.whamcloud.com/12781
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_obd.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 9b12159..9ab3033 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1548,6 +1548,8 @@ static int lov_fiemap(struct lov_obd *lov, __u32 keylen, void *key,
 	u64 fm_start, fm_end, fm_length, fm_end_offset;
 	u64 curr_loc;
 	int current_extent = 0, rc = 0, i;
+	/* Whether have we collected enough extents */
+	bool enough = false;
 	int ost_eof = 0; /* EOF for object */
 	int ost_done = 0; /* done with required mapping for this OST? */
 	int last_stripe;
@@ -1682,7 +1684,7 @@ static int lov_fiemap(struct lov_obd *lov, __u32 keylen, void *key,
 			lun_start += len_mapped_single_call;
 			fm_local->fm_length = req_fm_len - len_mapped_single_call;
 			req_fm_len = fm_local->fm_length;
-			fm_local->fm_extent_count = count_local;
+			fm_local->fm_extent_count = enough ? 1 : count_local;
 			fm_local->fm_mapped_extents = 0;
 			fm_local->fm_flags = fiemap->fm_flags;
 
@@ -1730,6 +1732,12 @@ inactive_tgt:
 					goto finish;
 				}
 				break;
+			} else if (enough) {
+				/*
+				 * We've collected enough extents and there are
+				 * more extents after it.
+				 */
+				goto finish;
 			}
 
 			/* If we just need num of extents then go to next device */
@@ -1769,7 +1777,7 @@ inactive_tgt:
 
 			/* Ran out of available extents? */
 			if (current_extent >= fiemap->fm_extent_count)
-				goto finish;
+				enough = true;
 		} while (ost_done == 0 && ost_eof == 0);
 
 		if (cur_stripe_wrap == last_stripe)
-- 
1.7.1
