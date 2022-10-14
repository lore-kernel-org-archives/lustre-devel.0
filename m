Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 105FBC43217
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:48 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0Bb5FMWz1yDV;
	Fri, 14 Oct 2022 14:38:47 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0B927kZz21HL
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:25 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1CE4810084E2;
 Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 19859DD53E; Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:38:05 -0400
Message-Id: <1665783491-13827-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/20] lustre: llog: correct llog FID and
 path output
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

- fix wrong LLOG_ID-to-FID convestion to output llog FID by
  introducing PLOGID macro to expand llog ID for DFID format
- stop printing lgl_ogen along with llog FID as it always zero
  since 2.3.51 and is not used anymore

Fixes: e813619f0a3b ("lustre: llog: update llog print format to use FIDs")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15646
Lustre-commit: e28f3ee185b2ef7ba ("LU-15646 llog: correct llog FID and path output")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48430
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/llog.c               | 11 ++++----
 fs/lustre/obdclass/llog_cat.c           | 37 ++++++++-----------------
 fs/lustre/obdclass/llog_swab.c          |  2 +-
 include/uapi/linux/lustre/lustre_user.h |  1 +
 4 files changed, 19 insertions(+), 32 deletions(-)

diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index 38904b6b5da5..eb8f7e5a8c48 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -422,7 +422,7 @@ static int llog_process_thread(void *arg)
 			if (rc) {
 				CERROR("%s: invalid record in llog "DFID" record for index %d/%d: rc = %d\n",
 				       loghandle2name(loghandle),
-                                       PFID(&loghandle->lgh_id.lgl_oi.oi_fid),
+				       PLOGID(&loghandle->lgh_id),
 				       rec->lrh_len, index, rc);
 				/*
 				 * the block seem to be corrupted, let's try
@@ -448,7 +448,7 @@ static int llog_process_thread(void *arg)
 				 */
 				CERROR("%s: "DFID" index %u, expected %u\n",
 				       loghandle2name(loghandle),
-				       PFID(&loghandle->lgh_id.lgl_oi.oi_fid),
+				       PLOGID(&loghandle->lgh_id),
 				       rec->lrh_index, index);
 				index = rec->lrh_index;
 			}
@@ -481,10 +481,9 @@ static int llog_process_thread(void *arg)
 	}
 
 out:
-	CDEBUG(D_HA, "stop processing %s " DOSTID ":%x index %d count %d\n",
+	CDEBUG(D_HA, "stop processing %s "DFID" index %d count %d\n",
 	       ((llh->llh_flags & LLOG_F_IS_CAT) ? "catalog" : "plain"),
-	       POSTID(&loghandle->lgh_id.lgl_oi), loghandle->lgh_id.lgl_ogen,
-	       index, llh->llh_count);
+	       PLOGID(&loghandle->lgh_id), index, llh->llh_count);
 
 	if (cd)
 		cd->lpcd_last_idx = last_called_index;
