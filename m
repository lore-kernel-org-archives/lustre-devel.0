Return-Path: <SRS0=WSMT=J7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26A55C433B4
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:11:05 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A4F6D610E6
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:11:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4F6D610E6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 19D0321F976;
	Mon,  3 May 2021 17:10:46 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6F3F521F467
 for <lustre-devel@lists.lustre.org>; Mon,  3 May 2021 17:10:24 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 35313EE3;
 Mon,  3 May 2021 20:10:20 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 31AFD8AD3D; Mon,  3 May 2021 20:10:20 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  3 May 2021 20:10:11 -0400
Message-Id: <1620087016-17857-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
References: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/14] lnet: libcfs: remove references to Sun
 Trademark.
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
need to acknowledge the trademark in every file, so just remove all
these claims.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14487
Lustre-commit: 6621439c371e37268 ("LU-14487 libcfs: remove references to Sun Trademark.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/42137
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/libcfs/libcfs.h         | 1 -
 include/linux/libcfs/libcfs_cpu.h     | 1 -
 include/linux/libcfs/libcfs_debug.h   | 1 -
 include/linux/libcfs/libcfs_hash.h    | 1 -
 include/linux/libcfs/libcfs_private.h | 1 -
 include/linux/libcfs/libcfs_string.h  | 1 -
 net/lnet/libcfs/debug.c               | 1 -
 net/lnet/libcfs/hash.c                | 1 -
 net/lnet/libcfs/libcfs_cpu.c          | 1 -
 net/lnet/libcfs/libcfs_lock.c         | 1 -
 net/lnet/libcfs/libcfs_mem.c          | 1 -
 net/lnet/libcfs/libcfs_string.c       | 1 -
 net/lnet/libcfs/module.c              | 1 -
 net/lnet/libcfs/tracefile.c           | 1 -
 net/lnet/libcfs/tracefile.h           | 1 -
 15 files changed, 15 deletions(-)

diff --git a/include/linux/libcfs/libcfs.h b/include/linux/libcfs/libcfs.h
index c98d7a1..b59ef9b 100644
--- a/include/linux/libcfs/libcfs.h
+++ b/include/linux/libcfs/libcfs.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef __LIBCFS_LIBCFS_H__
diff --git a/include/linux/libcfs/libcfs_cpu.h b/include/linux/libcfs/libcfs_cpu.h
index 310b25c..b4f1b58 100644
--- a/include/linux/libcfs/libcfs_cpu.h
+++ b/include/linux/libcfs/libcfs_cpu.h
@@ -23,7 +23,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * libcfs/include/libcfs/libcfs_cpu.h
  *
diff --git a/include/linux/libcfs/libcfs_debug.h b/include/linux/libcfs/libcfs_debug.h
index bc85bb9..373a055 100644
--- a/include/linux/libcfs/libcfs_debug.h
+++ b/include/linux/libcfs/libcfs_debug.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * libcfs/include/libcfs/libcfs_debug.h
  *
diff --git a/include/linux/libcfs/libcfs_hash.h b/include/linux/libcfs/libcfs_hash.h
index 7f62379..d3b4875 100644
--- a/include/linux/libcfs/libcfs_hash.h
+++ b/include/linux/libcfs/libcfs_hash.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * libcfs/include/libcfs/libcfs_hash.h
  *
diff --git a/include/linux/libcfs/libcfs_private.h b/include/linux/libcfs/libcfs_private.h
index 3996d0e..378c2a5 100644
--- a/include/linux/libcfs/libcfs_private.h
+++ b/include/linux/libcfs/libcfs_private.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * libcfs/include/libcfs/libcfs_private.h
  *
diff --git a/include/linux/libcfs/libcfs_string.h b/include/linux/libcfs/libcfs_string.h
index 34b5521..e2b6d72 100644
--- a/include/linux/libcfs/libcfs_string.h
+++ b/include/linux/libcfs/libcfs_string.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * libcfs/include/libcfs/libcfs_string.h
  *
diff --git a/net/lnet/libcfs/debug.c b/net/lnet/libcfs/debug.c
index cb6c33a..1bb382d 100644
--- a/net/lnet/libcfs/debug.c
+++ b/net/lnet/libcfs/debug.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * libcfs/libcfs/debug.c
  *
diff --git a/net/lnet/libcfs/hash.c b/net/lnet/libcfs/hash.c
index f452c45..d060eaa 100644
--- a/net/lnet/libcfs/hash.c
+++ b/net/lnet/libcfs/hash.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * libcfs/libcfs/hash.c
  *
diff --git a/net/lnet/libcfs/libcfs_cpu.c b/net/lnet/libcfs/libcfs_cpu.c
index 8e4fdb1..dca92cd 100644
--- a/net/lnet/libcfs/libcfs_cpu.c
+++ b/net/lnet/libcfs/libcfs_cpu.c
@@ -22,7 +22,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Please see comments in libcfs/include/libcfs/libcfs_cpu.h for introduction
  *
diff --git a/net/lnet/libcfs/libcfs_lock.c b/net/lnet/libcfs/libcfs_lock.c
index 313aa95..8af77b1 100644
--- a/net/lnet/libcfs/libcfs_lock.c
+++ b/net/lnet/libcfs/libcfs_lock.c
@@ -21,7 +21,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Author: liang@whamcloud.com
  */
diff --git a/net/lnet/libcfs/libcfs_mem.c b/net/lnet/libcfs/libcfs_mem.c
index 6a49d39..f2af90c 100644
--- a/net/lnet/libcfs/libcfs_mem.c
+++ b/net/lnet/libcfs/libcfs_mem.c
@@ -22,7 +22,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Author: liang@whamcloud.com
  */
diff --git a/net/lnet/libcfs/libcfs_string.c b/net/lnet/libcfs/libcfs_string.c
index 66a108c..d2460f3 100644
--- a/net/lnet/libcfs/libcfs_string.c
+++ b/net/lnet/libcfs/libcfs_string.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * String manipulation functions.
  *
diff --git a/net/lnet/libcfs/module.c b/net/lnet/libcfs/module.c
index 93e9b9e..8059569 100644
--- a/net/lnet/libcfs/module.c
+++ b/net/lnet/libcfs/module.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 #include <linux/miscdevice.h>
 #include <linux/module.h>
diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index b1a2f3e..6321840 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * libcfs/libcfs/tracefile.c
  *
diff --git a/net/lnet/libcfs/tracefile.h b/net/lnet/libcfs/tracefile.h
index 311ec8c..af21e4a 100644
--- a/net/lnet/libcfs/tracefile.h
+++ b/net/lnet/libcfs/tracefile.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef __LIBCFS_TRACEFILE_H__
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
