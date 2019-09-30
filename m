From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:11 -0400
Subject: [lustre-devel] [PATCH 112/151] lustre: mdc: add client NID to
 Changelogs entries
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-113-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Add a new changelog extension named changelog_ext_nid to hold
client's NID information.
NID info is added to every Changelog entry type except MARK, in
the form 'nid=<nid>':
1 01CREAT 15:50:20.834838318 2017.07.24 0x0 t=[0x200000401:0x2:0x0]
ef=0x3 u=500:500 nid=10.128.11.159 at tcp p=[0x200000007:0x1:0x0] fileA

WC-bug-id: https://jira.whamcloud.com/browse/LU-9727
Lustre-commit: d2629cfcabfa ("LU-9727 mdc: add client NID to Changelogs entries")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/28213
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_changelog.c           |  3 ++-
 include/uapi/linux/lustre/lustre_idl.h  |  3 ++-
 include/uapi/linux/lustre/lustre_user.h | 47 +++++++++++++++++++++++++++++++--
 3 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/mdc/mdc_changelog.c b/fs/lustre/mdc/mdc_changelog.c
index d9e861e..118e605 100644
--- a/fs/lustre/mdc/mdc_changelog.c
+++ b/fs/lustre/mdc/mdc_changelog.c
@@ -237,7 +237,8 @@ static int chlg_load(void *args)
 			      LLOG_F_IS_CAT |
 			      LLOG_F_EXT_JOBID |
 			      LLOG_F_EXT_EXTRA_FLAGS |
