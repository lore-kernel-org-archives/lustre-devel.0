Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B9F5BC36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:40:57 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2vh5PC9z210b;
	Fri, 21 Mar 2025 06:13:52 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2p94VxMz1y9c
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:09:05 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm4-e204-208.ccs.ornl.gov [160.91.203.22])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A505617B5B2;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id A3714106BE14; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:07:06 -0400
Message-ID: <20250321130711.3257092-24-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 23/27] lustre: llite: deadlock on lli_lsm_sem
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
Cc: Vitaly Fertman <c17818@cray.com>, Andriy Skulysh <c17819@cray.com>,
 Vitaly Fertman <vitaly.fertman@hpe.com>, Lai Siyao <lai.siyao@whamcloud.com>,
 Alexey Lyashkov <alexey.lyashkov@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vitaly Fertman <vitaly.fertman@hpe.com>

it may happen that one process is doing lookup, and after reply while
holding the LDLM lock is trying to update LSM/default LSM under the
write lli_lsm_sem for a dir.

another process has taken the read lli_lsm_sem (taken for all the MD
ops in ll_prep_md_op_data()) and is waiting for a conflicting PW LDLM
lock on server for its modification for this dir.

it may happen on restriping with LSM, on changing the default LSM, but
even more often way is racer run even without striped dirs:
- racer does LFS mkdir -i $i <subdir> per each MDS, what creates a default
  LSM on these subdirs inherited endlessly - to keep the MDS index;
- racer also does mkdir -p <path>, in which case we do:
        ll_new_node - create a parent dir, no RMF_DEFAULT_MDT_MD in reply
        ll_lookup parent it=open - no RMF_DEFAULT_MDT_MD in reply
        ll_new_node - create a child
the default LSM is inherited on the parent creation, however as those RPCs
do not have lookup LDLM lock and no data - the default layout is not set
for the parent in inode at the time of a child creation. thus a parallel
lookup which gets the LSM deadlocks with this ll_new_node().

at the same time, similar to CLIO, we do not need to hold a sem nor an
LDLM lock over the whole operation to avoid LSM modification on server,
we just need to take an uptodate LSM (this is a subject for LU-16320)
and to guarantee this op will be working on the client on this LSM for
the whole operation.

the solution is to let MD ops to work on a copy of LSM therefore letting
 others to modify LSM attached to inode in parallel if needed.

HPE-bug-id: LUS-10725
WC-bug-id: https://jira.whamcloud.com/browse/LU-15535
Lustre-commit: 3ebc8e0528e34a11f ("LU-15535 llite: deadlock on lli_lsm_sem")
Signed-off-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-on: https://es-gerrit.hpc.amslabs.hpecorp.net/161525
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Tested-by: Vitaly Fertman <c17818@cray.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50489
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_lmv.h          |  84 +++---
 fs/lustre/include/obd.h                 |  28 +-
 fs/lustre/include/obd_class.h           |  24 +-
 fs/lustre/llite/dir.c                   |  12 +-
 fs/lustre/llite/file.c                  |  17 +-
 fs/lustre/llite/llite_foreign.c         |  26 +-
 fs/lustre/llite/llite_foreign_symlink.c |  10 +-
 fs/lustre/llite/llite_internal.h        |  19 +-
 fs/lustre/llite/llite_lib.c             | 247 ++++++++---------
 fs/lustre/llite/namei.c                 |  43 +--
 fs/lustre/lmv/lmv_intent.c              |  21 +-
 fs/lustre/lmv/lmv_internal.h            |  16 +-
 fs/lustre/lmv/lmv_obd.c                 | 353 ++++++++++++++----------
 fs/lustre/mdc/mdc_request.c             |  45 +--
 14 files changed, 510 insertions(+), 435 deletions(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index c3b55d4b63e0..58f9be40f97d 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -55,31 +55,39 @@ struct lmv_stripe_md {
 	struct lmv_oinfo lsm_md_oinfo[0];
 };
 
-static inline bool lmv_dir_striped(const struct lmv_stripe_md *lsm)
+struct lmv_stripe_object {
+	atomic_t			lso_refs;
+	union {
+		struct lmv_stripe_md	lso_lsm;
+		struct lmv_foreign_md	lso_lfm;
+	};
+};
+
+static inline bool lmv_dir_striped(const struct lmv_stripe_object *lso)
 {
-	return lsm && lsm->lsm_md_magic == LMV_MAGIC;
+	return lso && lso->lso_lsm.lsm_md_magic == LMV_MAGIC;
 }
 
-static inline bool lmv_dir_foreign(const struct lmv_stripe_md *lsm)
+static inline bool lmv_dir_foreign(const struct lmv_stripe_object *lso)
 {
-	return lsm && lsm->lsm_md_magic == LMV_MAGIC_FOREIGN;
+	return lso && lso->lso_lsm.lsm_md_magic == LMV_MAGIC_FOREIGN;
 }
 
-static inline bool lmv_dir_layout_changing(const struct lmv_stripe_md *lsm)
+static inline bool lmv_dir_layout_changing(const struct lmv_stripe_object *lso)
 {
-	return lmv_dir_striped(lsm) &&
-	       lmv_hash_is_layout_changing(lsm->lsm_md_hash_type);
+	return lmv_dir_striped(lso) &&
+	       lmv_hash_is_layout_changing(lso->lso_lsm.lsm_md_hash_type);
 }
 
-static inline bool lmv_dir_bad_hash(const struct lmv_stripe_md *lsm)
+static inline bool lmv_dir_bad_hash(const struct lmv_stripe_object *lso)
 {
-	if (!lmv_dir_striped(lsm))
+	if (!lmv_dir_striped(lso))
 		return false;
 
-	if (lsm->lsm_md_hash_type & LMV_HASH_FLAG_BAD_TYPE)
+	if (lso->lso_lsm.lsm_md_hash_type & LMV_HASH_FLAG_BAD_TYPE)
 		return true;
 
-	return !lmv_is_known_hash_type(lsm->lsm_md_hash_type);
+	return !lmv_is_known_hash_type(lso->lso_lsm.lsm_md_hash_type);
 }
 
 static inline u8 lmv_inherit_next(u8 inherit)
@@ -109,9 +117,11 @@ static inline bool lmv_is_inheritable(u8 inherit)
 	       (inherit > LMV_INHERIT_END && inherit <= LMV_INHERIT_MAX);
 }
 
-static inline bool
-lsm_md_eq(const struct lmv_stripe_md *lsm1, const struct lmv_stripe_md *lsm2)
+static inline bool lsm_md_eq(const struct lmv_stripe_object *lso1,
+			     const struct lmv_stripe_object *lso2)
 {
+	const struct lmv_stripe_md *lsm1 = &lso1->lso_lsm;
+	const struct lmv_stripe_md *lsm2 = &lso2->lso_lsm;
 	u32 idx;
 
 	if (lsm1->lsm_md_magic != lsm2->lsm_md_magic ||
@@ -129,7 +139,7 @@ lsm_md_eq(const struct lmv_stripe_md *lsm1, const struct lmv_stripe_md *lsm2)
 		    sizeof(lsm1->lsm_md_pool_name)) != 0)
 		return false;
 
