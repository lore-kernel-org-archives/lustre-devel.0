From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:55 -0400
Subject: [lustre-devel] [PATCH 116/124] staging: lustre: llite: make
	default_easize writeable in /sysfs
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-117-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ned Bass <bass6@llnl.gov>, James Simmons <jsimmons@infradead.org>

From: Ned Bass <bass6@llnl.gov>

Allow default_easize to be tuned via /sysfs. A system administrator
might want this if a rare access to widely striped files drives up the
value on a filesystem where narrowly striped files are the more common
case. In practice, however, this is wanted primarily to facilitate
a test case for LU-5549.

 - Plumb the necessary interfaces through the LMV and MDC layers
   to expose write access to this value by higher layers.

 - Add block comments to modified functions.

Signed-off-by: Ned Bass <bass6@llnl.gov>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5549
Reviewed-on: http://review.whamcloud.com/13112
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |    1 +
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   33 +++++++++++++
 drivers/staging/lustre/lustre/llite/lproc_llite.c  |   51 +++++++++++++++++++-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   35 +++++++++++++-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    6 ++
 5 files changed, 124 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 70ca3e1..3e98bd6 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -839,6 +839,7 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 int ll_obd_statfs(struct inode *inode, void __user *arg);
 int ll_get_max_mdsize(struct ll_sb_info *sbi, int *max_mdsize);
 int ll_get_default_mdsize(struct ll_sb_info *sbi, int *default_mdsize);
+int ll_set_default_mdsize(struct ll_sb_info *sbi, int default_mdsize);
 int ll_process_config(struct lustre_cfg *lcfg);
 
 enum {
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 465b315..dab08a0 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -582,6 +582,17 @@ int ll_get_max_mdsize(struct ll_sb_info *sbi, int *lmmsize)
 	return rc;
 }
 
+/**
+ * Get the value of the default_easize parameter.
+ *
+ * \see client_obd::cl_default_mds_easize
+ *
+ * \param[in]  sbi	superblock info for this filesystem
+ * \param[out] lmmsize	pointer to storage location for value
+ *
+ * \retval 0		on success
+ * \retval negative	negated errno on failure
+ */
 int ll_get_default_mdsize(struct ll_sb_info *sbi, int *lmmsize)
 {
 	int size, rc;
@@ -595,6 +606,28 @@ int ll_get_default_mdsize(struct ll_sb_info *sbi, int *lmmsize)
 	return rc;
 }
 
+/**
+ * Set the default_easize parameter to the given value.
+ *
+ * \see client_obd::cl_default_mds_easize
+ *
+ * \param[in] sbi	superblock info for this filesystem
+ * \param[in] lmmsize	the size to set
+ *
+ * \retval 0		on success
+ * \retval negative	negated errno on failure
+ */
+int ll_set_default_mdsize(struct ll_sb_info *sbi, int lmmsize)
+{
+	if (lmmsize < sizeof(struct lov_mds_md) || lmmsize > PAGE_SIZE)
+		return -EINVAL;
+
+	return obd_set_info_async(NULL, sbi->ll_md_exp,
+				  sizeof(KEY_DEFAULT_EASIZE),
+				  KEY_DEFAULT_EASIZE,
+				  sizeof(int), &lmmsize, NULL);
+}
+
 static void client_common_put_super(struct super_block *sb)
 {
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 188fd37..6eae605 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -744,6 +744,18 @@ static ssize_t max_easize_show(struct kobject *kobj,
 }
 LUSTRE_RO_ATTR(max_easize);
 
+/**
+ * Get default_easize.
+ *
+ * \see client_obd::cl_default_mds_easize
+ *
+ * \param[in] kobj	kernel object for sysfs tree
+ * \param[in] attr	attribute of this kernel object
+ * \param[in] buf	buffer to write data into
+ *
+ * \retval positive	\a count on success
+ * \retval negative	negated errno on failure
+ */
 static ssize_t default_easize_show(struct kobject *kobj,
 				   struct attribute *attr,
 				   char *buf)
@@ -759,7 +771,44 @@ static ssize_t default_easize_show(struct kobject *kobj,
 
 	return sprintf(buf, "%u\n", ealen);
 }
-LUSTRE_RO_ATTR(default_easize);
+
+/**
+ * Set default_easize.
+ *
+ * Range checking on the passed value is handled by
+ * ll_set_default_mdsize().
+ *
+ * \see client_obd::cl_default_mds_easize
+ *
+ * \param[in] kobj	kernel object for sysfs tree
+ * \param[in] attr	attribute of this kernel object
+ * \param[in] buffer	string passed from user space
+ * \param[in] count	\a buffer length
+ *
+ * \retval positive	\a count on success
+ * \retval negative	negated errno on failure
+ */
+static ssize_t default_easize_store(struct kobject *kobj,
+				    struct attribute *attr,
+				    const char *buffer,
+				    size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kobj);
+	unsigned long val;
+	int rc;
+
+	rc = kstrtoul(buffer, 10, &val);
+	if (rc)
+		return rc;
+
+	rc = ll_set_default_mdsize(sbi, val);
+	if (rc)
+		return rc;
+
+	return count;
+}
+LUSTRE_RW_ATTR(default_easize);
 
 static int ll_sbi_flags_seq_show(struct seq_file *m, void *v)
 {
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index d67d0e0..e4cf6d3 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -2625,6 +2625,22 @@ static int lmv_precleanup(struct obd_device *obd, enum obd_cleanup_stage stage)
 	return 0;
 }
 
