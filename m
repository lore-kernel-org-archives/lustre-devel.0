From: Ting-Chih Hsiao <s894330@hotmail.com>
Date: Mon, 21 Sep 2015 14:58:09 +0800
Subject: [lustre-devel] [PATCH] staging: lustre-mgc: make mgc_obd_ops static
Message-ID: <BLU436-SMTP2595A0F3B91178F3D6D91BCB9460@phx.gbl>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Fix sparse warnings of the following type:

warning: symbol '....' was not declared. Should it be static?

Signed-off-by: Ting-Chih Hsiao <s894330@hotmail.com>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 9e36642..3e9cca0 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1692,7 +1692,7 @@ out:
 	return rc;
 }
 
-struct obd_ops mgc_obd_ops = {
+static struct obd_ops mgc_obd_ops = {
 	.o_owner	= THIS_MODULE,
 	.o_setup	= mgc_setup,
 	.o_precleanup   = mgc_precleanup,
-- 
1.9.1
