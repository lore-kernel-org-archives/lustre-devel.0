From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:06 -0500
Subject: [lustre-devel] [PATCH 138/622] lustre: misc: quiet console messages
 at startup
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-139-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Some modules print less-than-useful messages on every load.
Turn these into internal debug messages to reduce noise.

The message in gss_init_svc_upcall() should also be quieted,
but it exposes that this function is waiting 1.5s on each module
load for lsvcgssd to start.  This should be fixed separately.

WC-bug-id: https://jira.whamcloud.com/browse/LU-1095
Lustre-commit: ed0c19d250f6 ("LU-1095 misc: quiet console messages at startup")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33281
Reviewed-by: Nathaniel Clark <nclark@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 0da9269..81b86a0 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -257,10 +257,12 @@ static int lmv_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
 	for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
 		struct lmv_tgt_desc *tgt = lmv->tgts[i];
 
-		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active) {
+		if (!tgt || !tgt->ltd_exp) {
 			CWARN("%s: NULL export for %d\n", obd->obd_name, i);
 			continue;
 		}
+		if (!tgt->ltd_active)
+			continue;
 
 		rc = md_init_ea_size(tgt->ltd_exp, easize, def_easize);
 		if (rc) {
-- 
1.8.3.1
