From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:26 -0400
Subject: [lustre-devel] [PATCH 33/58] staging: lustre: obdclass: fix
	lmd_parse() to handle comma-separated NIDs
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-34-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jian Yu <jian.yu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jian Yu <jian.yu@intel.com>

This patch handles the  upgrade situation that old mountdata already
contains comma-separated NIDs. The correct way to fix the original
issue is to parse comma-separated NIDs in lmd_parse().

Signed-off-by: Jian Yu <jian.yu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4460
Reviewed-on: http://review.whamcloud.com/8918
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Sebastien Buisson <sebastien.buisson@bull.net>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index aa84a50..4931e37 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -880,7 +880,7 @@ static int lmd_parse_mgs(struct lustre_mount_data *lmd, char **ptr)
  */
 static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 {
-	char *s1, *s2, *devname = NULL;
+	char *s1, *s2, *s3, *devname = NULL;
 	struct lustre_mount_data *raw = (struct lustre_mount_data *)options;
 	int rc = 0;
 
@@ -913,6 +913,7 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 		/* Skip whitespace and extra commas */
 		while (*s1 == ' ' || *s1 == ',')
 			s1++;
+		s3 = s1;
 
 		/* Client options are parsed in ll_options: eg. flock,
 		 * user_xattr, acl
@@ -970,6 +971,7 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 			rc = lmd_parse_mgssec(lmd, s1 + 7);
 			if (rc)
 				goto invalid;
+			s3 = s2;
 			clear++;
 		/* ost exclusion list */
 		} else if (strncmp(s1, "exclude=", 8) == 0) {
@@ -990,10 +992,19 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 			size_t length, params_length;
 			char *tail = strchr(s1 + 6, ',');
 
-			if (!tail)
+			if (!tail) {
 				length = strlen(s1);
-			else
-				length = tail - s1;
+			} else {
+				lnet_nid_t nid;
+				char *param_str = tail + 1;
+				int supplementary = 1;
+
+				while (!class_parse_nid_quiet(param_str, &nid,
+							      &param_str)) {
+					supplementary = 0;
+				}
+				length = param_str - s1 - supplementary;
+			}
 			length -= 6;
 			params_length = strlen(lmd->lmd_params);
 			if (params_length + length + 1 >= LMD_PARAMS_MAXLEN)
@@ -1001,6 +1012,7 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 			strncat(lmd->lmd_params, s1 + 6, length);
 			lmd->lmd_params[params_length + length] = '\0';
 			strlcat(lmd->lmd_params, " ", LMD_PARAMS_MAXLEN);
+			s3 = s1 + 6 + length;
 			clear++;
 		} else if (strncmp(s1, "osd=", 4) == 0) {
 			rc = lmd_parse_string(&lmd->lmd_osd_type, s1 + 4);
-- 
1.7.1
