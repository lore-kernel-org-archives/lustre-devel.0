From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:43 -0400
Subject: [lustre-devel] [PATCH 084/151] lustre: mdc: add uid/gid to
 Changelogs entries
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-85-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Add a new changelog extension named changelog_ext_uidgid to hold
uid/gid information.
uid/gid info is added to every Changelog entry type except MARK, in
the form 'u=<uid>:<gid>':
5 01CREAT 15:44:32.385864793 2017.07.18 0x0 t=[0x200000402:0x3:0x0]
ef=0x1 u=500:500 p=[0x200000402:0x2:0x0] file1

WC-bug-id: https://jira.whamcloud.com/browse/LU-9727
Lustre-commit: 361edea47072 ("LU-9727 mdc: add uid/gid to Changelogs entries")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/28114
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Henri Doreau <henri.doreau@cea.fr>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_changelog.c           |  3 +-
 include/uapi/linux/lustre/lustre_idl.h  |  4 ++-
 include/uapi/linux/lustre/lustre_user.h | 51 +++++++++++++++++++++++++++++++--
 3 files changed, 53 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index e68ccb9..b6a26db 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -234,7 +234,8 @@ static int chlg_load(void *args)
 	rc = llog_init_handle(NULL, llh,
 			      LLOG_F_IS_CAT |
 			      LLOG_F_EXT_JOBID |
-			      LLOG_F_EXT_EXTRA_FLAGS,
+			      LLOG_F_EXT_EXTRA_FLAGS |
+			      LLOG_F_EXT_X_UIDGID,
 			      NULL);
 	if (rc) {
 		CERROR("%s: fail to init llog handle: rc = %d\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 15b0710..2c729ad 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2579,6 +2579,7 @@ enum llog_flag {
 	LLOG_F_EXT_JOBID	= 0x8,
 	LLOG_F_IS_FIXSIZE	= 0x10,
 	LLOG_F_EXT_EXTRA_FLAGS  = 0x20,
+	LLOG_F_EXT_X_UIDGID	= 0x40,
 
 	/*
 	 * Note: Flags covered by LLOG_F_EXT_MASK will be inherited from
@@ -2586,7 +2587,8 @@ enum llog_flag {
 	 * because the catlog record is usually fixed size, but its plain
 	 * log record can be variable
 	 */
-	LLOG_F_EXT_MASK = LLOG_F_EXT_JOBID | LLOG_F_EXT_EXTRA_FLAGS,
+	LLOG_F_EXT_MASK = LLOG_F_EXT_JOBID | LLOG_F_EXT_EXTRA_FLAGS |
+			  LLOG_F_EXT_X_UIDGID,
 };
 
 /* On-disk header structure of each log object, stored in little endian order */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 8e82359..ad50f95 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -973,8 +973,9 @@ static inline void hsm_set_cl_error(int *flags, int error)
 }
 
 enum changelog_rec_extra_flags {
-	CLFE_INVALID	= 0, /* No additional flags currently implemented */
-	CLFE_SUPPORTED	= CLFE_INVALID
+	CLFE_INVALID	= 0,
+	CLFE_UIDGID	= 0x0001,
+	CLFE_SUPPORTED	= CLFE_UIDGID
 };
 
 enum changelog_send_flag {
@@ -992,6 +993,11 @@ enum changelog_send_flag {
 	CHANGELOG_FLAG_EXTRA_FLAGS	= 0x08,
 };
 
+enum changelog_send_extra_flag {
+	/* Pack uid/gid into the changelog record */
+	CHANGELOG_EXTRA_FLAG_UIDGID = 0x01,
+};
+
 #define CR_MAXSIZE __ALIGN_KERNEL(2 * NAME_MAX + 2 + \
 				  changelog_rec_offset(CLF_SUPPORTED, \
 							CLFE_SUPPORTED), 8)
@@ -1037,6 +1043,12 @@ struct changelog_ext_extra_flags {
 	__u64 cr_extra_flags; /* Additional CLFE_* flags */
 };
 
