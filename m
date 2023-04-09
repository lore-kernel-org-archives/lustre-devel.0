Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1A840C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:36:00 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWPb0zNjz22RV;
	Sun,  9 Apr 2023 05:19:31 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWM94CKlz21JV
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:17:25 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 35D541008487;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 349252B3; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:05 -0400
Message-Id: <1681042400-15491-26-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 25/40] lnet: libcfs: remove unused hash code
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

From: Timothy Day <timday@amazon.com>

Two functions which hash then apply a mask
are removed.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16518
Lustre-commit: 239e826876e5e2040 ("LU-16518 misc: use fixed hash code")
Signed-off-by: Timothy Day <timday@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49916
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/libcfs/libcfs_hash.h | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/include/linux/libcfs/libcfs_hash.h b/include/linux/libcfs/libcfs_hash.h
index d3b4875..d60e002 100644
--- a/include/linux/libcfs/libcfs_hash.h
+++ b/include/linux/libcfs/libcfs_hash.h
@@ -829,24 +829,6 @@ static inline int __cfs_hash_theta(struct cfs_hash *hs)
 	return (hash & mask);
 }
 
-/*
- * Generic u32 hash algorithm.
- */
-static inline unsigned
-cfs_hash_u32_hash(const u32 key, unsigned int mask)
-{
-	return ((key * CFS_GOLDEN_RATIO_PRIME_32) & mask);
-}
-
-/*
- * Generic u64 hash algorithm.
- */
-static inline unsigned
-cfs_hash_u64_hash(const u64 key, unsigned int mask)
-{
-	return ((unsigned int)(key * CFS_GOLDEN_RATIO_PRIME_64) & mask);
-}
-
 /** iterate over all buckets in @bds (array of struct cfs_hash_bd) */
 #define cfs_hash_for_each_bd(bds, n, i)	\
 	for (i = 0; i < n && (bds)[i].bd_bucket != NULL; i++)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
