From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:32 -0500
Subject: [lustre-devel] [PATCH 164/622] lustre: hsm: make changelog flag
 argument an enum
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-165-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Since the changelog record flag is being stored on disk, pass it
around as an enum instead of a signed int.  Also make it clear at
the caller that only the low 12 bits of the flag are normally
being stored in the changelog records, since this isn't obvious
to the reader. For open and close records, the bottom 32 bits
of open flags are recorded.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10030
Lustre-commit: 2496089a0017 ("LU-10030 hsm: make changelog flag argument an enum")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32112
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_user.h | 34 ++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 5551cbf..3bd6fc7 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1019,16 +1019,17 @@ static inline const char *changelog_type2str(int type)
 	return NULL;
 }
 
-/* per-record flags */
+/* 12 bits of per-record data can be stored in the bottom of the flags */
 #define CLF_FLAGSHIFT   12
-#define CLF_FLAGMASK    ((1U << CLF_FLAGSHIFT) - 1)
-#define CLF_VERMASK     (~CLF_FLAGMASK)
 enum changelog_rec_flags {
 	CLF_VERSION	= 0x1000,
 	CLF_RENAME	= 0x2000,
 	CLF_JOBID	= 0x4000,
 	CLF_EXTRA_FLAGS = 0x8000,
-	CLF_SUPPORTED	= CLF_VERSION | CLF_RENAME | CLF_JOBID | CLF_EXTRA_FLAGS
+	CLF_SUPPORTED	= CLF_VERSION | CLF_RENAME | CLF_JOBID |
+			  CLF_EXTRA_FLAGS,
+	CLF_FLAGMASK	= (1U << CLF_FLAGSHIFT) - 1,
+	CLF_VERMASK	= ~CLF_FLAGMASK,
 };
 
 /* Anything under the flagmask may be per-type (if desired) */
@@ -1089,29 +1090,32 @@ static inline enum hsm_event hsm_get_cl_event(__u16 flags)
 	return CLF_GET_BITS(flags, CLF_HSM_EVENT_H, CLF_HSM_EVENT_L);
 }
 
-static inline void hsm_set_cl_event(int *flags, enum hsm_event he)
+static inline void hsm_set_cl_event(enum changelog_rec_flags *clf_flags,
+				    enum hsm_event he)
 {
-	*flags |= (he << CLF_HSM_EVENT_L);
+	*clf_flags |= (he << CLF_HSM_EVENT_L);
 }
 
-static inline __u16 hsm_get_cl_flags(int flags)
+static inline __u16 hsm_get_cl_flags(enum changelog_rec_flags clf_flags)
 {
-	return CLF_GET_BITS(flags, CLF_HSM_FLAG_H, CLF_HSM_FLAG_L);
+	return CLF_GET_BITS(clf_flags, CLF_HSM_FLAG_H, CLF_HSM_FLAG_L);
 }
 
-static inline void hsm_set_cl_flags(int *flags, int bits)
+static inline void hsm_set_cl_flags(enum changelog_rec_flags *clf_flags,
+				    unsigned int bits)
 {
-	*flags |= (bits << CLF_HSM_FLAG_L);
+	*clf_flags |= (bits << CLF_HSM_FLAG_L);
 }
 
-static inline int hsm_get_cl_error(int flags)
+static inline int hsm_get_cl_error(enum changelog_rec_flags clf_flags)
 {
-	return CLF_GET_BITS(flags, CLF_HSM_ERR_H, CLF_HSM_ERR_L);
+	return CLF_GET_BITS(clf_flags, CLF_HSM_ERR_H, CLF_HSM_ERR_L);
 }
 
-static inline void hsm_set_cl_error(int *flags, int error)
+static inline void hsm_set_cl_error(enum changelog_rec_flags *clf_flags,
+				    unsigned int error)
 {
-	*flags |= (error << CLF_HSM_ERR_L);
+	*clf_flags |= (error << CLF_HSM_ERR_L);
 }
 
 enum changelog_rec_extra_flags {
@@ -1198,7 +1202,7 @@ struct changelog_ext_nid {
 	__u32 padding;
 };
 
-/* Changelog extra extension to include OPEN mode. */
+/* Changelog extra extension to include low 32 bits of MDS_OPEN_* flags. */
 struct changelog_ext_openmode {
 	__u32 cr_openflags;
 };
-- 
1.8.3.1
