Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4F59C433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:03 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AA963610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA963610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7AC3532DD7E;
	Wed, 14 Apr 2021 21:03:59 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EBFA132F53E
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:59 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CFC43100F376;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id CE6F76DF70; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:38 -0400
Message-Id: <1618459361-17909-47-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 46/49] lustre: lov: return valid
 stripe_count/size for PFL files
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

From: Emoly Liu <emoly@whamcloud.com>

Dump struct lov_comp_md_v1 in function ll_lov_getstripe_ea_info()
correctly to avoid stripe_count=0 or stripe_size=0 returned by
old interface llapi_file_get_stripe(), which will cause
divide-by-zero for older userspace that calls this ioctl,
e.g. lustre ADIO driver.
The rule is:
- if stripe_count=0, return stripe_count=1;
- if stripe_size=0,
  -- for DoM files, return the stripe size of the second component,
     since the first component of DoM file data is placed on the
     MDT for faster access;
  -- else, return the stripe size of the last component.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14337
Lustre-commit: abf04e7ea356e8b ("LU-14337 lov: return valid stripe_count/size for PFL files")
Signed-off-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41803
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c   | 74 ++++++++++++++++++++++++++++++++++++++----------
 fs/lustre/lov/lov_pack.c |  7 -----
 2 files changed, 59 insertions(+), 22 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index bbb2ff9..2558a60 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2059,6 +2059,7 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 	}
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
+	LASSERT(body); /* checked by mdc_getattr_name */
 
 	lmmsize = body->mbo_eadatasize;
 
@@ -2069,6 +2070,7 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 	}
 
 	lmm = req_capsule_server_sized_get(&req->rq_pill, &RMF_MDT_MD, lmmsize);
+	LASSERT(lmm);
 
 	if (lmm->lmm_magic != cpu_to_le32(LOV_MAGIC_V1) &&
 	    lmm->lmm_magic != cpu_to_le32(LOV_MAGIC_V3) &&
@@ -2083,8 +2085,7 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 	 * little endian. We convert it to host endian before
 	 * passing it to userspace.
 	 */
-	if ((lmm->lmm_magic & __swab32(LOV_MAGIC_MAGIC)) ==
-	    __swab32(LOV_MAGIC_MAGIC)) {
+	if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC) {
 		int stripe_count = 0;
 
 		if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_V1) ||
@@ -2093,24 +2094,67 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 			if (le32_to_cpu(lmm->lmm_pattern) &
 			    LOV_PATTERN_F_RELEASED)
 				stripe_count = 0;
+
+			lustre_swab_lov_user_md((struct lov_user_md *)lmm, 0);
+
+			/* if function called for directory - we should
+			 * avoid swab not existent lsm objects
+			 */
+			if (lmm->lmm_magic == LOV_MAGIC_V1 &&
+			    S_ISREG(body->mbo_mode))
+				lustre_swab_lov_user_md_objects(((struct lov_user_md_v1 *)lmm)->lmm_objects,
+								stripe_count);
+			else if (lmm->lmm_magic == LOV_MAGIC_V3 &&
+				 S_ISREG(body->mbo_mode))
+				lustre_swab_lov_user_md_objects(((struct lov_user_md_v3 *)lmm)->lmm_objects,
+								stripe_count);
+		} else if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_COMP_V1)) {
+			lustre_swab_lov_comp_md_v1((struct lov_comp_md_v1 *)lmm);
 		}
+	}
 
-		lustre_swab_lov_user_md((struct lov_user_md *)lmm, 0);
+	if (lmm->lmm_magic == LOV_MAGIC_COMP_V1) {
+		struct lov_comp_md_v1 *comp_v1 = NULL;
+		struct lov_comp_md_entry_v1 *ent;
+		struct lov_user_md_v1 *v1;
+		u32 off;
+		int i = 0;
+
+		comp_v1 = (struct lov_comp_md_v1 *)lmm;
+		/* Dump the striping information */
+		for (; i < comp_v1->lcm_entry_count; i++) {
+			ent = &comp_v1->lcm_entries[i];
+			off = ent->lcme_offset;
+			v1 = (struct lov_user_md_v1 *)((char *)lmm + off);
+			CDEBUG(D_INFO,
+			       "comp[%d]: stripe_count=%u, stripe_size=%u\n",
+			       i, v1->lmm_stripe_count, v1->lmm_stripe_size);
+		}
 
-		/* if function called for directory - we should
-		 * avoid swab not existent lsm objects
+		/**
+		 * Return valid stripe_count and stripe_size instead of 0 for
+		 * DoM files to avoid divide-by-zero for older userspace that
+		 * calls this ioctl, e.g. lustre ADIO driver.
 		 */
-		if (lmm->lmm_magic == LOV_MAGIC_V1 && S_ISREG(body->mbo_mode))
-			lustre_swab_lov_user_md_objects(
-				((struct lov_user_md_v1 *)lmm)->lmm_objects,
-				stripe_count);
-		else if (lmm->lmm_magic == LOV_MAGIC_V3 &&
-			 S_ISREG(body->mbo_mode))
-			lustre_swab_lov_user_md_objects(
-				((struct lov_user_md_v3 *)lmm)->lmm_objects,
-				stripe_count);
+		if (lmm->lmm_stripe_count == 0)
+			lmm->lmm_stripe_count = 1;
+		if (lmm->lmm_stripe_size == 0) {
+			/* Since the first component of the file data is placed
+			 * on the MDT for faster access, the stripe_size of the
+			 * second one is always that applications which are
+			 * doing large IOs.
+			 */
+			if (lmm->lmm_pattern == LOV_PATTERN_MDT)
+				i = comp_v1->lcm_entry_count > 1 ? 1 : 0;
+			else
+				i = comp_v1->lcm_entry_count > 1 ?
+				    comp_v1->lcm_entry_count - 1 : 0;
+			ent = &comp_v1->lcm_entries[i];
+			off = ent->lcme_offset;
+			v1 = (struct lov_user_md_v1 *)((char *)lmm + off);
+			lmm->lmm_stripe_size = v1->lmm_stripe_size;
+		}
 	}
-
 out:
 	*lmmp = lmm;
 	*lmm_size = lmmsize;
diff --git a/fs/lustre/lov/lov_pack.c b/fs/lustre/lov/lov_pack.c
index 1962472..c97093e 100644
--- a/fs/lustre/lov/lov_pack.c
+++ b/fs/lustre/lov/lov_pack.c
@@ -450,13 +450,6 @@ int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
 	}
 
 	/**
-	 * Return stripe_count=1 instead of 0 for DoM files to avoid
-	 * divide-by-zero for older userspace that calls this ioctl,
-	 * e.g. lustre ADIO driver.
-	 */
-	if ((lum.lmm_stripe_count == 0) && (lum.lmm_pattern & LOV_PATTERN_MDT))
-		lum.lmm_stripe_count = 1;
-	/**
 	 * User specified limited buffer size, usually the buffer is
 	 * from ll_lov_setstripe(), and the buffer can only hold basic
 	 * layout template info.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
