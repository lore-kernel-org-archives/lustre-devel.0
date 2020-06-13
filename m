From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:04 -0400
Subject: [lustre-devel] [PATCH 08/20] lustre: lmv: check stripe FID sanity
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Striped directory layout may be broken, if some stripe FID is insane,
return -ENODEV.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13437
Lustre-commit: 698a496aac51e ("LU-13437 lmv: check stripe FID sanity")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38560
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 4583cea..203a17b 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1539,6 +1539,10 @@ static struct lu_tgt_desc *lmv_locate_tgt_rr(struct lmv_obd *lmv, u32 *mdt)
 			return ERR_CAST(oinfo);
 	}
 
+	/* check stripe FID is sane */
+	if (!fid_is_sane(&oinfo->lmo_fid))
+		return ERR_PTR(-ENODEV);
+
 	*fid = oinfo->lmo_fid;
 	*mds = oinfo->lmo_mds;
 	tgt = lmv_tgt(lmv, oinfo->lmo_mds);
-- 
1.8.3.1
