Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3D9A5C36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:38:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2vX0Rx5z210K;
	Fri, 21 Mar 2025 06:13:44 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2nW0FCwz1y69
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:08:30 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 98E2889123E;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 96FBE106BE18; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:07:03 -0400
Message-ID: <20250321130711.3257092-21-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 20/27] lustre: llite: simplify parsing in
 pcc_conds_parse()
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
Cc: Feng Lei <flei@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

If we duplicate the string to be parsed we can use standard parsing
tools like strsep() and strcmp().

WC-bug-id: https://jira.whamcloud.com/browse/LU-9859
Lustre-commit: d6136c5df6267712f ("LU-9859 llite: simplify parsing in pcc_conds_parse()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50839
Reviewed-by: Feng Lei <flei@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/pcc.c | 131 ++++++++++++++++++------------------------
 1 file changed, 55 insertions(+), 76 deletions(-)

diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index 677f5f38f100..a95d92404326 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -205,9 +205,9 @@ static void pcc_cmd_fini(struct pcc_cmd *cmd)
 	}
 }
 
-#define PCC_DISJUNCTION_DELIM	(',')
-#define PCC_CONJUNCTION_DELIM	('&')
-#define PCC_EXPRESSION_DELIM	('=')
+#define PCC_DISJUNCTION_DELIM	(",")
+#define PCC_CONJUNCTION_DELIM	("&")
+#define PCC_EXPRESSION_DELIM	("=")
 
 static int
 pcc_fname_list_add(struct cfs_lstr *id, struct list_head *fname_list)
@@ -255,34 +255,27 @@ pcc_fname_list_parse(char *str, int len, struct list_head *fname_list)
 }
 
 static int
