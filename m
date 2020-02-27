From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:56 -0500
Subject: [lustre-devel] [PATCH 428/622] lustre: uapi: Make lustre_user.h
 c++-legal
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-429-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Rob Latham <robl@mcs.anl.gov>

recent c++ compilers did not like some of the C idioms used in this
header:
  - C++ checks the types of enums more forecfully than is done in C
  - signed vs unsigned comparisons will generate a warning under g++
  - "invalid suffix on literal" warning: Lustre is not trying to
    generate a new literal identifier.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12527
Lustre-commit: 14b11dc3526a ("LU-12527 utils: Make lustre_user.h c++-legal")
Signed-off-by: Rob Latham <robl@mcs.anl.gov>
Reviewed-on: https://review.whamcloud.com/35471
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_user.h | 139 +++++++++++++++++++-------------
 1 file changed, 84 insertions(+), 55 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index db36ce5..3016b73 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -885,7 +885,7 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 
 #define ALLQUOTA 255	/* set all quota */
 
-static inline char *qtype_name(int qtype)
+static inline const char *qtype_name(int qtype)
 {
 	switch (qtype) {
 	case USRQUOTA:
@@ -1206,7 +1206,8 @@ static inline enum hsm_event hsm_get_cl_event(__u16 flags)
 static inline void hsm_set_cl_event(enum changelog_rec_flags *clf_flags,
 				    enum hsm_event he)
 {
-	*clf_flags |= (he << CLF_HSM_EVENT_L);
+	*clf_flags = (enum changelog_rec_flags)
+		(*clf_flags | (he << CLF_HSM_EVENT_L));
 }
 
 static inline __u16 hsm_get_cl_flags(enum changelog_rec_flags clf_flags)
@@ -1217,7 +1218,8 @@ static inline __u16 hsm_get_cl_flags(enum changelog_rec_flags clf_flags)
 static inline void hsm_set_cl_flags(enum changelog_rec_flags *clf_flags,
 				    unsigned int bits)
 {
-	*clf_flags |= (bits << CLF_HSM_FLAG_L);
+	*clf_flags = (enum changelog_rec_flags)
+		(*clf_flags | (bits << CLF_HSM_FLAG_L));
 }
 
 static inline int hsm_get_cl_error(enum changelog_rec_flags clf_flags)
@@ -1228,7 +1230,8 @@ static inline int hsm_get_cl_error(enum changelog_rec_flags clf_flags)
 static inline void hsm_set_cl_error(enum changelog_rec_flags *clf_flags,
 				    unsigned int error)
 {
-	*clf_flags |= (error << CLF_HSM_ERR_L);
+	*clf_flags = (enum changelog_rec_flags)
+		(*clf_flags | (error << CLF_HSM_ERR_L));
 }
 
 enum changelog_rec_extra_flags {
@@ -1370,9 +1373,11 @@ static inline size_t changelog_rec_size(struct changelog_rec *rec)
 	enum changelog_rec_extra_flags cref = CLFE_INVALID;
 
 	if (rec->cr_flags & CLF_EXTRA_FLAGS)
-		cref = changelog_rec_extra_flags(rec)->cr_extra_flags;
+		cref = (enum changelog_rec_extra_flags)
+		       changelog_rec_extra_flags(rec)->cr_extra_flags;
 
-	return changelog_rec_offset(rec->cr_flags, cref);
+	return changelog_rec_offset((enum changelog_rec_flags)rec->cr_flags,
+				    cref);
 }
 
 static inline size_t changelog_rec_varsize(struct changelog_rec *rec)
@@ -1383,7 +1388,8 @@ static inline size_t changelog_rec_varsize(struct changelog_rec *rec)
 static inline
 struct changelog_ext_rename *changelog_rec_rename(struct changelog_rec *rec)
 {
-	enum changelog_rec_flags crf = rec->cr_flags & CLF_VERSION;
+	enum changelog_rec_flags crf = (enum changelog_rec_flags)
+				       (rec->cr_flags & CLF_VERSION);
 
 	return (struct changelog_ext_rename *)((char *)rec +
 					       changelog_rec_offset(crf,
@@ -1394,8 +1400,8 @@ struct changelog_ext_rename *changelog_rec_rename(struct changelog_rec *rec)
 static inline
 struct changelog_ext_jobid *changelog_rec_jobid(struct changelog_rec *rec)
 {
-	enum changelog_rec_flags crf = rec->cr_flags &
-				       (CLF_VERSION | CLF_RENAME);
+	enum changelog_rec_flags crf = (enum changelog_rec_flags)
+				       (rec->cr_flags & (CLF_VERSION | CLF_RENAME));
 
 	return (struct changelog_ext_jobid *)((char *)rec +
 					      changelog_rec_offset(crf,
@@ -1407,8 +1413,8 @@ struct changelog_ext_jobid *changelog_rec_jobid(struct changelog_rec *rec)
 struct changelog_ext_extra_flags *changelog_rec_extra_flags(
 	const struct changelog_rec *rec)
 {
-	enum changelog_rec_flags crf = rec->cr_flags &
-		(CLF_VERSION | CLF_RENAME | CLF_JOBID);
+	enum changelog_rec_flags crf = (enum changelog_rec_flags)
+		(rec->cr_flags & (CLF_VERSION | CLF_RENAME | CLF_JOBID));
 
 	return (struct changelog_ext_extra_flags *)((char *)rec +
 						 changelog_rec_offset(crf,
@@ -1420,8 +1426,9 @@ struct changelog_ext_extra_flags *changelog_rec_extra_flags(
 struct changelog_ext_uidgid *changelog_rec_uidgid(
 	const struct changelog_rec *rec)
 {
-	enum changelog_rec_flags crf = rec->cr_flags &
-		(CLF_VERSION | CLF_RENAME | CLF_JOBID | CLF_EXTRA_FLAGS);
+	enum changelog_rec_flags crf = (enum changelog_rec_flags)
+		(rec->cr_flags &
+		 (CLF_VERSION | CLF_RENAME | CLF_JOBID | CLF_EXTRA_FLAGS));
 
 	return (struct changelog_ext_uidgid *)((char *)rec +
 					       changelog_rec_offset(crf,
@@ -1432,13 +1439,15 @@ struct changelog_ext_uidgid *changelog_rec_uidgid(
 static inline
 struct changelog_ext_nid *changelog_rec_nid(const struct changelog_rec *rec)
 {
-	enum changelog_rec_flags crf = rec->cr_flags &
-		(CLF_VERSION | CLF_RENAME | CLF_JOBID | CLF_EXTRA_FLAGS);
+	enum changelog_rec_flags crf = (enum changelog_rec_flags)
+		(rec->cr_flags &
+		 (CLF_VERSION | CLF_RENAME | CLF_JOBID | CLF_EXTRA_FLAGS));
 	enum changelog_rec_extra_flags cref = CLFE_INVALID;
 
 	if (rec->cr_flags & CLF_EXTRA_FLAGS)
-		cref = changelog_rec_extra_flags(rec)->cr_extra_flags &
-		       CLFE_UIDGID;
+		cref = (enum changelog_rec_extra_flags)
+			(changelog_rec_extra_flags(rec)->cr_extra_flags &
+			 CLFE_UIDGID);
 
 	return (struct changelog_ext_nid *)((char *)rec +
 					    changelog_rec_offset(crf, cref));
@@ -1449,13 +1458,16 @@ struct changelog_ext_nid *changelog_rec_nid(const struct changelog_rec *rec)
 struct changelog_ext_openmode *changelog_rec_openmode(
 	const struct changelog_rec *rec)
 {
-	enum changelog_rec_flags crf = rec->cr_flags &
-		(CLF_VERSION | CLF_RENAME | CLF_JOBID | CLF_EXTRA_FLAGS);
+	enum changelog_rec_flags crf = (enum changelog_rec_flags)
+		(rec->cr_flags &
+		 (CLF_VERSION | CLF_RENAME | CLF_JOBID | CLF_EXTRA_FLAGS));
 	enum changelog_rec_extra_flags cref = CLFE_INVALID;
 
-	if (rec->cr_flags & CLF_EXTRA_FLAGS)
-		cref = changelog_rec_extra_flags(rec)->cr_extra_flags &
-		       (CLFE_UIDGID | CLFE_NID);
+	if (rec->cr_flags & CLF_EXTRA_FLAGS) {
+		cref = (enum changelog_rec_extra_flags)
+			(changelog_rec_extra_flags(rec)->cr_extra_flags &
+			 (CLFE_UIDGID | CLFE_NID));
+	}
 
 	return (struct changelog_ext_openmode *)((char *)rec +
 						 changelog_rec_offset(crf, cref));
@@ -1466,13 +1478,15 @@ struct changelog_ext_openmode *changelog_rec_openmode(
 struct changelog_ext_xattr *changelog_rec_xattr(
 	const struct changelog_rec *rec)
 {
-	enum changelog_rec_flags crf = rec->cr_flags &
-		(CLF_VERSION | CLF_RENAME | CLF_JOBID | CLF_EXTRA_FLAGS);
+	enum changelog_rec_flags crf = (enum changelog_rec_flags)
+		(rec->cr_flags &
+		 (CLF_VERSION | CLF_RENAME | CLF_JOBID | CLF_EXTRA_FLAGS));
 	enum changelog_rec_extra_flags cref = CLFE_INVALID;
 
 	if (rec->cr_flags & CLF_EXTRA_FLAGS)
-		cref = changelog_rec_extra_flags(rec)->cr_extra_flags &
-		       (CLFE_UIDGID | CLFE_NID | CLFE_OPEN);
+		cref = (enum changelog_rec_extra_flags)
+			(changelog_rec_extra_flags(rec)->cr_extra_flags &
+		         (CLFE_UIDGID | CLFE_NID | CLFE_OPEN));
 
 	return (struct changelog_ext_xattr *)((char *)rec +
 					      changelog_rec_offset(crf, cref));
@@ -1484,10 +1498,12 @@ static inline char *changelog_rec_name(struct changelog_rec *rec)
 	enum changelog_rec_extra_flags cref = CLFE_INVALID;
 
 	if (rec->cr_flags & CLF_EXTRA_FLAGS)
-		cref = changelog_rec_extra_flags(rec)->cr_extra_flags;
+		cref = (enum changelog_rec_extra_flags)
+			changelog_rec_extra_flags(rec)->cr_extra_flags;
 
-	return (char *)rec + changelog_rec_offset(rec->cr_flags & CLF_SUPPORTED,
-						  cref & CLFE_SUPPORTED);
+	return (char *)rec + changelog_rec_offset(
+		(enum changelog_rec_flags)(rec->cr_flags & CLF_SUPPORTED),
+		(enum changelog_rec_extra_flags)(cref & CLFE_SUPPORTED));
 }
 
 static inline size_t changelog_rec_snamelen(struct changelog_rec *rec)
@@ -1535,8 +1551,10 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 	char *jid_mov, *rnm_mov;
 	enum changelog_rec_extra_flags cref = CLFE_INVALID;
 
-	crf_wanted &= CLF_SUPPORTED;
-	cref_want &= CLFE_SUPPORTED;
+	crf_wanted = (enum changelog_rec_flags)
+		      (crf_wanted & CLF_SUPPORTED);
+	cref_want = (enum changelog_rec_extra_flags)
+		     (cref_want & CLFE_SUPPORTED);
 
 	if ((rec->cr_flags & CLF_SUPPORTED) == crf_wanted) {
 		if (!(rec->cr_flags & CLF_EXTRA_FLAGS) ||
@@ -1554,38 +1572,49 @@ static inline void changelog_remap_rec(struct changelog_rec *rec,
 	/* Locations of extensions in the remapped record */
 	if (rec->cr_flags & CLF_EXTRA_FLAGS) {
 		xattr_mov = (char *)rec +
-			changelog_rec_offset(crf_wanted & CLF_SUPPORTED,
-					     cref_want & ~CLFE_XATTR);
+			    changelog_rec_offset((enum changelog_rec_flags)
+						  (crf_wanted & CLF_SUPPORTED),
+						 (enum changelog_rec_extra_flags)
+						  (cref_want & ~CLFE_XATTR));
 		omd_mov = (char *)rec +
-			changelog_rec_offset(crf_wanted & CLF_SUPPORTED,
-					     cref_want & ~(CLFE_OPEN |
-							   CLFE_XATTR));
+			  changelog_rec_offset((enum changelog_rec_flags)
+						(crf_wanted & CLF_SUPPORTED),
+					       (enum changelog_rec_extra_flags)
+					        (cref_want & ~(CLFE_OPEN |
+							       CLFE_XATTR)));
 		nid_mov = (char *)rec +
-			  changelog_rec_offset(crf_wanted & CLF_SUPPORTED,
-					       cref_want & ~(CLFE_NID |
-							     CLFE_OPEN |
-							     CLFE_XATTR));
+			  changelog_rec_offset((enum changelog_rec_flags)
+						(crf_wanted & CLF_SUPPORTED),
+					       (enum changelog_rec_extra_flags)
+					        (cref_want & ~(CLFE_NID |
+							       CLFE_OPEN |
+							       CLFE_XATTR)));
 		uidgid_mov = (char *)rec +
-			changelog_rec_offset(crf_wanted & CLF_SUPPORTED,
-					     cref_want & ~(CLFE_UIDGID |
-							   CLFE_NID |
-							   CLFE_OPEN |
-							   CLFE_XATTR));
-		cref = changelog_rec_extra_flags(rec)->cr_extra_flags;
+			     changelog_rec_offset((enum changelog_rec_flags)
+						   (crf_wanted & CLF_SUPPORTED),
+					          (enum changelog_rec_extra_flags)
+					           (cref_want & ~(CLFE_UIDGID |
+								  CLFE_NID |
+								  CLFE_OPEN |
+								  CLFE_XATTR)));
+		cref = (enum changelog_rec_extra_flags)
+		       changelog_rec_extra_flags(rec)->cr_extra_flags;
 	}
 
 	ef_mov  = (char *)rec +
-		  changelog_rec_offset(crf_wanted & ~CLF_EXTRA_FLAGS,
-				       CLFE_INVALID);
+		  changelog_rec_offset((enum changelog_rec_flags)
+					(crf_wanted & ~CLF_EXTRA_FLAGS),
+				        CLFE_INVALID);
 	jid_mov = (char *)rec +
-		  changelog_rec_offset(crf_wanted &
-				       ~(CLF_EXTRA_FLAGS | CLF_JOBID),
+		  changelog_rec_offset((enum changelog_rec_flags)
+					(crf_wanted & ~(CLF_EXTRA_FLAGS |
+							CLF_JOBID)),
 				       CLFE_INVALID);
 	rnm_mov = (char *)rec +
-		  changelog_rec_offset(crf_wanted &
-				       ~(CLF_EXTRA_FLAGS |
-					 CLF_JOBID |
-					 CLF_RENAME),
+		  changelog_rec_offset((enum changelog_rec_flags)
+					(crf_wanted & ~(CLF_EXTRA_FLAGS |
+							CLF_JOBID |
+							CLF_RENAME)),
 				       CLFE_INVALID);
 
 	/* Move the extension fields to the desired positions */
@@ -1824,7 +1853,7 @@ static inline ssize_t hur_len(struct hsm_user_request *hur)
 		(__u64)hur->hur_request.hr_itemcount *
 		sizeof(hur->hur_user_item[0]) + hur->hur_request.hr_data_len;
 
-	if (size != (ssize_t)size)
+	if ((ssize_t)size < 0)
 		return -1;
 
 	return size;
-- 
1.8.3.1
