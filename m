From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:26:15 -0400
Subject: [lustre-devel] [PATCH 23/31] lustre: llite: Return -ERESTARTSYS in
 range_lock()
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

If we return -ERESTARTSYS rather than -EINTR then the syscall can be
retried rather than failing with -EINTR.

Signed-off-by: Chris Horn <hornc@cray.com>
WC-id: https://jira.whamcloud.com/browse/LU-8735
Reviewed-on: https://review.whamcloud.com/23259
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/range_lock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/range_lock.c b/drivers/staging/lustre/lustre/llite/range_lock.c
index acdb0dc..d37da8e 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.c
+++ b/drivers/staging/lustre/lustre/llite/range_lock.c
@@ -157,7 +157,7 @@ int range_lock(struct range_lock_tree *tree, struct range_lock *lock)
 
 		if (signal_pending(current)) {
 			range_unlock(tree, lock);
-			rc = -EINTR;
+			rc = -ERESTARTSYS;
 			goto out;
 		}
 		spin_lock(&tree->rlt_lock);
-- 
1.8.3.1
