From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:07:54 -0500
Subject: [lustre-devel] [PATCH 006/622] lustre: ldlm: Make kvzalloc | kvfree
 use consistent
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "Christopher J. Morrone" <morrone2@llnl.gov>

struct ldlm_lock's l_lvb_data field is freed in ldlm_lock_put()
using kfree.  However, some other code paths can attach
a buffer to l_lvb_data that was allocated using vmalloc().
This can lead to a kfree() of a vmalloc()ed buffer, which can
trigger a kernel Oops.

WC-bug-id: https://jira.whamcloud.com/browse/LU-4194
Lustre-commit: 9c4d506c5fea ("LU-4194 ldlm: Make OBD_[ALLOC|FREE]_LARGE use consistent")
Signed-off-by: Christopher J. Morrone <morrone2@llnl.gov>
Reviewed-on: http://review.whamcloud.com/8298
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 6eebf5f..7242cd1 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -185,7 +185,7 @@ void ldlm_lock_put(struct ldlm_lock *lock)
 			lock->l_export = NULL;
 		}
 
-		kfree(lock->l_lvb_data);
+		kvfree(lock->l_lvb_data);
 
 		lu_ref_fini(&lock->l_reference);
 		OBD_FREE_RCU(lock, sizeof(*lock), &lock->l_handle);
@@ -1548,7 +1548,7 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 
 	if (lvb_len) {
 		lock->l_lvb_len = lvb_len;
-		lock->l_lvb_data = kzalloc(lvb_len, GFP_NOFS);
+		lock->l_lvb_data = kvzalloc(lvb_len, GFP_NOFS);
 		if (!lock->l_lvb_data) {
 			rc = -ENOMEM;
 			goto out;
-- 
1.8.3.1
