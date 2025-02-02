Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E4CFCC0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 21:13:19 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMKC5fhYz228J;
	Sun, 02 Feb 2025 12:53:03 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMFp5yWVz213T
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:50:06 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1B3C2881AA1;
 Sun,  2 Feb 2025 15:46:42 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 17E92106BE18; Sun,  2 Feb 2025 15:46:42 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:30 -0500
Message-ID: <20250202204633.1148872-31-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 30/33] lnet: libcfs: move cfs_expr_list_print
 to nidstrings.c
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

cfs_expr_list_print() is only called from nidstrings.c
so move it there and make it static.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9859
Lustre-commit: 531d7b630e962a33f ("LU-9859 libcfs: move cfs_expr_list_print to nidstrings.c")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50834
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/libcfs/libcfs_string.h |  2 -
 net/lnet/libcfs/libcfs_string.c      | 68 ----------------------------
 net/lnet/lnet/nidstrings.c           | 68 ++++++++++++++++++++++++++++
 3 files changed, 68 insertions(+), 70 deletions(-)

diff --git a/include/linux/libcfs/libcfs_string.h b/include/linux/libcfs/libcfs_string.h
index a8bd44dc33d9..7673a2fecf7e 100644
--- a/include/linux/libcfs/libcfs_string.h
+++ b/include/linux/libcfs/libcfs_string.h
@@ -79,8 +79,6 @@ int cfs_gettok(struct cfs_lstr *next, char delim, struct cfs_lstr *res);
 int cfs_str2num_check(char *str, int nob, unsigned int *num,
 		      unsigned int min, unsigned int max);
 int cfs_expr_list_match(u32 value, struct cfs_expr_list *expr_list);
-int cfs_expr_list_print(char *buffer, int count,
-			struct cfs_expr_list *expr_list);
 int cfs_expr_list_values(struct cfs_expr_list *expr_list,
 			 int max, u32 **values);
 void cfs_expr_list_free(struct cfs_expr_list *expr_list);
diff --git a/net/lnet/libcfs/libcfs_string.c b/net/lnet/libcfs/libcfs_string.c
index 672b8591c50f..811b16d0f48d 100644
--- a/net/lnet/libcfs/libcfs_string.c
+++ b/net/lnet/libcfs/libcfs_string.c
@@ -305,74 +305,6 @@ cfs_range_expr_parse(struct cfs_lstr *src, unsigned int min, unsigned int max,
 	return -EINVAL;
 }
 
-/**
- * Print the range expression @expr into specified @buffer.
- * If @bracketed is true, expression does not need additional
- * brackets.
- *
- * Return:	number of characters written
- */
-static int
-cfs_range_expr_print(char *buffer, int count, struct cfs_range_expr *expr,
-		     bool bracketed)
-{
-	int i;
-	char s[] = "[";
-	char e[] = "]";
-
-	if (bracketed) {
-		s[0] = '\0';
-		e[0] = '\0';
-	}
-
-	if (expr->re_lo == expr->re_hi)
-		i = scnprintf(buffer, count, "%u", expr->re_lo);
-	else if (expr->re_stride == 1)
-		i = scnprintf(buffer, count, "%s%u-%u%s",
-			      s, expr->re_lo, expr->re_hi, e);
-	else
-		i = scnprintf(buffer, count, "%s%u-%u/%u%s",
-			      s, expr->re_lo, expr->re_hi, expr->re_stride, e);
-	return i;
-}
-
-/**
- * Print a list of range expressions (@expr_list) into specified @buffer.
- * If the list contains several expressions, separate them with comma
- * and surround the list with brackets.
- *
- * Return:	number of characters written
- */
-int
-cfs_expr_list_print(char *buffer, int count, struct cfs_expr_list *expr_list)
-{
-	struct cfs_range_expr *expr;
-	int i = 0, j = 0;
-	int numexprs = 0;
-
-	if (count <= 0)
-		return 0;
-
-	list_for_each_entry(expr, &expr_list->el_exprs, re_link)
-		numexprs++;
-
-	if (numexprs > 1)
-		i += scnprintf(buffer + i, count - i, "[");
-
-	list_for_each_entry(expr, &expr_list->el_exprs, re_link) {
-		if (j++)
-			i += scnprintf(buffer + i, count - i, ",");
-		i += cfs_range_expr_print(buffer + i, count - i, expr,
-					  numexprs > 1);
-	}
-
-	if (numexprs > 1)
-		i += scnprintf(buffer + i, count - i, "]");
-
-	return i;
-}
-EXPORT_SYMBOL(cfs_expr_list_print);
-
 /**
  * Matches value (@value) against ranges expression list @expr_list.
  *
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index 05a9b3275624..893eaa4c48ef 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -591,6 +591,74 @@ cfs_ip_addr_parse(char *str, int len, struct list_head *list)
 	return rc;
 }
 
+/**
+ * Print the range expression @expr into specified @buffer.
+ * If @bracketed is true, expression does not need additional
+ * brackets.
+ *
+ * Return	number of characters written
+ */
+static int
+cfs_range_expr_print(char *buffer, int count, struct cfs_range_expr *expr,
+		     bool bracketed)
+{
+	int i;
+	char s[] = "[";
+	char e[] = "]";
+
+	if (bracketed) {
+		s[0] = '\0';
+		e[0] = '\0';
+	}
+
+	if (expr->re_lo == expr->re_hi)
+		i = scnprintf(buffer, count, "%u", expr->re_lo);
+	else if (expr->re_stride == 1)
+		i = scnprintf(buffer, count, "%s%u-%u%s",
+			      s, expr->re_lo, expr->re_hi, e);
+	else
+		i = scnprintf(buffer, count, "%s%u-%u/%u%s",
+			      s, expr->re_lo, expr->re_hi,
+			      expr->re_stride, e);
+	return i;
+}
+
+/**
+ * Print a list of range expressions (\a expr_list) into specified \a buffer.
+ * If the list contains several expressions, separate them with comma
+ * and surround the list with brackets.
+ *
+ * Return	number of characters written
+ */
+static int
+cfs_expr_list_print(char *buffer, int count, struct cfs_expr_list *expr_list)
+{
+	struct cfs_range_expr *expr;
+	int i = 0, j = 0;
+	int numexprs = 0;
+
+	if (count <= 0)
+		return 0;
+
+	list_for_each_entry(expr, &expr_list->el_exprs, re_link)
+		numexprs++;
+
+	if (numexprs > 1)
+		i += scnprintf(buffer + i, count - i, "[");
+
+	list_for_each_entry(expr, &expr_list->el_exprs, re_link) {
+		if (j++ != 0)
+			i += scnprintf(buffer + i, count - i, ",");
+		i += cfs_range_expr_print(buffer + i, count - i, expr,
+					  numexprs > 1);
+	}
+
+	if (numexprs > 1)
+		i += scnprintf(buffer + i, count - i, "]");
+
+	return i;
+}
+
 static int
 libcfs_ip_addr_range_print(char *buffer, int count, struct list_head *list)
 {
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
