Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAFF5C48BDF
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:25 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7BB33611CA
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BB33611CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2CB4321F35A;
	Sun, 13 Jun 2021 16:12:07 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9A30121F215
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:46 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E2D55100B05E;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E174C9C306; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:32 -0400
Message-Id: <1623625897-17706-23-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 22/27] lustre: lmv: change default hash type
 to crush
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

Change the default hash type to CRUSH to minimize the number
of directory entries that need to be migrated.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14459
Lustre-commit: bb60caa1c6e7c14c ("LU-14459 lmv: change default hash type to crush")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43684
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                   | 26 ++++++++++----------------
 include/uapi/linux/lustre/lustre_user.h |  2 +-
 2 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index d7466f3..bd15fee 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -417,23 +417,17 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	    !OBD_FAIL_CHECK(OBD_FAIL_LLITE_NO_CHECK_DEAD))
 		return -ENOENT;
 
+	/* MDS < 2.14 doesn't support 'crush' hash type, and cannot handle
+	 * unknown hash if client doesn't set a valid one. switch to fnv_1a_64.
+	 */
 	if (!(exp_connect_flags2(sbi->ll_md_exp) & OBD_CONNECT2_CRUSH)) {
-		if ((lump->lum_hash_type & LMV_HASH_TYPE_MASK) ==
-		     LMV_HASH_TYPE_CRUSH) {
-			/* if server doesn't support 'crush' hash type,
-			 * switch to fnv_1a_64.
-			 */
-			lump->lum_hash_type &= ~LMV_HASH_TYPE_MASK;
-			lump->lum_hash_type |= LMV_HASH_TYPE_FNV_1A_64;
-		} else if ((lump->lum_hash_type & LMV_HASH_TYPE_MASK) ==
-			    LMV_HASH_TYPE_UNKNOWN) {
-			/* from 2.14 MDT will choose default hash type if client
-			 * doesn't set a valid one, while old server doesn't
-			 * handle it.
-			 */
-			lump->lum_hash_type &= ~LMV_HASH_TYPE_MASK;
-			lump->lum_hash_type |= LMV_HASH_TYPE_DEFAULT;
-		}
+		enum lmv_hash_type type = lump->lum_hash_type &
+					  LMV_HASH_TYPE_MASK;
+
+		if (type == LMV_HASH_TYPE_CRUSH ||
+		    type == LMV_HASH_TYPE_UNKNOWN)
+			lump->lum_hash_type = (lump->lum_hash_type ^ type) |
+					      LMV_HASH_TYPE_FNV_1A_64;
 	}
 
 	if (unlikely(!lmv_user_magic_supported(cpu_to_le32(lump->lum_magic))))
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index aae6642..49b013c 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -701,7 +701,7 @@ static __attribute__((unused)) const char *mdt_hash_name[] = {
 	"crush",
 };
 
-#define LMV_HASH_TYPE_DEFAULT LMV_HASH_TYPE_FNV_1A_64
+#define LMV_HASH_TYPE_DEFAULT LMV_HASH_TYPE_CRUSH
 
 /* Right now only the lower part(0-16bits) of lmv_hash_type is being used,
  * and the higher part will be the flag to indicate the status of object,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
