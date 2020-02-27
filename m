From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:05 -0500
Subject: [lustre-devel] [PATCH 557/622] lustre: lmv: fix to return correct
 MDT count
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-558-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

@ltd_tgts_size could be larger than actual MDT count,
as we preallocate ltd_tgts and resize it if necessary.

Fix it to use @ld_tgt_count instead.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12951
Lustre-commit: 3aa8826aabc7 ("LU-12951 lmv: fix to return correct MDT count")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/36713
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Olaf Faaland-LLNL <faaland1@llnl.gov>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index e92be25..ee52bba 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -2870,7 +2870,7 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 			exp->exp_connect_data = *(struct obd_connect_data *)val;
 		return rc;
 	} else if (KEY_IS(KEY_TGT_COUNT)) {
-		*((int *)val) = lmv->lmv_mdt_descs.ltd_tgts_size;
+		*((int *)val) = lmv->lmv_mdt_descs.ltd_lmv_desc.ld_tgt_count;
 		return 0;
 	}
 
-- 
1.8.3.1
