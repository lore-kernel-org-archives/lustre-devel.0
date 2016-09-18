From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:47 -0400
Subject: [lustre-devel] [PATCH 048/124] staging: lustre: Flexible changelog
	format.
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-49-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>

From: Henri Doreau <henri.doreau@cea.fr>

Added jobid fields to Changelog records (and extended records). The
CLF_JOBID flags allows to check if the field is present or not (old
format) when reading an entry. Jobids are expressed as 32 chars long,
zero-terminated strings. Updated test_205 in sanity.sh.

Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1996
Reviewed-on: http://review.whamcloud.com/4060
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Aurelien Degremont <aurelien.degremont@cea.fr>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    2 +-
 .../lustre/lustre/include/lustre/lustre_idl.h      |   19 +--
 .../lustre/lustre/include/lustre/lustre_user.h     |  165 +++++++++++++++-----
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/llite/vvp_req.c      |    2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   22 ++-
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    6 +-
 .../lustre/lustre/obdclass/linux/linux-module.c    |    2 +-
 drivers/staging/lustre/lustre/obdclass/llog.c      |    4 +-
 drivers/staging/lustre/lustre/obdclass/llog_cat.c  |    4 +-
 .../staging/lustre/lustre/obdclass/llog_internal.h |    5 +
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |   23 ++--
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   54 +------
 14 files changed, 188 insertions(+), 124 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 5039643..5af1153 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -1899,7 +1899,7 @@ struct cl_req_attr {
 	/** Generic attributes for the server consumption. */
 	struct obdo	*cra_oa;
 	/** Jobid */
-	char		 cra_jobid[JOBSTATS_JOBID_SIZE];
+	char		 cra_jobid[LUSTRE_JOBID_SIZE];
 };
 
 /**
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 56b5129..2dc550a 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1101,7 +1101,7 @@ struct lustre_msg_v2 {
 
 /* without gss, ptlrpc_body is put at the first buffer. */
 #define PTLRPC_NUM_VERSIONS     4
-#define JOBSTATS_JOBID_SIZE     32  /* 32 bytes string */
+
 struct ptlrpc_body_v3 {
 	struct lustre_handle pb_handle;
 	__u32 pb_type;
@@ -1123,7 +1123,7 @@ struct ptlrpc_body_v3 {
 	__u64 pb_pre_versions[PTLRPC_NUM_VERSIONS];
 	/* padding for future needs */
 	__u64 pb_padding[4];
-	char  pb_jobid[JOBSTATS_JOBID_SIZE];
+	char  pb_jobid[LUSTRE_JOBID_SIZE];
 };
 
 #define ptlrpc_body     ptlrpc_body_v3
@@ -3088,15 +3088,9 @@ struct changelog_setinfo {
 
 /** changelog record */
 struct llog_changelog_rec {
-	struct llog_rec_hdr  cr_hdr;
-	struct changelog_rec cr;
-	struct llog_rec_tail cr_tail; /**< for_sizezof_only */
-} __packed;
-
-struct llog_changelog_ext_rec {
-	struct llog_rec_hdr      cr_hdr;
-	struct changelog_ext_rec cr;
-	struct llog_rec_tail     cr_tail; /**< for_sizezof_only */
+	struct llog_rec_hdr	cr_hdr;
+	struct changelog_rec	cr;		/**< Variable length field */
+	struct llog_rec_tail	cr_do_not_use;	/**< for_sizezof_only */
 } __packed;
 
 struct llog_changelog_user_rec {
@@ -3181,6 +3175,9 @@ enum llog_flag {
 	LLOG_F_ZAP_WHEN_EMPTY	= 0x1,
 	LLOG_F_IS_CAT		= 0x2,
 	LLOG_F_IS_PLAIN		= 0x4,
+	LLOG_F_EXT_JOBID        = BIT(3),
+
+	LLOG_F_EXT_MASK = LLOG_F_EXT_JOBID,
 };
 
 struct llog_log_hdr {
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 79cd876..cc0a786 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -673,11 +673,16 @@ static inline const char *changelog_type2str(int type)
 }
 
 /* per-record flags */
-#define CLF_VERSION     0x1000
-#define CLF_EXT_VERSION 0x2000
 #define CLF_FLAGSHIFT   12
 #define CLF_FLAGMASK    ((1U << CLF_FLAGSHIFT) - 1)
 #define CLF_VERMASK     (~CLF_FLAGMASK)
+enum changelog_rec_flags {
+	CLF_VERSION	= 0x1000,
+	CLF_RENAME	= 0x2000,
+	CLF_JOBID	= 0x4000,
+	CLF_SUPPORTED	= CLF_VERSION | CLF_RENAME | CLF_JOBID
+};
+
 /* Anything under the flagmask may be per-type (if desired) */
 /* Flags for unlink */
 #define CLF_UNLINK_LAST       0x0001 /* Unlink of last hardlink */
@@ -761,12 +766,35 @@ static inline void hsm_set_cl_error(int *flags, int error)
 	*flags |= (error << CLF_HSM_ERR_L);
 }
 
-#define CR_MAXSIZE cfs_size_round(2 * NAME_MAX + 1 + \
-				  sizeof(struct changelog_ext_rec))
+enum changelog_send_flag {
+	/* Not yet implemented */
+	CHANGELOG_FLAG_FOLLOW	= BIT(0),
+	/*
+	 * Blocking IO makes sense in case of slow user parsing of the records,
+	 * but it also prevents us from cleaning up if the records are not
+	 * consumed.
+	 */
+	CHANGELOG_FLAG_BLOCK	= BIT(1),
+	/* Pack jobid into the changelog records if available. */
+	CHANGELOG_FLAG_JOBID	= BIT(2),
+};
+
+#define CR_MAXSIZE cfs_size_round(2 * NAME_MAX + 2 + \
+				  changelog_rec_offset(CLF_SUPPORTED))
+
+/* 31 usable bytes string + null terminator. */
+#define LUSTRE_JOBID_SIZE	32
 
