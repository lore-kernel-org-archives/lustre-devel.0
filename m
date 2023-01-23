Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D2B67C25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:19:21 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Mn67jrz21P9;
	Mon, 23 Jan 2023 15:07:01 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15Mk3D8bz21Nn
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:06:58 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 7ABFC9F7;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 77EE158991; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:37 -0500
Message-Id: <1674514855-15399-25-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 24/42] lustre: move to kobj_type
 default_groups
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
Cc: Shaun Tancheff <shaun.tancheff@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Shaun Tancheff <shaun.tancheff@hpe.com>

Linux commit v5.1-rc3-29-gaa30f47cf666
  kobject: Add support for default attribute groups to kobj_type

Linux commit v5.18-rc1-2-gcdb4f26a63c3
  kobject: kobj_type: remove default_attrs

Switch to using kobj_type default_groups.

HPE-bug-id: LUS-11196
WC-bug-id: https://jira.whamcloud.com/browse/LU-16120
Lustre-commit: 62e9d055d9516ec6a ("LU-16120 build: Add support for kobj_type default_groups")
Signed-off-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48365
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h   | 39 +++++++++++++++++++++++++++++++++
 fs/lustre/ldlm/ldlm_pool.c      |  4 +++-
 fs/lustre/ldlm/ldlm_resource.c  |  4 +++-
 fs/lustre/llite/lproc_llite.c   |  4 +++-
 fs/lustre/lmv/lproc_lmv.c       |  4 +++-
 fs/lustre/lov/lproc_lov.c       |  4 +++-
 fs/lustre/mdc/lproc_mdc.c       |  4 +++-
 fs/lustre/obdclass/obd_config.c | 15 +++----------
 fs/lustre/osc/lproc_osc.c       |  4 +++-
 fs/lustre/ptlrpc/lproc_ptlrpc.c |  4 +++-
 10 files changed, 66 insertions(+), 20 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 9edd93cbacc5..81ef59e01956 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1750,4 +1750,43 @@ extern u64 obd_heat_get(struct obd_heat_instance *instance,
 			unsigned int period_second);
 extern void obd_heat_clear(struct obd_heat_instance *instance, int count);
 
+/* struct kobj_type */
+#define KOBJ_ATTR_GROUPS(_name)		_name##_groups
+
+static inline
+struct attribute *_get_attr_matches(const struct kobj_type *typ,
+				    const char *key, size_t keylen,
+				    int (*is_match)(const char *, const char *,
+						    size_t))
+{
+	int i;
+
+	for (i = 0; typ->default_groups[i]; i++) {
+		struct attribute **attrs;
+		int k;
+
+		attrs = (struct attribute **)typ->default_groups[i]->attrs;
+		for (k = 0; attrs[k]; k++) {
+			if (is_match(attrs[k]->name, key, keylen))
+				return (struct attribute *)attrs[k];
+		}
+	}
+
+	return NULL;
+}
+
+static inline
+int _attr_name_starts_with(const char *attr_name, const char *name, size_t len)
+{
+	return !strncmp(attr_name, name, len);
+}
+
+static inline
+struct attribute *get_attr_starts_with(const struct kobj_type *typ,
+				       const char *name,
+				       size_t len)
+{
+	return _get_attr_matches(typ, name, len, _attr_name_starts_with);
+}
+
 #endif /* __LINUX_OBD_CLASS_H */
diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index f0e629c5dd24..6fce509f7f31 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -549,6 +549,8 @@ static struct attribute *ldlm_pl_attrs[] = {
 	NULL,
 };
 
+ATTRIBUTE_GROUPS(ldlm_pl);
+
 static void ldlm_pl_release(struct kobject *kobj)
 {
 	struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool,
@@ -557,7 +559,7 @@ static void ldlm_pl_release(struct kobject *kobj)
 }
 
 static struct kobj_type ldlm_pl_ktype = {
-	.default_attrs	= ldlm_pl_attrs,
+	.default_groups = KOBJ_ATTR_GROUPS(ldlm_pl),
 	.sysfs_ops	= &lustre_sysfs_ops,
 	.release	= ldlm_pl_release,
 };
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 98c3e4fb4466..9a269cb326a0 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -419,8 +419,10 @@ static void ldlm_ns_release(struct kobject *kobj)
 	complete(&ns->ns_kobj_unregister);
 }
 
+ATTRIBUTE_GROUPS(ldlm_ns);
+
 static struct kobj_type ldlm_ns_ktype = {
-	.default_attrs	= ldlm_ns_attrs,
+	.default_groups = KOBJ_ATTR_GROUPS(ldlm_ns),
 	.sysfs_ops	= &lustre_sysfs_ops,
 	.release	= ldlm_ns_release,
 };
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index c4a514aa1e4f..3d64a936331a 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1759,6 +1759,8 @@ static struct attribute *llite_attrs[] = {
 	NULL,
 };
 
+ATTRIBUTE_GROUPS(llite); /* creates llite_groups */
+
 static void sbi_kobj_release(struct kobject *kobj)
 {
 	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
@@ -1767,7 +1769,7 @@ static void sbi_kobj_release(struct kobject *kobj)
 }
 
 static struct kobj_type sbi_ktype = {
-	.default_attrs	= llite_attrs,
+	.default_groups	= KOBJ_ATTR_GROUPS(llite),
 	.sysfs_ops	= &lustre_sysfs_ops,
 	.release	= sbi_kobj_release,
 };
