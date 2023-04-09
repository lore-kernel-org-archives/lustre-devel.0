Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5A1AEC77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:24:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWJr6Mpmz1yBV;
	Sun,  9 Apr 2023 05:15:24 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWHN6zX6z1yCk
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:14:08 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id EE9C8100827A;
 Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id ED5C02B2; Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:52 -0400
Message-Id: <1681042400-15491-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/40] lustre: sec: fid2path for encrypted
 files
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

Add support of fid2path for encrypted files. Server side returns raw
encrypted path name to client, which needs to process the returned
string. This is done from top to bottom, by iteratively decrypting
parent name and then doing a lookup on it, so that child can in turn
be decrypted.

For encrypted files that do not have their names encrypted, lookups
can be skipped. Indeed, name decryption is a no-op in this case, which
means it is not necessary to fetch the encryption key associated with
the parent inode.

Without the encryption key, lookups are skipped for the same reason.
But names have to be encoded and/or digested. So server needs to
insert FIDs of individual path components in the returned string.
These FIDs are interpreted by the client to build encoded/digested
names.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16205
Lustre-commit: fa9da556ad22b1485 ("LU-16205 sec: fid2path for encrypted files")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48930
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_export.h |   5 ++
 fs/lustre/llite/file.c            | 160 +++++++++++++++++++++++++++++++++++++-
 fs/lustre/llite/llite_internal.h  |  17 ++++
 fs/lustre/llite/llite_lib.c       |   1 +
 fs/lustre/lmv/lmv_obd.c           |  38 +++++++--
 fs/lustre/mdc/mdc_request.c       |  10 +--
 6 files changed, 214 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/include/lustre_export.h b/fs/lustre/include/lustre_export.h
index 6a59e6c..59f1dea 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -284,6 +284,11 @@ static inline int exp_connect_encrypt(struct obd_export *exp)
 	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_ENCRYPT);
 }
 
+static inline int exp_connect_encrypt_fid2path(struct obd_export *exp)
+{
+	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_ENCRYPT_FID2PATH);
+}
+
 static inline int exp_connect_lseek(struct obd_export *exp)
 {
 	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_LSEEK);
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index aa9c5da..668d544 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2744,12 +2744,146 @@ static int ll_do_fiemap(struct inode *inode, struct fiemap *fiemap,
 	return rc;
 }
 
