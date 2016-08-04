From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:52:59 -0400
Subject: [lustre-devel] [PATCH 23/32] staging: lustre: fid: do open-by-fid
	by default
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Lai Siyao <lai.siyao@intel.com>, James Simmons <jsimmons@infradead.org>

From: Lai Siyao <lai.siyao@intel.com>

Currently client open-by-fid often packs name into the request,
but the name may be invalid, eg. NFS export, and even if it's
valid, it may cause inconsistency because this operation is done
on this fid, which is globally unique, but name not.

Since open-by-fid doesn't pack name, for striped dir we can't know
parent stripe fid on client, so we set parent fid the same as
child fid, and MDT has to find its parent fid from linkea (this is
already supported by MDT).

M_CHECK_STALE becomes obsolete.

Unset MDS_OPEN_FL_INTERNAL from open syscall flags, because these
flags are internally used, and should not be set from user space.

It's not necessary to store parent fid in lli_pfid, because MDT
can get it's parent fid from linkea, and now that DNE stripe
directory stores master inode fid in lli_pfid, stop storing parent
fid to avoid conflict.

Signed-off-by: Lai Siyao <lai.siyao@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3544
Reviewed-on: http://review.whamcloud.com/7476
Reviewed-on: http://review.whamcloud.com/10692
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    5 ++
 .../staging/lustre/lustre/include/lustre_lite.h    |    1 -
 drivers/staging/lustre/lustre/include/lustre_mds.h |    3 -
 drivers/staging/lustre/lustre/llite/file.c         |   71 +++++++++-----------
 .../staging/lustre/lustre/llite/llite_internal.h   |    4 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   17 +----
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |   14 +++-
 drivers/staging/lustre/lustre/llite/namei.c        |    1 +
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |   41 +++++------
 drivers/staging/lustre/lustre/mdc/mdc_internal.h   |    1 -
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |    5 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   21 ------
 .../lustre/lustre/obdclass/lprocfs_status.c        |    2 +-
 13 files changed, 71 insertions(+), 115 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 400ab3c..a9661c0 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -2252,6 +2252,11 @@ void lustre_swab_mdt_rec_setattr(struct mdt_rec_setattr *sa);
 					      */
 #define MDS_OPEN_RELEASE   02000000000000ULL /* Open the file for HSM release */
 
