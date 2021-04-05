Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEEEDC433ED
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:22 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5D51161396
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D51161396
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 014B621F6C3;
	Mon,  5 Apr 2021 00:51:20 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5FF8D21F521
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:18 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8D1906B1;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 81A2690AA9; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:30 -0400
Message-Id: <1617583870-32029-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/41] lustre: llite: data corruption due to
 RPC reordering
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
Cc: Andrew Perepechko <c17827@cray.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andrew Perepechko <c17827@cray.com>

Without read-only cache, it is possible that a client
resends a BRW RPC, receives a reply from the original
BRW RPC, modifies the same data and sends a new BRW
RPC, however, because of RPC reordering stale data
gets to disk.

Let's use range locking to protect against this race.
For Linux clients it just a simple move of the range
lock code to obdclass.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10958
Lustre-commit: 35679a730bf0b7a ("LU-10958 ofd: data corruption due to RPC reordering")
Signed-off-by: Andrew Perepechko <c17827@cray.com>
Cray-bug-id: LUS-5578,LUS-8943
Reviewed-on: https://review.whamcloud.com/32281
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/{llite => include}/range_lock.h  | 0
 fs/lustre/llite/Makefile                   | 2 +-
 fs/lustre/llite/llite_internal.h           | 2 +-
 fs/lustre/obdclass/Makefile                | 3 ++-
 fs/lustre/{llite => obdclass}/range_lock.c | 6 +++++-
 5 files changed, 9 insertions(+), 4 deletions(-)
 rename fs/lustre/{llite => include}/range_lock.h (100%)
 rename fs/lustre/{llite => obdclass}/range_lock.c (96%)

diff --git a/fs/lustre/llite/range_lock.h b/fs/lustre/include/range_lock.h
similarity index 100%
rename from fs/lustre/llite/range_lock.h
rename to fs/lustre/include/range_lock.h
diff --git a/fs/lustre/llite/Makefile b/fs/lustre/llite/Makefile
index aa388bb6..3bad19c 100644
--- a/fs/lustre/llite/Makefile
+++ b/fs/lustre/llite/Makefile
@@ -3,7 +3,7 @@ ccflags-y += -I$(srctree)/$(src)/../include
 
 obj-$(CONFIG_LUSTRE_FS) += lustre.o
 lustre-y := dcache.o dir.o file.o llite_lib.o llite_nfs.o \
-	    rw.o rw26.o namei.o symlink.o llite_mmap.o range_lock.o \
+	    rw.o rw26.o namei.o symlink.o llite_mmap.o \
 	    xattr.o xattr_cache.o xattr_security.o \
 	    super25.o statahead.o glimpse.o lcommon_cl.o lcommon_misc.o \
 	    vvp_dev.o vvp_page.o vvp_io.o vvp_object.o \
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 797dfea..0fe0b562 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -45,12 +45,12 @@
 #include <lustre_intent.h>
 #include <linux/compat.h>
 #include <lustre_crypto.h>
+#include <range_lock.h>
 #include <linux/namei.h>
 #include <linux/xattr.h>
 #include <linux/posix_acl_xattr.h>
 
 #include "vvp_internal.h"
-#include "range_lock.h"
 #include "pcc.h"
 
 /** Only used on client-side for indicating the tail of dir hash/offset. */
diff --git a/fs/lustre/obdclass/Makefile b/fs/lustre/obdclass/Makefile
index 9693a5e..de37a89 100644
--- a/fs/lustre/obdclass/Makefile
+++ b/fs/lustre/obdclass/Makefile
@@ -8,4 +8,5 @@ obdclass-y := llog.o llog_cat.o llog_obd.o llog_swab.o class_obd.o \
 	      lustre_handles.o lustre_peer.o statfs_pack.o linkea.o \
 	      obdo.o obd_config.o obd_mount.o lu_object.o lu_ref.o \
 	      cl_object.o cl_page.o cl_lock.o cl_io.o kernelcomm.o \
-	      jobid.o integrity.o obd_cksum.o lu_tgt_descs.o
+	      jobid.o integrity.o obd_cksum.o lu_tgt_descs.o \
+	      range_lock.o
diff --git a/fs/lustre/llite/range_lock.c b/fs/lustre/obdclass/range_lock.c
similarity index 96%
rename from fs/lustre/llite/range_lock.c
rename to fs/lustre/obdclass/range_lock.c
index 772b8ac..2af6385 100644
--- a/fs/lustre/llite/range_lock.c
+++ b/fs/lustre/obdclass/range_lock.c
@@ -35,8 +35,8 @@
  * Author: Bobi Jam <bobijam.xu@intel.com>
  */
 #include <linux/sched/signal.h>
-#include "range_lock.h"
 #include <uapi/linux/lustre/lustre_idl.h>
+#include <range_lock.h>
 #include <linux/libcfs/libcfs.h>
 #include <linux/interval_tree_generic.h>
 
@@ -59,6 +59,7 @@ void range_lock_tree_init(struct range_lock_tree *tree)
 	tree->rlt_sequence = 0;
 	spin_lock_init(&tree->rlt_lock);
 }
+EXPORT_SYMBOL(range_lock_tree_init);
 
 /**
  * Initialize a range lock node
@@ -86,6 +87,7 @@ int range_lock_init(struct range_lock *lock, u64 start, u64 end)
 	lock->rl_sequence = 0;
 	return 0;
 }
+EXPORT_SYMBOL(range_lock_init);
 
 /**
  * Unlock a range lock, wake up locks blocked by this lock.
@@ -117,6 +119,7 @@ void range_unlock(struct range_lock_tree *tree, struct range_lock *lock)
 
 	spin_unlock(&tree->rlt_lock);
 }
+EXPORT_SYMBOL(range_unlock);
 
 /**
  * Lock a region
@@ -167,3 +170,4 @@ int range_lock(struct range_lock_tree *tree, struct range_lock *lock)
 out:
 	return rc;
 }
+EXPORT_SYMBOL(range_lock);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
