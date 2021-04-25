Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A765C433ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:25 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D9B1B611CC
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9B1B611CC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0EE7521F9F4;
	Sun, 25 Apr 2021 13:09:52 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6EFB721F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:45 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 24CD210087C8;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2226969A8C; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:21 -0400
Message-Id: <1619381316-7719-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/29] lustre: uapi: remove obsolete ioctls
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

Remove some very obsolete ioctl number definitions.

Highlight that some of the ioctl codes conflict with upstream
FSVerity ioctls that we may need to implement in the future.
This does not necessarily mean the actual ioctl numbers will
conflict (the "size" field can disambiguate them), but we should
avoid this range when adding new ioctls.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13107
Lustre-commit: 0f38a0b9db4f7c6c1 ("LU-13107 uapi: remove obsolete ioctls")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/37107
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                    |  3 +++
 fs/lustre/llite/file.c                   |  3 +++
 fs/lustre/llite/llite_lib.c              |  2 +-
 include/uapi/linux/lustre/lustre_ioctl.h | 28 +++++++++-------------------
 include/uapi/linux/lustre/lustre_user.h  |  1 +
 5 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 5dc93f4..76294ff5 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1865,7 +1865,10 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		kfree(qctl);
 		return rc;
 	}
+	case OBD_IOC_GETNAME_OLD:
+		/* fall through */
 	case OBD_IOC_GETDTNAME:
+		/* fall through */
 	case OBD_IOC_GETMDNAME:
 		return ll_get_obd_name(inode, cmd, arg);
 	case LL_IOC_FLUSHCTX:
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index e9f0fc9..1ca4589 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3745,7 +3745,10 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 
 		return 0;
 	}
+	case OBD_IOC_GETNAME_OLD:
+		/* fall through */
 	case OBD_IOC_GETDTNAME:
+		/* fall through */
 	case OBD_IOC_GETMDNAME:
 		return ll_get_obd_name(inode, cmd, arg);
 	case LL_IOC_HSM_STATE_GET: {
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 2f2d9f0..6af95fd 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2986,7 +2986,7 @@ int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg)
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	struct obd_device *obd;
 
-	if (cmd == OBD_IOC_GETDTNAME)
+	if (cmd == OBD_IOC_GETNAME_OLD || cmd == OBD_IOC_GETDTNAME)
 		obd = class_exp2obd(sbi->ll_dt_exp);
 	else if (cmd == OBD_IOC_GETMDNAME)
 		obd = class_exp2obd(sbi->ll_md_exp);
diff --git a/include/uapi/linux/lustre/lustre_ioctl.h b/include/uapi/linux/lustre/lustre_ioctl.h
index be388fc..fb1e6f1 100644
--- a/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/include/uapi/linux/lustre/lustre_ioctl.h
@@ -132,11 +132,6 @@ static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
  */
 #define OBD_IOC_DATA_TYPE	long
 
-/*	IOC_LDLM_TEST		_IOWR('f', 40, long) */
-/*	IOC_LDLM_DUMP		_IOWR('f', 41, long) */
-/*	IOC_LDLM_REGRESS_START	_IOWR('f', 42, long) */
-/*	IOC_LDLM_REGRESS_STOP	_IOWR('f', 43, long) */
-
 #define OBD_IOC_CREATE		_IOWR('f', 101, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_DESTROY		_IOW('f', 104, OBD_IOC_DATA_TYPE)
 /*	OBD_IOC_PREALLOCATE	_IOWR('f', 105, OBD_IOC_DATA_TYPE) */
@@ -148,29 +143,24 @@ static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
 
 #define OBD_IOC_STATFS		_IOWR('f', 113, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_SYNC		_IOW('f', 114, OBD_IOC_DATA_TYPE)
