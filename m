Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D16B8C4332F
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:31:21 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXhz4JT5z21B1;
	Sun, 20 Nov 2022 06:19:47 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXgv6P5Dz1yFh
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:18:51 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C796C1008252;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C5CE7E8B84; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:16:55 -0500
Message-Id: <1668953828-10909-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/22] lustre: llog: skip bad records in llog
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mikhail Pershin <mpershin@whamcloud.com>

This patch is further development of idea to skip bad
corrupted) llogs data. If llog has fixed-size records
then it is possible to skip one record but not rest of
llog block.

Patch also fixes the skipping to the next chunk:
 - make sure to skip to the next block for partial chunk
   or it causes the same block re-read.
 - handle index == 0 as goal for the llog_next_block() as
   expected exclusion and just return requested block
 - set new index after block was skipped to the first one
   in block
 - don't create fake padding record in llog_osd_next_block()
   as the caller can handle it and would know about
 - restore test_8 functionality to check corruption handling

Fixes: b79e7c205e40 ("lustre: llog: add synchronization for the last record")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16203
Lustre-commit: cf121b16685fe2a27 ("LU-16203 llog: skip bad records in llog")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48776
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/llog.c | 86 ++++++++++++++++++++++++++++-------------------
 1 file changed, 52 insertions(+), 34 deletions(-)

diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index eb8f7e5..90bb8bd 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -233,27 +233,26 @@ int llog_init_handle(const struct lu_env *env, struct llog_handle *handle,
 }
 EXPORT_SYMBOL(llog_init_handle);
 
