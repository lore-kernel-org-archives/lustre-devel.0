Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE9B3C433ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:20 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6ECBC611ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6ECBC611ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DF9F721FA49;
	Sun, 25 Apr 2021 13:09:47 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2FD9521F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:45 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 20E7A10087C7;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1F28869A85; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:20 -0400
Message-Id: <1619381316-7719-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/29] lustre: lmv: reduce struct lmv_obd size
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

The lmv_obd struct contains lmv_mdt_descs which is large enough
to reference 512 * 512 = 262144 targets, but there can be only
65536 OSTs or MDTs in a single filesystem today.

Shrink the allocation size to match the current limits, reducing
the size of obd_device.u since this is the largest union member.

This reduces the size of each obd_device from 6752 to 4568 bytes.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14055
Lustre-commit: e11deeb1e6d11460 ("LU-14055 lmv: reduce struct lmv_obd size")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41162
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lu_object.h     | 8 ++++----
 fs/lustre/obdclass/lu_tgt_descs.c | 5 ++++-
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/include/lu_object.h b/fs/lustre/include/lu_object.h
index 80cd36d..75bb6c3 100644
--- a/fs/lustre/include/lu_object.h
+++ b/fs/lustre/include/lu_object.h
@@ -1473,10 +1473,10 @@ struct lu_tgt_desc {
 			ltd_connecting:1;  /* target is connecting */
 };
 
-/* number of pointers at 1st level */
-#define TGT_PTRS		(PAGE_SIZE / sizeof(void *))
 /* number of pointers at 2nd level */
 #define TGT_PTRS_PER_BLOCK	(PAGE_SIZE / sizeof(void *))
+/* number of pointers at 1st level - only need as many as max OST/MDT count */
+#define TGT_PTRS		((LOV_ALL_STRIPES + 1) / TGT_PTRS_PER_BLOCK)
 
 struct lu_tgt_desc_idx {
 	struct lu_tgt_desc *ldi_tgt[TGT_PTRS_PER_BLOCK];
@@ -1521,8 +1521,8 @@ struct lu_tgt_descs {
 };
 
 #define LTD_TGT(ltd, index)						\
-	 (ltd)->ltd_tgt_idx[(index) / TGT_PTRS_PER_BLOCK]		\
-			->ldi_tgt[(index) % TGT_PTRS_PER_BLOCK]
+	 (ltd)->ltd_tgt_idx[(index) / TGT_PTRS_PER_BLOCK]->		\
+		ldi_tgt[(index) % TGT_PTRS_PER_BLOCK]
 
 u64 lu_prandom_u64_max(u64 ep_ro);
 void lu_qos_rr_init(struct lu_qos_rr *lqr);
diff --git a/fs/lustre/obdclass/lu_tgt_descs.c b/fs/lustre/obdclass/lu_tgt_descs.c
index a77ce20..ef30ee3 100644
--- a/fs/lustre/obdclass/lu_tgt_descs.c
+++ b/fs/lustre/obdclass/lu_tgt_descs.c
@@ -298,7 +298,7 @@ void lu_tgt_descs_fini(struct lu_tgt_descs *ltd)
 	int i;
 
 	bitmap_free(ltd->ltd_tgt_bitmap);
-	for (i = 0; i < TGT_PTRS; i++)
+	for (i = 0; i < ARRAY_SIZE(ltd->ltd_tgt_idx); i++)
 		kfree(ltd->ltd_tgt_idx[i]);
 	ltd->ltd_tgts_size = 0;
 }
@@ -368,6 +368,9 @@ int ltd_add_tgt(struct lu_tgt_descs *ltd, struct lu_tgt_desc *tgt)
 	if (index >= ltd->ltd_tgts_size) {
 		u32 newsize = 1;
 
+		if (index > TGT_PTRS * TGT_PTRS_PER_BLOCK)
+			return -ENFILE;
+
 		while (newsize < index + 1)
 			newsize = newsize << 1;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
