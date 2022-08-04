Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0CD8FC19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:39:19 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4LyrxL4xqfz23Jw;
	Wed,  3 Aug 2022 18:39:18 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwZ2bkPz23Jy
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:38 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D3553100B007;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D16DC8D620; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:02 -0400
Message-Id: <1659577097-19253-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/32] lustre: llog: Add LLOG_SKIP_PLAIN to
 skip llog plain
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

Add the catalog callback return LLOG_SKIP_PLAIN to conditionally skip
an entire llog plain.

This could speedup the catalog processing for specific usages when a
record need to be access in the "middle" of the catalog. This could
be useful for changelog with several users or HSM.

This patch modify chlg_read_cat_process_cb() to use LLOG_SKIP_PLAIN.
The main idea came from: d813c75d ("LU-14688 mdt: changelog purge
deletes plain llog")

**Performance test:**

* Environment:
2474195 changelogs record store on the mds0 (40 llog plain):
mds# lctl get_param -n mdd.lustrefs-MDT0000.changelog_users
current index: 2474195
ID    index (idle seconds)
cl1   0 (3509)

* Test
Access to records at the end of the catalog (offset: 2474194):
client# time lfs changelog lustrefs-MDT0000 2474194 >/dev/null

* Results
- with the patch:       real    0m0.592s
- without the patch:    real    0m17.835s (x30)

WC-bug-id: https://jira.whamcloud.com/browse/LU-15481
Lustre-commit: aa22a6826ee521ab1 ("LU-15481 llog: Add LLOG_SKIP_PLAIN to skip llog plain")
Signed-off-by: Etienne AUJAMES <etienne.aujames@cea.fr>
Reviewed-on: https://review.whamcloud.com/46310
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_log.h | 18 +++++++++++++++++-
 fs/lustre/mdc/mdc_changelog.c  |  5 +++++
 2 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/include/lustre_log.h b/fs/lustre/include/lustre_log.h
index 2e43d56..dbf3fd6 100644
--- a/fs/lustre/include/lustre_log.h
+++ b/fs/lustre/include/lustre_log.h
@@ -264,7 +264,7 @@ struct llog_ctxt {
 };
 
 #define LLOG_PROC_BREAK 0x0001
-#define LLOG_DEL_RECORD 0x0002
+#define LLOG_SKIP_PLAIN 0x0004
 
 static inline int llog_handle2ops(struct llog_handle *loghandle,
 				  const struct llog_operations **lop)
@@ -375,6 +375,22 @@ static inline int llog_next_block(const struct lu_env *env,
 	return rc;
 }
 
+/* Determine if a llog plain of a catalog could be skiped based on record
+ * custom indexes.
+ * This assumes that indexes follow each other. The number of records to skip
+ * can be computed base on a starting offset and the index of the current
+ * record (in llog catalog callback).
+ */
+static inline int llog_is_plain_skipable(struct llog_log_hdr *lh,
+					 struct llog_rec_hdr *rec,
+					 u64 curr, u64 start)
+{
+	if (start == 0 || curr >= start)
+		return 0;
+
+	return (LLOG_HDR_BITMAP_SIZE(lh) - rec->lrh_index) < (start - curr);
+}
+
 /* llog.c */
 int lustre_process_log(struct super_block *sb, char *logname,
 		       struct config_llog_instance *cfg);
diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index 36d7fdd..cd2a610 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -225,6 +225,11 @@ static int chlg_read_cat_process_cb(const struct lu_env *env,
 		return rc;
 	}
 
+	/* Check if we can skip the entire llog plain */
+	if (llog_is_plain_skipable(llh->lgh_hdr, hdr, rec->cr.cr_index,
+				   crs->crs_start_offset))
+		return LLOG_SKIP_PLAIN;
+
 	/* Skip undesired records */
 	if (rec->cr.cr_index < crs->crs_start_offset)
 		return 0;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
