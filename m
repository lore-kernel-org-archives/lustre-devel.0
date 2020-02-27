From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:13 -0500
Subject: [lustre-devel] [PATCH 265/622] lnet: Cleanup lnet_get_rtr_pool_cfg
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-266-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

The cfs_percpt_for_each loop contains an off-by-one error that causes
memory corruption. In addition, the way these loops are nested results
in unnecessary iterations. We only need to iterate through the cpts
until we match the cpt number passed as an argument. At that point we
want to copy the router buffer pools for that cpt.

Cray-bug-id: LUS-7240
WC-bug-id: https://jira.whamcloud.com/browse/LU-12152
Lustre-commit: 187117fd94e4 ("LU-12152 lnet: Cleanup lnet_get_rtr_pool_cfg")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/34591
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 66a116c..78a8659 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -549,29 +549,30 @@ static void lnet_shuffle_seed(void)
 	lnet_del_route(LNET_NIDNET(LNET_NID_ANY), LNET_NID_ANY);
 }
 
-int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
+int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
 {
+	struct lnet_rtrbufpool *rbp;
 	int i, rc = -ENOENT, j;
 
 	if (!the_lnet.ln_rtrpools)
 		return rc;
 
-	for (i = 0; i < LNET_NRBPOOLS; i++) {
-		struct lnet_rtrbufpool *rbp;
 
-		lnet_net_lock(LNET_LOCK_EX);
-		cfs_percpt_for_each(rbp, j, the_lnet.ln_rtrpools) {
-			if (i++ != idx)
-				continue;
+	cfs_percpt_for_each(rbp, i, the_lnet.ln_rtrpools) {
+		if (i != cpt)
+			continue;
 
-			pool_cfg->pl_pools[i].pl_npages = rbp[i].rbp_npages;
-			pool_cfg->pl_pools[i].pl_nbuffers = rbp[i].rbp_nbuffers;
-			pool_cfg->pl_pools[i].pl_credits = rbp[i].rbp_credits;
-			pool_cfg->pl_pools[i].pl_mincredits = rbp[i].rbp_mincredits;
-			rc = 0;
-			break;
+		lnet_net_lock(i);
+		for (j = 0; j < LNET_NRBPOOLS; j++) {
+			pool_cfg->pl_pools[j].pl_npages = rbp[j].rbp_npages;
+			pool_cfg->pl_pools[j].pl_nbuffers = rbp[j].rbp_nbuffers;
+			pool_cfg->pl_pools[j].pl_credits = rbp[j].rbp_credits;
+			pool_cfg->pl_pools[j].pl_mincredits =
+				rbp[j].rbp_mincredits;
 		}
-		lnet_net_unlock(LNET_LOCK_EX);
+		lnet_net_unlock(i);
+		rc = 0;
+		break;
 	}
 
 	lnet_net_lock(LNET_LOCK_EX);
-- 
1.8.3.1
