From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:04 -0400
Subject: [lustre-devel] [PATCH 25/42] lustre: lov: don't use inline for
 operations functions.
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

These functions have their address taken and stored in an 'operations'
structure.  So they cannot possibly be compiled "inline".
So remove the "inline" declaration.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: e58cfb7ec5ed5d ("LU-6142 lov: don't use inline for operations functions.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39376
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_ea.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
index 1d105c0..13f47ee 100644
--- a/fs/lustre/lov/lov_ea.c
+++ b/fs/lustre/lov/lov_ea.c
@@ -303,7 +303,7 @@ void lsm_free(struct lov_stripe_md *lsm)
 	return ERR_PTR(rc);
 }
 
-static inline struct lov_stripe_md *
+static struct lov_stripe_md *
 lsm_unpackmd_v1v3(struct lov_obd *lov,
 		  struct lov_mds_md *lmm, size_t buf_size,
 		  const char *pool_name,
-- 
1.8.3.1
