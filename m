From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:34 -0500
Subject: [lustre-devel] [PATCH 466/622] lustre: llite: remove ll_umounting
 field
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-467-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This field is set but never accessed, so remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 15b83c9b7b28 ("LU-6142 llite: remove ll_umounting field")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35885
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 3 +--
 fs/lustre/llite/llite_lib.c      | 1 -
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 77854a5..6186720 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -505,8 +505,7 @@ struct ll_sb_info {
 	struct lu_fid	     ll_root_fid; /* root object fid */
 
 	int		       ll_flags;
-	unsigned int		  ll_umounting:1,
-				  ll_xattr_cache_enabled:1,
+	unsigned int		  ll_xattr_cache_enabled:1,
 				ll_xattr_cache_set:1, /* already set to 0/1 */
 				  ll_client_common_fill_super_succeeded:1,
 				  ll_checksum_set:1;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 7d83ee3..ad7c2e2 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -785,7 +785,6 @@ void ll_kill_super(struct super_block *sb)
 	 */
 	if (sbi) {
 		sb->s_dev = sbi->ll_sdev_orig;
-		sbi->ll_umounting = 1;
 
 		/* wait running statahead threads to quit */
 		while (atomic_read(&sbi->ll_sa_running) > 0)
-- 
1.8.3.1
