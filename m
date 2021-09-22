Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFD81C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:50 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0A8376112F
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 0A8376112F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 46C9220574B;
	Tue, 21 Sep 2021 19:20:49 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1447B21F24A
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:10 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 266F4469;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 24C10FF4A3; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:51 -0400
Message-Id: <1632277201-6920-15-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 14/24] lustre: llite: Always do lookup on
 ENOENT in open
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

From: Patrick Farrell <pfarrell@whamcloud.com>

When there is no valid dentry found for a file we want to
open, we perform a full lookup, which goes to the server
and looks up the file by name. When we find an existing
dentry in cache *but the file is not open on the node*, we
do not do a full lookup.  We move directly to opening the
file.

When we open files, we use the FID of the file.  The
problem occurs when a new file is renamed *over* the file
we were trying to open.  This removes the FID we are
trying to open, but the file *name* userspace called open()
on is still present.  In this case, we will return ENOENT,
even though there is a file matching the name used in the
open() call.

The solution is when we get an ENOENT on open (indicating
our open raced with an unlink), we always send ESTALE back
to the VFS, which restarts the open and forces a lookup to
the server (by forcing Lustre to consider the dentry
invalid, see comments in ll_intent_file_open and code in
ll_revalidate_dentry).

This causes a lookup by name, which will correctly handle
the rename, allowing the open to proceed normally.

This should only generate extra retries in the case where a
positive dentry exists on the client but the file has been
removed on the server, ie, open racing with unlink.

This should hopefully be rare.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14949
lustre-commit: 72c1f7095203cc1ba ("LU-14949 llite: Always do lookup on ENOENT in open")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44675
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/llite/file.c          | 23 +++++++++++++++--------
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 1e8cebf..540e1e0 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -483,6 +483,7 @@
 #define OBD_FAIL_LLITE_CREATE_FILE_PAUSE2		0x1416
 #define OBD_FAIL_LLITE_RACE_MOUNT			0x1417
 #define OBD_FAIL_LLITE_PAGE_ALLOC			0x1418
+#define OBD_FAIL_LLITE_OPEN_DELAY			0x1419
 
 #define OBD_FAIL_FID_INDIR				0x1501
 #define OBD_FAIL_FID_INLMA				0x1502
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index aa5c662..10450ce 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -639,6 +639,8 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 	op_data->op_data = lmm;
 	op_data->op_data_size = lmmsize;
 
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_OPEN_DELAY, cfs_fail_val);
+
 	rc = md_intent_lock(sbi->ll_md_exp, op_data, itp, &req,
 			    &ll_md_blocking_ast, 0);
 	kfree(name);
@@ -692,15 +694,20 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 	ptlrpc_req_finished(req);
 	ll_intent_drop_lock(itp);
 
-	/*
-	 * We did open by fid, but by the time we got to the server,
-	 * the object disappeared. If this is a create, we cannot really
-	 * tell the userspace that the file it was trying to create
-	 * does not exist. Instead let's return -ESTALE, and the VFS will
-	 * retry the create with LOOKUP_REVAL that we are going to catch
-	 * in ll_revalidate_dentry() and use lookup then.
+	/* We did open by fid, but by the time we got to the server, the object
+	 * disappeared.  This is possible if the object was unlinked, but it's
+	 * also possible if the object was unlinked by a rename.  In the case
+	 * of an object renamed over our existing one, we can't fail this open.
+	 * O_CREAT also goes through this path if we had an existing dentry,
+	 * and it's obviously wrong to return ENOENT for O_CREAT.
+	 *
+	 * Instead let's return -ESTALE, and the VFS will retry the open with
+	 * LOOKUP_REVAL, which we catch in ll_revalidate_dentry and fail to
+	 * revalidate, causing a lookup.  This causes extra lookups in the case
+	 * where we had a dentry in cache but the file is being unlinked and we
+	 * lose the race with unlink, but this should be very rare.
 	 */
-	if (rc == -ENOENT && itp->it_op & IT_CREAT)
+	if (rc == -ENOENT)
 		rc = -ESTALE;
 
 	return rc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