-/*	OBD_IOC_READ2		_IOWR('f', 115, OBD_IOC_DATA_TYPE) */
-/*	OBD_IOC_FORMAT		_IOWR('f', 116, OBD_IOC_DATA_TYPE) */
-/*	OBD_IOC_PARTITION	_IOWR('f', 117, OBD_IOC_DATA_TYPE) */
-/*	OBD_IOC_COPY		_IOWR('f', 120, OBD_IOC_DATA_TYPE) */
-/*	OBD_IOC_MIGR		_IOWR('f', 121, OBD_IOC_DATA_TYPE) */
-/*	OBD_IOC_PUNCH		_IOWR('f', 122, OBD_IOC_DATA_TYPE) */
-
-/*	OBD_IOC_MODULE_DEBUG	_IOWR('f', 124, OBD_IOC_DATA_TYPE) */
+
 #define OBD_IOC_BRW_READ	_IOWR('f', 125, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_BRW_WRITE	_IOWR('f', 126, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_NAME2DEV	_IOWR('f', 127, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_GETDTNAME	_IOR('f', 127, char[MAX_OBD_NAME])
+/* ioctl codes 128-143 are reserved for fsverity */
 #define OBD_IOC_UUID2DEV	_IOWR('f', 130, OBD_IOC_DATA_TYPE)
-#define OBD_IOC_GETNAME		_IOWR('f', 131, OBD_IOC_DATA_TYPE)
+#define OBD_IOC_GETNAME_OLD	_IOWR('f', 131, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_GETMDNAME	_IOR('f', 131, char[MAX_OBD_NAME])
-#define OBD_IOC_GETDTNAME	OBD_IOC_GETNAME
 /*	OBD_IOC_LOV_GET_CONFIG	_IOWR('f', 132, OBD_IOC_DATA_TYPE) until 2.14 */
 #define OBD_IOC_CLIENT_RECOVER	_IOW('f', 133, OBD_IOC_DATA_TYPE)
-/* was	OBD_IOC_PING_TARGET	_IOW('f', 136, OBD_IOC_DATA_TYPE) until 2.11 */
-/*	OBD_IOC_DEC_FS_USE_COUNT _IO('f', 139) */
-/* was OBD_IOC_NO_TRANSNO      _IOW('f', 140, OBD_IOC_DATA_TYPE) until 2.14 */
+/* ioctl codes 128-143 are reserved for fsverity */
+/* FS_IOC_ENABLE_VERITY		_IOW('f', 133, struct fsverity_enable_arg) */
+/* FS_IOC_MEASURE_VERITY	_IOW('f', 134, struct fsverity_digest) */
+/* was OBD_IOC_NO_TRANSNO	_IOW('f', 140, OBD_IOC_DATA_TYPE) until 2.14 */
 #define OBD_IOC_SET_READONLY	_IOW('f', 141, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_ABORT_RECOVERY	_IOR('f', 142, OBD_IOC_DATA_TYPE)
-/*	OBD_IOC_ROOT_SQUASH	_IOWR('f', 143, OBD_IOC_DATA_TYPE) */
+/* ioctl codes 128-143 are reserved for fsverity */
 #define OBD_GET_VERSION		_IOWR('f', 144, OBD_IOC_DATA_TYPE)
 /*	OBD_IOC_GSS_SUPPORT	_IOWR('f', 145, OBD_IOC_DATA_TYPE) */
 /*	OBD_IOC_CLOSE_UUID	_IOWR('f', 147, OBD_IOC_DATA_TYPE) */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 3e2144a..4a21cd6 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -312,6 +312,7 @@ struct ll_ioc_lease_id {
  * *INFO    - set/get lov_user_mds_data
  */
 /*	lustre_ioctl.h			101-150 */
+/* ioctl codes 128-143 are reserved for fsverity */
 #define LL_IOC_GETFLAGS			_IOR('f', 151, long)
 #define LL_IOC_SETFLAGS			_IOW('f', 152, long)
 #define LL_IOC_CLRFLAGS			_IOW('f', 153, long)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
