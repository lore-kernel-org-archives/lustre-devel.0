From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:33 -0400
Subject: [lustre-devel] [PATCH 16/18] lustre: libcfs: restore original
 behavior in cfs_str2num_check
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

When cfs_str2num_check() moved from simple_strtoul to kstrtoul
some of the functionality got lost. Restore handling hexidecimal
number as well as '+' and '-'. Also handle any trailing spaces.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9325
Reviewed-on: https://review.whamcloud.com/32217
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index e1fb126..e390b0b 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -214,8 +214,10 @@ char *cfs_firststr(char *str, size_t size)
 {
 	bool all_numbers = true;
 	char *endp, cache;
+	int len;
 	int rc;
 
+	endp = strim(str);
 	/**
 	 * kstrouint can only handle strings composed
 	 * of only numbers. We need to scan the string
@@ -228,16 +230,25 @@ char *cfs_firststr(char *str, size_t size)
 	 * After we are done the character at the
 	 * position we placed '\0' must be restored.
 	 */
-	for (endp = str; endp < str + nob; endp++) {
-		if (!isdigit(*endp)) {
+	len = min((int)strlen(endp), nob);
+	for (; endp < str + len; endp++) {
+		if (!isdigit(*endp) && *endp != '-' &&
+		    *endp != '+') {
 			all_numbers = false;
 			break;
 		}
 	}
+
+	/* Eat trailing space */
+	if (!all_numbers && isspace(*endp)) {
+		all_numbers = true;
+		endp--;
+	}
+
 	cache = *endp;
 	*endp = '\0';
 
-	rc = kstrtouint(str, 10, num);
+	rc = kstrtouint(str, 0, num);
 	*endp = cache;
 	if (rc || !all_numbers)
 		return 0;
-- 
1.8.3.1
