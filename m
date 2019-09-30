From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:38 -0400
Subject: [lustre-devel] [PATCH 079/151] lustre: mdc: Add an additional set
 of 64 changelog flags
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-80-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Matthew Sanderson <matthew.sanderson@anu.edu.au>

This adds a new changelog extension containing 64 additional flag
bits, to be used for future changelog extensions.
The presence of the extension is signalled using the last remaining
unused changelog flag bit.
The new extension is present in all changelog records by default, but
will be removed from records read by legacy changelog consumers.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9727
Lustre-commit: 08ffb6f1428f ("LU-9727 mdc: Add an additional set of 64 changelog flags")
Signed-off-by: Matthew Sanderson <matthew.sanderson@anu.edu.au>
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/28045
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_changelog.c           |   5 +-
 include/uapi/linux/lustre/lustre_idl.h  |   3 +-
 include/uapi/linux/lustre/lustre_user.h | 119 +++++++++++++++++++++++++++-----
 3 files changed, 106 insertions(+), 21 deletions(-)

diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index 011bcc9..e68ccb9 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -231,7 +231,10 @@ static int chlg_load(void *args)
 		goto err_out;
 	}
 
-	rc = llog_init_handle(NULL, llh, LLOG_F_IS_CAT | LLOG_F_EXT_JOBID,
+	rc = llog_init_handle(NULL, llh,
+			      LLOG_F_IS_CAT |
+			      LLOG_F_EXT_JOBID |
+			      LLOG_F_EXT_EXTRA_FLAGS,
 			      NULL);
 	if (rc) {
 		CERROR("%s: fail to init llog handle: rc = %d\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index b2f68edd..c23d1cb 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2577,6 +2577,7 @@ enum llog_flag {
 	LLOG_F_IS_PLAIN		= 0x4,
 	LLOG_F_EXT_JOBID	= 0x8,
 	LLOG_F_IS_FIXSIZE	= 0x10,
+	LLOG_F_EXT_EXTRA_FLAGS  = 0x20,
 
 	/*
 	 * Note: Flags covered by LLOG_F_EXT_MASK will be inherited from
@@ -2584,7 +2585,7 @@ enum llog_flag {
 	 * because the catlog record is usually fixed size, but its plain
 	 * log record can be variable
 	 */
-	LLOG_F_EXT_MASK = LLOG_F_EXT_JOBID,
+	LLOG_F_EXT_MASK = LLOG_F_EXT_JOBID | LLOG_F_EXT_EXTRA_FLAGS,
 };
 
 /* On-disk header structure of each log object, stored in little endian order */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 779b9af..8e82359 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -885,7 +885,8 @@ enum changelog_rec_flags {
 	CLF_VERSION	= 0x1000,
 	CLF_RENAME	= 0x2000,
 	CLF_JOBID	= 0x4000,
-	CLF_SUPPORTED	= CLF_VERSION | CLF_RENAME | CLF_JOBID
+	CLF_EXTRA_FLAGS = 0x8000,
+	CLF_SUPPORTED	= CLF_VERSION | CLF_RENAME | CLF_JOBID | CLF_EXTRA_FLAGS
 };
 
 /* Anything under the flagmask may be per-type (if desired) */
@@ -971,6 +972,11 @@ static inline void hsm_set_cl_error(int *flags, int error)
 	*flags |= (error << CLF_HSM_ERR_L);
 }
 
+enum changelog_rec_extra_flags {
+	CLFE_INVALID	= 0, /* No additional flags currently implemented */
+	CLFE_SUPPORTED	= CLFE_INVALID
+};
+
 enum changelog_send_flag {
 	/* Not yet implemented */
 	CHANGELOG_FLAG_FOLLOW	= 0x01,
@@ -982,10 +988,13 @@ enum changelog_send_flag {
 	CHANGELOG_FLAG_BLOCK	= 0x02,
 	/* Pack jobid into the changelog records if available. */
 	CHANGELOG_FLAG_JOBID	= 0x04,
+	/* Pack additional flag bits into the changelog record */
+	CHANGELOG_FLAG_EXTRA_FLAGS	= 0x08,
 };
 
 #define CR_MAXSIZE __ALIGN_KERNEL(2 * NAME_MAX + 2 + \
-				  changelog_rec_offset(CLF_SUPPORTED), 8)
+				  changelog_rec_offset(CLF_SUPPORTED, \
+							CLFE_SUPPORTED), 8)
 
 /* 31 usable bytes string + null terminator. */
 #define LUSTRE_JOBID_SIZE	32