+static int fid2path_for_enc_file(struct inode *parent, char *gfpath,
+				 u32 gfpathlen)
+{
+	struct dentry *de = NULL, *de_parent = d_find_any_alias(parent);
+	struct fscrypt_str lltr = FSTR_INIT(NULL, 0);
+	struct fscrypt_str de_name;
+	char *p, *ptr = gfpath;
+	size_t len = 0, len_orig = 0;
+	int enckey = -1, nameenc = -1;
+	int rc = 0;
+
+	gfpath++;
+	while ((p = strsep(&gfpath, "/")) != NULL) {
+		struct lu_fid fid;
+
+		de = NULL;
+		if (!*p) {
+			dput(de_parent);
+			break;
+		}
+		len_orig = strlen(p);
+
+		rc = sscanf(p, "["SFID"]", RFID(&fid));
+		if (rc == 3)
+			p = strchr(p, ']') + 1;
+		else
+			fid_zero(&fid);
+		rc = 0;
+		len = strlen(p);
+
+		if (!IS_ENCRYPTED(parent)) {
+			if (gfpathlen < len + 1) {
+				dput(de_parent);
+				rc = -EOVERFLOW;
+				break;
+			}
+			memmove(ptr, p, len);
+			p = ptr;
+			ptr += len;
+			*(ptr++) = '/';
+			gfpathlen -= len + 1;
+			goto lookup;
+		}
+
+		/* From here, we know parent is encrypted */
+		if (enckey != 0) {
+			rc = fscrypt_get_encryption_info(parent);
+			if (rc && rc != -ENOKEY) {
+				dput(de_parent);
+				break;
+			}
+		}
+
+		if (enckey == -1) {
+			if (fscrypt_has_encryption_key(parent))
+				enckey = 1;
+			else
+				enckey = 0;
+			if (enckey == 1)
+				nameenc = true;
+		}
+
+		/* Even if names are not encrypted, we still need to call
+		 * ll_fname_disk_to_usr in order to decode names as they are
+		 * coming from the wire.
+		 */
+		rc = fscrypt_fname_alloc_buffer(parent, NAME_MAX + 1, &lltr);
+		if (rc < 0) {
+			dput(de_parent);
+			break;
+		}
+
+		de_name.name = p;
+		de_name.len = len;
+		rc = ll_fname_disk_to_usr(parent, 0, 0, &de_name,
+					  &lltr, &fid);
+		if (rc) {
+			fscrypt_fname_free_buffer(&lltr);
+			dput(de_parent);
+			break;
+		}
+		lltr.name[lltr.len] = '\0';
+
+		if (lltr.len <= len_orig && gfpathlen >= lltr.len + 1) {
+			memcpy(ptr, lltr.name, lltr.len);
+			p = ptr;
+			len = lltr.len;
+			ptr += lltr.len;
+			*(ptr++) = '/';
+			gfpathlen -= lltr.len + 1;
+		} else {
+			rc = -EOVERFLOW;
+		}
+		fscrypt_fname_free_buffer(&lltr);
+
+		if (rc == -EOVERFLOW) {
+			dput(de_parent);
+			break;
+		}
+
+lookup:
+		if (!gfpath) {
+			/* We reached the end of the string, which means
+			 * we are dealing with the last component in the path.
+			 * So save a useless lookup and exit.
+			 */
+			dput(de_parent);
+			break;
+		}
+
+		if (enckey == 0 || nameenc == 0)
+			continue;
+
+		inode_lock(parent);
+		de = lookup_one_len(p, de_parent, len);
+		inode_unlock(parent);
+		if (IS_ERR_OR_NULL(de) || !de->d_inode) {
+			dput(de_parent);
+			rc = -ENODATA;
+			break;
+		}
+
+		parent = de->d_inode;
+		dput(de_parent);
+		de_parent = de;
+	}
+
+	if (len)
+		*(ptr - 1) = '\0';
+	if (!IS_ERR_OR_NULL(de))
+		dput(de);
+	return rc;
+}
+
 int ll_fid2path(struct inode *inode, void __user *arg)
 {
 	struct obd_export *exp = ll_i2mdexp(inode);
 	const struct getinfo_fid2path __user *gfin = arg;
 	struct getinfo_fid2path *gfout;
-	u32 pathlen;
+	u32 pathlen, pathlen_orig;
 	size_t outsize;
 	int rc;
 
@@ -2763,7 +2897,9 @@ int ll_fid2path(struct inode *inode, void __user *arg)
 
 	if (pathlen > PATH_MAX)
 		return -EINVAL;
+	pathlen_orig = pathlen;
 
+gf_alloc:
 	outsize = sizeof(*gfout) + pathlen;
 
 	gfout = kzalloc(outsize, GFP_KERNEL);
@@ -2781,17 +2917,37 @@ int ll_fid2path(struct inode *inode, void __user *arg)
 	 * old server without fileset mount support will ignore this.
 	 */
 	*gfout->gf_root_fid = *ll_inode2fid(inode);
+	gfout->gf_pathlen = pathlen;
 
 	/* Call mdc_iocontrol */
 	rc = obd_iocontrol(OBD_IOC_FID2PATH, exp, outsize, gfout, NULL);
 	if (rc != 0)
 		goto gf_free;
 
-	if (copy_to_user(arg, gfout, outsize))
+	if (gfout->gf_pathlen && gfout->gf_path[0] == '/') {
+		/* by convention, server side (mdt_path_current()) puts
+		 * a leading '/' to tell client that we are dealing with
+		 * an encrypted file
+		 */
+		rc = fid2path_for_enc_file(inode, gfout->gf_path,
+					   gfout->gf_pathlen);
+		if (rc)
+			goto gf_free;
+		if (strlen(gfout->gf_path) > gfin->gf_pathlen) {
+			rc = -EOVERFLOW;
+			goto gf_free;
+		}
+	}
+
+	if (copy_to_user(arg, gfout, sizeof(*gfout) + pathlen_orig))
 		rc = -EFAULT;
 
 gf_free:
 	kfree(gfout);
+	if (rc == -ENAMETOOLONG) {
+		pathlen += PATH_MAX;
+		goto gf_alloc;
+	}
 	return rc;
 }
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 1d85d0b..2223dbb 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -523,6 +523,23 @@ static inline void obd_connect_set_name_enc(struct obd_connect_data *data)
 #endif
 }
 
