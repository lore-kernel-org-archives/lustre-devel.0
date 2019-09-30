From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:22 -0400
Subject: [lustre-devel] [PATCH 123/151] lustre: mdc: add CL_GETXATTR for
 Changelogs
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-124-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Record GETXATTR events in Changelogs, and add a new changelog
extension named changelog_ext_xattr to hold xattr name.
A GETXATTR changlog entry is in the following form:
8 23GXATR 09:22:55.886793012 2017.07.27 0x0
t=[0x200000402:0x1:0x0] ef=0xf u=500:500 nid=10.128.11.159 at tcp
x=user.name0
Also, rename CL_XATTR type to CL_SETXATTR.
By default, disable recording of GETXATTR events in Changelogs.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9727
Lustre-commit: c722371c1880 ("LU-9727 mdc: add CL_GETXATTR for Changelogs")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/28251
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_changelog.c           |  3 +-
 include/uapi/linux/lustre/lustre_idl.h  |  3 +-
 include/uapi/linux/lustre/lustre_user.h | 56 +++++++++++++++++++++++++++++----
 3 files changed, 54 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index 2aa4a8c..fb0de68 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -239,7 +239,8 @@ static int chlg_load(void *args)
 			      LLOG_F_EXT_EXTRA_FLAGS |
 			      LLOG_F_EXT_X_UIDGID |
 			      LLOG_F_EXT_X_NID |
-			      LLOG_F_EXT_X_OMODE,
+			      LLOG_F_EXT_X_OMODE |
+			      LLOG_F_EXT_X_XATTR,
 			      NULL);
 	if (rc) {
 		CERROR("%s: fail to init llog handle: rc = %d\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 6294eaa..1d8c607 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2541,6 +2541,7 @@ enum llog_flag {
 	LLOG_F_EXT_X_UIDGID	= 0x40,
 	LLOG_F_EXT_X_NID	= 0x80,
 	LLOG_F_EXT_X_OMODE	= 0x100,
+	LLOG_F_EXT_X_XATTR	= 0x200,
 
 	/*
 	 * Note: Flags covered by LLOG_F_EXT_MASK will be inherited from
@@ -2550,7 +2551,7 @@ enum llog_flag {
 	 */
 	LLOG_F_EXT_MASK = LLOG_F_EXT_JOBID | LLOG_F_EXT_EXTRA_FLAGS |
 			  LLOG_F_EXT_X_UIDGID | LLOG_F_EXT_X_NID |
-			  LLOG_F_EXT_X_OMODE,
+			  LLOG_F_EXT_X_OMODE | LLOG_F_EXT_X_XATTR,
 };
 
 /* On-disk header structure of each log object, stored in little endian order */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 4e673cd..8a529a1 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -932,13 +932,15 @@ enum changelog_rec_type {
 	CL_LAYOUT	= 12, /* file layout/striping modified */
 	CL_TRUNC	= 13,
 	CL_SETATTR	= 14,
-	CL_XATTR	= 15,
+	CL_SETXATTR	= 15,
+	CL_XATTR	= CL_SETXATTR, /* Deprecated name */
 	CL_HSM		= 16, /* HSM specific events, see flags */
 	CL_MTIME	= 17, /* Precedence: setattr > mtime > ctime > atime */
 	CL_CTIME	= 18,
 	CL_ATIME	= 19,
 	CL_FLRW		= 21, /* FLR: file was firstly written */
 	CL_RESYNC	= 22, /* FLR: file was resync-ed */
+	CL_GETXATTR	= 23,
 	CL_LAST
 };
 
@@ -948,7 +950,7 @@ static inline const char *changelog_type2str(int type)
 		"MARK",  "CREAT", "MKDIR", "HLINK", "SLINK", "MKNOD", "UNLNK",
 		"RMDIR", "RENME", "RNMTO", "OPEN",  "CLOSE", "LYOUT", "TRUNC",
 		"SATTR", "XATTR", "HSM",   "MTIME", "CTIME", "ATIME", "",
-		"FLRW",  "RESYNC",
+		"FLRW",  "RESYNC", "GXATTR",
 	};
 
 	if (type >= 0 && type < CL_LAST)
