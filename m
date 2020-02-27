From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:42 -0500
Subject: [lustre-devel] [PATCH 594/622] lustre: lmv: disable statahead for
 remote objects
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-595-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vladimir Saveliev <c17830@cray.com>

Statahead for remote objects is supposed to be disabled by
LU-11681 lmv: disable remote file statahead.

However due to typo it is not and statahead for remote objects is
accompanied by warnings like:
  ll_set_inode()) Can not initialize inode .. without object type..
  ll_prep_inode()) new_inode -fatal: rc -12

Fix the typo.

Test to illustrate the issue is added.

Fixes: 6dd8b9909e79 ("lustre: lmv: disable remote file statahead")

WC-bug-id: https://jira.whamcloud.com/browse/LU-13099
Lustre-commit: 68330379b01c ("LU-13099 lmv: disable statahead for remote objects")
Signed-off-by: Vladimir Saveliev <c17830@cray.com>
Cray-bug-id: LUS-8262
Reviewed-on: https://review.whamcloud.com/37089
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Olaf Faaland-LLNL <faaland1@llnl.gov>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index ee52bba..cead3a1 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3369,7 +3369,7 @@ static int lmv_intent_getattr_async(struct obd_export *exp,
 	if (IS_ERR(ptgt))
 		return PTR_ERR(ptgt);
 
-	ctgt = lmv_fid2tgt(lmv, &op_data->op_fid1);
+	ctgt = lmv_fid2tgt(lmv, &op_data->op_fid2);
 	if (IS_ERR(ctgt))
 		return PTR_ERR(ctgt);
 
-- 
1.8.3.1