+static inline bool obd_connect_has_enc_fid2path(struct obd_connect_data *data)
+{
+#ifdef HAVE_LUSTRE_CRYPTO
+	return data->ocd_connect_flags & OBD_CONNECT_FLAGS2 &&
+		data->ocd_connect_flags2 & OBD_CONNECT2_ENCRYPT_FID2PATH;
+#else
+	return false;
+#endif
+}
+
+static inline void obd_connect_set_enc_fid2path(struct obd_connect_data *data)
+{
+#ifdef HAVE_LUSTRE_CRYPTO
+	data->ocd_connect_flags2 |= OBD_CONNECT2_ENCRYPT_FID2PATH;
+#endif
+}
+
 /*
  * Locking to guarantee consistency of non-atomic updates to long long i_size,
  * consistency between file size and KMS.
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index e48bb6c..3774ca8 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -358,6 +358,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	obd_connect_set_secctx(data);
 	if (ll_sbi_has_encrypt(sbi)) {
+		obd_connect_set_enc_fid2path(data);
 		obd_connect_set_name_enc(data);
 		obd_connect_set_enc(data);
 	}
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 64d16d8..99604e8 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -551,6 +551,8 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 	struct getinfo_fid2path *remote_gf = NULL;
 	struct lu_fid root_fid;
 	int remote_gf_size = 0;
+	int currentisenc = 0;
+	int globalisenc = 0;
 	int rc;
 
 	tgt = lmv_fid2tgt(lmv, &gf->gf_fid);
@@ -565,11 +567,23 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 	if (rc != 0 && rc != -EREMOTE)
 		goto out_fid2path;
 
+	if (gf->gf_path[0] == '/') {
+		/* by convention, server side (mdt_path_current()) puts
+		 * a leading '/' to tell client that we are dealing with
+		 * an encrypted file
+		 */
+		currentisenc = 1;
+		globalisenc = 1;
+	} else {
+		currentisenc = 0;
+	}
+
 	/* If remote_gf != NULL, it means just building the
 	 * path on the remote MDT, copy this path segment to gf
 	 */
 	if (remote_gf) {
 		struct getinfo_fid2path *ori_gf;
+		int oldisenc = 0;
 		char *ptr;
 		int len;
 
@@ -581,14 +595,22 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 		}
 
 		ptr = ori_gf->gf_path;
+		oldisenc = ptr[0] == '/';
 
 		len = strlen(gf->gf_path);
-		/* move the current path to the right to release space
-		 * for closer-to-root part
-		 */
-		memmove(ptr + len + 1, ptr, strlen(ori_gf->gf_path));
-		memcpy(ptr, gf->gf_path, len);
-		ptr[len] = '/';
+		if (len) {
+			/* move the current path to the right to release space
+			 * for closer-to-root part
+			 */
+			memmove(ptr + len - currentisenc + 1 + globalisenc,
+				ptr + oldisenc,
+				strlen(ori_gf->gf_path) - oldisenc + 1);
+			if (globalisenc)
+				*(ptr++) = '/';
+			memcpy(ptr, gf->gf_path + currentisenc,
+			       len - currentisenc);
+			ptr[len - currentisenc] = '/';
+		}
 	}
 
 	CDEBUG(D_INFO, "%s: get path %s " DFID " rec: %llu ln: %u\n",
@@ -601,13 +623,13 @@ static int lmv_fid2path(struct obd_export *exp, int len, void *karg,
 
 	/* sigh, has to go to another MDT to do path building further */
 	if (!remote_gf) {
-		remote_gf_size = sizeof(*remote_gf) + PATH_MAX;
+		remote_gf_size = sizeof(*remote_gf) + len - sizeof(*gf);
 		remote_gf = kzalloc(remote_gf_size, GFP_NOFS);
 		if (!remote_gf) {
 			rc = -ENOMEM;
 			goto out_fid2path;
 		}
-		remote_gf->gf_pathlen = PATH_MAX;
+		remote_gf->gf_pathlen = len - sizeof(*gf);
 	}
 
 	if (!fid_is_sane(&gf->gf_fid)) {
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 643b6ee..58ea982 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1707,8 +1707,6 @@ static int mdc_ioc_fid2path(struct obd_export *exp, struct getinfo_fid2path *gf)
 	void *key;
 	int rc;
 
-	if (gf->gf_pathlen > PATH_MAX)
-		return -ENAMETOOLONG;
 	if (gf->gf_pathlen < 2)
 		return -EOVERFLOW;
 
@@ -1746,12 +1744,10 @@ static int mdc_ioc_fid2path(struct obd_export *exp, struct getinfo_fid2path *gf)
 		goto out;
 	}
 
-	CDEBUG(D_IOCTL, "path got " DFID " from %llu #%d: %s\n",
+	CDEBUG(D_IOCTL, "path got " DFID " from %llu #%d: %.*s\n",
 	       PFID(&gf->gf_fid), gf->gf_recno, gf->gf_linkno,
-	       gf->gf_pathlen < 512 ? gf->gf_path :
-	       /* only log the last 512 characters of the path */
-	       gf->gf_path + gf->gf_pathlen - 512);
-
+	       /* only log the first 512 characters of the path */
+	       512, gf->gf_path);
 out:
 	kfree(key);
 	return rc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
