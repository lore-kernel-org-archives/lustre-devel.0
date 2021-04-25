Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8C5DC433ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:28 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7B68C61260
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B68C61260
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1A5A221FA70;
	Sun, 25 Apr 2021 13:09:55 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DDEA621F7A3
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:46 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 32C1C10087CD;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 319D369A63; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:26 -0400
Message-Id: <1619381316-7719-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/29] lustre: mdt: mkdir should return
 -EEXIST if exists
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

lfs setdirstripe' will try restripe if target exists, however
it's confusing to get -ENOTSUPP or -EALREADY for 'lfs mkdir', while
the latter invokes the same function as 'lfs setdirstripe'.

Pack MDS_OPEN_CREAT flag in request for 'lfs mkdir', and MDT won't
try restripe if it's set.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14366
Lustre-commit: 65e3e4050ec5bb371 ("LU-14366 mdt: lfs mkdir should return -EEXIST if exists")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41329
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                  | 11 +++++++++--
 fs/lustre/mdc/mdc_lib.c                |  5 +++++
 include/uapi/linux/lustre/lustre_idl.h |  2 ++
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 76294ff5..21b40d1 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -373,7 +373,8 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
  *		<0 if the creation is failed.
  */
 static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
-			       size_t len, const char *dirname, umode_t mode)
+			       size_t len, const char *dirname, umode_t mode,
+			       bool createonly)
 {
 	struct inode *parent = dparent->d_inode;
 	struct ptlrpc_request *request = NULL;
@@ -482,6 +483,9 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	}
 
 	op_data->op_cli_flags |= CLI_SET_MEA;
+	if (createonly)
+		op_data->op_bias |= MDS_SETSTRIPE_CREATE;
+
 	err = md_create(sbi->ll_md_exp, op_data, lump, len, mode,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
@@ -1378,6 +1382,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		int namelen = 0;
 		int lumlen = 0;
 		umode_t mode;
+		bool createonly = false;
 		int len;
 		int rc;
 
@@ -1427,7 +1432,9 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		}
 
 		mode = data->ioc_type;
-		rc = ll_dir_setdirstripe(dentry, lum, lumlen, filename, mode);
+		createonly = data->ioc_obdo1.o_flags & OBD_FL_OBDMDEXISTS;
+		rc = ll_dir_setdirstripe(dentry, lum, lumlen, filename, mode,
+					 createonly);
 lmv_out_free:
 		kvfree(data);
 		return rc;
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 9251aec..69261b2 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -212,6 +212,11 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	flags = 0;
 	if (op_data->op_bias & MDS_CREATE_VOLATILE)
 		flags |= MDS_OPEN_VOLATILE;
+	if (op_data->op_bias & MDS_SETSTRIPE_CREATE)
+		/* borrow MDS_OPEN_CREATE flag to indicate current setstripe
+		 * create only, and don't restripe if object exists.
+		 */
+		flags |= MDS_OPEN_CREAT;
 	set_mrc_cr_flags(rec, flags);
 	rec->cr_bias = op_data->op_bias;
 	rec->cr_umask = current_umask();
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index d71fe47..c79010b 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1736,6 +1736,8 @@ enum mds_op_bias {
 	MDS_TRUNC_KEEP_LEASE	= 1 << 18,
 	MDS_PCC_ATTACH		= 1 << 19,
 	MDS_CLOSE_UPDATE_TIMES	= 1 << 20,
+	/* setstripe create only, don't restripe if target exists */
+	 MDS_SETSTRIPE_CREATE	= 1 << 21,
 };
 
 #define MDS_CLOSE_INTENT (MDS_HSM_RELEASE | MDS_CLOSE_LAYOUT_SWAP |         \
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
