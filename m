Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 64E80C4332F
	for <lustre-devel@archiver.kernel.org>; Wed, 29 Dec 2021 14:52:07 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D226D3AD509;
	Wed, 29 Dec 2021 06:52:01 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 944A03AD371
 for <lustre-devel@lists.lustre.org>; Wed, 29 Dec 2021 06:51:31 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 902EB1006F0B;
 Wed, 29 Dec 2021 09:51:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8891AD9E72; Wed, 29 Dec 2021 09:51:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed, 29 Dec 2021 09:51:19 -0500
Message-Id: <1640789487-22279-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
References: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/13] lustre: dne: dir migration in
 non-recursive mode
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

Add an option "-d|--directory" option for LL_IOC_MIGRATE to
migrate specified directory only, which is similar to "ls -d".

WC-bug-id: https://jira.whamcloud.com/browse/LU-14975
Lustre-commit: 5604a6d270b8be13a ("LU-14975 dne: dir migration in non-recursive mode")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44802
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                  | 5 ++++-
 fs/lustre/llite/file.c                 | 7 ++++++-
 fs/lustre/llite/llite_internal.h       | 2 +-
 fs/lustre/lmv/lmv_obd.c                | 5 +++++
 fs/lustre/ptlrpc/wiretest.c            | 6 ++++++
 include/uapi/linux/lustre/lustre_idl.h | 2 ++
 6 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 23d3fba..40e83e7 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -2102,6 +2102,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct lmv_user_md *lum;
 		char *filename;
 		int namelen = 0;
+		u32 flags;
 		int len;
 		int rc;
 
@@ -2117,6 +2118,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		filename = data->ioc_inlbuf1;
 		namelen = data->ioc_inllen1;
+		flags = data->ioc_type;
+
 		if (namelen < 1 || namelen != strlen(filename) + 1) {
 			CDEBUG(D_INFO, "IOC_MDC_LOOKUP missing filename\n");
 			rc = -EINVAL;
@@ -2132,7 +2135,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			goto migrate_free;
 		}
 
-		rc = ll_migrate(inode, file, lum, filename);
+		rc = ll_migrate(inode, file, lum, filename, flags);
 migrate_free:
 		kvfree(data);
 
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 20571c9..0dd1bae 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4682,7 +4682,7 @@ int ll_get_fid_by_name(struct inode *parent, const char *name,
 }
 
 int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
-	       const char *name)
+	       const char *name, u32 flags)
 {
 	struct ptlrpc_request *request = NULL;
 	struct obd_client_handle *och = NULL;
@@ -4779,6 +4779,11 @@ int ll_migrate(struct inode *parent, struct file *file, struct lmv_user_md *lum,
 	op_data->op_data = lum;
 	op_data->op_data_size = lumlen;
 
+	/* migrate dirent only for subdirs if MDS_MIGRATE_NSONLY set */
+	if (S_ISDIR(child_inode->i_mode) && (flags & MDS_MIGRATE_NSONLY) &&
+	    lmv_dir_layout_changing(ll_i2info(parent)->lli_lsm_md))
+		op_data->op_bias |= MDS_MIGRATE_NSONLY;
+
 again:
 	if (S_ISREG(child_inode->i_mode)) {
 		och = ll_lease_open(child_inode, NULL, FMODE_WRITE, 0);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 6e212c9..12d47e8 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1130,7 +1130,7 @@ static inline int ll_inode_flags_to_xflags(int inode_flags)
 }
 
 int ll_migrate(struct inode *parent, struct file *file,
-	       struct lmv_user_md *lum, const char *name);
+	       struct lmv_user_md *lum, const char *name, u32 flags);
 int ll_get_fid_by_name(struct inode *parent, const char *name,
 		       int namelen, struct lu_fid *fid, struct inode **inode);
 int ll_inode_permission(struct inode *inode, int mask);
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index b31f943..c87f37f 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -2227,6 +2227,11 @@ static int lmv_migrate(struct obd_export *exp, struct md_op_data *op_data,
 			tp_tgt = lmv_tgt(lmv, oinfo->lmo_mds);
 			if (!tp_tgt)
 				return -ENODEV;
+
+			/* parent unchanged and update namespace only */
+			if (lu_fid_eq(&op_data->op_fid4, &op_data->op_fid2) &&
+			    op_data->op_bias & MDS_MIGRATE_NSONLY)
+				return -EALREADY;
 		}
 	} else {
 		sp_tgt = parent_tgt;
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index a381af4..687a54d 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -2119,6 +2119,12 @@ void lustre_assert_wire_constants(void)
 		(unsigned int)MDS_PCC_ATTACH);
 	LASSERTF(MDS_CLOSE_UPDATE_TIMES == 0x00100000UL, "found 0x%.8xUL\n",
 		(unsigned int)MDS_CLOSE_UPDATE_TIMES);
+	LASSERTF(MDS_SETSTRIPE_CREATE == 0x00200000UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_SETSTRIPE_CREATE);
+	LASSERTF(MDS_FID_OP == 0x00400000UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_FID_OP);
+	LASSERTF(MDS_MIGRATE_NSONLY == 0x00800000UL, "found 0x%.8xUL\n",
+		(unsigned int)MDS_MIGRATE_NSONLY);
 
 	/* Checks for struct mdt_body */
 	LASSERTF((int)sizeof(struct mdt_body) == 216, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index debd0c1..35d3ed2 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1710,6 +1710,8 @@ enum mds_op_bias {
 	/* setstripe create only, don't restripe if target exists */
 	MDS_SETSTRIPE_CREATE	= 1 << 21,
 	MDS_FID_OP		= 1 << 22,
+	/* migrate dirent only */
+	MDS_MIGRATE_NSONLY	= 1 << 23,
 };
 
 #define MDS_CLOSE_INTENT (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP |         \
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
