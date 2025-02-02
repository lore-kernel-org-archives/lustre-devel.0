Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C194CC02193
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 21:06:09 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMGK0MjCz217f;
	Sun, 02 Feb 2025 12:50:33 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMF13zyXz20yq
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:49:25 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id E336B899ADF;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id E140E106BE16; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:19 -0500
Message-ID: <20250202204633.1148872-20-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 19/33] lustre: lmv: treat unknown hash type
 as sane type
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Hongchao Zhang <hongchao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

Directory migration failure may leave directory hash type as
LMV_HASH_TYPE_UNKNOWN|LMV_HASH_FLAG_BAD_TYPE, which should be treated
as sane hash type on existing directories, otherwise such directories
can't be unlinked.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16717
Lustre-commit: 05cdb71ba68135701 ("LU-16717 mdt: treat unknown hash type as sane type")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50796
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_lmv.h          |  4 ++--
 include/uapi/linux/lustre/lustre_user.h | 10 ++++++++++
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index a2ef550e38d4..5e3dbc52e846 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -443,7 +443,7 @@ static inline bool lmv_is_sane(const struct lmv_mds_md_v1 *lmv)
 	if (le32_to_cpu(lmv->lmv_stripe_count) == 0)
 		goto insane;
 
-	if (!lmv_is_known_hash_type(le32_to_cpu(lmv->lmv_hash_type)))
+	if (!lmv_is_sane_hash_type(le32_to_cpu(lmv->lmv_hash_type)))
 		goto insane;
 
 	return true;
@@ -465,7 +465,7 @@ static inline bool lmv_is_sane2(const struct lmv_mds_md_v1 *lmv)
 	if (le32_to_cpu(lmv->lmv_stripe_count) == 0)
 		goto insane;
 
-	if (!lmv_is_known_hash_type(le32_to_cpu(lmv->lmv_hash_type)))
+	if (!lmv_is_sane_hash_type(le32_to_cpu(lmv->lmv_hash_type)))
 		goto insane;
 
 	return true;
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index c098d119f18c..4b49bb9c370a 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -794,6 +794,16 @@ static inline bool lmv_is_known_hash_type(__u32 type)
 
 #define LMV_HASH_FLAG_KNOWN		0xbe000000
 
+/* migration failure may leave hash type as
+ * LMV_HASH_TYPE_UNKNOWN|LMV_HASH_FLAG_BAD_TYPE, which should be treated as
+ * sane, so such directory can be accessed (resume migration or unlink).
+ */
+static inline bool lmv_is_sane_hash_type(__u32 type)
+{
+	return lmv_is_known_hash_type(type) ||
+	       type == (LMV_HASH_TYPE_UNKNOWN | LMV_HASH_FLAG_BAD_TYPE);
+}
+
 /* both SPLIT and MIGRATION are set for directory split */
 static inline bool lmv_hash_is_splitting(__u32 hash)
 {
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
