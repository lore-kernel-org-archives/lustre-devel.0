From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:09 -0400
Subject: [lustre-devel] [PATCH 32/45] lustre: llog: allow delete of zero
 size llog
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-33-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Boyko <c17825@cray.com>

1) all plain logs belonging to catalog should have flag
LLOG_F_ZAP_WHEN_EMPTY base on llog_cat_new_log(). When
llog_cat_process_common processing plain log with zero file size,
this flag is not set during llog_cat_id2handle LLOG_EMPTY, so these
plain llogs are not canceled/destroyed. They appeared during cross
MDT updates. Fix adds flag LLOG_F_ZAP_WHEN_EMPTY for any plain llog
at catalog.

Cray-bug-id: LUS-8634
WC-bug-id: https://jira.whamcloud.com/browse/LU-13411
Lustre-commit: bc7f8cfe0fc6a ("LU-13411 llog: allow delete of zero size llog")
Signed-off-by: Alexander Boyko <c17825@cray.com>
Reviewed-on: https://review.whamcloud.com/38131
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/llog.c     | 9 +++++----
 fs/lustre/obdclass/llog_cat.c | 3 ++-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index 28a79bb..b2667d9 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -472,6 +472,7 @@ int llog_process_or_fork(const struct lu_env *env,
 	struct llog_process_info *lpi;
 	struct llog_process_data *d = data;
 	struct llog_process_cat_data *cd = catdata;
+	u32 flags = loghandle->lgh_hdr->llh_flags;
 	int rc;
 
 	lpi = kzalloc(sizeof(*lpi), GFP_KERNEL);
@@ -484,10 +485,10 @@ int llog_process_or_fork(const struct lu_env *env,
 
 	CDEBUG(D_OTHER,
 	       "Processing " DFID " flags 0x%03x startcat %d startidx %d first_idx %d last_idx %d\n",
-	       PFID(&loghandle->lgh_id.lgl_oi.oi_fid),
-	       loghandle->lgh_hdr->llh_flags, d ? d->lpd_startcat : -1,
-	       d ? d->lpd_startidx : -1, cd ? cd->lpcd_first_idx : -1,
-	       cd ? cd->lpcd_last_idx : -1);
+	       PFID(&loghandle->lgh_id.lgl_oi.oi_fid), flags,
+	       (flags & LLOG_F_IS_CAT) && d ? d->lpd_startcat : -1,
+	       (flags & LLOG_F_IS_CAT) && d ? d->lpd_startidx : -1,
+	       cd ? cd->lpcd_first_idx : -1, cd ? cd->lpcd_last_idx : -1);
 
 	if (fork) {
 		struct task_struct *task;
diff --git a/fs/lustre/obdclass/llog_cat.c b/fs/lustre/obdclass/llog_cat.c
index 46636f8..9298808 100644
--- a/fs/lustre/obdclass/llog_cat.c
+++ b/fs/lustre/obdclass/llog_cat.c
@@ -108,7 +108,8 @@ static int llog_cat_id2handle(const struct lu_env *env,
 		return rc;
 	}
 
-	rc = llog_init_handle(env, loghandle, fmt | LLOG_F_IS_PLAIN, NULL);
+	rc = llog_init_handle(env, loghandle, LLOG_F_IS_PLAIN |
+			      LLOG_F_ZAP_WHEN_EMPTY | fmt, NULL);
 	if (rc < 0) {
 		llog_close(env, loghandle);
 		*res = NULL;
-- 
1.8.3.1
