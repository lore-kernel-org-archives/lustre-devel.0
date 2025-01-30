Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id F17D2C0218F
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:50:48 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLn52lVXz22Td;
	Thu, 30 Jan 2025 06:21:45 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLdJ0zSSz214t
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:15:00 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 46B11899ADE;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 44B89106BE14; Thu, 30 Jan 2025 09:11:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:11:15 -0500
Message-ID: <20250130141115.950749-26-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 25/25] Revert "lustre: llite: access
 lli_lsm_md with lock in all places"
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
Cc: Vitaly Fertman <vitaly.fertman@hpe.com>,
 Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vitaly Fertman <vitaly.fertman@hpe.com>

This reverts commit f0c0d38c855f186b37844c4d92e24e44f1879fab.
as a prerequisite of a larger fix in this ticket which covers
this problem as well.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15535
Lustre-commit: be278f82efa736035 ("LU-15535 revert: "LU-15284 llite: access lli_lsm_md with lock in all places")
Signed-off-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50488
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c            |  6 +++---
 fs/lustre/llite/file.c           |  8 +++-----
 fs/lustre/llite/llite_internal.h | 17 ++---------------
 fs/lustre/llite/llite_lib.c      | 20 +++++++++-----------
 fs/lustre/llite/namei.c          |  7 ++-----
 fs/lustre/llite/statahead.c      |  2 --
 fs/lustre/lmv/lmv_obd.c          |  3 +--
 7 files changed, 20 insertions(+), 43 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 2e44f9bb3895..98da2c95ca37 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -162,11 +162,11 @@ void ll_release_page(struct inode *inode, struct page *page, bool remove)
 {
 	kunmap(page);
 
-	/* Always remove the page for striped dir, because the page is
+	/*
+	 * Always remove the page for striped dir, because the page is
 	 * built from temporarily in LMV layer
 	 */
-	if (inode && S_ISDIR(inode->i_mode) &&
-	    lmv_dir_striped(ll_i2info(inode)->lli_lsm_md)) {
+	if (inode && ll_dir_striped(inode)) {
 		__free_page(page);
 		return;
 	}
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 11006682be1a..c99e9c01bc65 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -5330,14 +5330,12 @@ static int ll_merge_md_attr(struct inode *inode)
 	struct cl_attr attr = { 0 };
 	int rc;
 
-	if (!lli->lli_lsm_md)
+	LASSERT(lli->lli_lsm_md);
+
+	if (!lmv_dir_striped(lli->lli_lsm_md))
 		return 0;
 
 	down_read(&lli->lli_lsm_sem);
-	if (!lmv_dir_striped(lli->lli_lsm_md)) {
-		up_read(&lli->lli_lsm_sem);
-		return 0;
-	}
 	rc = md_merge_attr(ll_i2mdexp(inode), lli->lli_lsm_md, &attr,
 			   ll_md_blocking_ast);
 	up_read(&lli->lli_lsm_sem);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index e86d700a182b..42f991ea9a7e 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1469,22 +1469,9 @@ static inline struct lu_fid *ll_inode2fid(struct inode *inode)
 
 static inline bool ll_dir_striped(struct inode *inode)
 {
-	struct ll_inode_info *lli;
-	bool rc;
-
 	LASSERT(inode);
-	if (!S_ISDIR(inode->i_mode))
-		return false;
-
-	lli = ll_i2info(inode);
-	if (!lli->lli_lsm_md)
-		return false;
-
-	down_read(&lli->lli_lsm_sem);
-	rc = lmv_dir_striped(lli->lli_lsm_md);
-	up_read(&lli->lli_lsm_sem);
-
-	return rc;
+	return S_ISDIR(inode->i_mode) &&
+	       lmv_dir_striped(ll_i2info(inode)->lli_lsm_md);
 }
 
 static inline loff_t ll_file_maxbytes(struct inode *inode)
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 751886b47445..37327be5be66 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1702,25 +1702,23 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	}
 
 	rc = ll_init_lsm_md(inode, md);
-	if (rc) {
-		up_write(&lli->lli_lsm_sem);
-		return rc;
-	}
+	up_write(&lli->lli_lsm_sem);
 
-	/* md_merge_attr() may take long, since lsm is already set, switch to
-	 * read lock.
-	 */
-	downgrade_write(&lli->lli_lsm_sem);
+	if (rc)
+		return rc;
 
 	/* set md->lmv to NULL, so the following free lustre_md will not free
 	 * this lsm.
 	 */
 	md->lmv = NULL;
 
-	if (!lmv_dir_striped(lli->lli_lsm_md)) {
-		rc = 0;
+	/* md_merge_attr() may take long, since lsm is already set, switch to
+	 * read lock.
+	 */
+	down_read(&lli->lli_lsm_sem);
+
+	if (!lmv_dir_striped(lli->lli_lsm_md))
 		goto unlock;
-	}
 
 	attr = kzalloc(sizeof(*attr), GFP_NOFS);
 	if (!attr) {
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 920b592489ab..59a7bbb7a99f 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -746,17 +746,14 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 			.it_op = IT_GETATTR,
 			.it_lock_handle = 0
 		};
-		struct ll_inode_info *lli = ll_i2info(parent);
-		struct lu_fid fid = lli->lli_fid;
+		struct lu_fid fid = ll_i2info(parent)->lli_fid;
 
 		/* If it is striped directory, get the real stripe parent */
 		if (unlikely(ll_dir_striped(parent))) {
-			down_read(&lli->lli_lsm_sem);
 			rc = md_get_fid_from_lsm(ll_i2mdexp(parent),
-						 lli->lli_lsm_md,
+						 ll_i2info(parent)->lli_lsm_md,
 						 (*de)->d_name.name,
 						 (*de)->d_name.len, &fid);
-			up_read(&lli->lli_lsm_sem);
 			if (rc)
 				return rc;
 		}
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 59688b4d7c7f..c820455cc3af 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -1211,10 +1211,8 @@ static int ll_statahead_thread(void *arg)
 		}
 
 		pos = le64_to_cpu(dp->ldp_hash_end);
-		down_read(&lli->lli_lsm_sem);
 		ll_release_page(dir, page,
 				le32_to_cpu(dp->ldp_flags) & LDF_COLLIDE);
-		up_read(&lli->lli_lsm_sem);
 
 		if (sa_low_hit(sai)) {
 			rc = -EFAULT;
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 98ee902d8cb5..27345a2a65b0 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3730,8 +3730,7 @@ lmv_get_fid_from_lsm(struct obd_export *exp,
 {
 	const struct lmv_oinfo *oinfo;
 
-	if (!lmv_dir_striped(lsm))
-		return -ESTALE;
+	LASSERT(lmv_dir_striped(lsm));
 
 	oinfo = lsm_name_to_stripe_info(lsm, name, namelen, false);
 	if (IS_ERR(oinfo))
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
