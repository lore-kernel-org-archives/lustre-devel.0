Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 39299C77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:32:21 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWNJ2bK2z22PK;
	Sun,  9 Apr 2023 05:18:24 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWLG03Mfz21Gs
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:16:37 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 27FED1008484;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 265462B3; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:02 -0400
Message-Id: <1681042400-15491-23-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 22/40] lustre: llog: fix processing of a
 wrapped catalog
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
Cc: Etienne AUJAMES <etienne.aujames@cea.fr>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Etienne AUJAMES <etienne.aujames@cea.fr>

Several issues were found with "lfs changelog --follow" for a wrapped
catalog (llog_cat_process() with startidx):

1/ incorrect lpcd_first_idx value for a wrapped catalog (startcat>0)

The first llog index to process is "lpcd_first_idx + 1". The startidx
represents the last record index processed for a llog plain. The
catalog index of this llog is startcat.
lpcd_first_idx of a catalog should be set to "startcat - 1"
e.g:
llog_cat_process(... startcat=10, startidx=101) means that the
processing will start with the llog plain at the index 10 of the
catalog. And the first record to process will be at index 102.

2/ startidx is not reset for an incorrect startcat index

startidx is relevant only for a startcat. So if the corresponding llog
plain is removed or if startcat is out of range, we need to reset
startidx.

This patch remove LLOG_CAT_FIRST, that was really confusing
(LU-14158). And update osp_sync_thread() with the
llog_cat_process() corrected behavior.

It modifies also llog_cat_retain_cb() to zap empty plain llog directly
in it (like for llog_cat_size_cb()), the current implementation is not
compatible with this patch.

Fixes: 58239d59 ("lustre: llog: fix processing of a wrapped catalog")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15280
Lustre-commit: 76cf7427145a397a3 ("LU-15280 llog: fix processing of a wrapped catalog")
Signed-off-by: Etienne AUJAMES <eaujames@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/45708
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Mikhail Pershin <mpershin@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_log.h         |  16 +++++
 fs/lustre/include/obd_support.h        |   1 +
 fs/lustre/obdclass/llog.c              |  21 +++---
 fs/lustre/obdclass/llog_cat.c          | 128 ++++++++++++++++++++++-----------
 include/uapi/linux/lustre/lustre_idl.h |   5 --
 5 files changed, 115 insertions(+), 56 deletions(-)

diff --git a/fs/lustre/include/lustre_log.h b/fs/lustre/include/lustre_log.h
index dbf3fd6..1586595 100644
--- a/fs/lustre/include/lustre_log.h
+++ b/fs/lustre/include/lustre_log.h
@@ -375,6 +375,15 @@ static inline int llog_next_block(const struct lu_env *env,
 	return rc;
 }
 
+static inline int llog_max_idx(struct llog_log_hdr *lh)
+{
+	if (OBD_FAIL_PRECHECK(OBD_FAIL_CAT_RECORDS) &&
+	    unlikely(lh->llh_flags & LLOG_F_IS_CAT))
+		return cfs_fail_val;
+	else
+		return LLOG_HDR_BITMAP_SIZE(lh) - 1;
+}
+
 /* Determine if a llog plain of a catalog could be skiped based on record
  * custom indexes.
  * This assumes that indexes follow each other. The number of records to skip
@@ -391,6 +400,13 @@ static inline int llog_is_plain_skipable(struct llog_log_hdr *lh,
 	return (LLOG_HDR_BITMAP_SIZE(lh) - rec->lrh_index) < (start - curr);
 }
 
+static inline bool llog_cat_is_wrapped(struct llog_handle *cat)
+{
+	struct llog_log_hdr *llh = cat->lgh_hdr;
+
+	return llh->llh_cat_idx >= cat->lgh_last_idx && llh->llh_count > 1;
+}
+
 /* llog.c */
 int lustre_process_log(struct super_block *sb, char *logname,
 		       struct config_llog_instance *cfg);
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 4ef5c61..55196ce 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -458,6 +458,7 @@
 /* was	OBD_FAIL_LLOG_CATINFO_NET			0x1309 until 2.3 */
 #define OBD_FAIL_MDS_SYNC_CAPA_SL			0x1310
 #define OBD_FAIL_SEQ_ALLOC				0x1311
+#define OBD_FAIL_CAT_RECORDS				0x1312
 #define OBD_FAIL_PLAIN_RECORDS				0x1319
 #define OBD_FAIL_CATALOG_FULL_CHECK			0x131a
 
diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index 90bb8bd..09fda39 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -247,7 +247,7 @@ int llog_verify_record(const struct llog_handle *llh, struct llog_rec_hdr *rec)
 	else if (rec->lrh_len == 0 || rec->lrh_len > chunk_size)
 		LLOG_ERROR_REC(llh, rec, "bad record len, chunk size is %d",
 			       chunk_size);
