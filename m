From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:14 -0500
Subject: [lustre-devel] [PATCH 206/622] lustre: llog: add synchronization
 for the last record
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-207-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

The initial problem was a race between llog_process_thread
and llog_osd_write_rec for a last record with lgh_last_idx.
The catalog should be wrapped for the problem. The lgh_last_idx
could be increased with a modification of llog bitmap, and a writing
record happen a bit later. When llog_process_thread processing
lgh_last_idx after modification and before a write it operates
with old record data.

The lustre client is only a consumer of llog records but we still
need the changes to better handle consumption of the llog records.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11591
Lustre-commit: ec4194e4e78c ("LU-11591 llog: add synchronization for the last record")
Signed-off-by: Alexander Boyko <c17825@cray.com>
Cray-bug-id: LUS-6683
Reviewed-on: https://review.whamcloud.com/33683
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/llog.c | 68 ++++++++++++++++++++++++++++++++++-------------
 1 file changed, 50 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index 65384ded..4e9fd17 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -230,10 +230,11 @@ static int llog_process_thread(void *arg)
 	struct llog_process_cat_data *cd  = lpi->lpi_catdata;
 	char *buf;
 	u64 cur_offset, tmp_offset;
-	int chunk_size;
+	size_t chunk_size;
 	int rc = 0, index = 1, last_index;
 	int saved_index = 0;
 	int last_called_index = 0;
+	bool repeated = false;
 
 	if (!llh)
 		return -EINVAL;
@@ -261,8 +262,10 @@ static int llog_process_thread(void *arg)
 	while (rc == 0) {
 		unsigned int buf_offset = 0;
 		struct llog_rec_hdr *rec;
+		off_t chunk_offset = 0;
 		bool partial_chunk;
-		off_t chunk_offset;
+		int synced_idx = 0;
+		int lh_last_idx;
 
 		/* skip records not set in bitmap */
 		while (index <= last_index &&
@@ -277,8 +280,23 @@ static int llog_process_thread(void *arg)
 repeat:
 		/* get the buf with our target record; avoid old garbage */
 		memset(buf, 0, chunk_size);
+		/* the record index for outdated chunk data */
+		/* it is safe to process buffer until saved lgh_last_idx */
+		lh_last_idx = LLOG_HDR_TAIL(llh)->lrt_index;
 		rc = llog_next_block(lpi->lpi_env, loghandle, &saved_index,
 				     index, &cur_offset, buf, chunk_size);
+		if (repeated && rc)
+			CDEBUG(D_OTHER,
+			       "cur_offset %llu, chunk_offset %llu, buf_offset %u, rc = %d\n",
+			       cur_offset, (u64)chunk_offset, buf_offset, rc);
+		/* we`ve tried to reread the chunk, but there is no
+		 * new records
+		 */
+		if (rc == -EIO && repeated && (chunk_offset + buf_offset) ==
+		    cur_offset) {
+			rc = 0;
+			goto out;
+		}
 		if (rc)
 			goto out;
 
@@ -313,29 +331,43 @@ static int llog_process_thread(void *arg)
 			CDEBUG(D_OTHER, "after swabbing, type=%#x idx=%d\n",
 			       rec->lrh_type, rec->lrh_index);
 
-			/*
-			 * for partial chunk the end of it is zeroed, check
-			 * for index 0 to distinguish it.
+			if (index == (synced_idx + 1) &&
+			    synced_idx == LLOG_HDR_TAIL(llh)->lrt_index) {
+				rc = 0;
+				goto out;
+			}
+
+			/* the bitmap could be changed during processing
+			 * records from the chunk. For wrapped catalog
+			 * it means we can read deleted record and try to
+			 * process it. Check this case and reread the chunk.
+			 * It is safe to process to lh_last_idx, including
+			 * lh_last_idx if it was synced. We can not do <=
+			 * comparison, cause for wrapped catalog lgh_last_idx
+			 * could be less than index. So we detect last index
+			 * for processing as index == lh_last_idx+1. But when
+			 * catalog is wrapped and full lgh_last_idx=llh_cat_idx,
+			 * the first processing index is llh_cat_idx+1.
 			 */
-			if (partial_chunk && !rec->lrh_index) {
-				/* concurrent llog_add() might add new records
-				 * while llog_processing, check this is not
-				 * the case and re-read the current chunk
-				 * otherwise.
-				 */
-				if (index > loghandle->lgh_last_idx) {
-					rc = 0;
-					goto out;
-				}
-				CDEBUG(D_OTHER,
-				       "Re-read last llog buffer for new records, index %u, last %u\n",
-				       index, loghandle->lgh_last_idx);
+			if ((index == lh_last_idx && synced_idx != index) ||
+			    (index == (lh_last_idx + 1) &&
+			     !(index == (llh->llh_cat_idx + 1) &&
+			       (llh->llh_flags & LLOG_F_IS_CAT))) ||
+			     (rec->lrh_index == 0 && !repeated)) {
 				/* save offset inside buffer for the re-read */
 				buf_offset = (char *)rec - (char *)buf;
 				cur_offset = chunk_offset;
+				repeated = true;
+				/* We need to be sure lgh_last_idx
+				 * record was saved to disk
+				 */
+				synced_idx = LLOG_HDR_TAIL(llh)->lrt_index;
+				CDEBUG(D_OTHER, "synced_idx: %d\n", synced_idx);
 				goto repeat;
 			}
 
+			repeated = false;
+
 			if (!rec->lrh_len || rec->lrh_len > chunk_size) {
 				CWARN("invalid length %d in llog record for index %d/%d\n",
 				      rec->lrh_len,
-- 
1.8.3.1
