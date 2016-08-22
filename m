From: Shawn Lin <shawn.lin@rock-chips.com>
Date: Mon, 22 Aug 2016 16:46:04 +0800
Subject: [lustre-devel] [PATCH] staging/lustre: avoid zero buf for the first
	time
Message-ID: <1471855564-15962-1-git-send-email-shawn.lin@rock-chips.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Shawn Lin <shawn.lin@rock-chips.com>

We only need to zero it when repeating in order to
avoid old garbage. Let's improve it by moving this
before we repeat the calculation to save some cpu
cycle.

Signed-off-by: Shawn Lin <shawn.lin@rock-chips.com>
---

 drivers/staging/lustre/lustre/obdclass/llog.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 1784ca0..923061f 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -248,8 +248,6 @@ repeat:
 		CDEBUG(D_OTHER, "index: %d last_index %d\n",
 		       index, last_index);
 
-		/* get the buf with our target record; avoid old garbage */
-		memset(buf, 0, LLOG_CHUNK_SIZE);
 		last_offset = cur_offset;
 		rc = llog_next_block(lpi->lpi_env, loghandle, &saved_index,
 				     index, &cur_offset, buf, LLOG_CHUNK_SIZE);
@@ -275,8 +273,11 @@ repeat:
 			if (rec->lrh_index == 0) {
 				/* probably another rec just got added? */
 				rc = 0;
-				if (index <= loghandle->lgh_last_idx)
+				if (index <= loghandle->lgh_last_idx) {
+					/* avoid old garbage */
+					memset(buf, 0, LLOG_CHUNK_SIZE);
 					goto repeat;
+				}
 				goto out; /* no more records */
 			}
 			if (rec->lrh_len == 0 ||
-- 
2.3.7
