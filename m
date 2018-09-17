From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Sep 2018 13:30:27 -0400
Subject: [lustre-devel] [PATCH 17/30] lustre: llite: protect ll_dentry_data
 modification
In-Reply-To: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537205440-6656-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

The ll_dentry_data bitfields modification should be protected by
a spinlock.

Signed-off-by: Andriy Skulysh <c17819@cray.com>
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9241
Seagate-bug-id: MRP-4257
Reviewed-on: https://review.whamcloud.com/26109
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_nfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index c66072a..5e91e83 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -171,8 +171,9 @@ struct lustre_nfs_fid {
 	 * we came from NFS and so opencache needs to be
 	 * enabled for this one
 	 */
+	spin_lock(&result->d_lock);
 	ll_d2d(result)->lld_nfs_dentry = 1;
-
+	spin_unlock(&result->d_lock);
 	return result;
 }
 
-- 
1.8.3.1
