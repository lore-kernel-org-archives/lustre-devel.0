Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 31961C433FE
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:21 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 73BE73AD7BC;
	Thu, 13 Jan 2022 17:38:17 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CB7813AD7F0
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:12 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 06382100F34C;
 Thu, 13 Jan 2022 20:38:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0352AA8102; Thu, 13 Jan 2022 20:38:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:38:01 -0500
Message-Id: <1642124283-10148-23-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 22/24] lustre: llite: Simplify
 cda_no_aio_complete use
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

It is better to handle AIO and DIO the same as much as
possible, limiting the difference to setup if possible.

In this spirit, move the check for DIO (is_sync_kiocb()) to
the setup function rather than cleanup and just use
no_aio_complete.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13799
Lustre-commit: b60bd21ec5d5f34ed ("LU-13799 llite: Simplify cda_no_aio_complete use")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44154
Reviewed-by: Wang Shilong <wangshilong1991@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/cl_io.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index f33a5f38..675116d 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1135,8 +1135,7 @@ static void cl_aio_end(const struct lu_env *env, struct cl_sync_io *anchor)
 		cl_page_put(env, page);
 	}
 
-	if (!is_sync_kiocb(aio->cda_iocb) && !aio->cda_no_aio_complete &&
-	    aio->cda_iocb->ki_complete)
+	if (!aio->cda_no_aio_complete)
 		aio->cda_iocb->ki_complete(aio->cda_iocb,
 					   ret ?: aio->cda_bytes, 0);
 }
@@ -1156,7 +1155,10 @@ struct cl_dio_aio *cl_aio_alloc(struct kiocb *iocb, struct cl_object *obj)
 				       cl_aio_end);
 		cl_page_list_init(&aio->cda_pages);
 		aio->cda_iocb = iocb;
-		aio->cda_no_aio_complete = 0;
+		if (is_sync_kiocb(iocb))
+			aio->cda_no_aio_complete = 1;
+		else
+			aio->cda_no_aio_complete = 0;
 		cl_object_get(obj);
 		aio->cda_obj = obj;
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
