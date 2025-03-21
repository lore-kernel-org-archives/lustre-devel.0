Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 133DCC36001
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:21:04 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2pk1YhMz1yCv;
	Fri, 21 Mar 2025 06:09:34 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2mq251rz1xp6
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:07:55 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 724E888F9D8;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 70B74106BE18; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:53 -0400
Message-ID: <20250321130711.3257092-11-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 10/27] lustre: llite: Rename ldp_aio to sdio
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

ldp_aio is a weird name for a 'sub dio' struct - rename it
to sdio.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13805
Lustre-commit: 7c416273ad1a8f559 ("LU-13805 llite: Rename ldp_aio to sdio")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50170
Reviewed-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw26.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 9239e029276e..5e9dcefa84f0 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -307,7 +307,7 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = file->f_mapping->host;
 	struct cl_dio_aio *ll_dio_aio;
-	struct cl_sub_dio *ldp_aio;
+	struct cl_sub_dio *sdio;
 	size_t count = iov_iter_count(iter);
 	ssize_t tot_bytes = 0, result = 0;
 	loff_t file_offset = iocb->ki_pos;
@@ -378,21 +378,21 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 		 * otherwise it is freed on the final call to cl_sync_io_note
 		 * (either in this function or from a ptlrpcd daemon)
 		 */
-		ldp_aio = cl_sub_dio_alloc(ll_dio_aio, sync_submit);
-		if (!ldp_aio) {
+		sdio = cl_sub_dio_alloc(ll_dio_aio, sync_submit);
+		if (!sdio) {
 			result = -ENOMEM;
 			goto out;
 		}
 
-		pvec = &ldp_aio->csd_dio_pages;
+		pvec = &sdio->csd_dio_pages;
 
 		result = ll_get_user_pages(rw, iter, &pages,
 					   &pvec->ldp_count, count);
 		if (unlikely(result <= 0)) {
-			cl_sync_io_note(env, &ldp_aio->csd_sync, result);
+			cl_sync_io_note(env, &sdio->csd_sync, result);
 			if (sync_submit) {
-				LASSERT(ldp_aio->csd_creator_free);
-				cl_sub_dio_free(ldp_aio);
+				LASSERT(sdio->csd_creator_free);
+				cl_sub_dio_free(sdio);
 			}
 			goto out;
 		}
@@ -402,19 +402,19 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 		pvec->ldp_pages = pages;
 
 		result = ll_direct_rw_pages(env, io, count,
-					    rw, inode, ldp_aio);
+					    rw, inode, sdio);
 		/* We've submitted pages and can now remove the extra
 		 * reference for that
 		 */
-		cl_sync_io_note(env, &ldp_aio->csd_sync, result);
+		cl_sync_io_note(env, &sdio->csd_sync, result);
 
 		if (sync_submit) {
-			rc2 = cl_sync_io_wait(env, &ldp_aio->csd_sync,
+			rc2 = cl_sync_io_wait(env, &sdio->csd_sync,
 					     0);
 			if (result == 0 && rc2)
 				result = rc2;
-			LASSERT(ldp_aio->csd_creator_free);
-			cl_sub_dio_free(ldp_aio);
+			LASSERT(sdio->csd_creator_free);
+			cl_sub_dio_free(sdio);
 		}
 		if (unlikely(result < 0))
 			goto out;
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
