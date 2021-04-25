Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F07AC433ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:46 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D29F4611CC
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D29F4611CC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1DA4E21F9E2;
	Sun, 25 Apr 2021 13:09:21 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E151621F80C
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:49 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 568DE10087D9;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 54E1669A64; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:36 -0400
Message-Id: <1619381316-7719-30-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 29/29] lustre: remove references to Sun
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
Lustre-commit: 83ddd179225821e5 ("LU-14487 modules: remove references to Sun Trademark.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/42139
Reviewed-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/fid/fid_internal.h          | 1 -
 fs/lustre/fid/fid_lib.c               | 1 -
 fs/lustre/fid/fid_request.c           | 1 -
 fs/lustre/fid/lproc_fid.c             | 1 -
 fs/lustre/fld/fld_cache.c             | 1 -
 fs/lustre/fld/fld_internal.h          | 1 -
 fs/lustre/fld/fld_request.c           | 1 -
 fs/lustre/fld/lproc_fld.c             | 1 -
 fs/lustre/ldlm/l_lock.c               | 1 -
 fs/lustre/ldlm/ldlm_extent.c          | 1 -
 fs/lustre/ldlm/ldlm_flock.c           | 1 -
 fs/lustre/ldlm/ldlm_inodebits.c       | 1 -
 fs/lustre/ldlm/ldlm_internal.h        | 1 -
 fs/lustre/ldlm/ldlm_lib.c             | 1 -
 fs/lustre/ldlm/ldlm_lock.c            | 1 -
 fs/lustre/ldlm/ldlm_lockd.c           | 1 -
 fs/lustre/ldlm/ldlm_plain.c           | 1 -
 fs/lustre/ldlm/ldlm_pool.c            | 1 -
 fs/lustre/ldlm/ldlm_request.c         | 1 -
 fs/lustre/ldlm/ldlm_resource.c        | 1 -
 fs/lustre/llite/acl.c                 | 1 -
 fs/lustre/llite/dcache.c              | 1 -
 fs/lustre/llite/dir.c                 | 1 -
 fs/lustre/llite/file.c                | 1 -
 fs/lustre/llite/glimpse.c             | 1 -
 fs/lustre/llite/lcommon_cl.c          | 1 -
 fs/lustre/llite/lcommon_misc.c        | 1 -
 fs/lustre/llite/llite_internal.h      | 1 -
 fs/lustre/llite/llite_lib.c           | 1 -
 fs/lustre/llite/llite_mmap.c          | 1 -
 fs/lustre/llite/llite_nfs.c           | 1 -
 fs/lustre/llite/lproc_llite.c         | 1 -
 fs/lustre/llite/namei.c               | 1 -
 fs/lustre/llite/rw.c                  | 1 -
 fs/lustre/llite/rw26.c                | 1 -
 fs/lustre/llite/statahead.c           | 1 -
 fs/lustre/llite/super25.c             | 1 -
 fs/lustre/llite/symlink.c             | 1 -
 fs/lustre/llite/vvp_dev.c             | 1 -
 fs/lustre/llite/vvp_internal.h        | 1 -
 fs/lustre/llite/vvp_io.c              | 1 -
 fs/lustre/llite/vvp_object.c          | 1 -
 fs/lustre/llite/vvp_page.c            | 1 -
 fs/lustre/llite/xattr.c               | 1 -
 fs/lustre/lmv/lmv_fld.c               | 1 -
 fs/lustre/lmv/lmv_intent.c            | 1 -
 fs/lustre/lmv/lmv_internal.h          | 1 -
 fs/lustre/lmv/lmv_obd.c               | 1 -
 fs/lustre/lmv/lproc_lmv.c             | 1 -
 fs/lustre/lov/lov_cl_internal.h       | 2 --
 fs/lustre/lov/lov_dev.c               | 1 -
 fs/lustre/lov/lov_ea.c                | 1 -
 fs/lustre/lov/lov_internal.h          | 1 -
 fs/lustre/lov/lov_io.c                | 1 -
 fs/lustre/lov/lov_lock.c              | 1 -
 fs/lustre/lov/lov_merge.c             | 1 -
 fs/lustre/lov/lov_obd.c               | 1 -
 fs/lustre/lov/lov_object.c            | 1 -
 fs/lustre/lov/lov_offset.c            | 1 -
 fs/lustre/lov/lov_pack.c              | 1 -
 fs/lustre/lov/lov_page.c              | 1 -
 fs/lustre/lov/lov_pool.c              | 1 -
 fs/lustre/lov/lov_request.c           | 1 -
 fs/lustre/lov/lovsub_dev.c            | 1 -
 fs/lustre/lov/lovsub_object.c         | 1 -
 fs/lustre/lov/lproc_lov.c             | 1 -
 fs/lustre/mdc/lproc_mdc.c             | 1 -
 fs/lustre/mdc/mdc_internal.h          | 1 -
 fs/lustre/mdc/mdc_lib.c               | 1 -
 fs/lustre/mdc/mdc_locks.c             | 1 -
 fs/lustre/mdc/mdc_reint.c             | 1 -
 fs/lustre/mdc/mdc_request.c           | 1 -
 fs/lustre/mgc/lproc_mgc.c             | 1 -
 fs/lustre/mgc/mgc_internal.h          | 1 -
 fs/lustre/mgc/mgc_request.c           | 1 -
 fs/lustre/obdclass/cl_internal.h      | 1 -
 fs/lustre/obdclass/cl_io.c            | 1 -
 fs/lustre/obdclass/cl_lock.c          | 1 -
 fs/lustre/obdclass/cl_object.c        | 1 -
 fs/lustre/obdclass/cl_page.c          | 1 -
 fs/lustre/obdclass/class_obd.c        | 1 -
 fs/lustre/obdclass/genops.c           | 1 -
 fs/lustre/obdclass/kernelcomm.c       | 1 -
 fs/lustre/obdclass/llog.c             | 1 -
 fs/lustre/obdclass/llog_cat.c         | 1 -
 fs/lustre/obdclass/llog_internal.h    | 1 -
 fs/lustre/obdclass/llog_obd.c         | 1 -
 fs/lustre/obdclass/llog_swab.c        | 1 -
 fs/lustre/obdclass/lprocfs_counters.c | 1 -
 fs/lustre/obdclass/lprocfs_status.c   | 1 -
 fs/lustre/obdclass/lu_object.c        | 1 -
 fs/lustre/obdclass/lu_ref.c           | 1 -
 fs/lustre/obdclass/lu_tgt_pool.c      | 2 --
 fs/lustre/obdclass/lustre_handles.c   | 1 -
 fs/lustre/obdclass/lustre_peer.c      | 1 -
 fs/lustre/obdclass/obd_config.c       | 1 -
 fs/lustre/obdclass/obd_mount.c        | 1 -
 fs/lustre/obdclass/obd_sysfs.c        | 1 -
 fs/lustre/obdclass/obdo.c             | 1 -
 fs/lustre/obdclass/statfs_pack.c      | 1 -
 fs/lustre/obdecho/debug.c             | 1 -
 fs/lustre/obdecho/echo_client.c       | 1 -
 fs/lustre/obdecho/echo_internal.h     | 1 -
 fs/lustre/osc/lproc_osc.c             | 1 -
 fs/lustre/osc/osc_cache.c             | 1 -
 fs/lustre/osc/osc_dev.c               | 1 -
 fs/lustre/osc/osc_internal.h          | 1 -
 fs/lustre/osc/osc_io.c                | 1 -
 fs/lustre/osc/osc_lock.c              | 1 -
 fs/lustre/osc/osc_object.c            | 1 -
 fs/lustre/osc/osc_page.c              | 1 -
 fs/lustre/osc/osc_request.c           | 1 -
 fs/lustre/ptlrpc/client.c             | 1 -
 fs/lustre/ptlrpc/connection.c         | 1 -
 fs/lustre/ptlrpc/events.c             | 1 -
 fs/lustre/ptlrpc/import.c             | 1 -
 fs/lustre/ptlrpc/layout.c             | 1 -
 fs/lustre/ptlrpc/llog_client.c        | 1 -
 fs/lustre/ptlrpc/llog_net.c           | 1 -
 fs/lustre/ptlrpc/lproc_ptlrpc.c       | 1 -
 fs/lustre/ptlrpc/niobuf.c             | 1 -
 fs/lustre/ptlrpc/pack_generic.c       | 1 -
 fs/lustre/ptlrpc/pers.c               | 1 -
 fs/lustre/ptlrpc/pinger.c             | 1 -
 fs/lustre/ptlrpc/ptlrpc_internal.h    | 1 -
 fs/lustre/ptlrpc/ptlrpc_module.c      | 1 -
 fs/lustre/ptlrpc/ptlrpcd.c            | 1 -
 fs/lustre/ptlrpc/recover.c            | 1 -
 fs/lustre/ptlrpc/sec.c                | 1 -
 fs/lustre/ptlrpc/sec_bulk.c           | 1 -
 fs/lustre/ptlrpc/sec_config.c         | 1 -
 fs/lustre/ptlrpc/sec_gc.c             | 1 -
 fs/lustre/ptlrpc/sec_lproc.c          | 1 -
 fs/lustre/ptlrpc/sec_null.c           | 1 -
 fs/lustre/ptlrpc/sec_plain.c          | 1 -
 fs/lustre/ptlrpc/service.c            | 1 -
 fs/lustre/ptlrpc/wiretest.c           | 1 -
 137 files changed, 139 deletions(-)

diff --git a/fs/lustre/fid/fid_internal.h b/fs/lustre/fid/fid_internal.h
index cbf0987..5256e87 100644
--- a/fs/lustre/fid/fid_internal.h
+++ b/fs/lustre/fid/fid_internal.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/fid/fid_internal.h
  *
diff --git a/fs/lustre/fid/fid_lib.c b/fs/lustre/fid/fid_lib.c
index 6b06847..dc1537d 100644
--- a/fs/lustre/fid/fid_lib.c
+++ b/fs/lustre/fid/fid_lib.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/fid/fid_lib.c
  *
diff --git a/fs/lustre/fid/fid_request.c b/fs/lustre/fid/fid_request.c
index a7013d1..c41932f 100644
--- a/fs/lustre/fid/fid_request.c
+++ b/fs/lustre/fid/fid_request.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/fid/fid_request.c
  *
diff --git a/fs/lustre/fid/lproc_fid.c b/fs/lustre/fid/lproc_fid.c
index be9846b..8f6a4a8 100644
--- a/fs/lustre/fid/lproc_fid.c
+++ b/fs/lustre/fid/lproc_fid.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/fid/lproc_fid.c
  *
diff --git a/fs/lustre/fld/fld_cache.c b/fs/lustre/fld/fld_cache.c
index f288907..f64ae65 100644
--- a/fs/lustre/fld/fld_cache.c
+++ b/fs/lustre/fld/fld_cache.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/fld/fld_cache.c
  *
diff --git a/fs/lustre/fld/fld_internal.h b/fs/lustre/fld/fld_internal.h
index d32360c..83c3a3e 100644
--- a/fs/lustre/fld/fld_internal.h
+++ b/fs/lustre/fld/fld_internal.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/fld/fld_internal.h
  *
diff --git a/fs/lustre/fld/fld_request.c b/fs/lustre/fld/fld_request.c
index 2e8d0b8..7260a14 100644
--- a/fs/lustre/fld/fld_request.c
+++ b/fs/lustre/fld/fld_request.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/fld/fld_request.c
  *
diff --git a/fs/lustre/fld/lproc_fld.c b/fs/lustre/fld/lproc_fld.c
index 9e1be53..e53cc08 100644
--- a/fs/lustre/fld/lproc_fld.c
+++ b/fs/lustre/fld/lproc_fld.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/fld/lproc_fld.c
  *
diff --git a/fs/lustre/ldlm/l_lock.c b/fs/lustre/ldlm/l_lock.c
index 3531420..639a72a 100644
--- a/fs/lustre/ldlm/l_lock.c
+++ b/fs/lustre/ldlm/l_lock.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LDLM
diff --git a/fs/lustre/ldlm/ldlm_extent.c b/fs/lustre/ldlm/ldlm_extent.c
index 7474c85..4533bdb 100644
--- a/fs/lustre/ldlm/ldlm_extent.c
+++ b/fs/lustre/ldlm/ldlm_extent.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ldlm/ldlm_extent.c
  *
diff --git a/fs/lustre/ldlm/ldlm_flock.c b/fs/lustre/ldlm/ldlm_flock.c
index b4916cb15..4ca69f8 100644
--- a/fs/lustre/ldlm/ldlm_flock.c
+++ b/fs/lustre/ldlm/ldlm_flock.c
@@ -32,7 +32,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 /**
diff --git a/fs/lustre/ldlm/ldlm_inodebits.c b/fs/lustre/ldlm/ldlm_inodebits.c
index 32de9b9..892a0dd 100644
--- a/fs/lustre/ldlm/ldlm_inodebits.c
+++ b/fs/lustre/ldlm/ldlm_inodebits.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ldlm/ldlm_inodebits.c
  *
diff --git a/fs/lustre/ldlm/ldlm_internal.h b/fs/lustre/ldlm/ldlm_internal.h
index 9dc0561..ed4fb2a 100644
--- a/fs/lustre/ldlm/ldlm_internal.h
+++ b/fs/lustre/ldlm/ldlm_internal.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 extern int ldlm_srv_namespace_nr;
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 9499995..c5ee2c3 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 /**
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 8201e28..4225c0b 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ldlm/ldlm_lock.c
  *
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 7d8bae2..04fe92e 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ldlm/ldlm_lockd.c
  *
diff --git a/fs/lustre/ldlm/ldlm_plain.c b/fs/lustre/ldlm/ldlm_plain.c
index e7357ee..e70597c 100644
--- a/fs/lustre/ldlm/ldlm_plain.c
+++ b/fs/lustre/ldlm/ldlm_plain.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ldlm/ldlm_plain.c
  *
diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
index b93ad4d..155b585 100644
--- a/fs/lustre/ldlm/ldlm_pool.c
+++ b/fs/lustre/ldlm/ldlm_pool.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ldlm/ldlm_pool.c
  *
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 3527678..7718e07 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 /**
  * This file contains Asynchronous System Trap (AST) handlers and related
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index 6e3feb2..d4b6e41 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ldlm/ldlm_resource.c
  *
diff --git a/fs/lustre/llite/acl.c b/fs/lustre/llite/acl.c
index 2ee9ff9..f4cc149 100644
--- a/fs/lustre/llite/acl.c
+++ b/fs/lustre/llite/acl.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/llite/acl.c
  */
diff --git a/fs/lustre/llite/dcache.c b/fs/lustre/llite/dcache.c
index 0a6d773..cf6619f 100644
--- a/fs/lustre/llite/dcache.c
+++ b/fs/lustre/llite/dcache.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #include <linux/fs.h>
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 21b40d1..bf2d9fe 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/llite/dir.c
  *
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index c8f250c..1561af1 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/llite/file.c
  *
diff --git a/fs/lustre/llite/glimpse.c b/fs/lustre/llite/glimpse.c
index 3d23612..c55d079 100644
--- a/fs/lustre/llite/glimpse.c
+++ b/fs/lustre/llite/glimpse.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * glimpse code used by vvp (and other Lustre clients in the future).
  *
diff --git a/fs/lustre/llite/lcommon_cl.c b/fs/lustre/llite/lcommon_cl.c
index c945351..f0d8f78 100644
--- a/fs/lustre/llite/lcommon_cl.c
+++ b/fs/lustre/llite/lcommon_cl.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  *   Author: Nikita Danilov <nikita.danilov@sun.com>
  */
diff --git a/fs/lustre/llite/lcommon_misc.c b/fs/lustre/llite/lcommon_misc.c
index d833a16..3b0c0f4 100644
--- a/fs/lustre/llite/lcommon_misc.c
+++ b/fs/lustre/llite/lcommon_misc.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * cl code used by vvp (and other Lustre clients in the future).
  *
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index dc9ea03..669500b 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef LLITE_INTERNAL_H
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 6af95fd..f520b34 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/llite/llite_lib.c
  *
diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index 0963757..a234a83 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #include <linux/kernel.h>
diff --git a/fs/lustre/llite/llite_nfs.c b/fs/lustre/llite/llite_nfs.c
index a57ab51..bf15023 100644
--- a/fs/lustre/llite/llite_nfs.c
+++ b/fs/lustre/llite/llite_nfs.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/lustre/llite/llite_nfs.c
  *
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 4ce6fab..3ca553d 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 #define DEBUG_SUBSYSTEM S_LLITE
 
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 654d065..7f1fd5c 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #include <linux/fs.h>
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index c64696d..08ab25d 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/llite/rw.c
  *
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 91a05ac..74f3b0b 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/lustre/llite/rw26.c
  *
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index a7d3a43..995a9e1 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #include <linux/fs.h>
diff --git a/fs/lustre/llite/super25.c b/fs/lustre/llite/super25.c
index 1b074a6..decfa2f 100644
--- a/fs/lustre/llite/super25.c
+++ b/fs/lustre/llite/super25.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LLITE
diff --git a/fs/lustre/llite/symlink.c b/fs/lustre/llite/symlink.c
index aae449c..f78db86 100644
--- a/fs/lustre/llite/symlink.c
+++ b/fs/lustre/llite/symlink.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #include <linux/fs.h>
diff --git a/fs/lustre/llite/vvp_dev.c b/fs/lustre/llite/vvp_dev.c
index aa8b2c5..fdcd314 100644
--- a/fs/lustre/llite/vvp_dev.c
+++ b/fs/lustre/llite/vvp_dev.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * cl_device and cl_device_type implementation for VVP layer.
  *
diff --git a/fs/lustre/llite/vvp_internal.h b/fs/lustre/llite/vvp_internal.h
index 6956d6b..f2599be 100644
--- a/fs/lustre/llite/vvp_internal.h
+++ b/fs/lustre/llite/vvp_internal.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Internal definitions for VVP layer.
  *
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 38a9430..e98792b 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Implementation of cl_io for VVP layer.
  *
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index 0c40814..e999caa 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * cl_object implementation for VVP layer.
  *
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index b0a119e..86353df 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Implementation of cl_page for VVP layer.
  *
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 7004893..cd973eb 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #include <linux/fs.h>
diff --git a/fs/lustre/lmv/lmv_fld.c b/fs/lustre/lmv/lmv_fld.c
index ea1ef72..8acad7a 100644
--- a/fs/lustre/lmv/lmv_fld.c
+++ b/fs/lustre/lmv/lmv_fld.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LMV
diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 2a15ec2..398bd17 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LMV
diff --git a/fs/lustre/lmv/lmv_internal.h b/fs/lustre/lmv/lmv_internal.h
index e42b141..9e89f88 100644
--- a/fs/lustre/lmv/lmv_internal.h
+++ b/fs/lustre/lmv/lmv_internal.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef _LMV_INTERNAL_H_
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 6555c6e..4fa441e 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LMV
diff --git a/fs/lustre/lmv/lproc_lmv.c b/fs/lustre/lmv/lproc_lmv.c
index 85963d2..767b40e 100644
--- a/fs/lustre/lmv/lproc_lmv.c
+++ b/fs/lustre/lmv/lproc_lmv.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_CLASS
diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index f231be9..7fcc327 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -28,11 +28,9 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Internal interfaces of LOV layer.
  *
diff --git a/fs/lustre/lov/lov_dev.c b/fs/lustre/lov/lov_dev.c
index a4e6b91..e001e68 100644
--- a/fs/lustre/lov/lov_dev.c
+++ b/fs/lustre/lov/lov_dev.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Implementation of cl_device and cl_device_type for LOV layer.
  *
diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
index f6b3df0..d2171a3 100644
--- a/fs/lustre/lov/lov_ea.c
+++ b/fs/lustre/lov/lov_ea.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/lov/lov_ea.c
  *
diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index e58235a..8c0b6fa 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef LOV_INTERNAL_H
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 1d5ea41..86e3fbd 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Implementation of cl_io for LOV layer.
  *
diff --git a/fs/lustre/lov/lov_lock.c b/fs/lustre/lov/lov_lock.c
index c79f728..efaca37 100644
--- a/fs/lustre/lov/lov_lock.c
+++ b/fs/lustre/lov/lov_lock.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Implementation of cl_lock for LOV layer.
  *
diff --git a/fs/lustre/lov/lov_merge.c b/fs/lustre/lov/lov_merge.c
index 7728630..8800c5f 100644
--- a/fs/lustre/lov/lov_merge.c
+++ b/fs/lustre/lov/lov_merge.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LOV
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 20e0be0..42a137d 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/lov/lov_obd.c
  *
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index db4070f..ee61983 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Implementation of cl_object for LOV layer.
  *
diff --git a/fs/lustre/lov/lov_offset.c b/fs/lustre/lov/lov_offset.c
index 2493331..73c3f1b 100644
--- a/fs/lustre/lov/lov_offset.c
+++ b/fs/lustre/lov/lov_offset.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LOV
diff --git a/fs/lustre/lov/lov_pack.c b/fs/lustre/lov/lov_pack.c
index c97093e..9b5fb9c 100644
--- a/fs/lustre/lov/lov_pack.c
+++ b/fs/lustre/lov/lov_pack.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/lov/lov_pack.c
  *
diff --git a/fs/lustre/lov/lov_page.c b/fs/lustre/lov/lov_page.c
index da036f2..fdc415b 100644
--- a/fs/lustre/lov/lov_page.c
+++ b/fs/lustre/lov/lov_page.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Implementation of cl_page for LOV layer.
  *
diff --git a/fs/lustre/lov/lov_pool.c b/fs/lustre/lov/lov_pool.c
index 8fbc6ee..d01c475 100644
--- a/fs/lustre/lov/lov_pool.c
+++ b/fs/lustre/lov/lov_pool.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/lov/lov_pool.c
  *
diff --git a/fs/lustre/lov/lov_request.c b/fs/lustre/lov/lov_request.c
index d263cec..0ae53a7 100644
--- a/fs/lustre/lov/lov_request.c
+++ b/fs/lustre/lov/lov_request.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LOV
diff --git a/fs/lustre/lov/lovsub_dev.c b/fs/lustre/lov/lovsub_dev.c
index 0555737..a0eeb06 100644
--- a/fs/lustre/lov/lovsub_dev.c
+++ b/fs/lustre/lov/lovsub_dev.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Implementation of cl_device and cl_device_type for LOVSUB layer.
  *
diff --git a/fs/lustre/lov/lovsub_object.c b/fs/lustre/lov/lovsub_object.c
index eef1713..672ea3b 100644
--- a/fs/lustre/lov/lovsub_object.c
+++ b/fs/lustre/lov/lovsub_object.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Implementation of cl_object for LOVSUB layer.
  *
diff --git a/fs/lustre/lov/lproc_lov.c b/fs/lustre/lov/lproc_lov.c
index e95a907..95fb4ef 100644
--- a/fs/lustre/lov/lproc_lov.c
+++ b/fs/lustre/lov/lproc_lov.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 #define DEBUG_SUBSYSTEM S_CLASS
 
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index af2b725..02636ef 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 #define DEBUG_SUBSYSTEM S_CLASS
 
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index 91e8240..06b0637 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef _MDC_INTERNAL_H
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index 69261b2..37fcb38 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_MDC
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index dbf402a..5373ec9 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_MDC
diff --git a/fs/lustre/mdc/mdc_reint.c b/fs/lustre/mdc/mdc_reint.c
index 9e566e7..786b23d 100644
--- a/fs/lustre/mdc/mdc_reint.c
+++ b/fs/lustre/mdc/mdc_reint.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_MDC
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index fb9971f..e6c0df5 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_MDC
diff --git a/fs/lustre/mgc/lproc_mgc.c b/fs/lustre/mgc/lproc_mgc.c
index dd7ed0f..6a945c5 100644
--- a/fs/lustre/mgc/lproc_mgc.c
+++ b/fs/lustre/mgc/lproc_mgc.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 #define DEBUG_SUBSYSTEM S_CLASS
 
diff --git a/fs/lustre/mgc/mgc_internal.h b/fs/lustre/mgc/mgc_internal.h
index 7a6e77b..e323f90 100644
--- a/fs/lustre/mgc/mgc_internal.h
+++ b/fs/lustre/mgc/mgc_internal.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef _MGC_INTERNAL_H
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 4b60056a..c2ad5d3 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/mgc/mgc_request.c
  *
diff --git a/fs/lustre/obdclass/cl_internal.h b/fs/lustre/obdclass/cl_internal.h
index 64a5ab2..db9dd98 100644
--- a/fs/lustre/obdclass/cl_internal.h
+++ b/fs/lustre/obdclass/cl_internal.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Internal cl interfaces.
  *
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index ca4d387..6c22137 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Client IO.
  *
diff --git a/fs/lustre/obdclass/cl_lock.c b/fs/lustre/obdclass/cl_lock.c
index 0c02546..9617764 100644
--- a/fs/lustre/obdclass/cl_lock.c
+++ b/fs/lustre/obdclass/cl_lock.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Client Extent Lock.
  *
diff --git a/fs/lustre/obdclass/cl_object.c b/fs/lustre/obdclass/cl_object.c
index aa3d928..c5deb5c 100644
--- a/fs/lustre/obdclass/cl_object.c
+++ b/fs/lustre/obdclass/cl_object.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Client Lustre Object.
  *
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 2cf8d30..4b6386c 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Client Lustre Page.
  *
diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index 38b8967..b30d941 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_CLASS
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 7bc4dab..bbb63b2 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/genops.c
  *
diff --git a/fs/lustre/obdclass/kernelcomm.c b/fs/lustre/obdclass/kernelcomm.c
index bc9b0f2..e59b6aa 100644
--- a/fs/lustre/obdclass/kernelcomm.c
+++ b/fs/lustre/obdclass/kernelcomm.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Author: Nathan Rutman <nathan.rutman@sun.com>
  *
diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index b431087..c342734 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/llog.c
  *
diff --git a/fs/lustre/obdclass/llog_cat.c b/fs/lustre/obdclass/llog_cat.c
index b67e7a2b..7f55895 100644
--- a/fs/lustre/obdclass/llog_cat.c
+++ b/fs/lustre/obdclass/llog_cat.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/llog_cat.c
  *
diff --git a/fs/lustre/obdclass/llog_internal.h b/fs/lustre/obdclass/llog_internal.h
index 41ac4f0..7a10389 100644
--- a/fs/lustre/obdclass/llog_internal.h
+++ b/fs/lustre/obdclass/llog_internal.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef __LLOG_INTERNAL_H__
diff --git a/fs/lustre/obdclass/llog_obd.c b/fs/lustre/obdclass/llog_obd.c
index 82f96ed..4743dc9 100644
--- a/fs/lustre/obdclass/llog_obd.c
+++ b/fs/lustre/obdclass/llog_obd.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_LOG
diff --git a/fs/lustre/obdclass/llog_swab.c b/fs/lustre/obdclass/llog_swab.c
index c18ca95..0b83dc3 100644
--- a/fs/lustre/obdclass/llog_swab.c
+++ b/fs/lustre/obdclass/llog_swab.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/llog_swab.c
  *
diff --git a/fs/lustre/obdclass/lprocfs_counters.c b/fs/lustre/obdclass/lprocfs_counters.c
index c7bf1ee..55cb12c 100644
--- a/fs/lustre/obdclass/lprocfs_counters.c
+++ b/fs/lustre/obdclass/lprocfs_counters.c
@@ -29,7 +29,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/lprocfs_counters.c
  *
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 0ed1bd5..cd5a2fa 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/lprocfs_status.c
  *
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index 419cb74..b49e0cd 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/lu_object.c
  *
diff --git a/fs/lustre/obdclass/lu_ref.c b/fs/lustre/obdclass/lu_ref.c
index 9b32c3c..fd7ac39 100644
--- a/fs/lustre/obdclass/lu_ref.c
+++ b/fs/lustre/obdclass/lu_ref.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/lu_ref.c
  *
diff --git a/fs/lustre/obdclass/lu_tgt_pool.c b/fs/lustre/obdclass/lu_tgt_pool.c
index fc5e298..5d8e362 100644
--- a/fs/lustre/obdclass/lu_tgt_pool.c
+++ b/fs/lustre/obdclass/lu_tgt_pool.c
@@ -21,14 +21,12 @@
  * GPL HEADER END
  */
 /*
- * Copyright  2008 Sun Microsystems, Inc. All rights reserved
  * Use is subject to license terms.
  *
  * Copyright (c) 2012, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 /*
  * lustre/target/tgt_pool.c
diff --git a/fs/lustre/obdclass/lustre_handles.c b/fs/lustre/obdclass/lustre_handles.c
index 7ecd15ad3..16099a4 100644
--- a/fs/lustre/obdclass/lustre_handles.c
+++ b/fs/lustre/obdclass/lustre_handles.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/lustre_handles.c
  *
diff --git a/fs/lustre/obdclass/lustre_peer.c b/fs/lustre/obdclass/lustre_peer.c
index 2675594..c0a0bfb 100644
--- a/fs/lustre/obdclass/lustre_peer.c
+++ b/fs/lustre/obdclass/lustre_peer.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 8f062bb..3a0dbd5 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/obd_config.c
  *
diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index ea5b469..fbad459 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/obd_mount.c
  *
diff --git a/fs/lustre/obdclass/obd_sysfs.c b/fs/lustre/obdclass/obd_sysfs.c
index e6fb1b9..43bbbe9 100644
--- a/fs/lustre/obdclass/obd_sysfs.c
+++ b/fs/lustre/obdclass/obd_sysfs.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/linux/linux-module.c
  *
diff --git a/fs/lustre/obdclass/obdo.c b/fs/lustre/obdclass/obdo.c
index 8fd2922..7df4ff3 100644
--- a/fs/lustre/obdclass/obdo.c
+++ b/fs/lustre/obdclass/obdo.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/obdo.c
  *
diff --git a/fs/lustre/obdclass/statfs_pack.c b/fs/lustre/obdclass/statfs_pack.c
index 355e888..e1d1f56 100644
--- a/fs/lustre/obdclass/statfs_pack.c
+++ b/fs/lustre/obdclass/statfs_pack.c
@@ -26,7 +26,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/statfs_pack.c
  *
diff --git a/fs/lustre/obdecho/debug.c b/fs/lustre/obdecho/debug.c
index 130d3bf..df30035 100644
--- a/fs/lustre/obdecho/debug.c
+++ b/fs/lustre/obdecho/debug.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdclass/debug.c
  *
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 270226b..0452942 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_ECHO
diff --git a/fs/lustre/obdecho/echo_internal.h b/fs/lustre/obdecho/echo_internal.h
index 95b0149..5736b17 100644
--- a/fs/lustre/obdecho/echo_internal.h
+++ b/fs/lustre/obdecho/echo_internal.h
@@ -24,7 +24,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/obdecho/echo_internal.h
  */
diff --git a/fs/lustre/osc/lproc_osc.c b/fs/lustre/osc/lproc_osc.c
index df48c76..3991b2c 100644
--- a/fs/lustre/osc/lproc_osc.c
+++ b/fs/lustre/osc/lproc_osc.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 #define DEBUG_SUBSYSTEM S_CLASS
 
diff --git a/fs/lustre/osc/osc_cache.c b/fs/lustre/osc/osc_cache.c
index e85f320..fc8079a 100644
--- a/fs/lustre/osc/osc_cache.c
+++ b/fs/lustre/osc/osc_cache.c
@@ -29,7 +29,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * osc cache management.
  *
diff --git a/fs/lustre/osc/osc_dev.c b/fs/lustre/osc/osc_dev.c
index 6469973..621beb6 100644
--- a/fs/lustre/osc/osc_dev.c
+++ b/fs/lustre/osc/osc_dev.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Implementation of cl_device, for OSC layer.
  *
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index fc3ca8a..3b65f2d 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #ifndef OSC_INTERNAL_H
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index ce64cf8..b792c22 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Implementation of cl_io for OSC layer.
  *
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 6ff3fb6..de96fc0 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Implementation of cl_lock for OSC layer.
  *
diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index 00f2800..8f36789 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Implementation of cl_object for OSC layer.
  *
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 8b25329a..94db9d2 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * Implementation of cl_page for OSC layer.
  *
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 376afb9..e49d73f 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_OSC
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index a818b01..97f1251 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 /** Implementation of client-side PortalRPC interfaces */
diff --git a/fs/lustre/ptlrpc/connection.c b/fs/lustre/ptlrpc/connection.c
index 1551a9a..0415357 100644
--- a/fs/lustre/ptlrpc/connection.c
+++ b/fs/lustre/ptlrpc/connection.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index e348e4a..c81181d 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index 5e33ebc..317f28c 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ptlrpc/import.c
  *
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 11c0d50..8bbe68b 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ptlrpc/layout.c
  *
diff --git a/fs/lustre/ptlrpc/llog_client.c b/fs/lustre/ptlrpc/llog_client.c
index 8bbff60..aa4a808 100644
--- a/fs/lustre/ptlrpc/llog_client.c
+++ b/fs/lustre/ptlrpc/llog_client.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ptlrpc/llog_client.c
  *
diff --git a/fs/lustre/ptlrpc/llog_net.c b/fs/lustre/ptlrpc/llog_net.c
index 1d86fb3..0090d00 100644
--- a/fs/lustre/ptlrpc/llog_net.c
+++ b/fs/lustre/ptlrpc/llog_net.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ptlrpc/llog_net.c
  *
diff --git a/fs/lustre/ptlrpc/lproc_ptlrpc.c b/fs/lustre/ptlrpc/lproc_ptlrpc.c
index 26ca55e..b291374 100644
--- a/fs/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/fs/lustre/ptlrpc/lproc_ptlrpc.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 #define DEBUG_SUBSYSTEM S_CLASS
 
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 5ae7dd1..cf9940b 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index fbed952..5dbab3d 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ptlrpc/pack_generic.c
  *
diff --git a/fs/lustre/ptlrpc/pers.c b/fs/lustre/ptlrpc/pers.c
index 78b8ce2..e24c8e3 100644
--- a/fs/lustre/ptlrpc/pers.c
+++ b/fs/lustre/ptlrpc/pers.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
diff --git a/fs/lustre/ptlrpc/pinger.c b/fs/lustre/ptlrpc/pinger.c
index 99d077b..f565982 100644
--- a/fs/lustre/ptlrpc/pinger.c
+++ b/fs/lustre/ptlrpc/pinger.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ptlrpc/pinger.c
  *
diff --git a/fs/lustre/ptlrpc/ptlrpc_internal.h b/fs/lustre/ptlrpc/ptlrpc_internal.h
index 248f9cb..62c3c97 100644
--- a/fs/lustre/ptlrpc/ptlrpc_internal.h
+++ b/fs/lustre/ptlrpc/ptlrpc_internal.h
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 /* Intramodule declarations for ptlrpc. */
diff --git a/fs/lustre/ptlrpc/ptlrpc_module.c b/fs/lustre/ptlrpc/ptlrpc_module.c
index 85fb0fa..8379bc4 100644
--- a/fs/lustre/ptlrpc/ptlrpc_module.c
+++ b/fs/lustre/ptlrpc/ptlrpc_module.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
diff --git a/fs/lustre/ptlrpc/ptlrpcd.c b/fs/lustre/ptlrpc/ptlrpcd.c
index ef24b0e..ed3f0e1 100644
--- a/fs/lustre/ptlrpc/ptlrpcd.c
+++ b/fs/lustre/ptlrpc/ptlrpcd.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ptlrpc/ptlrpcd.c
  */
diff --git a/fs/lustre/ptlrpc/recover.c b/fs/lustre/ptlrpc/recover.c
index 104af56..6ba31c1 100644
--- a/fs/lustre/ptlrpc/recover.c
+++ b/fs/lustre/ptlrpc/recover.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ptlrpc/recover.c
  *
diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index ea1dafe..c65cf89 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ptlrpc/sec.c
  *
diff --git a/fs/lustre/ptlrpc/sec_bulk.c b/fs/lustre/ptlrpc/sec_bulk.c
index ef127b8..b6ae77b 100644
--- a/fs/lustre/ptlrpc/sec_bulk.c
+++ b/fs/lustre/ptlrpc/sec_bulk.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ptlrpc/sec_bulk.c
  *
diff --git a/fs/lustre/ptlrpc/sec_config.c b/fs/lustre/ptlrpc/sec_config.c
index d9e3520..d44af0f 100644
--- a/fs/lustre/ptlrpc/sec_config.c
+++ b/fs/lustre/ptlrpc/sec_config.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_SEC
diff --git a/fs/lustre/ptlrpc/sec_gc.c b/fs/lustre/ptlrpc/sec_gc.c
index 36ac319..bc76323 100644
--- a/fs/lustre/ptlrpc/sec_gc.c
+++ b/fs/lustre/ptlrpc/sec_gc.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ptlrpc/sec_gc.c
  *
diff --git a/fs/lustre/ptlrpc/sec_lproc.c b/fs/lustre/ptlrpc/sec_lproc.c
index 94f77350..8dfbb77 100644
--- a/fs/lustre/ptlrpc/sec_lproc.c
+++ b/fs/lustre/ptlrpc/sec_lproc.c
@@ -26,7 +26,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ptlrpc/sec_lproc.c
  *
diff --git a/fs/lustre/ptlrpc/sec_null.c b/fs/lustre/ptlrpc/sec_null.c
index 3892d6e..cf8f24b 100644
--- a/fs/lustre/ptlrpc/sec_null.c
+++ b/fs/lustre/ptlrpc/sec_null.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ptlrpc/sec_null.c
  *
diff --git a/fs/lustre/ptlrpc/sec_plain.c b/fs/lustre/ptlrpc/sec_plain.c
index 80831af..7920ab0 100644
--- a/fs/lustre/ptlrpc/sec_plain.c
+++ b/fs/lustre/ptlrpc/sec_plain.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lustre/ptlrpc/sec_plain.c
  *
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 1057892..3d9192d 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index a500a87..71f9e32 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -28,7 +28,6 @@
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
  */
 
 #define DEBUG_SUBSYSTEM S_RPC
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
