Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 489A8C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:13 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1A40921CA80;
	Sun, 20 Mar 2022 06:31:12 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 89D3221CA7D
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:09 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id E5319B94;
 Sun, 20 Mar 2022 09:31:07 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D7877E41FE; Sun, 20 Mar 2022 09:31:07 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:15 -0400
Message-Id: <1647783064-20688-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/50] lustre: type cleanups and remove debug
 statements
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

Remove pr_info() left over from earlier debugging.
Remove __u[32|64] from core kernel code that slipped in.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h  | 2 +-
 fs/lustre/lov/lov_pack.c        | 5 +----
 fs/lustre/obdclass/lu_object.c  | 8 ++++----
 fs/lustre/ptlrpc/layout.c       | 2 +-
 fs/lustre/ptlrpc/pack_generic.c | 2 +-
 5 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index a2fe9676..9286bec 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -1451,7 +1451,7 @@ static inline int ldlm_extent_contain(const struct ldlm_extent *ex1,
 	return ex1->start <= ex2->start && ex1->end >= ex2->end;
 }
 
-int ldlm_inodebits_drop(struct ldlm_lock *lock,  __u64 to_drop);
+int ldlm_inodebits_drop(struct ldlm_lock *lock, u64 to_drop);
 
 #endif
 /** @} LDLM */
diff --git a/fs/lustre/lov/lov_pack.c b/fs/lustre/lov/lov_pack.c
index 438bf36..2a080ff 100644
--- a/fs/lustre/lov/lov_pack.c
+++ b/fs/lustre/lov/lov_pack.c
@@ -195,10 +195,8 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 	if (lsm->lsm_magic == LOV_MAGIC_V1 || lsm->lsm_magic == LOV_MAGIC_V3)
 		return lov_lsm_pack_v1v3(lsm, buf, buf_size);
 
-	if (lsm->lsm_magic == LOV_MAGIC_FOREIGN) {
-		pr_info("calling lov_lsm_pack_foreign\n");
+	if (lsm->lsm_magic == LOV_MAGIC_FOREIGN)
 		return lov_lsm_pack_foreign(lsm, buf, buf_size);
-	}
 
 	lmm_size = lov_comp_md_size(lsm);
 	if (buf_size == 0)
@@ -378,7 +376,6 @@ int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
 
 	lmm_size = lov_lsm_pack(lsm, lmmk, lmmk_size);
 	if (lmm_size < 0) {
-		pr_info("lov_lsm_pack return rc = %zd\n", lmm_size);
 		rc = lmm_size;
 		goto out_free;
 	}
diff --git a/fs/lustre/obdclass/lu_object.c b/fs/lustre/obdclass/lu_object.c
index b49e0cd..25b47d8 100644
--- a/fs/lustre/obdclass/lu_object.c
+++ b/fs/lustre/obdclass/lu_object.c
@@ -1810,7 +1810,7 @@ int lu_context_refill(struct lu_context *ctx)
 u32 lu_context_tags_default = LCT_CL_THREAD;
 u32 lu_session_tags_default = LCT_SESSION;
 
-void lu_context_tags_update(__u32 tags)
+void lu_context_tags_update(u32 tags)
 {
 	spin_lock(&lu_context_remembered_guard);
 	lu_context_tags_default |= tags;
@@ -1819,7 +1819,7 @@ void lu_context_tags_update(__u32 tags)
 }
 EXPORT_SYMBOL(lu_context_tags_update);
 
-void lu_context_tags_clear(__u32 tags)
+void lu_context_tags_clear(u32 tags)
 {
 	spin_lock(&lu_context_remembered_guard);
 	lu_context_tags_default &= ~tags;
@@ -1828,7 +1828,7 @@ void lu_context_tags_clear(__u32 tags)
 }
 EXPORT_SYMBOL(lu_context_tags_clear);
 
-void lu_session_tags_update(__u32 tags)
+void lu_session_tags_update(u32 tags)
 {
 	spin_lock(&lu_context_remembered_guard);
 	lu_session_tags_default |= tags;
@@ -1837,7 +1837,7 @@ void lu_session_tags_update(__u32 tags)
 }
 EXPORT_SYMBOL(lu_session_tags_update);
 
-void lu_session_tags_clear(__u32 tags)
+void lu_session_tags_clear(u32 tags)
 {
 	spin_lock(&lu_context_remembered_guard);
 	lu_session_tags_default &= ~tags;
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index f31ab6e..8e3c97d 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -854,7 +854,7 @@ enum rmf_flags {
 	.rmf_name	= (name),				\
 	.rmf_flags	= (flags),				\
 	.rmf_size	= (size),				\
-	.rmf_swab_len	= (int (*)(void *, __u32))(swab_len),	\
+	.rmf_swab_len	= (int (*)(void *, u32))(swab_len),	\
 	.rmf_dumper	= (void (*)(void *))(dumper)		\
 }
 
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index b41f51d..e06c421 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1246,7 +1246,7 @@ u32 lustre_msg_calc_cksum(struct lustre_msg *msg, u32 buf)
 
 #if IS_ENABLED(CONFIG_CRC32)
 		/* about 10x faster than crypto_hash for small buffers */
-		crc = crc32_le(~(__u32)0, (unsigned char *)pb, len);
+		crc = crc32_le(~(u32)0, (unsigned char *)pb, len);
 #elif IS_ENABLED(CONFIG_CRYPTO_CRC32)
 		unsigned int hsize = 4;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
