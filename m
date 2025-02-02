Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 20C5EC0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:51:11 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMCp0121z20vp;
	Sun, 02 Feb 2025 12:48:21 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmM9y3L7Nz1y9d
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:46:46 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm2-e204-208.ccs.ornl.gov [160.91.203.3])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B60CB899AC0;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id B1C5D106BE17; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:07 -0500
Message-ID: <20250202204633.1148872-8-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 07/33] lustre: obd: Reserve metadata
 overstriping flags
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
Cc: Patrick Farrell <farr0186@gmail.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <farr0186@gmail.com>

Reserve flag bits for metadata overstriping.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12273
Lustre-commit: 8b62a8ca9c2e824d9 ("LU-12273 obd: Reserve metadata overstriping flags")
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49707
Reviewed-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c             | 1 +
 include/uapi/linux/lustre/lustre_user.h | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index d4a2b82c961e..e336410a6ed1 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1800,6 +1800,7 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(LMV_MAGIC_V1 != 0x0CD20CD0);
 	BUILD_BUG_ON(LMV_MAGIC_STRIPE != 0x0CD40CD0);
 	BUILD_BUG_ON(LMV_HASH_TYPE_MASK != 0x0000ffff);
+	BUILD_BUG_ON(LMV_HASH_FLAG_OVERSTRIPED != 0x01000000);
 	BUILD_BUG_ON(LMV_HASH_FLAG_FIXED != 0x02000000);
 	BUILD_BUG_ON(LMV_HASH_FLAG_MERGE != 0x04000000);
 	BUILD_BUG_ON(LMV_HASH_FLAG_SPLIT != 0x08000000);
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 0383db67361d..7ee79e21e8ef 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -765,6 +765,8 @@ static inline bool lmv_is_known_hash_type(__u32 type)
 	       (type & LMV_HASH_TYPE_MASK) < LMV_HASH_TYPE_MAX;
 }
 
+/* This flag indicates that overstriping (>1 stripe per MDT) is desired */
+#define LMV_HASH_FLAG_OVERSTRIPED	0x01000000
 /* fixed layout, such directories won't split automatically */
 /* NB, update LMV_HASH_FLAG_KNOWN when adding new flag */
 #define LMV_HASH_FLAG_FIXED		0x02000000
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
