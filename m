From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:36 -0500
Subject: [lustre-devel] [PATCH 468/622] lustre: llite: remove lti_iter field
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-469-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This field is never used, so remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 0140f50c1287 ("LU-6142 llite: remove lti_iter field")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35886
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index bb5f519..025d33e 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1033,7 +1033,6 @@ struct ll_cl_context {
 };
 
 struct ll_thread_info {
-	struct iov_iter		lti_iter;
 	struct vvp_io_args	lti_args;
 	struct ra_io_arg	lti_ria;
 	struct ll_cl_context	lti_io_ctx;
-- 
1.8.3.1
