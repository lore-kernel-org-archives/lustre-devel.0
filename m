From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:12 -0400
Subject: [lustre-devel] [PATCH 113/151] lustre: mdc: implement CL_OPEN for
 Changelogs
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-114-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Record OPEN events in Changelogs, and add a new changelog
extension named changelog_ext_openmode to hold open mode.
An OPEN changlog entry is in the form:
7 10OPEN  13:38:51.510728296 2017.07.25 0x242
t=[0x200000401:0x2:0x0] ef=0x7 u=500:500 nid=10.128.11.159 at tcp m=-w-
By default, disable recording of OPEN events in Changelogs.
Note that CREAT are still recorded even if OPEN are disabled.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9727
Lustre-commit: 21fb4d93a94e ("LU-9727 mdc: implement CL_OPEN for Changelogs")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/28214
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_changelog.c           |  3 +-
 include/uapi/linux/lustre/lustre_idl.h  | 52 ++----------------
 include/uapi/linux/lustre/lustre_user.h | 95 +++++++++++++++++++++++++++++++--
 3 files changed, 97 insertions(+), 53 deletions(-)

diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index 118e605..2aa4a8c 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -238,7 +238,8 @@ static int chlg_load(void *args)
 			      LLOG_F_EXT_JOBID |
 			      LLOG_F_EXT_EXTRA_FLAGS |
 			      LLOG_F_EXT_X_UIDGID |
