Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2695FC48BDF
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:11:49 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B8FD761360
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:11:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8FD761360
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 609B621F1EE;
	Sun, 13 Jun 2021 16:11:46 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DEAE921C959
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:40 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id ACB21100B005;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A1A739C304; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:11 -0400
Message-Id: <1623625897-17706-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/27] lustre: uapi: add mdt_hash_name
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
Cc: Yang Sheng <ys@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Yang Sheng <ys@whamcloud.com>

Add mdt_hash_name to map LMV_HASH_NAME_* to a string. Will be
used to enhance debugging information.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11776
Lustre-commit: 00141b1a746d4733 ("LU-11776 utils: add support lfs find with mdt hash flag")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39340
Reviewed-by: James Simmons <jsimmons@infradead.org>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8837
Lustre-commit: 5ecd5a5ecfb880236 ("LU-14291 lustre: limit header scope for server only handling")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/43096
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/include/lustre_lmv.h          | 19 +++++++++++++------
 fs/lustre/llite/llite_lib.c             |  2 +-
 include/uapi/linux/lustre/lustre_user.h | 11 +++++++----
 3 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index a74f0a5..6861dd0 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -115,16 +115,20 @@ static inline bool lmv_dir_bad_hash(const struct lmv_stripe_md *lsm)
 
 static inline void lsm_md_dump(int mask, const struct lmv_stripe_md *lsm)
 {
+	bool valid_hash = lmv_dir_bad_hash(lsm);
 	int i;
 
 	/* If lsm_md_magic == LMV_MAGIC_FOREIGN pool_name may not be a null
 	 * terminated string so only print LOV_MAXPOOLNAME bytes.
 	 */
 	CDEBUG(mask,
-	       "magic %#x stripe count %d master mdt %d hash type %#x max inherit %hhu version %d migrate offset %d migrate hash %#x pool %.*s\n",
+	       "magic %#x stripe count %d master mdt %d hash type %s:%#x max inherit %hhu version %d migrate offset %d migrate hash %#x pool %.*s\n",
 	       lsm->lsm_md_magic, lsm->lsm_md_stripe_count,
-	       lsm->lsm_md_master_mdt_index, lsm->lsm_md_hash_type,
-	       lsm->lsm_md_max_inherit, lsm->lsm_md_layout_version,
+	       lsm->lsm_md_master_mdt_index,
+	       valid_hash ? "invalid hash" :
+			    mdt_hash_name[lsm->lsm_md_hash_type & (LMV_HASH_TYPE_MAX - 1)],
+	       lsm->lsm_md_hash_type, lsm->lsm_md_max_inherit,
+	       lsm->lsm_md_layout_version,
 	       lsm->lsm_md_migrate_offset, lsm->lsm_md_migrate_hash,
 	       LOV_MAXPOOLNAME, lsm->lsm_md_pool_name);
 
@@ -404,10 +408,13 @@ static inline bool lmv_user_magic_supported(u32 lum_magic)
 
 #define LMV_DEBUG(mask, lmv, msg)					\
 	CDEBUG(mask,							\
-	       "%s LMV: magic=%#x count=%u index=%u hash=%#x version=%u migrate offset=%u migrate hash=%u.\n",\
+	       "%s LMV: magic=%#x count=%u index=%u hash=%s:%#x version=%u migrate offset=%u migrate hash=%s:%u.\n",\
 	       msg, (lmv)->lmv_magic, (lmv)->lmv_stripe_count,          \
-	       (lmv)->lmv_master_mdt_index, (lmv)->lmv_hash_type,       \
-	       (lmv)->lmv_layout_version, (lmv)->lmv_migrate_offset,    \
+	       (lmv)->lmv_master_mdt_index,				\
+	       mdt_hash_name[(lmv)->lmv_hash_type & (LMV_HASH_TYPE_MAX - 1)],\
+	       (lmv)->lmv_hash_type, (lmv)->lmv_layout_version,		\
+	       (lmv)->lmv_migrate_offset,				\
+	       mdt_hash_name[(lmv)->lmv_migrate_hash & (LMV_HASH_TYPE_MAX - 1)],\
 	       (lmv)->lmv_migrate_hash)
 
 /* master LMV is sane */
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 0c914c9..39bdee0 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2772,7 +2772,7 @@ void ll_open_cleanup(struct super_block *sb, struct ptlrpc_request *open_req)
 
 	op_data->op_fid1 = body->mbo_fid1;
 	op_data->op_open_handle = body->mbo_open_handle;
-	op_data->op_mod_time = get_seconds();
+	op_data->op_mod_time = ktime_get_real_seconds();
 	md_close(exp, op_data, NULL, &close_req);
 	ptlrpc_req_finished(close_req);
 	ll_finish_md_op_data(op_data);
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index bcb9f86..972678f 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -694,11 +694,14 @@ enum lmv_hash_type {
 	LMV_HASH_TYPE_MAX,
 };
 
-#define LMV_HASH_TYPE_DEFAULT LMV_HASH_TYPE_FNV_1A_64
+static __attribute__((unused)) const char *mdt_hash_name[] = {
+	"none",
+	"all_char",
+	"fnv_1a_64",
+	"crush",
+};
 
-#define LMV_HASH_NAME_ALL_CHARS	"all_char"
-#define LMV_HASH_NAME_FNV_1A_64	"fnv_1a_64"
-#define LMV_HASH_NAME_CRUSH	"crush"
+#define LMV_HASH_TYPE_DEFAULT LMV_HASH_TYPE_FNV_1A_64
 
 /* Right now only the lower part(0-16bits) of lmv_hash_type is being used,
  * and the higher part will be the flag to indicate the status of object,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
