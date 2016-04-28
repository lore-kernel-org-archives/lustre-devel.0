From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 21:37:10 -0400
Subject: [lustre-devel] [PATCH 01/12] staging: lustre: obd: remove newline
	from LCONSOLE string
In-Reply-To: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
References: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461807441-3210-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

Remove the newline from the LCONSOLE debug macro in the
function class_config_dump_handler().

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2149
Reviewed-on: http://review.whamcloud.com/4254
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/obd_config.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 5395e99..084af1a 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1368,7 +1368,7 @@ int class_config_dump_handler(const struct lu_env *env,
 
 	if (rec->lrh_type == OBD_CFG_REC) {
 		class_config_parse_rec(rec, outstr, 256);
-		LCONSOLE(D_WARNING, "   %s\n", outstr);
+		LCONSOLE(D_WARNING, "   %s", outstr);
 	} else {
 		LCONSOLE(D_WARNING, "unhandled lrh_type: %#x\n", rec->lrh_type);
 		rc = -EINVAL;
-- 
2.7.4
