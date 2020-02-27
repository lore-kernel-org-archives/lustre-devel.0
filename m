From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:38 -0500
Subject: [lustre-devel] [PATCH 470/622] lustre: llite: remove sub_reenter
 field.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-471-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This field is never set or accessed, so
remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 3118333b9664 ("LU-6142 llite: remove sub_reenter field.")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35888
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_cl_internal.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 6fea0f5..40bb6f0 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -509,7 +509,6 @@ struct lov_io_sub {
 	 * \see cl_env_get()
 	 */
 	u16			sub_refcheck;
-	u16			sub_reenter;
 };
 
 /**
-- 
1.8.3.1
