Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 27CCEC36001
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:12:59 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2n44xGZz1y1h;
	Fri, 21 Mar 2025 06:08:08 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2m443KYz1x9v
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:07:16 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 55EE488F93C;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 5160E106BE17; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:45 -0400
Message-ID: <20250321130711.3257092-3-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 02/27] lnet: rework module loading
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Cc: Frank Sehr <fsehr@whamcloud.com>, Chris Horn <chris.horn@hpe.com>,
 Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

The kernel IS_MODULE() only works in the positive, ie no ifndef.
So rework the LND module loading code to handle if modules are
enabled and use the proper macro. Also don't use request_module
in obdclass module as well unless IS_MODULE is true for Lustre.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12511
Lustre-commit: 6e76d3569bf602d71 ("LU-12511 lnet: rework lnd module loading")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/57946
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/obdclass/genops.c |  4 +++-
 net/lnet/lnet/api-ni.c      | 12 ++++++------
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index a3f7b59db47f..0cbc2c7c393d 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -36,6 +36,7 @@
  */
 
 #define DEBUG_SUBSYSTEM S_CLASS
+#include <linux/kconfig.h>
 #include <linux/libcfs/libcfs_cpu.h>
 #include <obd_class.h>
 #include <lustre_log.h>
@@ -97,7 +98,7 @@ static struct obd_type *class_get_type(const char *name)
 
 	rcu_read_lock();
 	type = class_search_type(name);
-
+#if IS_MODULE(CONFIG_LUSTRE_FS)
 	if (!type) {
 		const char *modname = name;
 
@@ -111,6 +112,7 @@ static struct obd_type *class_get_type(const char *name)
 		rcu_read_lock();
 		type = class_search_type(name);
 	}
+#endif
 	if (type) {
 		/*
 		 * Holding rcu_read_lock() matches the synchronize_rcu() call
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 870ae4312d78..d65ccb4e78aa 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -2556,22 +2556,22 @@ static struct lnet_lnd *lnet_load_lnd(u32 lnd_type)
 	mutex_lock(&the_lnet.ln_lnd_mutex);
 	lnd = lnet_find_lnd_by_type(lnd_type);
 	if (!lnd) {
+#if IS_MODULE(CONFIG_LNET)
 		mutex_unlock(&the_lnet.ln_lnd_mutex);
 		rc = request_module("%s", libcfs_lnd2modname(lnd_type));
 		mutex_lock(&the_lnet.ln_lnd_mutex);
 
 		lnd = lnet_find_lnd_by_type(lnd_type);
 		if (!lnd) {
-			mutex_unlock(&the_lnet.ln_lnd_mutex);
 			CERROR("Can't load LND %s, module %s, rc=%d\n",
 			       libcfs_lnd2str(lnd_type),
 			       libcfs_lnd2modname(lnd_type), rc);
-#ifndef HAVE_MODULE_LOADING_SUPPORT
-			LCONSOLE_ERROR_MSG(0x104,
-					   "Your kernel must be compiled with kernel module loading support.");
-#endif
-			return ERR_PTR(-EINVAL);
+			lnd = ERR_PTR(-EINVAL);
 		}
+#else
+		LCONSOLE_ERROR("Could not find LND %s\n", libcfs_lnd2str(lnd_type));
+		lnd = ERR_PTR(-EINVAL);
+#endif
 	}
 	mutex_unlock(&the_lnet.ln_lnd_mutex);
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