+/**
+ * Get by key a value associated with a LMV device.
+ *
+ * Dispatch request to lower-layer devices as needed.
+ *
+ * \param[in]  env	execution environment for this thread
+ * \param[in]  exp	export for the LMV device
+ * \param[in]  keylen	length of key identifier
+ * \param[in]  key	identifier of key to get value for
+ * \param[in]  vallen	size of \a val
+ * \param[out] val	pointer to storage location for value
+ * \param[in]  lsm	optional striping metadata of object
+ *
+ * \retval 0		on success
+ * \retval negative	negated errno on failure
+ */
 static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 			__u32 keylen, void *key, __u32 *vallen, void *val,
 			struct lov_stripe_md *lsm)
@@ -2688,6 +2704,22 @@ static int lmv_get_info(const struct lu_env *env, struct obd_export *exp,
 	return -EINVAL;
 }
 
+/**
+ * Asynchronously set by key a value associated with a LMV device.
+ *
+ * Dispatch request to lower-layer devices as needed.
+ *
+ * \param[in] env	execution environment for this thread
+ * \param[in] exp	export for the LMV device
+ * \param[in] keylen	length of key identifier
+ * \param[in] key	identifier of key to store value for
+ * \param[in] vallen	size of value to store
+ * \param[in] val	pointer to data to be stored
+ * \param[in] set	optional list of related ptlrpc requests
+ *
+ * \retval 0		on success
+ * \retval negative	negated errno on failure
+ */
 static int lmv_set_info_async(const struct lu_env *env, struct obd_export *exp,
 			      u32 keylen, void *key, u32 vallen,
 			      void *val, struct ptlrpc_request_set *set)
@@ -2705,7 +2737,8 @@ static int lmv_set_info_async(const struct lu_env *env, struct obd_export *exp,
 	}
 	lmv = &obd->u.lmv;
 
-	if (KEY_IS(KEY_READ_ONLY) || KEY_IS(KEY_FLUSH_CTX)) {
+	if (KEY_IS(KEY_READ_ONLY) || KEY_IS(KEY_FLUSH_CTX) ||
+	    KEY_IS(KEY_DEFAULT_EASIZE)) {
 		int i, err = 0;
 
 		for (i = 0; i < lmv->desc.ld_tgt_count; i++) {
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 125d882..1c00fea 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2516,6 +2516,12 @@ static int mdc_set_info_async(const struct lu_env *env,
 		rc = mdc_hsm_copytool_send(vallen, val);
 		return rc;
 	}
+	if (KEY_IS(KEY_DEFAULT_EASIZE)) {
+		u32 *default_easize = val;
+
+		exp->exp_obd->u.cli.cl_default_mds_easize = *default_easize;
+		return 0;
+	}
 
 	CERROR("Unknown key %s\n", (char *)key);
 	return -EINVAL;
-- 
1.7.1
