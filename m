From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:13:49 -0500
Subject: [lustre-devel] [PATCH 361/622] lustre: llite: Rule based auto PCC
 caching when create files
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-362-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Qian Yingjin <qian@ddn.com>

Configurable rule based auto PCC caching for newly created files
can significantly benefit users for readwrite PCC. It can
determine which file can use a cache on PCC directly without any
admission control for high priority user/group/project or filename
with wildcard support. Meanwhile, we can enforce a quota limitation
of capacity usage for each user/group/project to providing caching
isolation.

Similar to NRS TBF command line, it supports logical conditional
conjunction and disjunction operations among different user/group/
project or filename with the wildcard support.

The command line to add this kind of rule is as follow:
lctl pcc add /mnt/lustre /mnt/pcc
        "projid={500 1000}&fname={*.h5},uid={1001} rwid=1 roid=1"
It means that Project ID of 500, 1000 AND file suffix name is "h5"
OR User ID is 1001 can be auto cached on PCC for newly create file
on the client. "rwid" means RW-PCC attach ID (which is
usually archive ID); "roid" means RO-PCC attach ID. By default,
RO-PCC attach id is setting same with RW-PCC attach ID for a
shared PCC backend.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10918
Lustre-commit: 4fbae1352947 ("LU-10918 llite: Rule based auto PCC caching when create files")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/34751
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/namei.c |  13 +-
 fs/lustre/llite/pcc.c   | 637 ++++++++++++++++++++++++++++++++++++++++++++----
 fs/lustre/llite/pcc.h   |  67 ++++-
 3 files changed, 659 insertions(+), 58 deletions(-)

diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 10c0cef..49433c9 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -826,7 +826,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 		lum->lmm_pattern = LOV_PATTERN_F_RELEASED | LOV_PATTERN_RAID0;
 		op_data->op_data = lum;
 		op_data->op_data_size = sizeof(*lum);
-		op_data->op_archive_id = dataset->pccd_id;
+		op_data->op_archive_id = dataset->pccd_rwid;
 
 		rc = obd_fid_alloc(NULL, ll_i2mdexp(parent), &op_data->op_fid2,
 				   op_data);
@@ -1002,9 +1002,14 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 		/* Volatile file is used for HSM restore, so do not use PCC */
 		if (!filename_is_volatile(dentry->d_name.name,
 					  dentry->d_name.len, NULL)) {
-			dataset = pcc_dataset_get(&sbi->ll_pcc_super,
-						  ll_i2info(dir)->lli_projid,
-						  0);
+			struct pcc_matcher item;
+
+			item.pm_uid = from_kuid(&init_user_ns, current_uid());
+			item.pm_gid = from_kgid(&init_user_ns, current_gid());
+			item.pm_projid = ll_i2info(dir)->lli_projid;
+			item.pm_name = &dentry->d_name;
+			dataset = pcc_dataset_match_get(&sbi->ll_pcc_super,
+							&item);
 			pca.pca_dataset = dataset;
 		}
 	}
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index fa81b55..469ff6c 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -109,6 +109,7 @@
 #include <linux/namei.h>
 #include <linux/file.h>
 #include <linux/mount.h>
+#include <linux/libcfs/libcfs_string.h>
 #include "llite_internal.h"
 
 struct kmem_cache *pcc_inode_slab;
@@ -129,23 +130,550 @@ int pcc_super_init(struct pcc_super *super)
 	return 0;
 }
 
