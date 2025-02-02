Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9203AC0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 21:06:22 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMFv5r1Bz1yBw;
	Sun, 02 Feb 2025 12:50:11 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMDV3VCkz20xl
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:48:58 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm2-e204-208.ccs.ornl.gov [160.91.203.3])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id DBAEF899ADE;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id D946A106BE15; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:17 -0500
Message-ID: <20250202204633.1148872-18-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 17/33] lnet: libcfs: Remove unsed
 LASSERT_ATOMIC_* macros
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
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Arshad Hussain <arshad.hussain@aeoncomputing.com>

This is the first up series of patchs which
replaces atomic_t with refcount_t

This patch removes unused LASSERT_ATOMIC_* macros.
There are still:
        LASSERT_ATOMIC_GT
        LASSERT_ATOMIC_GT_LT
        LASSERT_ATOMIC_ZERO
        LASSERT_ATOMIC_POS

macros being used which will be subsequently removed
in following patches. This helps in breaking up patch
logically as changes are large.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16796
Lustre-commit: f875d0c714b548553 ("LU-16796 libcfs: Remove unsed LASSERT_ATOMIC_* macros")
Signed-off-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50870
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/libcfs/libcfs_private.h | 44 ---------------------------
 1 file changed, 44 deletions(-)

diff --git a/include/linux/libcfs/libcfs_private.h b/include/linux/libcfs/libcfs_private.h
index 378c2a56ed67..86d135a65d81 100644
--- a/include/linux/libcfs/libcfs_private.h
+++ b/include/linux/libcfs/libcfs_private.h
@@ -112,26 +112,10 @@ int libcfs_debug_mark_buffer(const char *text);
 #define LASSERT_ATOMIC_EQ(a, v)			\
 	LASSERTF(atomic_read(a) == v, "value: %d\n", atomic_read((a)))
 
-/** assert value of @a is unequal to @v */
-#define LASSERT_ATOMIC_NE(a, v)		\
-	LASSERTF(atomic_read(a) != v, "value: %d\n", atomic_read((a)))
-
-/** assert value of @a is little than @v */
-#define LASSERT_ATOMIC_LT(a, v)		\
-	LASSERTF(atomic_read(a) < v, "value: %d\n", atomic_read((a)))
-
-/** assert value of @a is little/equal to @v */
-#define LASSERT_ATOMIC_LE(a, v)		\
-	LASSERTF(atomic_read(a) <= v, "value: %d\n", atomic_read((a)))
-
 /** assert value of @a is great than @v */
 #define LASSERT_ATOMIC_GT(a, v)		\
 	LASSERTF(atomic_read(a) > v, "value: %d\n", atomic_read((a)))
 
-/** assert value of @a is great/equal to @v */
-#define LASSERT_ATOMIC_GE(a, v)		\
-	LASSERTF(atomic_read(a) >= v, "value: %d\n", atomic_read((a)))
-
 /** assert value of @a is great than @v1 and little than @v2 */
 #define LASSERT_ATOMIC_GT_LT(a, v1, v2)				\
 do {								\
@@ -139,39 +123,11 @@ do {								\
 	LASSERTF(__v > v1 && __v < v2, "value: %d\n", __v);	\
 } while (0)
 
-/** assert value of @a is great than @v1 and little/equal to @v2 */
-#define LASSERT_ATOMIC_GT_LE(a, v1, v2)				\
-do {								\
-	int __v = atomic_read(a);				\
-	LASSERTF(__v > v1 && __v <= v2, "value: %d\n", __v);    \
-} while (0)
-
-/** assert value of @a is great/equal to @v1 and little than @v2 */
-#define LASSERT_ATOMIC_GE_LT(a, v1, v2)				\
-do {								\
-	int __v = atomic_read(a);				\
-	LASSERTF(__v >= v1 && __v < v2, "value: %d\n", __v);    \
-} while (0)
-
-/** assert value of @a is great/equal to @v1 and little/equal to @v2 */
-#define LASSERT_ATOMIC_GE_LE(a, v1, v2)				\
-do {								\
-	int __v = atomic_read(a);				\
-	LASSERTF(__v >= v1 && __v <= v2, "value: %d\n", __v);   \
-} while (0)
-
 #else /* !LASSERT_ATOMIC_ENABLED */
 
 #define LASSERT_ATOMIC_EQ(a, v)		do {} while (0)
-#define LASSERT_ATOMIC_NE(a, v)		do {} while (0)
-#define LASSERT_ATOMIC_LT(a, v)		do {} while (0)
-#define LASSERT_ATOMIC_LE(a, v)		do {} while (0)
 #define LASSERT_ATOMIC_GT(a, v)		do {} while (0)
-#define LASSERT_ATOMIC_GE(a, v)		do {} while (0)
 #define LASSERT_ATOMIC_GT_LT(a, v1, v2)	do {} while (0)
-#define LASSERT_ATOMIC_GT_LE(a, v1, v2)	do {} while (0)
-#define LASSERT_ATOMIC_GE_LT(a, v1, v2)	do {} while (0)
-#define LASSERT_ATOMIC_GE_LE(a, v1, v2)	do {} while (0)
 
 #endif /* LASSERT_ATOMIC_ENABLED */
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
