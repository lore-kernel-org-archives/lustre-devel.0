Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3EB1C433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5BCF160230
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BCF160230
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 292A62F64CE;
	Wed, 14 Apr 2021 21:03:31 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9639232F509
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:52 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7FEDC100F355;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7D0699188E; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:12 -0400
Message-Id: <1618459361-17909-21-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 20/49] lustre: uapi: remove
 OBD_IOC_LOV_GET_CONFIG
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

The "lctl lov_getconfig" command has been obsolete for some time,
but was kept around for sanity test_44a to work properly.  Now
that LU-11656 has landed, "lfs getstripe -d $DIR" can be used to
get the actual layout used for files created in a directory.

Remove the lov_getconfig command along with the IOC definition
it was using.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13107
Lustre-commit: d2cb789537485eec ("LU-13107 utils: remove lctl lov_getconfig command")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/37106
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_obd.c                  | 43 --------------------------------
 include/uapi/linux/lustre/lustre_ioctl.h |  3 +--
 2 files changed, 1 insertion(+), 45 deletions(-)

diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 9554d85..2939d66 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -964,7 +964,6 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	struct obd_device *obd = class_exp2obd(exp);
 	struct lov_obd *lov = &obd->u.lov;
 	int i = 0, rc = 0, count = lov->desc.ld_tgt_count;
-	struct obd_uuid *uuidp;
 
 	switch (cmd) {
 	case IOC_OBD_STATFS: {
@@ -1013,48 +1012,6 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 			return -EFAULT;
 		break;
 	}
-	case OBD_IOC_LOV_GET_CONFIG: {
-		struct obd_ioctl_data *data;
-		struct lov_desc *desc;
-		u32 *genp;
-
-		len = 0;
-		if (obd_ioctl_getdata(&data, &len, uarg))
-			return -EINVAL;
-
-		if (sizeof(*desc) > data->ioc_inllen1) {
-			kvfree(data);
-			return -EINVAL;
-		}
-
-		if (sizeof(uuidp->uuid) * count > data->ioc_inllen2) {
-			kvfree(data);
-			return -EINVAL;
-		}
-
-		if (sizeof(u32) * count > data->ioc_inllen3) {
-			kvfree(data);
-			return -EINVAL;
-		}
-
-		desc = (struct lov_desc *)data->ioc_inlbuf1;
-		memcpy(desc, &lov->desc, sizeof(*desc));
-
-		uuidp = (struct obd_uuid *)data->ioc_inlbuf2;
-		genp = (u32 *)data->ioc_inlbuf3;
-		/* the uuid will be empty for deleted OSTs */
-		for (i = 0; i < count; i++, uuidp++, genp++) {
-			if (!lov->lov_tgts[i])
-				continue;
-			*uuidp = lov->lov_tgts[i]->ltd_uuid;
-			*genp = lov->lov_tgts[i]->ltd_gen;
-		}
-
-		if (copy_to_user(uarg, data, len))
-			rc = -EFAULT;
-		kvfree(data);
-		break;
-	}
 	case OBD_IOC_QUOTACTL: {
 		struct if_quotactl *qctl = karg;
 		struct lov_tgt_desc *tgt = NULL;
diff --git a/include/uapi/linux/lustre/lustre_ioctl.h b/include/uapi/linux/lustre/lustre_ioctl.h
index 7d48e27..be388fc 100644
--- a/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/include/uapi/linux/lustre/lustre_ioctl.h
@@ -163,10 +163,9 @@ static inline __u32 obd_ioctl_packlen(struct obd_ioctl_data *data)
 #define OBD_IOC_GETNAME		_IOWR('f', 131, OBD_IOC_DATA_TYPE)
 #define OBD_IOC_GETMDNAME	_IOR('f', 131, char[MAX_OBD_NAME])
 #define OBD_IOC_GETDTNAME	OBD_IOC_GETNAME
-#define OBD_IOC_LOV_GET_CONFIG	_IOWR('f', 132, OBD_IOC_DATA_TYPE)
+/*	OBD_IOC_LOV_GET_CONFIG	_IOWR('f', 132, OBD_IOC_DATA_TYPE) until 2.14 */
 #define OBD_IOC_CLIENT_RECOVER	_IOW('f', 133, OBD_IOC_DATA_TYPE)
 /* was	OBD_IOC_PING_TARGET	_IOW('f', 136, OBD_IOC_DATA_TYPE) until 2.11 */
-
 /*	OBD_IOC_DEC_FS_USE_COUNT _IO('f', 139) */
 /* was OBD_IOC_NO_TRANSNO      _IOW('f', 140, OBD_IOC_DATA_TYPE) until 2.14 */
 #define OBD_IOC_SET_READONLY	_IOW('f', 141, OBD_IOC_DATA_TYPE)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
