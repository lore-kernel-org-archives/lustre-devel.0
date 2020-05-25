From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:18 -0400
Subject: [lustre-devel] [PATCH 41/45] lustre: lmv: do not print MDTs that
 are inactive
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-42-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Have lmv return -EAGAIN instead of -ENODATA for unconfigured MDTs.
That avoids "lfs df -v" from printing a long list of invalid MDTs
when trying to get the target state for non-rotational devices.

Add test for "lfs df -v" printing nonrotational state, as well as
limiting the reported OST and MDT to configured devices.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13427
Lustre-commit: 3728c2825aa27 ("LU-13427 lmv: do not print MDTs that are inactive")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38165
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Ben Evans <beevans@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index bb60f64..4583cea 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -820,7 +820,10 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 			return -ENODEV;
 
 		tgt = lmv_tgt(lmv, index);
-		if (!tgt || !tgt->ltd_active)
+		if (!tgt)
+			return -EAGAIN;
+
+		if (!tgt->ltd_active)
 			return -ENODATA;
 
 		mdc_obd = class_exp2obd(tgt->ltd_exp);
-- 
1.8.3.1
