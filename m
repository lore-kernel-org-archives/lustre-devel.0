From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:12 -0400
Subject: [lustre-devel] [PATCH 02/32] staging/lustre:
	KEY_DEFAULT/MAX_COOKIESIZE key is unused, remove them
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Also remove the lmv and mdc infrastructure to query these keys.
In fact this whole "unlink cookies" thing becomes irrelevant
with newer servers, but since we still retain 2.[123] servers
commpatibility, we cannot completely remove all traces of it yet.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/obd.h     |  2 --
 drivers/staging/lustre/lustre/lmv/lmv_obd.c     |  2 --
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 20 --------------------
 3 files changed, 24 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 314f5c7..5de9776 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -840,8 +840,6 @@ enum obd_cleanup_stage {
 #define KEY_LOV_IDX	     "lov_idx"
 #define KEY_MAX_EASIZE		"max_easize"
 #define KEY_DEFAULT_EASIZE	"default_easize"
-#define KEY_MAX_COOKIESIZE	"max_cookiesize"
-#define KEY_DEFAULT_COOKIESIZE	"default_cookiesize"
 #define KEY_MDS_CONN	    "mds_conn"
 #define KEY_MGSSEC	      "mgssec"
 #define KEY_NEXT_ID	     "next_id"
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 8f0ffa4..7e6a060 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2322,8 +2322,6 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 		return -EINVAL;
 	} else if (KEY_IS(KEY_MAX_EASIZE) ||
 		   KEY_IS(KEY_DEFAULT_EASIZE) ||
-		   KEY_IS(KEY_MAX_COOKIESIZE) ||
-		   KEY_IS(KEY_DEFAULT_COOKIESIZE) ||
 		   KEY_IS(KEY_CONN_DATA)) {
 		rc = lmv_check_connect(obd);
 		if (rc)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 8726176..dc234a7 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2124,26 +2124,6 @@ static int mdc_get_info(const struct lu_env *env, struct obd_export *exp,
 		default_easize = val;
 		*default_easize = exp->exp_obd->u.cli.cl_default_mds_easize;
 		return 0;
-	} else if (KEY_IS(KEY_MAX_COOKIESIZE)) {
-		int mdsize, *max_cookiesize;
-
-		if (*vallen != sizeof(int))
-			return -EINVAL;
-		mdsize = *(int *)val;
-		if (mdsize > exp->exp_obd->u.cli.cl_max_mds_cookiesize)
-			exp->exp_obd->u.cli.cl_max_mds_cookiesize = mdsize;
-		max_cookiesize = val;
-		*max_cookiesize = exp->exp_obd->u.cli.cl_max_mds_cookiesize;
-		return 0;
-	} else if (KEY_IS(KEY_DEFAULT_COOKIESIZE)) {
-		int *default_cookiesize;
-
-		if (*vallen != sizeof(int))
-			return -EINVAL;
-		default_cookiesize = val;
-		*default_cookiesize =
-			exp->exp_obd->u.cli.cl_default_mds_cookiesize;
-		return 0;
 	} else if (KEY_IS(KEY_CONN_DATA)) {
 		struct obd_import *imp = class_exp2cliimp(exp);
 		struct obd_connect_data *data = val;
-- 
2.1.0
