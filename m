Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 05912ECAAA1
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:55:49 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7l70TRGz1y6r;
	Mon,  5 Sep 2022 18:55:47 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7l45Hmvz1y64
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:44 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B067A100AFF9;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A183F589A1; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:18 -0400
Message-Id: <1662429337-18737-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/24] lustre: llite: use
 fatal_signal_pending in range_lock
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Qian Yingjin <qian@ddn.com>

FIO io_uring failed with one file shared by two FIO processes
under newer kernels.
After analyzed, we found that range_lock() function return
-ERESTARTSYS when there pending signal on current process in
Lustre I/O. This causes -EINTR returned to the application.

we solve this bug by replacing @signal_pending(current) with
@fatal_signal_pending(current) in range_lock(). The range_lock()
function only returns -ERESTARTSYS when the current process has
fatal pending signal such as SIGKILL.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15994
Lustre-commit: 4c5b0b0967f052af3 ("LU-15994 llite: use fatal_signal_pending in range_lock")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/48106
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/range_lock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/obdclass/range_lock.c b/fs/lustre/obdclass/range_lock.c
index 2af6385..9731e57 100644
--- a/fs/lustre/obdclass/range_lock.c
+++ b/fs/lustre/obdclass/range_lock.c
@@ -159,7 +159,7 @@ int range_lock(struct range_lock_tree *tree, struct range_lock *lock)
 		spin_unlock(&tree->rlt_lock);
 		schedule();
 
-		if (signal_pending(current)) {
+		if (fatal_signal_pending(current)) {
 			range_unlock(tree, lock);
 			rc = -ERESTARTSYS;
 			goto out;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
