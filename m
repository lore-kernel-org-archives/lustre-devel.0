Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 664FCC0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:21:39 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLbc5ZMJz1yY0;
	Thu, 30 Jan 2025 06:13:32 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLYX2cxyz1xNk
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:11:44 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 019A1899AC0;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id F39AC106BE14; Thu, 30 Jan 2025 09:11:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:10:59 -0500
Message-ID: <20250130141115.950749-10-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 09/25] lustre: pcc: reserve flags for PCC-RO
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
Cc: Feng Lei <flei@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Qian Yingjin <qian@ddn.com>

This patch reserves flags for PCC-RO. It also adds wire check /
test for these new flags.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16700
Lustre-commit: d3874966e4938df175 ("LU-16700 pcc: reserve flags for PCC-RO")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50504
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Feng Lei <flei@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c             |  4 ++++
 include/uapi/linux/lustre/lustre_idl.h  |  4 +++-
 include/uapi/linux/lustre/lustre_user.h | 17 ++++++++++++++++-
 3 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 0da776dc6366..d4a2b82c961e 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -4373,6 +4373,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)LAYOUT_INTENT_RELEASE);
 	LASSERTF(LAYOUT_INTENT_RESTORE == 6, "found %lld\n",
 		 (long long)LAYOUT_INTENT_RESTORE);
+	LASSERTF(LAYOUT_INTENT_PCCRO_SET == 7, "found %lld\n",
+		 (long long)LAYOUT_INTENT_PCCRO_SET);
+	LASSERTF(LAYOUT_INTENT_PCCRO_CLEAR == 8, "found %lld\n",
+		 (long long)LAYOUT_INTENT_PCCRO_CLEAR);
 
 	/* Checks for struct hsm_action_item */
 	LASSERTF((int)sizeof(struct hsm_action_item) == 72, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index a77a005f0ab1..187a807d4809 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2835,7 +2835,9 @@ enum layout_intent_opc {
 	LAYOUT_INTENT_GLIMPSE	= 3,	/** not used */
 	LAYOUT_INTENT_TRUNC	= 4,	/** truncate file, for comp layout */
 	LAYOUT_INTENT_RELEASE	= 5,	/** reserved for HSM release */
-	LAYOUT_INTENT_RESTORE	= 6	/** reserved for HSM restore */
+	LAYOUT_INTENT_RESTORE	= 6,	/** reserved for HSM restore */
+	LAYOUT_INTENT_PCCRO_SET	= 7,	/** set read-only layout for PCC */
+	LAYOUT_INTENT_PCCRO_CLEAR = 8,	/** clear read-only layout */
 };
 
 /* enqueue layout lock with intent */
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 68fddcf4cb59..876d337a3b2b 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -373,6 +373,7 @@ struct ll_ioc_lease_id {
 #define LL_IOC_LADVISE			_IOR('f', 250, struct llapi_lu_ladvise)
 #define LL_IOC_HEAT_GET			_IOWR('f', 251, struct lu_heat)
 #define LL_IOC_HEAT_SET			_IOW('f', 251, __u64)
+#define LL_IOC_PCC_ATTACH		_IOW('f', 252, struct lu_pcc_attach)
 #define LL_IOC_PCC_DETACH		_IOW('f', 252, struct lu_pcc_detach)
 #define LL_IOC_PCC_DETACH_BY_FID	_IOW('f', 252, struct lu_pcc_detach_fid)
 #define LL_IOC_PCC_STATE		_IOR('f', 252, struct lu_pcc_state)
@@ -830,9 +831,18 @@ struct lustre_foreign_type {
  **/
 enum lustre_foreign_types {
 	LU_FOREIGN_TYPE_NONE = 0,
+	/* HSM copytool lhsm_posix */
+	LU_FOREIGN_TYPE_POSIX	= 1,
+	/* Used for PCC-RW. PCCRW components are local to a single archive. */
+	LU_FOREIGN_TYPE_PCCRW	= 2,
+	/* Used for PCC-RO. PCCRO components may be shared between archives. */
+	LU_FOREIGN_TYPE_PCCRO	= 3,
+	/* Used for S3 */
+	LU_FOREIGN_TYPE_S3	= 4,
+	/* Used for DAOS */
 	LU_FOREIGN_TYPE_SYMLINK = 0xda05,
 	/* must be the max/last one */
-	LU_FOREIGN_TYPE_UNKNOWN = 0xffffffff,
+	LU_FOREIGN_TYPE_UNKNOWN	= 0xffffffff,
 };
 
 extern struct lustre_foreign_type lu_foreign_types[];
@@ -1928,6 +1938,8 @@ enum hsm_states {
 	HS_NORELEASE	= 0x00000010,
 	HS_NOARCHIVE	= 0x00000020,
 	HS_LOST		= 0x00000040,
+	HS_PCCRW	= 0x00000080,
+	HS_PCCRO	= 0x00000100,
 };
 
 /* HSM user-setable flags. */
@@ -2356,6 +2368,7 @@ enum lu_pcc_type {
 	LU_PCC_READWRITE	= 0x01,
 	LU_PCC_READONLY		= 0x02,
 	LU_PCC_TYPE_MASK	= LU_PCC_READWRITE | LU_PCC_READONLY,
+	LU_PCC_FL_ASYNC		= 0x10,
 	LU_PCC_MAX
 };
 
@@ -2399,6 +2412,8 @@ enum lu_pcc_state_flags {
 	PCC_STATE_FL_ATTR_VALID		= 0x01,
 	/* The file is being attached into PCC */
 	PCC_STATE_FL_ATTACHING		= 0x02,
+	/* The PCC copy is unlinked */
+	PCC_STATE_FL_UNLINKED		= 0x04,
 };
 
 struct lu_pcc_state {
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
