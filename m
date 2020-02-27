From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:30 -0500
Subject: [lustre-devel] [PATCH 462/622] lustre: ptlrpc: remove srv_threads
 from struct ptlrpc_service
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-463-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

The threads are not stored here - nothing is.
Threads are stored in svcpt->scp_threads.
So remove the field and update the comment.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 6d1062cdffca ("LU-6142 ptlrpc: remove srv_threads from struct ptlrpc_service")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35881
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index bec92cf..68db603 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1314,7 +1314,7 @@ enum {
  */
 struct ptlrpc_thread {
 	/**
-	 * List of active threads in svc->srv_threads
+	 * List of active threads in svcpt->scp_threads
 	 */
 	struct list_head		t_link;
 	/**
@@ -1474,8 +1474,6 @@ struct ptlrpc_service {
 	char				*srv_name;
 	/** only statically allocated strings here; we don't clean them */
 	char				*srv_thread_name;
-	/** service thread list */
-	struct list_head		srv_threads;
 	/** threads # should be created for each partition on initializing */
 	int				srv_nthrs_cpt_init;
 	/** limit of threads number for each partition */
-- 
1.8.3.1
