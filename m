Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 67E84C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:34:28 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWNy2rbqz22QT;
	Sun,  9 Apr 2023 05:18:58 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWLh3Lkdz21Hw
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:17:00 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 314EF1008486;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3013A2B2; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:04 -0400
Message-Id: <1681042400-15491-25-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 24/40] lustre: llite: match lock in
 corresponding namespace
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

For remote object, LOOKUP lock is on parent MDT, so lmv_lock_match()
iterates all MDT namespaces to match locks. This is needed in places
where only LOOKUP ibit is matched, and the lock namespace is unknown.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15971
Lustre-commit: 64264dc424ca13d90 ("LU-15971 llite: match lock in corresponding namespace")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/47843
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c            |  3 ++-
 fs/lustre/llite/file.c           |  6 ++---
 fs/lustre/llite/llite_internal.h |  4 ++--
 fs/lustre/llite/namei.c          |  7 +++---
 fs/lustre/lmv/lmv_obd.c          | 52 ++++++++++++++++++++++++----------------
 5 files changed, 42 insertions(+), 30 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 1298bd6..0422701 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -347,7 +347,8 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 			struct inode *parent;
 
 			parent = file_dentry(filp)->d_parent->d_inode;
-			if (ll_have_md_lock(parent, &ibits, LCK_MINMODE))
+			if (ll_have_md_lock(ll_i2mdexp(parent), parent, &ibits,
+					    LCK_MINMODE))
 				pfid = *ll_inode2fid(parent);
 		}
 
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index fb8ede2..746c18f 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -5198,7 +5198,7 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
  *
  * Returns:		boolean, true iff all bits are found
  */
