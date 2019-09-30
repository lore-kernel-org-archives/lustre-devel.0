From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:47 -0400
Subject: [lustre-devel] [PATCH 028/151] lustre: lmv: stripe dir page may be
 released mistakenly
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

stripe_dirent_next() may put_stripe_dirent() while its dirent
is still in use, e.g. lmv_dirent_next() popped stripe last
dirent, when it can't point sd_ent to next, but it shouldn't
release stripe dir page.

stripe_dirent->sd_ent should be set NULL when its dir page
is released, which can avoid misuse.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9857
Lustre-commit: beadbad429ae ("LU-9857 lmv: stripe dir page may be released mistakenly")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28548
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Tested-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index d71d077..bcbda30 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -2023,6 +2023,7 @@ static inline void put_stripe_dirent(struct stripe_dirent *stripe)
 		kunmap(stripe->sd_page);
 		put_page(stripe->sd_page);
 		stripe->sd_page = NULL;
+		stripe->sd_ent = NULL;
 	}
 }
 
@@ -2045,20 +2046,24 @@ static struct lu_dirent *stripe_dirent_next(struct lmv_dir_ctxt *ctxt,
 
 	LASSERT(stripe == &ctxt->ldc_stripes[stripe_index]);
 
+	if (stripe->sd_eof)
+		return NULL;
+
 	if (ent) {
 		ent = lu_dirent_next(ent);
 		if (!ent) {
 check_eof:
 			end = le64_to_cpu(stripe->sd_dp->ldp_hash_end);
 
-			put_stripe_dirent(stripe);
-
+			LASSERTF(hash <= end, "hash %llx end %llx\n",
+				 hash, end);
 			if (end == MDS_DIR_END_OFF) {
 				stripe->sd_ent = NULL;
 				stripe->sd_eof = true;
 				return NULL;
 			}
-			LASSERT(hash <= end);
+
+			put_stripe_dirent(stripe);
 			hash = end;
 		}
 	}
@@ -2114,10 +2119,8 @@ static struct lu_dirent *stripe_dirent_next(struct lmv_dir_ctxt *ctxt,
 			     le16_to_cpu(ent->lde_namelen)) == 0))
 			continue;
 
-		if (le64_to_cpu(ent->lde_hash) < hash)
-			continue;
-
-		break;
+		if (le64_to_cpu(ent->lde_hash) >= hash)
+			break;
 	}
 
 	if (!ent)
-- 
1.8.3.1
