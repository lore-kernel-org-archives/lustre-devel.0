From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:22 -0400
Subject: [lustre-devel] [PATCH 023/124] staging: lustre: mdc: Report
	D_CHANGELOG messages as D_HSM
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>

From: Henri Doreau <henri.doreau@cea.fr>

Removed the D_CHANGELOG pseudo-debug flag that wasn't actually defined
as a usable one. Report the D_CHANGELOG messages as D_HSM ones instead
since this is the primary user of these messages.

Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5538
Reviewed-on: http://review.whamcloud.com/11558
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Nunez <james.a.nunez@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index cf94926..956b946 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1857,8 +1857,6 @@ static struct kuc_hdr *changelog_kuc_hdr(char *buf, int len, int flags)
 	return lh;
 }
 
-#define D_CHANGELOG 0
-
 struct changelog_show {
 	__u64		cs_startrec;
 	__u32		cs_flags;
@@ -1885,12 +1883,12 @@ static int changelog_kkuc_cb(const struct lu_env *env, struct llog_handle *llh,
 
 	if (rec->cr.cr_index < cs->cs_startrec) {
 		/* Skip entries earlier than what we are interested in */
-		CDEBUG(D_CHANGELOG, "rec=%llu start=%llu\n",
+		CDEBUG(D_HSM, "rec=%llu start=%llu\n",
 		       rec->cr.cr_index, cs->cs_startrec);
 		return 0;
 	}
 
-	CDEBUG(D_CHANGELOG, "%llu %02d%-5s %llu 0x%x t="DFID" p="DFID
+	CDEBUG(D_HSM, "%llu %02d%-5s %llu 0x%x t=" DFID " p=" DFID
 		" %.*s\n", rec->cr.cr_index, rec->cr.cr_type,
 		changelog_type2str(rec->cr.cr_type), rec->cr.cr_time,
 		rec->cr.cr_flags & CLF_FLAGMASK,
@@ -1904,7 +1902,7 @@ static int changelog_kkuc_cb(const struct lu_env *env, struct llog_handle *llh,
 	memcpy(lh + 1, &rec->cr, len - sizeof(*lh));
 
 	rc = libcfs_kkuc_msg_put(cs->cs_fp, lh);
-	CDEBUG(D_CHANGELOG, "kucmsg fp %p len %d rc %d\n", cs->cs_fp, len, rc);
+	CDEBUG(D_HSM, "kucmsg fp %p len %d rc %d\n", cs->cs_fp, len, rc);
 
 	return rc;
 }
@@ -1917,7 +1915,7 @@ static int mdc_changelog_send_thread(void *csdata)
 	struct kuc_hdr *kuch;
 	int rc;
 
-	CDEBUG(D_CHANGELOG, "changelog to fp=%p start %llu\n",
+	CDEBUG(D_HSM, "changelog to fp=%p start %llu\n",
 	       cs->cs_fp, cs->cs_startrec);
 
 	cs->cs_buf = kzalloc(KUC_CHANGELOG_MSG_MAXSIZE, GFP_NOFS);
@@ -1996,7 +1994,7 @@ static int mdc_ioc_changelog_send(struct obd_device *obd,
 		kfree(cs);
 	} else {
 		rc = 0;
-		CDEBUG(D_CHANGELOG, "%s: started changelog thread\n",
+		CDEBUG(D_HSM, "%s: started changelog thread\n",
 		       obd->obd_name);
 	}
 
-- 
1.7.1
