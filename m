From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:48 -0400
Subject: [lustre-devel] [PATCH 149/151] lustre: llite: remove // comments.
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-150-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

Apart from the SPDX-License-Identifier comments,
the only remaining // comments are now themselves inside
/* */ comments, so they don't really count as comments.

The comments about rw_semaphore alignment are completely outdated.

Signed-off-by: NeilBrown <neilb@suse.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 2cb67b0..ee8d160 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -183,13 +183,6 @@ struct ll_inode_info {
 		struct {
 			struct mutex			lli_size_mutex;
 			char			       *lli_symlink_name;
-			/*
-			 * struct rw_semaphore {
-			 *    signed long	count;     // align d.d_def_acl
-			 *    spinlock_t	wait_lock; // align d.d_sa_lock
-			 *    struct list_head wait_list;
-			 * }
-			 */
 			struct rw_semaphore		lli_trunc_sem;
 			struct range_lock_tree		lli_write_tree;
 
-- 
1.8.3.1
