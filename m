Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D84C7C433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:47 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 934F7610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 934F7610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A68F332F902;
	Wed, 14 Apr 2021 21:03:23 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4B1C332F509
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:52 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7B0B4100F354;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 79DA391883; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:11 -0400
Message-Id: <1618459361-17909-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/49] lustre: mds: add enums for MDS_ATTR
 flags
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

From: Andreas Dilger <adilger@whamcloud.com>

Add mds_attr_flags to the code to make it easier to follow the logic.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12885
Lustre-commit: 6c6b8cb972ac92c0 ("LU-12885 mds: add enums for MDS_ATTR flags")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33512
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_lib.c                | 10 +++++---
 include/uapi/linux/lustre/lustre_idl.h | 46 ++++++++++++++++++----------------
 2 files changed, 30 insertions(+), 26 deletions(-)

diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 6cb14c1..9251aec 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -325,9 +325,10 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	set_mrc_cr_flags(rec, cr_flags);
 }
 
-static inline u64 attr_pack(unsigned int ia_valid, enum op_xvalid ia_xvalid)
+static inline enum mds_attr_flags mdc_attr_pack(unsigned int ia_valid,
+						enum op_xvalid ia_xvalid)
 {
-	u64 sa_valid = 0;
+	enum mds_attr_flags sa_valid = 0;
 
 	if (ia_valid & ATTR_MODE)
 		sa_valid |= MDS_ATTR_MODE;
@@ -370,6 +371,7 @@ static inline u64 attr_pack(unsigned int ia_valid, enum op_xvalid ia_xvalid)
 		sa_valid |= MDS_ATTR_LSIZE;
 	if (ia_xvalid & OP_XVALID_LAZYBLOCKS)
 		sa_valid |= MDS_ATTR_LBLOCKS;
+
 	return sa_valid;
 }
 
@@ -383,8 +385,8 @@ static void mdc_setattr_pack_rec(struct mdt_rec_setattr *rec,
 	rec->sa_suppgid = -1;
 
 	rec->sa_fid = op_data->op_fid1;
-	rec->sa_valid  = attr_pack(op_data->op_attr.ia_valid,
-				   op_data->op_xvalid);
+	rec->sa_valid  = mdc_attr_pack(op_data->op_attr.ia_valid,
+				       op_data->op_xvalid);
 	rec->sa_mode = op_data->op_attr.ia_mode;
 	rec->sa_uid = from_kuid(&init_user_ns, op_data->op_attr.ia_uid);
 	rec->sa_gid = from_kgid(&init_user_ns, op_data->op_attr.ia_gid);
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 3a33657..b0c6191 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1683,28 +1683,30 @@ struct mdt_rec_setattr {
  * since the client and MDS may run different kernels (see bug 13828)
  * Therefore, we should only use MDS_ATTR_* attributes for sa_valid.
  */
-#define MDS_ATTR_MODE		   0x1ULL /* = 1 */
-#define MDS_ATTR_UID		   0x2ULL /* = 2 */
-#define MDS_ATTR_GID		   0x4ULL /* = 4 */
-#define MDS_ATTR_SIZE		   0x8ULL /* = 8 */
-#define MDS_ATTR_ATIME		  0x10ULL /* = 16 */
-#define MDS_ATTR_MTIME		  0x20ULL /* = 32 */
-#define MDS_ATTR_CTIME		  0x40ULL /* = 64 */
-#define MDS_ATTR_ATIME_SET	  0x80ULL /* = 128 */
-#define MDS_ATTR_MTIME_SET	 0x100ULL /* = 256 */
-#define MDS_ATTR_FORCE		 0x200ULL /* = 512, Not a change, but a change it */
-#define MDS_ATTR_ATTR_FLAG	 0x400ULL /* = 1024 */
-#define MDS_ATTR_KILL_SUID	 0x800ULL /* = 2048 */
-#define MDS_ATTR_KILL_SGID	0x1000ULL /* = 4096 */
-#define MDS_ATTR_CTIME_SET	0x2000ULL /* = 8192 */
-#define MDS_ATTR_FROM_OPEN	0x4000ULL /* = 16384, called from open path,
-					   * ie O_TRUNC
-					   */
-#define MDS_ATTR_BLOCKS		0x8000ULL  /* = 32768 */
-#define MDS_ATTR_PROJID		0x10000ULL /* = 65536 */
-#define MDS_ATTR_LSIZE		0x20000ULL /* = 131072 */
-#define MDS_ATTR_LBLOCKS	0x40000ULL /* = 262144 */
-#define MDS_ATTR_OVERRIDE	0x2000000ULL /* = 33554432 */
+enum mds_attr_flags {
+	MDS_ATTR_MODE =		      0x1ULL, /* = 1 */
+	MDS_ATTR_UID =		      0x2ULL, /* = 2 */
+	MDS_ATTR_GID =		      0x4ULL, /* = 4 */
+	MDS_ATTR_SIZE =		      0x8ULL, /* = 8 */
+	MDS_ATTR_ATIME =	     0x10ULL, /* = 16 */
+	MDS_ATTR_MTIME =	     0x20ULL, /* = 32 */
+	MDS_ATTR_CTIME =	     0x40ULL, /* = 64 */
+	MDS_ATTR_ATIME_SET =	     0x80ULL, /* = 128 */
+	MDS_ATTR_MTIME_SET =	    0x100ULL, /* = 256 */
+	MDS_ATTR_FORCE =	    0x200ULL, /* = 512, Not a change, but a change it */
+	MDS_ATTR_ATTR_FLAG =	    0x400ULL, /* = 1024 */
+	MDS_ATTR_KILL_SUID =	    0x800ULL, /* = 2048 */
+	MDS_ATTR_KILL_SGID =	   0x1000ULL, /* = 4096 */
+	MDS_ATTR_CTIME_SET =	   0x2000ULL, /* = 8192 */
+	MDS_ATTR_FROM_OPEN =	   0x4000ULL, /* = 16384, called from open path,
+					       * ie O_TRUNC
+					       */
+	MDS_ATTR_BLOCKS =	   0x8000ULL, /* = 32768 */
+	MDS_ATTR_PROJID	=	  0x10000ULL, /* = 65536 */
+	MDS_ATTR_LSIZE =	  0x20000ULL, /* = 131072 */
+	MDS_ATTR_LBLOCKS =	  0x40000ULL, /* = 262144 */
+	MDS_ATTR_OVERRIDE =	0x2000000ULL, /* = 33554432 */
+};
 
 enum mds_op_bias {
 /*	MDS_CHECK_SPLIT		= 1 << 0, obsolete before 2.3.58 */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
