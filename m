Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 632B4C433E0
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:18 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 04D8923A5A
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04D8923A5A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C6F7221FE79;
	Thu, 21 Jan 2021 09:17:48 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1B05221FC17
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:12 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 5FFCB1008482;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5E52D1B49C; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:45 -0500
Message-Id: <1611249422-556-23-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 22/39] lustre: uapi: fix compatibility for
 LL_IOC_MDC_GETINFO
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

From: Qian Yingjin <qian@ddn.com>

The landed patch "lustre: som: integrate LSOM with lfs find"
uses "LL_IOC_MDC_GETINFO_OLD", so while the IOCTL number/structs
are ABI compatible, it is not API compatible and applications
using for the header including the definition LL_IOC_MDC_GETINFO
is broken.

This patch defines versioned IOCTL number: LL_IOC_MDC_GETINFO_V1,
LL_IOC_MDC_GETINFO_V2. Then we can use the explicitly versioned
constrants everywhere for the in-tree code, and declare
LL_IOC_MDC_GETINFO in a compatible way, but external applications
can select the version that they want explicitly.

And this patch does the same fix for IOC_MDC_GETFILEINFO.

Fixes: 9b5e45e7275e ("lustre: som: integrate LSOM with lfs find")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13826
Lustre-commit: 449c648793d2fc ("LU-13826 utils: fix compatibility for LL_IOC_MDC_GETINFO")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/40858
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                   | 34 ++++++++++++++++-----------------
 include/uapi/linux/lustre/lustre_user.h | 14 ++++++--------
 2 files changed, 23 insertions(+), 25 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index db620ce..c42cff7 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1634,10 +1634,10 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		return ll_obd_statfs(inode, (void __user *)arg);
 	case LL_IOC_LOV_GETSTRIPE:
 	case LL_IOC_LOV_GETSTRIPE_NEW:
