Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 63665C433EF
	for <lustre-devel@archiver.kernel.org>; Tue, 19 Apr 2022 00:31:20 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D7ABE427322;
	Mon, 18 Apr 2022 17:31:12 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 66A0C425525
 for <lustre-devel@lists.lustre.org>; Mon, 18 Apr 2022 17:31:08 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 2D85510058E4;
 Mon, 18 Apr 2022 20:31:06 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 24CFADA296; Mon, 18 Apr 2022 20:31:06 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 18 Apr 2022 20:31:01 -0400
Message-Id: <1650328264-8763-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1650328264-8763-1-git-send-email-jsimmons@infradead.org>
References: <1650328264-8763-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 4/7] lustre: lmv: change default hash back to
 fnv_1a_64
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

Until performance issue is resolved, change the default directory
hash type from 'crush' back to 'fnv_1a_64'.

Fixes: 92fb134e43a0 ("lustre: lmv: change default hash type to crush")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15692
Lustre-commit: 0090b6f6f6cfd65fc ("LU-15692 lmv: change default hash back to fnv_1a_64")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/46950
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Shuichi Ihara <sihara@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_user.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 3017148..fa01c28 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -707,7 +707,7 @@ static __attribute__((unused)) const char *mdt_hash_name[] = {
 	"crush",
 };
 
-#define LMV_HASH_TYPE_DEFAULT LMV_HASH_TYPE_CRUSH
+#define LMV_HASH_TYPE_DEFAULT LMV_HASH_TYPE_FNV_1A_64
 
 /* Right now only the lower part(0-16bits) of lmv_hash_type is being used,
  * and the higher part will be the flag to indicate the status of object,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