-	else if (rec->lrh_index >= LLOG_HDR_BITMAP_SIZE(llh->lgh_hdr))
+	else if (rec->lrh_index > llog_max_idx(llh->lgh_hdr))
 		LLOG_ERROR_REC(llh, rec, "index is too high");
 	else
 		return 0;
@@ -292,16 +292,21 @@ static int llog_process_thread(void *arg)
 		return 0;
 	}
 
+	last_index = llog_max_idx(llh);
 	if (cd) {
-		last_called_index = cd->lpcd_first_idx;
+		if (cd->lpcd_first_idx >= llog_max_idx(llh)) {
+			/* End of the indexes -> Nothing to do */
+			rc = 0;
+			goto out;
+		}
 		index = cd->lpcd_first_idx + 1;
+		last_called_index = cd->lpcd_first_idx;
+		if (cd->lpcd_last_idx > 0 &&
+		    cd->lpcd_last_idx <= llog_max_idx(llh))
+			last_index = cd->lpcd_last_idx;
+		else if (cd->lpcd_read_mode & LLOG_READ_MODE_RAW)
+			last_index = loghandle->lgh_last_idx;
 	}
-	if (cd && cd->lpcd_last_idx)
-		last_index = cd->lpcd_last_idx;
-	else if (cd && (cd->lpcd_read_mode & LLOG_READ_MODE_RAW))
-		last_index = loghandle->lgh_last_idx;
-	else
-		last_index = LLOG_HDR_BITMAP_SIZE(llh) - 1;
 
 	while (rc == 0) {
 		unsigned int buf_offset = 0;
diff --git a/fs/lustre/obdclass/llog_cat.c b/fs/lustre/obdclass/llog_cat.c
index 95bfa65..9d624a7 100644
--- a/fs/lustre/obdclass/llog_cat.c
+++ b/fs/lustre/obdclass/llog_cat.c
@@ -174,19 +174,25 @@ static int llog_cat_process_cb(const struct lu_env *env,
 	struct llog_handle *llh = NULL;
 	int rc;
 
+	/* Skip processing of the logs until startcat */
+	if (rec->lrh_index < d->lpd_startcat)
+		return 0;
+
 	rc = llog_cat_process_common(env, cat_llh, rec, &llh);
 	if (rc)
 		goto out;
 
-	if (rec->lrh_index < d->lpd_startcat)
-		/* Skip processing of the logs until startcat */
-		rc = 0;
-	else if (d->lpd_startidx > 0) {
-		struct llog_process_cat_data cd;
-
-		cd.lpcd_read_mode = LLOG_READ_MODE_NORMAL;
-		cd.lpcd_first_idx = d->lpd_startidx;
-		cd.lpcd_last_idx = 0;
+	if (d->lpd_startidx > 0) {
+		struct llog_process_cat_data cd = {
+			.lpcd_first_idx = 0,
+			.lpcd_last_idx = 0,
+			.lpcd_read_mode = LLOG_READ_MODE_NORMAL,
+		};
+
+		/* startidx is always associated with a catalog index */
+		if (d->lpd_startcat == rec->lrh_index)
+			cd.lpcd_first_idx = d->lpd_startidx;
+
 		rc = llog_process_or_fork(env, llh, d->lpd_cb, d->lpd_data,
 					  &cd, false);
 		/* Continue processing the next log from idx 0 */
@@ -208,57 +214,93 @@ static int llog_cat_process_or_fork(const struct lu_env *env,
 				    void *data, int startcat,
 				    int startidx, bool fork)
 {
-	struct llog_process_data d;
 	struct llog_log_hdr *llh = cat_llh->lgh_hdr;
+	struct llog_process_data d;
+	struct llog_process_cat_data cd;
 	int rc;
 
 	LASSERT(llh->llh_flags & LLOG_F_IS_CAT);
 	d.lpd_data = data;
 	d.lpd_cb = cb;
-	d.lpd_startcat = (startcat == LLOG_CAT_FIRST ? 0 : startcat);
-	d.lpd_startidx = startidx;
 
-	if (llh->llh_cat_idx > cat_llh->lgh_last_idx) {
-		struct llog_process_cat_data cd = {
-			.lpcd_read_mode = LLOG_READ_MODE_NORMAL
-		};
+	/* default: start from the oldest record */
+	d.lpd_startidx = 0;
+	d.lpd_startcat = llh->llh_cat_idx + 1;
+	cd.lpcd_first_idx = llh->llh_cat_idx;
+	cd.lpcd_last_idx = 0;
+	cd.lpcd_read_mode = LLOG_READ_MODE_NORMAL;
+
+	if (startcat > 0 && startcat <= llog_max_idx(llh)) {
+		/* start from a custom catalog/llog plain indexes*/
+		d.lpd_startidx = startidx;
+		d.lpd_startcat = startcat;
+		cd.lpcd_first_idx = startcat - 1;
+	} else if (startcat != 0) {
+		CWARN("%s: startcat %d out of range for catlog "DFID"\n",
+		      loghandle2name(cat_llh), startcat,
+		      PLOGID(&cat_llh->lgh_id));
+		return -EINVAL;
+	}
+
+	startcat = d.lpd_startcat;
+
+	/* if startcat <= lgh_last_idx, we only need to process the first part
+	 * of the catalog (from startcat).
+	 */
+	if (llog_cat_is_wrapped(cat_llh) && startcat > cat_llh->lgh_last_idx) {
+		int cat_idx_origin = llh->llh_cat_idx;
 
 		CWARN("%s: catlog " DFID " crosses index zero\n",
 		      loghandle2name(cat_llh),
 		      PLOGID(&cat_llh->lgh_id));
-		/*startcat = 0 is default value for general processing */
-		if ((startcat != LLOG_CAT_FIRST &&
-		    startcat >= llh->llh_cat_idx) || !startcat) {
-			/* processing the catalog part at the end */
-			cd.lpcd_first_idx = (startcat ? startcat :
-					     llh->llh_cat_idx);
-			cd.lpcd_last_idx = 0;
-			rc = llog_process_or_fork(env, cat_llh, cat_cb,
-						  &d, &cd, fork);
-			/* Reset the startcat because it has already reached
-			 * catalog bottom.
-			 */
-			startcat = 0;
-			d.lpd_startcat = 0;
-			if (rc != 0)
-				return rc;
-		}
-		/* processing the catalog part at the beginning */
-		cd.lpcd_first_idx = (startcat == LLOG_CAT_FIRST) ? 0 : startcat;
-		/* Note, the processing will stop at the lgh_last_idx value,
-		 * and it could be increased during processing. So records
-		 * between current lgh_last_idx and lgh_last_idx in future
-		 * would left unprocessed.
-		 */
-		cd.lpcd_last_idx = cat_llh->lgh_last_idx;
+
+		/* processing the catalog part at the end */
 		rc = llog_process_or_fork(env, cat_llh, cat_cb, &d, &cd, fork);
-	} else {
-		rc = llog_process_or_fork(env, cat_llh, cat_cb, &d, NULL, fork);
+		if (rc)
+			return rc;
+
+		/* Reset the startcat because it has already reached catalog
+		 * bottom.
+		 * lgh_last_idx value could be increased during processing. So
+		 * we process the remaining of catalog entries to be sure.
+		 */
+		d.lpd_startcat = 1;
+		d.lpd_startidx = 0;
+		cd.lpcd_first_idx = 0;
+		cd.lpcd_last_idx = max(cat_idx_origin, cat_llh->lgh_last_idx);
+	} else if (llog_cat_is_wrapped(cat_llh)) {
+		/* only process 1st part -> stop before reaching 2sd part */
+		cd.lpcd_last_idx = llh->llh_cat_idx;
 	}
 
+	/* processing the catalog part at the beginning */
+	rc = llog_process_or_fork(env, cat_llh, cat_cb, &d, &cd, fork);
+
 	return rc;
 }
 
+/**
+ * Process catalog records with a callback
+ *
+ * @note
+ * If "starcat = 0", this is the default processing. "startidx" argument is
+ * ignored and processing begin from the oldest record.
+ * If "startcat > 0", this is a custom starting point. Processing begin with
+ * the llog plain defined in the catalog record at index "startcat". The first
+ * llog plain record to process is at index "startidx + 1".
+ *
+ * @env		Lustre environnement
+ * @cat_llh	Catalog llog handler
+ * @cb		Callback executed for each records (in llog plain files)
+ * @data	Callback data argument
+ * @startcat	Catalog index of the llog plain to start with.
+ * @startidx	Index of the llog plain to start processing. The first
+ *		record to process is at startidx + 1.
+ *
+ * RETURN	0 processing successfully completed
+ *		LLOG_PROC_BREAK processing was stopped by the callback.
+ *		-errno on error.
+ */
 int llog_cat_process(const struct lu_env *env, struct llog_handle *cat_llh,
 		     llog_cb_t cb, void *data, int startcat, int startidx)
 {
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index a752639..d60d1d8 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2619,11 +2619,6 @@ enum llog_flag {
 			  LLOG_F_EXT_X_OMODE | LLOG_F_EXT_X_XATTR,
 };
 
-/* means first record of catalog */
-enum {
-	LLOG_CAT_FIRST = -1,
-};
-
 /* On-disk header structure of each log object, stored in little endian order */
 #define LLOG_MIN_CHUNK_SIZE	8192
 #define LLOG_HEADER_SIZE	(96)	/* sizeof (llog_log_hdr) +
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
