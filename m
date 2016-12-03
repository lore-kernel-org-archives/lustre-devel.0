From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:13 -0500
Subject: [lustre-devel] [PATCH 06/22] staging: lustre: llog: reset llog
	bitmap
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

Once update request fails due to eviction or other failures,
all of update request in the sending list should return fail,
because after the failure, the update log in the following
request will have wrong llog bitmap.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7039
Reviewed-on: http://review.whamcloud.com/16969
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/llog.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index ae63047..65e6ce6 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -114,6 +114,7 @@ static int llog_read_header(const struct lu_env *env,
 	rc = lop->lop_read_header(env, handle);
 	if (rc == LLOG_EEMPTY) {
 		struct llog_log_hdr *llh = handle->lgh_hdr;
+		size_t len;
 
 		/* lrh_len should be initialized in llog_init_handle */
 		handle->lgh_last_idx = 0; /* header is record with index 0 */
@@ -127,6 +128,12 @@ static int llog_read_header(const struct lu_env *env,
 			memcpy(&llh->llh_tgtuuid, uuid,
 			       sizeof(llh->llh_tgtuuid));
 		llh->llh_bitmap_offset = offsetof(typeof(*llh), llh_bitmap);
+		/*
+		 * Since update llog header might also call this function,
+		 * let's reset the bitmap to 0 here
+		 */
+		len = llh->llh_hdr.lrh_len - llh->llh_bitmap_offset;
+		memset(LLOG_HDR_BITMAP(llh), 0, len - sizeof(llh->llh_tail));
 		ext2_set_bit(0, LLOG_HDR_BITMAP(llh));
 		LLOG_HDR_TAIL(llh)->lrt_len = llh->llh_hdr.lrh_len;
 		LLOG_HDR_TAIL(llh)->lrt_index = llh->llh_hdr.lrh_index;
-- 
1.7.1
