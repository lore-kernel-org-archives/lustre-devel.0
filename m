From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:31:02 -0500
Subject: [lustre-devel] [PATCH 32/35] staging: lustre: mount: fix
	lmd_parse() to handle commas in expr_list
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-33-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jian Yu <jian.yu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jian Yu <jian.yu@intel.com>

The lmd_parse() function parses mount options with comma as
delimiter without considering commas in expr_list as follows
is a valid LNET nid range syntax:

<expr_list>  :== '[' <range_expr> [ ',' <range_expr>] ']'

This patch fixes the above issue by using cfs_parse_nidlist()
to parse nid range list instead of using class_parse_nid_quiet()
to parse only one nid.

Signed-off-by: Jian Yu <jian.yu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5690
Reviewed-on: http://review.whamcloud.com/17036
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   91 ++++++++++++++++++--
 1 files changed, 85 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 2283e92..1eb8e71 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -871,6 +871,87 @@ static int lmd_parse_mgs(struct lustre_mount_data *lmd, char **ptr)
 	return 0;
 }
 
+/**
+ * Find the first comma delimiter from the specified \a buf and make \a *endh
+ * point to the string starting with the comma. The commas in expression list
+ * [...] will be skipped.
+ *
+ * \param[in] buf	a comma-separated string
+ * \param[in] endh	a pointer to a pointer that will point to the string
+ *			starting with the comma
+ *
+ * \retval 0		if comma delimiter is found
+ * \retval 1		if comma delimiter is not found
+ */
+static int lmd_find_comma(char *buf, char **endh)
+{
+	char *c = buf;
+	int skip = 0;
+
+	if (!buf)
+		return 1;
+
+	while (*c != '\0') {
+		if (*c == '[')
+			skip++;
+		else if (*c == ']')
+			skip--;
+
+		if (*c == ',' && !skip) {
+			if (endh)
+				*endh = c;
+			return 0;
+		}
+		c++;
+	}
+	return 1;
+}
+
+/**
+ * Find the first valid string delimited by comma from the specified \a buf
+ # and parse it to see whether it's a valid nid list. If yes, \a *endh will
+ * point to the next string starting with the comma.
+ *
+ * \param[in] buf	a comma-separated string
+ * \param[in] endh	a pointer to a pointer that will point to the string
+ *			starting with the comma
+ *
+ * \retval 0		if the string is a valid nid list
+ * \retval 1		if the string is not a valid nid list
+ */
+static int lmd_parse_nidlist(char *buf, char **endh)
+{
+	struct list_head nidlist;
+	char *endp = buf;
+	int rc = 0;
+	char tmp;
+
+	if (!buf)
+		return 1;
+	while (*buf == ',' || *buf == ':')
+		buf++;
+	if (*buf == ' ' || *buf == '/' || *buf == '\0')
+		return 1;
+
+	if (lmd_find_comma(buf, &endp))
+		endp = buf + strlen(buf);
+
+	tmp = *endp;
+	*endp = '\0';
+
+	INIT_LIST_HEAD(&nidlist);
+	if (cfs_parse_nidlist(buf, strlen(buf), &nidlist) <= 0)
+		rc = 1;
+	cfs_free_nidlist(&nidlist);
+
+	*endp = tmp;
+	if (rc)
+		return rc;
+	if (endh)
+		*endh = endp;
+	return 0;
+}
+
 /** Parse mount line options
  * e.g. mount -v -t lustre -o abort_recov uml1:uml2:/lustre-client /mnt/lustre
  * dev is passed as device=uml1:/lustre by mount.lustre
@@ -987,19 +1068,17 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 			clear++;
 		} else if (strncmp(s1, "param=", 6) == 0) {
 			size_t length, params_length;
-			char *tail = strchr(s1 + 6, ',');
+			char *tail = s1;
 
-			if (!tail) {
+			if (lmd_find_comma(s1 + 6, &tail)) {
 				length = strlen(s1);
 			} else {
-				lnet_nid_t nid;
 				char *param_str = tail + 1;
 				int supplementary = 1;
 
-				while (!class_parse_nid_quiet(param_str, &nid,
-							      &param_str)) {
+				while (!lmd_parse_nidlist(param_str,
+							  &param_str))
 					supplementary = 0;
-				}
 				length = param_str - s1 - supplementary;
 			}
 			length -= 6;
-- 
1.7.1
