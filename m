Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 125D8C433E0
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:17:35 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9AEE623A59
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:17:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AEE623A59
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id ADF3021FDBE;
	Thu, 21 Jan 2021 09:17:25 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8D9E321FBD8
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:11 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 596CC1008064;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 57EC71B49F; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:43 -0500
Message-Id: <1611249422-556-21-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 20/39] lustre: lmv: optimize dir shard
 revalidate
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

mdt_is_remote_object() will check whether child is directory shard
if parent and child are on different MDTs, which needs to read LMV
from disk, and hurt striped directory stat performance.

This can be optimized, client can just set CROSS_REF flag to do a
cross reference getattr, which avoids lots of checks.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14172
Lustre-commit: de47c7671f29b2 ("LU-14172 lmv: optimize dir shard revalidate")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40863
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h                |  2 +-
 fs/lustre/include/obd_class.h          |  3 +--
 fs/lustre/llite/file.c                 |  4 ++--
 fs/lustre/llite/llite_lib.c            |  4 ++--
 fs/lustre/lmv/lmv_intent.c             | 15 ++++++++-------
 fs/lustre/lmv/lmv_internal.h           |  1 -
 fs/lustre/lmv/lmv_obd.c                |  3 +--
 include/uapi/linux/lustre/lustre_idl.h |  7 +++++++
 8 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index a017997..de62005 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -1033,7 +1033,7 @@ struct md_ops {
 
 	int (*free_lustre_md)(struct obd_export *, struct lustre_md *);
 
-	int (*merge_attr)(struct obd_export *, const struct lu_fid *fid,
+	int (*merge_attr)(struct obd_export *exp,
 			  const struct lmv_stripe_md *lsm,
 			  struct cl_attr *attr, ldlm_blocking_callback);
 
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 1ac9fcf..b441215 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1460,7 +1460,6 @@ static inline int md_free_lustre_md(struct obd_export *exp,
 }
 
 static inline int md_merge_attr(struct obd_export *exp,
-				const struct lu_fid *fid,
 				const struct lmv_stripe_md *lsm,
 				struct cl_attr *attr,
 				ldlm_blocking_callback cb)
@@ -1471,7 +1470,7 @@ static inline int md_merge_attr(struct obd_export *exp,
 	if (rc)
 		return rc;
 
-	return MDP(exp->exp_obd, merge_attr)(exp, fid, lsm, attr, cb);
+	return MDP(exp->exp_obd, merge_attr)(exp, lsm, attr, cb);
 }
 
 static inline int md_setxattr(struct obd_export *exp, const struct lu_fid *fid,
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 2b0ffad..5d03fc3 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4708,8 +4708,8 @@ static int ll_merge_md_attr(struct inode *inode)
 		return 0;
 
 	down_read(&lli->lli_lsm_sem);
-	rc = md_merge_attr(ll_i2mdexp(inode), &lli->lli_fid, lli->lli_lsm_md,
-			   &attr, ll_md_blocking_ast);
+	rc = md_merge_attr(ll_i2mdexp(inode), lli->lli_lsm_md, &attr,
+			   ll_md_blocking_ast);
 	up_read(&lli->lli_lsm_sem);
 	if (rc)
 		return rc;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index c560492..570d51a 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1521,8 +1521,8 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	}
 
 	/* validate the lsm */
-	rc = md_merge_attr(ll_i2mdexp(inode), &lli->lli_fid, lli->lli_lsm_md,
-			   attr, ll_md_blocking_ast);
+	rc = md_merge_attr(ll_i2mdexp(inode), lli->lli_lsm_md, attr,
+			   ll_md_blocking_ast);
 	if (!rc) {
 		if (md->body->mbo_valid & OBD_MD_FLNLINK)
 			md->body->mbo_nlink = attr->cat_nlink;
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index ad59b64..38b8c75 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -153,7 +153,6 @@ static int lmv_intent_remote(struct obd_export *exp, struct lookup_intent *it,
 }
 
 int lmv_revalidate_slaves(struct obd_export *exp,
-			  const struct lu_fid *pfid,
 			  const struct lmv_stripe_md *lsm,
 			  ldlm_blocking_callback cb_blocking,
 			  int extra_lock_flags)
@@ -197,11 +196,14 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 		 * which is not needed here.
 		 */
 		memset(op_data, 0, sizeof(*op_data));
-		if (exp_connect_flags2(exp) & OBD_CONNECT2_GETATTR_PFID)
-			op_data->op_fid1 = *pfid;
-		else
-			op_data->op_fid1 = fid;
+		op_data->op_fid1 = fid;
 		op_data->op_fid2 = fid;
+		/* shard revalidate only needs to fetch attributes and UPDATE
+		 * lock, which is similar to the bottom half of remote object
+		 * getattr, set this flag so that MDT skips checking whether
+		 * it's remote object.
+		 */
+		op_data->op_bias = MDS_CROSS_REF;
 
 		tgt = lmv_tgt(lmv, lsm->lsm_md_oinfo[i].lmo_mds);
 		if (!tgt) {
@@ -495,8 +497,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 		 * during update_inode process (see ll_update_lsm_md)
 		 */
 		if (lmv_dir_striped(op_data->op_mea2)) {
-			rc = lmv_revalidate_slaves(exp, &op_data->op_fid2,
-						   op_data->op_mea2,
+			rc = lmv_revalidate_slaves(exp, op_data->op_mea2,
 						   cb_blocking,
 						   extra_lock_flags);
 			if (rc != 0)
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index 756fa27..e42b141 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -53,7 +53,6 @@ int lmv_fid_alloc(const struct lu_env *env, struct obd_export *exp,
 		  struct lu_fid *fid, struct md_op_data *op_data);
 
 int lmv_revalidate_slaves(struct obd_export *exp,
-			  const struct lu_fid *pfid,
 			  const struct lmv_stripe_md *lsm,
 			  ldlm_blocking_callback cb_blocking,
 			  int extra_lock_flags);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index fa1dae5..d845118 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3482,7 +3482,6 @@ static int lmv_quotactl(struct obd_device *unused, struct obd_export *exp,
 }
 
 static int lmv_merge_attr(struct obd_export *exp,
-			  const struct lu_fid *fid,
 			  const struct lmv_stripe_md *lsm,
 			  struct cl_attr *attr,
 			  ldlm_blocking_callback cb_blocking)
@@ -3492,7 +3491,7 @@ static int lmv_merge_attr(struct obd_export *exp,
 	if (!lmv_dir_striped(lsm))
 		return 0;
 
-	rc = lmv_revalidate_slaves(exp, fid, lsm, cb_blocking, 0);
+	rc = lmv_revalidate_slaves(exp, lsm, cb_blocking, 0);
 	if (rc < 0)
 		return rc;
 
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index f56b3c5..f953815 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1705,6 +1705,13 @@ struct mdt_rec_setattr {
 
 enum mds_op_bias {
 /*	MDS_CHECK_SPLIT		= 1 << 0, obsolete before 2.3.58 */
+	/* used for remote object getattr/open by name: in the original
+	 * getattr/open request, MDT found the object against name is on another
+	 * MDT, then packed FID and LOOKUP lock in reply and returned -EREMOTE,
+	 * and client knew it's a remote object, then set this flag in
+	 * getattr/open request and sent to the corresponding MDT to finish
+	 * getattr/open, which fetched attributes and UPDATE lock/opened file.
+	 */
 	MDS_CROSS_REF		= 1 << 1,
 /*	MDS_VTX_BYPASS		= 1 << 2, obsolete since 2.3.54 */
 	MDS_PERM_BYPASS		= 1 << 3,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
