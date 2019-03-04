From: NeilBrown <neilb@suse.com>
Date: Mon, 04 Mar 2019 17:31:39 +1100
Subject: [lustre-devel] [PATCH 27/28] lustre: ldlm: simplify
 lock_mode_to_index()
In-Reply-To: <155168107971.31333.14345309795939467246.stgit@noble.brown>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
Message-ID: <155168109905.31333.13609917410154153988.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This function has the same effect as ilog2(), so just use ilog2
directly.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index 99aef0bee53c..b3d1a2565dbc 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -104,8 +104,7 @@ static inline int lock_mode_to_index(enum ldlm_mode mode)
 
 	LASSERT(mode != 0);
 	LASSERT(is_power_of_2(mode));
-	for (index = -1; mode; index++)
-		mode >>= 1;
+	index = ilog2(mode);
 	LASSERT(index < LCK_MODE_NUM);
 	return index;
 }