-	if (lmv_dir_striped(lsm1)) {
+	if (lmv_dir_striped(lso1)) {
 		for (idx = 0; idx < lsm1->lsm_md_stripe_count; idx++) {
 			if (!lu_fid_eq(&lsm1->lsm_md_oinfo[idx].lmo_fid,
 				       &lsm2->lsm_md_oinfo[idx].lmo_fid))
@@ -146,14 +156,16 @@ lsm_md_eq(const struct lmv_stripe_md *lsm1, const struct lmv_stripe_md *lsm2)
 	return true;
 }
 
-static inline void lsm_md_dump(int mask, const struct lmv_stripe_md *lsm)
+static inline void
+lmv_stripe_object_dump(int mask, const struct lmv_stripe_object *lsmo)
 {
+	const struct lmv_stripe_md *lsm = &lsmo->lso_lsm;
 	int i;
 
 	CDEBUG_LIMIT(mask,
-	       "dump LMV: magic=%#x count=%u index=%u hash=%s:%#x max_inherit=%hhu max_inherit_rr=%hhu version=%u migrate_offset=%u migrate_hash=%s:%x pool=%.*s\n",
-	       lsm->lsm_md_magic, lsm->lsm_md_stripe_count,
-	       lsm->lsm_md_master_mdt_index,
+	       "dump LMV: refs %u magic=%#x count=%u index=%u hash=%s:%#x max_inherit=%hhu max_inherit_rr=%hhu version=%u migrate_offset=%u migrate_hash=%s:%x pool=%.*s\n",
+	       lsm->lsm_md_magic, atomic_read(&lsmo->lso_refs),
+	       lsm->lsm_md_stripe_count, lsm->lsm_md_master_mdt_index,
 	       lmv_is_known_hash_type(lsm->lsm_md_hash_type) ?
 		mdt_hash_name[lsm->lsm_md_hash_type & LMV_HASH_TYPE_MASK] :
 		"invalid", lsm->lsm_md_hash_type,
@@ -164,7 +176,7 @@ static inline void lsm_md_dump(int mask, const struct lmv_stripe_md *lsm)
 		"invalid", lsm->lsm_md_migrate_hash,
 	       LOV_MAXPOOLNAME, lsm->lsm_md_pool_name);
 
-	if (!lmv_dir_striped(lsm))
+	if (!lmv_dir_striped(lsmo))
 		return;
 
 	for (i = 0; i < lsm->lsm_md_stripe_count; i++)
@@ -173,24 +185,34 @@ static inline void lsm_md_dump(int mask, const struct lmv_stripe_md *lsm)
 }
 
 static inline bool
-lsm_md_inherited(const struct lmv_stripe_md *plsm,
-		 const struct lmv_stripe_md *clsm)
+lmv_object_inherited(const struct lmv_stripe_object *plsm,
+		     const struct lmv_stripe_object *clsm)
 {
 	return plsm && clsm &&
-	       plsm->lsm_md_magic == clsm->lsm_md_magic &&
-	       plsm->lsm_md_stripe_count == clsm->lsm_md_stripe_count &&
-	       plsm->lsm_md_master_mdt_index ==
-			clsm->lsm_md_master_mdt_index &&
-	       plsm->lsm_md_hash_type == clsm->lsm_md_hash_type &&
-	       lmv_inherit_next(plsm->lsm_md_max_inherit) ==
-			clsm->lsm_md_max_inherit &&
-	       lmv_inherit_rr_next(plsm->lsm_md_max_inherit_rr) ==
-			clsm->lsm_md_max_inherit_rr;
+	       plsm->lso_lsm.lsm_md_magic ==
+			clsm->lso_lsm.lsm_md_magic &&
+	       plsm->lso_lsm.lsm_md_stripe_count ==
+			clsm->lso_lsm.lsm_md_stripe_count &&
+	       plsm->lso_lsm.lsm_md_master_mdt_index ==
+			clsm->lso_lsm.lsm_md_master_mdt_index &&
+	       plsm->lso_lsm.lsm_md_hash_type ==
+			clsm->lso_lsm.lsm_md_hash_type &&
+	       lmv_inherit_next(plsm->lso_lsm.lsm_md_max_inherit) ==
+			clsm->lso_lsm.lsm_md_max_inherit &&
+	       lmv_inherit_rr_next(plsm->lso_lsm.lsm_md_max_inherit_rr) ==
+			clsm->lso_lsm.lsm_md_max_inherit_rr;
 }
 
 union lmv_mds_md;
 
-void lmv_free_memmd(struct lmv_stripe_md *lsm);
+struct lmv_stripe_object *lmv_stripe_object_alloc(u32 magic,
+						  const union lmv_mds_md *lmm,
+						  size_t lmm_size);
+
+void lmv_stripe_object_put(struct lmv_stripe_object **lsm_obj);
+
+struct lmv_stripe_object *
+	lmv_stripe_object_get(struct lmv_stripe_object *lsm_obj);
 
 static inline void lmv1_le_to_cpu(struct lmv_mds_md_v1 *lmv_dst,
 				  const struct lmv_mds_md_v1 *lmv_src)
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 604739ca92c2..8f6d42544711 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -47,6 +47,7 @@
 #include <lustre_fld.h>
 #include <lustre_handles.h>
 #include <lustre_intent.h>
+#include <lustre_lmv.h>
 #include <cl_object.h>
 
 #include <linux/rhashtable.h>
@@ -759,11 +760,9 @@ struct md_op_data {
 	s64			op_mod_time;
 	const char	       *op_name;
 	size_t			op_namelen;
-	struct rw_semaphore	*op_mea1_sem;
-	struct rw_semaphore	*op_mea2_sem;
-	struct lmv_stripe_md   *op_mea1;
-	struct lmv_stripe_md   *op_mea2;
-	struct lmv_stripe_md	*op_default_mea1;	/* default LMV */
+	struct lmv_stripe_object *op_lso1;
+	struct lmv_stripe_object *op_lso2;
+	struct lmv_stripe_object *op_default_lso1; /* default LMV */
 	u32			op_suppgids[2];
 	u32			op_fsuid;
 	u32			op_fsgid;
@@ -1020,11 +1019,8 @@ struct obd_ops {
 struct lustre_md {
 	struct mdt_body			*body;
 	struct lu_buf			 layout;
-	union {
-		struct lmv_stripe_md	*lmv;
-		struct lmv_foreign_md   *lfm;
-	};
-	struct lmv_stripe_md    *default_lmv;
+	struct lmv_stripe_object	*lsm_obj;
+	struct lmv_stripe_object	*def_lsm_obj;
 #ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 	struct posix_acl		*posix_acl;
 #endif
@@ -1123,10 +1119,10 @@ struct md_ops {
 			     struct obd_export *, struct obd_export *,
 			     struct lustre_md *);
 
-	int (*free_lustre_md)(struct obd_export *, struct lustre_md *);
+	int (*put_lustre_md)(struct obd_export *, struct lustre_md *);
 
 	int (*merge_attr)(struct obd_export *exp,
-			  const struct lmv_stripe_md *lsm,
+			  const struct lmv_stripe_object *,
 			  struct cl_attr *attr, ldlm_blocking_callback);
 
 	int (*set_open_replay_data)(struct obd_export *,
@@ -1147,7 +1143,7 @@ struct md_ops {
 			     enum ldlm_cancel_flags flags, void *opaque);
 
 	int (*get_fid_from_lsm)(struct obd_export *,
-				const struct lmv_stripe_md *,
+				const struct lmv_stripe_object *,
 				const char *name, int namelen,
 				struct lu_fid *fid);
 
@@ -1157,8 +1153,10 @@ struct md_ops {
 	int (*revalidate_lock)(struct obd_export *, struct lookup_intent *,
 			       struct lu_fid *, u64 *bits);
 
-	int (*unpackmd)(struct obd_export *exp, struct lmv_stripe_md **plsm,
-			const union lmv_mds_md *lmv, size_t lmv_size);
+	int (*stripe_object_create)(struct obd_export *exp,
+				    struct lmv_stripe_object **plso,
+				    const union lmv_mds_md *lmv,
+				    size_t lmv_size);
 	int (*rmfid)(struct obd_export *exp, struct fid_array *fa, int *rcs,
 		     struct ptlrpc_request_set *set);
 	struct lu_batch *(*batch_create)(struct obd_export *exp,
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index f8ae45b6e986..a6a554ce6af7 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1446,8 +1446,8 @@ static inline int md_get_lustre_md(struct obd_export *exp,
 	return MDP(exp->exp_obd, get_lustre_md)(exp, pill, dt_exp, md_exp, md);
 }
 
-static inline int md_free_lustre_md(struct obd_export *exp,
-				    struct lustre_md *md)
+static inline int md_put_lustre_md(struct obd_export *exp,
+				   struct lustre_md *md)
 {
 	int rc;
 
@@ -1455,11 +1455,11 @@ static inline int md_free_lustre_md(struct obd_export *exp,
 	if (rc)
 		return rc;
 
-	return MDP(exp->exp_obd, free_lustre_md)(exp, md);
+	return MDP(exp->exp_obd, put_lustre_md)(exp, md);
 }
 
 static inline int md_merge_attr(struct obd_export *exp,
-				const struct lmv_stripe_md *lsm,
+				const struct lmv_stripe_object *lso,
 				struct cl_attr *attr,
 				ldlm_blocking_callback cb)
 {
@@ -1469,7 +1469,7 @@ static inline int md_merge_attr(struct obd_export *exp,
 	if (rc)
 		return rc;
 
-	return MDP(exp->exp_obd, merge_attr)(exp, lsm, attr, cb);
+	return MDP(exp->exp_obd, merge_attr)(exp, lso, attr, cb);
 }
 
 static inline int md_setxattr(struct obd_export *exp, const struct lu_fid *fid,
@@ -1625,7 +1625,7 @@ static inline int md_revalidate_lock(struct obd_export *exp,
 }
 
 static inline int md_get_fid_from_lsm(struct obd_export *exp,
-				      const struct lmv_stripe_md *lsm,
+				      const struct lmv_stripe_object *lso,
 				      const char *name, int namelen,
 				      struct lu_fid *fid)
 {
@@ -1635,7 +1635,8 @@ static inline int md_get_fid_from_lsm(struct obd_export *exp,
 	if (rc)
 		return rc;
 
-	return MDP(exp->exp_obd, get_fid_from_lsm)(exp, lsm, name, namelen, fid);
+	return MDP(exp->exp_obd, get_fid_from_lsm)(exp, lso, name, namelen,
+						   fid);
 }
 
 /*
@@ -1645,9 +1646,10 @@ static inline int md_get_fid_from_lsm(struct obd_export *exp,
  * If *plsm != NULL and lmm == NULL then *lsm will be freed.
  * If *plsm == NULL then it will be allocated.
  */
-static inline int md_unpackmd(struct obd_export *exp,
-			      struct lmv_stripe_md **plsm,
-			      const union lmv_mds_md *lmm, size_t lmm_size)
+static inline int md_stripe_object_create(struct obd_export *exp,
+					  struct lmv_stripe_object **lsop,
+					  const union lmv_mds_md *lmm,
+					  size_t lmm_size)
 {
 	int rc;
 
@@ -1655,7 +1657,7 @@ static inline int md_unpackmd(struct obd_export *exp,
 	if (rc)
 		return rc;
 
-	return MDP(exp->exp_obd, unpackmd)(exp, plsm, lmm, lmm_size);
+	return MDP(exp->exp_obd, stripe_object_create)(exp, lsop, lmm, lmm_size);
 }
 
 static inline int md_rmfid(struct obd_export *exp, struct fid_array *fa,
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index b628e11e759c..2e43e31c5cd0 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -167,8 +167,7 @@ void ll_release_page(struct inode *inode, struct page *page, bool remove)
 	/* Always remove the page for striped dir, because the page is
 	 * built from temporarily in LMV layer
 	 */
-	if (inode && S_ISDIR(inode->i_mode) &&
-	    lmv_dir_striped(ll_i2info(inode)->lli_lsm_md)) {
+	if (inode && ll_dir_striped(inode)) {
 		__free_page(page);
 		return;
 	}
@@ -362,8 +361,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	}
 
 	/* foreign dirs are browsed out of Lustre */
-	if (unlikely(op_data->op_mea1 &&
-		     op_data->op_mea1->lsm_md_magic == LMV_MAGIC_FOREIGN)) {
+	if (unlikely(lmv_dir_foreign(op_data->op_lso1))) {
 		ll_finish_md_op_data(op_data);
 		return -ENODATA;
 	}
@@ -656,9 +654,9 @@ static int ll_dir_get_default_lmv(struct inode *inode, struct lmv_user_md *lum)
 	int rc = -ENODATA;
 
 retry:
-	if (lli->lli_default_lsm_md) {
+	if (lli->lli_def_lsm_obj) {
 		down_read(&lli->lli_lsm_sem);
-		lsm = lli->lli_default_lsm_md;
+		lsm = &lli->lli_def_lsm_obj->lso_lsm;
 		if (lsm) {
 			lum->lum_magic = lsm->lsm_md_magic;
 			lum->lum_stripe_count = lsm->lsm_md_stripe_count;
@@ -1984,7 +1982,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			 * instead of the client.
 			 */
 			if (cmd == LL_IOC_MDC_GETINFO_V2 &&
-			    ll_i2info(inode)->lli_lsm_md)
+			    ll_dir_striped(inode))
 				valid &= ~(OBD_MD_FLSIZE | OBD_MD_FLBLOCKS);
 
 			if (flagsp && copy_to_user(flagsp, &valid,
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 48c4245d61b3..881beb1c887f 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -5043,7 +5043,7 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 
 	/* migrate dirent only for subdirs if MDS_MIGRATE_NSONLY set */
 	if (S_ISDIR(child_inode->i_mode) && (flags & MDS_MIGRATE_NSONLY) &&
-	    lmv_dir_layout_changing(ll_i2info(parent)->lli_lsm_md))
+	    lmv_dir_layout_changing(op_data->op_lso1))
 		op_data->op_bias |= MDS_MIGRATE_NSONLY;
 
 again:
@@ -5294,18 +5294,21 @@ static int ll_inode_revalidate(struct dentry *dentry, enum ldlm_intent_flags op)
 static int ll_merge_md_attr(struct inode *inode)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
+	struct lmv_stripe_object *lsm_obj;
 	struct cl_attr attr = { 0 };
 	int rc;
 
-	LASSERT(lli->lli_lsm_md);
-
-	if (!lmv_dir_striped(lli->lli_lsm_md))
+	if (!ll_dir_striped(inode))
 		return 0;
 
 	down_read(&lli->lli_lsm_sem);
-	rc = md_merge_attr(ll_i2mdexp(inode), lli->lli_lsm_md, &attr,
-			   ll_md_blocking_ast);
+	LASSERT(lli->lli_lsm_obj);
+	lsm_obj = lmv_stripe_object_get(lli->lli_lsm_obj);
 	up_read(&lli->lli_lsm_sem);
+
+	rc = md_merge_attr(ll_i2mdexp(inode), lsm_obj,
+			   &attr, ll_md_blocking_ast);
+	lmv_stripe_object_put(&lsm_obj);
 	if (rc)
 		return rc;
 
@@ -5403,7 +5406,7 @@ int ll_getattr_dentry(struct dentry *de, struct kstat *stat, u32 request_mask,
 	} else {
 		/* If object isn't regular a file then don't validate size. */
 		/* foreign dir is not striped dir */
-		if (ll_dir_striped(inode) && !foreign) {
+		if (!foreign) {
 			rc = ll_merge_md_attr(inode);
 			if (rc < 0)
 				return rc;
diff --git a/fs/lustre/llite/llite_foreign.c b/fs/lustre/llite/llite_foreign.c
index ed958f50762c..5f8f2e67c8ae 100644
--- a/fs/lustre/llite/llite_foreign.c
+++ b/fs/lustre/llite/llite_foreign.c
@@ -117,17 +117,16 @@ int ll_manage_foreign(struct inode *inode, struct lustre_md *lmd)
 			cl_env_put(env, &refcheck);
 		}
 	} else if (S_ISDIR((inode)->i_mode)) {
-		if (lmd->lfm &&
-		    lmd->lfm->lfm_magic == LMV_MAGIC_FOREIGN) {
-			ll_manage_foreign_dir(inode, lmd->lfm);
+		if (lmv_dir_foreign(lmd->lsm_obj)) {
+			ll_manage_foreign_dir(inode, &lmd->lsm_obj->lso_lfm);
 		} else {
 			struct ll_inode_info *lli = ll_i2info(inode);
-			struct lmv_foreign_md *lfm;
+			struct lmv_stripe_object *lsm_obj;
 
 			down_read(&lli->lli_lsm_sem);
-			lfm = (struct lmv_foreign_md *)(lli->lli_lsm_md);
-			if (lfm &&  lfm->lfm_magic == LMV_MAGIC_FOREIGN)
-				ll_manage_foreign_dir(inode, lfm);
+			lsm_obj = lli->lli_lsm_obj;
+			if (lmv_dir_foreign(lsm_obj))
+				ll_manage_foreign_dir(inode, &lsm_obj->lso_lfm);
 			up_read(&lli->lli_lsm_sem);
 		}
 	}
@@ -256,18 +255,19 @@ bool ll_foreign_is_removable(struct dentry *dentry, bool unset)
 		}
 	} else if (S_ISDIR(inode->i_mode)) {
 		struct ll_inode_info *lli = ll_i2info(inode);
-		struct lmv_foreign_md *lfm;
+		struct lmv_stripe_object *lsm_obj;
 
 		down_read(&lli->lli_lsm_sem);
-		lfm = (struct lmv_foreign_md *)(lli->lli_lsm_md);
-		if (!lfm)
+		lsm_obj = lli->lli_lsm_obj;
+		if (!lsm_obj)
 			CDEBUG(D_INFO,
 			       "unable to check if dir (%.*s, "DFID") is foreign...\n",
 			       name->len, name->name,
 			       PFID(ll_inode2fid(inode)));
-		else if (lfm->lfm_magic == LMV_MAGIC_FOREIGN)
-			preserve_foreign = should_preserve_foreign_dir(lfm, lli,
-								       unset);
+		else if (lmv_dir_foreign(lsm_obj))
+			preserve_foreign =
+				should_preserve_foreign_dir(&lsm_obj->lso_lfm,
+							    lli, unset);
 		up_read(&lli->lli_lsm_sem);
 		if (preserve_foreign) {
 			CDEBUG(D_INFO,
diff --git a/fs/lustre/llite/llite_foreign_symlink.c b/fs/lustre/llite/llite_foreign_symlink.c
index 64bc5db8b291..e9564f71ece8 100644
--- a/fs/lustre/llite/llite_foreign_symlink.c
+++ b/fs/lustre/llite/llite_foreign_symlink.c
@@ -221,6 +221,7 @@ static int ll_foreign_readlink_internal(struct inode *inode, char **symname)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
+	struct lmv_stripe_object *lsm_obj = NULL;
 	struct lov_foreign_md *lfm = NULL;
 	char *destname = NULL;
 	size_t lfm_size = 0;
@@ -279,8 +280,11 @@ static int ll_foreign_readlink_internal(struct inode *inode, char **symname)
 		 * and LMV formats are identical, and then we also only need
 		 * one set of parsing routines for both foreign files and dirs!
 		 */
-		lfm = (struct lov_foreign_md *)(lli->lli_lsm_md);
-		if (lfm) {
+		lsm_obj = lmv_stripe_object_get(lli->lli_lsm_obj);
+		up_read(&lli->lli_lsm_sem);
+
+		if (lsm_obj) {
+			lfm = (struct lov_foreign_md *)&lsm_obj->lso_lfm;
 			CDEBUG(D_INFO, "%s: inode "DFID": LMV cached found\n",
 			       sbi->ll_fsname, PFID(ll_inode2fid(inode)));
 		} else {
@@ -301,7 +305,7 @@ static int ll_foreign_readlink_internal(struct inode *inode, char **symname)
 	rc = ll_foreign_symlink_parse(sbi, inode, lfm, &destname);
 failed:
 	if (S_ISDIR(inode->i_mode))
-		up_read(&lli->lli_lsm_sem);
+		lmv_stripe_object_put(&lsm_obj);
 
 	if (S_ISREG(inode->i_mode) && lfm)
 		kfree(lfm);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 2db240f07b83..9c11cf198864 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -202,15 +202,15 @@ struct ll_inode_info {
 			 * is for old server, or default LMV is set by
 			 * "lfs setdirstripe -D".
 			 */
-							lli_default_lmv_set:1;
+							lli_def_lsm_obj_set:1;
 			/* generation for statahead */
 			unsigned int			lli_sa_generation;
 			/* rw lock protects lli_lsm_md */
 			struct rw_semaphore		lli_lsm_sem;
 			/* directory stripe information */
-			struct lmv_stripe_md	       *lli_lsm_md;
+			struct lmv_stripe_object	*lli_lsm_obj;
 			/* directory default LMV */
-			struct lmv_stripe_md		*lli_default_lsm_md;
+			struct lmv_stripe_object	*lli_def_lsm_obj;
 		};
 
 		/* for non-directory */
@@ -1502,9 +1502,18 @@ static inline struct lu_fid *ll_inode2fid(struct inode *inode)
 
 static inline bool ll_dir_striped(struct inode *inode)
 {
+	bool rc;
 	LASSERT(inode);
-	return S_ISDIR(inode->i_mode) &&
-	       lmv_dir_striped(ll_i2info(inode)->lli_lsm_md);
+
+	if (!S_ISDIR(inode->i_mode))
+		return false;
+
+	down_read(&ll_i2info(inode)->lli_lsm_sem);
+	rc = !!(ll_i2info(inode)->lli_lsm_obj &&
+		lmv_dir_striped(ll_i2info(inode)->lli_lsm_obj));
+	up_read(&ll_i2info(inode)->lli_lsm_sem);
+
+	return rc;
 }
 
 static inline loff_t ll_file_maxbytes(struct inode *inode)
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 39b8074bd306..3455622f4ba2 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -712,7 +712,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	LASSERT(fid_is_sane(&sbi->ll_root_fid));
 	api32 = test_bit(LL_SBI_32BIT_API, sbi->ll_flags);
 	root = ll_iget(sb, cl_fid_build_ino(&sbi->ll_root_fid, api32), &lmd);
-	md_free_lustre_md(sbi->ll_md_exp, &lmd);
+	md_put_lustre_md(sbi->ll_md_exp, &lmd);
 
 	if (IS_ERR(root)) {
 		lmd_clear_acl(&lmd);
@@ -1487,16 +1487,10 @@ void ll_dir_clear_lsm_md(struct inode *inode)
 	struct ll_inode_info *lli = ll_i2info(inode);
 
 	LASSERT(S_ISDIR(inode->i_mode));
-
-	if (lli->lli_lsm_md) {
-		lmv_free_memmd(lli->lli_lsm_md);
-		lli->lli_lsm_md = NULL;
-	}
-
-	if (lli->lli_default_lsm_md) {
-		lmv_free_memmd(lli->lli_default_lsm_md);
-		lli->lli_default_lsm_md = NULL;
-	}
+	down_write(&lli->lli_lsm_sem);
+	lmv_stripe_object_put(&lli->lli_lsm_obj);
+	lmv_stripe_object_put(&lli->lli_def_lsm_obj);
+	up_write(&lli->lli_lsm_sem);
 }
 
 static struct inode *ll_iget_anon_dir(struct super_block *sb,
@@ -1509,7 +1503,7 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 	struct inode *inode;
 	ino_t ino;
 
-	LASSERT(md->lmv);
+	LASSERT(md->lsm_obj);
 	ino = cl_fid_build_ino(fid, test_bit(LL_SBI_32BIT_API, sbi->ll_flags));
 	inode = iget_locked(sb, ino);
 	if (!inode) {
@@ -1553,18 +1547,19 @@ static struct inode *ll_iget_anon_dir(struct super_block *sb,
 
 static int ll_init_lsm_md(struct inode *inode, struct lustre_md *md)
 {
-	struct lmv_stripe_md *lsm = md->lmv;
+	struct lmv_stripe_md *lsm;
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct lu_fid *fid;
 	int i;
 
-	LASSERT(lsm);
+	LASSERT(md->lsm_obj);
+	lsm = &md->lsm_obj->lso_lsm;
 
 	CDEBUG(D_INODE, "%s: "DFID" set dir layout:\n",
 	       ll_i2sbi(inode)->ll_fsname, PFID(&lli->lli_fid));
-	lsm_md_dump(D_INODE, lsm);
+	lmv_stripe_object_dump(D_INODE, md->lsm_obj);
 
-	if (!lmv_dir_striped(lsm))
+	if (!lmv_dir_striped(md->lsm_obj))
 		goto out;
 
 	/*
@@ -1598,36 +1593,36 @@ static int ll_init_lsm_md(struct inode *inode, struct lustre_md *md)
 		}
 	}
 out:
-	lli->lli_lsm_md = lsm;
-
+	/* move lsm_obj to lli */
+	lli->lli_lsm_obj = md->lsm_obj;
+	md->lsm_obj = NULL;
 	return 0;
 }
 
 static void ll_update_default_lsm_md(struct inode *inode, struct lustre_md *md)
 {
+	struct lmv_stripe_object *lsm_obj = md->def_lsm_obj;
 	struct ll_inode_info *lli = ll_i2info(inode);
 
-	if (!md->default_lmv) {
+	if (!lsm_obj) {
 		/* clear default lsm */
-		if (lli->lli_default_lsm_md && lli->lli_default_lmv_set) {
+		if (lli->lli_def_lsm_obj && lli->lli_def_lsm_obj_set) {
 			down_write(&lli->lli_lsm_sem);
-			if (lli->lli_default_lsm_md &&
-			    lli->lli_default_lmv_set) {
-				lmv_free_memmd(lli->lli_default_lsm_md);
-				lli->lli_default_lsm_md = NULL;
+			if (lli->lli_def_lsm_obj_set) {
+				lmv_stripe_object_put(&lli->lli_def_lsm_obj);
 				lli->lli_inherit_depth = 0;
-				lli->lli_default_lmv_set = 0;
+				lli->lli_def_lsm_obj_set = 0;
 			}
 			up_write(&lli->lli_lsm_sem);
 		}
 		return;
 	}
 
-	if (lli->lli_default_lsm_md) {
+	if (lli->lli_def_lsm_obj) {
 		/* do nonthing if default lsm isn't changed */
 		down_read(&lli->lli_lsm_sem);
-		if (lli->lli_default_lsm_md &&
-		    lsm_md_eq(lli->lli_default_lsm_md, md->default_lmv)) {
+		if (lli->lli_def_lsm_obj &&
+		    lsm_md_eq(lli->lli_def_lsm_obj, lsm_obj)) {
 			up_read(&lli->lli_lsm_sem);
 			return;
 		}
@@ -1635,28 +1630,28 @@ static void ll_update_default_lsm_md(struct inode *inode, struct lustre_md *md)
 	}
 
 	down_write(&lli->lli_lsm_sem);
-	if (lli->lli_default_lsm_md)
-		lmv_free_memmd(lli->lli_default_lsm_md);
-	lli->lli_default_lsm_md = md->default_lmv;
-	lli->lli_default_lmv_set = 1;
-	lsm_md_dump(D_INODE, md->default_lmv);
-	md->default_lmv = NULL;
+	/* update default lsm. */
+	lmv_stripe_object_put(&lli->lli_def_lsm_obj);
+	lli->lli_def_lsm_obj = lsm_obj;
+	lli->lli_def_lsm_obj_set = 1;
+	lmv_stripe_object_dump(D_INODE, lsm_obj);
+	md->def_lsm_obj = NULL;
 	up_write(&lli->lli_lsm_sem);
 }
 
 static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 {
+	struct lmv_stripe_object *lsm_obj = md->lsm_obj;
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct lmv_stripe_md *lsm = md->lmv;
-	struct cl_attr	*attr;
+	struct cl_attr *attr;
 	int rc = 0;
 
 	LASSERT(S_ISDIR(inode->i_mode));
-	CDEBUG(D_INODE, "update lsm %p of " DFID "\n", lli->lli_lsm_md,
+	CDEBUG(D_INODE, "update lsm_obj %p of "DFID"\n", lli->lli_lsm_obj,
 	       PFID(ll_inode2fid(inode)));
 
 	/* update default LMV */
-	if (md->default_lmv)
+	if (md->def_lsm_obj)
 		ll_update_default_lsm_md(inode, md);
 
 	/* after dir migration/restripe, a stripe may be turned into a
@@ -1669,7 +1664,7 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	 * no striped information from request, lustre_md from req does not
 	 * include stripeEA, see ll_md_setattr()
 	 */
-	if (!lsm)
+	if (!lsm_obj)
 		return 0;
 
 	/*
@@ -1679,8 +1674,19 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	down_read(&lli->lli_lsm_sem);
 
 	/* some current lookup initialized lsm, and unchanged */
-	if (lli->lli_lsm_md && lsm_md_eq(lli->lli_lsm_md, lsm))
+	if (lli->lli_lsm_obj && lsm_md_eq(lli->lli_lsm_obj, lsm_obj)) {
+		up_read(&lli->lli_lsm_sem);
+		return 0;
+	}
+
+	up_read(&lli->lli_lsm_sem);
+	down_write(&lli->lli_lsm_sem);
+
+	/* check again in case of a race */
+	if (lli->lli_lsm_obj && lsm_md_eq(lli->lli_lsm_obj, lsm_obj)) {
+		rc = 0;
 		goto unlock;
+	}
 
 	/* if dir layout doesn't match, check whether version is increased,
 	 * which means layout is changed, this happens in dir split/merge and
@@ -1688,52 +1694,40 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	 *
 	 * foreign LMV should not change.
 	 */
-	if (lli->lli_lsm_md && lmv_dir_striped(lli->lli_lsm_md) &&
-	    lsm->lsm_md_layout_version <=
-	    lli->lli_lsm_md->lsm_md_layout_version) {
+	if (lli->lli_lsm_obj && lmv_dir_striped(lli->lli_lsm_obj) &&
+	    lsm_obj->lso_lsm.lsm_md_layout_version <=
+	    lli->lli_lsm_obj->lso_lsm.lsm_md_layout_version) {
 		CERROR("%s: " DFID " dir layout mismatch:\n",
 		       ll_i2sbi(inode)->ll_fsname, PFID(&lli->lli_fid));
-		lsm_md_dump(D_ERROR, lli->lli_lsm_md);
-		lsm_md_dump(D_ERROR, lsm);
+		lmv_stripe_object_dump(D_ERROR, lli->lli_lsm_obj);
+		lmv_stripe_object_dump(D_ERROR, lsm_obj);
 		rc = -EINVAL;
 		goto unlock;
 	}
 
-	up_read(&lli->lli_lsm_sem);
-	down_write(&lli->lli_lsm_sem);
 	/* clear existing lsm */
-	if (lli->lli_lsm_md) {
-		lmv_free_memmd(lli->lli_lsm_md);
-		lli->lli_lsm_md = NULL;
-	}
+	lmv_stripe_object_put(&lli->lli_lsm_obj);
 
 	rc = ll_init_lsm_md(inode, md);
-	up_write(&lli->lli_lsm_sem);
-
 	if (rc)
-		return rc;
-
-	/* set md->lmv to NULL, so the following free lustre_md will not free
-	 * this lsm.
-	 */
-	md->lmv = NULL;
-
-	/* md_merge_attr() may take long, since lsm is already set, switch to
-	 * read lock.
-	 */
-	down_read(&lli->lli_lsm_sem);
+		goto unlock;
 
-	if (!lmv_dir_striped(lli->lli_lsm_md))
+	if (!lmv_dir_striped(lli->lli_lsm_obj)) {
+		rc = 0;
 		goto unlock;
+	}
+
+	lsm_obj = lmv_stripe_object_get(lli->lli_lsm_obj);
+	up_write(&lli->lli_lsm_sem);
 
 	attr = kzalloc(sizeof(*attr), GFP_NOFS);
 	if (!attr) {
 		rc = -ENOMEM;
-		goto unlock;
+		goto err;
 	}
 
 	/* validate the lsm */
-	rc = md_merge_attr(ll_i2mdexp(inode), lli->lli_lsm_md, attr,
+	rc = md_merge_attr(ll_i2mdexp(inode), lsm_obj, attr,
 			   ll_md_blocking_ast);
 	if (!rc) {
 		if (md->body->mbo_valid & OBD_MD_FLNLINK)
@@ -1749,9 +1743,11 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	}
 
 	kfree(attr);
+err:
+	lmv_stripe_object_put(&lsm_obj);
+	return rc;
 unlock:
-	up_read(&lli->lli_lsm_sem);
-
+	up_write(&lli->lli_lsm_sem);
 	return rc;
 }
 
@@ -1874,6 +1870,7 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data)
 
 	rc = ll_update_inode(inode, &md);
 	ptlrpc_req_finished(request);
+	md_put_lustre_md(sbi->ll_md_exp, &md);
 
 	return rc;
 }
@@ -2757,8 +2754,8 @@ static int ll_dir_default_lmv_inherit(struct inode *dir, struct inode *inode)
 {
 	struct ll_inode_info *plli = ll_i2info(dir);
 	struct ll_inode_info *lli = ll_i2info(inode);
-	struct lmv_stripe_md *plsm;
-	struct lmv_stripe_md *lsm;
+	struct lmv_stripe_object *plsm_obj;
+	struct lmv_stripe_object *lsm_obj;
 	int rc = 0;
 
 	/* ROOT default LMV is not inherited */
@@ -2768,25 +2765,24 @@ static int ll_dir_default_lmv_inherit(struct inode *dir, struct inode *inode)
 		return 0;
 
 	/* nothing to do if no default LMV on both */
-	if (!plli->lli_default_lsm_md && !lli->lli_default_lsm_md)
+	if (!plli->lli_def_lsm_obj && !lli->lli_def_lsm_obj)
 		return 0;
 
 	/* subdir default LMV comes from disk */
-	if (lli->lli_default_lsm_md && lli->lli_default_lmv_set)
+	if (lli->lli_def_lsm_obj && lli->lli_def_lsm_obj_set)
 		return 0;
 
 	/* delete subdir default LMV if parent's is deleted or becomes
 	 * uninheritable.
 	 */
 	down_read(&plli->lli_lsm_sem);
-	plsm = plli->lli_default_lsm_md;
-	if (!plsm || !lmv_is_inheritable(plsm->lsm_md_max_inherit)) {
-		if (lli->lli_default_lsm_md && !lli->lli_default_lmv_set) {
+	plsm_obj = plli->lli_def_lsm_obj;
+	if (!plsm_obj ||
+	    !lmv_is_inheritable(plsm_obj->lso_lsm.lsm_md_max_inherit)) {
+		if (lli->lli_def_lsm_obj && !lli->lli_def_lsm_obj_set) {
 			down_write(&lli->lli_lsm_sem);
-			if (lli->lli_default_lsm_md &&
-			    !lli->lli_default_lmv_set) {
-				lmv_free_memmd(lli->lli_default_lsm_md);
-				lli->lli_default_lsm_md = NULL;
+			if (!lli->lli_def_lsm_obj_set) {
+				lmv_stripe_object_put(&lli->lli_def_lsm_obj);
 				lli->lli_inherit_depth = 0;
 			}
 			up_write(&lli->lli_lsm_sem);
@@ -2796,11 +2792,12 @@ static int ll_dir_default_lmv_inherit(struct inode *dir, struct inode *inode)
 	}
 
 	/* do nothing if inherited LMV is unchanged */
-	if (lli->lli_default_lsm_md) {
+	if (lli->lli_def_lsm_obj) {
 		rc = 1;
 		down_read(&lli->lli_lsm_sem);
-		if (!lli->lli_default_lmv_set)
-			rc = lsm_md_inherited(plsm, lli->lli_default_lsm_md);
+		if (!lli->lli_def_lsm_obj_set)
+			rc = lmv_object_inherited(plsm_obj,
+						  lli->lli_def_lsm_obj);
 		up_read(&lli->lli_lsm_sem);
 		if (rc == 1) {
 			rc = 0;
@@ -2810,31 +2807,31 @@ static int ll_dir_default_lmv_inherit(struct inode *dir, struct inode *inode)
 
 	/* inherit default LMV */
 	down_write(&lli->lli_lsm_sem);
-	if (lli->lli_default_lsm_md) {
+	if (lli->lli_def_lsm_obj) {
 		/* checked above, but in case of race, check again with lock */
-		if (lli->lli_default_lmv_set) {
+		if (lli->lli_def_lsm_obj_set) {
 			rc = 0;
 			goto unlock_child;
 		}
 		/* always update subdir default LMV in case parent's changed */
-		lsm = lli->lli_default_lsm_md;
+		lsm_obj = lli->lli_def_lsm_obj;
 	} else {
-		lsm = kzalloc(sizeof(*lsm), GFP_NOFS);
-		if (!lsm) {
-			rc = -ENOMEM;
+		lsm_obj = lmv_stripe_object_alloc(LMV_USER_MAGIC, NULL, 0);
+		if (IS_ERR(lsm_obj)) {
+			rc = PTR_ERR(lsm_obj);
 			goto unlock_child;
 		}
-		lli->lli_default_lsm_md = lsm;
+		lli->lli_def_lsm_obj = lsm_obj;
 	}
 
-	*lsm = *plsm;
-	lsm->lsm_md_max_inherit = lmv_inherit_next(plsm->lsm_md_max_inherit);
-	lsm->lsm_md_max_inherit_rr =
-			lmv_inherit_rr_next(plsm->lsm_md_max_inherit_rr);
+	lsm_obj->lso_lsm = plsm_obj->lso_lsm;
+	lsm_obj->lso_lsm.lsm_md_max_inherit =
+		lmv_inherit_next(plsm_obj->lso_lsm.lsm_md_max_inherit);
+	lsm_obj->lso_lsm.lsm_md_max_inherit_rr =
+		lmv_inherit_rr_next(plsm_obj->lso_lsm.lsm_md_max_inherit_rr);
 	lli->lli_inherit_depth = plli->lli_inherit_depth + 1;
 
-	lsm_md_dump(D_INODE, lsm);
-
+	lmv_stripe_object_dump(D_INODE, lsm_obj);
 unlock_child:
 	up_write(&lli->lli_lsm_sem);
 unlock_parent:
@@ -2872,12 +2869,12 @@ void ll_update_dir_depth_dmv(struct inode *dir, struct dentry *de)
 	plli = ll_i2info(dir);
 	lli = ll_i2info(inode);
 	lli->lli_dir_depth = plli->lli_dir_depth + 1;
-	if (lli->lli_default_lsm_md && lli->lli_default_lmv_set) {
-		if (plli->lli_default_lsm_md) {
+	if (lli->lli_def_lsm_obj && lli->lli_def_lsm_obj_set) {
+		if (plli->lli_def_lsm_obj) {
 			down_read_nested(&plli->lli_lsm_sem, LSM_SEM_PARENT);
 			down_read_nested(&lli->lli_lsm_sem, LSM_SEM_CHILD);
-			if (lsm_md_inherited(plli->lli_default_lsm_md,
-					     lli->lli_default_lsm_md))
+			if (lmv_object_inherited(plli->lli_def_lsm_obj,
+						 lli->lli_def_lsm_obj))
 				lli->lli_inherit_depth =
 					plli->lli_inherit_depth + 1;
 			else
@@ -2893,11 +2890,11 @@ void ll_update_dir_depth_dmv(struct inode *dir, struct dentry *de)
 		ll_dir_default_lmv_inherit(dir, inode);
 	}
 
-	if (lli->lli_default_lsm_md)
+	if (lli->lli_def_lsm_obj)
 		CDEBUG(D_INODE,
 		       "%s "DFID" depth %hu %s default LMV inherit depth %hu\n",
 		       de->d_name.name, PFID(&lli->lli_fid), lli->lli_dir_depth,
-		       lli->lli_default_lmv_set ? "server" : "client",
+		       lli->lli_def_lsm_obj_set ? "server" : "client",
 		       lli->lli_inherit_depth);
 }
 
@@ -3383,7 +3380,7 @@ static int ll_fileset_default_lmv_fixup(struct inode *inode,
 
 	LASSERT(is_root_inode(inode));
 	LASSERT(!fid_is_root(&sbi->ll_root_fid));
-	LASSERT(!md->default_lmv);
+	LASSERT(!md->def_lsm_obj);
 
 	rc = ll_dir_get_default_layout(inode, (void **)&lmm, &size, &req,
 				       OBD_MD_DEFAULT_MEA,
@@ -3393,7 +3390,8 @@ static int ll_fileset_default_lmv_fixup(struct inode *inode,
 
 	rc = 0;
 	if (lmm && size) {
-		rc = md_unpackmd(sbi->ll_md_exp, &md->default_lmv, lmm, size);
+		rc = md_stripe_object_create(sbi->ll_md_exp, &md->def_lsm_obj,
+					     lmm, size);
 		if (rc < 0)
 			goto out;
 		rc = 0;
@@ -3425,7 +3423,7 @@ int ll_prep_inode(struct inode **inode, struct req_capsule *pill,
 	 * ll_update_lsm_md() may change md.
 	 */
 	if (it && (it->it_op & (IT_LOOKUP | IT_GETATTR)) &&
-	    S_ISDIR(md.body->mbo_mode) && !md.default_lmv) {
+	    S_ISDIR(md.body->mbo_mode) && !md.def_lsm_obj) {
 		if (unlikely(*inode && is_root_inode(*inode) &&
 			     !fid_is_root(&sbi->ll_root_fid))) {
 			rc = ll_fileset_default_lmv_fixup(*inode, &md);
@@ -3433,7 +3431,7 @@ int ll_prep_inode(struct inode **inode, struct req_capsule *pill,
 				goto out;
 		}
 
-		if (!md.default_lmv)
+		if (!md.def_lsm_obj)
 			default_lmv_deleted = true;
 	}
 
@@ -3504,7 +3502,7 @@ int ll_prep_inode(struct inode **inode, struct req_capsule *pill,
 		rc = ll_manage_foreign(*inode, &md);
 out:
 	/* cleanup will be done if necessary */
-	md_free_lustre_md(sbi->ll_md_exp, &md);
+	md_put_lustre_md(sbi->ll_md_exp, &md);
 
 	if (rc != 0 && it && it->it_op & IT_OPEN) {
 		ll_intent_drop_lock(it);
@@ -3575,15 +3573,9 @@ int ll_obd_statfs(struct inode *inode, void __user *uarg)
  */
 void ll_unlock_md_op_lsm(struct md_op_data *op_data)
 {
-	if (op_data->op_mea2_sem) {
-		up_read_non_owner(op_data->op_mea2_sem);
-		op_data->op_mea2_sem = NULL;
-	}
-
-	if (op_data->op_mea1_sem) {
-		up_read_non_owner(op_data->op_mea1_sem);
-		op_data->op_mea1_sem = NULL;
-	}
+	lmv_stripe_object_put(&op_data->op_lso2);
+	lmv_stripe_object_put(&op_data->op_lso1);
+	lmv_stripe_object_put(&op_data->op_default_lso1);
 }
 
 /* this function prepares md_op_data hint for passing ot down to MD stack. */
@@ -3631,24 +3623,21 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 		op_data->op_fid1 = *ll_inode2fid(i1);
 
 	if (S_ISDIR(i1->i_mode)) {
-		down_read_non_owner(&ll_i2info(i1)->lli_lsm_sem);
-		op_data->op_mea1_sem = &ll_i2info(i1)->lli_lsm_sem;
-		op_data->op_mea1 = ll_i2info(i1)->lli_lsm_md;
-		op_data->op_default_mea1 = ll_i2info(i1)->lli_default_lsm_md;
+		down_read(&ll_i2info(i1)->lli_lsm_sem);
+		op_data->op_lso1 =
+			lmv_stripe_object_get(ll_i2info(i1)->lli_lsm_obj);
+		op_data->op_default_lso1 =
+			lmv_stripe_object_get(ll_i2info(i1)->lli_def_lsm_obj);
+		up_read(&ll_i2info(i1)->lli_lsm_sem);
 	}
 
 	if (i2) {
 		op_data->op_fid2 = *ll_inode2fid(i2);
 		if (S_ISDIR(i2->i_mode)) {
-			if (i2 != i1) {
-				/* i2 is typically a child of i1, and MUST be
-				 * further from the root to avoid deadlocks.
-				 */
-				down_read_non_owner(&ll_i2info(i2)->lli_lsm_sem);
-				op_data->op_mea2_sem =
-						&ll_i2info(i2)->lli_lsm_sem;
-			}
-			op_data->op_mea2 = ll_i2info(i2)->lli_lsm_md;
+			down_read(&ll_i2info(i2)->lli_lsm_sem);
+			op_data->op_lso2 =
+			    lmv_stripe_object_get(ll_i2info(i2)->lli_lsm_obj);
+			up_read(&ll_i2info(i2)->lli_lsm_sem);
 		}
 	} else {
 		fid_zero(&op_data->op_fid2);
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 1d21626588ec..7b7f0b4e66a1 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -753,10 +753,12 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 
 		/* If it is striped directory, get the real stripe parent */
 		if (unlikely(ll_dir_striped(parent))) {
+			down_read(&ll_i2info(parent)->lli_lsm_sem);
 			rc = md_get_fid_from_lsm(ll_i2mdexp(parent),
-						 ll_i2info(parent)->lli_lsm_md,
+						 ll_i2info(parent)->lli_lsm_obj,
 						 (*de)->d_name.name,
 						 (*de)->d_name.len, &fid);
+			up_read(&ll_i2info(parent)->lli_lsm_sem);
 			if (rc)
 				return rc;
 		}
@@ -1482,11 +1484,11 @@ static void ll_qos_mkdir_prep(struct md_op_data *op_data, struct inode *dir)
 	depth = lli->lli_dir_depth;
 
 	/* parent directory is striped */
-	if (unlikely(lli->lli_lsm_md))
+	if (unlikely(ll_dir_striped(dir)))
 		return;
 
 	/* default LMV set on parent directory */
-	if (unlikely(lli->lli_default_lsm_md))
+	if (unlikely(lli->lli_def_lsm_obj))
 		return;
 
 	/* parent is ROOT */
@@ -1494,13 +1496,13 @@ static void ll_qos_mkdir_prep(struct md_op_data *op_data, struct inode *dir)
 		return;
 
 	/* default LMV not set on ROOT */
-	if (!rlli->lli_default_lsm_md)
+	if (!rlli->lli_def_lsm_obj)
 		return;
 
 	down_read(&rlli->lli_lsm_sem);
-	lsm = rlli->lli_default_lsm_md;
-	if (!lsm)
+	if (!rlli->lli_def_lsm_obj)
 		goto unlock;
+	lsm = &rlli->lli_def_lsm_obj->lso_lsm;
 
 	/* not space balanced */
 	if (lsm->lsm_md_master_mdt_index != LMV_OFFSET_DEFAULT)
@@ -1562,7 +1564,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 		ll_qos_mkdir_prep(op_data, dir);
 		if ((exp_connect_flags2(ll_i2mdexp(dir)) &
 		     OBD_CONNECT2_DMV_IMP_INHERIT) &&
-		    op_data->op_default_mea1 && !lum) {
+		    op_data->op_default_lso1 && !lum) {
 			const struct lmv_stripe_md *lsm;
 
 			/* once DMV_IMP_INHERIT is set, pack default LMV in
@@ -1573,7 +1575,7 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 				err = -ENOMEM;
 				goto err_exit;
 			}
-			lsm = op_data->op_default_mea1;
+			lsm = &op_data->op_default_lso1->lso_lsm;
 			lum->lum_magic = cpu_to_le32(lsm->lsm_md_magic);
 			lum->lum_stripe_count =
 				cpu_to_le32(lsm->lsm_md_stripe_count);
@@ -1685,37 +1687,38 @@ static int ll_new_node(struct inode *dir, struct dentry *dchild,
 				goto err_exit;
 			}
 
-			md.default_lmv = kzalloc(sizeof(*md.default_lmv),
+			md.def_lsm_obj = kzalloc(sizeof(*md.def_lsm_obj),
 						 GFP_NOFS);
-			if (!md.default_lmv) {
+			if (!md.def_lsm_obj) {
 				err = -ENOMEM;
 				goto err_exit;
 			}
 
-			md.default_lmv->lsm_md_magic = lum->lum_magic;
-			md.default_lmv->lsm_md_stripe_count =
+			md.def_lsm_obj->lso_lsm.lsm_md_magic = lum->lum_magic;
+			md.def_lsm_obj->lso_lsm.lsm_md_stripe_count =
 				lum->lum_stripe_count;
-			md.default_lmv->lsm_md_master_mdt_index =
+			md.def_lsm_obj->lso_lsm.lsm_md_master_mdt_index =
 				lum->lum_stripe_offset;
-			md.default_lmv->lsm_md_hash_type = lum->lum_hash_type;
-			md.default_lmv->lsm_md_max_inherit =
+			md.def_lsm_obj->lso_lsm.lsm_md_hash_type =
+				lum->lum_hash_type;
+			md.def_lsm_obj->lso_lsm.lsm_md_max_inherit =
 				lum->lum_max_inherit;
-			md.default_lmv->lsm_md_max_inherit_rr =
+			md.def_lsm_obj->lso_lsm.lsm_md_max_inherit_rr =
 				lum->lum_max_inherit_rr;
+			atomic_set(&md.def_lsm_obj->lso_refs, 1);
 
 			err = ll_update_inode(dir, &md);
-			md_free_lustre_md(sbi->ll_md_exp, &md);
+			md_put_lustre_md(sbi->ll_md_exp, &md);
 			if (err)
 				goto err_exit;
-		} else if (err2 == -ENODATA && lli->lli_default_lsm_md) {
+		} else if (err2 == -ENODATA && lli->lli_def_lsm_obj) {
 			/*
 			 * If there are no default stripe EA on the MDT, but the
 			 * client has default stripe, then it probably means
 			 * default stripe EA has just been deleted.
 			 */
 			down_write(&lli->lli_lsm_sem);
-			kfree(lli->lli_default_lsm_md);
-			lli->lli_default_lsm_md = NULL;
+			lmv_stripe_object_put(&lli->lli_def_lsm_obj);
 			up_write(&lli->lli_lsm_sem);
 		} else {
 			goto err_exit;
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 2322b6a6ae92..399ba0c3fb55 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -302,15 +302,15 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	int rc;
 
 	/* do not allow file creation in foreign dir */
-	if ((it->it_op & IT_CREAT) && lmv_dir_foreign(op_data->op_mea1))
+	if ((it->it_op & IT_CREAT) && lmv_dir_foreign(op_data->op_lso1))
 		return -ENODATA;
 
 	if ((it->it_op & IT_CREAT) && !(flags & MDS_OPEN_BY_FID)) {
 		/* don't allow create under dir with bad hash */
-		if (lmv_dir_bad_hash(op_data->op_mea1))
+		if (lmv_dir_bad_hash(op_data->op_lso1))
 			return -EBADF;
 
-		if (lmv_dir_layout_changing(op_data->op_mea1)) {
+		if (lmv_dir_layout_changing(op_data->op_lso1)) {
 			if (flags & O_EXCL) {
 				/*
 				 * open(O_CREAT | O_EXCL) needs to check
@@ -338,12 +338,11 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	if (it->it_flags & MDS_OPEN_BY_FID) {
 		LASSERT(fid_is_sane(&op_data->op_fid2));
 
-		/*
-		 * for striped directory, we can't know parent stripe fid
+		/* for striped directory, we can't know parent stripe fid
 		 * without name, but we can set it to child fid, and MDT
 		 * will obtain it from linkea in open in such case.
 		 */
-		if (lmv_dir_striped(op_data->op_mea1))
+		if (lmv_dir_striped(op_data->op_lso1))
 			op_data->op_fid1 = op_data->op_fid2;
 
 		tgt = lmv_fid2tgt(lmv, &op_data->op_fid2);
@@ -443,7 +442,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	int rc;
 
 	/* foreign dir is not striped */
-	if (lmv_dir_foreign(op_data->op_mea1)) {
+	if (lmv_dir_foreign(op_data->op_lso1)) {
 		/* only allow getattr/lookup for itself */
 		if (op_data->op_name)
 			return -ENODATA;
@@ -502,12 +501,12 @@ static int lmv_intent_lookup(struct obd_export *exp,
 		return rc;
 
 	if (!*reqp) {
-		/*
-		 * If RPC happens, lsm information will be revalidated
+		/* If RPC happens, lsm information will be revalidated
 		 * during update_inode process (see ll_update_lsm_md)
 		 */
-		if (lmv_dir_striped(op_data->op_mea2)) {
-			rc = lmv_revalidate_slaves(exp, op_data->op_mea2,
+		if (lmv_dir_striped(op_data->op_lso2)) {
+			rc = lmv_revalidate_slaves(exp,
+						   &op_data->op_lso2->lso_lsm,
 						   cb_blocking,
 						   extra_lock_flags);
 			if (rc != 0)
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index 64ec4ae9dc17..b89e53bf35d3 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -166,13 +166,15 @@ static inline int lmv_stripe_md_size(int stripe_count)
 
 /* for file under migrating directory, return the target stripe info */
 static inline const struct lmv_oinfo *
-lsm_name_to_stripe_info(const struct lmv_stripe_md *lsm, const char *name,
+lsm_name_to_stripe_info(const struct lmv_stripe_object *lso, const char *name,
 			int namelen, bool new_layout)
 {
+	const struct lmv_stripe_md *lsm;
 	int stripe_index;
 
-	LASSERT(lmv_dir_striped(lsm));
+	LASSERT(lmv_dir_striped(lso));
 
+	lsm = &lso->lso_lsm;
 	stripe_index = __lmv_name_to_stripe_index(lsm->lsm_md_hash_type,
 						  lsm->lsm_md_stripe_count,
 						  lsm->lsm_md_migrate_hash,
@@ -186,18 +188,18 @@ lsm_name_to_stripe_info(const struct lmv_stripe_md *lsm, const char *name,
 
 static inline bool lmv_dir_retry_check_update(struct md_op_data *op_data)
 {
-	const struct lmv_stripe_md *lsm = op_data->op_mea1;
+	const struct lmv_stripe_object *lso = op_data->op_lso1;
 
-	if (!lsm)
+	if (!lso)
 		return false;
 
-	if (lmv_dir_layout_changing(lsm) && !op_data->op_new_layout) {
+	if (lmv_dir_layout_changing(lso) && !op_data->op_new_layout) {
 		op_data->op_new_layout = true;
 		return true;
 	}
 
-	if (lmv_dir_bad_hash(lsm) &&
-	    op_data->op_stripe_index < lsm->lsm_md_stripe_count - 1) {
+	if (lmv_dir_bad_hash(lso) &&
+	    op_data->op_stripe_index < lso->lso_lsm.lsm_md_stripe_count - 1) {
 		op_data->op_stripe_index++;
 		return true;
 	}
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index da28bc0e544b..eb9f0e86291f 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1666,14 +1666,14 @@ static struct lu_tgt_desc *lmv_locate_tgt_lf(struct lmv_obd *lmv)
  * which stripe its dirent is stored.
  */
 static struct lmv_tgt_desc *
-lmv_locate_tgt_by_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
+lmv_locate_tgt_by_name(struct lmv_obd *lmv, struct lmv_stripe_object *lso,
 		       const char *name, int namelen, struct lu_fid *fid,
 		       u32 *mds, bool new_layout)
 {
 	const struct lmv_oinfo *oinfo;
 	struct lmv_tgt_desc *tgt;
 
-	if (!lmv_dir_striped(lsm) || !namelen) {
+	if (!lmv_dir_striped(lso) || !namelen) {
 		tgt = lmv_fid2tgt(lmv, fid);
 		if (IS_ERR(tgt))
 			return tgt;
@@ -1683,11 +1683,11 @@ lmv_locate_tgt_by_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
 	}
 
 	if (CFS_FAIL_CHECK(OBD_FAIL_LFSCK_BAD_NAME_HASH)) {
-		if (cfs_fail_val >= lsm->lsm_md_stripe_count)
+		if (cfs_fail_val >= lso->lso_lsm.lsm_md_stripe_count)
 			return ERR_PTR(-EBADF);
-		oinfo = &lsm->lsm_md_oinfo[cfs_fail_val];
+		oinfo = &lso->lso_lsm.lsm_md_oinfo[cfs_fail_val];
 	} else {
-		oinfo = lsm_name_to_stripe_info(lsm, name, namelen, new_layout);
+		oinfo = lsm_name_to_stripe_info(lso, name, namelen, new_layout);
 		if (IS_ERR(oinfo))
 			return ERR_CAST(oinfo);
 	}
@@ -1717,7 +1717,7 @@ lmv_locate_tgt_by_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
  *
  * @lmv:	LMV device
  * @op_data:	client MD stack parameters, name, namelen etc,
- *		op_mds and op_fid1 will be updated if op_mea1
+ *		op_mds and op_fid1 will be updated if op_lso1
  *		indicates fid1 represents a striped directory.
  *
  * Returns:	pointer to the lmv_tgt_desc if succeed.
@@ -1726,11 +1726,11 @@ lmv_locate_tgt_by_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
 struct lmv_tgt_desc *
 lmv_locate_tgt(struct lmv_obd *lmv, struct md_op_data *op_data)
 {
-	struct lmv_stripe_md *lsm = op_data->op_mea1;
+	struct lmv_stripe_md *lsm;
 	struct lmv_oinfo *oinfo;
 	struct lmv_tgt_desc *tgt;
 
-	if (lmv_dir_foreign(lsm))
+	if (lmv_dir_foreign(op_data->op_lso1))
 		return ERR_PTR(-ENODATA);
 
 	/*
@@ -1744,10 +1744,11 @@ lmv_locate_tgt(struct lmv_obd *lmv, struct md_op_data *op_data)
 		if (!tgt)
 			return ERR_PTR(-ENODEV);
 
-		if (lmv_dir_striped(lsm)) {
+		if (lmv_dir_striped(op_data->op_lso1)) {
 			int i;
 
 			/* refill the right parent fid */
+			lsm = &op_data->op_lso1->lso_lsm;
 			for (i = 0; i < lsm->lsm_md_stripe_count; i++) {
 				oinfo = &lsm->lsm_md_oinfo[i];
 				if (oinfo->lmo_mds == op_data->op_mds) {
@@ -1759,7 +1760,9 @@ lmv_locate_tgt(struct lmv_obd *lmv, struct md_op_data *op_data)
 			if (i == lsm->lsm_md_stripe_count)
 				op_data->op_fid1 = lsm->lsm_md_oinfo[0].lmo_fid;
 		}
-	} else if (lmv_dir_bad_hash(lsm)) {
+	} else if (lmv_dir_bad_hash(op_data->op_lso1)) {
+		lsm = &op_data->op_lso1->lso_lsm;
+
 		LASSERT(op_data->op_stripe_index < lsm->lsm_md_stripe_count);
 		oinfo = &lsm->lsm_md_oinfo[op_data->op_stripe_index];
 
@@ -1770,7 +1773,7 @@ lmv_locate_tgt(struct lmv_obd *lmv, struct md_op_data *op_data)
 		if (!tgt)
 			return ERR_PTR(-ENODEV);
 	} else {
-		tgt = lmv_locate_tgt_by_name(lmv, op_data->op_mea1,
+		tgt = lmv_locate_tgt_by_name(lmv, op_data->op_lso1,
 					     op_data->op_name,
 					     op_data->op_namelen,
 					     &op_data->op_fid1,
@@ -1789,26 +1792,26 @@ lmv_locate_tgt2(struct lmv_obd *lmv, struct md_op_data *op_data)
 	int rc;
 
 	LASSERT(op_data->op_name);
-	if (lmv_dir_layout_changing(op_data->op_mea2)) {
+	if (lmv_dir_layout_changing(op_data->op_lso2)) {
 		struct lu_fid fid1 = op_data->op_fid1;
-		struct lmv_stripe_md *lsm1 = op_data->op_mea1;
+		struct lmv_stripe_object *lso1 = op_data->op_lso1;
 		struct ptlrpc_request *request = NULL;
 
 		/*
 		 * avoid creating new file under old layout of migrating
 		 * directory, check it here.
 		 */
-		tgt = lmv_locate_tgt_by_name(lmv, op_data->op_mea2,
+		tgt = lmv_locate_tgt_by_name(lmv, op_data->op_lso2,
 				op_data->op_name, op_data->op_namelen,
 				&op_data->op_fid2, &op_data->op_mds, false);
 		if (IS_ERR(tgt))
 			return tgt;
 
 		op_data->op_fid1 = op_data->op_fid2;
-		op_data->op_mea1 = op_data->op_mea2;
+		op_data->op_lso1 = op_data->op_lso2;
 		rc = md_getattr_name(tgt->ltd_exp, op_data, &request);
 		op_data->op_fid1 = fid1;
-		op_data->op_mea1 = lsm1;
+		op_data->op_lso1 = lso1;
 		if (!rc) {
 			ptlrpc_req_finished(request);
 			return ERR_PTR(-EEXIST);
@@ -1818,9 +1821,10 @@ lmv_locate_tgt2(struct lmv_obd *lmv, struct md_op_data *op_data)
 			return ERR_PTR(rc);
 	}
 
-	return lmv_locate_tgt_by_name(lmv, op_data->op_mea2, op_data->op_name,
-				op_data->op_namelen, &op_data->op_fid2,
-				&op_data->op_mds, true);
+	return lmv_locate_tgt_by_name(lmv, op_data->op_lso2,
+				      op_data->op_name, op_data->op_namelen,
+				      &op_data->op_fid2, &op_data->op_mds,
+				      true);
 }
 
 int lmv_old_layout_lookup(struct lmv_obd *lmv, struct md_op_data *op_data)
@@ -1829,7 +1833,7 @@ int lmv_old_layout_lookup(struct lmv_obd *lmv, struct md_op_data *op_data)
 	struct ptlrpc_request *request;
 	int rc;
 
-	LASSERT(lmv_dir_layout_changing(op_data->op_mea1));
+	LASSERT(lmv_dir_layout_changing(op_data->op_lso1));
 	LASSERT(!op_data->op_new_layout);
 
 	tgt = lmv_locate_tgt(lmv, op_data);
@@ -1857,7 +1861,7 @@ static inline bool lmv_op_user_qos_mkdir(const struct md_op_data *op_data)
 	if (op_data->op_code != LUSTRE_OPC_MKDIR)
 		return false;
 
-	if (lmv_dir_striped(op_data->op_mea1))
+	if (lmv_dir_striped(op_data->op_lso1))
 		return false;
 
 	return (op_data->op_cli_flags & CLI_SET_MEA) && lum &&
@@ -1868,16 +1872,17 @@ static inline bool lmv_op_user_qos_mkdir(const struct md_op_data *op_data)
 /* mkdir by QoS if either ROOT or parent default LMV is space balanced. */
 static inline bool lmv_op_default_qos_mkdir(const struct md_op_data *op_data)
 {
-	const struct lmv_stripe_md *lsm = op_data->op_default_mea1;
+	const struct lmv_stripe_object *lso = op_data->op_default_lso1;
 
 	if (op_data->op_code != LUSTRE_OPC_MKDIR)
 		return false;
 
-	if (lmv_dir_striped(op_data->op_mea1))
+	if (lmv_dir_striped(op_data->op_lso1))
 		return false;
 
 	return (op_data->op_flags & MF_QOS_MKDIR) ||
-	       (lsm && lsm->lsm_md_master_mdt_index == LMV_OFFSET_DEFAULT);
+	       (lso && lso->lso_lsm.lsm_md_master_mdt_index ==
+		LMV_OFFSET_DEFAULT);
 }
 
 /* if parent default LMV is space balanced, and
@@ -1889,11 +1894,11 @@ static inline bool lmv_op_default_qos_mkdir(const struct md_op_data *op_data)
  */
 static inline bool lmv_op_default_rr_mkdir(const struct md_op_data *op_data)
 {
-	const struct lmv_stripe_md *lsm = op_data->op_default_mea1;
+	const struct lmv_stripe_object *lso = op_data->op_default_lso1;
 
 	return (op_data->op_flags & MF_RR_MKDIR) ||
-	       (lsm && lsm->lsm_md_max_inherit_rr != LMV_INHERIT_RR_NONE) ||
-	       fid_is_root(&op_data->op_fid1);
+	       (lso && lso->lso_lsm.lsm_md_max_inherit_rr !=
+		LMV_INHERIT_RR_NONE) || fid_is_root(&op_data->op_fid1);
 }
 
 /* 'lfs mkdir -i <specific_MDT>' */
@@ -1913,8 +1918,8 @@ static inline bool
 lmv_op_default_specific_mkdir(const struct md_op_data *op_data)
 {
 	return op_data->op_code == LUSTRE_OPC_MKDIR &&
-	       op_data->op_default_mea1 &&
-	       op_data->op_default_mea1->lsm_md_master_mdt_index !=
+	       op_data->op_default_lso1 &&
+	       op_data->op_default_lso1->lso_lsm.lsm_md_master_mdt_index !=
 			LMV_OFFSET_DEFAULT;
 }
 
@@ -1964,10 +1969,10 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 	if (!lmv->lmv_mdt_descs.ltd_lmv_desc.ld_active_tgt_count)
 		return -EIO;
 
-	if (lmv_dir_bad_hash(op_data->op_mea1))
+	if (lmv_dir_bad_hash(op_data->op_lso1))
 		return -EBADF;
 
-	if (lmv_dir_layout_changing(op_data->op_mea1)) {
+	if (lmv_dir_layout_changing(op_data->op_lso1)) {
 		/*
 		 * if parent is migrating, create() needs to lookup existing
 		 * name in both old and new layout, check old layout on client.
@@ -2001,8 +2006,9 @@ int lmv_create(struct obd_export *exp, struct md_op_data *op_data,
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
 	} else if (lmv_op_default_specific_mkdir(op_data)) {
-		op_data->op_mds =
-			op_data->op_default_mea1->lsm_md_master_mdt_index;
+		struct lmv_stripe_md *lsm = &op_data->op_default_lso1->lso_lsm;
+
+		op_data->op_mds = lsm->lsm_md_master_mdt_index;
 		tgt = lmv_tgt(lmv, op_data->op_mds);
 		if (!tgt)
 			return -ENODEV;
@@ -2215,7 +2221,7 @@ static inline bool lmv_op_topdir_migrate(const struct md_op_data *op_data)
 	if (!S_ISDIR(op_data->op_mode))
 		return false;
 
-	if (lmv_dir_layout_changing(op_data->op_mea1))
+	if (lmv_dir_layout_changing(op_data->op_lso1))
 		return false;
 
 	return true;
@@ -2250,7 +2256,7 @@ static inline bool lmv_subdir_specific_migrate(const struct md_op_data *op_data)
 	if (!S_ISDIR(op_data->op_mode))
 		return false;
 
-	if (!lmv_dir_layout_changing(op_data->op_mea1))
+	if (!lmv_dir_layout_changing(op_data->op_lso1))
 		return false;
 
 	return le32_to_cpu(lum->lum_stripe_offset) != LMV_OFFSET_DEFAULT;
@@ -2262,7 +2268,7 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
-	struct lmv_stripe_md *lsm = op_data->op_mea1;
+	struct lmv_stripe_object *lso = op_data->op_lso1;
 	struct lmv_tgt_desc *parent_tgt;
 	struct lmv_tgt_desc *sp_tgt;
 	struct lmv_tgt_desc *tp_tgt = NULL;
@@ -2284,10 +2290,10 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 	if (IS_ERR(parent_tgt))
 		return PTR_ERR(parent_tgt);
 
-	if (lmv_dir_striped(lsm)) {
+	if (lmv_dir_striped(lso)) {
 		const struct lmv_oinfo *oinfo;
 
-		oinfo = lsm_name_to_stripe_info(lsm, name, namelen, false);
+		oinfo = lsm_name_to_stripe_info(lso, name, namelen, false);
 		if (IS_ERR(oinfo))
 			return PTR_ERR(oinfo);
 
@@ -2301,8 +2307,8 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 		 * if parent is being migrated too, fill op_fid2 with target
 		 * stripe fid, otherwise the target stripe is not created yet.
 		 */
-		if (lmv_dir_layout_changing(lsm)) {
-			oinfo = lsm_name_to_stripe_info(lsm, name, namelen,
+		if (lmv_dir_layout_changing(lso)) {
+			oinfo = lsm_name_to_stripe_info(lso, name, namelen,
 							true);
 			if (IS_ERR(oinfo))
 				return PTR_ERR(oinfo);
@@ -2729,7 +2735,7 @@ static struct lu_dirent *stripe_dirent_load(struct lmv_dir_ctxt *ctxt,
 			hash = end;
 		}
 
-		oinfo = &op_data->op_mea1->lsm_md_oinfo[stripe_index];
+		oinfo = &op_data->op_lso1->lso_lsm.lsm_md_oinfo[stripe_index];
 		if (!oinfo->lmo_root) {
 			rc = -ENOENT;
 			break;
@@ -2912,7 +2918,7 @@ static int lmv_striped_read_page(struct obd_export *exp,
 	last_ent = ent;
 
 	/* initialize dir read context */
-	stripe_count = op_data->op_mea1->lsm_md_stripe_count;
+	stripe_count = op_data->op_lso1->lso_lsm.lsm_md_stripe_count;
 	ctxt = kzalloc(offsetof(typeof(*ctxt), ldc_stripes[stripe_count]),
 		       GFP_NOFS);
 	if (!ctxt) {
@@ -3005,10 +3011,10 @@ static int lmv_read_page(struct obd_export *exp, struct md_op_data *op_data,
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt;
 
-	if (unlikely(lmv_dir_foreign(op_data->op_mea1)))
+	if (unlikely(lmv_dir_foreign(op_data->op_lso1)))
 		return -ENODATA;
 
-	if (unlikely(lmv_dir_striped(op_data->op_mea1))) {
+	if (unlikely(lmv_dir_striped(op_data->op_lso1))) {
 		return lmv_striped_read_page(exp, op_data, mrinfo, offset,
 					     ppage);
 	}
@@ -3414,117 +3420,187 @@ static inline int lmv_unpack_user_md(struct obd_export *exp,
 	return 0;
 }
 
-static int lmv_unpackmd(struct obd_export *exp, struct lmv_stripe_md **lsmp,
-			const union lmv_mds_md *lmm, size_t lmm_size)
+struct lmv_stripe_object *lmv_stripe_object_alloc(u32 magic,
+						  const union lmv_mds_md *lmm,
+						  size_t lmm_size)
 {
-	struct lmv_stripe_md *lsm;
-	bool allocated = false;
-	int lsm_size, rc;
+	struct lmv_stripe_object *lsm_obj;
+	int size;
 
-	LASSERT(lsmp);
+	if (magic == LMV_MAGIC_FOREIGN) {
+		struct lmv_foreign_md *lfm;
 
-	lsm = *lsmp;
-	/* Free memmd */
-	if (lsm && !lmm) {
-		int i;
-		struct lmv_foreign_md *lfm = (struct lmv_foreign_md *)lsm;
+		size = offsetof(typeof(*lfm), lfm_value[0]);
+		if (lmm_size < size)
+			return ERR_PTR(-EPROTO);
 
-		if (lfm->lfm_magic == LMV_MAGIC_FOREIGN) {
-			size_t lfm_size;
+		size += le32_to_cpu(lmm->lmv_foreign_md.lfm_length);
+		if (lmm_size < size)
+			return ERR_PTR(-EPROTO);
 
-			lfm_size = lfm->lfm_length + offsetof(typeof(*lfm),
-							      lfm_value[0]);
-			kvfree(lfm);
-			return 0;
-		}
+		lsm_obj = kvmalloc(lmm_size +
+				   offsetof(typeof(*lsm_obj), lso_lfm),
+				   GFP_NOFS);
+	} else {
+		if (magic == LMV_MAGIC_V1) {
+			int count;
+
+			size = offsetof(struct lmv_mds_md_v1,
+					lmv_stripe_fids[0]);
+			if (lmm_size < size)
+				return ERR_PTR(-EPROTO);
+
+			count = lmv_mds_md_stripe_count_get(lmm);
+			size += count * sizeof(struct lu_fid);
+			if (lmm_size < size)
+				return ERR_PTR(-EPROTO);
 
-		if (lmv_dir_striped(lsm)) {
-			for (i = 0; i < lsm->lsm_md_stripe_count; i++)
-				iput(lsm->lsm_md_oinfo[i].lmo_root);
-			lsm_size = lmv_stripe_md_size(lsm->lsm_md_stripe_count);
+			size = lmv_stripe_md_size(count);
 		} else {
-			lsm_size = lmv_stripe_md_size(0);
+			if (lmm && lmm_size < sizeof(struct lmv_user_md))
+				return ERR_PTR(-EPROTO);
+
+			/**
+			 * Unpack default dirstripe(lmv_user_md) to
+			 * lmv_stripe_md, stripecount should be 0 then.
+			 */
+			size = lmv_stripe_md_size(0);
 		}
-		kvfree(lsm);
-		*lsmp = NULL;
-		return 0;
+		size += offsetof(typeof(*lsm_obj), lso_lsm);
+		lsm_obj = kzalloc(size, GFP_NOFS);
 	}
 
-	/* foreign lmv case */
-	if (le32_to_cpu(lmm->lmv_magic) == LMV_MAGIC_FOREIGN) {
-		struct lmv_foreign_md *lfm = (struct lmv_foreign_md *)lsm;
-
-		if (!lfm) {
-			lfm = kvzalloc(lmm_size, GFP_NOFS);
-			if (!lfm)
-				return -ENOMEM;
-			*lsmp = (struct lmv_stripe_md *)lfm;
-		}
-		lfm->lfm_magic = le32_to_cpu(lmm->lmv_foreign_md.lfm_magic);
-		lfm->lfm_length = le32_to_cpu(lmm->lmv_foreign_md.lfm_length);
-		lfm->lfm_type = le32_to_cpu(lmm->lmv_foreign_md.lfm_type);
-		lfm->lfm_flags = le32_to_cpu(lmm->lmv_foreign_md.lfm_flags);
-		memcpy(&lfm->lfm_value, &lmm->lmv_foreign_md.lfm_value,
-		       lfm->lfm_length);
-		return lmm_size;
+	if (lsm_obj) {
+		atomic_set(&lsm_obj->lso_refs, 1);
+		return lsm_obj;
 	}
 
-	if (le32_to_cpu(lmm->lmv_magic) == LMV_MAGIC_STRIPE)
+	return ERR_PTR(-ENOMEM);
+}
+EXPORT_SYMBOL(lmv_stripe_object_alloc);
+
+static int lmv_stripe_object_create(struct obd_export *exp,
+				    struct lmv_stripe_object **lsop,
+				    const union lmv_mds_md *lmm,
+				    size_t lmm_size)
+{
+	struct lmv_stripe_object *lsm_obj;
+	u32 magic;
+	int rc;
+
+	LASSERT(lsop && !*lsop);
+	if (lmm_size == 0)
+		return -EPROTO;
+
+	magic = le32_to_cpu(lmm->lmv_magic);
+	if (magic == LMV_MAGIC_STRIPE)
 		return -EPERM;
 
-	/* Unpack memmd */
-	if (le32_to_cpu(lmm->lmv_magic) != LMV_MAGIC_V1 &&
-	    le32_to_cpu(lmm->lmv_magic) != LMV_USER_MAGIC) {
+	if (magic != LMV_MAGIC_V1 && magic != LMV_USER_MAGIC &&
+	    magic != LMV_MAGIC_FOREIGN) {
 		CERROR("%s: invalid lmv magic %x: rc = %d\n",
-		       exp->exp_obd->obd_name, le32_to_cpu(lmm->lmv_magic),
-		       -EIO);
+		       exp->exp_obd->obd_name, magic, -EIO);
 		return -EIO;
 	}
 
-	if (le32_to_cpu(lmm->lmv_magic) == LMV_MAGIC_V1)
-		lsm_size = lmv_stripe_md_size(lmv_mds_md_stripe_count_get(lmm));
-	else
-		/**
-		 * Unpack default dirstripe(lmv_user_md) to lmv_stripe_md,
-		 * stripecount should be 0 then.
-		 */
-		lsm_size = lmv_stripe_md_size(0);
+	/* foreign lmv case */
+	if (magic == LMV_MAGIC_FOREIGN) {
+		struct lmv_foreign_md *lfm;
 
-	if (!lsm) {
-		lsm = kvzalloc(lsm_size, GFP_NOFS);
-		if (!lsm)
-			return -ENOMEM;
-		allocated = true;
-		*lsmp = lsm;
+		lsm_obj = lmv_stripe_object_alloc(magic, lmm, lmm_size);
+		if (IS_ERR(lsm_obj))
+			return PTR_ERR(lsm_obj);
+
+		*lsop = lsm_obj;
+		lfm = &lsm_obj->lso_lfm;
+		lfm->lfm_magic = magic;
+		lfm->lfm_length = le32_to_cpu(lmm->lmv_foreign_md.lfm_length);
+		lfm->lfm_type = le32_to_cpu(lmm->lmv_foreign_md.lfm_type);
+		lfm->lfm_flags = le32_to_cpu(lmm->lmv_foreign_md.lfm_flags);
+		memcpy(&lfm->lfm_value, &lmm->lmv_foreign_md.lfm_value,
+		       lfm->lfm_length);
+		return 0;
 	}
 
-	switch (le32_to_cpu(lmm->lmv_magic)) {
+	/* Unpack memmd */
+	lsm_obj = lmv_stripe_object_alloc(magic, lmm, lmm_size);
+	if (IS_ERR(lsm_obj))
+		return PTR_ERR(lsm_obj);
+
+	switch (magic) {
 	case LMV_MAGIC_V1:
-		rc = lmv_unpack_md_v1(exp, lsm, &lmm->lmv_md_v1);
+		rc = lmv_unpack_md_v1(exp, &lsm_obj->lso_lsm, &lmm->lmv_md_v1);
 		break;
 	case LMV_USER_MAGIC:
-		rc = lmv_unpack_user_md(exp, lsm, &lmm->lmv_user_md);
+		rc = lmv_unpack_user_md(exp, &lsm_obj->lso_lsm,
+					&lmm->lmv_user_md);
 		break;
 	default:
 		CERROR("%s: unrecognized magic %x\n", exp->exp_obd->obd_name,
-		       le32_to_cpu(lmm->lmv_magic));
+		       magic);
 		rc = -EINVAL;
 		break;
 	}
 
-	if (rc && allocated) {
-		kvfree(lsm);
-		*lsmp = NULL;
-		lsm_size = rc;
-	}
-	return lsm_size;
+	if (rc != 0)
+		lmv_stripe_object_put(&lsm_obj);
+
+	*lsop = lsm_obj;
+	return rc;
+}
+
+struct lmv_stripe_object *
+lmv_stripe_object_get(struct lmv_stripe_object *lsm_obj)
+{
+	if (!lsm_obj)
+		return NULL;
+
+	atomic_inc(&lsm_obj->lso_refs);
+	CDEBUG(D_INODE, "get %p %u\n", lsm_obj,
+	       atomic_read(&lsm_obj->lso_refs));
+	return lsm_obj;
 }
+EXPORT_SYMBOL(lmv_stripe_object_get);
 
-void lmv_free_memmd(struct lmv_stripe_md *lsm)
+void lmv_stripe_object_put(struct lmv_stripe_object **lsop)
 {
-	lmv_unpackmd(NULL, &lsm, NULL, 0);
+	struct lmv_stripe_object *lsm_obj;
+	size_t size;
+	int i;
+
+	LASSERT(lsop);
+
+	lsm_obj = *lsop;
+	if (!lsm_obj)
+		return;
+
+	*lsop = NULL;
+	CDEBUG(D_INODE, "put %p %u\n", lsm_obj,
+	       atomic_read(&lsm_obj->lso_refs) - 1);
+
+	if (!atomic_dec_and_test(&lsm_obj->lso_refs))
+		return;
+
+	if (lmv_dir_foreign(lsm_obj)) {
+		size = lsm_obj->lso_lfm.lfm_length +
+		       offsetof(typeof(lsm_obj->lso_lfm), lfm_value[0]) +
+		       offsetof(typeof(*lsm_obj), lso_lsm);
+		kvfree(lsm_obj);
+		return;
+	}
+
+	if (lmv_dir_striped(lsm_obj)) {
+		struct lmv_stripe_md *lsm = &lsm_obj->lso_lsm;
+
+		for (i = 0; i < lsm->lsm_md_stripe_count; i++)
+			iput(lsm->lsm_md_oinfo[i].lmo_root);
+		size = lmv_stripe_md_size(lsm->lsm_md_stripe_count);
+	} else {
+		size = lmv_stripe_md_size(0);
+	}
+	kfree(lsm_obj);
 }
-EXPORT_SYMBOL(lmv_free_memmd);
+EXPORT_SYMBOL(lmv_stripe_object_put);
 
 static int lmv_cancel_unused(struct obd_export *exp, const struct lu_fid *fid,
 			     union ldlm_policy_data *policy,
@@ -3633,23 +3709,18 @@ static int lmv_get_lustre_md(struct obd_export *exp,
 	return md_get_lustre_md(tgt->ltd_exp, pill, dt_exp, md_exp, md);
 }
 
-static int lmv_free_lustre_md(struct obd_export *exp, struct lustre_md *md)
+static int lmv_put_lustre_md(struct obd_export *exp, struct lustre_md *md)
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
 	struct lmv_tgt_desc *tgt = lmv_tgt(lmv, 0);
 
-	if (md->default_lmv) {
-		lmv_free_memmd(md->default_lmv);
-		md->default_lmv = NULL;
-	}
-	if (md->lmv) {
-		lmv_free_memmd(md->lmv);
-		md->lmv = NULL;
-	}
+	lmv_stripe_object_put(&md->def_lsm_obj);
+	lmv_stripe_object_put(&md->lsm_obj);
+
 	if (!tgt || !tgt->ltd_exp)
 		return -EINVAL;
-	return md_free_lustre_md(tgt->ltd_exp, md);
+	return 0;
 }
 
 static int lmv_set_open_replay_data(struct obd_export *exp,
@@ -3725,16 +3796,15 @@ static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 	return md_revalidate_lock(tgt->ltd_exp, it, fid, bits);
 }
 
-static int
-lmv_get_fid_from_lsm(struct obd_export *exp,
-		     const struct lmv_stripe_md *lsm,
-		     const char *name, int namelen, struct lu_fid *fid)
+static int lmv_get_fid_from_lsm(struct obd_export *exp,
+				const struct lmv_stripe_object *lso,
+				const char *name, int namelen,
+				struct lu_fid *fid)
 {
 	const struct lmv_oinfo *oinfo;
 
-	LASSERT(lmv_dir_striped(lsm));
-
-	oinfo = lsm_name_to_stripe_info(lsm, name, namelen, false);
+	LASSERT(lmv_dir_striped(lso));
+	oinfo = lsm_name_to_stripe_info(lso, name, namelen, false);
 	if (IS_ERR(oinfo))
 		return PTR_ERR(oinfo);
 
@@ -3789,13 +3859,14 @@ static int lmv_quotactl(struct obd_device *unused, struct obd_export *exp,
 }
 
 static int lmv_merge_attr(struct obd_export *exp,
-			  const struct lmv_stripe_md *lsm,
+			  const struct lmv_stripe_object *lso,
 			  struct cl_attr *attr,
 			  ldlm_blocking_callback cb_blocking)
 {
+	const struct lmv_stripe_md *lsm = &lso->lso_lsm;
 	int rc, i;
 
-	if (!lmv_dir_striped(lsm))
+	if (!lmv_dir_striped(lso))
 		return 0;
 
 	rc = lmv_revalidate_slaves(exp, lsm, cb_blocking, 0);
@@ -4073,14 +4144,14 @@ static const struct md_ops lmv_md_ops = {
 	.set_lock_data		= lmv_set_lock_data,
 	.lock_match		= lmv_lock_match,
 	.get_lustre_md		= lmv_get_lustre_md,
-	.free_lustre_md		= lmv_free_lustre_md,
+	.put_lustre_md		= lmv_put_lustre_md,
 	.merge_attr		= lmv_merge_attr,
 	.set_open_replay_data	= lmv_set_open_replay_data,
 	.clear_open_replay_data	= lmv_clear_open_replay_data,
 	.intent_getattr_async	= lmv_intent_getattr_async,
 	.revalidate_lock	= lmv_revalidate_lock,
 	.get_fid_from_lsm	= lmv_get_fid_from_lsm,
-	.unpackmd		= lmv_unpackmd,
+	.stripe_object_create	= lmv_stripe_object_create,
 	.rmfid			= lmv_rmfid,
 	.batch_create		= lmv_batch_create,
 	.batch_add		= lmv_batch_add,
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index d0f51b2e0051..64f19a2f3a40 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -617,29 +617,17 @@ static int mdc_get_lustre_md(struct obd_export *exp, struct req_capsule *pill,
 				goto out;
 			}
 
-			rc = md_unpackmd(md_exp, &md->lmv, lmv, lmv_size);
+			rc = md_stripe_object_create(md_exp, &md->lsm_obj,
+						     lmv, lmv_size);
 			if (rc < 0)
 				goto out;
-
-			if (rc < (int)sizeof(*md->lmv)) {
-				struct lmv_foreign_md *lfm = md->lfm;
-
-				/* short (< sizeof(struct lmv_stripe_md))
-				 * foreign LMV case
-				 */
-				if (lfm->lfm_magic != LMV_MAGIC_FOREIGN) {
-					CDEBUG(D_INFO,
-					       "lmv size too small: %d < %d\n",
-					       rc, (int)sizeof(*md->lmv));
-					rc = -EPROTO;
-					goto out;
-				}
-			}
 		}
 
 		/* since 2.12.58 intent_getattr fetches default LMV */
 		if (md->body->mbo_valid & OBD_MD_DEFAULT_MEA) {
-			lmv_size = sizeof(struct lmv_user_md);
+			lmv_size = req_capsule_get_size(pill,
+							&RMF_DEFAULT_MDT_MD,
+							RCL_SERVER);
 			lmv = req_capsule_server_sized_get(pill,
 							   &RMF_DEFAULT_MDT_MD,
 							   lmv_size);
@@ -648,18 +636,10 @@ static int mdc_get_lustre_md(struct obd_export *exp, struct req_capsule *pill,
 				goto out;
 			}
 
-			rc = md_unpackmd(md_exp, &md->default_lmv, lmv,
-					 lmv_size);
+			rc = md_stripe_object_create(md_exp, &md->def_lsm_obj,
+						     lmv, lmv_size);
 			if (rc < 0)
 				goto out;
-
-			if (rc < (int)sizeof(*md->default_lmv)) {
-				CDEBUG(D_INFO,
-				       "default lmv size too small: %d < %d\n",
-				       rc, (int)sizeof(*md->lmv));
-				rc = -EPROTO;
-				goto out;
-			}
 		}
 	}
 	rc = 0;
@@ -671,19 +651,15 @@ static int mdc_get_lustre_md(struct obd_export *exp, struct req_capsule *pill,
 	 */
 	if (md->body->mbo_valid & OBD_MD_FLACL)
 		rc = mdc_unpack_acl(pill, md);
-
 out:
-	if (rc)
+	if (rc) {
 		lmd_clear_acl(md);
+		md_put_lustre_md(md_exp, md);
+	}
 
 	return rc;
 }
 
-static int mdc_free_lustre_md(struct obd_export *exp, struct lustre_md *md)
-{
-	return 0;
-}
-
 void mdc_replay_open(struct ptlrpc_request *req)
 {
 	struct md_open_data *mod = req->rq_cb_data;
@@ -3030,7 +3006,6 @@ static const struct md_ops mdc_md_ops = {
 	.set_lock_data		= mdc_set_lock_data,
 	.lock_match		= mdc_lock_match,
 	.get_lustre_md		= mdc_get_lustre_md,
-	.free_lustre_md		= mdc_free_lustre_md,
 	.set_open_replay_data	= mdc_set_open_replay_data,
 	.clear_open_replay_data	= mdc_clear_open_replay_data,
 	.intent_getattr_async	= mdc_intent_getattr_async,
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
