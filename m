From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:31 -0500
Subject: [lustre-devel] [PATCH 463/622] lustre: ptlrpc: remove
 scp_nthrs_stopping field.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-464-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This field is unused, so remove it.
If "shrinking threads" is ever needed, any extra fields
required can be added then.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 7233248e565f ("LU-6142 ptlrpc: remove scp_nthrs_stopping field.")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35882
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 68db603..aaf5cb8 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1557,8 +1557,6 @@ struct ptlrpc_service_part {
 	int				scp_thr_nextid;
 	/** # of starting threads */
 	int				scp_nthrs_starting;
-	/** # of stopping threads, reserved for shrinking threads */
-	int				scp_nthrs_stopping;
 	/** # running threads */
 	int				scp_nthrs_running;
 	/** service threads list */
-- 
1.8.3.1
