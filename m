From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 18 Mar 2016 08:42:47 +0300
Subject: [lustre-devel] [patch] staging: lustre: checking for NULL instead
	of IS_ERR
Message-ID: <20160318054247.GF2111@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

lustre_cfg_new() returns error pointers on error, it never returns NULL.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 65caffe..b7dc872 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1282,7 +1282,7 @@ static int mgc_apply_recover_logs(struct obd_device *mgc,
 
 		rc = -ENOMEM;
 		lcfg = lustre_cfg_new(LCFG_PARAM, &bufs);
-		if (!lcfg) {
+		if (IS_ERR(lcfg)) {
 			CERROR("mgc: cannot allocate memory\n");
 			break;
 		}
