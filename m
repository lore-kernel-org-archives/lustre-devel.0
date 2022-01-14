Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B3063C433F5
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:31 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E230E3AD960;
	Thu, 13 Jan 2022 17:38:23 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 371E121FF8F
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:07 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A8F34100BAF3;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9EDFADF4C4; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:41 -0500
Message-Id: <1642124283-10148-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/24] lustre: llite: add trusted.projid
 virtual xattr
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
Cc: Li Dongyang <dongyangli@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Li Dongyang <dongyangli@ddn.com>

Add trusted.projid virtual xattr in ldiskfs to export the
current project id, intended for ldiskfs level MDT backup.

When the project id is EXT4_DEF_PROJID/0,
the virtual xattr is hidden from listxattr(2).

It's also hidden on lustre client when parent has the
project inherit flag and the same project ID,
to stop mv from setting the virtual xattr on the dest with
the project id from src, which could be different from dest.

getxattr(2) on trusted.projid will report current project id,
setxattr(2) will change curent project id and
removexattr(2) will set project id back to EXT4_DEF_PROJID/0

Both get|setxattr(2) will work even when the virtual xattr is
hidden.

Invalidate client xattr cache for the inode when changing its
project id, so the virtual xattr can get the new value
for next getxattr(2)

Add test cases to verify the virtual projid xattr and backup
restore MDT using tar can now preserve the project id.

Change mds_backup_restore in test framework, to use
tar with --xattrs --xattrs-include='trusted.*'" options.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12056
Lustre-commit: 665383d3a1f4d1dc7 ("LU-12056 ldiskfs: add trusted.projid virtual xattr")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/45679
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/xattr.c                | 15 +++++++++++++++
 fs/lustre/llite/xattr_cache.c          | 15 +++++++++++++++
 include/uapi/linux/lustre/lustre_idl.h |  1 +
 3 files changed, 31 insertions(+)

diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 6aea651..ce9585a 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -613,6 +613,7 @@ static int ll_xattr_get(const struct xattr_handler *handler,
 
 ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 {
+	struct inode *dir = d_inode(dentry->d_parent);
 	struct inode *inode = d_inode(dentry);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	ktime_t kstart = ktime_get();
@@ -656,6 +657,20 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 				hide_xattr = true;
 		}
 
+		/* Hide virtual project id xattr from the list when
+		 * parent has the inherit flag and the same project id,
+		 * so project id won't be messed up by copying the xattrs
+		 * when mv to a tree with different project id.
+		 */
+		if (get_xattr_type(xattr_name)->flags == XATTR_TRUSTED_T &&
+		    strcmp(xattr_name, XATTR_NAME_PROJID) == 0) {
+			if (ll_i2info(inode)->lli_projid ==
+					ll_i2info(dir)->lli_projid &&
+			    test_bit(LLIF_PROJECT_INHERIT,
+				     &ll_i2info(dir)->lli_flags))
+				hide_xattr = true;
+		}
+
 		len = strnlen(xattr_name, rem - 1) + 1;
 		rem -= len;
 		if (!xattr_type_filter(sbi, hide_xattr ? NULL :
diff --git a/fs/lustre/llite/xattr_cache.c b/fs/lustre/llite/xattr_cache.c
index 7c1f5b7..723cc39 100644
--- a/fs/lustre/llite/xattr_cache.c
+++ b/fs/lustre/llite/xattr_cache.c
@@ -563,6 +563,21 @@ int ll_xattr_cache_get(struct inode *inode, const char *name, char *buffer,
 				else
 					rc = -ERANGE;
 			}
+		/* Return the project id when the virtual project id xattr
+		 * is explicitly asked.
+		 */
+		} else if (strcmp(name, XATTR_NAME_PROJID) == 0) {
+			/* 10 chars to hold u32 in decimal, plus ending \0 */
+			char projid[11];
+
+			rc = snprintf(projid, sizeof(projid),
+				      "%u", lli->lli_projid);
+			if (size != 0) {
+				if (rc <= size)
+					memcpy(buffer, projid, rc);
+				else
+					rc = -ERANGE;
+			}
 		}
 	} else if (valid & OBD_MD_FLXATTRLS) {
 		rc = ll_xattr_cache_list(&lli->lli_xattrs,
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 35d3ed2..78e20a7 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1078,6 +1078,7 @@ struct lov_mds_md_v1 {		/* LOV EA mds/wire data (little-endian) */
 #define XATTR_NAME_SOM		"trusted.som"
 #define XATTR_NAME_HSM		"trusted.hsm"
 #define XATTR_NAME_LFSCK_NAMESPACE "trusted.lfsck_namespace"
+#define XATTR_NAME_PROJID	"trusted.projid"
 
 #define LL_XATTR_NAME_ENCRYPTION_CONTEXT XATTR_SECURITY_PREFIX"c"
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