@@ -534,7 +533,7 @@ int llog_process_or_fork(const struct lu_env *env,
 
 	CDEBUG(D_OTHER,
 	       "Processing " DFID " flags 0x%03x startcat %d startidx %d first_idx %d last_idx %d read_mode %d\n",
-	       PFID(&loghandle->lgh_id.lgl_oi.oi_fid), flags,
+	       PLOGID(&loghandle->lgh_id), flags,
 	       (flags & LLOG_F_IS_CAT) && d ? d->lpd_startcat : -1,
 	       (flags & LLOG_F_IS_CAT) && d ? d->lpd_startidx : -1,
 	       cd ? cd->lpcd_first_idx : -1, cd ? cd->lpcd_last_idx : -1,
diff --git a/fs/lustre/obdclass/llog_cat.c b/fs/lustre/obdclass/llog_cat.c
index 753422be3185..95bfa65d25b1 100644
--- a/fs/lustre/obdclass/llog_cat.c
+++ b/fs/lustre/obdclass/llog_cat.c
@@ -77,18 +77,11 @@ static int llog_cat_id2handle(const struct lu_env *env,
 
 		if (ostid_id(&cgl->lgl_oi) == ostid_id(&logid->lgl_oi) &&
 		    ostid_seq(&cgl->lgl_oi) == ostid_seq(&logid->lgl_oi)) {
-			if (cgl->lgl_ogen != logid->lgl_ogen) {
-				CWARN("%s: log " DFID " generation %x != %x\n",
-				      loghandle2name(loghandle),
-				      PFID(&logid->lgl_oi.oi_fid),
-				      cgl->lgl_ogen, logid->lgl_ogen);
-				continue;
-			}
 			*res = llog_handle_get(loghandle);
 			if (!*res) {
 				CERROR("%s: log "DFID" refcount is zero!\n",
 				       loghandle2name(loghandle),
-				       PFID(&logid->lgl_oi.oi_fid));
+				       PLOGID(logid));
 				continue;
 			}
 			loghandle->u.phd.phd_cat_handle = cathandle;
@@ -101,9 +94,8 @@ static int llog_cat_id2handle(const struct lu_env *env,
 	rc = llog_open(env, cathandle->lgh_ctxt, &loghandle, logid, NULL,
 		       LLOG_OPEN_EXISTS);
 	if (rc < 0) {
-		CERROR("%s: error opening log id " DFID ":%x: rc = %d\n",
-		       loghandle2name(cathandle), PFID(&logid->lgl_oi.oi_fid),
-		       logid->lgl_ogen, rc);
+		CERROR("%s: error opening log id "DFID": rc = %d\n",
+		       loghandle2name(cathandle), PLOGID(logid), rc);
 		return rc;
 	}
 
@@ -153,25 +145,20 @@ static int llog_cat_process_common(const struct lu_env *env,
 
 	if (rec->lrh_type != le32_to_cpu(LLOG_LOGID_MAGIC)) {
 		rc = -EINVAL;
-		CWARN("%s: invalid record in catalog " DFID ":%x: rc = %d\n",
-		      loghandle2name(cat_llh),
-		      PFID(&cat_llh->lgh_id.lgl_oi.oi_fid),
-		      cat_llh->lgh_id.lgl_ogen, rc);
-
+		CWARN("%s: invalid record in catalog "DFID": rc = %d\n",
+		      loghandle2name(cat_llh), PLOGID(&cat_llh->lgh_id), rc);
 		return rc;
 	}
 	CDEBUG(D_HA,
-	       "processing log " DFID ":%x at index %u of catalog " DFID "\n",
-	       PFID(&lir->lid_id.lgl_oi.oi_fid), lir->lid_id.lgl_ogen,
-	       le32_to_cpu(rec->lrh_index),
-	       PFID(&cat_llh->lgh_id.lgl_oi.oi_fid));
+	       "processing log "DFID" at index %u of catalog "DFID"\n",
+	       PLOGID(&lir->lid_id), le32_to_cpu(rec->lrh_index),
+	       PLOGID(&cat_llh->lgh_id));
 
 	rc = llog_cat_id2handle(env, cat_llh, llhp, &lir->lid_id);
 	if (rc) {
-		CWARN("%s: can't find llog handle " DFID ":%x: rc = %d\n",
-		      loghandle2name(cat_llh),
-		      PFID(&lir->lid_id.lgl_oi.oi_fid),
-		      lir->lid_id.lgl_ogen, rc);
+		CWARN("%s: can't find llog handle "DFID": rc = %d\n",
+		      loghandle2name(cat_llh), PLOGID(&lir->lid_id),
+		      rc);
 
 		return rc;
 	}
@@ -238,7 +225,7 @@ static int llog_cat_process_or_fork(const struct lu_env *env,
 
 		CWARN("%s: catlog " DFID " crosses index zero\n",
 		      loghandle2name(cat_llh),
-		      PFID(&cat_llh->lgh_id.lgl_oi.oi_fid));
+		      PLOGID(&cat_llh->lgh_id));
 		/*startcat = 0 is default value for general processing */
 		if ((startcat != LLOG_CAT_FIRST &&
 		    startcat >= llh->llh_cat_idx) || !startcat) {
diff --git a/fs/lustre/obdclass/llog_swab.c b/fs/lustre/obdclass/llog_swab.c
index fcc2a48b50b0..5d2936429b9f 100644
--- a/fs/lustre/obdclass/llog_swab.c
+++ b/fs/lustre/obdclass/llog_swab.c
@@ -45,7 +45,7 @@ static void print_llogd_body(struct llogd_body *d)
 {
 	CDEBUG(D_OTHER, "llogd body: %p\n", d);
 	CDEBUG(D_OTHER, "\tlgd_logid.lgl_oi: " DFID "\n",
-	       PFID(&d->lgd_logid.lgl_oi.oi_fid));
+	       PLOGID(&d->lgd_logid));
 	CDEBUG(D_OTHER, "\tlgd_logid.lgl_ogen: %#x\n", d->lgd_logid.lgl_ogen);
 	CDEBUG(D_OTHER, "\tlgd_ctxt_idx: %#x\n", d->lgd_ctxt_idx);
 	CDEBUG(D_OTHER, "\tlgd_llh_flags: %#x\n", d->lgd_llh_flags);
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 6577202517af..db18cd5f1fa8 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -987,6 +987,7 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
  */
 #define SFID "0x%llx:0x%x:0x%x"
 #define RFID(fid) &((fid)->f_seq), &((fid)->f_oid), &((fid)->f_ver)
+#define PLOGID(logid) ((unsigned long long)(logid)->lgl_oi.oi.oi_seq, (__u32)(logid)->lgl_oi.oi.oi_id, 0)
 
 /********* Quotas **********/
 
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
