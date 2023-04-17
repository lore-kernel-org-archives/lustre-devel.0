Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D6F84C77B76
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 14:13:58 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T7j4HkCz1yG6;
	Mon, 17 Apr 2023 06:54:41 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0T2c18Hsz21Hy
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:50:16 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id BCAC1100849A;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BB4C6379; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:20 -0400
Message-Id: <1681739243-29375-25-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 24/27] lustre: llite: only first sync to MDS
 matter
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

From: Alex Zhuravlev <bzzz@whamcloud.com>

fsync() is supposed to sync metadata and data, but given file's
layout the only first MDS_SYNC matters to ensure the file creation
has been committed, everything else go to OSTs (data and attributes)
also, uid/gid/mode, EAs and ACLs must be subject to sync.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11404
Lustre-commit: 1c8a49bedff2746775 ("LU-11404 llite: only first sync to MDS matter")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/33175
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/acl.c            |  2 ++
 fs/lustre/llite/file.c           | 19 ++++++++++++++-----
 fs/lustre/llite/llite_internal.h |  1 +
 fs/lustre/llite/llite_lib.c      |  1 +
 fs/lustre/llite/xattr.c          |  1 +
 5 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/llite/acl.c b/fs/lustre/llite/acl.c
index bd045cc..91a7421 100644
--- a/fs/lustre/llite/acl.c
+++ b/fs/lustre/llite/acl.c
@@ -94,6 +94,8 @@ int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type)
 	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
 			 value ? OBD_MD_FLXATTR : OBD_MD_FLXATTRRM,
 			 name, value, value_size, 0, 0, &req);
+	if (!rc)
+		ll_i2info(inode)->lli_synced_to_mds = false;
 
 	ptlrpc_req_finished(req);
 out_value:
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index ceac08c..0186db4 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4758,11 +4758,20 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 		}
 	}
 
-	err = md_fsync(ll_i2sbi(inode)->ll_md_exp, ll_inode2fid(inode), &req);
-	if (!rc)
-		rc = err;
-	if (!err)
-		ptlrpc_req_finished(req);
+	if (S_ISREG(inode->i_mode) && !lli->lli_synced_to_mds) {
+		/*
+		 * only the first sync on MDS makes sense,
+		 * everything else is stored on OSTs
+		 */
+		err = md_fsync(ll_i2sbi(inode)->ll_md_exp,
+			       ll_inode2fid(inode), &req);
+		if (!rc)
+			rc = err;
+		if (!err) {
+			lli->lli_synced_to_mds = true;
+			ptlrpc_req_finished(req);
+		}
+	}
 
 	if (S_ISREG(inode->i_mode)) {
 		struct ll_file_data *fd = file->private_data;
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 6590399..129c817 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -155,6 +155,7 @@ struct ll_inode_info {
 	s64				lli_ctime;
 	s64				lli_btime;
 	spinlock_t			lli_agl_lock;
+	bool				lli_synced_to_mds;
 
 	/* inode specific open lock caching threshold */
 	u32				lli_open_thrsh_count;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index c54ca1f..002e870 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2181,6 +2181,7 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr,
 	rc = ll_md_setattr(dentry, op_data);
 	if (rc)
 		goto out;
+	lli->lli_synced_to_mds = false;
 
 	if (!S_ISREG(inode->i_mode) || hsm_import) {
 		rc = 0;
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index c90f501..ceaad60 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -160,6 +160,7 @@ static int ll_xattr_set_common(const struct xattr_handler *handler,
 		}
 		return rc;
 	}
+	ll_i2info(inode)->lli_synced_to_mds = false;
 
 	ptlrpc_req_finished(req);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
