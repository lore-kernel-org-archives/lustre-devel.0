From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:33 -0500
Subject: [lustre-devel] [PATCH 465/622] lustre: llite: remove
 lli_readdir_mutex
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-466-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.com>

This mutex is initialized but never used, so
remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 26bf41c177a5 ("LU-6142 llite: remove lli_readdir_mutex")
Signed-off-by: Mr NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35884
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 3 ---
 fs/lustre/llite/llite_lib.c      | 1 -
 2 files changed, 4 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 232fb0a..77854a5 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -143,9 +143,6 @@ struct ll_inode_info {
 	union {
 		/* for directory */
 		struct {
-			/* serialize normal readdir and statahead-readdir. */
-			struct mutex			lli_readdir_mutex;
-
 			/* metadata statahead */
 			/* since parent-child threads can share the same @file
 			 * struct, "opendir_key" is the token when dir close for
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 217268e..7d83ee3 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -960,7 +960,6 @@ void ll_lli_init(struct ll_inode_info *lli)
 
 	LASSERT(lli->lli_vfs_inode.i_mode != 0);
 	if (S_ISDIR(lli->lli_vfs_inode.i_mode)) {
-		mutex_init(&lli->lli_readdir_mutex);
 		lli->lli_opendir_key = NULL;
 		lli->lli_sai = NULL;
 		spin_lock_init(&lli->lli_sa_lock);
-- 
1.8.3.1
