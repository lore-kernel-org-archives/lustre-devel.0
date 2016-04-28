From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 21:37:11 -0400
Subject: [lustre-devel] [PATCH 02/12] staging: lustre: obd: add newline for
	dumped config record
In-Reply-To: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
References: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461807441-3210-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

The function class_config_parse_rec() parses the llog record
and places it into a buffer to be returned. That buffer needs
to end with a newline which is currently missing.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2149
Reviewed-on: http://review.whamcloud.com/4254
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/obd_config.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 084af1a..e60ef4a 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1350,6 +1350,7 @@ static int class_config_parse_rec(struct llog_rec_hdr *rec, char *buf,
 					lustre_cfg_string(lcfg, i));
 		}
 	}
+	ptr += snprintf(ptr, end - ptr, "\n");
 	/* return consumed bytes */
 	rc = ptr - buf;
 	return rc;
-- 
2.7.4
