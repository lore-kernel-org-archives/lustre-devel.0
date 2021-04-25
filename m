Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75333C433ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:53 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 36B2A611CC
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36B2A611CC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 62F7E21F869;
	Sun, 25 Apr 2021 13:09:25 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9284821F803
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:49 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 5478110087D8;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5198769A85; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:35 -0400
Message-Id: <1619381316-7719-29-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 28/29] lnet: remove references to Sun
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
Lustre-commit: b77281bfd01367d2 ("LU-14487 lnet: remove references to Sun Trademark.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/42138
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lnet/libcfs_debug.h     | 1 -
 include/uapi/linux/lnet/libcfs_ioctl.h     | 1 -
 include/uapi/linux/lnet/lnet-idl.h         | 1 -
 include/uapi/linux/lnet/socklnd.h          | 1 -
 net/lnet/klnds/o2iblnd/o2iblnd-idl.h       | 1 -
 net/lnet/klnds/o2iblnd/o2iblnd.c           | 1 -
 net/lnet/klnds/o2iblnd/o2iblnd.h           | 1 -
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c        | 1 -
 net/lnet/klnds/o2iblnd/o2iblnd_modparams.c | 1 -
 net/lnet/klnds/socklnd/socklnd.c           | 1 -
 net/lnet/klnds/socklnd/socklnd_lib.c       | 1 -
 net/lnet/lnet/acceptor.c                   | 1 -
 net/lnet/lnet/api-ni.c                     | 1 -
 net/lnet/lnet/config.c                     | 1 -
 net/lnet/lnet/lib-md.c                     | 1 -
 net/lnet/lnet/lib-me.c                     | 1 -
 net/lnet/lnet/lib-move.c                   | 1 -
 net/lnet/lnet/lib-msg.c                    | 1 -
 net/lnet/lnet/lib-ptl.c                    | 1 -
 net/lnet/lnet/lo.c                         | 1 -
 net/lnet/lnet/module.c                     | 1 -
 net/lnet/lnet/nidstrings.c                 | 1 -
 net/lnet/lnet/peer.c                       | 1 -
 net/lnet/selftest/brw_test.c               | 1 -
 net/lnet/selftest/conctl.c                 | 1 -
 net/lnet/selftest/conrpc.c                 | 1 -
 net/lnet/selftest/conrpc.h                 | 1 -
 net/lnet/selftest/console.c                | 1 -
 net/lnet/selftest/console.h                | 1 -
 net/lnet/selftest/framework.c              | 1 -
 net/lnet/selftest/module.c                 | 1 -
 net/lnet/selftest/ping_test.c              | 1 -
 net/lnet/selftest/rpc.c                    | 1 -
 net/lnet/selftest/rpc.h                    | 1 -
 net/lnet/selftest/selftest.h               | 1 -
 net/lnet/selftest/timer.c                  | 1 -
 net/lnet/selftest/timer.h                  | 1 -
 37 files changed, 37 deletions(-)

diff --git a/include/uapi/linux/lnet/libcfs_debug.h b/include/uapi/linux/lnet/libcfs_debug.h
index b720e06..6b64f0e 100644
--- a/include/uapi/linux/lnet/libcfs_debug.h
+++ b/include/uapi/linux/lnet/libcfs_debug.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * libcfs/include/libcfs/libcfs_debug.h
  *
diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index 5a46a48..2c900ef 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * libcfs/include/libcfs/libcfs_ioctl.h
  *
diff --git a/include/uapi/linux/lnet/lnet-idl.h b/include/uapi/linux/lnet/lnet-idl.h
index a5b1414..1e27f3b 100644
--- a/include/uapi/linux/lnet/lnet-idl.h
+++ b/include/uapi/linux/lnet/lnet-idl.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef __UAPI_LNET_IDL_H__
diff --git a/include/uapi/linux/lnet/socklnd.h b/include/uapi/linux/lnet/socklnd.h
index 50f2a13..b5b7493 100644
--- a/include/uapi/linux/lnet/socklnd.h
+++ b/include/uapi/linux/lnet/socklnd.h
@@ -26,7 +26,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * #defines shared between socknal implementation and utilities
  */
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd-idl.h b/net/lnet/klnds/o2iblnd/o2iblnd-idl.h
index 660440c..f8972d1 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd-idl.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd-idl.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/klnds/o2iblnd/o2iblnd-idl.h
  *
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 0c43969..d670180 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/klnds/o2iblnd/o2iblnd.c
  *
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index c578673..824b204 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/klnds/o2iblnd/o2iblnd.h
  *
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index de3b42e..ec0d05a 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/klnds/o2iblnd/o2iblnd_cb.c
  *
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 029c9fb..81cde1b 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/klnds/o2iblnd/o2iblnd_modparams.c
  *
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 54c5e2c..4c79d1a 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/klnds/socklnd/socklnd.c
  *
diff --git a/net/lnet/klnds/socklnd/socklnd_lib.c b/net/lnet/klnds/socklnd/socklnd_lib.c
index 6ce5ca4..78e58f6 100644
--- a/net/lnet/klnds/socklnd/socklnd_lib.c
+++ b/net/lnet/klnds/socklnd/socklnd_lib.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #include <linux/highmem.h>
diff --git a/net/lnet/lnet/acceptor.c b/net/lnet/lnet/acceptor.c
index d326e39..b301ffa 100644
--- a/net/lnet/lnet/acceptor.c
+++ b/net/lnet/lnet/acceptor.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 27640c7..cc40040 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index ee68c63..5f4b90b 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index b3f758c..fbee4e0 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/lnet/lib-md.c
  *
diff --git a/net/lnet/lnet/lib-me.c b/net/lnet/lnet/lib-me.c
index f75f3cb1..66a79e2 100644
--- a/net/lnet/lnet/lib-me.c
+++ b/net/lnet/lnet/lib-me.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/lnet/lib-me.c
  *
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index a9399cc..896ab12 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/lnet/lib-move.c
  *
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 0a4a317..3f6cd1d 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/lnet/lib-msg.c
  *
diff --git a/net/lnet/lnet/lib-ptl.c b/net/lnet/lnet/lib-ptl.c
index 45d1be2..095b190 100644
--- a/net/lnet/lnet/lib-ptl.c
+++ b/net/lnet/lnet/lib-ptl.c
@@ -21,7 +21,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/lnet/lib-ptl.c
  *
diff --git a/net/lnet/lnet/lo.c b/net/lnet/lnet/lo.c
index 58b0ee9..4ddf1cd 100644
--- a/net/lnet/lnet/lo.c
+++ b/net/lnet/lnet/lo.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
diff --git a/net/lnet/lnet/module.c b/net/lnet/lnet/module.c
index 939c255..aba9589 100644
--- a/net/lnet/lnet/module.c
+++ b/net/lnet/lnet/module.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index cce2ae4..209da0f 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/lnet/nidstrings.c
  *
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 36e52df..0ec1460 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/lnet/peer.c
  */
diff --git a/net/lnet/selftest/brw_test.c b/net/lnet/selftest/brw_test.c
index 560bcc7..87ad765 100644
--- a/net/lnet/selftest/brw_test.c
+++ b/net/lnet/selftest/brw_test.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/selftest/brw_test.c
  *
diff --git a/net/lnet/selftest/conctl.c b/net/lnet/selftest/conctl.c
index 7e82304..b6dc4ee 100644
--- a/net/lnet/selftest/conctl.c
+++ b/net/lnet/selftest/conctl.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/selftest/conctl.c
  *
diff --git a/net/lnet/selftest/conrpc.c b/net/lnet/selftest/conrpc.c
index 6a55b23..0170219 100644
--- a/net/lnet/selftest/conrpc.c
+++ b/net/lnet/selftest/conrpc.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/selftest/conctl.c
  *
diff --git a/net/lnet/selftest/conrpc.h b/net/lnet/selftest/conrpc.h
index 180fa02..203576f 100644
--- a/net/lnet/selftest/conrpc.h
+++ b/net/lnet/selftest/conrpc.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * /lnet/selftest/conrpc.h
  *
diff --git a/net/lnet/selftest/console.c b/net/lnet/selftest/console.c
index cc2c61d..38b169f 100644
--- a/net/lnet/selftest/console.c
+++ b/net/lnet/selftest/console.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/selftest/conctl.c
  *
diff --git a/net/lnet/selftest/console.h b/net/lnet/selftest/console.h
index cd132e1..93aa515 100644
--- a/net/lnet/selftest/console.h
+++ b/net/lnet/selftest/console.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/selftest/console.h
  *
diff --git a/net/lnet/selftest/framework.c b/net/lnet/selftest/framework.c
index 00e7363..e84904e 100644
--- a/net/lnet/selftest/framework.c
+++ b/net/lnet/selftest/framework.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/selftest/framework.c
  *
diff --git a/net/lnet/selftest/module.c b/net/lnet/selftest/module.c
index 2de2b59..f6a3ec2 100644
--- a/net/lnet/selftest/module.c
+++ b/net/lnet/selftest/module.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
diff --git a/net/lnet/selftest/ping_test.c b/net/lnet/selftest/ping_test.c
index f54bd63..a0563a3 100644
--- a/net/lnet/selftest/ping_test.c
+++ b/net/lnet/selftest/ping_test.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/selftest/conctl.c
  *
diff --git a/net/lnet/selftest/rpc.c b/net/lnet/selftest/rpc.c
index d012930..7141da4 100644
--- a/net/lnet/selftest/rpc.c
+++ b/net/lnet/selftest/rpc.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/selftest/rpc.c
  *
diff --git a/net/lnet/selftest/rpc.h b/net/lnet/selftest/rpc.h
index 6d07452..2a5e317 100644
--- a/net/lnet/selftest/rpc.h
+++ b/net/lnet/selftest/rpc.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef __SELFTEST_RPC_H__
diff --git a/net/lnet/selftest/selftest.h b/net/lnet/selftest/selftest.h
index 0fe8c4f..26202c1 100644
--- a/net/lnet/selftest/selftest.h
+++ b/net/lnet/selftest/selftest.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/selftest/selftest.h
  *
diff --git a/net/lnet/selftest/timer.c b/net/lnet/selftest/timer.c
index 51ff979..ee82f87 100644
--- a/net/lnet/selftest/timer.c
+++ b/net/lnet/selftest/timer.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/selftest/timer.c
  *
diff --git a/net/lnet/selftest/timer.h b/net/lnet/selftest/timer.h
index 7f0ef9b..3abedb9 100644
--- a/net/lnet/selftest/timer.h
+++ b/net/lnet/selftest/timer.h
@@ -26,7 +26,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/selftest/timer.h
  *
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
