From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:16 -0500
Subject: [lustre-devel] [PATCH 388/622] lustre: obdclass: add comment for
 rcu handling in lu_env_remove
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-389-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

During the review it was pointed out why the RCU lock was dropped
in lu_env_remove() but the code itself doesn't explain why. Add
a comment giving the details why RCU locking is not needed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12491
Lustre-commit: 709fbe6ee54a ("LU-12491 obdclass: add comment for rcu handling in lu_env_remove")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/35447
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Neil Brown <neilb@suse.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lu_object.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index c94911d..d8bff3f 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -1932,6 +1932,11 @@ void lu_env_remove(struct lu_env *env)
 		}
 	}
 
+	/* The rcu_lock is not taking in this case since the key
+	 * used is the actual task_struct. This implies that each
+	 * object is only removed by the owning thread, so there
+	 * can never be a race on a particular object.
+	 */
 	lei = rhashtable_lookup_fast(&lu_env_rhash, &task,
 				     lu_env_rhash_params);
 	if (lei && rhashtable_remove_fast(&lu_env_rhash, &lei->lei_linkage,
-- 
1.8.3.1
