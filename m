From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:32 -0400
Subject: [lustre-devel] [PATCH 15/18] lustre: mount: fix lmd_parse() to
 handle new delimiters
In-Reply-To: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573875-20465-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jian Yu <jian.yu@intel.com>

The lmd_parse() function parses mount options with comma as
delimiter without considering commas in expr_list as follows
is a valid LNET nid range syntax:

<expr_list>  :== '[' <range_expr> [ ',' <range_expr>] ']'

This patch fixes the above issue by using cfs_parse_nidlist()
to parse nid range list instead of using class_parse_nid_quiet()
to parse only one nid.

In multi-rail and failover configurations, colon is a valid
delimiter in LNET nid list to separate different hosts.
This patch fixes lmd_parse()->lmd_parse_nidlist() to handle
both comma and colon as delimiters.

Signed-off-by: Jian Yu <jian.yu@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9325
Reviewed-on: https://review.whamcloud.com/26558
WC-bug-id: https://jira.whamcloud.com/browse/LU-8311
Reviewed-on: http://review.whamcloud.com/21329
WC-bug-id: https://jira.whamcloud.com/browse/LU-5690
Reviewed-on: http://review.whamcloud.com/17036
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 112 +++++++++++++++++++--
 1 file changed, 104 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 6e9803b..708c580 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -889,6 +889,104 @@ static int lmd_parse_mgs(struct lustre_mount_data *lmd, char **ptr)
 	return 0;
 }
 
+/**
+ * Find the first delimiter (comma or colon) from the specified \a buf and
+ * make \a *endh point to the string starting with the delimiter. The commas
+ * in expression list [...] will be skipped.
+ *
+ * @buf		a delimiter-separated string
+ * @endh	a pointer to a pointer that will point to the string
+ *		starting with the delimiter
+ *
+ * RETURNS	true if delimiter is found, false if delimiter is not found
+ */
+static bool lmd_find_delimiter(char *buf, char **endh)
+{
+	char *c = buf;
+	size_t pos;
+	bool found;
+
+	if (!buf)
+		return false;
+try_again:
+	if (*c == ',' || *c == ':')
+		return true;
+
+	pos = strcspn(c, "[:,]");
+	if (!pos)
+		return false;
+
+	/* Not a valid mount string */
+	if (*c == ']') {
+		CWARN("invalid mount string format\n");
+		return false;
+	}
+
+	c += pos;
+	if (*c == '[') {
+		c = strchr(c, ']');
+
+		/* invalid mount string */
+		if (!c) {
+			CWARN("invalid mount string format\n");
+			return false;
+		}
+		c++;
+		goto try_again;
+	}
+
+	found = *c != '\0';
+	if (found && endh)
+		*endh = c;
+
+	return found;
+}
+
+/**
+ * Find the first valid string delimited by comma or colon from the specified
+ * \a buf and parse it to see whether it's a valid nid list. If yes, \a *endh
+ * will point to the next string starting with the delimiter.
+ *
+ * \param[in] buf	a delimiter-separated string
+ * \param[in] endh	a pointer to a pointer that will point to the string
+ *			starting with the delimiter
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
+	if (!lmd_find_delimiter(buf, &endp))
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
@@ -1006,20 +1104,18 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 			clear++;
 		} else if (strncmp(s1, "param=", 6) == 0) {
 			size_t length, params_length;
-			char *tail = strchr(s1 + 6, ',');
+			char *tail = s1;
 
-			if (!tail) {
-				length = strlen(s1);
-			} else {
-				lnet_nid_t nid;
+			if (lmd_find_delimiter(s1 + 6, &tail)) {
 				char *param_str = tail + 1;
 				int supplementary = 1;
 
-				while (!class_parse_nid_quiet(param_str, &nid,
-							      &param_str)) {
+				while (!lmd_parse_nidlist(param_str,
+							  &param_str))
 					supplementary = 0;
-				}
 				length = param_str - s1 - supplementary;
+			} else {
+				length = strlen(s1);
 			}
 			length -= 6;
 			params_length = strlen(lmd->lmd_params);
-- 
1.8.3.1