+#define MDS_OPEN_FL_INTERNAL (MDS_OPEN_HAS_EA | MDS_OPEN_HAS_OBJS |	\
+			      MDS_OPEN_OWNEROVERRIDE | MDS_OPEN_LOCK |	\
+			      MDS_OPEN_BY_FID | MDS_OPEN_LEASE |	\
+			      MDS_OPEN_RELEASE)
+
 enum mds_op_bias {
 	MDS_CHECK_SPLIT		= 1 << 0,
 	MDS_CROSS_REF		= 1 << 1,
diff --git a/drivers/staging/lustre/lustre/include/lustre_lite.h b/drivers/staging/lustre/lustre/include/lustre_lite.h
index b168977..a3d7573 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lite.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lite.h
@@ -42,7 +42,6 @@
 
 #include "obd_class.h"
 #include "lustre_net.h"
-#include "lustre_mds.h"
 #include "lustre_ha.h"
 
 /* 4UL * 1024 * 1024 */
diff --git a/drivers/staging/lustre/lustre/include/lustre_mds.h b/drivers/staging/lustre/lustre/include/lustre_mds.h
index 4104bd9..23a7e4f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mds.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mds.h
@@ -58,9 +58,6 @@ struct mds_group_info {
 #define MDD_OBD_NAME     "mdd_obd"
 #define MDD_OBD_UUID     "mdd_obd_uuid"
 
-/* these are local flags, used only on the client, private */
-#define M_CHECK_STALE	   0200000000
-
 /** @} mds */
 
 #endif
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 8d690d7..03531c6 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -379,53 +379,35 @@ int ll_file_release(struct inode *inode, struct file *file)
 	return rc;
 }
 
-static int ll_intent_file_open(struct dentry *dentry, void *lmm,
-			       int lmmsize, struct lookup_intent *itp)
+static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
+			       struct lookup_intent *itp)
 {
-	struct inode *inode = d_inode(dentry);
+	struct inode *inode = d_inode(de);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
-	struct dentry *parent = dentry->d_parent;
-	const char *name = dentry->d_name.name;
-	const int len = dentry->d_name.len;
+	struct dentry *parent = de->d_parent;
+	const char *name = NULL;
 	struct md_op_data *op_data;
 	struct ptlrpc_request *req;
-	__u32 opc = LUSTRE_OPC_ANY;
-	int rc;
+	int len = 0, rc;
 
-	/* Usually we come here only for NFSD, and we want open lock. */
-	/* We can also get here if there was cached open handle in revalidate_it
-	 * but it disappeared while we were getting from there to ll_file_open.
-	 * But this means this file was closed and immediately opened which
-	 * makes a good candidate for using OPEN lock
-	 */
-	/* If lmmsize & lmm are not 0, we are just setting stripe info
-	 * parameters. No need for the open lock
+	LASSERT(parent);
+	LASSERT(itp->it_flags & MDS_OPEN_BY_FID);
+
+	/*
+	 * if server supports open-by-fid, or file name is invalid, don't pack
+	 * name in open request
 	 */
-	if (!lmm && lmmsize == 0) {
-		struct ll_dentry_data *ldd = ll_d2d(dentry);
-		/*
-		 * If we came via ll_iget_for_nfs, then we need to request
-		 * struct ll_dentry_data *ldd = ll_d2d(file->f_dentry);
-		 *
-		 * NB: when ldd is NULL, it must have come via normal
-		 * lookup path only, since ll_iget_for_nfs always calls
-		 * ll_d_init().
-		 */
-		if (ldd && ldd->lld_nfs_dentry) {
-			ldd->lld_nfs_dentry = 0;
-			itp->it_flags |= MDS_OPEN_LOCK;
-		}
-		if (itp->it_flags & FMODE_WRITE)
-			opc = LUSTRE_OPC_CREATE;
+	if (!(exp_connect_flags(sbi->ll_md_exp) & OBD_CONNECT_OPEN_BY_FID) &&
+	    lu_name_is_valid_2(de->d_name.name, de->d_name.len)) {
+		name = de->d_name.name;
+		len = de->d_name.len;
 	}
 
-	op_data  = ll_prep_md_op_data(NULL, d_inode(parent),
-				      inode, name, len,
-				      O_RDWR, opc, NULL);
+	op_data  = ll_prep_md_op_data(NULL, d_inode(parent), inode, name, len,
+				      O_RDWR, LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	itp->it_flags |= MDS_OPEN_BY_FID;
 	rc = md_intent_lock(sbi->ll_md_exp, op_data, lmm, lmmsize, itp,
 			    0 /*unused */, &req, ll_md_blocking_ast, 0);
 	ll_finish_md_op_data(op_data);
@@ -655,9 +637,19 @@ restart:
 			 * result in a deadlock
 			 */
 			mutex_unlock(&lli->lli_och_mutex);
-			it->it_create_mode |= M_CHECK_STALE;
+			/*
+			 * Normally called under two situations:
+			 * 1. NFS export.
+			 * 2. revalidate with IT_OPEN (revalidate doesn't
+			 *    execute this intent any more).
+			 *
+			 * Always fetch MDS_OPEN_LOCK if this is not setstripe.
+			 *
+			 * Always specify MDS_OPEN_BY_FID because we don't want
+			 * to get file with different fid.
+			 */
+			it->it_flags |= MDS_OPEN_LOCK | MDS_OPEN_BY_FID;
 			rc = ll_intent_file_open(file->f_path.dentry, NULL, 0, it);
-			it->it_create_mode &= ~M_CHECK_STALE;
 			if (rc)
 				goto out_openerr;
 
@@ -1399,6 +1391,7 @@ int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
 	}
 
 	ll_inode_size_lock(inode);
+	oit.it_flags |= MDS_OPEN_BY_FID;
 	rc = ll_intent_file_open(dentry, lum, lum_size, &oit);
 	if (rc)
 		goto out_unlock;
@@ -3066,7 +3059,6 @@ static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 		if (IS_ERR(op_data))
 			return PTR_ERR(op_data);
 
-		oit.it_create_mode |= M_CHECK_STALE;
 		rc = md_intent_lock(exp, op_data, NULL, 0,
 				    /* we are not interested in name
 				     * based lookup
@@ -3074,7 +3066,6 @@ static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 				    &oit, 0, &req,
 				    ll_md_blocking_ast, 0);
 		ll_finish_md_op_data(op_data);
-		oit.it_create_mode &= ~M_CHECK_STALE;
 		if (rc < 0) {
 			rc = ll_inode_revalidate_fini(inode, rc);
 			goto out;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 43269aa..b4e843a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -118,9 +118,7 @@ struct ll_inode_info {
 
 	/* identifying fields for both metadata and data stacks. */
 	struct lu_fid		   lli_fid;
-	/* Parent fid for accessing default stripe data on parent directory
-	 * for allocating OST objects after a mknod() and later open-by-FID.
-	 */
+	/* master inode fid for stripe directory */
 	struct lu_fid		   lli_pfid;
 
 	struct list_head	      lli_close_list;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 5f6343a..da00fbd 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -189,7 +189,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 				  OBD_CONNECT_PINGLESS |
 				  OBD_CONNECT_MAX_EASIZE |
 				  OBD_CONNECT_FLOCK_DEAD |
-				  OBD_CONNECT_DISP_STRIPE | OBD_CONNECT_LFSCK;
+				  OBD_CONNECT_DISP_STRIPE | OBD_CONNECT_LFSCK |
+				  OBD_CONNECT_OPEN_BY_FID;
 
 	if (sbi->ll_flags & LL_SBI_SOM_PREVIEW)
 		data->ocd_connect_flags |= OBD_CONNECT_SOM;
@@ -2364,20 +2365,6 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 	op_data->op_mds = 0;
 	op_data->op_data = data;
 
-	/* If the file is being opened after mknod() (normally due to NFS)
-	 * try to use the default stripe data from parent directory for
-	 * allocating OST objects.  Try to pass the parent FID to MDS.
-	 */
-	if (opc == LUSTRE_OPC_CREATE && i1 == i2 && S_ISREG(i2->i_mode) &&
-	    !ll_i2info(i2)->lli_has_smd) {
-		struct ll_inode_info *lli = ll_i2info(i2);
-
-		spin_lock(&lli->lli_lock);
-		if (likely(!lli->lli_has_smd && !fid_is_zero(&lli->lli_pfid)))
-			op_data->op_fid1 = lli->lli_pfid;
-		spin_unlock(&lli->lli_lock);
-	}
-
 	/* When called by ll_setattr_raw, file is i1. */
 	if (ll_i2info(i1)->lli_flags & LLIF_DATA_MODIFIED)
 		op_data->op_bias |= MDS_DATA_MODIFIED;
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index ac96d89..2b65240 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -148,12 +148,18 @@ ll_iget_for_nfs(struct super_block *sb, struct lu_fid *fid, struct lu_fid *paren
 		return ERR_PTR(-ESTALE);
 	}
 
+	result = d_obtain_alias(inode);
+	if (IS_ERR(result)) {
+		iput(inode);
+		return result;
+	}
+
 	/**
-	 * It is an anonymous dentry without OST objects created yet.
-	 * We have to find the parent to tell MDS how to init lov objects.
+	 * In case d_obtain_alias() found a disconnected dentry, always update
+	 * lli_pfid to allow later operation (normally open) have parent fid,
+	 * which may be used by MDS to create data.
 	 */
-	if (S_ISREG(inode->i_mode) && !ll_i2info(inode)->lli_has_smd &&
-	    parent && !fid_is_zero(parent)) {
+	if (parent) {
 		struct ll_inode_info *lli = ll_i2info(inode);
 
 		spin_lock(&lli->lli_lock);
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index ac0f442..ee5a42e 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -650,6 +650,7 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	}
 	it->it_create_mode = (mode & S_IALLUGO) | S_IFREG;
 	it->it_flags = (open_flags & ~O_ACCMODE) | OPEN_FMODE(open_flags);
+	it->it_flags &= ~MDS_OPEN_FL_INTERNAL;
 
 	/* Dentry added to dcache tree in ll_lookup_it */
 	de = ll_lookup_it(dir, dentry, it, lookup_flags);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 761ab24..cde1d7b 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -111,10 +111,6 @@ static int lmv_intent_remote(struct obd_export *exp, void *lmm,
 		 */
 		LASSERT(it->it_op & IT_OPEN);
 		op_data->op_fid2 = *parent_fid;
-		/* Add object FID to op_fid3, in case it needs to check stale
-		 * (M_CHECK_STALE), see mdc_finish_intent_lock
-		 */
-		op_data->op_fid3 = body->mbo_fid1;
 	}
 
 	op_data->op_bias = MDS_CROSS_REF;
@@ -313,17 +309,16 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	struct mdt_body		*body;
 	int			rc;
 
-	if (it->it_flags & MDS_OPEN_BY_FID && fid_is_sane(&op_data->op_fid2)) {
-		if (op_data->op_mea1) {
-			struct lmv_stripe_md *lsm = op_data->op_mea1;
-			const struct lmv_oinfo *oinfo;
+	if (it->it_flags & MDS_OPEN_BY_FID) {
+		LASSERT(fid_is_sane(&op_data->op_fid2));
 
-			oinfo = lsm_name_to_stripe_info(lsm, op_data->op_name,
-							op_data->op_namelen);
-			if (IS_ERR(oinfo))
-				return PTR_ERR(oinfo);
-			op_data->op_fid1 = oinfo->lmo_fid;
-		}
+		/*
+		 * for striped directory, we can't know parent stripe fid
+		 * without name, but we can set it to child fid, and MDT
+		 * will obtain it from linkea in open in such case.
+		 */
+		if (op_data->op_mea1)
+			op_data->op_fid1 = op_data->op_fid2;
 
 		tgt = lmv_find_target(lmv, &op_data->op_fid2);
 		if (IS_ERR(tgt))
@@ -331,6 +326,10 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 
 		op_data->op_mds = tgt->ltd_idx;
 	} else {
+		LASSERT(fid_is_sane(&op_data->op_fid1));
+		LASSERT(fid_is_zero(&op_data->op_fid2));
+		LASSERT(op_data->op_name);
+
 		tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
 		if (IS_ERR(tgt))
 			return PTR_ERR(tgt);
@@ -339,13 +338,11 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	/* If it is ready to open the file by FID, do not need
 	 * allocate FID at all, otherwise it will confuse MDT
 	 */
-	if ((it->it_op & IT_CREAT) &&
-	    !(it->it_flags & MDS_OPEN_BY_FID)) {
+	if ((it->it_op & IT_CREAT) && !(it->it_flags & MDS_OPEN_BY_FID)) {
 		/*
-		 * For open with IT_CREATE and for IT_CREATE cases allocate new
-		 * fid and setup FLD for it.
+		 * For lookup(IT_CREATE) cases allocate new fid and setup FLD
+		 * for it.
 		 */
-		op_data->op_fid3 = op_data->op_fid2;
 		rc = lmv_fid_alloc(NULL, exp, &op_data->op_fid2, op_data);
 		if (rc != 0)
 			return rc;
@@ -494,9 +491,9 @@ int lmv_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 
 	LASSERT(fid_is_sane(&op_data->op_fid1));
 
-	CDEBUG(D_INODE, "INTENT LOCK '%s' for '%*s' on "DFID"\n",
-	       LL_IT2STR(it), op_data->op_namelen, op_data->op_name,
-	       PFID(&op_data->op_fid1));
+	CDEBUG(D_INODE, "INTENT LOCK '%s' for "DFID" '%*s' on "DFID"\n",
+	       LL_IT2STR(it), PFID(&op_data->op_fid2), op_data->op_namelen,
+	       op_data->op_name, PFID(&op_data->op_fid1));
 
 	rc = lmv_check_connect(obd);
 	if (rc)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 00e8435..1901b93 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -34,7 +34,6 @@
 #define _MDC_INTERNAL_H
 
 #include "../include/lustre_mdc.h"
-#include "../include/lustre_mds.h"
 
 void lprocfs_mdc_init_vars(struct lprocfs_static_vars *lvars);
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 813f923..aa496f3 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -171,10 +171,7 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 static __u64 mds_pack_open_flags(__u64 flags, __u32 mode)
 {
 	__u64 cr_flags = (flags & (FMODE_READ | FMODE_WRITE |
-				   MDS_OPEN_HAS_EA | MDS_OPEN_HAS_OBJS |
-				   MDS_OPEN_OWNEROVERRIDE | MDS_OPEN_LOCK |
-				   MDS_OPEN_BY_FID | MDS_OPEN_LEASE |
-				   MDS_OPEN_RELEASE));
+				   MDS_OPEN_FL_INTERNAL));
 	if (flags & O_CREAT)
 		cr_flags |= MDS_OPEN_CREAT;
 	if (flags & O_EXCL)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index fab83dd..1c3b78d 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -922,27 +922,6 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 	mdt_body = req_capsule_server_get(&request->rq_pill, &RMF_MDT_BODY);
 	LASSERT(mdt_body);      /* mdc_enqueue checked */
 
-	/* If we were revalidating a fid/name pair, mark the intent in
-	 * case we fail and get called again from lookup
-	 */
-	if (fid_is_sane(&op_data->op_fid2) &&
-	    it->it_create_mode & M_CHECK_STALE &&
-	    it->it_op != IT_GETATTR) {
-		/* Also: did we find the same inode? */
-		/* sever can return one of two fids:
-		 * op_fid2 - new allocated fid - if file is created.
-		 * op_fid3 - existent fid - if file only open.
-		 * op_fid3 is saved in lmv_intent_open
-		 */
-		if ((!lu_fid_eq(&op_data->op_fid2, &mdt_body->mbo_fid1)) &&
-		    (!lu_fid_eq(&op_data->op_fid3, &mdt_body->mbo_fid1))) {
-			CDEBUG(D_DENTRY, "Found stale data "DFID"("DFID")/"DFID
-			       "\n", PFID(&op_data->op_fid2),
-			       PFID(&op_data->op_fid2), PFID(&mdt_body->mbo_fid1));
-			return -ESTALE;
-		}
-	}
-
 	rc = it_open_error(DISP_LOOKUP_EXECD, it);
 	if (rc)
 		return rc;
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index f42ed17..fbb0851 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -96,7 +96,7 @@ static const char * const obd_connect_names[] = {
 	"pingless",
 	"flock_deadlock",
 	"disp_stripe",
-	"unknown",
+	"open_by_fid",
 	"lfsck",
 	"unknown",
 	NULL
-- 
1.7.1
