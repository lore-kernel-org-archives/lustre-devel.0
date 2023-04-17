Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id ACA70C77B76
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 13:53:28 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T0w0Ldrz216B;
	Mon, 17 Apr 2023 06:48:48 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0SzP28bRz1y5y
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:47:29 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 5FD2D1005FA1;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 56BB1379; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:46:59 -0400
Message-Id: <1681739243-29375-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/27] lustre: llite: protect cp_state with
 vmpage lock
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

From: Bobi Jam <bobijam@whamcloud.com>

cl_page_make_ready() calls cl_page_io_start() without vmpage lock
protection, and that could mess up cl_page's cp_state/cp_owner.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16612
Lustre-commit: d03b038d0dd8360dc ("LU-16612 llite: protect cp_state with vmpage lock")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50180
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/cl_page.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 8320293..80423b7 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -871,6 +871,7 @@ int cl_page_make_ready(const struct lu_env *env, struct cl_page *cp,
 		       enum cl_req_type crt)
 {
 	struct page *vmpage = cp->cp_vmpage;
+	bool unlock = false;
 	int rc = 0;
 
 	PASSERT(env, cp, crt == CRT_WRITE);
@@ -879,6 +880,7 @@ int cl_page_make_ready(const struct lu_env *env, struct cl_page *cp,
 		goto out;
 
 	lock_page(vmpage);
+	unlock = true;
 
 	if (clear_page_dirty_for_io(vmpage)) {
 		LASSERT(cp->cp_state == CPS_CACHED);
@@ -899,13 +901,15 @@ int cl_page_make_ready(const struct lu_env *env, struct cl_page *cp,
 		LBUG();
 	}
 
-	unlock_page(vmpage);
 out:
 	if (rc == 0) {
 		PASSERT(env, cp, cp->cp_state == CPS_CACHED);
 		cl_page_io_start(env, cp, crt);
 	}
 
+	if (unlock)
+		unlock_page(vmpage);
+
 	CL_PAGE_HEADER(D_TRACE, env, cp, "%d %d\n", crt, rc);
 
 	return rc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
