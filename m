From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:23 -0500
Subject: [lustre-devel] [PATCH 55/60] staging: lustre: obd: move s3 in
	lmd_parse to inner loop
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-56-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Building the lustre client with W=1 reports the following
error:

obdclass/obd_mount.c: In function lmd_parse:
obdclass/obd_mount.c:880: warning: variable set but not used

The solution is to move s3 to the inner loop
where it is only used.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8378
Reviewed-on: https://review.whamcloud.com/23820
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 2283e92..8e0d4b1 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -877,7 +877,7 @@ static int lmd_parse_mgs(struct lustre_mount_data *lmd, char **ptr)
  */
 static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 {
-	char *s1, *s2, *s3, *devname = NULL;
+	char *s1, *s2, *devname = NULL;
 	struct lustre_mount_data *raw = (struct lustre_mount_data *)options;
 	int rc = 0;
 
@@ -906,6 +906,7 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 	while (*s1) {
 		int clear = 0;
 		int time_min = OBD_RECOVERY_TIME_MIN;
+		char *s3;
 
 		/* Skip whitespace and extra commas */
 		while (*s1 == ' ' || *s1 == ',')
-- 
1.8.3.1
