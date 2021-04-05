Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C85CEC433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:17 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 86A806112E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86A806112E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5E6963284B8;
	Mon,  5 Apr 2021 00:52:37 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 988D821FF34
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:27 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1E3FCEC0;
 Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1BC4C90AAC; Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:51:03 -0400
Message-Id: <1617583870-32029-35-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 34/41] lustre: remove non-static 'inline'
 markings.
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

From: Mr NeilBrown <neilb@suse.de>

There is rarely any point in marking a non-static function as
'inline'.  The result is to compile a state-alone function that other
files can refer to, and also to inline the code where it is used in
the same file.

In many cases the non-static inline functions are not used in the same
file, so the 'inline' marking has no effect.  In other cases it may
have an effect, but it can only be needed in highly performance
critical situations where a function call must be avoided, and that
doesn't seem like in any of these cases.

So just remove the "inline".

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: f0736a6a52ed9581 ("LU-6142 lustre: remove non-static 'inline' markings.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/40289
Reviewed-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/crypto.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index d37f0a9..3d34b3b 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -114,7 +114,7 @@ static int ll_set_context(struct inode *inode, const void *ctx, size_t len,
 
 #define llcrypto_free_ctx	kfree
 
-inline bool ll_sbi_has_test_dummy_encryption(struct ll_sb_info *sbi)
+bool ll_sbi_has_test_dummy_encryption(struct ll_sb_info *sbi)
 {
 	return unlikely(sbi->ll_flags & LL_SBI_TEST_DUMMY_ENCRYPTION);
 }
@@ -126,12 +126,12 @@ static bool ll_dummy_context(struct inode *inode)
 	return sbi ? ll_sbi_has_test_dummy_encryption(sbi) : false;
 }
 
-inline bool ll_sbi_has_encrypt(struct ll_sb_info *sbi)
+bool ll_sbi_has_encrypt(struct ll_sb_info *sbi)
 {
 	return sbi->ll_flags & LL_SBI_ENCRYPT;
 }
 
-inline void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set)
+void ll_sbi_set_encrypt(struct ll_sb_info *sbi, bool set)
 {
 	if (set)
 		sbi->ll_flags |= LL_SBI_ENCRYPT;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