diff --git a/fs/lustre/lmv/lproc_lmv.c b/fs/lustre/lmv/lproc_lmv.c
index 6d4e8d986f8b..3b8181f51080 100644
--- a/fs/lustre/lmv/lproc_lmv.c
+++ b/fs/lustre/lmv/lproc_lmv.c
@@ -290,11 +290,13 @@ static struct attribute *lmv_attrs[] = {
 	NULL,
 };
 
+ATTRIBUTE_GROUPS(lmv); /* creates lmv_groups */
+
 int lmv_tunables_init(struct obd_device *obd)
 {
 	int rc;
 
-	obd->obd_ktype.default_attrs = lmv_attrs;
+	obd->obd_ktype.default_groups = KOBJ_ATTR_GROUPS(lmv);
 	rc = lprocfs_obd_setup(obd, true);
 	if (rc)
 		return rc;
diff --git a/fs/lustre/lov/lproc_lov.c b/fs/lustre/lov/lproc_lov.c
index 95fb4ef91928..05cbde6e6e99 100644
--- a/fs/lustre/lov/lproc_lov.c
+++ b/fs/lustre/lov/lproc_lov.c
@@ -277,12 +277,14 @@ static struct attribute *lov_attrs[] = {
 	NULL,
 };
 
+ATTRIBUTE_GROUPS(lov); /* creates lov_groups */
+
 int lov_tunables_init(struct obd_device *obd)
 {
 	struct lov_obd *lov = &obd->u.lov;
 	int rc;
 
-	obd->obd_ktype.default_attrs = lov_attrs;
+	obd->obd_ktype.default_groups = KOBJ_ATTR_GROUPS(lov);
 	rc = lprocfs_obd_setup(obd, false);
 	if (rc)
 		return rc;
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index b59bba3595e3..fa799c525f46 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -754,11 +754,13 @@ static struct attribute *mdc_attrs[] = {
 	NULL,
 };
 
+ATTRIBUTE_GROUPS(mdc); /* creates mdc_groups */
+
 int mdc_tunables_init(struct obd_device *obd)
 {
 	int rc;
 
-	obd->obd_ktype.default_attrs = mdc_attrs;
+	obd->obd_ktype.default_groups = KOBJ_ATTR_GROUPS(mdc);
 	obd->obd_vars = lprocfs_mdc_obd_vars;
 
 	rc = lprocfs_obd_setup(obd, false);
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 75fc6a632cda..953f544b410d 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -1080,7 +1080,7 @@ ssize_t class_modify_config(struct lustre_cfg *lcfg, const char *prefix,
 	}
 
 	typ = get_ktype(kobj);
-	if (!typ || !typ->default_attrs)
+	if (!typ || !typ->default_groups)
 		return -ENODEV;
 
 	print_lustre_cfg(lcfg);
@@ -1091,11 +1091,10 @@ ssize_t class_modify_config(struct lustre_cfg *lcfg, const char *prefix,
 	 * or   lctl conf_param lustre-OST0000.osc.max_dirty_mb=36
 	 */
 	for (i = 1; i < lcfg->lcfg_bufcount; i++) {
-		struct attribute *attr;
+		struct attribute *attr = NULL;
 		size_t keylen;
 		char *value;
 		char *key;
-		int j;
 
 		key = lustre_cfg_buf(lcfg, i);
 		/* Strip off prefix */
@@ -1116,15 +1115,7 @@ ssize_t class_modify_config(struct lustre_cfg *lcfg, const char *prefix,
 		keylen = value - key;
 		value++;
 
-		attr = NULL;
-		for (j = 0; typ->default_attrs[j]; j++) {
-			if (!strncmp(typ->default_attrs[j]->name, key,
-				     keylen)) {
-				attr = typ->default_attrs[j];
-				break;
-			}
-		}
-
+		attr = get_attr_starts_with(typ, key, keylen);
 		if (!attr) {
 			char *envp[4], *param, *path;
 
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index b458a867c31f..d3131ee7eef1 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -872,12 +872,14 @@ static struct attribute *osc_attrs[] = {
 	NULL,
 };
 
+ATTRIBUTE_GROUPS(osc); /* creates osc_groups */
+
 int osc_tunables_init(struct obd_device *obd)
 {
 	int rc;
 
 	obd->obd_vars = lprocfs_osc_obd_vars;
-	obd->obd_ktype.default_attrs = osc_attrs;
+	obd->obd_ktype.default_groups = KOBJ_ATTR_GROUPS(osc);
 	rc = lprocfs_obd_setup(obd, false);
 	if (rc)
 		return rc;
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index e0b85bd9f74e..f3f8a7115ade 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -1125,6 +1125,8 @@ static struct attribute *ptlrpc_svc_attrs[] = {
 	NULL,
 };
 
+ATTRIBUTE_GROUPS(ptlrpc_svc); /* creates ptlrpc_svc_groups */
+
 static void ptlrpc_sysfs_svc_release(struct kobject *kobj)
 {
 	struct ptlrpc_service *svc = container_of(kobj, struct ptlrpc_service,
@@ -1134,7 +1136,7 @@ static void ptlrpc_sysfs_svc_release(struct kobject *kobj)
 }
 
 static struct kobj_type ptlrpc_svc_ktype = {
-	.default_attrs	= ptlrpc_svc_attrs,
+	.default_groups = KOBJ_ATTR_GROUPS(ptlrpc_svc),
 	.sysfs_ops	= &lustre_sysfs_ops,
 	.release	= ptlrpc_sysfs_svc_release,
 };
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
