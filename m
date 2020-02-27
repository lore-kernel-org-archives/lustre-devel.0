From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:35 -0500
Subject: [lustre-devel] [PATCH 167/622] lustre: lmv: allocate fid on parent
 MDT in migrate
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-168-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

During directory migration, if the migrated file is not directory,
the target should be allocated on its parent MDT, not user specified
MDT. Because if it's parent is striped, this file should be migrated
to the MDT by its name hash, not the starting MDT of its parent.

Add sanity 230k to check file data not changed after migration.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11642
Lustre-commit: a857446dc648 ("LU-11642 lmv: allocate fid on parent MDT in migrate")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33641
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index e98f33d..428904c 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1970,7 +1970,10 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 	if (IS_ERR(child_tgt))
 		return PTR_ERR(child_tgt);
 
-	rc = lmv_fid_alloc(NULL, exp, &target_fid, op_data);
+	if (!S_ISDIR(op_data->op_mode) && tp_tgt)
+		rc = __lmv_fid_alloc(lmv, &target_fid, tp_tgt->ltd_idx);
+	else
+		rc = lmv_fid_alloc(NULL, exp, &target_fid, op_data);
 	if (rc)
 		return rc;
 
-- 
1.8.3.1
