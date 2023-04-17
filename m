Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7E6A9C77B70
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 14:02:06 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T3k2Wxkz226d;
	Mon, 17 Apr 2023 06:51:14 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0T1K4389z21BC
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:49:09 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 9645E1008492;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 94DD2372; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:12 -0400
Message-Id: <1681739243-29375-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/27] lustre: uapi: fix unused function
 errors
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

Clang has default errors related to unused functions.
The errors related to 'fid_flatten' and 'fid_flatten32'
were resolved by moving the definitions of these
functions to the 'lustre_fid' header. This is a better
place for them, since they are small 'static inline'
functions and has the added benefit of cutting down
code duplication.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16518
Lustre-commit: 0991267eab728e9a6 ("LU-16518 utils: fix unused function errors")
Signed-off-by: Timothy Day <timday@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49901
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_fid.h         | 61 ++-----------------------------
 fs/lustre/llite/lcommon_cl.c           |  4 +--
 include/uapi/linux/lustre/lustre_fid.h | 65 ++++++++++++++++++++++++++++++++++
 3 files changed, 70 insertions(+), 60 deletions(-)

diff --git a/fs/lustre/include/lustre_fid.h b/fs/lustre/include/lustre_fid.h
index 5ebe362..bc3f058 100644
--- a/fs/lustre/include/lustre_fid.h
+++ b/fs/lustre/include/lustre_fid.h
@@ -536,68 +536,13 @@ static inline void ost_fid_build_resid(const struct lu_fid *fid,
 	}
 }
 
