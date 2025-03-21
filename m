Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 36A3DC36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:16:31 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2nS3DPnz1y5l;
	Fri, 21 Mar 2025 06:08:28 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2m52n25z1xSC
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:07:17 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 6263288F9D5;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 59500106BE19; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:47 -0400
Message-ID: <20250321130711.3257092-5-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 04/27] lustre: llite: improve readpage debug
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <pfarrell@whamcloud.com>

LU-16412 (which is a workaround for a kernel bug) added a
debug message in ll_readpage(), but this message is printed
every time rather than only when the kernel bug is hit.

Let's fix this.

Fixes: aaa089da3f ("lustre: llite: check truncated page in ->readpage()")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16805
Lustre-commit: c2f548dacc5fd7285 ("LU-16805 llite: improve readpage debug")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50892
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Timothy Day <timday@amazon.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 276cad2b6eb7..e258d995c54b 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1981,9 +1981,6 @@ int ll_readpage(struct file *file, struct page *vmpage)
 	}
 
 	if (lcc && lcc->lcc_type != LCC_MMAP) {
-		CDEBUG(D_VFSTRACE, "pgno:%ld, beyond read end_index:%ld\n",
-		       vmpage->index, lcc->lcc_end_index);
-
 		/*
 		 * This handles a kernel bug introduced in kernel 5.12:
 		 * comment: cbd59c48ae2bcadc4a7599c29cf32fd3f9b78251
@@ -2009,6 +2006,10 @@ int ll_readpage(struct file *file, struct page *vmpage)
 		 * mentioned above.
 		 */
 		if (vmpage->index >= lcc->lcc_end_index) {
+			CDEBUG(D_VFSTRACE,
+			       "pgno:%ld, beyond read end_index:%ld\n",
+			       vmpage->index, lcc->lcc_end_index);
+
 			result = cl_io_read_ahead(env, io, vmpage->index, &ra);
 			if (result < 0 || vmpage->index > ra.cra_end_idx) {
 				cl_read_ahead_release(env, &ra);
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