-			      LLOG_F_EXT_X_UIDGID,
+			      LLOG_F_EXT_X_UIDGID |
+			      LLOG_F_EXT_X_NID,
 			      NULL);
 	if (rc) {
 		CERROR("%s: fail to init llog handle: rc = %d\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index cf35813..c2fa26f 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2584,6 +2584,7 @@ enum llog_flag {
 	LLOG_F_IS_FIXSIZE	= 0x10,
 	LLOG_F_EXT_EXTRA_FLAGS  = 0x20,
 	LLOG_F_EXT_X_UIDGID	= 0x40,
+	LLOG_F_EXT_X_NID	= 0x80,
 
 	/*
 	 * Note: Flags covered by LLOG_F_EXT_MASK will be inherited from
@@ -2592,7 +2593,7 @@ enum llog_flag {
 	 * log record can be variable
 	 */
 	LLOG_F_EXT_MASK = LLOG_F_EXT_JOBID | LLOG_F_EXT_EXTRA_FLAGS |
-			  LLOG_F_EXT_X_UIDGID,
+			  LLOG_F_EXT_X_UIDGID | LLOG_F_EXT_X_NID,
 };
 
 /* On-disk header structure of each log object, stored in little endian order */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 36f78a6..771a2cf 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1005,7 +1005,8 @@ static inline void hsm_set_cl_error(int *flags, int error)
 enum changelog_rec_extra_flags {
 	CLFE_INVALID	= 0,
 	CLFE_UIDGID	= 0x0001,
-	CLFE_SUPPORTED	= CLFE_UIDGID
+	CLFE_NID	= 0x0002,
+	CLFE_SUPPORTED	= CLFE_UIDGID | CLFE_NID
 };
 
 enum changelog_send_flag {
@@ -1026,6 +1027,8 @@ enum changelog_send_flag {
 enum changelog_send_extra_flag {
 	/* Pack uid/gid into the changelog record */
 	CHANGELOG_EXTRA_FLAG_UIDGID = 0x01,
+	/* Pack nid into the changelog record */
+	CHANGELOG_EXTRA_FLAG_NID	= 0x02,
 };
 
 #define CR_MAXSIZE __ALIGN_KERNEL(2 * NAME_MAX + 2 + \
@@ -1068,6 +1071,15 @@ struct changelog_ext_jobid {
 	char	cr_jobid[LUSTRE_JOBID_SIZE];	/**< zero-terminated string. */
 };
 
+/* Changelog extra extension to include NID. */
+struct changelog_ext_nid {
+	/* have __u64 instead of lnet_nid_t type for use by client api */
+	__u64 cr_nid;
+	/* for use when IPv6 support is added */
+	__u64 extra;
+	__u32 padding;
+};
+
 /* Changelog extension to include additional flags. */
 struct changelog_ext_extra_flags {
 	__u64 cr_extra_flags; /* Additional CLFE_* flags */
@@ -1097,6 +1109,8 @@ static inline size_t changelog_rec_offset(enum changelog_rec_flags crf,
 		size += sizeof(struct changelog_ext_extra_flags);
 		if (cref & CLFE_UIDGID)
 			size += sizeof(struct changelog_ext_uidgid);
+		if (cref & CLFE_NID)
+			size += sizeof(struct changelog_ext_nid);
 	}
 
 	return size;
@@ -1165,6 +1179,22 @@ struct changelog_ext_uidgid *changelog_rec_uidgid(
 								 CLFE_INVALID));
 }
 
+/* The nid is the second extra extension */
+static inline
+struct changelog_ext_nid *changelog_rec_nid(const struct changelog_rec *rec)
+{
+	enum changelog_rec_flags crf = rec->cr_flags &
+		(CLF_VERSION | CLF_RENAME | CLF_JOBID | CLF_EXTRA_FLAGS);
+	enum changelog_rec_extra_flags cref = CLFE_INVALID;
+
+	if (rec->cr_flags & CLF_EXTRA_FLAGS)
+		cref = changelog_rec_extra_flags(rec)->cr_extra_flags &
+		       CLFE_UIDGID;
+
+	return (struct changelog_ext_nid *)((char *)rec +
+					    changelog_rec_offset(crf, cref));
+}
+
 /* The name follows the rename, jobid  and extra flags extns, if present */
 static inline char *changelog_rec_name(struct changelog_rec *rec)
 {
@@ -1214,6 +1244,7 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 				       enum changelog_rec_flags crf_wanted,
 				       enum changelog_rec_extra_flags cref_want)
 {
+	char *nid_mov = NULL;
 	char *uidgid_mov = NULL;
 	char *ef_mov;
 	char *jid_mov, *rnm_mov;
@@ -1237,9 +1268,13 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 
 	/* Locations of extensions in the remapped record */
 	if (rec->cr_flags & CLF_EXTRA_FLAGS) {
+		nid_mov = (char *)rec +
+			  changelog_rec_offset(crf_wanted & CLF_SUPPORTED,
+					       cref_want & ~CLFE_NID);
 		uidgid_mov = (char *)rec +
 			changelog_rec_offset(crf_wanted & CLF_SUPPORTED,
-					     CLFE_INVALID);
+					     cref_want & ~(CLFE_UIDGID |
+							   CLFE_NID));
 		cref = changelog_rec_extra_flags(rec)->cr_extra_flags;
 	}
 
@@ -1260,6 +1295,10 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 	/* Move the extension fields to the desired positions */
 	if ((crf_wanted & CLF_EXTRA_FLAGS) &&
 	    (rec->cr_flags & CLF_EXTRA_FLAGS)) {
+		if ((cref_want & CLFE_NID) && (cref & CLFE_NID))
+			memmove(nid_mov, changelog_rec_nid(rec),
+				sizeof(struct changelog_ext_nid));
+
 		if ((cref_want & CLFE_UIDGID) && (cref & CLFE_UIDGID))
 			memmove(uidgid_mov, changelog_rec_uidgid(rec),
 				sizeof(struct changelog_ext_uidgid));
@@ -1277,6 +1316,10 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 			sizeof(struct changelog_ext_rename));
 
 	/* Clear newly added fields */
+	if (nid_mov && (cref_want & CLFE_NID) &&
+	    !(cref & CLFE_NID))
+		memset(nid_mov, 0, sizeof(struct changelog_ext_nid));
+
 	if (uidgid_mov && (cref_want & CLFE_UIDGID) &&
 	    !(cref & CLFE_UIDGID))
 		memset(uidgid_mov, 0, sizeof(struct changelog_ext_uidgid));
-- 
1.8.3.1
