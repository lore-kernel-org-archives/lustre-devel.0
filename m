From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:27 -0500
Subject: [lustre-devel] [PATCH 459/622] lustre: llog: remove
 olg_cat_processing field.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-460-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This mutex is initialized but never used.
Remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 2801ef81f1d0 ("LU-6142 llog: remove olg_cat_processing field.")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35878
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_log.h | 1 -
 fs/lustre/include/obd.h        | 1 -
 2 files changed, 2 deletions(-)

diff --git a/fs/lustre/include/lustre_log.h b/fs/lustre/include/lustre_log.h
index 99c6305..9c784ac 100644
--- a/fs/lustre/include/lustre_log.h
+++ b/fs/lustre/include/lustre_log.h
@@ -288,7 +288,6 @@ static inline void llog_group_init(struct obd_llog_group *olg)
 {
 	init_waitqueue_head(&olg->olg_waitq);
 	spin_lock_init(&olg->olg_lock);
-	mutex_init(&olg->olg_cat_processing);
 }
 
 static inline int llog_group_set_ctxt(struct obd_llog_group *olg,
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 70dbaaf..ef37f78 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -527,7 +527,6 @@ struct obd_llog_group {
 	struct llog_ctxt       *olg_ctxts[LLOG_MAX_CTXTS];
 	wait_queue_head_t	olg_waitq;
 	spinlock_t		olg_lock;
-	struct mutex		olg_cat_processing;
 };
 
 /* corresponds to one of the obd's */
-- 
1.8.3.1
