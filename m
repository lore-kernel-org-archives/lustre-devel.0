From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:04:30 -0500
Subject: [lustre-devel] [PATCH 02/60] staging: lustre: statahead: drop
	support for remote entry
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Lai Siyao <lai.siyao@intel.com>, James Simmons <jsimmons@infradead.org>

From: Lai Siyao <lai.siyao@intel.com>

This patch dropped support for remote entry statahead, because it
needs 2 async RPCs to fetch both LOOKUP lock from parent MDT and
UPDATE lock from client MDT, which is complicated. Plus not
supporting remote entry statahead won't cause any issue.

* pack child fid in statahead request.
* lmv_intent_getattr_async() will compare parent and child MDT,
  if child is remote, return -ENOTSUPP.

Signed-off-by: Lai Siyao <lai.siyao@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6578
Reviewed-on: http://review.whamcloud.com/15767
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/obd.h       |  4 +-
 drivers/staging/lustre/lustre/include/obd_class.h |  5 +-
 drivers/staging/lustre/lustre/llite/statahead.c   | 94 +++++++++--------------
 drivers/staging/lustre/lustre/lmv/lmv_obd.c       | 30 ++++++--
 drivers/staging/lustre/lustre/mdc/mdc_internal.h  |  3 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c     | 16 +---
 6 files changed, 68 insertions(+), 84 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 6f0f5dd..7f0fc44 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -761,6 +761,7 @@ struct md_enqueue_info {
 	struct lookup_intent    mi_it;
 	struct lustre_handle    mi_lockh;
 	struct inode	   *mi_dir;
+	struct ldlm_enqueue_info	mi_einfo;
 	int (*mi_cb)(struct ptlrpc_request *req,
 		     struct md_enqueue_info *minfo, int rc);
 	void			*mi_cbdata;
@@ -978,8 +979,7 @@ struct md_ops {
 				struct lu_fid *fid);
 
 	int (*intent_getattr_async)(struct obd_export *,
-				    struct md_enqueue_info *,
-				    struct ldlm_enqueue_info *);
+				    struct md_enqueue_info *);
 
 	int (*revalidate_lock)(struct obd_export *, struct lookup_intent *,
 			       struct lu_fid *, __u64 *bits);
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 7ec2520..083a6ff 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1444,14 +1444,13 @@ static inline int md_init_ea_size(struct obd_export *exp, u32 easize,
 }
 
 static inline int md_intent_getattr_async(struct obd_export *exp,
-					  struct md_enqueue_info *minfo,
-					  struct ldlm_enqueue_info *einfo)
+					  struct md_enqueue_info *minfo)
 {
 	int rc;
 
 	EXP_CHECK_MD_OP(exp, intent_getattr_async);
 	EXP_MD_COUNTER_INCREMENT(exp, intent_getattr_async);
-	rc = MDP(exp->exp_obd, intent_getattr_async)(exp, minfo, einfo);
+	rc = MDP(exp->exp_obd, intent_getattr_async)(exp, minfo);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index f1ee17f..fb7c315 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -79,6 +79,8 @@ struct sa_entry {
 	struct inode	   *se_inode;
 	/* entry name */
 	struct qstr	     se_qstr;
+	/* entry fid */
+	struct lu_fid		se_fid;
 };
 
 static unsigned int sai_generation;
@@ -169,7 +171,7 @@ static inline int is_omitted_entry(struct ll_statahead_info *sai, __u64 index)
 /* allocate sa_entry and hash it to allow scanner process to find it */
 static struct sa_entry *
 sa_alloc(struct dentry *parent, struct ll_statahead_info *sai, __u64 index,
-	 const char *name, int len)
+	 const char *name, int len, const struct lu_fid *fid)
 {
 	struct ll_inode_info *lli;
 	struct sa_entry   *entry;
@@ -194,6 +196,7 @@ static inline int is_omitted_entry(struct ll_statahead_info *sai, __u64 index)
 	entry->se_qstr.hash = full_name_hash(parent, name, len);
 	entry->se_qstr.len = len;
 	entry->se_qstr.name = dname;
+	entry->se_fid = *fid;
 
 	lli = ll_i2info(sai->sai_dentry->d_inode);
 	spin_lock(&lli->lli_sa_lock);
@@ -566,24 +569,8 @@ static void sa_instantiate(struct ll_statahead_info *sai,
 	}
 
 	child = entry->se_inode;
-	if (!child) {
-		/*
-		 * lookup.
-		 */
-		LASSERT(fid_is_zero(&minfo->mi_data.op_fid2));
-
-		/* XXX: No fid in reply, this is probably cross-ref case.
-		 * SA can't handle it yet.
-		 */
-		if (body->mbo_valid & OBD_MD_MDS) {
-			rc = -EAGAIN;
-			goto out;
-		}
-	} else {
-		/*
-		 * revalidate.
-		 */
-		/* unlinked and re-created with the same name */
+	if (child) {
+		/* revalidate; unlinked and re-created with the same name */
 		if (unlikely(!lu_fid_eq(&minfo->mi_data.op_fid2, &body->mbo_fid1))) {
 			entry->se_inode = NULL;
 			iput(child);
@@ -720,50 +707,42 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 }
 
 /* finish async stat RPC arguments */
-static void sa_fini_data(struct md_enqueue_info *minfo,
-			 struct ldlm_enqueue_info *einfo)
+static void sa_fini_data(struct md_enqueue_info *minfo)
 {
-	LASSERT(minfo && einfo);
 	iput(minfo->mi_dir);
 	kfree(minfo);
-	kfree(einfo);
 }
 
 /**
  * prepare arguments for async stat RPC.
  */
-static int sa_prep_data(struct inode *dir, struct inode *child,
-			struct sa_entry *entry, struct md_enqueue_info **pmi,
-			struct ldlm_enqueue_info **pei)
+static struct md_enqueue_info *
+sa_prep_data(struct inode *dir, struct inode *child, struct sa_entry *entry)
 {
-	const struct qstr      *qstr = &entry->se_qstr;
 	struct md_enqueue_info   *minfo;
 	struct ldlm_enqueue_info *einfo;
 	struct md_op_data	*op_data;
 
-	einfo = kzalloc(sizeof(*einfo), GFP_NOFS);
-	if (!einfo)
-		return -ENOMEM;
-
 	minfo = kzalloc(sizeof(*minfo), GFP_NOFS);
-	if (!minfo) {
-		kfree(einfo);
-		return -ENOMEM;
-	}
+	if (!minfo)
+		return ERR_PTR(-ENOMEM);
 
-	op_data = ll_prep_md_op_data(&minfo->mi_data, dir, child, qstr->name,
-				     qstr->len, 0, LUSTRE_OPC_ANY, NULL);
+	op_data = ll_prep_md_op_data(&minfo->mi_data, dir, child, NULL, 0, 0,
+				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data)) {
-		kfree(einfo);
 		kfree(minfo);
-		return PTR_ERR(op_data);
+		return (struct md_enqueue_info *)op_data;
 	}
 
+	if (!child)
+		op_data->op_fid2 = entry->se_fid;
+
 	minfo->mi_it.it_op = IT_GETATTR;
 	minfo->mi_dir = igrab(dir);
 	minfo->mi_cb = ll_statahead_interpret;
 	minfo->mi_cbdata = entry;
 
+	einfo = &minfo->mi_einfo;
 	einfo->ei_type   = LDLM_IBITS;
 	einfo->ei_mode   = it_to_lock_mode(&minfo->mi_it);
 	einfo->ei_cb_bl  = ll_md_blocking_ast;
@@ -771,26 +750,22 @@ static int sa_prep_data(struct inode *dir, struct inode *child,
 	einfo->ei_cb_gl  = NULL;
 	einfo->ei_cbdata = NULL;
 
-	*pmi = minfo;
-	*pei = einfo;
-
-	return 0;
+	return minfo;
 }
 
 /* async stat for file not found in dcache */
 static int sa_lookup(struct inode *dir, struct sa_entry *entry)
 {
 	struct md_enqueue_info   *minfo;
-	struct ldlm_enqueue_info *einfo;
 	int		       rc;
 
-	rc = sa_prep_data(dir, NULL, entry, &minfo, &einfo);
-	if (rc)
-		return rc;
+	minfo = sa_prep_data(dir, NULL, entry);
+	if (IS_ERR(minfo))
+		return PTR_ERR(minfo);
 
-	rc = md_intent_getattr_async(ll_i2mdexp(dir), minfo, einfo);
+	rc = md_intent_getattr_async(ll_i2mdexp(dir), minfo);
 	if (rc)
-		sa_fini_data(minfo, einfo);
+		sa_fini_data(minfo);
 
 	return rc;
 }
@@ -809,7 +784,6 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 	struct lookup_intent      it = { .it_op = IT_GETATTR,
 					 .it_lock_handle = 0 };
 	struct md_enqueue_info   *minfo;
-	struct ldlm_enqueue_info *einfo;
 	int rc;
 
 	if (unlikely(!inode))
@@ -827,25 +801,26 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 		return 1;
 	}
 
-	rc = sa_prep_data(dir, inode, entry, &minfo, &einfo);
-	if (rc) {
+	minfo = sa_prep_data(dir, inode, entry);
+	if (IS_ERR(minfo)) {
 		entry->se_inode = NULL;
 		iput(inode);
-		return rc;
+		return PTR_ERR(minfo);
 	}
 
-	rc = md_intent_getattr_async(ll_i2mdexp(dir), minfo, einfo);
+	rc = md_intent_getattr_async(ll_i2mdexp(dir), minfo);
 	if (rc) {
 		entry->se_inode = NULL;
 		iput(inode);
-		sa_fini_data(minfo, einfo);
+		sa_fini_data(minfo);
 	}
 
 	return rc;
 }
 
 /* async stat for file with @name */
-static void sa_statahead(struct dentry *parent, const char *name, int len)
+static void sa_statahead(struct dentry *parent, const char *name, int len,
+			 const struct lu_fid *fid)
 {
 	struct inode	     *dir    = d_inode(parent);
 	struct ll_inode_info     *lli    = ll_i2info(dir);
@@ -854,7 +829,7 @@ static void sa_statahead(struct dentry *parent, const char *name, int len)
 	struct sa_entry *entry;
 	int		       rc;
 
-	entry = sa_alloc(parent, sai, sai->sai_index, name, len);
+	entry = sa_alloc(parent, sai, sai->sai_index, name, len, fid);
 	if (IS_ERR(entry))
 		return;
 
@@ -1043,6 +1018,7 @@ static int ll_statahead_thread(void *arg)
 		for (ent = lu_dirent_start(dp);
 		     ent && thread_is_running(sa_thread) && !sa_low_hit(sai);
 		     ent = lu_dirent_next(ent)) {
+			struct lu_fid fid;
 			__u64 hash;
 			int namelen;
 			char *name;
@@ -1088,6 +1064,8 @@ static int ll_statahead_thread(void *arg)
 			if (unlikely(++first == 1))
 				continue;
 
+			fid_le_to_cpu(&fid, &ent->lde_fid);
+
 			/* wait for spare statahead window */
 			do {
 				l_wait_event(sa_thread->t_ctl_waitq,
@@ -1117,7 +1095,7 @@ static int ll_statahead_thread(void *arg)
 			} while (sa_sent_full(sai) &&
 				 thread_is_running(sa_thread));
 
-			sa_statahead(parent, name, namelen);
+			sa_statahead(parent, name, namelen, &fid);
 		}
 
 		pos = le64_to_cpu(dp->ldp_hash_end);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 76a0306..6a3b83f 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -3012,24 +3012,40 @@ static int lmv_clear_open_replay_data(struct obd_export *exp,
 }
 
 static int lmv_intent_getattr_async(struct obd_export *exp,
-				    struct md_enqueue_info *minfo,
-				    struct ldlm_enqueue_info *einfo)
+				    struct md_enqueue_info *minfo)
 {
 	struct md_op_data       *op_data = &minfo->mi_data;
 	struct obd_device       *obd = exp->exp_obd;
 	struct lmv_obd	  *lmv = &obd->u.lmv;
-	struct lmv_tgt_desc     *tgt = NULL;
+	struct lmv_tgt_desc *ptgt = NULL;
+	struct lmv_tgt_desc *ctgt = NULL;
 	int		      rc;
 
+	if (!fid_is_sane(&op_data->op_fid2))
+		return -EINVAL;
+
 	rc = lmv_check_connect(obd);
 	if (rc)
 		return rc;
 
-	tgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
-	if (IS_ERR(tgt))
-		return PTR_ERR(tgt);
+	ptgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid1);
+	if (IS_ERR(ptgt))
+		return PTR_ERR(ptgt);
+
+	ctgt = lmv_locate_mds(lmv, op_data, &op_data->op_fid2);
+	if (IS_ERR(ctgt))
+		return PTR_ERR(ctgt);
+
+	/*
+	 * if child is on remote MDT, we need 2 async RPCs to fetch both LOOKUP
+	 * lock on parent, and UPDATE lock on child MDT, which makes all
+	 * complicated. Considering remote dir is rare case, and not supporting
+	 * it in statahead won't cause any issue, drop its support for now.
+	 */
+	if (ptgt != ctgt)
+		return -ENOTSUPP;
 
-	return md_intent_getattr_async(tgt->ltd_exp, minfo, einfo);
+	return md_intent_getattr_async(ptgt->ltd_exp, minfo);
 }
 
 static int lmv_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_internal.h b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
index 881c6a0..fecedc88 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_internal.h
+++ b/drivers/staging/lustre/lustre/mdc/mdc_internal.h
@@ -116,8 +116,7 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 			struct lu_fid *fid, __u64 *bits);
 
 int mdc_intent_getattr_async(struct obd_export *exp,
-			     struct md_enqueue_info *minfo,
-			     struct ldlm_enqueue_info *einfo);
+			     struct md_enqueue_info *minfo);
 
 enum ldlm_mode mdc_lock_match(struct obd_export *exp, __u64 flags,
 			      const struct lu_fid *fid, enum ldlm_type type,
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 54ebb99..156add7 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -49,7 +49,6 @@
 struct mdc_getattr_args {
 	struct obd_export	   *ga_exp;
 	struct md_enqueue_info      *ga_minfo;
-	struct ldlm_enqueue_info    *ga_einfo;
 };
 
 int it_open_error(int phase, struct lookup_intent *it)
@@ -1111,7 +1110,7 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 	struct mdc_getattr_args  *ga = args;
 	struct obd_export	*exp = ga->ga_exp;
 	struct md_enqueue_info   *minfo = ga->ga_minfo;
-	struct ldlm_enqueue_info *einfo = ga->ga_einfo;
+	struct ldlm_enqueue_info *einfo = &minfo->mi_einfo;
 	struct lookup_intent     *it;
 	struct lustre_handle     *lockh;
 	struct obd_device	*obddev;
@@ -1147,14 +1146,12 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 	rc = mdc_finish_intent_lock(exp, req, &minfo->mi_data, it, lockh);
 
 out:
-	kfree(einfo);
 	minfo->mi_cb(req, minfo, rc);
 	return 0;
 }
 
 int mdc_intent_getattr_async(struct obd_export *exp,
-			     struct md_enqueue_info *minfo,
-			     struct ldlm_enqueue_info *einfo)
+			     struct md_enqueue_info *minfo)
 {
 	struct md_op_data       *op_data = &minfo->mi_data;
 	struct lookup_intent    *it = &minfo->mi_it;
@@ -1162,10 +1159,6 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 	struct mdc_getattr_args *ga;
 	struct obd_device       *obddev = class_exp2obd(exp);
 	struct ldlm_res_id       res_id;
-	/*XXX: Both MDS_INODELOCK_LOOKUP and MDS_INODELOCK_UPDATE are needed
-	 *     for statahead currently. Consider CMD in future, such two bits
-	 *     maybe managed by different MDS, should be adjusted then.
-	 */
 	union ldlm_policy_data policy = {
 		.l_inodebits = { MDS_INODELOCK_LOOKUP | MDS_INODELOCK_UPDATE }
 	};
@@ -1188,8 +1181,8 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 		return rc;
 	}
 
-	rc = ldlm_cli_enqueue(exp, &req, einfo, &res_id, &policy, &flags, NULL,
-			      0, LVB_T_NONE, &minfo->mi_lockh, 1);
+	rc = ldlm_cli_enqueue(exp, &req, &minfo->mi_einfo, &res_id, &policy,
+			      &flags, NULL, 0, LVB_T_NONE, &minfo->mi_lockh, 1);
 	if (rc < 0) {
 		obd_put_request_slot(&obddev->u.cli);
 		ptlrpc_req_finished(req);
@@ -1200,7 +1193,6 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 	ga = ptlrpc_req_async_args(req);
 	ga->ga_exp = exp;
 	ga->ga_minfo = minfo;
-	ga->ga_einfo = einfo;
 
 	req->rq_interpret_reply = mdc_intent_getattr_async_interpret;
 	ptlrpcd_add_req(req);
-- 
1.8.3.1