+#define LLOG_ERROR_REC(lgh, rec, format, a...) \
+	CERROR("%s: "DFID" rec type=%x idx=%u len=%u, " format "\n", \
+	       loghandle2name(lgh), PLOGID(&lgh->lgh_id), (rec)->lrh_type, \
+	       (rec)->lrh_index, (rec)->lrh_len, ##a)
+
 int llog_verify_record(const struct llog_handle *llh, struct llog_rec_hdr *rec)
 {
 	int chunk_size = llh->lgh_hdr->llh_hdr.lrh_len;
 
-	if (rec->lrh_len == 0 || rec->lrh_len > chunk_size) {
-		CERROR("%s: record is too large: %d > %d\n",
-		       loghandle2name(llh), rec->lrh_len, chunk_size);
-		return -EINVAL;
-	}
-	if (rec->lrh_index >= LLOG_HDR_BITMAP_SIZE(llh->lgh_hdr)) {
-		CERROR("%s: index is too high: %d\n",
-		       loghandle2name(llh), rec->lrh_index);
-		return -EINVAL;
-	}
-	if ((rec->lrh_type & LLOG_OP_MASK) != LLOG_OP_MAGIC) {
-		CERROR("%s: magic %x is bad\n",
-		       loghandle2name(llh), rec->lrh_type);
-		return -EINVAL;
-	}
+	if ((rec->lrh_type & LLOG_OP_MASK) != LLOG_OP_MAGIC)
+		LLOG_ERROR_REC(llh, rec, "magic is bad");
+	else if (rec->lrh_len == 0 || rec->lrh_len > chunk_size)
+		LLOG_ERROR_REC(llh, rec, "bad record len, chunk size is %d",
+			       chunk_size);
+	else if (rec->lrh_index >= LLOG_HDR_BITMAP_SIZE(llh->lgh_hdr))
+		LLOG_ERROR_REC(llh, rec, "index is too high");
+	else
+		return 0;
 
-	return 0;
+	return -EINVAL;
 }
 
 static inline bool llog_is_index_skipable(int idx, struct llog_log_hdr *llh,
@@ -278,7 +277,6 @@ static int llog_process_thread(void *arg)
 	int saved_index = 0;
 	int last_called_index = 0;
 	bool repeated = false;
-	bool refresh_idx = false;
 
 	if (!llh)
 		return -EINVAL;
@@ -346,6 +344,11 @@ static int llog_process_thread(void *arg)
 			rc = 0;
 			goto out;
 		}
+		/* EOF while trying to skip to the next chunk */
+		if (!index && rc == -EBADR) {
+			rc = 0;
+			goto out;
+		}
 		if (rc)
 			goto out;
 
@@ -377,6 +380,15 @@ static int llog_process_thread(void *arg)
 			CDEBUG(D_OTHER, "after swabbing, type=%#x idx=%d\n",
 			       rec->lrh_type, rec->lrh_index);
 
+			/* start with first rec if block was skipped */
+			if (!index) {
+				CDEBUG(D_OTHER,
+				       "%s: skipping to the index %u\n",
+				       loghandle2name(loghandle),
+				       rec->lrh_index);
+				index = rec->lrh_index;
+			}
+
 			if (index == (synced_idx + 1) &&
 			    synced_idx == LLOG_HDR_TAIL(llh)->lrt_index) {
 				rc = 0;
@@ -399,11 +411,15 @@ static int llog_process_thread(void *arg)
 			 * it turns to
 			 * lh_last_idx != LLOG_HDR_TAIL(llh)->lrt_index
 			 * This exception is working for catalog only.
+			 * The last check is for the partial chunk boundary,
+			 * if it is reached then try to re-read for possible
+			 * new records once.
 			 */
 			if ((index == lh_last_idx && synced_idx != index) ||
 			    (index == (lh_last_idx + 1) &&
 			     lh_last_idx != LLOG_HDR_TAIL(llh)->lrt_index) ||
-			    (rec->lrh_index == 0 && !repeated)) {
+			    (((char *)rec - buf >= cur_offset - chunk_offset) &&
+			    !repeated)) {
 				/* save offset inside buffer for the re-read */
 				buf_offset = (char *)rec - (char *)buf;
 				cur_offset = chunk_offset;
@@ -415,24 +431,27 @@ static int llog_process_thread(void *arg)
 				CDEBUG(D_OTHER, "synced_idx: %d\n", synced_idx);
 				goto repeat;
 			}
-
 			repeated = false;
 
 			rc = llog_verify_record(loghandle, rec);
 			if (rc) {
-				CERROR("%s: invalid record in llog "DFID" record for index %d/%d: rc = %d\n",
-				       loghandle2name(loghandle),
-				       PLOGID(&loghandle->lgh_id),
-				       rec->lrh_len, index, rc);
+				CDEBUG(D_OTHER, "invalid record at index %d\n",
+				       index);
 				/*
-				 * the block seem to be corrupted, let's try
-				 * with the next one. reset rc to go to the
-				 * next chunk.
+				 * for fixed-sized llogs we can skip one record
+				 * by using llh_size from llog header.
+				 * Otherwise skip the next llog chunk.
 				 */
-				refresh_idx = true;
-				index = 0;
 				rc = 0;
-				goto repeat;
+				if (llh->llh_flags & LLOG_F_IS_FIXSIZE) {
+					rec->lrh_len = llh->llh_size;
+					goto next_rec;
+				}
+				/* make sure that is always next block */
+				cur_offset = chunk_offset + chunk_size;
+				/* no goal to find, just next block to read */
+				index = 0;
+				break;
 			}
 
 			if (rec->lrh_index < index) {
@@ -446,10 +465,9 @@ static int llog_process_thread(void *arg)
 				 * gap which can be result of old bugs, just
 				 * keep going
 				 */
-				CERROR("%s: "DFID" index %u, expected %u\n",
-				       loghandle2name(loghandle),
-				       PLOGID(&loghandle->lgh_id),
-				       rec->lrh_index, index);
+				LLOG_ERROR_REC(loghandle, rec,
+					       "gap in index, expected %u",
+					       index);
 				index = rec->lrh_index;
 			}
 
@@ -470,7 +488,7 @@ static int llog_process_thread(void *arg)
 				if (rc)
 					goto out;
 			}
-
+next_rec:
 			/* exit if the last index is reached */
 			if (index >= last_index) {
 				rc = 0;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