+/*
+ * This is the minimal changelog record. It can contain extensions
+ * such as rename fields or process jobid. Its exact content is described
+ * by the cr_flags.
+ *
+ * Extensions are packed in the same order as their corresponding flags.
+ */
 struct changelog_rec {
 	__u16		 cr_namelen;
-	__u16		 cr_flags; /**< (flags&CLF_FLAGMASK)|CLF_VERSION */
+	__u16		 cr_flags; /**< \a changelog_rec_flags */
 	__u32		 cr_type;  /**< \a changelog_rec_type */
 	__u64		 cr_index; /**< changelog record number */
 	__u64		 cr_prev;  /**< last index for this target fid */
@@ -776,55 +804,116 @@ struct changelog_rec {
 		__u32	 cr_markerflags; /**< CL_MARK flags */
 	};
 	struct lu_fid	    cr_pfid;	/**< parent fid */
-	char		  cr_name[0];     /**< last element */
 } __packed;
 
-/* changelog_ext_rec is 2*sizeof(lu_fid) bigger than changelog_rec, to save
- * space, only rename uses changelog_ext_rec, while others use changelog_rec to
- * store records.
- */
-struct changelog_ext_rec {
-	__u16			cr_namelen;
-	__u16			cr_flags; /**< (flags & CLF_FLAGMASK) |
-					   *	CLF_EXT_VERSION
-					   */
-	__u32			cr_type;  /**< \a changelog_rec_type */
-	__u64			cr_index; /**< changelog record number */
-	__u64			cr_prev;  /**< last index for this target fid */
-	__u64			cr_time;
-	union {
-		struct lu_fid	cr_tfid;	/**< target fid */
-		__u32		cr_markerflags; /**< CL_MARK flags */
-	};
-	struct lu_fid		cr_pfid;	/**< target parent fid */
-	struct lu_fid		cr_sfid;	/**< source fid, or zero */
-	struct lu_fid		cr_spfid;     /**< source parent fid, or zero */
-	char			cr_name[0];     /**< last element */
-} __packed;
+/* Changelog extension for RENAME. */
+struct changelog_ext_rename {
+	struct lu_fid	cr_sfid;	/**< source fid, or zero */
+	struct lu_fid	cr_spfid;	/**< source parent fid, or zero */
+};
+
+/* Changelog extension to include JOBID. */
+struct changelog_ext_jobid {
+	char	cr_jobid[LUSTRE_JOBID_SIZE];	/**< zero-terminated string. */
+};
+
+static inline unsigned int changelog_rec_offset(enum changelog_rec_flags crf)
+{
+	unsigned int size = sizeof(struct changelog_rec);
+
+	if (crf & CLF_RENAME)
+		size += sizeof(struct changelog_ext_rename);
+
+	if (crf & CLF_JOBID)
+		size += sizeof(struct changelog_ext_jobid);
 
-#define CHANGELOG_REC_EXTENDED(rec) \
-	(((rec)->cr_flags & CLF_VERMASK) == CLF_EXT_VERSION)
+	return size;
+}
 
 static inline int changelog_rec_size(struct changelog_rec *rec)
 {
-	return CHANGELOG_REC_EXTENDED(rec) ? sizeof(struct changelog_ext_rec) :
-					     sizeof(*rec);
+	return changelog_rec_offset(rec->cr_flags);
+}
+
+static inline unsigned int changelog_rec_varsize(struct changelog_rec *rec)
+{
+	return changelog_rec_size(rec) - sizeof(*rec) + rec->cr_namelen;
+}
+
+static inline
+struct changelog_ext_rename *changelog_rec_rename(struct changelog_rec *rec)
+{
+	enum changelog_rec_flags crf = rec->cr_flags & CLF_VERSION;
+
+	return (struct changelog_ext_rename *)((char *)rec +
+					       changelog_rec_offset(crf));
+}
+
+/* The jobid follows the rename extension, if present */
+static inline
+struct changelog_ext_jobid *changelog_rec_jobid(struct changelog_rec *rec)
+{
+	enum changelog_rec_flags crf = rec->cr_flags &
+				       (CLF_VERSION | CLF_RENAME);
+
+	return (struct changelog_ext_jobid *)((char *)rec +
+					      changelog_rec_offset(crf));
 }
 
