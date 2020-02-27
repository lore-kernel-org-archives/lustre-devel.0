From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:41 -0500
Subject: [lustre-devel] [PATCH 233/622] lustre: osc: propagate grant shrink
 interval immediately
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-234-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

currently the new interval (updated with lctl) will be used
only when the next shrink happens. with default interval it
will take at least 20 minutes. instead we should refresh it
immediately.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11408
Lustre-commit: 0b09a19bdf2d ("LU-11408 osc: propagate grant shrink interval immediately")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33204
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/lproc_osc.c    | 2 ++
 fs/lustre/osc/osc_internal.h | 1 +
 fs/lustre/osc/osc_request.c  | 6 ++++++
 3 files changed, 9 insertions(+)

diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index ea67d20..5faf518 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -349,6 +349,8 @@ static ssize_t grant_shrink_interval_store(struct kobject *kobj,
 		return -ERANGE;
 
 	obd->u.cli.cl_grant_shrink_interval = val;
+	osc_update_next_shrink(&obd->u.cli);
+	osc_schedule_grant_work();
 
 	return count;
 }
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index 2cb737b..0f0f4d4 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -43,6 +43,7 @@
 extern struct ptlrpc_request_pool *osc_rq_pool;
 
 int osc_shrink_grant_to_target(struct client_obd *cli, u64 target_bytes);
+void osc_schedule_grant_work(void);
 void osc_update_next_shrink(struct client_obd *cli);
 int lru_queue_work(const struct lu_env *env, void *data);
 int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 7190da9..7b120da 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -905,6 +905,12 @@ static void osc_grant_work_handler(struct work_struct *data)
 		schedule_work(&work.work);
 }
 
+void osc_schedule_grant_work(void)
+{
+	cancel_delayed_work_sync(&work);
+	schedule_work(&work.work);
+}
+
 /**
  * Start grant thread for returing grant to server for idle clients.
  */
-- 
1.8.3.1
