Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CF89DC77B70
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 13:53:16 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T0r0sbLz215p;
	Mon, 17 Apr 2023 06:48:44 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0SzR3fjYz1y7W
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:47:31 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 66FA51005FA3;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 60DF137C; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:01 -0400
Message-Id: <1681739243-29375-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/27] lustre: protocol: add
 OBD_BRW_COMPRESSED
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

From: Alex Zhuravlev <bzzz@whamcloud.com>

so the client can hint OST the data is compressed

WC-bug-id: https://jira.whamcloud.com/browse/LU-16603
Lustre-commit: 764e19186cfc99123 ("LU-16603 protocol: add OBD_BRW_COMPRESSED")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50154
Reviewed-by: Artem Blagodarenko <ablagodarenko@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c            | 2 ++
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 2 files changed, 3 insertions(+)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 472d155c..6e893f0 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -2085,6 +2085,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_BRW_RDMA_ONLY);
 	LASSERTF(OBD_BRW_SYS_RESOURCE == 0x40000, "found 0x%.8x\n",
 		 OBD_BRW_SYS_RESOURCE);
+	LASSERTF(OBD_BRW_COMPRESSED == 0x80000, "found 0x%.8x\n",
+		 OBD_BRW_COMPRESSED);
 
 	/* Checks for struct ost_body */
 	LASSERTF((int)sizeof(struct ost_body) == 208, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index c979e24..83c8ea8 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1253,6 +1253,7 @@ struct hsm_state_set {
 #define OBD_BRW_ROOT_PRJQUOTA 0x10000 /* check project quota for root */
 #define OBD_BRW_RDMA_ONLY    0x20000 /* RPC contains RDMA-only pages*/
 #define OBD_BRW_SYS_RESOURCE 0x40000 /* page has CAP_SYS_RESOURCE */
+#define OBD_BRW_COMPRESSED   0x80000 /* data compressed on client */
 
 #define OBD_MAX_GRANT 0x7fffffffUL /* Max grant allowed to one client: 2 GiB */
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
