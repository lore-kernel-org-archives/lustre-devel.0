Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 711AEC4338F
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:18 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2986A611F2
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 2986A611F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 09A6421E04E;
	Sun, 22 Aug 2021 19:28:06 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7A34921CAB1
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 19:27:50 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1D145100BAF4;
 Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0EDECB6C7F; Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 22 Aug 2021 22:27:32 -0400
Message-Id: <1629685666-4533-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
References: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/15] lustre: uapi: support fixed directory
 layout
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

User may not want directories split automatically in some cases:
*.directory migrated.
* directory restriped.

To support this, an LMV flag LMV_HASH_FLAG_FIXED is added, and it will
be set on migrated/restriped directories. NB, if directory is migrated
or restriped to a one-stripe directory, it won't be transformed into a
plain directory, because this flag needs to be kept.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14459
Lustre-commit: 4c2514f483280137 ("LU-14459 mdt: support fixed directory layout")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43291
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c             | 1 +
 include/uapi/linux/lustre/lustre_user.h | 5 +++++
 2 files changed, 6 insertions(+)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 4301bd4..7d504bd 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1778,6 +1778,7 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(LMV_MAGIC_V1 != 0x0CD20CD0);
 	BUILD_BUG_ON(LMV_MAGIC_STRIPE != 0x0CD40CD0);
 	BUILD_BUG_ON(LMV_HASH_TYPE_MASK != 0x0000ffff);
+	BUILD_BUG_ON(LMV_HASH_FLAG_FIXED != 0x02000000);
 	BUILD_BUG_ON(LMV_HASH_FLAG_MERGE != 0x04000000);
 	BUILD_BUG_ON(LMV_HASH_FLAG_SPLIT != 0x08000000);
 	BUILD_BUG_ON(LMV_HASH_FLAG_LOST_LMV != 0x10000000);
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index b317bbf..7fcc009 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -718,6 +718,9 @@ static inline bool lmv_is_known_hash_type(__u32 type)
 	       (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_CRUSH;
 }
 
+/* fixed layout, such directories won't split automatically */
+/* NB, update LMV_HASH_FLAG_KNOWN when adding new flag */
+#define LMV_HASH_FLAG_FIXED		0x02000000
 #define LMV_HASH_FLAG_MERGE		0x04000000
 #define LMV_HASH_FLAG_SPLIT		0x08000000
 
@@ -733,6 +736,8 @@ static inline bool lmv_is_known_hash_type(__u32 type)
 #define LMV_HASH_FLAG_LAYOUT_CHANGE	\
 	(LMV_HASH_FLAG_MIGRATION | LMV_HASH_FLAG_SPLIT | LMV_HASH_FLAG_MERGE)
 
+#define LMV_HASH_FLAG_KNOWN		0xfe000000
+
 /* both SPLIT and MIGRATION are set for directory split */
 static inline bool lmv_hash_is_splitting(__u32 hash)
 {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
