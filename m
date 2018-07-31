From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:25:55 -0400
Subject: [lustre-devel] [PATCH 03/31] lustre: obd: change positional struct
 initializers to C99
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Steve Guminski <stephenx.guminski@intel.com>

This patch makes no functional changes.  Struct initializers in the
obd directory that use C89 or GCC-only syntax are updated to C99
syntax.  Whitespace is changed to match the code style guidelines.

The C99 syntax prevents incorrect initialization if values are
accidently placed in the wrong position, allows changes in the struct
definition, and clears any members that are not given an explicit
value.

The following struct initializers have been updated:

lustre/obdclass/obd_config.c:
        struct llog_process_cat_data

Signed-off-by: Steve Guminski <stephenx.guminski@intel.com>
WC-id: https://jira.whamcloud.com/browse/LU-6210
Reviewed-on: https://review.whamcloud.com/23697
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/obd_config.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 6d47435..d962f0c 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1417,7 +1417,9 @@ int class_config_llog_handler(const struct lu_env *env,
 int class_config_parse_llog(const struct lu_env *env, struct llog_ctxt *ctxt,
 			    char *name, struct config_llog_instance *cfg)
 {
-	struct llog_process_cat_data	 cd = {0, 0};
+	struct llog_process_cat_data cd = {
+		.lpcd_first_idx = 0,
+	};
 	struct llog_handle		*llh;
 	llog_cb_t			 callback;
 	int				 rc;
-- 
1.8.3.1