+/* Rule based auto caching */
+static void pcc_id_list_free(struct list_head *id_list)
+{
+	struct pcc_match_id *id, *n;
+
+	list_for_each_entry_safe(id, n, id_list, pmi_linkage) {
+		list_del_init(&id->pmi_linkage);
+		kfree(id);
+	}
+}
+
+static void pcc_fname_list_free(struct list_head *fname_list)
+{
+	struct pcc_match_fname *fname, *n;
+
+	list_for_each_entry_safe(fname, n, fname_list, pmf_linkage) {
+		kfree(fname->pmf_name);
+		list_del_init(&fname->pmf_linkage);
+		kfree(fname);
+	}
+}
+
+static void pcc_expression_free(struct pcc_expression *expr)
+{
+	LASSERT(expr->pe_field >= PCC_FIELD_UID &&
+		expr->pe_field < PCC_FIELD_MAX);
+	switch (expr->pe_field) {
+	case PCC_FIELD_UID:
+	case PCC_FIELD_GID:
+	case PCC_FIELD_PROJID:
+		pcc_id_list_free(&expr->pe_cond);
+		break;
+	case PCC_FIELD_FNAME:
+		pcc_fname_list_free(&expr->pe_cond);
+		break;
+	default:
+		LBUG();
+	}
+	kfree(expr);
+}
+
+static void pcc_conjunction_free(struct pcc_conjunction *conjunction)
+{
+	struct pcc_expression *expression, *n;
+
+	LASSERT(list_empty(&conjunction->pc_linkage));
+	list_for_each_entry_safe(expression, n,
+				 &conjunction->pc_expressions,
+				 pe_linkage) {
+		list_del_init(&expression->pe_linkage);
+		pcc_expression_free(expression);
+	}
+	kfree(conjunction);
+}
+
+static void pcc_rule_conds_free(struct list_head *cond_list)
+{
+	struct pcc_conjunction *conjunction, *n;
+
+	list_for_each_entry_safe(conjunction, n, cond_list, pc_linkage) {
+		list_del_init(&conjunction->pc_linkage);
+		pcc_conjunction_free(conjunction);
+	}
+}
+
+static void pcc_cmd_fini(struct pcc_cmd *cmd)
+{
+	if (cmd->pccc_cmd == PCC_ADD_DATASET) {
+		if (!list_empty(&cmd->u.pccc_add.pccc_conds))
+			pcc_rule_conds_free(&cmd->u.pccc_add.pccc_conds);
+		kfree(cmd->u.pccc_add.pccc_conds_str);
+	}
+}
+
+#define PCC_DISJUNCTION_DELIM	(',')
+#define PCC_CONJUNCTION_DELIM	('&')
+#define PCC_EXPRESSION_DELIM	('=')
+
+static int
+pcc_fname_list_add(struct cfs_lstr *id, struct list_head *fname_list)
+{
+	struct pcc_match_fname *fname;
+
+	fname = kzalloc(sizeof(*fname), GFP_KERNEL);
+	if (!fname)
+		return -ENOMEM;
+
+	fname->pmf_name = kzalloc(id->ls_len + 1, GFP_KERNEL);
+	if (!fname->pmf_name) {
+		kfree(fname);
+		return -ENOMEM;
+	}
+
+	memcpy(fname->pmf_name, id->ls_str, id->ls_len);
+	list_add_tail(&fname->pmf_linkage, fname_list);
+	return 0;
+}
+
+static int
+pcc_fname_list_parse(char *str, int len, struct list_head *fname_list)
+{
+	struct cfs_lstr src;
+	struct cfs_lstr res;
+	int rc = 0;
+
+	src.ls_str = str;
+	src.ls_len = len;
+	INIT_LIST_HEAD(fname_list);
+	while (src.ls_str) {
+		rc = cfs_gettok(&src, ' ', &res);
+		if (rc == 0) {
+			rc = -EINVAL;
+			break;
+		}
+		rc = pcc_fname_list_add(&res, fname_list);
+		if (rc)
+			break;
+	}
+	if (rc)
+		pcc_fname_list_free(fname_list);
+	return rc;
+}
+
+static int
+pcc_id_list_parse(char *str, int len, struct list_head *id_list,
+		  enum pcc_field type)
+{
+	struct cfs_lstr src;
+	struct cfs_lstr res;
+	int rc = 0;
+
+	if (type != PCC_FIELD_UID && type != PCC_FIELD_GID &&
+	    type != PCC_FIELD_PROJID)
+		return -EINVAL;
+
+	src.ls_str = str;
+	src.ls_len = len;
+	INIT_LIST_HEAD(id_list);
+	while (src.ls_str) {
+		struct pcc_match_id *id;
+		u32 id_val;
+
+		if (cfs_gettok(&src, ' ', &res) == 0) {
+			rc = -EINVAL;
+			goto out;
+		}
+
+		if (!cfs_str2num_check(res.ls_str, res.ls_len,
+				       &id_val, 0, (u32)~0U)) {
+			rc = -EINVAL;
+			goto out;
+		}
+
+		id = kzalloc(sizeof(*id), GFP_KERNEL);
+		if (!id) {
+			rc = -ENOMEM;
+			goto out;
+		}
+
+		id->pmi_id = id_val;
+		list_add_tail(&id->pmi_linkage, id_list);
+	}
+out:
+	if (rc)
+		pcc_id_list_free(id_list);
+	return rc;
+}
+
+static inline bool
+pcc_check_field(struct cfs_lstr *field, char *str)
+{
+	int len = strlen(str);
+
+	return (field->ls_len == len &&
+		strncmp(field->ls_str, str, len) == 0);
+}
+
+static int
+pcc_expression_parse(struct cfs_lstr *src, struct list_head *cond_list)
+{
+	struct pcc_expression *expr;
+	struct cfs_lstr field;
+	int rc = 0;
+
+	expr = kzalloc(sizeof(*expr), GFP_KERNEL);
+	if (!expr)
+		return -ENOMEM;
+
+	rc = cfs_gettok(src, PCC_EXPRESSION_DELIM, &field);
+	if (rc == 0 || src->ls_len <= 2 || src->ls_str[0] != '{' ||
+	    src->ls_str[src->ls_len - 1] != '}') {
+		rc = -EINVAL;
+		goto out;
+	}
+
+	/* Skip '{' and '}' */
+	src->ls_str++;
+	src->ls_len -= 2;
+
+	if (pcc_check_field(&field, "uid")) {
+		if (pcc_id_list_parse(src->ls_str,
+				      src->ls_len,
+				      &expr->pe_cond,
+				      PCC_FIELD_UID) < 0) {
+			rc = -EINVAL;
+			goto out;
+		}
+		expr->pe_field = PCC_FIELD_UID;
+	} else if (pcc_check_field(&field, "gid")) {
+		if (pcc_id_list_parse(src->ls_str,
+				      src->ls_len,
+				      &expr->pe_cond,
+				      PCC_FIELD_GID) < 0) {
+			rc = -EINVAL;
+			goto out;
+		}
+		expr->pe_field = PCC_FIELD_GID;
+	} else if (pcc_check_field(&field, "projid")) {
+		if (pcc_id_list_parse(src->ls_str,
+				      src->ls_len,
+				      &expr->pe_cond,
+				      PCC_FIELD_PROJID) < 0) {
+			rc = -EINVAL;
+			goto out;
+		}
+		expr->pe_field = PCC_FIELD_PROJID;
+	} else if (pcc_check_field(&field, "fname")) {
+		if (pcc_fname_list_parse(src->ls_str,
+					 src->ls_len,
+					 &expr->pe_cond) < 0) {
+			rc = -EINVAL;
+			goto out;
+		}
+		expr->pe_field = PCC_FIELD_FNAME;
+	} else {
+		rc = -EINVAL;
+		goto out;
+	}
+
+	list_add_tail(&expr->pe_linkage, cond_list);
+	return 0;
+out:
+	kfree(expr);
+	return rc;
+}
+
+static int
+pcc_conjunction_parse(struct cfs_lstr *src, struct list_head *cond_list)
+{
+	struct pcc_conjunction *conjunction;
+	struct cfs_lstr expr;
+	int rc = 0;
+
+	conjunction = kzalloc(sizeof(*conjunction), GFP_KERNEL);
+	if (!conjunction)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&conjunction->pc_expressions);
+	list_add_tail(&conjunction->pc_linkage, cond_list);
+
+	while (src->ls_str) {
+		rc = cfs_gettok(src, PCC_CONJUNCTION_DELIM, &expr);
+		if (rc == 0) {
+			rc = -EINVAL;
+			break;
+		}
+		rc = pcc_expression_parse(&expr,
+					  &conjunction->pc_expressions);
+		if (rc)
+			break;
+	}
+	return rc;
+}
+
+static int pcc_conds_parse(char *str, int len, struct list_head *cond_list)
+{
+	struct cfs_lstr src;
+	struct cfs_lstr res;
+	int rc = 0;
+
+	src.ls_str = str;
+	src.ls_len = len;
+	INIT_LIST_HEAD(cond_list);
+	while (src.ls_str) {
+		rc = cfs_gettok(&src, PCC_DISJUNCTION_DELIM, &res);
+		if (rc == 0) {
+			rc = -EINVAL;
+			break;
+		}
+		rc = pcc_conjunction_parse(&res, cond_list);
+		if (rc)
+			break;
+	}
+	return rc;
+}
+
+static int pcc_id_parse(struct pcc_cmd *cmd, const char *id)
+{
+	int rc;
+
+	cmd->u.pccc_add.pccc_conds_str = kzalloc(strlen(id) + 1, GFP_KERNEL);
+	if (!cmd->u.pccc_add.pccc_conds_str)
+		return -ENOMEM;
+
+	memcpy(cmd->u.pccc_add.pccc_conds_str, id, strlen(id));
+
+	rc = pcc_conds_parse(cmd->u.pccc_add.pccc_conds_str,
+			     strlen(cmd->u.pccc_add.pccc_conds_str),
+			     &cmd->u.pccc_add.pccc_conds);
+	if (rc)
+		pcc_cmd_fini(cmd);
+
+	return rc;
+}
+
+static int
+pcc_parse_value_pair(struct pcc_cmd *cmd, char *buffer)
+{
+	char *key, *val;
+	unsigned long id;
+	int rc;
+
+	val = buffer;
+	key = strsep(&val, "=");
+	if (!val || strlen(val) == 0)
+		return -EINVAL;
+
+	/* Key of the value pair */
+	if (strcmp(key, "rwid") == 0) {
+		rc = kstrtoul(val, 10, &id);
+		if (rc)
+			return rc;
+		if (id <= 0)
+			return -EINVAL;
+		cmd->u.pccc_add.pccc_rwid = id;
+	} else if (strcmp(key, "roid") == 0) {
+		rc = kstrtoul(val, 10, &id);
+		if (rc)
+			return rc;
+		if (id <= 0)
+			return -EINVAL;
+		cmd->u.pccc_add.pccc_roid = id;
+	} else {
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int
+pcc_parse_value_pairs(struct pcc_cmd *cmd, char *buffer)
+{
+	char *val;
+	char *token;
+	int rc;
+
+	val = buffer;
+	while (val && strlen(val) != 0) {
+		token = strsep(&val, " ");
+		rc = pcc_parse_value_pair(cmd, token);
+		if (rc)
+			return rc;
+	}
+
+	return 0;
+}
+
+static void
+pcc_dataset_rule_fini(struct pcc_match_rule *rule)
+{
+	if (!list_empty(&rule->pmr_conds))
+		pcc_rule_conds_free(&rule->pmr_conds);
+	LASSERT(rule->pmr_conds_str);
+	kfree(rule->pmr_conds_str);
+}
+
+static int
+pcc_dataset_rule_init(struct pcc_match_rule *rule, struct pcc_cmd *cmd)
+{
+	int rc = 0;
+
+	LASSERT(cmd->u.pccc_add.pccc_conds_str);
+	rule->pmr_conds_str = kzalloc(
+		strlen(cmd->u.pccc_add.pccc_conds_str) + 1,
+		GFP_KERNEL);
+	if (!rule->pmr_conds_str)
+		return -ENOMEM;
+
+	memcpy(rule->pmr_conds_str,
+	       cmd->u.pccc_add.pccc_conds_str,
+	       strlen(cmd->u.pccc_add.pccc_conds_str));
+
+	INIT_LIST_HEAD(&rule->pmr_conds);
+	if (!list_empty(&cmd->u.pccc_add.pccc_conds))
+		rc = pcc_conds_parse(rule->pmr_conds_str,
+					  strlen(rule->pmr_conds_str),
+					  &rule->pmr_conds);
+
+	if (rc)
+		pcc_dataset_rule_fini(rule);
+
+	return rc;
+}
+
+/* Rule Matching */
+static int
+pcc_id_list_match(struct list_head *id_list, u32 id_val)
+{
+	struct pcc_match_id *id;
+
+	list_for_each_entry(id, id_list, pmi_linkage) {
+		if (id->pmi_id == id_val)
+			return 1;
+	}
+	return 0;
+}
+
+static bool
+cfs_match_wildcard(const char *pattern, const char *content)
+{
+	if (*pattern == '\0' && *content == '\0')
+		return true;
+
+	if (*pattern == '*' && *(pattern + 1) != '\0' && *content == '\0')
+		return false;
+
+	while (*pattern == *content) {
+		pattern++;
+		content++;
+		if (*pattern == '\0' && *content == '\0')
+			return true;
+
+		if (*pattern == '*' && *(pattern + 1) != '\0' &&
+		    *content == '\0')
+			return false;
+	}
+
+	if (*pattern == '*')
+		return (cfs_match_wildcard(pattern + 1, content) ||
+			cfs_match_wildcard(pattern, content + 1));
+
+	return false;
+}
+
+static int
+pcc_fname_list_match(struct list_head *fname_list, const char *name)
+{
+	struct pcc_match_fname *fname;
+
+	list_for_each_entry(fname, fname_list, pmf_linkage) {
+		if (cfs_match_wildcard(fname->pmf_name, name))
+			return 1;
+	}
+	return 0;
+}
+
+static int
+pcc_expression_match(struct pcc_expression *expr, struct pcc_matcher *matcher)
+{
+	switch (expr->pe_field) {
+	case PCC_FIELD_UID:
+		return pcc_id_list_match(&expr->pe_cond, matcher->pm_uid);
+	case PCC_FIELD_GID:
+		return pcc_id_list_match(&expr->pe_cond, matcher->pm_gid);
+	case PCC_FIELD_PROJID:
+		return pcc_id_list_match(&expr->pe_cond, matcher->pm_projid);
+	case PCC_FIELD_FNAME:
+		return pcc_fname_list_match(&expr->pe_cond,
+					    matcher->pm_name->name);
+	default:
+		return 0;
+	}
+}
+
+static int
+pcc_conjunction_match(struct pcc_conjunction *conjunction,
+		      struct pcc_matcher *matcher)
+{
+	struct pcc_expression *expr;
+	int matched;
+
+	list_for_each_entry(expr, &conjunction->pc_expressions, pe_linkage) {
+		matched = pcc_expression_match(expr, matcher);
+		if (!matched)
+			return 0;
+	}
+
+	return 1;
+}
+
+static int
+pcc_cond_match(struct pcc_match_rule *rule, struct pcc_matcher *matcher)
+{
+	struct pcc_conjunction *conjunction;
+	int matched;
+
+	list_for_each_entry(conjunction, &rule->pmr_conds, pc_linkage) {
+		matched = pcc_conjunction_match(conjunction, matcher);
+		if (matched)
+			return 1;
+	}
+
+	return 0;
+}
+
+struct pcc_dataset*
+pcc_dataset_match_get(struct pcc_super *super, struct pcc_matcher *matcher)
+{
+	struct pcc_dataset *dataset;
+	struct pcc_dataset *selected = NULL;
+
+	spin_lock(&super->pccs_lock);
+	list_for_each_entry(dataset, &super->pccs_datasets, pccd_linkage) {
+		if (pcc_cond_match(&dataset->pccd_rule, matcher)) {
+			atomic_inc(&dataset->pccd_refcount);
+			selected = dataset;
+			break;
+		}
+	}
+	spin_unlock(&super->pccs_lock);
+	if (selected)
+		CDEBUG(D_CACHE, "PCC create, matched %s - %d:%d:%d:%s\n",
+		       dataset->pccd_rule.pmr_conds_str,
+		       matcher->pm_uid, matcher->pm_gid,
+		       matcher->pm_projid, matcher->pm_name->name);
+
+	return selected;
+}
+
 /**
  * pcc_dataset_add - Add a Cache policy to control which files need be
  * cached and where it will be cached.
  *
- * @super: superblock of pcc
- * @pathname: root path of pcc
- * @id: HSM archive ID
- * @projid: files with specified project ID will be cached.
+ * @super:	superblock of pcc
+ * @cmd:	pcc command
  */
 static int
-pcc_dataset_add(struct pcc_super *super, const char *pathname,
-		u32 archive_id, u32 projid)
+pcc_dataset_add(struct pcc_super *super, struct pcc_cmd *cmd)
 {
-	int rc;
+	char *pathname = cmd->pccc_pathname;
 	struct pcc_dataset *dataset;
 	struct pcc_dataset *tmp;
 	bool found = false;
+	int rc;
 
 	dataset = kzalloc(sizeof(*dataset), GFP_NOFS);
 	if (!dataset)
@@ -157,13 +685,23 @@ int pcc_super_init(struct pcc_super *super)
 		return rc;
 	}
 	strncpy(dataset->pccd_pathname, pathname, PATH_MAX);
-	dataset->pccd_id = archive_id;
-	dataset->pccd_projid = projid;
+	dataset->pccd_rwid = cmd->u.pccc_add.pccc_rwid;
+	dataset->pccd_roid = cmd->u.pccc_add.pccc_roid;
 	atomic_set(&dataset->pccd_refcount, 1);
 
+	rc = pcc_dataset_rule_init(&dataset->pccd_rule, cmd);
+	if (rc) {
+		pcc_dataset_put(dataset);
+		return rc;
+	}
+
 	spin_lock(&super->pccs_lock);
 	list_for_each_entry(tmp, &super->pccs_datasets, pccd_linkage) {
-		if (tmp->pccd_id == archive_id) {
+		if (strcmp(tmp->pccd_pathname, pathname) == 0 ||
+		    (dataset->pccd_rwid != 0 &&
+		     dataset->pccd_rwid == tmp->pccd_rwid) ||
+		    (dataset->pccd_roid != 0 &&
+		     dataset->pccd_roid == tmp->pccd_roid)) {
 			found = true;
 			break;
 		}
@@ -181,23 +719,21 @@ int pcc_super_init(struct pcc_super *super)
 }
 
 struct pcc_dataset *
-pcc_dataset_get(struct pcc_super *super, u32 projid, u32 archive_id)
+pcc_dataset_get(struct pcc_super *super, enum lu_pcc_type type, u32 id)
 {
 	struct pcc_dataset *dataset;
 	struct pcc_dataset *selected = NULL;
 
-	if (projid == 0 && archive_id == 0)
+	if (id == 0)
 		return NULL;
 
 	/*
-	 * archive ID is unique in the list, projid might be duplicate,
+	 * archive ID (read-write ID) or read-only ID is unique in the list,
 	 * we just return last added one as first priority.
 	 */
 	spin_lock(&super->pccs_lock);
 	list_for_each_entry(dataset, &super->pccs_datasets, pccd_linkage) {
-		if (projid && dataset->pccd_projid != projid)
-			continue;
-		if (archive_id && dataset->pccd_id != archive_id)
+		if (type == LU_PCC_READWRITE && dataset->pccd_rwid != id)
 			continue;
 		atomic_inc(&dataset->pccd_refcount);
 		selected = dataset;
@@ -205,8 +741,8 @@ struct pcc_dataset *
 	}
 	spin_unlock(&super->pccs_lock);
 	if (selected)
-		CDEBUG(D_CACHE, "matched projid %u, PCC create\n",
-		       selected->pccd_projid);
+		CDEBUG(D_CACHE, "matched id %u, PCC mode %d\n", id, type);
+
 	return selected;
 }
 
@@ -214,6 +750,7 @@ struct pcc_dataset *
 pcc_dataset_put(struct pcc_dataset *dataset)
 {
 	if (atomic_dec_and_test(&dataset->pccd_refcount)) {
+		pcc_dataset_rule_fini(&dataset->pccd_rule);
 		path_put(&dataset->pccd_path);
 		kfree(dataset);
 	}
@@ -244,8 +781,8 @@ struct pcc_dataset *
 pcc_dataset_dump(struct pcc_dataset *dataset, struct seq_file *m)
 {
 	seq_printf(m, "%s:\n", dataset->pccd_pathname);
-	seq_printf(m, "  rwid: %u\n", dataset->pccd_id);
-	seq_printf(m, "  autocache: projid=%u\n", dataset->pccd_projid);
+	seq_printf(m, "  rwid: %u\n", dataset->pccd_rwid);
+	seq_printf(m, "  autocache: %s\n", dataset->pccd_rule.pmr_conds_str);
 }
 
 int
@@ -293,7 +830,6 @@ static bool pathname_is_valid(const char *pathname)
 	static struct pcc_cmd *cmd;
 	char *token;
 	char *val;
-	unsigned long tmp;
 	int rc = 0;
 
 	cmd = kzalloc(sizeof(*cmd), GFP_KERNEL);
@@ -336,38 +872,40 @@ static bool pathname_is_valid(const char *pathname)
 	cmd->pccc_pathname = token;
 
 	if (cmd->pccc_cmd == PCC_ADD_DATASET) {
-		/* archive ID */
-		token = strsep(&val, " ");
+		/* List of ID */
+		LASSERT(val);
+		token = val;
+		val = strrchr(token, '}');
 		if (!val) {
 			rc = -EINVAL;
 			goto out_free_cmd;
 		}
 
-		rc = kstrtoul(token, 10, &tmp);
-		if (rc != 0) {
-			rc = -EINVAL;
-			goto out_free_cmd;
-		}
-		if (tmp == 0) {
+		/* Skip '}' */
+		val++;
+		if (*val == '\0') {
+			val = NULL;
+		} else if (*val == ' ') {
+			*val = '\0';
+			val++;
+		} else {
 			rc = -EINVAL;
 			goto out_free_cmd;
 		}
-		cmd->u.pccc_add.pccc_id = tmp;
 
-		token = val;
-		rc = kstrtoul(token, 10, &tmp);
-		if (rc != 0) {
-			rc = -EINVAL;
+		rc = pcc_id_parse(cmd, token);
+		if (rc)
 			goto out_free_cmd;
-		}
-		if (tmp == 0) {
+
+		rc = pcc_parse_value_pairs(cmd, val);
+		if (rc) {
 			rc = -EINVAL;
-			goto out_free_cmd;
+			goto out_cmd_fini;
 		}
-		cmd->u.pccc_add.pccc_projid = tmp;
 	}
-
 	goto out;
+out_cmd_fini:
+	pcc_cmd_fini(cmd);
 out_free_cmd:
 	kfree(cmd);
 out:
@@ -388,9 +926,7 @@ int pcc_cmd_handle(char *buffer, unsigned long count,
 
 	switch (cmd->pccc_cmd) {
 	case PCC_ADD_DATASET:
-		rc = pcc_dataset_add(super, cmd->pccc_pathname,
-				      cmd->u.pccc_add.pccc_id,
-				      cmd->u.pccc_add.pccc_projid);
+		rc = pcc_dataset_add(super, cmd);
 		break;
 	case PCC_DEL_DATASET:
 		rc = pcc_dataset_del(super, cmd->pccc_pathname);
@@ -403,6 +939,7 @@ int pcc_cmd_handle(char *buffer, unsigned long count,
 		break;
 	}
 
+	pcc_cmd_fini(cmd);
 	kfree(cmd);
 	return rc;
 }
@@ -1025,7 +1562,8 @@ static int pcc_inode_remove(struct pcc_inode *pcci)
 	dentry = pcci->pcci_path.dentry;
 	rc = vfs_unlink(dentry->d_parent->d_inode, dentry, NULL);
 	if (rc)
-		CWARN("failed to unlink cached file, rc = %d\n", rc);
+		CWARN("failed to unlink PCC file %.*s, rc = %d\n",
+		      dentry->d_name.len, dentry->d_name.name, rc);
 
 	return rc;
 }
@@ -1226,7 +1764,10 @@ int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
 		rc2 = vfs_unlink(pcc_dentry->d_parent->d_inode,
 				 pcc_dentry, NULL);
 		if (rc2)
-			CWARN("failed to unlink PCC file, rc = %d\n", rc2);
+			CWARN("%s: failed to unlink PCC file %.*s, rc = %d\n",
+			      ll_i2sbi(inode)->ll_fsname,
+			      pcc_dentry->d_name.len, pcc_dentry->d_name.name,
+			      rc2);
 
 		dput(pcc_dentry);
 	}
@@ -1327,8 +1868,8 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 	if (rc)
 		return rc;
 
-	dataset = pcc_dataset_get(&ll_i2sbi(inode)->ll_pcc_super, 0,
-				  archive_id);
+	dataset = pcc_dataset_get(&ll_i2sbi(inode)->ll_pcc_super,
+				  LU_PCC_READWRITE, archive_id);
 	if (!dataset)
 		return -ENOENT;
 
@@ -1384,7 +1925,9 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 		rc2 = vfs_unlink(dentry->d_parent->d_inode, dentry, NULL);
 		revert_creds(old_cred);
 		if (rc2)
-			CWARN("failed to unlink PCC file, rc = %d\n", rc2);
+			CWARN("%s: failed to unlink PCC file %.*s, rc = %d\n",
+			      ll_i2sbi(inode)->ll_fsname, dentry->d_name.len,
+			      dentry->d_name.name, rc2);
 
 		dput(dentry);
 	}
diff --git a/fs/lustre/llite/pcc.h b/fs/lustre/llite/pcc.h
index 54492c9..f2b57f9 100644
--- a/fs/lustre/llite/pcc.h
+++ b/fs/lustre/llite/pcc.h
@@ -43,13 +43,64 @@
 
 #define LPROCFS_WR_PCC_MAX_CMD 4096
 
+/* User/Group/Project ID */
+struct pcc_match_id {
+	u32			pmi_id;
+	struct list_head	pmi_linkage;
+};
+
+/* wildcard file name */
+struct pcc_match_fname {
+	char			*pmf_name;
+	struct list_head	 pmf_linkage;
+};
+
+enum pcc_field {
+	PCC_FIELD_UID,
+	PCC_FIELD_GID,
+	PCC_FIELD_PROJID,
+	PCC_FIELD_FNAME,
+	PCC_FIELD_MAX
+};
+
+struct pcc_expression {
+	enum pcc_field		pe_field;
+	struct list_head	pe_cond;
+	struct list_head	pe_linkage;
+};
+
+struct pcc_conjunction {
+	/* link to disjunction */
+	struct list_head	pc_linkage;
+	/* list of logical conjunction */
+	struct list_head	pc_expressions;
+};
+
+/**
+ * Match rule for auto PCC-cached files.
+ */
+struct pcc_match_rule {
+	char			*pmr_conds_str;
+	struct list_head	 pmr_conds;
+};
+
+struct pcc_matcher {
+	u32		 pm_uid;
+	u32		 pm_gid;
+	u32		 pm_projid;
+	struct qstr	*pm_name;
+};
+
 struct pcc_dataset {
-	u32			pccd_id;	 /* Archive ID */
-	u32			pccd_projid;	 /* Project ID */
+	u32			pccd_rwid;	 /* Archive ID */
+	u32			pccd_roid;	 /* Readonly ID */
+	struct pcc_match_rule	pccd_rule;	 /* Match rule */
+	u32			pccd_rwonly:1, /* Only use as RW-PCC */
+				pccd_roonly:1; /* Only use as RO-PCC */
 	char			pccd_pathname[PATH_MAX]; /* full path */
 	struct path		pccd_path;	 /* Root path */
 	struct list_head	pccd_linkage;  /* Linked to pccs_datasets */
-	atomic_t		pccd_refcount; /* reference count */
+	atomic_t		pccd_refcount; /* Reference count */
 };
 
 struct pcc_super {
@@ -103,8 +154,10 @@ struct pcc_cmd {
 	char					*pccc_pathname;
 	union {
 		struct pcc_cmd_add {
-			u32			 pccc_id;
-			u32			 pccc_projid;
+			u32			 pccc_rwid;
+			u32			 pccc_roid;
+			struct list_head	 pccc_conds;
+			char			*pccc_conds_str;
 		} pccc_add;
 		struct pcc_cmd_del {
 			u32			 pccc_pad;
@@ -149,8 +202,8 @@ int pcc_inode_create(struct super_block *sb, struct pcc_dataset *dataset,
 		     struct lu_fid *fid, struct dentry **pcc_dentry);
 int pcc_inode_create_fini(struct pcc_dataset *dataset, struct inode *inode,
 			   struct dentry *pcc_dentry);
-struct pcc_dataset *pcc_dataset_get(struct pcc_super *super, u32 projid,
-				    u32 archive_id);
+struct pcc_dataset *pcc_dataset_match_get(struct pcc_super *super,
+					  struct pcc_matcher *matcher);
 void pcc_dataset_put(struct pcc_dataset *dataset);
 void pcc_inode_free(struct inode *inode);
 void pcc_layout_invalidate(struct inode *inode);
-- 
1.8.3.1
