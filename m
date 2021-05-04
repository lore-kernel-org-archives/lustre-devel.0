Return-Path: <SRS0=WSMT=J7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABCA7C43460
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:54 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6240E61185
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6240E61185
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0EF7A21F7F9;
	Mon,  3 May 2021 17:10:39 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2630621F467
 for <lustre-devel@lists.lustre.org>; Mon,  3 May 2021 17:10:24 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 30CAFEE2;
 Mon,  3 May 2021 20:10:20 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2E9898AD3C; Mon,  3 May 2021 20:10:20 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  3 May 2021 20:10:10 -0400
Message-Id: <1620087016-17857-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
References: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/14] lustre: move lu_tgt_pool out of
 obd_target.h
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

'struct lu_tgt_pool' is the only part of obd_target.h that is needed
on the client.
So move it and related declarations to lu_object.h.
Then obd_target.h does not need to be included by lu_object.h,
and it will only be included server-side;

WC-bug-id: https://jira.whamcloud.com/browse/LU-8837
Lustre-commit: 5a8dc02609ace484 ("LU-8837 lustre: move lu_tgt_pool out of obd_target.h")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41951
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h    | 18 +++++++++++++-
 fs/lustre/include/obd_target.h   | 53 ----------------------------------------
 fs/lustre/obdclass/lu_tgt_pool.c |  2 +-
 3 files changed, 18 insertions(+), 55 deletions(-)
 delete mode 100644 fs/lustre/include/obd_target.h

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 0aa28c7..a270631 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -38,7 +38,6 @@
 #include <linux/rhashtable.h>
 #include <linux/libcfs/libcfs.h>
 #include <linux/ctype.h>
-#include <obd_target.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <lu_ref.h>
 
@@ -1404,6 +1403,23 @@ struct lu_kmem_descr {
 extern u32 lu_context_tags_default;
 extern u32 lu_session_tags_default;
 
+/* Generic subset of tgts */
+struct lu_tgt_pool {
+	u32		   *op_array;	/* array of index of
+					 * lov_obd->lov_tgts
+					 */
+	unsigned int	    op_count;	/* number of tgts in the array */
+	unsigned int	    op_size;	/* allocated size of op_array */
+	struct rw_semaphore op_rw_sem;	/* to protect lu_tgt_pool use */
+};
+
+int tgt_pool_init(struct lu_tgt_pool *op, unsigned int count);
+int tgt_pool_add(struct lu_tgt_pool *op, u32 idx, unsigned int min_count);
+int tgt_pool_remove(struct lu_tgt_pool *op, u32 idx);
+int tgt_pool_free(struct lu_tgt_pool *op);
+int tgt_check_index(int idx, struct lu_tgt_pool *osts);
+int tgt_pool_extend(struct lu_tgt_pool *op, unsigned int min_count);
+
 /* bitflags used in rr / qos allocation */
 enum lq_flag {
 	LQ_DIRTY	= 0,	/* recalc qos data */
diff --git a/fs/lustre/include/obd_target.h b/fs/lustre/include/obd_target.h
deleted file mode 100644
index 5d8e8bb..0000000
--- a/fs/lustre/include/obd_target.h
+++ /dev/null
@@ -1,53 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/* GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.gnu.org/licenses/gpl-2.0.html
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2011, 2014, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- */
-
-#ifndef __OBD_TARGET_H
-#define __OBD_TARGET_H
-#include <lprocfs_status.h>
-
-/* Generic subset of tgts */
-struct lu_tgt_pool {
-	__u32		   *op_array;	/* array of index of
-					 * lov_obd->lov_tgts
-					 */
-	unsigned int	    op_count;	/* number of tgts in the array */
-	unsigned int	    op_size;	/* allocated size of op_array */
-	struct rw_semaphore op_rw_sem;	/* to protect lu_tgt_pool use */
-};
-
-int tgt_pool_init(struct lu_tgt_pool *op, unsigned int count);
-int tgt_pool_add(struct lu_tgt_pool *op, __u32 idx, unsigned int min_count);
-int tgt_pool_remove(struct lu_tgt_pool *op, __u32 idx);
-int tgt_pool_free(struct lu_tgt_pool *op);
-int tgt_check_index(int idx, struct lu_tgt_pool *osts);
-int tgt_pool_extend(struct lu_tgt_pool *op, unsigned int min_count);
-
-#endif /* __OBD_TARGET_H */
diff --git a/fs/lustre/obdclass/lu_tgt_pool.c b/fs/lustre/obdclass/lu_tgt_pool.c
index 5d8e362..a8e1028 100644
--- a/fs/lustre/obdclass/lu_tgt_pool.c
+++ b/fs/lustre/obdclass/lu_tgt_pool.c
@@ -42,8 +42,8 @@
 #define DEBUG_SUBSYSTEM S_CLASS
 
 #include <linux/libcfs/libcfs_private.h>
-#include <obd_target.h>
 #include <obd_support.h>
+#include <lu_object.h>
 
 /**
  * Initialize the pool data structures at startup.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
