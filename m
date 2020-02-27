From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:00 -0500
Subject: [lustre-devel] [PATCH 192/622] lustre: ldlm: Adjust search_*
 functions
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-193-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

The search_itree and search_queue functions should both
return either a pointer to a found lock or NULL.

Currently, search_itree just returns the contents of
data->lmd_lock, whether or not a lock was found.

search_queue will do the same under certain cirumstances.

Zero lmd_lock in both search_* functions, and also stop
searching in search_itree once a lock is found.

cray-bug-id: LUS-6783
WC-bug-id: https://jira.whamcloud.com/browse/LU-11719
Lustre-commit: a231148843bd ("LU-11719 ldlm: Adjust search_* functions")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33754
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lock.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index b9771ef..06690a6 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -1159,6 +1159,8 @@ static struct ldlm_lock *search_itree(struct ldlm_resource *res,
 {
 	int idx;
 
+	data->lmd_lock = NULL;
+
 	for (idx = 0; idx < LCK_MODE_NUM; idx++) {
 		struct ldlm_interval_tree *tree = &res->lr_itree[idx];
 
@@ -1172,11 +1174,14 @@ static struct ldlm_lock *search_itree(struct ldlm_resource *res,
 				   data->lmd_policy->l_extent.start,
 				   data->lmd_policy->l_extent.end,
 				   lock_matches, data);
+		if (data->lmd_lock)
+			return data->lmd_lock;
 	}
-	return data->lmd_lock;
+
+	return NULL;
 }
 
-/**
+/*
  * Search for a lock with given properties in a queue.
  *
  * @queue	search for a lock in this queue
@@ -1189,9 +1194,12 @@ static struct ldlm_lock *search_queue(struct list_head *queue,
 {
 	struct ldlm_lock *lock;
 
+	data->lmd_lock = NULL;
+
 	list_for_each_entry(lock, queue, l_res_link)
 		if (lock_matches(lock, data))
 			return data->lmd_lock;
+
 	return NULL;
 }
 
-- 
1.8.3.1
