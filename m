From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:19 -0500
Subject: [lustre-devel] [PATCH 211/622] lustre: lov: fix lov_iocontrol for
 inactive OST case
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-212-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Vladimir Saveliev <c17830@cray.com>

For inactive OSTs lov->lov_tgts[index]->ltd_exp is
NULL. lov_iocontrol() is to check that before dereferencing to
lov->lov_tgts[index]->ltd_exp->exp_obd.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11911
Lustre-commit: 0facd12afa33 ("LU-11911 lov: fix lov_iocontrol for inactive OST case")
Signed-off-by: Vladimir Saveliev <c17830@cray.com>
Cray-bug-id: LUS-6937
Reviewed-on: https://review.whamcloud.com/34148
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_obd.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 08d7edc..cc0ca1c 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -1001,15 +1001,15 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 			/* Try again with the next index */
 			return -EAGAIN;
 
-		imp = lov->lov_tgts[index]->ltd_exp->exp_obd->u.cli.cl_import;
-		if (!lov->lov_tgts[index]->ltd_active &&
-		    imp->imp_state != LUSTRE_IMP_IDLE)
-			return -ENODATA;
-
 		osc_obd = class_exp2obd(lov->lov_tgts[index]->ltd_exp);
 		if (!osc_obd)
 			return -EINVAL;
 
+		imp = osc_obd->u.cli.cl_import;
+		if (!lov->lov_tgts[index]->ltd_active &&
+		    imp->imp_state != LUSTRE_IMP_IDLE)
+			return -ENODATA;
+
 		/* copy UUID */
 		if (copy_to_user(data->ioc_pbuf2, obd2cli_tgt(osc_obd),
 				 min_t(unsigned long, data->ioc_plen2,
-- 
1.8.3.1
