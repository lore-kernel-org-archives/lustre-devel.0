Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47467C433B4
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:31 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 01E056124B
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01E056124B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5403721F8A8;
	Sun, 25 Apr 2021 13:09:11 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D94E421F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:44 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1EC8910087C6;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 186EF69A7D; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:18 -0400
Message-Id: <1619381316-7719-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/29] lustre: include: remove references to
 Sun Trademark.
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

From: Mr NeilBrown <neilb@suse.de>

"lustre" is no longer a Trademark of Sun Microsystems.  There is no
need to acknowledge the trademark is every file, so just remove all
these claims.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14487
Lustre-commit: 1d3c585194a907ad ("LU-14487 lustre: remove references to Sun Trademark.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41880
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h             | 1 -
 fs/lustre/include/lprocfs_status.h        | 1 -
 fs/lustre/include/lu_object.h             | 1 -
 fs/lustre/include/lustre_acl.h            | 1 -
 fs/lustre/include/lustre_disk.h           | 1 -
 fs/lustre/include/lustre_dlm.h            | 1 -
 fs/lustre/include/lustre_export.h         | 1 -
 fs/lustre/include/lustre_fid.h            | 1 -
 fs/lustre/include/lustre_fld.h            | 1 -
 fs/lustre/include/lustre_ha.h             | 1 -
 fs/lustre/include/lustre_handles.h        | 2 --
 fs/lustre/include/lustre_import.h         | 2 --
 fs/lustre/include/lustre_intent.h         | 1 -
 fs/lustre/include/lustre_lib.h            | 1 -
 fs/lustre/include/lustre_log.h            | 1 -
 fs/lustre/include/lustre_mdc.h            | 1 -
 fs/lustre/include/lustre_net.h            | 1 -
 fs/lustre/include/lustre_osc.h            | 1 -
 fs/lustre/include/lustre_req_layout.h     | 1 -
 fs/lustre/include/lustre_sec.h            | 1 -
 fs/lustre/include/obd.h                   | 1 -
 fs/lustre/include/obd_cksum.h             | 1 -
 fs/lustre/include/obd_class.h             | 1 -
 fs/lustre/include/obd_support.h           | 1 -
 fs/lustre/include/obd_target.h            | 1 -
 include/uapi/linux/lustre/lustre_cfg.h    | 1 -
 include/uapi/linux/lustre/lustre_fiemap.h | 1 -
 include/uapi/linux/lustre/lustre_idl.h    | 1 -
 include/uapi/linux/lustre/lustre_param.h  | 1 -
 include/uapi/linux/lustre/lustre_user.h   | 1 -
 30 files changed, 32 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 6554e3d..3926aac 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 #ifndef _LUSTRE_CL_OBJECT_H
 #define _LUSTRE_CL_OBJECT_H
diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index 9051de7..c8923c8 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/include/lprocfs_status.h
  *
diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 34610d4..80cd36d 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef __LUSTRE_LU_OBJECT_H
diff --git a/fs/lustre/include/lustre_acl.h b/fs/lustre/include/lustre_acl.h
index bb161ba..43b6f1d 100644
--- a/fs/lustre/include/lustre_acl.h
+++ b/fs/lustre/include/lustre_acl.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/include/lustre_acl.h
  */
diff --git a/fs/lustre/include/lustre_disk.h b/fs/lustre/include/lustre_disk.h
index a54b5fd..81a0d40 100644
--- a/fs/lustre/include/lustre_disk.h
+++ b/fs/lustre/include/lustre_disk.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/include/lustre_disk.h
  *
diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 8156f75..f1828df 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 /** \defgroup LDLM Lustre Distributed Lock Manager
diff --git a/fs/lustre/include/lustre_export.h b/fs/lustre/include/lustre_export.h
index 4cc88ef..6a59e6c 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 /** \defgroup obd_export PortalRPC export definitions
  *
diff --git a/fs/lustre/include/lustre_fid.h b/fs/lustre/include/lustre_fid.h
index c67dfb2d..b8a3f2e 100644
--- a/fs/lustre/include/lustre_fid.h
+++ b/fs/lustre/include/lustre_fid.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/include/lustre_fid.h
  *
diff --git a/fs/lustre/include/lustre_fld.h b/fs/lustre/include/lustre_fld.h
index 92074ab..2382484 100644
--- a/fs/lustre/include/lustre_fld.h
+++ b/fs/lustre/include/lustre_fld.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef __LINUX_FLD_H
diff --git a/fs/lustre/include/lustre_ha.h b/fs/lustre/include/lustre_ha.h
index c914ef6..a072b95 100644
--- a/fs/lustre/include/lustre_ha.h
+++ b/fs/lustre/include/lustre_ha.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef _LUSTRE_HA_H
diff --git a/fs/lustre/include/lustre_handles.h b/fs/lustre/include/lustre_handles.h
index 9dbe7c9..88111ae 100644
--- a/fs/lustre/include/lustre_handles.h
+++ b/fs/lustre/include/lustre_handles.h
@@ -1,4 +1,3 @@
-// SPDX-License-Identifier: GPL-2.0
 /*
  * GPL HEADER START
  *
@@ -28,7 +27,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef __LUSTRE_HANDLES_H_
diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index 72a303e..8c1fe65 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -1,4 +1,3 @@
-// SPDX-License-Identifier: GPL-2.0
 /*
  * GPL HEADER START
  *
@@ -28,7 +27,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 /** \defgroup obd_import PtlRPC import definitions
  * Imports are client-side representation of remote obd target.
diff --git a/fs/lustre/include/lustre_intent.h b/fs/lustre/include/lustre_intent.h
index f97c318..e7d81f6 100644
--- a/fs/lustre/include/lustre_intent.h
+++ b/fs/lustre/include/lustre_intent.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef LUSTRE_INTENT_H
diff --git a/fs/lustre/include/lustre_lib.h b/fs/lustre/include/lustre_lib.h
index fc4b4c5..7210a56 100644
--- a/fs/lustre/include/lustre_lib.h
+++ b/fs/lustre/include/lustre_lib.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/include/lustre_lib.h
  *
diff --git a/fs/lustre/include/lustre_log.h b/fs/lustre/include/lustre_log.h
index 24e6609..1fc7729 100644
--- a/fs/lustre/include/lustre_log.h
+++ b/fs/lustre/include/lustre_log.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/include/lustre_log.h
  *
diff --git a/fs/lustre/include/lustre_mdc.h b/fs/lustre/include/lustre_mdc.h
index d7b6e4a..2ee77ce 100644
--- a/fs/lustre/include/lustre_mdc.h
+++ b/fs/lustre/include/lustre_mdc.h
@@ -29,7 +29,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/include/lustre_mdc.h
  *
diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index abd16ea..e1eb888 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 /** \defgroup PtlRPC Portal RPC and networking module.
  *
diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 17bfbfb..f83d1e6 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 /*
  * fs/lustre/include/lustre_osc.h
diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 434bb08..f6ebda3 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/include/lustre_req_layout.h
  *
diff --git a/fs/lustre/include/lustre_sec.h b/fs/lustre/include/lustre_sec.h
index aec30bc..e8410e1 100644
--- a/fs/lustre/include/lustre_sec.h
+++ b/fs/lustre/include/lustre_sec.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef _LUSTRE_SEC_H_
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 9957105..efd4538 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef __OBD_H
diff --git a/fs/lustre/include/obd_cksum.h b/fs/lustre/include/obd_cksum.h
index 08c1cb9..1189bc2 100644
--- a/fs/lustre/include/obd_cksum.h
+++ b/fs/lustre/include/obd_cksum.h
@@ -26,7 +26,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef __OBD_CKSUM
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 6bcd89b..1d1777a 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 #ifndef __CLASS_OBD_H
 #define __CLASS_OBD_H
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 027667f..878a5cd 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef _OBD_SUPPORT
diff --git a/fs/lustre/include/obd_target.h b/fs/lustre/include/obd_target.h
index 466dd3c..5d8e8bb 100644
--- a/fs/lustre/include/obd_target.h
+++ b/fs/lustre/include/obd_target.h
@@ -27,7 +27,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef __OBD_TARGET_H
diff --git a/include/uapi/linux/lustre/lustre_cfg.h b/include/uapi/linux/lustre/lustre_cfg.h
index 1036d0d..2a1eabb 100644
--- a/include/uapi/linux/lustre/lustre_cfg.h
+++ b/include/uapi/linux/lustre/lustre_cfg.h
@@ -27,7 +27,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef _UAPI_LUSTRE_CFG_H_
diff --git a/include/uapi/linux/lustre/lustre_fiemap.h b/include/uapi/linux/lustre/lustre_fiemap.h
index f93e107..c3e32ef 100644
--- a/include/uapi/linux/lustre/lustre_fiemap.h
+++ b/include/uapi/linux/lustre/lustre_fiemap.h
@@ -27,7 +27,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * FIEMAP data structures and flags. This header file will be used until
  * fiemap.h is available in the upstream kernel.
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index b0c6191..d71fe47 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -27,7 +27,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Lustre wire protocol definitions.
  */
diff --git a/include/uapi/linux/lustre/lustre_param.h b/include/uapi/linux/lustre/lustre_param.h
index ab026e3..fda6e7a 100644
--- a/include/uapi/linux/lustre/lustre_param.h
+++ b/include/uapi/linux/lustre/lustre_param.h
@@ -27,7 +27,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * User-settable parameter keys
  *
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index acc0eaf..3e2144a 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -27,7 +27,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/include/lustre/lustre_user.h
  *
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
