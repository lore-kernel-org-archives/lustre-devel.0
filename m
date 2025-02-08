Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8096EC0219E
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:37:17 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWwL0fbFz1y63;
	Fri, 07 Feb 2025 16:30:58 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWw42G5pz1xPn
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:44 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 0E4E288F9EB;
 Fri,  7 Feb 2025 19:30:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 0C5FE106BE19; Fri,  7 Feb 2025 19:30:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:17 -0500
Message-ID: <20250208003027.180076-12-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 11/21] lustre: csdc: reserve connect bits for
 compressed layout
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Bobi Jam <bobijam@whamcloud.com>

Add connect data bit for compressed layout (OBD_CONNECT2_COMPRESS)
and another connect data bit to be used (OBD_CONNECT2_LARGE_NID).

Also reserve obd_connect_data::ocd_compr_type which is a bitmask of
supported compression type to be negotiated between client and MDS.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16837
Lustre-commit: 83189aef3b23f18cb ("LU-16837 csdc: reserve connect bits for compressed layout")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51108
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c    |  2 ++
 fs/lustre/ptlrpc/pack_generic.c        |  6 ++++--
 fs/lustre/ptlrpc/wiretest.c            | 13 +++++++++----
 include/uapi/linux/lustre/lustre_idl.h |  4 +++-
 4 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index bde287bbb793..8ecce8901941 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -140,6 +140,8 @@ static const char *const obd_connect_names[] = {
 	"mkdir_replay",			/* 0x10000000 */
 	"dmv_imp_inherit",		/* 0x20000000 */
 	"encryption_fid2path",		/* 0x40000000 */
+	"large_nid",			/* 0x100000000 */
+	"compressed_file",		/* 0x200000000 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index cb7a8a39a380..e1692986dd4c 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1768,9 +1768,11 @@ void lustre_swab_connect(struct obd_connect_data *ocd)
 		__swab16s(&ocd->ocd_maxmodrpcs);
 	BUILD_BUG_ON(!offsetof(typeof(*ocd), padding0));
 	BUILD_BUG_ON(offsetof(typeof(*ocd), padding1) == 0);
-	if (ocd->ocd_connect_flags & OBD_CONNECT_FLAGS2)
+	if (ocd->ocd_connect_flags & OBD_CONNECT_FLAGS2) {
 		__swab64s(&ocd->ocd_connect_flags2);
-	BUILD_BUG_ON(offsetof(typeof(*ocd), padding3) == 0);
+		if (ocd->ocd_connect_flags2 & OBD_CONNECT2_COMPRESS)
+			__swab64s(&ocd->ocd_compr_type);
+	}
 	BUILD_BUG_ON(offsetof(typeof(*ocd), padding4) == 0);
 	BUILD_BUG_ON(offsetof(typeof(*ocd), padding5) == 0);
 	BUILD_BUG_ON(offsetof(typeof(*ocd), padding6) == 0);
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 8cec6a35c692..cc81d4d6717d 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1025,10 +1025,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obd_connect_data, ocd_connect_flags2));
 	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_connect_flags2) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct obd_connect_data *)0)->ocd_connect_flags2));
-	LASSERTF((int)offsetof(struct obd_connect_data, padding3) == 88, "found %lld\n",
-		 (long long)(int)offsetof(struct obd_connect_data, padding3));
-	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->padding3) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct obd_connect_data *)0)->padding3));
+	LASSERTF((int)offsetof(struct obd_connect_data, ocd_compr_type) == 88, "found %lld\n",
+		 (long long)(int)offsetof(struct obd_connect_data, ocd_compr_type));
+	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->ocd_compr_type) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct obd_connect_data *)0)->ocd_compr_type));
 	LASSERTF((int)offsetof(struct obd_connect_data, padding4) == 96, "found %lld\n",
 		 (long long)(int)offsetof(struct obd_connect_data, padding4));
 	LASSERTF((int)sizeof(((struct obd_connect_data *)0)->padding4) == 8, "found %lld\n",
@@ -1255,6 +1255,11 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_DMV_IMP_INHERIT);
 	LASSERTF(OBD_CONNECT2_ENCRYPT_FID2PATH == 0x40000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_ENCRYPT_FID2PATH);
+	LASSERTF(OBD_CONNECT2_LARGE_NID == 0x100000000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_LARGE_NID);
+	LASSERTF(OBD_CONNECT2_COMPRESS == 0x200000000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_COMPRESS);
+
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 2a7299e6ce46..b61fa5c6d9a1 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -788,6 +788,8 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_ENCRYPT_NAME	  0x8000000ULL /* name encrypt */
 #define OBD_CONNECT2_DMV_IMP_INHERIT	 0x20000000ULL /* client handle DMV inheritance */
 #define OBD_CONNECT2_ENCRYPT_FID2PATH	 0x40000000ULL /* fid2path enc file */
+#define OBD_CONNECT2_LARGE_NID		0x100000000ULL /* understands large/IPv6 NIDs */
+#define OBD_CONNECT2_COMPRESS		0x200000000ULL /* compressed file */
 /* XXX README XXX README XXX README XXX README XXX README XXX README XXX
  * Please DO NOT add OBD_CONNECT flags before first ensuring that this value
  * is not in use by some other branch/patch.  Email adilger@whamcloud.com
@@ -839,7 +841,7 @@ struct obd_connect_data {
 	__u16 padding0;		/* READ BELOW! also fix lustre_swab_connect */
 	__u32 padding1;		/* READ BELOW! also fix lustre_swab_connect */
 	__u64 ocd_connect_flags2;/* OBD_CONNECT2_* per above */
-	__u64 padding3;		/* READ BELOW! also fix lustre_swab_connect */
+	__u64 ocd_compr_type;	/* bitmask of supported compression types */
 	__u64 padding4;		/* READ BELOW! also fix lustre_swab_connect */
 	__u64 padding5;		/* READ BELOW! also fix lustre_swab_connect */
 	__u64 padding6;		/* READ BELOW! also fix lustre_swab_connect */
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
