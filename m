Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id EBBC9C0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 21:08:27 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMGx1Dg8z21Y6;
	Sun, 02 Feb 2025 12:51:05 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMFL6PGSz1yXX
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:49:42 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id E801389ABF4;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id E5141106BE17; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:20 -0500
Message-ID: <20250202204633.1148872-21-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 20/33] lustre: llite: Fix return for
 non-queued aio
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
Cc: Zhenyu Xu <bobijam@hotmail.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <pfarrell@whamcloud.com>

If an AIO fails or is completed synchronously (even
partially), the VFS will handle calling the completion
callback to finish the AIO, and so Lustre needs to return
the number of bytes successfully completed to the VFS.

This fixes a bug where if an AIO was racing with buffered
I/O, the AIO would fall back to buffered I/O, causing it to
complete before returning to the VFS rather than being
queued.  In this case, Lustre would return 0 the VFS, and
the VFS would complete the AIO and report 0 bytes moved.

This fixes the logic for this.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13805
Lustre-commit: 8a5bb81f774b9d41f ("LU-13805 llite: Fix return for non-queued aio")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49915
Reviewed-by: Zhenyu Xu <bobijam@hotmail.com>
Reviewed-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 51 +++++++++++++++++++++++-------------------
 fs/lustre/llite/rw26.c |  1 -
 2 files changed, 28 insertions(+), 24 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index fc9095279a4b..e745dc8c53a5 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1832,21 +1832,12 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
 		range_locked = false;
 	}
 
-	/*
-	 * In order to move forward AIO, ci_nob was increased,
-	 * but that doesn't mean io have been finished, it just
-	 * means io have been submited, we will always return
-	 * EIOCBQUEUED to the caller, So we could only return
-	 * number of bytes in non-AIO case.
-	 */
 	if (io->ci_nob > 0) {
-		if (!is_aio) {
-			if (rc2 == 0) {
-				result += io->ci_nob;
-				*ppos = io->u.ci_wr.wr.crw_pos; /* for splice */
-			} else if (rc2) {
-				result = 0;
-			}
+		if (rc2 == 0) {
+			result += io->ci_nob;
+			*ppos = io->u.ci_wr.wr.crw_pos; /* for splice */
+		} else if (rc2) {
+			result = 0;
 		}
 		count -= io->ci_nob;
 
@@ -1886,22 +1877,36 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
 	}
 
 	if (io->ci_dio_aio) {
+		/* set the number of bytes successfully moved in the aio */
+		if (result > 0)
+			io->ci_dio_aio->cda_bytes = result;
 		/*
 		 * VFS will call aio_complete() if no -EIOCBQUEUED
 		 * is returned for AIO, so we can not call aio_complete()
-		 * in our end_io().
+		 * in our end_io().  (cda_no_aio_complete is always set for
+		 * normal DIO.)
 		 *
-		 * NB: This is safe because the atomic_dec_and_lock  in
-		 * cl_sync_io_init has implicit memory barriers, so this will
-		 * be seen by whichever thread completes the DIO/AIO, even if
-		 * it's not this one
+		 * NB: Setting cda_no_aio_complete like this is safe because
+		 * the atomic_dec_and_lock in cl_sync_io_note has implicit
+		 * memory barriers, so this will be seen by whichever thread
+		 * completes the DIO/AIO, even if it's not this one.
 		 */
-		if (rc != -EIOCBQUEUED)
+		if (is_aio && rc != -EIOCBQUEUED)
 			io->ci_dio_aio->cda_no_aio_complete = 1;
+		/* if an aio enqueued successfully (-EIOCBQUEUED), then Lustre
+		 * will call aio_complete rather than the vfs, so we return 0
+		 * to tell the VFS we're handling it
+		 */
+		else if (is_aio) /* rc == -EIOCBQUEUED */
+			result = 0;
 		/**
-		 * Drop one extra reference so that end_io() could be
-		 * called for this IO context, we could call it after
-		 * we make sure all AIO requests have been proceed.
+		 * Drop the reference held by the llite layer on this top level
+		 * IO context.
+		 *
+		 * For DIO, this frees it here, since IO is complete, and for
+		 * AIO, we will call aio_complete() (and then free this top
+		 * level context) once all the outstanding chunks of this AIO
+		 * have completed.
 		 */
 		cl_sync_io_note(env, &io->ci_dio_aio->cda_sync,
 				rc == -EIOCBQUEUED ? 0 : rc);
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index ad7308a8c902..9239e029276e 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -425,7 +425,6 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	}
 
 out:
-	ll_dio_aio->cda_bytes += tot_bytes;
 
 	if (rw == WRITE)
 		vio->u.readwrite.vui_written += tot_bytes;
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
