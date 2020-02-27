From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:12 -0500
Subject: [lustre-devel] [PATCH 384/622] lustre: obdclass: use RCU to release
 lu_env_item
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-385-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

as rhashtable_lookup_fast() is lockless and can
find just released objects.

Fixes: c678ad5a25 ("lustre: obdclass: put all service's env on the list")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12491
Lustre-commit: 87306c22e4b9 ("LU-12491 obdclass: use RCU to release lu_env_item")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35038
Reviewed-by: Neil Brown <neilb@suse.com>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lu_object.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index bafd817..c94911d 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -1870,6 +1870,7 @@ struct lu_env_item {
 	struct task_struct	*lei_task;	/* rhashtable key */
 	struct rhash_head	lei_linkage;
 	struct lu_env		*lei_env;
+	struct rcu_head		lei_rcu_head;
 };
 
 static const struct rhashtable_params lu_env_rhash_params = {
@@ -1909,6 +1910,14 @@ int lu_env_add(struct lu_env *env)
 }
 EXPORT_SYMBOL(lu_env_add);
 
+static void lu_env_item_free(struct rcu_head *head)
+{
+	struct lu_env_item *lei;
+
+	lei = container_of(head, struct lu_env_item, lei_rcu_head);
+	kfree(lei);
+}
+
 void lu_env_remove(struct lu_env *env)
 {
 	struct lu_env_item *lei;
@@ -1923,13 +1932,11 @@ void lu_env_remove(struct lu_env *env)
 		}
 	}
 
-	rcu_read_lock();
 	lei = rhashtable_lookup_fast(&lu_env_rhash, &task,
 				     lu_env_rhash_params);
 	if (lei && rhashtable_remove_fast(&lu_env_rhash, &lei->lei_linkage,
 					  lu_env_rhash_params) == 0)
-		kfree(lei);
-	rcu_read_unlock();
+		call_rcu(&lei->lei_rcu_head, lu_env_item_free);
 }
 EXPORT_SYMBOL(lu_env_remove);
 
-- 
1.8.3.1
