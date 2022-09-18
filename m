Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 19794C32771
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:32 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbm53QsQz1yD0;
	Sat, 17 Sep 2022 22:22:29 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVblv32ZQz1wLC
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:19 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id D1067367;
 Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C3AF2F64; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:21:51 -0400
Message-Id: <1663478534-19917-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/24] lustre: dne: add crush2 hash type
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

The original "crush" hash type has a significant error with files
that have all-number suffixes, or suffixes that have non-alpha
characters in them.  These files will all be placed on the same
MDT as the base filename, which causes MDT imbalance.

Add a "crush2" hash type that has more stringent checks for the
suffix, so that it doesn't consider all-digit suffixes, or files
that only have a '.' at the right offset, as temporary files.

Test that the "broken" all-digit or extra-'.' filenames are hashed
properly with "crush2".  We also need to confirm that the old "crush"
hash has not changed (for name lookup compatibility) and still has
the original "bad hashing" bug that puts all files on the same MDT.

Fix handling of types beyond MDT_HASH_TYPE_CRUSH when creating dirs.

Fix debug layout printing of hash_type in more parts of the code.
Don't flood console if hash type is unrecognized in the future.

Fixes: d956d88c463f ("lustre: dne: introduce new directory hash type 'crush'")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15720
Lustre-commit: 1ac4b9598ad6e2f94 ("LU-15720 dne: add crush2 hash type")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47015
Tested-by: Shuichi Ihara <sihara@ddn.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h           | 64 ++++++++++++++++++++++++++++-----
 fs/lustre/include/lustre_lmv.h          | 60 +++++++++++++++++--------------
 fs/lustre/include/obd_support.h         |  2 +-
 fs/lustre/llite/dir.c                   |  9 +++--
 fs/lustre/llite/namei.c                 |  2 --
 fs/lustre/lmv/lmv_obd.c                 |  4 +--
 include/uapi/linux/lustre/lustre_user.h | 15 ++++----
 7 files changed, 105 insertions(+), 51 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index e4dd287c5..5c7f439 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1290,8 +1290,29 @@ static inline bool lu_name_is_dot_or_dotdot(const struct lu_name *lname)
 	return name_is_dot_or_dotdot(lname->ln_name, lname->ln_namelen);
 }
 
+/**
+ * Determine if filename should be considered a "temporary" name.
+ *
+ * For temporary names, use only the main part of the filename and ignore
+ * the suffix, so that the filename will hash to the same MDT after it is
+ * renamed.  That avoids creating spurious remote entries for rsync, dcp,
+ * vi, and other tools that create a temporary name before renaming the file.
+ *
+ * The "CRUSH" and "CRUSH2" hash types are slightly different, and should
+ * not be modified without introducing a new hash type.  The hash algorithm
+ * forms an important part of the network protocol for striped directories,
+ * so if the hash function were "fixed" in any way it would prevent clients
+ * from looking up a filename on the right MDT.  LU-15692.
+ *
+ * @name		filename
+ * @namelen		length of @name
+ * @dot_prefix		if @name needs a leading '.' to be temporary
+ * @suffixlen		number of characters after '.' in @name to check
+ * @crush2		whether CRUSH or CRUSH2 heuristic should be used
+ */
 static inline bool lu_name_is_temp_file(const char *name, int namelen,
-					bool dot_prefix, int suffixlen)
+					bool dot_prefix, int suffixlen,
+					bool crush2)
 {
 	int lower = 0;
 	int upper = 0;
@@ -1305,21 +1326,46 @@ static inline bool lu_name_is_temp_file(const char *name, int namelen,
 	    name[namelen - suffixlen - 1] != '.')
 		return false;
 
+	/* Any non-alphanumeric chars in the suffix for CRUSH2 mean the
+	 * filename is *not* temporary.  The original CRUSH was incorrectly
+	 * matching if a '.' happens to be in the right place, for example
+	 * file.mdtest.12.12345 or output.6334.log, which is bad.  LU-15692
+	 */
 	while (len) {
-		lower += islower(name[namelen - len]);
-		upper += isupper(name[namelen - len]);
-		digit += isdigit(name[namelen - len]);
+		if (islower(name[namelen - len]))
+			lower++;
+		else if (isupper(name[namelen - len]))
+			upper++;
+		else if (isdigit(name[namelen - len]))
+			digit++;
+		else if (crush2)
+			return false;
 		len--;
 	}
-	/* mktemp() filename suffixes will have a mix of upper- and lower-case
-	 * letters and/or numbers, not all numbers, or all upper or lower-case.
-	 * About 0.07% of randomly-generated names will slip through,
+
+	/* mktemp() suffixes normally have a mix of upper- and lower-case
+	 * letters and/or digits, rarely all upper- or lower-case or digits.
+	 * Random all-digit suffixes are rare (1/45k for suffixlen=6), but
+	 * common in normal usage (incrementing versions, dates, ranks, etc),
+	 * so are considered non-temporary even if 1 or 2 non-numeric chars.
+	 *
+	 * About 0.07% of randomly-generated names will slip through, which
+	 * only means that they may be renamed to a different MDT (slowdown),
 	 * but this avoids 99.93% of cross-MDT renames for those files.
 	 */
-	if ((digit >= suffixlen - 1 && !isdigit(name[namelen - suffixlen])) ||
-	    upper == suffixlen || lower == suffixlen)
+	if (upper == suffixlen || lower == suffixlen)
 		return false;
 
+	if (crush2) {
+		if (digit >= suffixlen - 1 &&
+		    isdigit(name[namelen - suffixlen]))
+			return false;
+	} else { /* old crush incorrectly returns "true" for all-digit suffix */
+		if (digit >= suffixlen - 1 &&
+		    !isdigit(name[namelen - suffixlen]))
+			return false;
+	}
+
 	return true;
 }
 
diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index 3720a97..a2ef550 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -121,21 +121,20 @@ static inline bool lmv_dir_bad_hash(const struct lmv_stripe_md *lsm)
 
 static inline void lsm_md_dump(int mask, const struct lmv_stripe_md *lsm)
 {
-	bool valid_hash = lmv_dir_bad_hash(lsm);
 	int i;
 
-	/* If lsm_md_magic == LMV_MAGIC_FOREIGN pool_name may not be a null
-	 * terminated string so only print LOV_MAXPOOLNAME bytes.
-	 */
-	CDEBUG(mask,
-	       "magic %#x stripe count %d master mdt %d hash type %s:%#x max-inherit %hhu max-inherit-rr %hhu version %d migrate offset %d migrate hash %#x pool %.*s\n",
+	CDEBUG_LIMIT(mask,
+	       "dump LMV: magic=%#x count=%u index=%u hash=%s:%#x max_inherit=%hhu max_inherit_rr=%hhu version=%u migrate_offset=%u migrate_hash=%s:%x pool=%.*s\n",
 	       lsm->lsm_md_magic, lsm->lsm_md_stripe_count,
 	       lsm->lsm_md_master_mdt_index,
-	       valid_hash ? "invalid hash" :
-			    mdt_hash_name[lsm->lsm_md_hash_type & (LMV_HASH_TYPE_MAX - 1)],
-	       lsm->lsm_md_hash_type, lsm->lsm_md_max_inherit,
-	       lsm->lsm_md_max_inherit_rr, lsm->lsm_md_layout_version,
-	       lsm->lsm_md_migrate_offset, lsm->lsm_md_migrate_hash,
+	       lmv_is_known_hash_type(lsm->lsm_md_hash_type) ?
+		mdt_hash_name[lsm->lsm_md_hash_type & LMV_HASH_TYPE_MASK] :
+		"invalid", lsm->lsm_md_hash_type,
+	       lsm->lsm_md_max_inherit, lsm->lsm_md_max_inherit_rr,
+	       lsm->lsm_md_layout_version, lsm->lsm_md_migrate_offset,
+	       lmv_is_known_hash_type(lsm->lsm_md_migrate_hash) ?
+		mdt_hash_name[lsm->lsm_md_migrate_hash & LMV_HASH_TYPE_MASK] :
+		"invalid", lsm->lsm_md_migrate_hash,
 	       LOV_MAXPOOLNAME, lsm->lsm_md_pool_name);
 
 	if (!lmv_dir_striped(lsm))
@@ -245,7 +244,7 @@ static inline u32 crush_hash(u32 a, u32 b)
  * algorithm.
  */
 static inline unsigned int
-lmv_hash_crush(unsigned int count, const char *name, int namelen)
+lmv_hash_crush(unsigned int count, const char *name, int namelen, bool crush2)
 {
 	unsigned long long straw;
 	unsigned long long highest_straw = 0;
@@ -258,10 +257,10 @@ static inline u32 crush_hash(u32 a, u32 b)
 	 * 1. rsync: .<target>.XXXXXX
 	 * 2. dstripe: <target>.XXXXXXXX
 	 */
-	if (lu_name_is_temp_file(name, namelen, true, 6)) {
+	if (lu_name_is_temp_file(name, namelen, true, 6, crush2)) {
 		name++;
 		namelen -= 8;
-	} else if (lu_name_is_temp_file(name, namelen, false, 8)) {
+	} else if (lu_name_is_temp_file(name, namelen, false, 8, crush2)) {
 		namelen -= 9;
 	} else if (lu_name_is_backup_file(name, namelen, &i)) {
 		LASSERT(i < namelen);
@@ -340,7 +339,11 @@ static inline u32 crush_hash(u32 a, u32 b)
 			break;
 		case LMV_HASH_TYPE_CRUSH:
 			stripe_index = lmv_hash_crush(stripe_count, name,
-						      namelen);
+						      namelen, false);
+			break;
+		case LMV_HASH_TYPE_CRUSH2:
+			stripe_index = lmv_hash_crush(stripe_count, name,
+						      namelen, true);
 			break;
 		default:
 			return -EBADFD;
@@ -414,16 +417,19 @@ static inline bool lmv_user_magic_supported(u32 lum_magic)
 	       lum_magic == LMV_MAGIC_FOREIGN;
 }
 
-#define LMV_DEBUG(mask, lmv, msg)					\
-	CDEBUG(mask,							\
-	       "%s LMV: magic=%#x count=%u index=%u hash=%s:%#x version=%u migrate offset=%u migrate hash=%s:%u.\n",\
-	       msg, (lmv)->lmv_magic, (lmv)->lmv_stripe_count,          \
-	       (lmv)->lmv_master_mdt_index,				\
-	       mdt_hash_name[(lmv)->lmv_hash_type & (LMV_HASH_TYPE_MAX - 1)],\
-	       (lmv)->lmv_hash_type, (lmv)->lmv_layout_version,		\
-	       (lmv)->lmv_migrate_offset,				\
-	       mdt_hash_name[(lmv)->lmv_migrate_hash & (LMV_HASH_TYPE_MAX - 1)],\
-	       (lmv)->lmv_migrate_hash)
+#define LMV_DEBUG(mask, lmv, msg)						   \
+	CDEBUG_LIMIT(mask,							   \
+		     "%s LMV: magic=%#x count=%u index=%u hash=%s:%#x version=%u migrate_offset=%u migrate_hash=%s:%x pool=%.*s\n",\
+		     msg, (lmv)->lmv_magic, (lmv)->lmv_stripe_count,		   \
+		     (lmv)->lmv_master_mdt_index,				   \
+		     lmv_is_known_hash_type((lmv)->lmv_hash_type) ?		   \
+		     mdt_hash_name[(lmv)->lmv_hash_type & LMV_HASH_TYPE_MASK] :	   \
+		     "invalid", (lmv)->lmv_hash_type,				   \
+		     (lmv)->lmv_layout_version, (lmv)->lmv_migrate_offset,	   \
+		     lmv_is_known_hash_type((lmv)->lmv_migrate_hash) ?		   \
+		     mdt_hash_name[(lmv)->lmv_migrate_hash & LMV_HASH_TYPE_MASK] : \
+		     "invalid", (lmv)->lmv_migrate_hash,			   \
+		     LOV_MAXPOOLNAME, lmv->lmv_pool_name)
 
 /* master LMV is sane */
 static inline bool lmv_is_sane(const struct lmv_mds_md_v1 *lmv)
@@ -442,7 +448,7 @@ static inline bool lmv_is_sane(const struct lmv_mds_md_v1 *lmv)
 
 	return true;
 insane:
-	LMV_DEBUG(D_ERROR, lmv, "insane");
+	LMV_DEBUG(D_ERROR, lmv, "unknown layout");
 	return false;
 }
 
@@ -464,7 +470,7 @@ static inline bool lmv_is_sane2(const struct lmv_mds_md_v1 *lmv)
 
 	return true;
 insane:
-	LMV_DEBUG(D_ERROR, lmv, "insane");
+	LMV_DEBUG(D_ERROR, lmv, "unknown layout");
 	return false;
 }
 
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index e25d4ed..0909351 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -513,7 +513,7 @@
 #define OBD_FAIL_UPDATE_OBJ_NET_REP			0x1701
 
 /* LMV */
-#define OBD_FAIL_UNKNOWN_LMV_STRIPE			0x1901
+#define OBD_FAIL_LMV_UNKNOWN_STRIPE			0x1901
 
 /* FLR */
 #define OBD_FAIL_FLR_LV_DELAY				0x1A01
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 9e7812d..451bd0e 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -442,9 +442,10 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 
 	if (lump->lum_magic != LMV_MAGIC_FOREIGN) {
 		CDEBUG(D_VFSTRACE,
-		       "VFS Op:inode=" DFID "(%p) name %s stripe_offset %d, stripe_count: %u\n",
+		       "VFS Op:inode=" DFID "(%p) name %s stripe_offset %d stripe_count: %u, hash_type=%x\n",
 		       PFID(ll_inode2fid(parent)), parent, dirname,
-		       (int)lump->lum_stripe_offset, lump->lum_stripe_count);
+		       (int)lump->lum_stripe_offset, lump->lum_stripe_count,
+		       lump->lum_hash_type);
 	} else {
 		struct lmv_foreign_md *lfm = (struct lmv_foreign_md *)lump;
 
@@ -465,7 +466,9 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	/* MDS < 2.14 doesn't support 'crush' hash type, and cannot handle
 	 * unknown hash if client doesn't set a valid one. switch to fnv_1a_64.
 	 */
-	if (!(exp_connect_flags2(sbi->ll_md_exp) & OBD_CONNECT2_CRUSH)) {
+	if (CFS_FAIL_CHECK(OBD_FAIL_LMV_UNKNOWN_STRIPE)) {
+		lump->lum_hash_type = cfs_fail_val;
+	} else if (!(exp_connect_flags2(sbi->ll_md_exp) & OBD_CONNECT2_CRUSH)) {
 		enum lmv_hash_type type = lump->lum_hash_type &
 					  LMV_HASH_TYPE_MASK;
 
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index d382554..8b21effc 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1637,7 +1637,6 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
 			current_cap(), rdev, &request);
-#if OBD_OCD_VERSION(2, 14, 58, 0) < LUSTRE_VERSION_CODE
 	/*
 	 * server < 2.12.58 doesn't pack default LMV in intent_getattr reply,
 	 * fetch default LMV here.
@@ -1704,7 +1703,6 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 		request = NULL;
 		goto again;
 	}
-#endif
 
 	if (err < 0)
 		goto err_exit;
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index e10d1bf..84d583e 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3307,8 +3307,8 @@ static int lmv_unpack_md_v1(struct obd_export *exp, struct lmv_stripe_md *lsm,
 	lsm->lsm_md_magic = le32_to_cpu(lmm1->lmv_magic);
 	lsm->lsm_md_stripe_count = le32_to_cpu(lmm1->lmv_stripe_count);
 	lsm->lsm_md_master_mdt_index = le32_to_cpu(lmm1->lmv_master_mdt_index);
-	if (OBD_FAIL_CHECK(OBD_FAIL_UNKNOWN_LMV_STRIPE))
-		lsm->lsm_md_hash_type = LMV_HASH_TYPE_UNKNOWN;
+	if (CFS_FAIL_CHECK(OBD_FAIL_LMV_UNKNOWN_STRIPE))
+		lsm->lsm_md_hash_type = cfs_fail_val ?: LMV_HASH_TYPE_UNKNOWN;
 	else
 		lsm->lsm_md_hash_type = le32_to_cpu(lmm1->lmv_hash_type);
 	lsm->lsm_md_layout_version = le32_to_cpu(lmm1->lmv_layout_version);
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 7b79604..8cfee7f 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -709,10 +709,12 @@ struct lmv_user_mds_data {
 
 enum lmv_hash_type {
 	LMV_HASH_TYPE_UNKNOWN	= 0,	/* 0 is reserved for testing purpose */
-	LMV_HASH_TYPE_ALL_CHARS = 1,
-	LMV_HASH_TYPE_FNV_1A_64 = 2,
-	LMV_HASH_TYPE_CRUSH	= 3,
+	LMV_HASH_TYPE_ALL_CHARS = 1,	/* simple sum of characters */
+	LMV_HASH_TYPE_FNV_1A_64 = 2,	/* reasonable non-cryptographic hash */
+	LMV_HASH_TYPE_CRUSH	= 3,	/* double-hash to optimize migration */
+	LMV_HASH_TYPE_CRUSH2	= 4,	/* CRUSH with small fixes, LU-15692 */
 	LMV_HASH_TYPE_MAX,
+	LMV_HASH_TYPE_DEFAULT	= LMV_HASH_TYPE_FNV_1A_64
 };
 
 static __attribute__((unused)) const char *mdt_hash_name[] = {
@@ -720,9 +722,9 @@ static __attribute__((unused)) const char *mdt_hash_name[] = {
 	"all_char",
 	"fnv_1a_64",
 	"crush",
+	"crush2",
 };
 
-#define LMV_HASH_TYPE_DEFAULT LMV_HASH_TYPE_FNV_1A_64
 
 /* Right now only the lower part(0-16bits) of lmv_hash_type is being used,
  * and the higher part will be the flag to indicate the status of object,
@@ -733,9 +735,8 @@ static __attribute__((unused)) const char *mdt_hash_name[] = {
 
 static inline bool lmv_is_known_hash_type(__u32 type)
 {
-	return (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_FNV_1A_64 ||
-	       (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_ALL_CHARS ||
-	       (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_CRUSH;
+	return (type & LMV_HASH_TYPE_MASK) > LMV_HASH_TYPE_UNKNOWN &&
+	       (type & LMV_HASH_TYPE_MASK) < LMV_HASH_TYPE_MAX;
 }
 
 /* fixed layout, such directories won't split automatically */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
