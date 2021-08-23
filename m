Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 525E1C432BE
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:13 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 151F561360
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 151F561360
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8900B21E011;
	Sun, 22 Aug 2021 19:28:03 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 92D8B21CAB2
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 19:27:53 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 36060100BB03;
 Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 33B5DB6C91; Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 22 Aug 2021 22:27:44 -0400
Message-Id: <1629685666-4533-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
References: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/15] lustre: llite: Proved an abstraction
 for AS_EXITING
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
Cc: Shaun Tancheff <shaun.tancheff@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Shaun Tancheff <shaun.tancheff@hpe.com>

Linux kernel v3.14-7405-g91b0abe36a7b added AS_EXITING flag
AS_EXITING flag is set while address_space mapping is exiting.

Provide an abstraction mapping_clear_exiting() to clear
the AS_EXITING flag. This balances the kernel
mapping_set_existing().

HPE-bug-id: LUS-9977
WC-bug-id: https://jira.whamcloud.com/browse/LU-14787
Lustre-commit: e423a0bd7a4a59be ("LU-14787 libcfs: Proved an abstraction for AS_EXITING")
Signed-off-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-on: https://review.whamcloud.com/44070
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h | 7 +++++++
 fs/lustre/llite/vvp_object.c     | 2 +-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 95e4f45..6b5e318 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -32,6 +32,8 @@
 
 #ifndef LLITE_INTERNAL_H
 #define LLITE_INTERNAL_H
+
+#include <linux/pagemap.h>
 #include <obd.h>
 #include <uapi/linux/lustre/lustre_ver.h>
 #include <lustre_disk.h>	/* for s2sbi */
@@ -1110,6 +1112,11 @@ void ll_cl_add(struct file *file, const struct lu_env *env, struct cl_io *io,
 void ll_cl_remove(struct file *file, const struct lu_env *env);
 struct ll_cl_context *ll_cl_find(struct file *file);
 
+static inline void mapping_clear_exiting(struct address_space *mapping)
+{
+	clear_bit(AS_EXITING, &mapping->flags);
+}
+
 extern const struct address_space_operations ll_aops;
 
 /* llite/file.c */
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index 294df88..8a53458 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -164,7 +164,7 @@ static int vvp_prune(const struct lu_env *env, struct cl_object *obj)
 	}
 
 	ll_truncate_inode_pages_final(inode);
-	clear_bit(AS_EXITING, &inode->i_mapping->flags);
+	mapping_clear_exiting(inode->i_mapping);
 
 	return 0;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
