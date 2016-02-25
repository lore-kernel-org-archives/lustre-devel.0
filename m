From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:00 -0500
Subject: [lustre-devel] [PATCH v2 17/84] staging/lustre: Get rid of
	lustre_fid typedef
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-18-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with struct lu_fid

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |  2 +-
 .../lustre/lustre/include/lustre/lustre_user.h     | 24 +++++++++++-----------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index af70ebb..4188402 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -3550,7 +3550,7 @@ void lustre_swab_layout_intent(struct layout_intent *li);
  */
 struct hsm_progress_kernel {
 	/* Field taken from struct hsm_progress */
-	lustre_fid		hpk_fid;
+	struct lu_fid		hpk_fid;
 	__u64			hpk_cookie;
 	struct hsm_extent	hpk_extent;
 	__u16			hpk_flags;
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 2b4dd65..a4765c2 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -136,7 +136,7 @@ struct filter_fid_old {
 /* Userspace should treat lu_fid as opaque, and only use the following methods
  * to print or parse them.  Other functions (e.g. compare, swab) could be moved
  * here from lustre_idl.h if needed. */
-typedef struct lu_fid lustre_fid;
+struct lu_fid;
 
 /**
  * Following struct for object attributes, that will be kept inode's EA.
@@ -761,10 +761,10 @@ struct changelog_rec {
 	__u64		 cr_prev;  /**< last index for this target fid */
 	__u64		 cr_time;
 	union {
-		lustre_fid    cr_tfid;	/**< target fid */
+		struct lu_fid    cr_tfid;	/**< target fid */
 		__u32	 cr_markerflags; /**< CL_MARK flags */
 	};
-	lustre_fid	    cr_pfid;	/**< parent fid */
+	struct lu_fid	    cr_pfid;	/**< parent fid */
 	char		  cr_name[0];     /**< last element */
 } __packed;
 
@@ -781,12 +781,12 @@ struct changelog_ext_rec {
 	__u64			cr_prev;  /**< last index for this target fid */
 	__u64			cr_time;
 	union {
-		lustre_fid	cr_tfid;	/**< target fid */
+		struct lu_fid	cr_tfid;	/**< target fid */
 		__u32		cr_markerflags; /**< CL_MARK flags */
 	};
-	lustre_fid		cr_pfid;	/**< target parent fid */
-	lustre_fid		cr_sfid;	/**< source fid, or zero */
-	lustre_fid		cr_spfid;       /**< source parent fid, or zero */
+	struct lu_fid		cr_pfid;	/**< target parent fid */
+	struct lu_fid		cr_sfid;	/**< source fid, or zero */
+	struct lu_fid		cr_spfid;     /**< source parent fid, or zero */
 	char			cr_name[0];     /**< last element */
 } __packed;
 
@@ -976,8 +976,8 @@ struct hsm_request {
 };
 
 struct hsm_user_item {
-       lustre_fid	hui_fid;
-       struct hsm_extent hui_extent;
+	struct lu_fid	hui_fid;
+	struct hsm_extent hui_extent;
 } __packed;
 
 struct hsm_user_request {
@@ -1046,8 +1046,8 @@ static inline char *hsm_copytool_action2name(enum hsm_copytool_action  a)
 struct hsm_action_item {
 	__u32      hai_len;     /* valid size of this struct */
 	__u32      hai_action;  /* hsm_copytool_action, but use known size */
-	lustre_fid hai_fid;     /* Lustre FID to operated on */
-	lustre_fid hai_dfid;    /* fid used for data access */
+	struct lu_fid hai_fid;     /* Lustre FID to operated on */
+	struct lu_fid hai_dfid;    /* fid used for data access */
 	struct hsm_extent hai_extent;  /* byte range to operate on */
 	__u64      hai_cookie;  /* action cookie from coordinator */
 	__u64      hai_gid;     /* grouplock id */
@@ -1157,7 +1157,7 @@ struct hsm_user_import {
 #define HP_FLAG_RETRY     0x02
 
 struct hsm_progress {
-	lustre_fid		hp_fid;
+	struct lu_fid		hp_fid;
 	__u64			hp_cookie;
 	struct hsm_extent	hp_extent;
 	__u16			hp_flags;
-- 
2.1.0
