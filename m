Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 953FDC433ED
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:41 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 536F76138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 536F76138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9146332899A;
	Mon,  5 Apr 2021 00:52:13 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2D0F121F949
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:24 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id DB48E9FE;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id DA11190AA8; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:51 -0400
Message-Id: <1617583870-32029-23-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 22/41] lustre: obdclass: try to skip
 corrupted llog records
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alex Zhuravlev <bzzz@whamcloud.com>

if llog's header or record is found corrupted, then
ignore the remaining records and try with the next one.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14098
Lustre-commit: 910eb97c1b43a44 ("LU-14098 obdclass: try to skip corrupted llog records")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40754
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/llog.c          | 76 ++++++++++++++++++++++++++++++--------
 fs/lustre/obdclass/llog_cat.c      | 14 +++----
 fs/lustre/obdclass/llog_internal.h |  5 +++
 3 files changed, 72 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index e172ebc..7668d51 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -184,7 +184,7 @@ int llog_init_handle(const struct lu_env *env, struct llog_handle *handle,
 			     (llh->llh_flags & LLOG_F_IS_CAT &&
 			      flags & LLOG_F_IS_PLAIN))) {
 			CERROR("%s: llog type is %s but initializing %s\n",
-			       handle->lgh_ctxt->loc_obd->obd_name,
+			       loghandle2name(handle),
 			       llh->llh_flags & LLOG_F_IS_CAT ?
 			       "catalog" : "plain",
 			       flags & LLOG_F_IS_CAT ? "catalog" : "plain");
@@ -206,7 +206,7 @@ int llog_init_handle(const struct lu_env *env, struct llog_handle *handle,
 		if (unlikely(uuid &&
 			     !obd_uuid_equals(uuid, &llh->llh_tgtuuid))) {
 			CERROR("%s: llog uuid mismatch: %s/%s\n",
-			       handle->lgh_ctxt->loc_obd->obd_name,
+			       loghandle2name(handle),
 			       (char *)uuid->uuid,
 			       (char *)llh->llh_tgtuuid.uuid);
 			rc = -EEXIST;
@@ -220,8 +220,8 @@ int llog_init_handle(const struct lu_env *env, struct llog_handle *handle,
 		llh->llh_flags |= LLOG_F_IS_FIXSIZE;
 	} else if (!(flags & LLOG_F_IS_PLAIN)) {
 		CERROR("%s: unknown flags: %#x (expected %#x or %#x)\n",
-		       handle->lgh_ctxt->loc_obd->obd_name,
-		       flags, LLOG_F_IS_CAT, LLOG_F_IS_PLAIN);
+		       loghandle2name(handle), flags, LLOG_F_IS_CAT,
+		       LLOG_F_IS_PLAIN);
 		rc = -EINVAL;
 	}
 	llh->llh_flags |= fmt;
@@ -234,6 +234,29 @@ int llog_init_handle(const struct lu_env *env, struct llog_handle *handle,
 }
 EXPORT_SYMBOL(llog_init_handle);
 
+int llog_verify_record(const struct llog_handle *llh, struct llog_rec_hdr *rec)
+{
+	int chunk_size = llh->lgh_hdr->llh_hdr.lrh_len;
+
+	if (rec->lrh_len == 0 || rec->lrh_len > chunk_size) {
+		CERROR("%s: record is too large: %d > %d\n",
+		       loghandle2name(llh), rec->lrh_len, chunk_size);
+		return -EINVAL;
+	}
+	if (rec->lrh_index >= LLOG_HDR_BITMAP_SIZE(llh->lgh_hdr)) {
+		CERROR("%s: index is too high: %d\n",
+		       loghandle2name(llh), rec->lrh_index);
+		return -EINVAL;
+	}
+	if ((rec->lrh_type & LLOG_OP_MASK) != LLOG_OP_MAGIC) {
+		CERROR("%s: magic %x is bad\n",
+		       loghandle2name(llh), rec->lrh_type);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static int llog_process_thread(void *arg)
 {
 	struct llog_process_info *lpi = arg;
@@ -247,6 +270,7 @@ static int llog_process_thread(void *arg)
 	int saved_index = 0;
 	int last_called_index = 0;
 	bool repeated = false;
+	bool refresh_idx = false;
 
 	if (!llh)
 		return -EINVAL;
@@ -380,12 +404,21 @@ static int llog_process_thread(void *arg)
 
 			repeated = false;
 
-			if (!rec->lrh_len || rec->lrh_len > chunk_size) {
-				CWARN("invalid length %d in llog record for index %d/%d\n",
-				      rec->lrh_len,
-				      rec->lrh_index, index);
-				rc = -EINVAL;
-				goto out;
+			rc = llog_verify_record(loghandle, rec);
+			if (rc) {
+				CERROR("%s: invalid record in llog "DFID" record for index %d/%d: rc = %d\n",
+				       loghandle2name(loghandle),
+                                       PFID(&loghandle->lgh_id.lgl_oi.oi_fid),
+				       rec->lrh_len, index, rc);
+				/*
+				 * the block seem to be corrupted, let's try
+				 * with the next one. reset rc to go to the
+				 * next chunk.
+				 */
+				refresh_idx = true;
+				index = 0;
+				rc = 0;
+				goto repeat;
 			}
 
 			if (rec->lrh_index < index) {
@@ -395,11 +428,22 @@ static int llog_process_thread(void *arg)
 			}
 
 			if (rec->lrh_index != index) {
-				CERROR("%s: Invalid record: index %u but expected %u\n",
-				       loghandle->lgh_ctxt->loc_obd->obd_name,
-				       rec->lrh_index, index);
-				rc = -ERANGE;
-				goto out;
+				/*
+				 * the last time we couldn't parse the block due
+				 * to corruption, thus has no idea about the
+				 * next index, take it from the block, once.
+				 */
+				if (refresh_idx) {
+					refresh_idx = false;
+					index = rec->lrh_index;
+				} else {
+					CERROR("%s: "DFID" Invalid record: index %u but expected %u\n",
+					       loghandle2name(loghandle),
+					       PFID(&loghandle->lgh_id.lgl_oi.oi_fid),
+					       rec->lrh_index, index);
+					rc = -ERANGE;
+					goto out;
+				}
 			}
 
 			CDEBUG(D_OTHER,
@@ -501,7 +545,7 @@ int llog_process_or_fork(const struct lu_env *env,
 		if (IS_ERR(task)) {
 			rc = PTR_ERR(task);
 			CERROR("%s: cannot start thread: rc = %d\n",
-			       loghandle->lgh_ctxt->loc_obd->obd_name, rc);
+			       loghandle2name(loghandle), rc);
 			goto out_lpi;
 		}
 		wait_for_completion(&lpi->lpi_completion);
diff --git a/fs/lustre/obdclass/llog_cat.c b/fs/lustre/obdclass/llog_cat.c
index 9298808..b67e7a2b 100644
--- a/fs/lustre/obdclass/llog_cat.c
+++ b/fs/lustre/obdclass/llog_cat.c
@@ -80,7 +80,7 @@ static int llog_cat_id2handle(const struct lu_env *env,
 		    ostid_seq(&cgl->lgl_oi) == ostid_seq(&logid->lgl_oi)) {
 			if (cgl->lgl_ogen != logid->lgl_ogen) {
 				CWARN("%s: log " DFID " generation %x != %x\n",
-				      loghandle->lgh_ctxt->loc_obd->obd_name,
+				      loghandle2name(loghandle),
 				      PFID(&logid->lgl_oi.oi_fid),
 				      cgl->lgl_ogen, logid->lgl_ogen);
 				continue;
@@ -88,7 +88,7 @@ static int llog_cat_id2handle(const struct lu_env *env,
 			*res = llog_handle_get(loghandle);
 			if (!*res) {
 				CERROR("%s: log "DFID" refcount is zero!\n",
-				       loghandle->lgh_ctxt->loc_obd->obd_name,
+				       loghandle2name(loghandle),
 				       PFID(&logid->lgl_oi.oi_fid));
 				continue;
 			}
@@ -103,8 +103,8 @@ static int llog_cat_id2handle(const struct lu_env *env,
 		       LLOG_OPEN_EXISTS);
 	if (rc < 0) {
 		CERROR("%s: error opening log id " DFID ":%x: rc = %d\n",
-		       cathandle->lgh_ctxt->loc_obd->obd_name,
-		       PFID(&logid->lgl_oi.oi_fid), logid->lgl_ogen, rc);
+		       loghandle2name(cathandle), PFID(&logid->lgl_oi.oi_fid),
+		       logid->lgl_ogen, rc);
 		return rc;
 	}
 
@@ -155,7 +155,7 @@ static int llog_cat_process_common(const struct lu_env *env,
 	if (rec->lrh_type != le32_to_cpu(LLOG_LOGID_MAGIC)) {
 		rc = -EINVAL;
 		CWARN("%s: invalid record in catalog " DFID ":%x: rc = %d\n",
-		      cat_llh->lgh_ctxt->loc_obd->obd_name,
+		      loghandle2name(cat_llh),
 		      PFID(&cat_llh->lgh_id.lgl_oi.oi_fid),
 		      cat_llh->lgh_id.lgl_ogen, rc);
 
@@ -170,7 +170,7 @@ static int llog_cat_process_common(const struct lu_env *env,
 	rc = llog_cat_id2handle(env, cat_llh, llhp, &lir->lid_id);
 	if (rc) {
 		CWARN("%s: can't find llog handle " DFID ":%x: rc = %d\n",
-		      cat_llh->lgh_ctxt->loc_obd->obd_name,
+		      loghandle2name(cat_llh),
 		      PFID(&lir->lid_id.lgl_oi.oi_fid),
 		      lir->lid_id.lgl_ogen, rc);
 
@@ -235,7 +235,7 @@ static int llog_cat_process_or_fork(const struct lu_env *env,
 		struct llog_process_cat_data cd;
 
 		CWARN("%s: catlog " DFID " crosses index zero\n",
-		      cat_llh->lgh_ctxt->loc_obd->obd_name,
+		      loghandle2name(cat_llh),
 		      PFID(&cat_llh->lgh_id.lgl_oi.oi_fid));
 		/*startcat = 0 is default value for general processing */
 		if ((startcat != LLOG_CAT_FIRST &&
diff --git a/fs/lustre/obdclass/llog_internal.h b/fs/lustre/obdclass/llog_internal.h
index c34adfe..41ac4f0 100644
--- a/fs/lustre/obdclass/llog_internal.h
+++ b/fs/lustre/obdclass/llog_internal.h
@@ -74,4 +74,9 @@ static inline struct llog_rec_hdr *llog_rec_hdr_next(struct llog_rec_hdr *rec)
 {
 	return (struct llog_rec_hdr *)((char *)rec + rec->lrh_len);
 }
+
+static inline char *loghandle2name(const struct llog_handle *lgh)
+{
+	return lgh->lgh_ctxt->loc_obd->obd_name;
+}
 #endif
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
