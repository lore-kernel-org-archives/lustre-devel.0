Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DC794C36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:41:51 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2wL45zdz211N;
	Fri, 21 Mar 2025 06:14:26 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2pB6H7xz1y9f
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:09:06 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A9458893DA1;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id A700F106BE16; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:07:07 -0400
Message-ID: <20250321130711.3257092-25-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 24/27] lustre: llite: Improve sync_io comments
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

Correct and improve comments on cl_sync_io_wait_recycle.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13805
Lustre-commit: 8fa28e42ce38cb3b6 ("LU-13805 llite: Improve sync_io comments")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50167
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Qian Yingjin <qian@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/cl_io.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index 99672510aa5a..6132f42b77e5 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -1259,6 +1259,10 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
 }
 EXPORT_SYMBOL(cl_sync_io_note);
 
+/* this function waits for completion of outstanding io and then re-initializes
+ * the anchor used to track it.  This is used to wait to complete DIO before
+ * returning to userspace, and is never called for true AIO
+ */
 int cl_sync_io_wait_recycle(const struct lu_env *env, struct cl_sync_io *anchor,
 			    long timeout, int ioret)
 {
@@ -1271,10 +1275,8 @@ int cl_sync_io_wait_recycle(const struct lu_env *env, struct cl_sync_io *anchor,
 	 * count to be zero.
 	 */
 	cl_sync_io_note(env, anchor, ioret);
-	/* Wait for completion of normal dio.
-	 * This replaces the EIOCBQEUED return from the DIO/AIO
-	 * path, and this is where AIO and DIO implementations
-	 * split.
+	/* Wait for completion of outstanding dio before re-initializing for
+	 * possible restart
 	 */
 	rc = cl_sync_io_wait(env, anchor, timeout);
 	/**
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