@@ -1056,7 +1058,8 @@ enum changelog_rec_extra_flags {
 	CLFE_UIDGID	= 0x0001,
 	CLFE_NID	= 0x0002,
 	CLFE_OPEN	= 0x0004,
-	CLFE_SUPPORTED	= CLFE_UIDGID | CLFE_NID | CLFE_OPEN
+	CLFE_XATTR	= 0x0008,
+	CLFE_SUPPORTED	= CLFE_UIDGID | CLFE_NID | CLFE_OPEN | CLFE_XATTR
 };
 
 enum changelog_send_flag {
@@ -1081,6 +1084,8 @@ enum changelog_send_extra_flag {
 	CHANGELOG_EXTRA_FLAG_NID	= 0x02,
 	/* Pack open mode into the changelog record */
 	CHANGELOG_EXTRA_FLAG_OMODE	= 0x04,
+	/* Pack xattr name into the changelog record */
+	CHANGELOG_EXTRA_FLAG_XATTR	= 0x08,
 };
 
 #define CR_MAXSIZE __ALIGN_KERNEL(2 * NAME_MAX + 2 + \
@@ -1137,6 +1142,11 @@ struct changelog_ext_openmode {
 	__u32 cr_openflags;
 };
 
+/* Changelog extra extension to include xattr */
+struct changelog_ext_xattr {
+	char cr_xattr[XATTR_NAME_MAX + 1]; /**< zero-terminated string. */
+};
+
 /* Changelog extension to include additional flags. */
 struct changelog_ext_extra_flags {
 	__u64 cr_extra_flags; /* Additional CLFE_* flags */
@@ -1170,6 +1180,8 @@ static inline size_t changelog_rec_offset(enum changelog_rec_flags crf,
 			size += sizeof(struct changelog_ext_nid);
 		if (cref & CLFE_OPEN)
 			size += sizeof(struct changelog_ext_openmode);
+		if (cref & CLFE_XATTR)
+			size += sizeof(struct changelog_ext_xattr);
 	}
 
 	return size;
@@ -1271,6 +1283,23 @@ struct changelog_ext_openmode *changelog_rec_openmode(
 						 changelog_rec_offset(crf, cref));
 }
 
+/* The xattr name is the fourth extra extension */
+static inline
+struct changelog_ext_xattr *changelog_rec_xattr(
+	const struct changelog_rec *rec)
+{
+	enum changelog_rec_flags crf = rec->cr_flags &
+		(CLF_VERSION | CLF_RENAME | CLF_JOBID | CLF_EXTRA_FLAGS);
+	enum changelog_rec_extra_flags cref = CLFE_INVALID;
+
+	if (rec->cr_flags & CLF_EXTRA_FLAGS)
+		cref = changelog_rec_extra_flags(rec)->cr_extra_flags &
+		       (CLFE_UIDGID | CLFE_NID | CLFE_OPEN);
+
+	return (struct changelog_ext_xattr *)((char *)rec +
+					      changelog_rec_offset(crf, cref));
+}
+
 /* The name follows the rename, jobid  and extra flags extns, if present */
 static inline char *changelog_rec_name(struct changelog_rec *rec)
 {
@@ -1320,6 +1349,7 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 				       enum changelog_rec_flags crf_wanted,
 				       enum changelog_rec_extra_flags cref_want)
 {
+	char *xattr_mov = NULL;
 	char *omd_mov = NULL;
 	char *nid_mov = NULL;
 	char *uidgid_mov = NULL;
@@ -1345,18 +1375,24 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 
 	/* Locations of extensions in the remapped record */
 	if (rec->cr_flags & CLF_EXTRA_FLAGS) {
+		xattr_mov = (char *)rec +
+			changelog_rec_offset(crf_wanted & CLF_SUPPORTED,
+					     cref_want & ~CLFE_XATTR);
 		omd_mov = (char *)rec +
 			changelog_rec_offset(crf_wanted & CLF_SUPPORTED,
-					     cref_want & ~CLFE_OPEN);
+					     cref_want & ~(CLFE_OPEN |
+							   CLFE_XATTR));
 		nid_mov = (char *)rec +
 			  changelog_rec_offset(crf_wanted & CLF_SUPPORTED,
 					       cref_want & ~(CLFE_NID |
-							     CLFE_OPEN));
+							     CLFE_OPEN |
+							     CLFE_XATTR));
 		uidgid_mov = (char *)rec +
 			changelog_rec_offset(crf_wanted & CLF_SUPPORTED,
 					     cref_want & ~(CLFE_UIDGID |
 							   CLFE_NID |
-							   CLFE_OPEN));
+							   CLFE_OPEN |
+							   CLFE_XATTR));
 		cref = changelog_rec_extra_flags(rec)->cr_extra_flags;
 	}
 
@@ -1377,6 +1413,10 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 	/* Move the extension fields to the desired positions */
 	if ((crf_wanted & CLF_EXTRA_FLAGS) &&
 	    (rec->cr_flags & CLF_EXTRA_FLAGS)) {
+		if ((cref_want & CLFE_XATTR) && (cref & CLFE_XATTR))
+			memmove(xattr_mov, changelog_rec_xattr(rec),
+				sizeof(struct changelog_ext_xattr));
+
 		if ((cref_want & CLFE_OPEN) && (cref & CLFE_OPEN))
 			memmove(omd_mov, changelog_rec_openmode(rec),
 				sizeof(struct changelog_ext_openmode));
@@ -1402,6 +1442,10 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 			sizeof(struct changelog_ext_rename));
 
 	/* Clear newly added fields */
+	if (xattr_mov && (cref_want & CLFE_XATTR) &&
+	    !(cref & CLFE_XATTR))
+		memset(xattr_mov, 0, sizeof(struct changelog_ext_xattr));
+
 	if (omd_mov && (cref_want & CLFE_OPEN) &&
 	    !(cref & CLFE_OPEN))
 		memset(omd_mov, 0, sizeof(struct changelog_ext_openmode));
-- 
1.8.3.1
