Return-Path: <SRS0=HxeM=ML=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AE3FC07E9B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:33:13 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2E94C6112D
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:33:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E94C6112D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 70D5034FB13;
	Mon, 19 Jul 2021 05:32:45 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AA3CC34F991
 for <lustre-devel@lists.lustre.org>; Mon, 19 Jul 2021 05:32:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B69C191F;
 Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B5057BD1C6; Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 19 Jul 2021 08:32:12 -0400
Message-Id: <1626697933-6971-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
References: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/18] lustre: pcc: introducing
 OBD_CONNECT2_PCCRO flag
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

From: Qian Yingjin <qian@ddn.com>

Add a new connection flag OBD_CONNECT2_PCCRO to solve the access
consistency from the old client without PCC-RO support.

By necessity, also include definitions for OBD_CONNECT2_MODE_CONVERT
and OBD_CONNECT2_BATCH_RPC so obd_connect_names[] works.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10499
Lustre-commit: 6007dc9382df726 ("LU-10499 pcc: introducing OBD_CONNECT2_PCCRO flag")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/40791
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c            | 6 ++++++
 include/uapi/linux/lustre/lustre_idl.h | 4 ++++
 2 files changed, 10 insertions(+)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index c7eb218..cd1456c 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1252,6 +1252,12 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_DOM_LVB);
 	LASSERTF(OBD_CONNECT2_REP_MBITS == 0x100000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_REP_MBITS);
+	LASSERTF(OBD_CONNECT2_MODE_CONVERT == 0x200000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_MODE_CONVERT);
+	LASSERTF(OBD_CONNECT2_BATCH_RPC == 0x400000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_BATCH_RPC);
+	LASSERTF(OBD_CONNECT2_PCCRO == 0x800000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_PCCRO);
 	LASSERTF(OBD_CONNECT2_ATOMIC_OPEN_LOCK == 0x4000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_ATOMIC_OPEN_LOCK);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 8f49adb..2047b92 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -840,6 +840,10 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_LSEEK	      0x40000ULL /* SEEK_HOLE/DATA RPC */
 #define OBD_CONNECT2_DOM_LVB	      0x80000ULL /* pack DOM glimpse data in LVB */
 #define OBD_CONNECT2_REP_MBITS	     0x100000ULL /* match reply by mbits, not xid */
+#define OBD_CONNECT2_REP_MBITS       0x100000ULL /* match reply mbits not xid*/
+#define OBD_CONNECT2_MODE_CONVERT    0x200000ULL /* LDLM mode convert */
+#define OBD_CONNECT2_BATCH_RPC	     0x400000ULL /* Multi-RPC batch request */
+#define OBD_CONNECT2_PCCRO	     0x800000ULL /* Read-only PCC */
 #define OBD_CONNECT2_ATOMIC_OPEN_LOCK 0x4000000ULL/* request lock on 1st open */
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