-			      LLOG_F_EXT_X_NID,
+			      LLOG_F_EXT_X_NID |
+			      LLOG_F_EXT_X_OMODE,
 			      NULL);
 	if (rc) {
 		CERROR("%s: fail to init llog handle: rc = %d\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index c2fa26f..4b33104 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1636,54 +1636,6 @@ struct mdt_rec_setattr {
 #define MDS_ATTR_BLOCKS		0x8000ULL  /* = 32768 */
 #define MDS_ATTR_PROJID		0x10000ULL /* = 65536 */
 
-#define MDS_FMODE_CLOSED	00000000
-#define MDS_FMODE_EXEC		00000004
-/*	MDS_FMODE_EPOCH		01000000 obsolete since 2.8.0 */
-/*	MDS_FMODE_TRUNC		02000000 obsolete since 2.8.0 */
-/*	MDS_FMODE_SOM		04000000 obsolete since 2.8.0 */
-
-#define MDS_OPEN_CREATED	00000010
-#define MDS_OPEN_CROSS		00000020
-
-#define MDS_OPEN_CREAT		00000100
-#define MDS_OPEN_EXCL		00000200
-#define MDS_OPEN_TRUNC		00001000
-#define MDS_OPEN_APPEND		00002000
-#define MDS_OPEN_SYNC		00010000
-#define MDS_OPEN_DIRECTORY	00200000
-
-#define MDS_OPEN_BY_FID		040000000 /* open_by_fid for known object */
-#define MDS_OPEN_DELAY_CREATE  0100000000 /* delay initial object create */
-#define MDS_OPEN_OWNEROVERRIDE 0200000000 /* NFSD rw-reopen ro file for owner */
-#define MDS_OPEN_JOIN_FILE     0400000000 /* open for join file.
-					   * We do not support JOIN FILE
-					   * anymore, reserve this flags
-					   * just for preventing such bit
-					   * to be reused.
-					   */
-
-#define MDS_OPEN_LOCK	      04000000000 /* This open requires open lock */
-#define MDS_OPEN_HAS_EA      010000000000 /* specify object create pattern */
-#define MDS_OPEN_HAS_OBJS    020000000000 /* Just set the EA the obj exist */
-#define MDS_OPEN_NORESTORE  0100000000000ULL /* Do not restore file at open */
-#define MDS_OPEN_NEWSTRIPE  0200000000000ULL /* New stripe needed (restripe or
-					      * hsm restore)
-					      */
-#define MDS_OPEN_VOLATILE   0400000000000ULL /* File is volatile = created
-					      * unlinked
-					      */
-#define MDS_OPEN_LEASE	   01000000000000ULL /* Open the file and grant lease
-					      * delegation, succeed if it's not
-					      * being opened with conflict mode.
-					      */
-#define MDS_OPEN_RELEASE   02000000000000ULL /* Open the file for HSM release */
-#define MDS_OPEN_RESYNC    04000000000000ULL /* FLR: file resync */
-
-#define MDS_OPEN_FL_INTERNAL (MDS_OPEN_HAS_EA | MDS_OPEN_HAS_OBJS |	\
-			      MDS_OPEN_OWNEROVERRIDE | MDS_OPEN_LOCK |	\
-			      MDS_OPEN_BY_FID | MDS_OPEN_LEASE |	\
-			      MDS_OPEN_RELEASE | MDS_OPEN_RESYNC)
-
 enum mds_op_bias {
 	MDS_CHECK_SPLIT		= 1 << 0,
 	MDS_CROSS_REF		= 1 << 1,
@@ -2585,6 +2537,7 @@ enum llog_flag {
 	LLOG_F_EXT_EXTRA_FLAGS  = 0x20,
 	LLOG_F_EXT_X_UIDGID	= 0x40,
 	LLOG_F_EXT_X_NID	= 0x80,
+	LLOG_F_EXT_X_OMODE	= 0x100,
 
 	/*
 	 * Note: Flags covered by LLOG_F_EXT_MASK will be inherited from
@@ -2593,7 +2546,8 @@ enum llog_flag {
 	 * log record can be variable
 	 */
 	LLOG_F_EXT_MASK = LLOG_F_EXT_JOBID | LLOG_F_EXT_EXTRA_FLAGS |
-			  LLOG_F_EXT_X_UIDGID | LLOG_F_EXT_X_NID,
+			  LLOG_F_EXT_X_UIDGID | LLOG_F_EXT_X_NID |
+			  LLOG_F_EXT_X_OMODE,
 };
 
 /* On-disk header structure of each log object, stored in little endian order */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 771a2cf..f3fa24b 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -865,6 +865,54 @@ enum la_valid {
 	LA_REMOTE_ATTR_SET = (LA_UID | LA_GID | LA_PROJID | LA_LAYOUT_VERSION)
 };
 
+#define MDS_FMODE_CLOSED	00000000
+#define MDS_FMODE_EXEC		00000004
+/*	MDS_FMODE_EPOCH		01000000 obsolete since 2.8.0 */
+/*	MDS_FMODE_TRUNC		02000000 obsolete since 2.8.0 */
+/*	MDS_FMODE_SOM		04000000 obsolete since 2.8.0 */
+
+#define MDS_OPEN_CREATED	00000010
+#define MDS_OPEN_CROSS		00000020
+
+#define MDS_OPEN_CREAT		00000100
+#define MDS_OPEN_EXCL		00000200
+#define MDS_OPEN_TRUNC		00001000
+#define MDS_OPEN_APPEND		00002000
+#define MDS_OPEN_SYNC		00010000
+#define MDS_OPEN_DIRECTORY	00200000
+
+#define MDS_OPEN_BY_FID		040000000 /* open_by_fid for known object */
+#define MDS_OPEN_DELAY_CREATE  0100000000 /* delay initial object create */
+#define MDS_OPEN_OWNEROVERRIDE 0200000000 /* NFSD rw-reopen ro file for owner */
+#define MDS_OPEN_JOIN_FILE     0400000000 /* open for join file.
+					   * We do not support JOIN FILE
+					   * anymore, reserve this flags
+					   * just for preventing such bit
+					   * to be reused.
+					   */
+
+#define MDS_OPEN_LOCK	      04000000000    /* This open requires open lock */
+#define MDS_OPEN_HAS_EA	     010000000000    /* specify object create pattern */
+#define MDS_OPEN_HAS_OBJS    020000000000    /* Just set the EA the obj exist */
+#define MDS_OPEN_NORESTORE  0100000000000ULL /* Do not restore file@open */
+#define MDS_OPEN_NEWSTRIPE  0200000000000ULL /* New stripe needed (restripe or
+					      * hsm restore)
+					      */
+#define MDS_OPEN_VOLATILE   0400000000000ULL /* File is volatile = created
+					      * unlinked
+					      */
+#define MDS_OPEN_LEASE	   01000000000000ULL /* Open the file and grant lease
+					      * delegation, succeed if it's not
+					      * being opened with conflict mode.
+					      */
+#define MDS_OPEN_RELEASE   02000000000000ULL /* Open the file for HSM release */
+#define MDS_OPEN_RESYNC    04000000000000ULL /* FLR: file resync */
+
+#define MDS_OPEN_FL_INTERNAL (MDS_OPEN_HAS_EA | MDS_OPEN_HAS_OBJS |	\
+			      MDS_OPEN_OWNEROVERRIDE | MDS_OPEN_LOCK |	\
+			      MDS_OPEN_BY_FID | MDS_OPEN_LEASE |	\
+			      MDS_OPEN_RELEASE | MDS_OPEN_RESYNC)
+
 /********* Changelogs **********/
 /** Changelog record types */
 enum changelog_rec_type {
@@ -1006,7 +1054,8 @@ enum changelog_rec_extra_flags {
 	CLFE_INVALID	= 0,
 	CLFE_UIDGID	= 0x0001,
 	CLFE_NID	= 0x0002,
-	CLFE_SUPPORTED	= CLFE_UIDGID | CLFE_NID
+	CLFE_OPEN	= 0x0004,
+	CLFE_SUPPORTED	= CLFE_UIDGID | CLFE_NID | CLFE_OPEN
 };
 
 enum changelog_send_flag {
@@ -1029,6 +1078,8 @@ enum changelog_send_extra_flag {
 	CHANGELOG_EXTRA_FLAG_UIDGID = 0x01,
 	/* Pack nid into the changelog record */
 	CHANGELOG_EXTRA_FLAG_NID	= 0x02,
+	/* Pack open mode into the changelog record */
+	CHANGELOG_EXTRA_FLAG_OMODE	= 0x04,
 };
 
 #define CR_MAXSIZE __ALIGN_KERNEL(2 * NAME_MAX + 2 + \
@@ -1080,6 +1131,11 @@ struct changelog_ext_nid {
 	__u32 padding;
 };
 
+/* Changelog extra extension to include OPEN mode. */
+struct changelog_ext_openmode {
+	__u32 cr_openflags;
+};
+
 /* Changelog extension to include additional flags. */
 struct changelog_ext_extra_flags {
 	__u64 cr_extra_flags; /* Additional CLFE_* flags */
@@ -1111,6 +1167,8 @@ static inline size_t changelog_rec_offset(enum changelog_rec_flags crf,
 			size += sizeof(struct changelog_ext_uidgid);
 		if (cref & CLFE_NID)
 			size += sizeof(struct changelog_ext_nid);
+		if (cref & CLFE_OPEN)
+			size += sizeof(struct changelog_ext_openmode);
 	}
 
 	return size;
@@ -1195,6 +1253,23 @@ struct changelog_ext_nid *changelog_rec_nid(const struct changelog_rec *rec)
 					    changelog_rec_offset(crf, cref));
 }
 
+/* The OPEN mode is the third extra extension */
+static inline
+struct changelog_ext_openmode *changelog_rec_openmode(
+	const struct changelog_rec *rec)
+{
+	enum changelog_rec_flags crf = rec->cr_flags &
+		(CLF_VERSION | CLF_RENAME | CLF_JOBID | CLF_EXTRA_FLAGS);
+	enum changelog_rec_extra_flags cref = CLFE_INVALID;
+
+	if (rec->cr_flags & CLF_EXTRA_FLAGS)
+		cref = changelog_rec_extra_flags(rec)->cr_extra_flags &
+		       (CLFE_UIDGID | CLFE_NID);
+
+	return (struct changelog_ext_openmode *)((char *)rec +
+						 changelog_rec_offset(crf, cref));
+}
+
 /* The name follows the rename, jobid  and extra flags extns, if present */
 static inline char *changelog_rec_name(struct changelog_rec *rec)
 {
@@ -1244,6 +1319,7 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 				       enum changelog_rec_flags crf_wanted,
 				       enum changelog_rec_extra_flags cref_want)
 {
+	char *omd_mov = NULL;
 	char *nid_mov = NULL;
 	char *uidgid_mov = NULL;
 	char *ef_mov;
@@ -1268,13 +1344,18 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 
 	/* Locations of extensions in the remapped record */
 	if (rec->cr_flags & CLF_EXTRA_FLAGS) {
+		omd_mov = (char *)rec +
+			changelog_rec_offset(crf_wanted & CLF_SUPPORTED,
+					     cref_want & ~CLFE_OPEN);
 		nid_mov = (char *)rec +
 			  changelog_rec_offset(crf_wanted & CLF_SUPPORTED,
-					       cref_want & ~CLFE_NID);
+					       cref_want & ~(CLFE_NID |
+							     CLFE_OPEN));
 		uidgid_mov = (char *)rec +
 			changelog_rec_offset(crf_wanted & CLF_SUPPORTED,
 					     cref_want & ~(CLFE_UIDGID |
-							   CLFE_NID));
+							   CLFE_NID |
+							   CLFE_OPEN));
 		cref = changelog_rec_extra_flags(rec)->cr_extra_flags;
 	}
 
@@ -1295,6 +1376,10 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 	/* Move the extension fields to the desired positions */
 	if ((crf_wanted & CLF_EXTRA_FLAGS) &&
 	    (rec->cr_flags & CLF_EXTRA_FLAGS)) {
+		if ((cref_want & CLFE_OPEN) && (cref & CLFE_OPEN))
+			memmove(omd_mov, changelog_rec_openmode(rec),
+				sizeof(struct changelog_ext_openmode));
+
 		if ((cref_want & CLFE_NID) && (cref & CLFE_NID))
 			memmove(nid_mov, changelog_rec_nid(rec),
 				sizeof(struct changelog_ext_nid));
@@ -1316,6 +1401,10 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 			sizeof(struct changelog_ext_rename));
 
 	/* Clear newly added fields */
+	if (omd_mov && (cref_want & CLFE_OPEN) &&
+	    !(cref & CLFE_OPEN))
+		memset(omd_mov, 0, sizeof(struct changelog_ext_openmode));
+
 	if (nid_mov && (cref_want & CLFE_NID) &&
 	    !(cref & CLFE_NID))
 		memset(nid_mov, 0, sizeof(struct changelog_ext_nid));
-- 
1.8.3.1