-	case LL_IOC_MDC_GETINFO:
-	case LL_IOC_MDC_GETINFO_OLD:
-	case IOC_MDC_GETFILEINFO:
-	case IOC_MDC_GETFILEINFO_OLD:
+	case LL_IOC_MDC_GETINFO_V1:
+	case LL_IOC_MDC_GETINFO_V2:
+	case IOC_MDC_GETFILEINFO_V1:
+	case IOC_MDC_GETFILEINFO_V2:
 	case IOC_MDC_GETFILESTRIPE: {
 		struct ptlrpc_request *request = NULL;
 		struct ptlrpc_request *root_request = NULL;
@@ -1652,8 +1652,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		struct lu_fid __user *fidp = NULL;
 		int lmmsize;
 
-		if (cmd == IOC_MDC_GETFILEINFO_OLD ||
-		    cmd == IOC_MDC_GETFILEINFO ||
+		if (cmd == IOC_MDC_GETFILEINFO_V1 ||
+		    cmd == IOC_MDC_GETFILEINFO_V2 ||
 		    cmd == IOC_MDC_GETFILESTRIPE) {
 			filename = ll_getname((const char __user *)arg);
 			if (IS_ERR(filename))
@@ -1675,10 +1675,10 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			goto out_req;
 		}
 
-		if (rc == -ENODATA && (cmd == IOC_MDC_GETFILEINFO ||
-				       cmd == LL_IOC_MDC_GETINFO ||
-				       cmd == IOC_MDC_GETFILEINFO_OLD ||
-				       cmd == LL_IOC_MDC_GETINFO_OLD)) {
+		if (rc == -ENODATA && (cmd == IOC_MDC_GETFILEINFO_V1 ||
+				       cmd == LL_IOC_MDC_GETINFO_V1 ||
+				       cmd == IOC_MDC_GETFILEINFO_V2 ||
+				       cmd == LL_IOC_MDC_GETINFO_V2)) {
 			lmmsize = 0;
 			rc = 0;
 		}
@@ -1690,8 +1690,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		    cmd == LL_IOC_LOV_GETSTRIPE ||
 		    cmd == LL_IOC_LOV_GETSTRIPE_NEW) {
 			lump = (struct lov_user_md __user *)arg;
-		} else if (cmd == IOC_MDC_GETFILEINFO_OLD ||
-			   cmd == LL_IOC_MDC_GETINFO_OLD){
+		} else if (cmd == IOC_MDC_GETFILEINFO_V1 ||
+			   cmd == LL_IOC_MDC_GETINFO_V1) {
 			struct lov_user_mds_data_v1 __user *lmdp;
 
 			lmdp = (struct lov_user_mds_data_v1 __user *)arg;
@@ -1724,8 +1724,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			rc = -EOVERFLOW;
 		}
 
-		if (cmd == IOC_MDC_GETFILEINFO_OLD ||
-		    cmd == LL_IOC_MDC_GETINFO_OLD) {
+		if (cmd == IOC_MDC_GETFILEINFO_V1 ||
+		    cmd == LL_IOC_MDC_GETINFO_V1) {
 			lstat_t st = { 0 };
 
 			st.st_dev = inode->i_sb->s_dev;
@@ -1748,8 +1748,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 				rc = -EFAULT;
 				goto out_req;
 			}
-		} else if (cmd == IOC_MDC_GETFILEINFO ||
-			   cmd == LL_IOC_MDC_GETINFO) {
+		} else if (cmd == IOC_MDC_GETFILEINFO_V2 ||
+			   cmd == LL_IOC_MDC_GETINFO_V2) {
 			struct statx stx = { 0 };
 			u64 valid = body->mbo_valid;
 
@@ -1783,7 +1783,7 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			 * However, this whould be better decided by the MDS
 			 * instead of the client.
 			 */
-			if (cmd == LL_IOC_MDC_GETINFO &&
+			if (cmd == LL_IOC_MDC_GETINFO_V2 &&
 			    ll_i2info(inode)->lli_lsm_md)
 				valid &= ~(OBD_MD_FLSIZE | OBD_MD_FLBLOCKS);
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 62c6952..835ffce 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -86,8 +86,6 @@
 #define fstatat_f	fstatat
 #endif
 
-#define HAVE_LOV_USER_MDS_DATA
-
 #define LUSTRE_EOF 0xffffffffffffffffULL
 
 /* for statfs() */
@@ -384,10 +382,12 @@ struct ll_ioc_lease_id {
 #define IOC_MDC_TYPE		'i'
 #define IOC_MDC_LOOKUP		_IOWR(IOC_MDC_TYPE, 20, struct obd_device *)
 #define IOC_MDC_GETFILESTRIPE	_IOWR(IOC_MDC_TYPE, 21, struct lov_user_md *)
-#define IOC_MDC_GETFILEINFO_OLD	_IOWR(IOC_MDC_TYPE, 22, struct lov_user_mds_data_v1 *)
-#define IOC_MDC_GETFILEINFO	_IOWR(IOC_MDC_TYPE, 22, struct lov_user_mds_data)
-#define LL_IOC_MDC_GETINFO_OLD	_IOWR(IOC_MDC_TYPE, 23, struct lov_user_mds_data_v1 *)
-#define LL_IOC_MDC_GETINFO	_IOWR(IOC_MDC_TYPE, 23, struct lov_user_mds_data)
+#define IOC_MDC_GETFILEINFO_V1	_IOWR(IOC_MDC_TYPE, 22, struct lov_user_mds_data_v1 *)
+#define IOC_MDC_GETFILEINFO_V2	_IOWR(IOC_MDC_TYPE, 22, struct lov_user_mds_data)
+#define LL_IOC_MDC_GETINFO_V1	_IOWR(IOC_MDC_TYPE, 23, struct lov_user_mds_data_v1 *)
+#define LL_IOC_MDC_GETINFO_V2	_IOWR(IOC_MDC_TYPE, 23, struct lov_user_mds_data)
+#define IOC_MDC_GETFILEINFO	IOC_MDC_GETFILEINFO_V1
+#define LL_IOC_MDC_GETINFO	LL_IOC_MDC_GETINFO_V1
 
 #define MAX_OBD_NAME 128 /* If this changes, a NEW ioctl must be added */
 
@@ -658,7 +658,6 @@ static inline __u32 lov_user_md_size(__u16 stripes, __u32 lmm_magic)
  * use this.  It is unsafe to #define those values in this header as it
  * is possible the application has already #included <sys/stat.h>.
  */
-#ifdef HAVE_LOV_USER_MDS_DATA
 #define lov_user_mds_data lov_user_mds_data_v2
 struct lov_user_mds_data_v1 {
 	lstat_t lmd_st;			/* MDS stat struct */
@@ -678,7 +677,6 @@ struct lov_user_mds_data_v3 {
 	lstat_t lmd_st;			/* MDS stat struct */
 	struct lov_user_md_v3 lmd_lmm;	/* LOV EA V3 user data */
 } __attribute__((packed));
-#endif
 
 struct lmv_user_mds_data {
 	struct lu_fid	lum_fid;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
