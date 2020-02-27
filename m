From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:55 -0500
Subject: [lustre-devel] [PATCH 187/622] lustre: ldlm: remove trace from
 ldlm_pool_count()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-188-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: "John L. Hammond" <jhammond@whamcloud.com>

The trace in ldlm_pool_count() is too noisy given its
information value so remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10862
Lustre-commit: 3fe2096dfc30 ("LU-10862 ldlm: remove trace from ldlm_pool_{count,skrink}()")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31820
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_pool.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index d2149a6..b2b3ead 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -773,9 +773,6 @@ static unsigned long ldlm_pools_count(enum ldlm_side client, gfp_t gfp_mask)
 	if (client == LDLM_NAMESPACE_CLIENT && !(gfp_mask & __GFP_FS))
 		return 0;
 
-	CDEBUG(D_DLMTRACE, "Request to count %s locks from all pools\n",
-	       client == LDLM_NAMESPACE_CLIENT ? "client" : "server");
-
 	/*
 	 * Find out how many resources we may release.
 	 */
-- 
1.8.3.1