@@ -993,9 +1002,10 @@ enum changelog_send_flag {
 /*
  * This is the minimal changelog record. It can contain extensions
  * such as rename fields or process jobid. Its exact content is described
- * by the cr_flags.
+ * by the cr_flags and cr_extra_flags.
  *
- * Extensions are packed in the same order as their corresponding flags.
+ * Extensions are packed in the same order as their corresponding flags,
+ * then in the same order as their corresponding extra flags.
  */
 struct changelog_rec {
 	__u16		 cr_namelen;
@@ -1022,7 +1032,16 @@ struct changelog_ext_jobid {
 	char	cr_jobid[LUSTRE_JOBID_SIZE];	/**< zero-terminated string. */
 };
 
-static inline size_t changelog_rec_offset(enum changelog_rec_flags crf)
+/* Changelog extension to include additional flags. */
+struct changelog_ext_extra_flags {
+	__u64 cr_extra_flags; /* Additional CLFE_* flags */
+};
+
+static inline struct changelog_ext_extra_flags *changelog_rec_extra_flags(
+	const struct changelog_rec *rec);
+
+static inline size_t changelog_rec_offset(enum changelog_rec_flags crf,
+					  enum changelog_rec_extra_flags cref)
 {
 	size_t size = sizeof(struct changelog_rec);
 
@@ -1032,12 +1051,20 @@ static inline size_t changelog_rec_offset(enum changelog_rec_flags crf)
 	if (crf & CLF_JOBID)
 		size += sizeof(struct changelog_ext_jobid);
 
+	if (crf & CLF_EXTRA_FLAGS)
+		size += sizeof(struct changelog_ext_extra_flags);
+
 	return size;
 }
 
 static inline size_t changelog_rec_size(struct changelog_rec *rec)
 {
-	return changelog_rec_offset(rec->cr_flags);
+	enum changelog_rec_extra_flags cref = CLFE_INVALID;
+
+	if (rec->cr_flags & CLF_EXTRA_FLAGS)
+		cref = changelog_rec_extra_flags(rec)->cr_extra_flags;
+
+	return changelog_rec_offset(rec->cr_flags, cref);
 }
 
 static inline size_t changelog_rec_varsize(struct changelog_rec *rec)
@@ -1051,7 +1078,8 @@ struct changelog_ext_rename *changelog_rec_rename(struct changelog_rec *rec)
 	enum changelog_rec_flags crf = rec->cr_flags & CLF_VERSION;
 
 	return (struct changelog_ext_rename *)((char *)rec +
-					       changelog_rec_offset(crf));
+					       changelog_rec_offset(crf,
+								 CLFE_INVALID));
 }
 
 /* The jobid follows the rename extension, if present */
@@ -1062,14 +1090,33 @@ struct changelog_ext_jobid *changelog_rec_jobid(struct changelog_rec *rec)
 				       (CLF_VERSION | CLF_RENAME);
 
 	return (struct changelog_ext_jobid *)((char *)rec +
-					      changelog_rec_offset(crf));
+					      changelog_rec_offset(crf,
+								 CLFE_INVALID));
 }
 
-/* The name follows the rename and jobid extensions, if present */
+/* The additional flags follow the rename and jobid extensions, if present */
+static inline
+struct changelog_ext_extra_flags *changelog_rec_extra_flags(
+	const struct changelog_rec *rec)
+{
+	enum changelog_rec_flags crf = rec->cr_flags &
+		(CLF_VERSION | CLF_RENAME | CLF_JOBID);
+
+	return (struct changelog_ext_extra_flags *)((char *)rec +
+						 changelog_rec_offset(crf,
+								 CLFE_INVALID));
+}
+
+/* The name follows the rename, jobid  and extra flags extns, if present */
 static inline char *changelog_rec_name(struct changelog_rec *rec)
 {
-	return (char *)rec + changelog_rec_offset(rec->cr_flags &
-						  CLF_SUPPORTED);
+	enum changelog_rec_extra_flags cref = CLFE_INVALID;
+
+	if (rec->cr_flags & CLF_EXTRA_FLAGS)
+		cref = changelog_rec_extra_flags(rec)->cr_extra_flags;
+
+	return (char *)rec + changelog_rec_offset(rec->cr_flags & CLF_SUPPORTED,
+						  cref & CLFE_SUPPORTED);
 }
 
 static inline size_t changelog_rec_snamelen(struct changelog_rec *rec)
