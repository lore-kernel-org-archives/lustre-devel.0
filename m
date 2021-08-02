Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDA56C432BE
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 09E2660724
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 09E2660724
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5C60C352C1E;
	Mon,  2 Aug 2021 12:51:01 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2F54135286A
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:57 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 61C871008040;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 60014C2F50; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:29 -0400
Message-Id: <1627933851-7603-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/25] lustre: uapi: remove
 MDS_SETATTR_PORTAL and service
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

From: Andreas Dilger <adilger@whamcloud.com>

Remove the MDS_SETATTR_PORTAL and the service threads listening on
this portal since they are unused since Lustre 2.1 and are no longer
needed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13326
Lustre-commit: 7a2ef25f1f259c0a ("LU-13326 mds: remove MDS_SETATTR_PORTAL and service")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/37798
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_idl.h | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 2047b92..65948d8 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -93,15 +93,11 @@
 
 #define CONNMGR_REQUEST_PORTAL	1
 #define CONNMGR_REPLY_PORTAL	2
-/* #define OSC_REQUEST_PORTAL	3 */
 #define OSC_REPLY_PORTAL	4
-/* #define OSC_BULK_PORTAL	5 */
 #define OST_IO_PORTAL		6
 #define OST_CREATE_PORTAL	7
 #define OST_BULK_PORTAL		8
-/* #define MDC_REQUEST_PORTAL	9 */
 #define MDC_REPLY_PORTAL	10
-/* #define MDC_BULK_PORTAL	11 */
 #define MDS_REQUEST_PORTAL	12
 #define MDS_IO_PORTAL		13
 #define MDS_BULK_PORTAL		14
@@ -109,10 +105,7 @@
 #define LDLM_CB_REPLY_PORTAL	16
 #define LDLM_CANCEL_REQUEST_PORTAL 17
 #define LDLM_CANCEL_REPLY_PORTAL   18
-/* #define PTLBD_REQUEST_PORTAL	19 */
-/* #define PTLBD_REPLY_PORTAL	20 */
-/* #define PTLBD_BULK_PORTAL	21 */
-#define MDS_SETATTR_PORTAL	22
+/* #define MDS_SETATTR_PORTAL	22 obsolete after 2.13 */
 #define MDS_READPAGE_PORTAL	23
 #define OUT_PORTAL		24
 #define MGC_REPLY_PORTAL	25
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
