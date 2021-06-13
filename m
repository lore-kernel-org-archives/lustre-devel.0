Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4922C48BDF
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:37 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A403C611CA
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A403C611CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E2C1C21F693;
	Sun, 13 Jun 2021 16:12:13 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 30F3321F2B4
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E95BC100BAE1;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E7E9C9C303; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:34 -0400
Message-Id: <1623625897-17706-25-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 24/27] lustre: llite: add selinux testing
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
Cc: Saurabh Tandan <saurabh.tandan@intel.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sebastien Buisson <sbuisson@ddn.com>

New test sanity-selinux.sh aims at exercing SELinux support
on the client side, as implemented according to LU-5560.
This patch adds new fail_locs in CLIO.

WC-bug-id: https://jira.whamcloud.com/browse/LU-5560
Lustre-commit: bfca8338e5f2ae1b ("LU-5560 tests: add sanity-selinux.sh")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: Saurabh Tandan <saurabh.tandan@intel.com>
Reviewed-on: http://review.whamcloud.com/15818
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h | 3 +++
 fs/lustre/llite/dir.c           | 2 ++
 fs/lustre/llite/namei.c         | 6 ++++++
 3 files changed, 11 insertions(+)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 188e552..1e8cebf 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -468,6 +468,9 @@
 #define OBD_FAIL_LLITE_LOST_LAYOUT			0x1407
 #define OBD_FAIL_LLITE_NO_CHECK_DEAD			0x1408
 #define OBD_FAIL_GETATTR_DELAY				0x1409
+#define OBD_FAIL_LLITE_CREATE_FILE_PAUSE		0x1409
+#define OBD_FAIL_LLITE_NEWNODE_PAUSE			0x140a
+#define OBD_FAIL_LLITE_SETDIRSTRIPE_PAUSE		0x140b
 #define OBD_FAIL_LLITE_CREATE_NODE_PAUSE		0x140c
 #define OBD_FAIL_LLITE_IMUTEX_SEC			0x140e
 #define OBD_FAIL_LLITE_IMUTEX_NOSEC			0x140f
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 3432034..fa8e697 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -486,6 +486,8 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	if (err)
 		goto out_request;
 
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LLITE_SETDIRSTRIPE_PAUSE, cfs_fail_val);
+
 	err = ll_prep_inode(&inode, &request->rq_pill, parent->i_sb, NULL);
 	if (err)
 		goto out_inode;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 9eab6fe..f42e872 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1156,6 +1156,8 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	else if (de)
 		dentry = de;
 
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LLITE_CREATE_FILE_PAUSE, cfs_fail_val);
+
 	if (!rc) {
 		if (it_disposition(it, DISP_OPEN_CREATE)) {
 			/* Dentry instantiated in ll_create_it. */
@@ -1485,6 +1487,8 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 
 	ll_update_times(request, dir);
 
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LLITE_NEWNODE_PAUSE, cfs_fail_val);
+
 	err = ll_prep_inode(&inode, &request->rq_pill, dir->i_sb, NULL);
 	if (err)
 		goto err_exit;
@@ -1575,6 +1579,8 @@ static int ll_create_nd(struct inode *dir, struct dentry *dentry,
 	ktime_t kstart = ktime_get();
 	int rc;
 
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LLITE_CREATE_FILE_PAUSE, cfs_fail_val);
+
 	CDEBUG(D_VFSTRACE,
 	       "VFS Op:name=%pd, dir=" DFID "(%p), flags=%u, excl=%d\n",
 	       dentry, PFID(ll_inode2fid(dir)), dir, mode, want_excl);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
