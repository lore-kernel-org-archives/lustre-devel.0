From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:42 -0400
Subject: [lustre-devel] [PATCH 143/151] lustre: ldlm: simplify
 lock_mode_to_index()
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-144-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

This function has the same effect as ilog2(), so just use ilog2
directly.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12542
Lustre-commit: 32ae82e57cf8 ("LU-12542 ldlm: simplify lock_mode_to_index()")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/35486
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_extent.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_extent.c b/fs/lustre/ldlm/ldlm_extent.c
index 77d3e79..7c72d04 100644
--- a/fs/lustre/ldlm/ldlm_extent.c
+++ b/fs/lustre/ldlm/ldlm_extent.c
@@ -139,8 +139,7 @@ static inline int lock_mode_to_index(enum ldlm_mode mode)
 
 	LASSERT(mode != 0);
 	LASSERT(is_power_of_2(mode));
-	for (index = -1; mode; index++)
-		mode >>= 1;
+	index = ilog2(mode);
 	LASSERT(index < LCK_MODE_NUM);
 	return index;
 }
-- 
1.8.3.1
