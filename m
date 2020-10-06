From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:09 -0400
Subject: [lustre-devel] [PATCH 30/42] lustre: lov: guard against
 class_exp2obd() returning NULL.
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

class_exp2obd() can return NULL.  Sometimes this is tested for,
sometimes not.
Add appropriate tested so that a NULL return is never dereferenced.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 0aa3d883acfb05 ("LU-6142 lov: guard against class_exp2obd() returning NULL.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39379
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_obd.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 7fe7372..d88d325 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -269,8 +269,8 @@ static int lov_disconnect_obd(struct obd_device *obd, struct lov_tgt_desc *tgt)
 	int rc;
 
 	osc_obd = class_exp2obd(tgt->ltd_exp);
-	CDEBUG(D_CONFIG, "%s: disconnecting target %s\n",
-	       obd->obd_name, osc_obd ? osc_obd->obd_name : "NULL");
+	CDEBUG(D_CONFIG, "%s: disconnecting target %s\n", obd->obd_name,
+	       osc_obd ? osc_obd->obd_name : "<no obd>");
 
 	if (tgt->ltd_active) {
 		tgt->ltd_active = 0;
@@ -1122,7 +1122,8 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 
 			/* ll_umount_begin() sets force on lov, pass to osc */
 			osc_obd = class_exp2obd(lov->lov_tgts[i]->ltd_exp);
-			osc_obd->obd_force = obd->obd_force;
+			if (osc_obd)
+				osc_obd->obd_force = obd->obd_force;
 			err = obd_iocontrol(cmd, lov->lov_tgts[i]->ltd_exp,
 					    len, karg, uarg);
 			if (err) {
-- 
1.8.3.1
