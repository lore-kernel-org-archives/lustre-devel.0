Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DA684C36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:15:31 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2nM6Smfz1y3g;
	Fri, 21 Mar 2025 06:08:23 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2m81Lkmz1xNs
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:07:20 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm4-e204-208.ccs.ornl.gov [160.91.203.22])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6808D17D187;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 64A4A106BE14; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:50 -0400
Message-ID: <20250321130711.3257092-8-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 07/27] lustre: obd: fix style and clang error
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
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Timothy Day <timday@amazon.com>

Tabify the remaining code in this file and clean
up some of the comments. Add SPDX text.

Remove a function which is never used.

Fix the style of and inline cl_io_invariant.

Conserve a significant number of * so that they
can be repurposed in other comments.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16518
Lustre-commit: 4fc3c208422e3f2a1 ("LU-16518 obd: fix style and clang error")
Signed-off-by: Timothy Day <timday@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51311
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  7 ++--
 fs/lustre/obdclass/cl_io.c    | 68 ++++++++++++-----------------------
 2 files changed, 26 insertions(+), 49 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index b8ac31960a2f..9871b695a4fb 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -805,7 +805,8 @@ struct cl_page_slice {
 enum cl_lock_mode {
 	CLM_READ,
 	CLM_WRITE,
-	CLM_GROUP
+	CLM_GROUP,
+	CLM_MAX,
 };
 
 /**
@@ -1395,8 +1396,7 @@ typedef void (*cl_commit_cbt)(const struct lu_env *, struct cl_io *,
 			      struct pagevec *);
 
 struct cl_read_ahead {
-	/*
-	 * Maximum page index the readahead window will end.
+	/* Maximum page index the readahead window will end.
 	 * This is determined DLM lock coverage, RPC and stripe boundary.
 	 * cra_end is included.
 	 */
@@ -1411,6 +1411,7 @@ struct cl_read_ahead {
 	/* Callback data for cra_release routine */
 	void				*cra_dlmlock;
 	void				*cra_oio;
+
 	/* whether lock is in contention */
 	bool				cra_contention;
 };
diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index d6518e9f9c66..99672510aa5a 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1,55 +1,34 @@
 // SPDX-License-Identifier: GPL-2.0
-/*
- * GPL HEADER START
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
+
 /*
  * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
  * Copyright (c) 2011, 2017, Intel Corporation.
  */
+
 /*
  * This file is part of Lustre, http://www.lustre.org/
  *
  * Client IO.
  *
- *   Author: Nikita Danilov <nikita.danilov@sun.com>
- *   Author: Jinshan Xiong <jinshan.xiong@intel.com>
+ * Author: Nikita Danilov <nikita.danilov@sun.com>
+ * Author: Jinshan Xiong <jinshan.xiong@intel.com>
  */
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
+#include <linux/sched.h>
+#include <linux/list.h>
+#include <linux/list_sort.h>
 #include <obd_class.h>
 #include <obd_support.h>
 #include <lustre_fid.h>
-#include <linux/list.h>
-#include <linux/list_sort.h>
-#include <linux/sched.h>
 #include <cl_object.h>
 #include "cl_internal.h"
 
-/*****************************************************************************
- *
+/*
  * cl_io interface.
- *
  */
 
 static inline int cl_io_type_is_valid(enum cl_io_type type)
@@ -66,19 +45,15 @@ static inline int cl_io_is_loopable(const struct cl_io *io)
  * cl_io invariant that holds at all times when exported cl_io_*() functions
  * are entered and left.
  */
-static int cl_io_invariant(const struct cl_io *io)
+static inline int cl_io_invariant(const struct cl_io *io)
 {
-	struct cl_io *up;
-
-	up = io->ci_parent;
-	return
-		/*
-		 * io can own pages only when it is ongoing. Sub-io might
-		 * still be in CIS_LOCKED state when top-io is in
-		 * CIS_IO_GOING.
-		 */
-		ergo(io->ci_owned_nr > 0, io->ci_state == CIS_IO_GOING ||
-		     (io->ci_state == CIS_LOCKED && up));
+	/*
+	 * io can own pages only when it is ongoing. Sub-io might
+	 * still be in CIS_LOCKED state when top-io is in
+	 * CIS_IO_GOING.
+	 */
+	return ergo(io->ci_owned_nr > 0, io->ci_state == CIS_IO_GOING ||
+		    (io->ci_state == CIS_LOCKED && io->ci_parent));
 }
 
 /**
@@ -92,8 +67,8 @@ void cl_io_fini(const struct lu_env *env, struct cl_io *io)
 	LINVRNT(cl_io_invariant(io));
 
 	while (!list_empty(&io->ci_layers)) {
-		slice = list_last_entry(&io->ci_layers, struct cl_io_slice,
-					cis_linkage);
+		slice = container_of(io->ci_layers.prev, struct cl_io_slice,
+				     cis_linkage);
 		list_del_init(&slice->cis_linkage);
 		if (slice->cis_iop->op[io->ci_type].cio_fini)
 			slice->cis_iop->op[io->ci_type].cio_fini(env, slice);
@@ -111,7 +86,6 @@ void cl_io_fini(const struct lu_env *env, struct cl_io *io)
 	case CIT_READ:
 	case CIT_WRITE:
 	case CIT_DATA_VERSION:
-		break;
 	case CIT_FAULT:
 		break;
 	case CIT_FSYNC:
@@ -122,7 +96,6 @@ void cl_io_fini(const struct lu_env *env, struct cl_io *io)
 		/* Check ignore layout change conf */
 		LASSERT(ergo(io->ci_ignore_layout || !io->ci_verify_layout,
 			     !io->ci_need_restart));
-		break;
 	case CIT_GLIMPSE:
 		break;
 	case CIT_LADVISE:
@@ -1256,7 +1229,10 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 		/*
 		 * Holding the lock across both the decrement and
 		 * the wakeup ensures cl_sync_io_wait() doesn't complete
-		 * before the wakeup completes.
+		 * before the wakeup completes and the contents of
+		 * the anchor become unsafe to access as the owner is free
+		 * to immediately reclaim anchor when cl_sync_io_wait()
+		 * completes.
 		 */
 		wake_up_locked(&anchor->csi_waitq);
 		if (end_io)
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