-pcc_id_list_parse(char *str, int len, struct list_head *id_list,
+pcc_id_list_parse(char *str, struct list_head *id_list,
 		  enum pcc_field type)
 {
-	struct cfs_lstr src;
-	struct cfs_lstr res;
 	int rc = 0;
 
 	if (type != PCC_FIELD_UID && type != PCC_FIELD_GID &&
 	    type != PCC_FIELD_PROJID)
 		return -EINVAL;
 
-	src.ls_str = str;
-	src.ls_len = len;
 	INIT_LIST_HEAD(id_list);
-	while (src.ls_str) {
+	while (str) {
+		char *num;
 		struct pcc_match_id *id;
-		u32 id_val;
+		unsigned long id_val;
 
-		if (cfs_gettok(&src, ' ', &res) == 0) {
-			rc = -EINVAL;
-			goto out;
-		}
-
-		if (!cfs_str2num_check(res.ls_str, res.ls_len,
-				       &id_val, 0, (u32)~0U)) {
-			rc = -EINVAL;
+		num = strsep(&str, " ");
+		if (!*num)
+			continue;
+		rc = kstrtoul(num, 0, &id_val);
+		if (rc)
 			goto out;
-		}
 
 		id = kzalloc(sizeof(*id), GFP_KERNEL);
 		if (!id) {
@@ -293,73 +286,70 @@ pcc_id_list_parse(char *str, int len, struct list_head *id_list,
 		id->pmi_id = id_val;
 		list_add_tail(&id->pmi_linkage, id_list);
 	}
+	if (list_empty(id_list))
+		rc = -EINVAL;
 out:
 	if (rc)
 		pcc_id_list_free(id_list);
 	return rc;
 }
 
-static inline bool
-pcc_check_field(struct cfs_lstr *field, char *str)
-{
-	int len = strlen(str);
-
-	return (field->ls_len == len &&
-		strncmp(field->ls_str, str, len) == 0);
-}
-
 static int
-pcc_expression_parse(struct cfs_lstr *src, struct list_head *cond_list)
+pcc_expression_parse(char *str, struct list_head *cond_list)
 {
 	struct pcc_expression *expr;
-	struct cfs_lstr field;
+	char *field;
+	int len;
 	int rc = 0;
 
 	expr = kzalloc(sizeof(*expr), GFP_KERNEL);
 	if (!expr)
 		return -ENOMEM;
 
-	rc = cfs_gettok(src, PCC_EXPRESSION_DELIM, &field);
-	if (rc == 0 || src->ls_len <= 2 || src->ls_str[0] != '{' ||
-	    src->ls_str[src->ls_len - 1] != '}') {
+	field = strim(strsep(&str, PCC_EXPRESSION_DELIM));
+	if (!*field || !str) {
+		/* No LHS or no '=' */
+		rc = -EINVAL;
+		goto out;
+	}
+	str = skip_spaces(str);
+	len = strlen(str);
+	if (str[0] != '{' || str[len - 1] != '}') {
 		rc = -EINVAL;
 		goto out;
 	}
 
 	/* Skip '{' and '}' */
-	src->ls_str++;
-	src->ls_len -= 2;
+	str[len - 1] = '\0';
+	str += 1;
+	len -= 2;
 
-	if (pcc_check_field(&field, "uid")) {
-		if (pcc_id_list_parse(src->ls_str,
-				      src->ls_len,
+	if (strcmp(field, "uid") == 0) {
+		if (pcc_id_list_parse(str,
 				      &expr->pe_cond,
 				      PCC_FIELD_UID) < 0) {
 			rc = -EINVAL;
 			goto out;
 		}
 		expr->pe_field = PCC_FIELD_UID;
-	} else if (pcc_check_field(&field, "gid")) {
-		if (pcc_id_list_parse(src->ls_str,
-				      src->ls_len,
+	} else if (strcmp(field, "gid") == 0) {
+		if (pcc_id_list_parse(str,
 				      &expr->pe_cond,
 				      PCC_FIELD_GID) < 0) {
 			rc = -EINVAL;
 			goto out;
 		}
 		expr->pe_field = PCC_FIELD_GID;
-	} else if (pcc_check_field(&field, "projid")) {
-		if (pcc_id_list_parse(src->ls_str,
-				      src->ls_len,
+	} else if (strcmp(field, "projid") == 0) {
+		if (pcc_id_list_parse(str,
 				      &expr->pe_cond,
 				      PCC_FIELD_PROJID) < 0) {
 			rc = -EINVAL;
 			goto out;
 		}
 		expr->pe_field = PCC_FIELD_PROJID;
-	} else if (pcc_check_field(&field, "fname")) {
-		if (pcc_fname_list_parse(src->ls_str,
-					 src->ls_len,
+	} else if (strcmp(field, "fname") == 0) {
+		if (pcc_fname_list_parse(str, len,
 					 &expr->pe_cond) < 0) {
 			rc = -EINVAL;
 			goto out;
@@ -378,10 +368,9 @@ pcc_expression_parse(struct cfs_lstr *src, struct list_head *cond_list)
 }
 
 static int
-pcc_conjunction_parse(struct cfs_lstr *src, struct list_head *cond_list)
+pcc_conjunction_parse(char *str, struct list_head *cond_list)
 {
 	struct pcc_conjunction *conjunction;
-	struct cfs_lstr expr;
 	int rc = 0;
 
 	conjunction = kzalloc(sizeof(*conjunction), GFP_KERNEL);
@@ -391,39 +380,31 @@ pcc_conjunction_parse(struct cfs_lstr *src, struct list_head *cond_list)
 	INIT_LIST_HEAD(&conjunction->pc_expressions);
 	list_add_tail(&conjunction->pc_linkage, cond_list);
 
-	while (src->ls_str) {
-		rc = cfs_gettok(src, PCC_CONJUNCTION_DELIM, &expr);
-		if (rc == 0) {
-			rc = -EINVAL;
-			break;
-		}
-		rc = pcc_expression_parse(&expr,
-					  &conjunction->pc_expressions);
-		if (rc)
-			break;
+	while (rc == 0 && str) {
+		char *expr = strsep(&str, PCC_CONJUNCTION_DELIM);
+
+		rc = pcc_expression_parse(expr, &conjunction->pc_expressions);
 	}
 	return rc;
 }
 
-static int pcc_conds_parse(char *str, int len, struct list_head *cond_list)
+static int pcc_conds_parse(char *orig, struct list_head *cond_list)
 {
-	struct cfs_lstr src;
-	struct cfs_lstr res;
+	char *str;
 	int rc = 0;
 
-	src.ls_str = str;
-	src.ls_len = len;
+	orig = kstrdup(orig, GFP_KERNEL);
+	if (!orig)
+		return -ENOMEM;
+	str = orig;
+
 	INIT_LIST_HEAD(cond_list);
-	while (src.ls_str) {
-		rc = cfs_gettok(&src, PCC_DISJUNCTION_DELIM, &res);
-		if (rc == 0) {
-			rc = -EINVAL;
-			break;
-		}
-		rc = pcc_conjunction_parse(&res, cond_list);
-		if (rc)
-			break;
+	while (rc == 0 && str) {
+		char *term = strsep(&str, PCC_DISJUNCTION_DELIM);
+
+		rc = pcc_conjunction_parse(term, cond_list);
 	}
+	kfree(orig);
 	return rc;
 }
 
@@ -438,7 +419,6 @@ static int pcc_id_parse(struct pcc_cmd *cmd, const char *id)
 	memcpy(cmd->u.pccc_add.pccc_conds_str, id, strlen(id));
 
 	rc = pcc_conds_parse(cmd->u.pccc_add.pccc_conds_str,
-			     strlen(cmd->u.pccc_add.pccc_conds_str),
 			     &cmd->u.pccc_add.pccc_conds);
 	if (rc)
 		pcc_cmd_fini(cmd);
@@ -598,8 +578,7 @@ pcc_dataset_rule_init(struct pcc_match_rule *rule, struct pcc_cmd *cmd)
 	INIT_LIST_HEAD(&rule->pmr_conds);
 	if (!list_empty(&cmd->u.pccc_add.pccc_conds))
 		rc = pcc_conds_parse(rule->pmr_conds_str,
-					  strlen(rule->pmr_conds_str),
-					  &rule->pmr_conds);
+				     &rule->pmr_conds);
 
 	if (rc)
 		pcc_dataset_rule_fini(rule);
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