+/* The name follows the rename and jobid extensions, if present */
 static inline char *changelog_rec_name(struct changelog_rec *rec)
 {
-	return CHANGELOG_REC_EXTENDED(rec) ?
-		((struct changelog_ext_rec *)rec)->cr_name : rec->cr_name;
+	return (char *)rec + changelog_rec_offset(rec->cr_flags &
+						  CLF_SUPPORTED);
+}
+
+static inline int changelog_rec_snamelen(struct changelog_rec *rec)
+{
+	return rec->cr_namelen - strlen(changelog_rec_name(rec)) - 1;
 }
 
-static inline int changelog_rec_snamelen(struct changelog_ext_rec *rec)
+static inline char *changelog_rec_sname(struct changelog_rec *rec)
 {
-	return rec->cr_namelen - strlen(rec->cr_name) - 1;
+	char *cr_name = changelog_rec_name(rec);
+
+	return cr_name + strlen(cr_name) + 1;
 }
 
-static inline char *changelog_rec_sname(struct changelog_ext_rec *rec)
+/*
+ * Remap a record to the desired format as specified by the crf flags.
+ * The record must be big enough to contain the final remapped version.
+ */
+static inline void changelog_remap_rec(struct changelog_rec *rec,
+				       enum changelog_rec_flags crf)
 {
-	return rec->cr_name + strlen(rec->cr_name) + 1;
+	size_t var_size;
+	char *var_part;
+
+	crf &= CLF_SUPPORTED;
+
+	if ((rec->cr_flags & CLF_SUPPORTED) == crf)
+		return;
+
+	if ((crf & CLF_JOBID) && rec->cr_flags & CLF_JOBID) {
+		var_part = (char *)changelog_rec_jobid(rec);
+		var_size = rec->cr_namelen + sizeof(struct changelog_ext_jobid);
+	} else {
+		var_part = changelog_rec_name(rec);
+		var_size = rec->cr_namelen;
+	}
+
+	memmove((char *)rec + changelog_rec_offset(crf & ~CLF_JOBID), var_part,
+		var_size);
+
+	if ((crf & CLF_RENAME) && !(rec->cr_flags & CLF_RENAME))
+		memset(changelog_rec_rename(rec), 0,
+		       sizeof(struct changelog_ext_rename));
+
+	if ((crf & CLF_JOBID) && !(rec->cr_flags & CLF_JOBID))
+		memset(changelog_rec_jobid(rec), 0,
+		       sizeof(struct changelog_ext_jobid));
+
+	rec->cr_flags = (rec->cr_flags & CLF_FLAGMASK) | crf;
 }
 
 struct ioc_changelog {
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index f972ba3..fc707c2 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -232,7 +232,7 @@ struct ll_inode_info {
 			 * so the read/write statistics for jobid will not be
 			 * accurate if the file is shared by different jobs.
 			 */
-			char		     f_jobid[JOBSTATS_JOBID_SIZE];
+			char		     f_jobid[LUSTRE_JOBID_SIZE];
 		} f;
 
 #define lli_size_mutex          u.f.f_size_mutex
diff --git a/drivers/staging/lustre/lustre/llite/vvp_req.c b/drivers/staging/lustre/lustre/llite/vvp_req.c
index a6e2672..e3f4c79 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_req.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_req.c
@@ -85,7 +85,7 @@ static void vvp_req_attr_set(const struct lu_env *env,
 	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_INVALID_PFID))
 		oa->o_parent_oid++;
 	memcpy(attr->cra_jobid, ll_i2info(inode)->lli_jobid,
-	       JOBSTATS_JOBID_SIZE);
+	       LUSTRE_JOBID_SIZE);
 }
 
 static void vvp_req_completion(const struct lu_env *env,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 956b946..aeadcd6 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1859,12 +1859,17 @@ static struct kuc_hdr *changelog_kuc_hdr(char *buf, int len, int flags)
 
 struct changelog_show {
 	__u64		cs_startrec;
-	__u32		cs_flags;
+	enum changelog_send_flag	cs_flags;
 	struct file	*cs_fp;
 	char		*cs_buf;
 	struct obd_device *cs_obd;
 };
 
+static inline char *cs_obd_name(struct changelog_show *cs)
+{
+	return cs->cs_obd->obd_name;
+}
+
 static int changelog_kkuc_cb(const struct lu_env *env, struct llog_handle *llh,
 			     struct llog_rec_hdr *hdr, void *data)
 {
@@ -1876,7 +1881,7 @@ static int changelog_kkuc_cb(const struct lu_env *env, struct llog_handle *llh,
 	if (rec->cr_hdr.lrh_type != CHANGELOG_REC) {
 		rc = -EINVAL;
 		CERROR("%s: not a changelog rec %x/%d: rc = %d\n",
-		       cs->cs_obd->obd_name, rec->cr_hdr.lrh_type,
+		       cs_obd_name(cs), rec->cr_hdr.lrh_type,
 		       rec->cr.cr_type, rc);
 		return rc;
 	}
@@ -1909,6 +1914,7 @@ static int changelog_kkuc_cb(const struct lu_env *env, struct llog_handle *llh,
 
 static int mdc_changelog_send_thread(void *csdata)
 {
+	enum llog_flag flags = LLOG_F_IS_CAT;
 	struct changelog_show *cs = csdata;
 	struct llog_ctxt *ctxt = NULL;
 	struct llog_handle *llh = NULL;
@@ -1934,10 +1940,14 @@ static int mdc_changelog_send_thread(void *csdata)
 		       LLOG_OPEN_EXISTS);
 	if (rc) {
 		CERROR("%s: fail to open changelog catalog: rc = %d\n",
-		       cs->cs_obd->obd_name, rc);
+		       cs_obd_name(cs), rc);
 		goto out;
 	}
-	rc = llog_init_handle(NULL, llh, LLOG_F_IS_CAT, NULL);
+
+	if (cs->cs_flags & CHANGELOG_FLAG_JOBID)
+		flags |= LLOG_F_EXT_JOBID;
+
+	rc = llog_init_handle(NULL, llh, flags, NULL);
 	if (rc) {
 		CERROR("llog_init_handle failed %d\n", rc);
 		goto out;
@@ -1990,12 +2000,12 @@ static int mdc_ioc_changelog_send(struct obd_device *obd,
 	if (IS_ERR(task)) {
 		rc = PTR_ERR(task);
 		CERROR("%s: can't start changelog thread: rc = %d\n",
-		       obd->obd_name, rc);
+		       cs_obd_name(cs), rc);
 		kfree(cs);
 	} else {
 		rc = 0;
 		CDEBUG(D_HSM, "%s: started changelog thread\n",
-		       obd->obd_name);
+		       cs_obd_name(cs));
 	}
 
 	CERROR("Failed to start changelog thread: %d\n", rc);
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 629d8b5..4c30d6b 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -81,7 +81,7 @@ EXPORT_SYMBOL(obd_dirty_transit_pages);
 char obd_jobid_var[JOBSTATS_JOBID_VAR_MAX_LEN + 1] = JOBSTATS_DISABLE;
 EXPORT_SYMBOL(obd_jobid_var);
 
-char obd_jobid_node[JOBSTATS_JOBID_SIZE + 1];
+char obd_jobid_node[LUSTRE_JOBID_SIZE + 1];
 
 /* Get jobid of current process from stored variable or calculate
  * it from pid and user_id.
@@ -92,14 +92,14 @@ char obd_jobid_node[JOBSTATS_JOBID_SIZE + 1];
  */
 int lustre_get_jobid(char *jobid)
 {
-	memset(jobid, 0, JOBSTATS_JOBID_SIZE);
+	memset(jobid, 0, LUSTRE_JOBID_SIZE);
 	/* Jobstats isn't enabled */
 	if (strcmp(obd_jobid_var, JOBSTATS_DISABLE) == 0)
 		return 0;
 
 	/* Use process name + fsuid as jobid */
 	if (strcmp(obd_jobid_var, JOBSTATS_PROCNAME_UID) == 0) {
-		snprintf(jobid, JOBSTATS_JOBID_SIZE, "%s.%u",
+		snprintf(jobid, LUSTRE_JOBID_SIZE, "%s.%u",
 			 current_comm(),
 			 from_kuid(&init_user_ns, current_fsuid()));
 		return 0;
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 2b691d8..ae172c4 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -292,7 +292,7 @@ static ssize_t jobid_name_store(struct kobject *kobj, struct attribute *attr,
 				const char *buffer,
 				size_t count)
 {
-	if (!count || count > JOBSTATS_JOBID_SIZE)
+	if (!count || count > LUSTRE_JOBID_SIZE)
 		return -EINVAL;
 
 	memcpy(obd_jobid_node, buffer, count);
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 8f06141..119372c 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -137,6 +137,7 @@ static int llog_read_header(const struct lu_env *env,
 int llog_init_handle(const struct lu_env *env, struct llog_handle *handle,
 		     int flags, struct obd_uuid *uuid)
 {
+	enum llog_flag fmt = flags & LLOG_F_EXT_MASK;
 	struct llog_log_hdr	*llh;
 	int			 rc;
 
@@ -194,6 +195,7 @@ int llog_init_handle(const struct lu_env *env, struct llog_handle *handle,
 		       flags, LLOG_F_IS_CAT, LLOG_F_IS_PLAIN);
 		rc = -EINVAL;
 	}
+	llh->llh_flags |= fmt;
 out:
 	if (rc) {
 		kfree(llh);
@@ -262,7 +264,7 @@ repeat:
 		 */
 		for (rec = (struct llog_rec_hdr *)buf;
 		     (char *)rec < buf + LLOG_CHUNK_SIZE;
-		     rec = (struct llog_rec_hdr *)((char *)rec + rec->lrh_len)) {
+		     rec = llog_rec_hdr_next(rec)) {
 			CDEBUG(D_OTHER, "processing rec 0x%p type %#x\n",
 			       rec, rec->lrh_type);
 
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_cat.c b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
index b27f08f..ce8e2f6 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_cat.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_cat.c
@@ -63,11 +63,13 @@ static int llog_cat_id2handle(const struct lu_env *env,
 			      struct llog_logid *logid)
 {
 	struct llog_handle	*loghandle;
+	enum llog_flag fmt;
 	int			 rc = 0;
 
 	if (!cathandle)
 		return -EBADF;
 
+	fmt = cathandle->lgh_hdr->llh_flags & LLOG_F_EXT_MASK;
 	down_write(&cathandle->lgh_lock);
 	list_for_each_entry(loghandle, &cathandle->u.chd.chd_head,
 			    u.phd.phd_entry) {
@@ -99,7 +101,7 @@ static int llog_cat_id2handle(const struct lu_env *env,
 		return rc;
 	}
 
-	rc = llog_init_handle(env, loghandle, LLOG_F_IS_PLAIN, NULL);
+	rc = llog_init_handle(env, loghandle, fmt | LLOG_F_IS_PLAIN, NULL);
 	if (rc < 0) {
 		llog_close(env, loghandle);
 		loghandle = NULL;
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_internal.h b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
index f794952..21a93c7 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_internal.h
+++ b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
@@ -70,4 +70,9 @@ int llog_process_or_fork(const struct lu_env *env,
 			 llog_cb_t cb, void *data, void *catdata, bool fork);
 int llog_cat_cleanup(const struct lu_env *env, struct llog_handle *cathandle,
 		     struct llog_handle *loghandle, int index);
+
+static inline struct llog_rec_hdr *llog_rec_hdr_next(struct llog_rec_hdr *rec)
+{
+	return (struct llog_rec_hdr *)((char *)rec + rec->lrh_len);
+}
 #endif
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index 0ec6361..21ab90c 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -172,20 +172,23 @@ void lustre_swab_llog_rec(struct llog_rec_hdr *rec)
 		__swab64s(&cr->cr.cr_time);
 		lustre_swab_lu_fid(&cr->cr.cr_tfid);
 		lustre_swab_lu_fid(&cr->cr.cr_pfid);
-		if (CHANGELOG_REC_EXTENDED(&cr->cr)) {
-			struct llog_changelog_ext_rec *ext =
-				(struct llog_changelog_ext_rec *)rec;
-
-			lustre_swab_lu_fid(&ext->cr.cr_sfid);
-			lustre_swab_lu_fid(&ext->cr.cr_spfid);
-			tail = &ext->cr_tail;
-		} else {
-			tail = &cr->cr_tail;
+		if (cr->cr.cr_flags & CLF_RENAME) {
+			struct changelog_ext_rename *rnm =
+				changelog_rec_rename(&cr->cr);
+
+			lustre_swab_lu_fid(&rnm->cr_sfid);
+			lustre_swab_lu_fid(&rnm->cr_spfid);
 		}
-		tail = (struct llog_rec_tail *)((char *)tail +
+		/*
+		 * Because the tail follows a variable-length structure we need
+		 * to compute its location at runtime
+		 */
+		tail = (struct llog_rec_tail *)((char *)&cr->cr +
+						changelog_rec_size(&cr->cr) +
 						cr->cr.cr_namelen);
 		break;
 	}
+
 	case CHANGELOG_USER_REC:
 	{
 		struct llog_changelog_user_rec *cur =
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 03fd5d7..e25596f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1378,7 +1378,7 @@ void lustre_msg_set_jobid(struct lustre_msg *msg, char *jobid)
 		LASSERTF(pb, "invalid msg %p: no ptlrpc body!\n", msg);
 
 		if (jobid)
-			memcpy(pb->pb_jobid, jobid, JOBSTATS_JOBID_SIZE);
+			memcpy(pb->pb_jobid, jobid, LUSTRE_JOBID_SIZE);
 		else if (pb->pb_jobid[0] == '\0')
 			lustre_get_jobid(pb->pb_jobid);
 		return;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index b33fd7b..e5945e2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -684,7 +684,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_padding));
 	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding) == 32, "found %lld\n",
 		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding));
-	CLASSERT(JOBSTATS_JOBID_SIZE == 32);
+	CLASSERT(LUSTRE_JOBID_SIZE == 32);
 	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_jobid) == 152, "found %lld\n",
 		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_jobid));
 	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_jobid) == 32, "found %lld\n",
@@ -3300,50 +3300,6 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct changelog_rec *)0)->cr_pfid) == 16, "found %lld\n",
 		 (long long)(int)sizeof(((struct changelog_rec *)0)->cr_pfid));
 
-	/* Checks for struct changelog_ext_rec */
-	LASSERTF((int)sizeof(struct changelog_ext_rec) == 96, "found %lld\n",
-		 (long long)(int)sizeof(struct changelog_ext_rec));
-	LASSERTF((int)offsetof(struct changelog_ext_rec, cr_namelen) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct changelog_ext_rec, cr_namelen));
-	LASSERTF((int)sizeof(((struct changelog_ext_rec *)0)->cr_namelen) == 2, "found %lld\n",
-		 (long long)(int)sizeof(((struct changelog_ext_rec *)0)->cr_namelen));
-	LASSERTF((int)offsetof(struct changelog_ext_rec, cr_flags) == 2, "found %lld\n",
-		 (long long)(int)offsetof(struct changelog_ext_rec, cr_flags));
-	LASSERTF((int)sizeof(((struct changelog_ext_rec *)0)->cr_flags) == 2, "found %lld\n",
-		 (long long)(int)sizeof(((struct changelog_ext_rec *)0)->cr_flags));
-	LASSERTF((int)offsetof(struct changelog_ext_rec, cr_type) == 4, "found %lld\n",
-		 (long long)(int)offsetof(struct changelog_ext_rec, cr_type));
-	LASSERTF((int)sizeof(((struct changelog_ext_rec *)0)->cr_type) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct changelog_ext_rec *)0)->cr_type));
-	LASSERTF((int)offsetof(struct changelog_ext_rec, cr_index) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct changelog_ext_rec, cr_index));
-	LASSERTF((int)sizeof(((struct changelog_ext_rec *)0)->cr_index) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct changelog_ext_rec *)0)->cr_index));
-	LASSERTF((int)offsetof(struct changelog_ext_rec, cr_prev) == 16, "found %lld\n",
-		 (long long)(int)offsetof(struct changelog_ext_rec, cr_prev));
-	LASSERTF((int)sizeof(((struct changelog_ext_rec *)0)->cr_prev) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct changelog_ext_rec *)0)->cr_prev));
-	LASSERTF((int)offsetof(struct changelog_ext_rec, cr_time) == 24, "found %lld\n",
-		 (long long)(int)offsetof(struct changelog_ext_rec, cr_time));
-	LASSERTF((int)sizeof(((struct changelog_ext_rec *)0)->cr_time) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct changelog_ext_rec *)0)->cr_time));
-	LASSERTF((int)offsetof(struct changelog_ext_rec, cr_tfid) == 32, "found %lld\n",
-		 (long long)(int)offsetof(struct changelog_ext_rec, cr_tfid));
-	LASSERTF((int)sizeof(((struct changelog_ext_rec *)0)->cr_tfid) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct changelog_ext_rec *)0)->cr_tfid));
-	LASSERTF((int)offsetof(struct changelog_ext_rec, cr_pfid) == 48, "found %lld\n",
-		 (long long)(int)offsetof(struct changelog_ext_rec, cr_pfid));
-	LASSERTF((int)sizeof(((struct changelog_ext_rec *)0)->cr_pfid) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct changelog_ext_rec *)0)->cr_pfid));
-	LASSERTF((int)offsetof(struct changelog_ext_rec, cr_sfid) == 64, "found %lld\n",
-		 (long long)(int)offsetof(struct changelog_ext_rec, cr_sfid));
-	LASSERTF((int)sizeof(((struct changelog_ext_rec *)0)->cr_sfid) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct changelog_ext_rec *)0)->cr_sfid));
-	LASSERTF((int)offsetof(struct changelog_ext_rec, cr_spfid) == 80, "found %lld\n",
-		 (long long)(int)offsetof(struct changelog_ext_rec, cr_spfid));
-	LASSERTF((int)sizeof(((struct changelog_ext_rec *)0)->cr_spfid) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct changelog_ext_rec *)0)->cr_spfid));
-
 	/* Checks for struct changelog_setinfo */
 	LASSERTF((int)sizeof(struct changelog_setinfo) == 12, "found %lld\n",
 		 (long long)(int)sizeof(struct changelog_setinfo));
@@ -3367,10 +3323,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct llog_changelog_rec, cr));
 	LASSERTF((int)sizeof(((struct llog_changelog_rec *)0)->cr) == 64, "found %lld\n",
 		 (long long)(int)sizeof(((struct llog_changelog_rec *)0)->cr));
-	LASSERTF((int)offsetof(struct llog_changelog_rec, cr_tail) == 80, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_changelog_rec, cr_tail));
-	LASSERTF((int)sizeof(((struct llog_changelog_rec *)0)->cr_tail) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_changelog_rec *)0)->cr_tail));
+	LASSERTF((int)offsetof(struct llog_changelog_rec, cr_do_not_use) == 80, "found %lld\n",
+		 (long long)(int)offsetof(struct llog_changelog_rec, cr_do_not_use));
+	LASSERTF((int)sizeof(((struct llog_changelog_rec *)0)->cr_do_not_use) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct llog_changelog_rec *)0)->cr_do_not_use));
 
 	/* Checks for struct llog_changelog_user_rec */
 	LASSERTF((int)sizeof(struct llog_changelog_user_rec) == 40, "found %lld\n",
-- 
1.7.1
