Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 48F31C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:26:39 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWKc4NdXz21C4;
	Sun,  9 Apr 2023 05:16:04 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWHH0SXVz1yBZ
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:14:03 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id DBE591008276;
 Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id DA3C62B2; Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:48 -0400
Message-Id: <1681042400-15491-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/40] lustre: enc: align Base64 encoding
 with RFC 4648 base64url
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

From: Sebastien Buisson <sbuisson@ddn.com>

Lustre encryption uses a Base64 encoding to encode no-key filenames
(the filenames that are presented to userspace when a directory is
 listed without its encryption key).
Make this Base64 encoding compliant with RFC 4648 base64url. And use
'+' leading character to distringuish digested names.

This is adapted from kernel
commit ba47b515f594 ("fscrypt: align Base64 encoding with RFC 4648 base64url")

To maintain compatibility with older clients, a new llite parameter
named 'filename_enc_use_old_base64' is introduced, set to 0 by
default. When 0, Lustre uses new-fashion base64 encoding. When set to
1, Lustre uses old-style base64 encoding.

To set this parameter globally for all clients, do on the MGS:
mgs# lctl set_param -P llite.*.filename_enc_use_old_base64={0,1}

WC-bug-id: https://jira.whamcloud.com/browse/LU-16374
Lustre-commit: 583ee6911b6cac7f2 ("LU-16374 enc: align Base64 encoding with RFC 4648 base64url")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49581
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_crypto.h |  3 +++
 fs/lustre/include/lustre_disk.h   |  3 ++-
 fs/lustre/llite/crypto.c          | 24 ++++++++++++-------
 fs/lustre/llite/llite_lib.c       |  3 +++
 fs/lustre/llite/lproc_llite.c     | 49 +++++++++++++++++++++++++++++++++++++++
 5 files changed, 72 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/include/lustre_crypto.h b/fs/lustre/include/lustre_crypto.h
index 2252798..ced1a191 100644
--- a/fs/lustre/include/lustre_crypto.h
+++ b/fs/lustre/include/lustre_crypto.h
@@ -32,6 +32,9 @@
 
 #include <linux/fscrypt.h>
 