@@ -1099,31 +1146,57 @@ static inline char *changelog_rec_sname(struct changelog_rec *rec)
  * The following assumptions are being made:
  *	- CLF_RENAME will not be removed
  *	- CLF_JOBID will not be added without CLF_RENAME being added too
+ *	- CLF_EXTRA_FLAGS will not be added without CLF_JOBID being added too
  *
  * @rec			The record to remap.
  * @crf_wanted		Flags describing the desired extensions.
+ * @cref_want		Flags describing the desired extra extensions.
  */
 static inline void changelog_remap_rec(struct changelog_rec *rec,
-				       enum changelog_rec_flags crf_wanted)
+				       enum changelog_rec_flags crf_wanted,
+				       enum changelog_rec_extra_flags cref_want)
 {
+	char *ef_mov;
 	char *jid_mov, *rnm_mov;
 
 	crf_wanted &= CLF_SUPPORTED;
-
-	if ((rec->cr_flags & CLF_SUPPORTED) == crf_wanted)
-		return;
+	cref_want &= CLFE_SUPPORTED;
+
+	if ((rec->cr_flags & CLF_SUPPORTED) == crf_wanted) {
+		if (!(rec->cr_flags & CLF_EXTRA_FLAGS) ||
+		    (rec->cr_flags & CLF_EXTRA_FLAGS &&
+		    (changelog_rec_extra_flags(rec)->cr_extra_flags &
+							CLFE_SUPPORTED) ==
+								     cref_want))
+			return;
+	}
 
 	/* First move the variable-length name field */
-	memmove((char *)rec + changelog_rec_offset(crf_wanted),
+	memmove((char *)rec + changelog_rec_offset(crf_wanted, cref_want),
 		changelog_rec_name(rec), rec->cr_namelen);
 
-	/* Locations of jobid and rename extensions in the remapped record */
+	/* Locations of extensions in the remapped record */
+	ef_mov  = (char *)rec +
+		  changelog_rec_offset(crf_wanted & ~CLF_EXTRA_FLAGS,
+				       CLFE_INVALID);
 	jid_mov = (char *)rec +
-		  changelog_rec_offset(crf_wanted & ~CLF_JOBID);
+		  changelog_rec_offset(crf_wanted &
+				       ~(CLF_EXTRA_FLAGS | CLF_JOBID),
+				       CLFE_INVALID);
 	rnm_mov = (char *)rec +
-		  changelog_rec_offset(crf_wanted & ~(CLF_JOBID | CLF_RENAME));
+		  changelog_rec_offset(crf_wanted &
+				       ~(CLF_EXTRA_FLAGS |
+					 CLF_JOBID |
+					 CLF_RENAME),
+				       CLFE_INVALID);
 
 	/* Move the extension fields to the desired positions */
+	if ((crf_wanted & CLF_EXTRA_FLAGS) &&
+	    (rec->cr_flags & CLF_EXTRA_FLAGS)) {
+		memmove(ef_mov, changelog_rec_extra_flags(rec),
+			sizeof(struct changelog_ext_extra_flags));
+	}
+
 	if ((crf_wanted & CLF_JOBID) && (rec->cr_flags & CLF_JOBID))
 		memmove(jid_mov, changelog_rec_jobid(rec),
 			sizeof(struct changelog_ext_jobid));
@@ -1133,6 +1206,10 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 			sizeof(struct changelog_ext_rename));
 
 	/* Clear newly added fields */
+	if ((crf_wanted & CLF_EXTRA_FLAGS) &&
+	    !(rec->cr_flags & CLF_EXTRA_FLAGS))
+		memset(ef_mov, 0, sizeof(struct changelog_ext_extra_flags));
+
 	if ((crf_wanted & CLF_JOBID) && !(rec->cr_flags & CLF_JOBID))
 		memset(jid_mov, 0, sizeof(struct changelog_ext_jobid));
 
@@ -1141,6 +1218,10 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 
 	/* Update the record's flags accordingly */
 	rec->cr_flags = (rec->cr_flags & CLF_FLAGMASK) | crf_wanted;
+	if (rec->cr_flags & CLF_EXTRA_FLAGS)
+		changelog_rec_extra_flags(rec)->cr_extra_flags =
+			changelog_rec_extra_flags(rec)->cr_extra_flags |
+			cref_want;
 }
 
 enum changelog_message_type {
-- 
1.8.3.1