+/* Changelog extra extension to include UID/GID. */
+struct changelog_ext_uidgid {
+	__u64	cr_uid;
+	__u64	cr_gid;
+};
+
 static inline struct changelog_ext_extra_flags *changelog_rec_extra_flags(
 	const struct changelog_rec *rec);
 
@@ -1051,8 +1063,11 @@ static inline size_t changelog_rec_offset(enum changelog_rec_flags crf,
 	if (crf & CLF_JOBID)
 		size += sizeof(struct changelog_ext_jobid);
 
-	if (crf & CLF_EXTRA_FLAGS)
+	if (crf & CLF_EXTRA_FLAGS) {
 		size += sizeof(struct changelog_ext_extra_flags);
+		if (cref & CLFE_UIDGID)
+			size += sizeof(struct changelog_ext_uidgid);
+	}
 
 	return size;
 }
@@ -1107,6 +1122,19 @@ struct changelog_ext_extra_flags *changelog_rec_extra_flags(
 								 CLFE_INVALID));
 }
 
+/* The uid/gid is the first extra extension */
+static inline
+struct changelog_ext_uidgid *changelog_rec_uidgid(
+	const struct changelog_rec *rec)
+{
+	enum changelog_rec_flags crf = rec->cr_flags &
+		(CLF_VERSION | CLF_RENAME | CLF_JOBID | CLF_EXTRA_FLAGS);
+
+	return (struct changelog_ext_uidgid *)((char *)rec +
+					       changelog_rec_offset(crf,
+								 CLFE_INVALID));
+}
+
 /* The name follows the rename, jobid  and extra flags extns, if present */
 static inline char *changelog_rec_name(struct changelog_rec *rec)
 {
@@ -1156,8 +1184,10 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 				       enum changelog_rec_flags crf_wanted,
 				       enum changelog_rec_extra_flags cref_want)
 {
+	char *uidgid_mov = NULL;
 	char *ef_mov;
 	char *jid_mov, *rnm_mov;
+	enum changelog_rec_extra_flags cref = CLFE_INVALID;
 
 	crf_wanted &= CLF_SUPPORTED;
 	cref_want &= CLFE_SUPPORTED;
@@ -1176,6 +1206,13 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 		changelog_rec_name(rec), rec->cr_namelen);
 
 	/* Locations of extensions in the remapped record */
+	if (rec->cr_flags & CLF_EXTRA_FLAGS) {
+		uidgid_mov = (char *)rec +
+			changelog_rec_offset(crf_wanted & CLF_SUPPORTED,
+					     CLFE_INVALID);
+		cref = changelog_rec_extra_flags(rec)->cr_extra_flags;
+	}
+
 	ef_mov  = (char *)rec +
 		  changelog_rec_offset(crf_wanted & ~CLF_EXTRA_FLAGS,
 				       CLFE_INVALID);
@@ -1193,6 +1230,10 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 	/* Move the extension fields to the desired positions */
 	if ((crf_wanted & CLF_EXTRA_FLAGS) &&
 	    (rec->cr_flags & CLF_EXTRA_FLAGS)) {
+		if ((cref_want & CLFE_UIDGID) && (cref & CLFE_UIDGID))
+			memmove(uidgid_mov, changelog_rec_uidgid(rec),
+				sizeof(struct changelog_ext_uidgid));
+
 		memmove(ef_mov, changelog_rec_extra_flags(rec),
 			sizeof(struct changelog_ext_extra_flags));
 	}
@@ -1206,6 +1247,10 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 			sizeof(struct changelog_ext_rename));
 
 	/* Clear newly added fields */
+	if (uidgid_mov && (cref_want & CLFE_UIDGID) &&
+	    !(cref & CLFE_UIDGID))
+		memset(uidgid_mov, 0, sizeof(struct changelog_ext_uidgid));
+
 	if ((crf_wanted & CLF_EXTRA_FLAGS) &&
 	    !(rec->cr_flags & CLF_EXTRA_FLAGS))
 		memset(ef_mov, 0, sizeof(struct changelog_ext_extra_flags));
-- 
1.8.3.1