-int ll_have_md_lock(struct inode *inode, u64 *bits,
+int ll_have_md_lock(struct obd_export *exp, struct inode *inode, u64 *bits,
 		    enum ldlm_mode l_req_mode)
 {
 	struct lustre_handle lockh;
@@ -5222,8 +5222,8 @@ int ll_have_md_lock(struct inode *inode, u64 *bits,
 		if (policy.l_inodebits.bits == 0)
 			continue;
 
-		if (md_lock_match(ll_i2mdexp(inode), flags, fid, LDLM_IBITS,
-				  &policy, mode, &lockh)) {
+		if (md_lock_match(exp, flags, fid, LDLM_IBITS, &policy, mode,
+				  &lockh)) {
 			struct ldlm_lock *lock;
 
 			lock = ldlm_handle2lock(&lockh);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index cdfc75e..b101a71 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1175,8 +1175,8 @@ static inline void mapping_clear_exiting(struct address_space *mapping)
 /* llite/file.c */
 extern const struct inode_operations ll_file_inode_operations;
 const struct file_operations *ll_select_file_operations(struct ll_sb_info *sbi);
-int ll_have_md_lock(struct inode *inode, u64 *bits,
-		    enum ldlm_mode l_req_mode);
+int ll_have_md_lock(struct obd_export *exp, struct inode *inode,
+		    u64 *bits, enum ldlm_mode l_req_mode);
 enum ldlm_mode ll_take_md_lock(struct inode *inode, u64 bits,
 			       struct lustre_handle *lockh, u64 flags,
 			       enum ldlm_mode mode);
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index ada539e..0c4c8e6 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -256,7 +256,8 @@ static void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
 	 * LCK_CR, LCK_CW, LCK_PR - bug 22891
 	 */
 	if (bits & MDS_INODELOCK_OPEN)
-		ll_have_md_lock(inode, &bits, lock->l_req_mode);
+		ll_have_md_lock(lock->l_conn_export, inode, &bits,
+				lock->l_req_mode);
 
 	if (bits & MDS_INODELOCK_OPEN) {
 		fmode_t fmode;
@@ -284,7 +285,7 @@ static void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
 	if (bits & (MDS_INODELOCK_LOOKUP | MDS_INODELOCK_UPDATE |
 		    MDS_INODELOCK_LAYOUT | MDS_INODELOCK_PERM |
 		    MDS_INODELOCK_DOM))
-		ll_have_md_lock(inode, &bits, LCK_MINMODE);
+		ll_have_md_lock(lock->l_conn_export, inode, &bits, LCK_MINMODE);
 
 	if (bits & MDS_INODELOCK_DOM) {
 		rc = ll_dom_lock_cancel(inode, lock);
@@ -435,7 +436,7 @@ int ll_md_need_convert(struct ldlm_lock *lock)
 	unlock_res_and_lock(lock);
 
 	inode = ll_inode_from_resource_lock(lock);
-	ll_have_md_lock(inode, &bits, mode);
+	ll_have_md_lock(lock->l_conn_export, inode, &bits, mode);
 	iput(inode);
 	return !!(bits);
 }
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 1b6e4aa..1b95d93 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3558,39 +3558,49 @@ static enum ldlm_mode lmv_lock_match(struct obd_export *exp, u64 flags,
 {
 	struct obd_device *obd = exp->exp_obd;
 	struct lmv_obd *lmv = &obd->u.lmv;
-	enum ldlm_mode rc;
 	struct lu_tgt_desc *tgt;
-	int i;
+	u64 bits = policy->l_inodebits.bits;
+	enum ldlm_mode rc = LCK_MINMODE;
 	int index;
+	int i;
 
 	CDEBUG(D_INODE, "Lock match for " DFID "\n", PFID(fid));
 
-	/*
-	 * With DNE every object can have two locks in different namespaces:
+	/* only one bit is set */
+	LASSERT(bits && !(bits & (bits - 1)));
+	/* With DNE every object can have two locks in different namespaces:
 	 * lookup lock in space of MDT storing direntry and update/open lock in
 	 * space of MDT storing inode.  Try the MDT that the FID maps to first,
 	 * since this can be easily found, and only try others if that fails.
 	 */
-	for (i = 0, index = lmv_fid2tgt_index(lmv, fid);
-	     i < lmv->lmv_mdt_descs.ltd_tgts_size;
-	     i++, index = (index + 1) % lmv->lmv_mdt_descs.ltd_tgts_size) {
-		if (index < 0) {
-			CDEBUG(D_HA, "%s: " DFID " is inaccessible: rc = %d\n",
-			       obd->obd_name, PFID(fid), index);
-			index = 0;
+	if (bits == MDS_INODELOCK_LOOKUP) {
+		for (i = 0, index = lmv_fid2tgt_index(lmv, fid);
+		     i < lmv->lmv_mdt_descs.ltd_tgts_size; i++,
+		     index = (index + 1) % lmv->lmv_mdt_descs.ltd_tgts_size) {
+			if (index < 0) {
+				CDEBUG(D_HA,
+				       "%s: " DFID " is inaccessible: rc = %d\n",
+				       obd->obd_name, PFID(fid), index);
+				index = 0;
+			}
+			tgt = lmv_tgt(lmv, index);
+			if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
+				continue;
+			rc = md_lock_match(tgt->ltd_exp, flags, fid, type,
+					   policy, mode, lockh);
+			if (rc)
+				break;
 		}
-
-		tgt = lmv_tgt(lmv, index);
-		if (!tgt || !tgt->ltd_exp || !tgt->ltd_active)
-			continue;
-
-		rc = md_lock_match(tgt->ltd_exp, flags, fid, type, policy, mode,
-				   lockh);
-		if (rc)
-			return rc;
+	} else {
+		tgt = lmv_fid2tgt(lmv, fid);
+		if (!IS_ERR(tgt) && tgt->ltd_exp && tgt->ltd_active)
+			rc = md_lock_match(tgt->ltd_exp, flags, fid, type,
+					   policy, mode, lockh);
 	}
 
-	return 0;
+	CDEBUG(D_INODE, "Lock match for "DFID": %d\n", PFID(fid), rc);
+
+	return rc;
 }
 
 static int lmv_get_lustre_md(struct obd_export *exp,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
