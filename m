Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 83D4BC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:34:01 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9CAB321FD66;
	Sun, 20 Mar 2022 06:32:45 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2C23621CABE
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:22 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 9A244102E;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 96C42D5A47; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:31:01 -0400
Message-Id: <1647783064-20688-48-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 47/50] lustre: llite: set default LMV hash
 type with 2.12 MDS
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

If default LMV hash type is CRUSH, or unset, it should be converted
to fnv_16_64, because 2.12 MDS doesn't understand this.

Fix LMV_HASH_FLAG_KNOWN to match actual known flags.

Fixes: d956d88c463f ("lustre: dne: introduce new directory hash type: "crush")
Fixes: 7d33e94b9575 ("lustre: lmv: change default hash type to crush")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15502
Lustre-commit: 51c6d596d4f3e82de ("LU-15502 llite: set default LMV hash type with 2.12 MDS
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/46378
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                   | 28 +++++++++++++++++++++++-----
 include/uapi/linux/lustre/lustre_user.h |  2 +-
 2 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 4165726..cfd8184 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -469,7 +469,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 		enum lmv_hash_type type = lump->lum_hash_type &
 					  LMV_HASH_TYPE_MASK;
 
-		if (type == LMV_HASH_TYPE_CRUSH ||
+		if (type >= LMV_HASH_TYPE_CRUSH ||
 		    type == LMV_HASH_TYPE_UNKNOWN)
 			lump->lum_hash_type = (lump->lum_hash_type ^ type) |
 					      LMV_HASH_TYPE_FNV_1A_64;
@@ -590,11 +590,29 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 		case LOV_USER_MAGIC_COMP_V1:
 			lum_size = ((struct lov_comp_md_v1 *)lump)->lcm_size;
 			break;
-		case LMV_USER_MAGIC:
-			if (lump->lmm_magic != cpu_to_le32(LMV_USER_MAGIC))
-				lustre_swab_lmv_user_md((struct lmv_user_md *)lump);
-			lum_size = sizeof(struct lmv_user_md);
+		case LMV_USER_MAGIC: {
+			struct lmv_user_md *lmv = (struct lmv_user_md *)lump;
+
+			/* MDS < 2.14 doesn't support 'crush' hash type, and
+			 * cannot handle unknown hash if client doesn't set a
+			 * valid one. switch to fnv_1a_64.
+			 */
+			if (!(exp_connect_flags2(sbi->ll_md_exp) &
+			      OBD_CONNECT2_CRUSH)) {
+				enum lmv_hash_type type = lmv->lum_hash_type &
+							  LMV_HASH_TYPE_MASK;
+
+				if (type >= LMV_HASH_TYPE_CRUSH ||
+				    type == LMV_HASH_TYPE_UNKNOWN)
+					lmv->lum_hash_type =
+						(lmv->lum_hash_type ^ type) |
+						LMV_HASH_TYPE_FNV_1A_64;
+			}
+			if (lmv->lum_magic != cpu_to_le32(LMV_USER_MAGIC))
+				lustre_swab_lmv_user_md(lmv);
+			lum_size = sizeof(*lmv);
 			break;
+		}
 		case LOV_USER_MAGIC_SPECIFIC: {
 			struct lov_user_md_v3 *v3 =
 				(struct lov_user_md_v3 *)lump;
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 9892fc5..3017148 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -741,7 +741,7 @@ static inline bool lmv_is_known_hash_type(__u32 type)
 #define LMV_HASH_FLAG_LAYOUT_CHANGE	\
 	(LMV_HASH_FLAG_MIGRATION | LMV_HASH_FLAG_SPLIT | LMV_HASH_FLAG_MERGE)
 
-#define LMV_HASH_FLAG_KNOWN		0xfe000000
+#define LMV_HASH_FLAG_KNOWN		0xbe000000
 
 /* both SPLIT and MIGRATION are set for directory split */
 static inline bool lmv_hash_is_splitting(__u32 hash)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
