Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44F07C433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:24 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 046FA60FF0
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 046FA60FF0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 246A421FA8E;
	Mon,  5 Apr 2021 00:52:43 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9B0EF32821F
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:28 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 2CFE5EC7;
 Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2A61C90AAC; Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:51:07 -0400
Message-Id: <1617583870-32029-39-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 38/41] lnet: libcfs: use wait_event_timeout()
 in tracefiled().
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

By using wait_event_timeout() we can make it more clear what is being
waited for, and when the loop terminates.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9859
Lustre-commit: 0269ac4a0069b0e4 ("LU-9859 libcfs: use wait_event_timeout() in tracefiled().")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39293
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/tracefile.c | 37 +++++++++++++++----------------------
 1 file changed, 15 insertions(+), 22 deletions(-)

diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index 14fcb2a..4e1900d 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -1085,13 +1085,18 @@ static int tracefiled(void *arg)
 
 	complete(&tctl->tctl_start);
 
-	while (1) {
-		wait_queue_entry_t __wait;
-
-		pc.pc_want_daemon_pages = 0;
-		collect_pages(&pc);
+	pc.pc_want_daemon_pages = 0;
+
+	while (!last_loop) {
+		wait_event_timeout(tctl->tctl_waitq,
+				   ({ collect_pages(&pc);
+				     !list_empty(&pc.pc_pages); }) ||
+				   atomic_read(&tctl->tctl_shutdown),
+				   HZ);
+		if (atomic_read(&tctl->tctl_shutdown))
+			last_loop = 1;
 		if (list_empty(&pc.pc_pages))
-			goto end_loop;
+			continue;
 
 		filp = NULL;
 		down_read(&cfs_tracefile_sem);
@@ -1110,18 +1115,19 @@ static int tracefiled(void *arg)
 		if (!filp) {
 			put_pages_on_daemon_list(&pc);
 			__LASSERT(list_empty(&pc.pc_pages));
-			goto end_loop;
+			continue;
 		}
 
 		list_for_each_entry_safe(tage, tmp, &pc.pc_pages, linkage) {
+			struct dentry *de = file_dentry(filp);
 			static loff_t f_pos;
 
 			__LASSERT_TAGE_INVARIANT(tage);
 
 			if (f_pos >= (off_t)cfs_tracefile_size)
 				f_pos = 0;
-			else if (f_pos > i_size_read(file_inode(filp)))
-				f_pos = i_size_read(file_inode(filp));
+			else if (f_pos > i_size_read(de->d_inode))
+				f_pos = i_size_read(de->d_inode);
 
 			buf = kmap(tage->page);
 			rc = kernel_write(filp, buf, tage->used, &f_pos);
@@ -1158,19 +1164,6 @@ static int tracefiled(void *arg)
 			pr_err("Lustre: There are %d pages unwritten\n", i);
 		}
 		__LASSERT(list_empty(&pc.pc_pages));
-end_loop:
-		if (atomic_read(&tctl->tctl_shutdown)) {
-			if (!last_loop) {
-				last_loop = 1;
-				continue;
-			} else {
-				break;
-			}
-		}
-		init_wait(&__wait);
-		add_wait_queue(&tctl->tctl_waitq, &__wait);
-		schedule_timeout_interruptible(HZ);
-		remove_wait_queue(&tctl->tctl_waitq, &__wait);
 	}
 	complete(&tctl->tctl_stop);
 	return 0;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