-/**
- * Flatten 128-bit FID values into a 64-bit value for use as an inode number.
- * For non-IGIF FIDs this starts just over 2^32, and continues without
- * conflict until 2^64, at which point we wrap the high 24 bits of the SEQ
- * into the range where there may not be many OID values in use, to minimize
- * the risk of conflict.
- *
- * Suppose LUSTRE_SEQ_MAX_WIDTH less than (1 << 24) which is currently true,
- * the time between re-used inode numbers is very long - 2^40 SEQ numbers,
- * or about 2^40 client mounts, if clients create less than 2^24 files/mount.
- */
-static inline u64 fid_flatten(const struct lu_fid *fid)
-{
-	u64 ino;
-	u64 seq;
-
-	if (fid_is_igif(fid)) {
-		ino = lu_igif_ino(fid);
-		return ino;
-	}
-
-	seq = fid_seq(fid);
-
-	ino = (seq << 24) + ((seq >> 24) & 0xffffff0000ULL) + fid_oid(fid);
-
-	return ino ? ino : fid_oid(fid);
-}
-
 static inline u32 fid_hash(const struct lu_fid *f, int bits)
 {
-	/* all objects with same id and different versions will belong to same
+	/*
+	 * All objects with same id and different versions will belong to same
 	 * collisions list.
 	 */
-	return hash_long(fid_flatten(f), bits);
-}
-
-/**
- * map fid to 32 bit value for ino on 32bit systems.
- */
-static inline u32 fid_flatten32(const struct lu_fid *fid)
-{
-	u32 ino;
-	u64 seq;
-
-	if (fid_is_igif(fid)) {
-		ino = lu_igif_ino(fid);
-		return ino;
-	}
-
-	seq = fid_seq(fid) - FID_SEQ_START;
-
-	/* Map the high bits of the OID into higher bits of the inode number so
-	 * that inodes generated at about the same time have a reduced chance
-	 * of collisions. This will give a period of 2^12 = 1024 unique clients
-	 * (from SEQ) and up to min(LUSTRE_SEQ_MAX_WIDTH, 2^20) = 128k objects
-	 * (from OID), or up to 128M inodes without collisions for new files.
-	 */
-	ino = ((seq & 0x000fffffULL) << 12) + ((seq >> 8) & 0xfffff000) +
-	       (seq >> (64 - (40 - 8)) & 0xffffff00) +
-	       (fid_oid(fid) & 0xff000fff) + ((fid_oid(fid) & 0x00fff000) << 8);
-
-	return ino ? ino : fid_oid(fid);
+	return hash_long(fid_flatten64(f), bits);
 }
 
 static inline int lu_fid_diff(const struct lu_fid *fid1,
diff --git a/fs/lustre/llite/lcommon_cl.c b/fs/lustre/llite/lcommon_cl.c
index 2735d5c..9b0c6bc 100644
--- a/fs/lustre/llite/lcommon_cl.c
+++ b/fs/lustre/llite/lcommon_cl.c
@@ -280,7 +280,7 @@ u64 cl_fid_build_ino(const struct lu_fid *fid, bool api32)
 	if (BITS_PER_LONG == 32 || api32)
 		return fid_flatten32(fid);
 	else
-		return fid_flatten(fid);
+		return fid_flatten64(fid);
 }
 
 /*
@@ -292,5 +292,5 @@ u32 cl_fid_build_gen(const struct lu_fid *fid)
 	if (fid_is_igif(fid))
 		return lu_igif_gen(fid);
 
-	return fid_flatten(fid) >> 32;
+	return fid_flatten64(fid) >> 32;
 }
diff --git a/include/uapi/linux/lustre/lustre_fid.h b/include/uapi/linux/lustre/lustre_fid.h
index d8561cd..ef47f45 100644
--- a/include/uapi/linux/lustre/lustre_fid.h
+++ b/include/uapi/linux/lustre/lustre_fid.h
@@ -302,4 +302,69 @@ static inline int lu_fid_cmp(const struct lu_fid *f0,
 
 	return 0;
 }
+
+/**
+ * Flatten 128-bit FID values into a 64-bit value for use as an inode number.
+ * For non-IGIF FIDs this starts just over 2^32, and continues without
+ * conflict until 2^64, at which point we wrap the high 24 bits of the SEQ
+ * into the range where there may not be many OID values in use, to minimize
+ * the risk of conflict.
+ *
+ * Suppose LUSTRE_SEQ_MAX_WIDTH less than (1 << 24) which is currently true,
+ * the time between re-used inode numbers is very long - 2^40 SEQ numbers,
+ * or about 2^40 client mounts, if clients create less than 2^24 files/mount.
+ */
+static inline __u64 fid_flatten64(const struct lu_fid *fid)
+{
+	__u64 ino;
+	__u64 seq;
+
+	if (fid_is_igif(fid)) {
+		ino = lu_igif_ino(fid);
+		return ino;
+	}
+
+	seq = fid_seq(fid);
+
+	ino = (seq << 24) + ((seq >> 24) & 0xffffff0000ULL) + fid_oid(fid);
+
+	return ino ?: fid_oid(fid);
+}
+
+/**
+ * map fid to 32 bit value for ino on 32bit systems.
+ */
+static inline __u32 fid_flatten32(const struct lu_fid *fid)
+{
+	__u32 ino;
+	__u64 seq;
+
+	if (fid_is_igif(fid)) {
+		ino = lu_igif_ino(fid);
+		return ino;
+	}
+
+	seq = fid_seq(fid) - FID_SEQ_START;
+
+	/* Map the high bits of the OID into higher bits of the inode number so
+	 * that inodes generated at about the same time have a reduced chance
+	 * of collisions. This will give a period of 2^12 = 1024 unique clients
+	 * (from SEQ) and up to min(LUSTRE_SEQ_MAX_WIDTH, 2^20) = 128k objects
+	 * (from OID), or up to 128M inodes without collisions for new files.
+	 */
+	ino = ((seq & 0x000fffffULL) << 12) + ((seq >> 8) & 0xfffff000) +
+	      (seq >> (64 - (40-8)) & 0xffffff00) +
+	      (fid_oid(fid) & 0xff000fff) + ((fid_oid(fid) & 0x00fff000) << 8);
+
+	return ino ?: fid_oid(fid);
+}
+
+#if __BITS_PER_LONG == 32
+#define fid_flatten_long fid_flatten32
+#elif __BITS_PER_LONG == 64
+#define fid_flatten_long fid_flatten64
+#else
+#error "Wordsize not 32 or 64"
+#endif
+
 #endif
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
