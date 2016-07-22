From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:32 -0400
Subject: [lustre-devel] [PATCH 39/58] staging: lustre: osc: allow to call
	brw_commit() multiple times
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-40-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Sometimes the rq_commit_cb of BRW RPC can be called twice if that RPC
has already committed at reply time. This will cause inaccuracy of
unstable pages accounting and then assertion.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3274
Reviewed-on: http://review.whamcloud.com/8215
Reviewed-by: Prakash Surya <surya1@llnl.gov>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c   |   19 ++++---------------
 drivers/staging/lustre/lustre/osc/osc_request.c |    8 ++++----
 2 files changed, 8 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index d1a7d6b..e5c1bc1 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1875,11 +1875,6 @@ void osc_dec_unstable_pages(struct ptlrpc_request *req)
 	atomic_sub(page_count, &obd_unstable_pages);
 	LASSERT(atomic_read(&obd_unstable_pages) >= 0);
 
-	spin_lock(&req->rq_lock);
-	req->rq_committed = 1;
-	req->rq_unstable  = 0;
-	spin_unlock(&req->rq_lock);
-
 	wake_up_all(&cli->cl_cache->ccc_unstable_waitq);
 }
 
@@ -1909,27 +1904,21 @@ void osc_inc_unstable_pages(struct ptlrpc_request *req)
 	LASSERT(atomic_read(&obd_unstable_pages) >= 0);
 	atomic_add(page_count, &obd_unstable_pages);
 
-	spin_lock(&req->rq_lock);
-
 	/*
 	 * If the request has already been committed (i.e. brw_commit
 	 * called via rq_commit_cb), we need to undo the unstable page
 	 * increments we just performed because rq_commit_cb wont be
-	 * called again. Otherwise, just set the commit callback so the
-	 * unstable page accounting is properly updated when the request
-	 * is committed
+	 * called again.
 	 */
-	if (req->rq_committed) {
+	spin_lock(&req->rq_lock);
+	if (unlikely(req->rq_committed)) {
 		/* Drop lock before calling osc_dec_unstable_pages */
 		spin_unlock(&req->rq_lock);
 		osc_dec_unstable_pages(req);
-		spin_lock(&req->rq_lock);
 	} else {
 		req->rq_unstable = 1;
-		req->rq_commit_cb = osc_dec_unstable_pages;
+		spin_unlock(&req->rq_lock);
 	}
-
-	spin_unlock(&req->rq_lock);
 }
 
 /* this must be called holding the loi list lock to give coverage to exit_cache,
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 536b868..a2d948f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1847,21 +1847,21 @@ static int brw_interpret(const struct lu_env *env,
 
 static void brw_commit(struct ptlrpc_request *req)
 {
-	spin_lock(&req->rq_lock);
 	/*
 	 * If osc_inc_unstable_pages (via osc_extent_finish) races with
 	 * this called via the rq_commit_cb, I need to ensure
 	 * osc_dec_unstable_pages is still called. Otherwise unstable
 	 * pages may be leaked.
 	 */
-	if (req->rq_unstable) {
+	spin_lock(&req->rq_lock);
+	if (unlikely(req->rq_unstable)) {
+		req->rq_unstable = 0;
 		spin_unlock(&req->rq_lock);
 		osc_dec_unstable_pages(req);
-		spin_lock(&req->rq_lock);
 	} else {
 		req->rq_committed = 1;
+		spin_unlock(&req->rq_lock);
 	}
-	spin_unlock(&req->rq_lock);
 }
 
 /**
-- 
1.7.1
