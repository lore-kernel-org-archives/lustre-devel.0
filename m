Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 36DCDC433FE
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:26 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5ED2C3AD880;
	Thu, 13 Jan 2022 17:38:20 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0FA1E21FFAD
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:13 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 099BF100F34D;
 Thu, 13 Jan 2022 20:38:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 06630E07E3; Thu, 13 Jan 2022 20:38:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:38:02 -0500
Message-Id: <1642124283-10148-24-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 23/24] lustre: osc: Always set aio in anchor
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

We currently do not set csi_aio for DIO and use this to
control when we free the aio struct.  (For AIO, we must
free it in cl_sync_io_note, but for other users, we have to
wait until after cl_sync_io_wait has been called.)

The lack of csi_aio causes trouble for the implementation
of the next patch, so instead we always set it and control
freeing by checking at that time if we are doing DIO.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13799
Lustre-commit: eadccb33ac4bbe54a ("LU-13799 osc: Always set aio in anchor")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44153
Reviewed-by: Wang Shilong <wangshilong1991@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/cl_io.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 675116d..b72f5db 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1150,9 +1150,7 @@ struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb, struct cl_object *obj)
 		 * Hold one ref so that it won't be released until
 		 * every pages is added.
 		 */
-		cl_sync_io_init_notify(&aio->cda_sync, 1,
-				       is_sync_kiocb(iocb) ? NULL : aio,
-				       cl_aio_end);
+		cl_sync_io_init_notify(&aio->cda_sync, 1, aio, cl_aio_end);
 		cl_page_list_init(&aio->cda_pages);
 		aio->cda_iocb = iocb;
 		if (is_sync_kiocb(iocb))
@@ -1203,16 +1201,20 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 		wake_up_locked(&anchor->csi_waitq);
 		if (end_io)
 			end_io(env, anchor);
-		if (anchor->csi_aio)
-			aio = anchor->csi_aio;
+
+		aio = anchor->csi_aio;
 
 		spin_unlock(&anchor->csi_waitq.lock);
 
 		/**
-		 * If anchor->csi_aio is set, we are responsible for freeing
-		 * memory here rather than when cl_sync_io_wait() completes.
+		 * For AIO (!is_sync_kiocb), we are responsible for freeing
+		 * memory here.  This is because we are the last user of this
+		 * aio struct, whereas in other cases, we will call
+		 * cl_sync_io_wait to wait after this, and so the memory is
+		 * freed after that call.
 		 */
-		cl_aio_free(env, aio);
+		if (aio && !is_sync_kiocb(aio->cda_iocb))
+			cl_aio_free(env, aio);
 	}
 }
 EXPORT_SYMBOL(cl_sync_io_note);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
