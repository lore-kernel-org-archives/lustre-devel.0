From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:50 -0500
Subject: [lustre-devel] [PATCH 602/622] lustre: obdclass: convert waiting in
 cl_sync_io_wait().
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-603-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This function will *always* wait until ->csi_sync_nr reaches zero.
The effect of the timeout is:
  1/ to report an error if the count doesn't reach zero in the given
     time
  2/ to return -ETIMEDOUt instead of csi_sync_rc if the timeout was
     exceeded.

So we rearrange the code to make that more obvious.
A small exrta change is that we now call wait_event_idle() again
even if there was a timeout and the first wait succeeded.
This will simply test csi_sync_nr again and not actually wait.
We could protected it with 'rc != 0 || timeout == 0' but there seems
no point.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10467
Lustre-commit: d6ce546eb7e2 ("LU-10467 obdclass: convert waiting in cl_sync_io_wait().")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/36102
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/cl_io.c | 23 ++++++++++-------------
 1 file changed, 10 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 3bc9097..e11f9fe 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1054,27 +1054,24 @@ void cl_sync_io_init_notify(struct cl_sync_io *anchor, int nr,
 int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
 		    long timeout)
 {
-	int rc = 1;
+	int rc = 0;
 
 	LASSERT(timeout >= 0);
 
-	if (timeout == 0)
-		wait_event_idle(anchor->csi_waitq,
-				atomic_read(&anchor->csi_sync_nr) == 0);
-	else
-		rc = wait_event_idle_timeout(anchor->csi_waitq,
-					     atomic_read(&anchor->csi_sync_nr) == 0,
-					     timeout * HZ);
-	if (rc == 0) {
+	if (timeout > 0 &&
+	    wait_event_idle_timeout(anchor->csi_waitq,
+				    atomic_read(&anchor->csi_sync_nr) == 0,
+				    timeout * HZ) == 0) {
 		rc = -ETIMEDOUT;
 		CERROR("IO failed: %d, still wait for %d remaining entries\n",
 		       rc, atomic_read(&anchor->csi_sync_nr));
+	}
 
-		wait_event_idle(anchor->csi_waitq,
-				atomic_read(&anchor->csi_sync_nr) == 0);
-	} else {
+	wait_event_idle(anchor->csi_waitq,
+			atomic_read(&anchor->csi_sync_nr) == 0);
+	if (!rc)
 		rc = anchor->csi_sync_rc;
-	}
+
 	/* We take the lock to ensure that cl_sync_io_note() has finished */
 	spin_lock(&anchor->csi_waitq.lock);
 	LASSERT(atomic_read(&anchor->csi_sync_nr) == 0);
-- 
1.8.3.1
