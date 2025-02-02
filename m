Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C927EC0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:53:57 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMDZ0d5gz20xk;
	Sun, 02 Feb 2025 12:49:01 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMCT23xcz20th
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:48:05 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id BFB62899AD7;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id BE120106BE16; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:10 -0500
Message-ID: <20250202204633.1148872-11-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 10/33] lustre: csdc: reserve layout bits for
 compress component
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
Cc: Artem Blagodarenko <ablagodarenko@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Bobi Jam <bobijam@whamcloud.com>

Add layout bits for compress component layout.

* lcme_compr_type: compression type (gzip, lz4, lz4hc, lzo, etc.)
* lcme_compr_lvl: compression level (0=default, 1-15)
* lcme_compr_chunk_log_bits: chunk size = 2^(16+chunk_log_bits)

Component pattern:
* LOV_PATTERN_COMPRESS - file contains compressed data chunks and
        cannot be read by a client without decompression support.

Compress component flags:
* LCME_FL_COMPRESS - the component should be compressed with the
        compression algorithm stored in lcme_comp_type, at level
        lcme_comp_level, with chunk size 2^(16+lcme_chunk_log_bits)
* LCME_FL_PARTIAL - the component holds some uncompressed chunks due
        to poor write size/alignment, and may benefit from being
        recompressed as the full file data is available
* LCME_FL_NOCOMPR - the component should not be compressed because
        the data was found to be incompressible, or by user request

WC-bug-id: https://jira.whamcloud.com/browse/LU-10026
Lustre-commit: 570d76dc3fd677357 ("LU-10026 csdc: reserve layout bits for compress component")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49170
Reviewed-by: Artem Blagodarenko <ablagodarenko@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/pack_generic.c         |  1 -
 fs/lustre/ptlrpc/wiretest.c             | 13 +++++++++----
 include/uapi/linux/lustre/lustre_user.h | 17 ++++++++++++++++-
 3 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 16058b9cd9be..61fd122e8e3f 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -2299,7 +2299,6 @@ void lustre_swab_lov_comp_md_v1(struct lov_comp_md_v1 *lum)
 		__swab32s(&ent->lcme_layout_gen);
 		/* no need to swab lcme_dstripe_count */
 		/* no need to swab lcme_cstripe_count */
-		BUILD_BUG_ON(offsetof(typeof(*ent), lcme_padding_1) == 0);
 
 		v1 = (struct lov_user_md_v1 *)((char *)lum + off);
 		stripe_count = v1->lmm_stripe_count;
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index e336410a6ed1..45adb33a9c56 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1676,10 +1676,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_cstripe_count));
 	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_cstripe_count) == 1, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_cstripe_count));
-	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_padding_1) == 46, "found %lld\n",
-		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_padding_1));
-	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding_1) == 2, "found %lld\n",
-		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding_1));
+	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_compr_type) == 46, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_compr_type));
+	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_compr_type) == 1, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_compr_type));
 	BUILD_BUG_ON(LCME_FL_STALE != 0x00000001);
 	BUILD_BUG_ON(LCME_FL_PREF_RD != 0x00000002);
 	BUILD_BUG_ON(LCME_FL_PREF_WR != 0x00000004);
@@ -1689,6 +1689,9 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(LCME_FL_NOSYNC != 0x00000020);
 	BUILD_BUG_ON(LCME_FL_EXTENSION != 0x00000040);
 	BUILD_BUG_ON(LCME_FL_PARITY != 0x00000080);
+	BUILD_BUG_ON(LCME_FL_COMPRESS != 0x00000100);
+	BUILD_BUG_ON(LCME_FL_PARTIAL != 0x00000200);
+	BUILD_BUG_ON(LCME_FL_NOCOMPR != 0x00000400);
 	BUILD_BUG_ON(LCME_FL_NEG != 0x80000000);
 
 	/* Checks for struct lov_comp_md_v1 */
@@ -1749,6 +1752,8 @@ void lustre_assert_wire_constants(void)
 		 (long long)LCM_FL_SYNC_PENDING);
 	LASSERTF(LCM_FL_PCC_RDONLY == 8, "found %lld\n",
 		 (long long)LCM_FL_PCC_RDONLY);
+	LASSERTF(LCM_FL_FLR_MASK == 11, "found %lld\n",
+		 (long long)LCM_FL_FLR_MASK);
 
 	/* Checks for struct lmv_mds_md_v1 */
 	LASSERTF((int)sizeof(struct lmv_mds_md_v1) == 56, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 7ee79e21e8ef..8f648ecd91fa 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -425,6 +425,7 @@ struct ll_ioc_lease_id {
 #define LOV_PATTERN_MDT			0x100
 #define LOV_PATTERN_OVERSTRIPING	0x200
 #define LOV_PATTERN_FOREIGN		0x400
+#define LOV_PATTERN_COMPRESS		0x800
 
 #define LOV_PATTERN_F_MASK	0xffff0000
 #define LOV_PATTERN_F_HOLE	0x40000000 /* there is hole in LOV EA */
@@ -586,6 +587,15 @@ enum lov_comp_md_entry_flags {
 	LCME_FL_NOSYNC		= 0x00000020,	/* FLR: no sync for the mirror */
 	LCME_FL_EXTENSION	= 0x00000040,	/* extension comp, never init */
 	LCME_FL_PARITY		= 0x00000080,	/* EC: a parity code component */
+	LCME_FL_COMPRESS	= 0x00000100,	/* the component should be
+						 * compressed
+						 */
+	LCME_FL_PARTIAL		= 0x00000200,	/* some chunks in the component
+						 * are uncompressed
+						 */
+	LCME_FL_NOCOMPR		= 0x00000400,	/* the component should not be
+						 * compressed
+						 */
 	LCME_FL_NEG		= 0x80000000,	/* used to indicate a negative
 						 * flag, won't be stored on disk
 						 */
@@ -640,7 +650,12 @@ struct lov_comp_md_entry_v1 {
 	__u8			lcme_cstripe_count;	/* code stripe count,
 							 * p value in EC
 							 */
-	__u16			lcme_padding_1;
+	__u8			lcme_compr_type;	/* compress type */
+	__u8			lcme_compr_lvl:4;	/* compress level */
+	__u8			lcme_compr_chunk_log_bits:4;
+				     /* chunk_size = 2^(16+chunk_log_bits)
+				      * i.e. power-of-two multiple of 64KiB
+				      */
 } __attribute__((packed));
 
 #define SEQ_ID_MAX		0x0000FFFF
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
