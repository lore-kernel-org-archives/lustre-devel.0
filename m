Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 74D8CC77B76
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 13:50:47 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T065jQYz1yFh;
	Mon, 17 Apr 2023 06:48:06 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0SzQ1Tg1z1y6h
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:47:30 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 649311005FA2;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5B1C337B; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:00 -0400
Message-Id: <1681739243-29375-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/27] lustre: llite: restart clio for AIO if
 necessary
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
Cc: Li Dongyang <dongyangli@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Li Dongyang <dongyangli@ddn.com>

If the clio needs to be restarted from where it left off,
do it for AIO as well, so we don't end up with short IO.
Limit thr number of retries to 1000, to avoid potential
issues if the loop is stuck forever.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14760
Lustre-commit: 6b1e747ad5bf02915 ("LU-14760 llite: restart clio for AIO if necessary")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/43995
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 746c18f..b96efb1 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1689,6 +1689,7 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	ssize_t result = 0;
 	int rc = 0;
 	int rc2 = 0;
+	int retries = 1000;
 	unsigned int retried = 0;
 	unsigned int dio_lock = 0;
 	bool is_aio = false;
@@ -1851,13 +1852,13 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	       file->f_path.dentry->d_name.name,
 	       iot, rc, result, io->ci_need_restart);
 
-	if ((!rc || rc == -ENODATA || rc == -ENOLCK) &&
-	    count > 0 && io->ci_need_restart) {
+	if ((!rc || rc == -ENODATA || rc == -ENOLCK || rc == -EIOCBQUEUED) &&
+	    count > 0 && io->ci_need_restart && retries-- > 0) {
 		CDEBUG(D_VFSTRACE,
-		       "%s: restart %s from %lld, count:%zu, result: %zd\n",
+		       "%s: restart %s from ppos=%lld count=%zu retries=%u ret=%zd: rc = %d\n",
 		       file_dentry(file)->d_name.name,
 		       iot == CIT_READ ? "read" : "write",
-		       *ppos, count, result);
+		       *ppos, count, retries, result, rc);
 		/* preserve the tried count for FLR */
 		retried = io->ci_ndelay_tried;
 		dio_lock = io->ci_dio_lock;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
