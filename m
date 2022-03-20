Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 83745C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:33:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 185BE21CB7D;
	Sun, 20 Mar 2022 06:32:13 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D7CB321F999
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:19 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 784F9EFD;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 73B28D5A47; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:52 -0400
Message-Id: <1647783064-20688-39-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 38/50] lustre: sec: present .fscrypt in
 subdir mount
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sebastien Buisson <sbuisson@ddn.com>

fscrypt userspace tool works with a .fscrypt directory at the root of
the file system. In case of subdirectory mount, we virtually present
this .fscrypt directory at the root of the mount point so that fscrypt
can be used. This makes it possible to even do a subdirectory mount of
an encrypted directory, making clients access encrypted content only.
Internally, the .fscrypt directory is always stored at the root of
Lustre.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15176
Lustre-commit: c12378fba7f0aa2f2 ("LU-15176 sec: present .fscrypt in subdir mount")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/46167
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/crypto.c                |  9 +++++++--
 fs/lustre/llite/llite_lib.c             | 11 ++++++++++-
 fs/lustre/llite/namei.c                 |  9 +++++++++
 include/uapi/linux/lustre/lustre_user.h |  1 +
 4 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index f310d4c..b0e4f76 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -233,8 +233,13 @@ int ll_setup_filename(struct inode *dir, const struct qstr *iname,
 	}
 	rc = fscrypt_setup_filename(dir, &dname, lookup, fname);
 	if (rc == -ENOENT && lookup &&
-	    !fscrypt_has_encryption_key(dir) &&
-	    unlikely(filename_is_volatile(iname->name, iname->len, NULL))) {
+	    ((is_root_inode(dir) && iname->len == strlen(dot_fscrypt_name) &&
+	      strncmp(iname->name, dot_fscrypt_name, iname->len) == 0) ||
+	     (!fscrypt_has_encryption_key(dir) &&
+	      unlikely(filename_is_volatile(iname->name, iname->len, NULL))))) {
+		/* In case of subdir mount of an encrypted directory, we allow
+		 * lookup of /.fscrypt directory.
+		 */
 		/* For purpose of migration or mirroring without enc key, we
 		 * allow lookup of volatile file without enc context.
 		 */
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 423c531..8c0a3e0 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -3157,7 +3157,16 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 		return ERR_PTR(-ENOMEM);
 
 	ll_i2gids(op_data->op_suppgids, i1, i2);
-	op_data->op_fid1 = *ll_inode2fid(i1);
+	/* If the client is using a subdir mount and looks at what it sees as
+	 * /.fscrypt, interpret it as the .fscrypt dir at the root of the fs.
+	 */
+	if (unlikely(i1->i_sb && i1->i_sb->s_root && is_root_inode(i1) &&
+		     !fid_is_root(ll_inode2fid(i1)) &&
+		     name && namelen == strlen(dot_fscrypt_name) &&
+		     strncmp(name, dot_fscrypt_name, namelen) == 0))
+		lu_root_fid(&op_data->op_fid1);
+	else
+		op_data->op_fid1 = *ll_inode2fid(i1);
 
 	if (S_ISDIR(i1->i_mode)) {
 		down_read_non_owner(&ll_i2info(i1)->lli_lsm_sem);
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 1e3a4fd..c05e3bf 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -2068,6 +2068,15 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
+	/* If the client is using a subdir mount and does a rename to what it
+	 * sees as /.fscrypt, interpret it as the .fscrypt dir at fs root.
+	 */
+	if (unlikely(is_root_inode(tgt) && !fid_is_root(ll_inode2fid(tgt)) &&
+		     tgt_dchild->d_name.len == strlen(dot_fscrypt_name) &&
+		     strncmp(tgt_dchild->d_name.name, dot_fscrypt_name,
+			     tgt_dchild->d_name.len) == 0))
+		lu_root_fid(&op_data->op_fid2);
+
 	if (src_dchild->d_inode)
 		op_data->op_fid3 = *ll_inode2fid(src_dchild->d_inode);
 	if (tgt_dchild->d_inode)
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 2fdd7df..96efdf0 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1856,6 +1856,7 @@ enum ioc_data_version_flags {
 #endif
 
 #define dot_lustre_name ".lustre"
+#define dot_fscrypt_name ".fscrypt"
 
 /********* HSM **********/
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