+#define LLCRYPT_DIGESTED_CHAR		'+'
+#define LLCRYPT_DIGESTED_CHAR_OLD	'_'
+
 /* Macro to extract digest from Lustre specific structures */
 #define LLCRYPT_EXTRACT_DIGEST(name, len)			\
 	((name) + round_down((len) - FS_CRYPTO_BLOCK_SIZE - 1,	\
diff --git a/fs/lustre/include/lustre_disk.h b/fs/lustre/include/lustre_disk.h
index 15f94ad8..a8e935e 100644
--- a/fs/lustre/include/lustre_disk.h
+++ b/fs/lustre/include/lustre_disk.h
@@ -136,7 +136,8 @@ struct lustre_sb_info {
 	struct fscrypt_dummy_context lsi_dummy_enc_ctx;
 };
 
-#define LSI_UMOUNT_FAILOVER	0x00200000
+#define LSI_UMOUNT_FAILOVER		0x00200000
+#define LSI_FILENAME_ENC_B64_OLD_CLI    0x01000000 /* use old style base64 */
 
 #define     s2lsi(sb)	((struct lustre_sb_info *)((sb)->s_fs_info))
 #define     s2lsi_nocast(sb) ((sb)->s_fs_info)
diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index d6750fb..5fb7f4d 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -227,15 +227,16 @@ int ll_setup_filename(struct inode *dir, const struct qstr *iname,
 	struct qstr dname;
 	int rc;
 
-	if (fid) {
-		fid->f_seq = 0;
-		fid->f_oid = 0;
-		fid->f_ver = 0;
-	}
-
 	if (fid && IS_ENCRYPTED(dir) && !fscrypt_has_encryption_key(dir) &&
-	    iname->name[0] == '_')
-		digested = 1;
+	    !fscrypt_has_encryption_key(dir)) {
+		struct lustre_sb_info *lsi = s2lsi(dir->i_sb);
+
+		if ((!(lsi->lsi_flags & LSI_FILENAME_ENC_B64_OLD_CLI) &&
+		     iname->name[0] == LLCRYPT_DIGESTED_CHAR) ||
+		   ((lsi->lsi_flags & LSI_FILENAME_ENC_B64_OLD_CLI) &&
+		     iname->name[0] == LLCRYPT_DIGESTED_CHAR_OLD))
+			digested = 1;
+	}
 
 	dname.name = iname->name + digested;
 	dname.len = iname->len - digested;
@@ -375,6 +376,8 @@ int ll_fname_disk_to_usr(struct inode *inode,
 		}
 		if (lltr.len > FS_CRYPTO_BLOCK_SIZE * 2 &&
 		    !fscrypt_has_encryption_key(inode)) {
+			struct lustre_sb_info *lsi = s2lsi(inode->i_sb);
+
 			digested = 1;
 			/* Without the key for long names, set the dentry name
 			 * to the representing struct ll_digest_filename. It
@@ -391,7 +394,10 @@ int ll_fname_disk_to_usr(struct inode *inode,
 			lltr.name = (char *)&digest;
 			lltr.len = sizeof(digest);
 
-			oname->name[0] = '_';
+			if (!(lsi->lsi_flags & LSI_FILENAME_ENC_B64_OLD_CLI))
+				oname->name[0] = LLCRYPT_DIGESTED_CHAR;
+			else
+				oname->name[0] = LLCRYPT_DIGESTED_CHAR_OLD;
 			oname->name = oname->name + 1;
 			oname->len--;
 		}
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index f84b6f5..e48bb6c 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -508,10 +508,13 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	}
 
 	if (ll_sbi_has_name_encrypt(sbi) && !obd_connect_has_name_enc(data)) {
+		struct  lustre_sb_info *lsi = s2lsi(sb);
+
 		if (ll_sb_has_test_dummy_encryption(sb))
 			LCONSOLE_WARN("%s: server %s does not support name encryption, not using it.\n",
 				      sbi->ll_fsname,
 				      sbi->ll_md_exp->exp_obd->obd_name);
+		lsi->lsi_flags &= ~LSI_FILENAME_ENC_B64_OLD_CLI;
 		ll_sbi_set_name_encrypt(sbi, false);
 	}
 
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 70dbc87..48d93c6 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1653,6 +1653,53 @@ static ssize_t ll_nosquash_nids_seq_write(struct file *file,
 
 LDEBUGFS_SEQ_FOPS(ll_nosquash_nids);
 
+static int ll_old_b64_enc_seq_show(struct seq_file *m, void *v)
+{
+	struct super_block *sb = m->private;
+	struct lustre_sb_info *lsi = s2lsi(sb);
+
+	seq_printf(m, "%u\n",
+		   lsi->lsi_flags & LSI_FILENAME_ENC_B64_OLD_CLI ? 1 : 0);
+	return 0;
+}
+
+static ssize_t ll_old_b64_enc_seq_write(struct file *file,
+					const char __user *buffer,
+					size_t count, loff_t *off)
+{
+	struct seq_file *m = file->private_data;
+	struct super_block *sb = m->private;
+	struct lustre_sb_info *lsi = s2lsi(sb);
+	struct ll_sb_info *sbi = ll_s2sbi(sb);
+	bool val;
+	int rc;
+
+	rc = kstrtobool_from_user(buffer, count, &val);
+	if (rc)
+		return rc;
+
+	if (val) {
+		if (!ll_sbi_has_name_encrypt(sbi)) {
+			/* server does not support name encryption,
+			 * so force it to NULL on client
+			 */
+			CDEBUG(D_SEC,
+			       "%s: server does not support name encryption\n",
+			       sbi->ll_fsname);
+			lsi->lsi_flags &= ~LSI_FILENAME_ENC_B64_OLD_CLI;
+			return -EOPNOTSUPP;
+		}
+
+		lsi->lsi_flags |= LSI_FILENAME_ENC_B64_OLD_CLI;
+	} else {
+		lsi->lsi_flags &= ~LSI_FILENAME_ENC_B64_OLD_CLI;
+	}
+
+	return count;
+}
+
+LDEBUGFS_SEQ_FOPS(ll_old_b64_enc);
+
 static int ll_pcc_seq_show(struct seq_file *m, void *v)
 {
 	struct super_block *sb = m->private;
@@ -1709,6 +1756,8 @@ struct ldebugfs_vars lprocfs_llite_obd_vars[] = {
 	  .fops =	&ll_nosquash_nids_fops			},
 	{ .name =	"pcc",
 	  .fops =	&ll_pcc_fops,				},
+	{ .name =	"filename_enc_use_old_base64",
+	  .fops =	&ll_old_b64_enc_fops,			},
 	{ NULL }
 };
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
