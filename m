Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E27D6C433F5
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:22:04 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A61EB610A1
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:22:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org A61EB610A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1CD2021F2C2;
	Tue, 21 Sep 2021 19:22:04 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8063A21F2CD
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:12 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 44638490;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 41B0CFF4A8; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:20:00 -0400
Message-Id: <1632277201-6920-24-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 23/24] lustre: ptlrpc: separate out server
 code for wiretest
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

Both the kernel and userland utility wiretest is used by both
client and server to validate data being sent over the network.
Make userland  wiretest buildable on the native Linux client
which lacks server specific data structures. Use of the UAPI
values to hardern testing of user land data passed to the
kernel.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13903
Lustre-commit: 9ef92397c3c806631 ("LU-13903 utils: separate out server code for wiretest")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/43873
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/include/lustre_swab.h        |   1 -
 fs/lustre/obdclass/llog_swab.c         |  33 ------
 fs/lustre/ptlrpc/layout.c              |   3 +-
 fs/lustre/ptlrpc/pack_generic.c        |  13 +--
 fs/lustre/ptlrpc/wiretest.c            | 205 +++++++++++++--------------------
 include/uapi/linux/lustre/lustre_idl.h |  78 +++----------
 6 files changed, 97 insertions(+), 236 deletions(-)

diff --git a/fs/lustre/include/lustre_swab.h b/fs/lustre/include/lustre_swab.h
index bac3636..000e622 100644
--- a/fs/lustre/include/lustre_swab.h
+++ b/fs/lustre/include/lustre_swab.h
@@ -70,7 +70,6 @@
 void lustre_swab_lmv_desc(struct lmv_desc *ld);
 void lustre_swab_lmv_mds_md(union lmv_mds_md *lmm);
 void lustre_swab_lov_desc(struct lov_desc *ld);
-void lustre_swab_gl_desc(union ldlm_gl_desc *desc);
 void lustre_swab_ldlm_intent(struct ldlm_intent *i);
 void lustre_swab_ldlm_request(struct ldlm_request *rq);
 void lustre_swab_ldlm_reply(struct ldlm_reply *r);
diff --git a/fs/lustre/obdclass/llog_swab.c b/fs/lustre/obdclass/llog_swab.c
index 7bfc304..fcc2a48 100644
--- a/fs/lustre/obdclass/llog_swab.c
+++ b/fs/lustre/obdclass/llog_swab.c
@@ -189,25 +189,6 @@ void lustre_swab_llog_rec(struct llog_rec_hdr *rec)
 		break;
 	}
 
-	case CHANGELOG_USER_REC:
-	case CHANGELOG_USER_REC2:
-	{
-		struct llog_changelog_user_rec2 *cur =
-			(struct llog_changelog_user_rec2 *)rec;
-
-		__swab32s(&cur->cur_id);
-		__swab64s(&cur->cur_endrec);
-		if (cur->cur_hdr.lrh_type == CHANGELOG_USER_REC2) {
-			__swab32s(&cur->cur_mask);
-			BUILD_BUG_ON(offsetof(typeof(*cur), cur_padding1) == 0);
-			BUILD_BUG_ON(offsetof(typeof(*cur), cur_padding2) == 0);
-			BUILD_BUG_ON(offsetof(typeof(*cur), cur_padding3) == 0);
-		}
-		tail = (struct llog_rec_tail *)((char *)rec +
-						rec->lrh_len - sizeof(*tail));
-		break;
-	}
-
 	case HSM_AGENT_REC: {
 		struct llog_agent_req_rec *arr =
 			(struct llog_agent_req_rec *)rec;
@@ -225,20 +206,6 @@ void lustre_swab_llog_rec(struct llog_rec_hdr *rec)
 		break;
 	}
 
-	case MDS_SETATTR64_REC:
-	{
-		struct llog_setattr64_rec *lsr =
-			(struct llog_setattr64_rec *)rec;
-
-		lustre_swab_ost_id(&lsr->lsr_oi);
-		__swab32s(&lsr->lsr_uid);
-		__swab32s(&lsr->lsr_uid_h);
-		__swab32s(&lsr->lsr_gid);
-		__swab32s(&lsr->lsr_gid_h);
-		__swab64s(&lsr->lsr_valid);
-		tail = &lsr->lsr_tail;
-		break;
-	}
 	case OBD_CFG_REC:
 		/* these are swabbed as they are consumed */
 		break;
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 2874a41..f31ab6e 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -1052,8 +1052,7 @@ struct req_msg_field RMF_DLM_LVB =
 EXPORT_SYMBOL(RMF_DLM_LVB);
 
 struct req_msg_field RMF_DLM_GL_DESC =
-	DEFINE_MSGF("dlm_gl_desc", 0, sizeof(union ldlm_gl_desc),
-		    lustre_swab_gl_desc, NULL);
+	DEFINE_MSGF("dlm_gl_desc", 0, sizeof(union ldlm_gl_desc), NULL, NULL);
 EXPORT_SYMBOL(RMF_DLM_GL_DESC);
 
 struct req_msg_field RMF_MDT_MD =
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 6710e6b..62e060d 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1738,17 +1738,6 @@ void lustre_swab_generic_32s(u32 *val)
 	__swab32s(val);
 }
 
-void lustre_swab_gl_desc(union ldlm_gl_desc *desc)
-{
-	lustre_swab_lu_fid(&desc->lquota_desc.gl_id.qid_fid);
-	__swab64s(&desc->lquota_desc.gl_flags);
-	__swab64s(&desc->lquota_desc.gl_ver);
-	__swab64s(&desc->lquota_desc.gl_hardlimit);
-	__swab64s(&desc->lquota_desc.gl_softlimit);
-	__swab64s(&desc->lquota_desc.gl_time);
-	BUILD_BUG_ON(offsetof(typeof(desc->lquota_desc), gl_pad2) == 0);
-}
-
 void lustre_swab_ost_lvb_v1(struct ost_lvb_v1 *lvb)
 {
 	__swab64s(&lvb->lvb_size);
@@ -2321,7 +2310,7 @@ void lustre_swab_ldlm_intent(struct ldlm_intent *i)
 static void lustre_swab_ldlm_resource_desc(struct ldlm_resource_desc *r)
 {
 	__swab32s(&r->lr_type);
-	BUILD_BUG_ON(offsetof(typeof(*r), lr_padding) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*r), lr_pad) == 0);
 	lustre_swab_ldlm_res_id(&r->lr_name);
 }
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 1e89974..bf09341 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -24,7 +24,7 @@
  * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
  * Use is subject to license terms.
  *
- * Copyright (c) 2011, 2015, Intel Corporation.
+ * Copyright (c) 2011, 2017, Intel Corporation.
  */
 /*
  * This file is part of Lustre, http://www.lustre.org/
@@ -32,14 +32,15 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
+#ifdef CONFIG_LUSTRE_FS_POSIX_ACL
 #include <linux/fs.h>
 #include <linux/posix_acl_xattr.h>
+#endif /* CONFIG_LUSTRE_FS_POSIX_ACL */
 
 #include <obd_support.h>
 #include <obd_class.h>
 #include <lustre_net.h>
 #include <lustre_disk.h>
-#include <uapi/linux/lustre/lustre_idl.h>
 #include <uapi/linux/lustre/lustre_cfg.h>
 
 #include "ptlrpc_internal.h"
@@ -48,9 +49,6 @@ void lustre_assert_wire_constants(void)
 {
 	/* Wire protocol assertions generated by 'wirecheck'
 	 * (make -C lustre/utils newwiretest)
-	 * running on Linux centos6-bis 2.6.32-358.0.1.el6-head
-	 * #3 SMP Wed Apr 17 17:37:43 CEST 2013
-	 * with gcc version 4.4.6 20110731 (Red Hat 4.4.6-3) (GCC)
 	 */
 
 	/* Constants... */
@@ -257,11 +255,12 @@ void lustre_assert_wire_constants(void)
 		 (long long)MDS_ATTR_KILL_SGID);
 	LASSERTF(MDS_ATTR_CTIME_SET == 0x0000000000002000ULL, "found 0x%.16llxULL\n",
 		 (long long)MDS_ATTR_CTIME_SET);
+	LASSERTF(MDS_ATTR_FROM_OPEN == 0x0000000000004000ULL, "found 0x%.16llxULL\n",
+		 (long long)MDS_ATTR_FROM_OPEN);
 	LASSERTF(MDS_ATTR_BLOCKS == 0x0000000000008000ULL, "found 0x%.16llxULL\n",
 		 (long long)MDS_ATTR_BLOCKS);
 	LASSERTF(MDS_ATTR_PROJID == 0x0000000000010000ULL, "found 0x%.16llxULL\n",
 		 (long long)MDS_ATTR_PROJID);
-
 	LASSERTF(MDS_ATTR_LSIZE == 0x0000000000020000ULL, "found 0x%.16llxULL\n",
 		 (long long)MDS_ATTR_LSIZE);
 	LASSERTF(MDS_ATTR_LBLOCKS == 0x0000000000040000ULL, "found 0x%.16llxULL\n",
@@ -420,30 +419,6 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct lustre_som_attrs *)0)->lsa_blocks) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct lustre_som_attrs *)0)->lsa_blocks));
 
-	/* Checks for struct lustre_mdt_attrs */
-	LASSERTF((int)sizeof(struct lustre_mdt_attrs) == 24, "found %lld\n",
-		 (long long)(int)sizeof(struct lustre_mdt_attrs));
-	LASSERTF((int)offsetof(struct lustre_mdt_attrs, lma_compat) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct lustre_mdt_attrs, lma_compat));
-	LASSERTF((int)sizeof(((struct lustre_mdt_attrs *)0)->lma_compat) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct lustre_mdt_attrs *)0)->lma_compat));
-	LASSERTF((int)offsetof(struct lustre_mdt_attrs, lma_incompat) == 4, "found %lld\n",
-		 (long long)(int)offsetof(struct lustre_mdt_attrs, lma_incompat));
-	LASSERTF((int)sizeof(((struct lustre_mdt_attrs *)0)->lma_incompat) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct lustre_mdt_attrs *)0)->lma_incompat));
-	LASSERTF((int)offsetof(struct lustre_mdt_attrs, lma_self_fid) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct lustre_mdt_attrs, lma_self_fid));
-	LASSERTF((int)sizeof(((struct lustre_mdt_attrs *)0)->lma_self_fid) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct lustre_mdt_attrs *)0)->lma_self_fid));
-	LASSERTF(LMAI_RELEASED == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned int)LMAI_RELEASED);
-	LASSERTF(LMAC_HSM == 0x00000001UL, "found 0x%.8xUL\n",
-		 (unsigned int)LMAC_HSM);
-	LASSERTF(LMAC_NOT_IN_OI == 0x00000004UL, "found 0x%.8xUL\n",
-		 (unsigned int)LMAC_NOT_IN_OI);
-	LASSERTF(LMAC_FID_ON_OST == 0x00000008UL, "found 0x%.8xUL\n",
-		 (unsigned int)LMAC_FID_ON_OST);
-
 	/* Checks for struct ost_id */
 	LASSERTF((int)sizeof(struct ost_id) == 16, "found %lld\n",
 		 (long long)(int)sizeof(struct ost_id));
@@ -459,10 +434,12 @@ void lustre_assert_wire_constants(void)
 		 (long long)FID_SEQ_LLOG);
 	LASSERTF(FID_SEQ_ECHO == 2, "found %lld\n",
 		 (long long)FID_SEQ_ECHO);
-	LASSERTF(FID_SEQ_OST_MDT1 == 3, "found %lld\n",
-		 (long long)FID_SEQ_OST_MDT1);
-	LASSERTF(FID_SEQ_OST_MAX == 9, "found %lld\n",
-		 (long long)FID_SEQ_OST_MAX);
+	LASSERTF(FID_SEQ_UNUSED_START == 3, "found %lld\n",
+		 (long long)FID_SEQ_UNUSED_START);
+	LASSERTF(FID_SEQ_UNUSED_END == 9, "found %lld\n",
+		 (long long)FID_SEQ_UNUSED_END);
+	LASSERTF(FID_SEQ_LLOG_NAME == 10, "found %lld\n",
+		 (long long)FID_SEQ_LLOG_NAME);
 	LASSERTF(FID_SEQ_RSVD == 11, "found %lld\n",
 		 (long long)FID_SEQ_RSVD);
 	LASSERTF(FID_SEQ_IGIF == 12, "found %lld\n",
@@ -479,6 +456,8 @@ void lustre_assert_wire_constants(void)
 		 (long long)FID_SEQ_LOCAL_FILE);
 	LASSERTF(FID_SEQ_DOT_LUSTRE == 0x0000000200000002ULL, "found 0x%.16llxULL\n",
 		 (long long)FID_SEQ_DOT_LUSTRE);
+	LASSERTF(FID_SEQ_LOCAL_NAME == 0x0000000200000003ULL, "found 0x%.16llxULL\n",
+		 (long long)FID_SEQ_LOCAL_NAME);
 	LASSERTF(FID_SEQ_SPECIAL == 0x0000000200000004ULL, "found 0x%.16llxULL\n",
 		 (long long)FID_SEQ_SPECIAL);
 	LASSERTF(FID_SEQ_QUOTA == 0x0000000200000005ULL, "found 0x%.16llxULL\n",
@@ -497,6 +476,8 @@ void lustre_assert_wire_constants(void)
 		 (unsigned int)FID_OID_DOT_LUSTRE);
 	LASSERTF(FID_OID_DOT_LUSTRE_OBF == 0x00000002UL, "found 0x%.8xUL\n",
 		 (unsigned int)FID_OID_DOT_LUSTRE_OBF);
+	LASSERTF(FID_OID_DOT_LUSTRE_LPF == 0x00000003UL, "found 0x%.8xUL\n",
+		 (unsigned int)FID_OID_DOT_LUSTRE_LPF);
 
 	/* Checks for struct lu_dirent */
 	LASSERTF((int)sizeof(struct lu_dirent) == 32, "found %lld\n",
@@ -1112,8 +1093,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT_TRANSNO);
 	LASSERTF(OBD_CONNECT_IBITS == 0x1000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_IBITS);
-	LASSERTF(OBD_CONNECT_JOIN == 0x2000ULL, "found 0x%.16llxULL\n",
-		 OBD_CONNECT_JOIN);
+	LASSERTF(OBD_CONNECT_BARRIER == 0x2000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT_BARRIER);
 	LASSERTF(OBD_CONNECT_ATTRFID == 0x4000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_ATTRFID);
 	LASSERTF(OBD_CONNECT_NODEVOH == 0x8000ULL, "found 0x%.16llxULL\n",
@@ -1204,6 +1185,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT_DIR_STRIPE);
 	LASSERTF(OBD_CONNECT_SUBTREE == 0x800000000000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_SUBTREE);
+	LASSERTF(OBD_CONNECT_BULK_MBITS == 0x2000000000000000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT_BULK_MBITS);
 	LASSERTF(OBD_CONNECT_OBDOPACK == 0x4000000000000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_OBDOPACK);
 	LASSERTF(OBD_CONNECT_FLAGS2 == 0x8000000000000000ULL, "found 0x%.16llxULL\n",
@@ -1502,6 +1485,10 @@ void lustre_assert_wire_constants(void)
 		 OBD_MD_FLGETATTRLOCK);
 	LASSERTF(OBD_MD_FLDATAVERSION == (0x0010000000000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLDATAVERSION);
+	LASSERTF(OBD_MD_CLOSE_INTENT_EXECED == (0x0020000000000000ULL), "found 0x%.16llxULL\n",
+		 OBD_MD_CLOSE_INTENT_EXECED);
+	LASSERTF(OBD_MD_DEFAULT_MEA == (0x0040000000000000ULL), "found 0x%.16llxULL\n",
+		 OBD_MD_DEFAULT_MEA);
 	LASSERTF(OBD_MD_FLOSTLAYOUT == (0x0080000000000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLOSTLAYOUT);
 	LASSERTF(OBD_MD_FLPROJID == (0x0100000000000000ULL), "found 0x%.16llxULL\n",
@@ -1538,6 +1525,8 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(OBD_FL_MMAP != 0x00040000);
 	BUILD_BUG_ON(OBD_FL_RECOV_RESEND != 0x00080000);
 	BUILD_BUG_ON(OBD_FL_NOSPC_BLK != 0x00100000);
+	BUILD_BUG_ON(OBD_FL_FLUSH != 0x00200000);
+	BUILD_BUG_ON(OBD_FL_SHORT_IO != 0x00400000);
 
 	/* Checks for struct lov_ost_data_v1 */
 	LASSERTF((int)sizeof(struct lov_ost_data_v1) == 24, "found %lld\n",
@@ -1616,10 +1605,10 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_layout_gen) == 2, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_layout_gen));
 	BUILD_BUG_ON(LOV_MAXPOOLNAME != 15);
-	LASSERTF((int)offsetof(struct lov_mds_md_v3, lmm_pool_name[16]) == 48, "found %lld\n",
-		 (long long)(int)offsetof(struct lov_mds_md_v3, lmm_pool_name[16]));
-	LASSERTF((int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_pool_name[16]) == 1, "found %lld\n",
-		 (long long)(int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_pool_name[16]));
+	LASSERTF((int)offsetof(struct lov_mds_md_v3, lmm_pool_name[15 + 1]) == 48, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_mds_md_v3, lmm_pool_name[15 + 1]));
+	LASSERTF((int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_pool_name[15 + 1]) == 1, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_pool_name[15 + 1]));
 	LASSERTF((int)offsetof(struct lov_mds_md_v3, lmm_objects[0]) == 48, "found %lld\n",
 		 (long long)(int)offsetof(struct lov_mds_md_v3, lmm_objects[0]));
 	LASSERTF((int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_objects[0]) == 24, "found %lld\n",
@@ -1769,10 +1758,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_padding3));
 	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_padding3) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_padding3));
-	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_pool_name[16]) == 56, "found %lld\n",
-		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_pool_name[16]));
-	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_pool_name[16]) == 1, "found %lld\n",
-		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_pool_name[16]));
+	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_pool_name[15 + 1]) == 56, "found %lld\n",
+		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_pool_name[15 + 1]));
+	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_pool_name[15 + 1]) == 1, "found %lld\n",
+		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_pool_name[15 + 1]));
 	LASSERTF((int)offsetof(struct lmv_mds_md_v1, lmv_stripe_fids[0]) == 56, "found %lld\n",
 		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_stripe_fids[0]));
 	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_stripe_fids[0]) == 16, "found %lld\n",
@@ -1913,6 +1902,11 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(QIF_DQBLKSIZE == 1024, "found %lld\n",
 		 (long long)QIF_DQBLKSIZE);
 
+	LASSERTF(QIF_DQBLKSIZE_BITS == 10, "found %lld\n",
+		 (long long)QIF_DQBLKSIZE_BITS);
+	LASSERTF(QIF_DQBLKSIZE == 1024, "found %lld\n",
+		 (long long)QIF_DQBLKSIZE);
+
 	/* Checks for struct obd_quotactl */
 	LASSERTF((int)sizeof(struct obd_quotactl) == 112, "found %lld\n",
 		 (long long)(int)sizeof(struct obd_quotactl));
@@ -2060,6 +2054,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_BRW_OVER_GRPQUOTA);
 	LASSERTF(OBD_BRW_SOFT_SYNC == 0x4000, "found 0x%.8x\n",
 		 OBD_BRW_SOFT_SYNC);
+	LASSERTF(OBD_BRW_OVER_PRJQUOTA == 0x8000, "found 0x%.8x\n",
+		 OBD_BRW_OVER_PRJQUOTA);
 	LASSERTF(OBD_BRW_RDMA_ONLY == 0x20000, "found 0x%.8x\n",
 		 OBD_BRW_RDMA_ONLY);
 
@@ -3004,6 +3000,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct mdt_rec_resync, rs_padding0));
 	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding0) == 16, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_padding0));
+	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_lease_handle) == 72, "found %lld\n",
+		 (long long)(int)offsetof(struct mdt_rec_resync, rs_lease_handle));
+	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_lease_handle) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct mdt_rec_resync *)0)->rs_lease_handle));
 	LASSERTF((int)offsetof(struct mdt_rec_resync, rs_padding1) == 80, "found %lld\n",
 		 (long long)(int)offsetof(struct mdt_rec_resync, rs_padding1));
 	LASSERTF((int)sizeof(((struct mdt_rec_resync *)0)->rs_padding1) == 8, "found %lld\n",
@@ -3278,6 +3278,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct ldlm_inodebits, bits));
 	LASSERTF((int)sizeof(((struct ldlm_inodebits *)0)->bits) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct ldlm_inodebits *)0)->bits));
+	LASSERTF((int)offsetof(struct ldlm_inodebits, cancel_bits) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct ldlm_inodebits, cancel_bits));
+	LASSERTF((int)sizeof(((struct ldlm_inodebits *)0)->cancel_bits) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct ldlm_inodebits *)0)->cancel_bits));
 	LASSERTF((int)offsetof(struct ldlm_inodebits, li_gid) == 16, "found %lld\n",
 		 (long long)(int)offsetof(struct ldlm_inodebits, li_gid));
 	LASSERTF((int)sizeof(((struct ldlm_inodebits *)0)->li_gid) == 8, "found %lld\n",
@@ -3333,10 +3337,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct ldlm_resource_desc, lr_type));
 	LASSERTF((int)sizeof(((struct ldlm_resource_desc *)0)->lr_type) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct ldlm_resource_desc *)0)->lr_type));
-	LASSERTF((int)offsetof(struct ldlm_resource_desc, lr_padding) == 4, "found %lld\n",
-		 (long long)(int)offsetof(struct ldlm_resource_desc, lr_padding));
-	LASSERTF((int)sizeof(((struct ldlm_resource_desc *)0)->lr_padding) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct ldlm_resource_desc *)0)->lr_padding));
+	LASSERTF((int)offsetof(struct ldlm_resource_desc, lr_pad) == 4, "found %lld\n",
+		 (long long)(int)offsetof(struct ldlm_resource_desc, lr_pad));
+	LASSERTF((int)sizeof(((struct ldlm_resource_desc *)0)->lr_pad) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct ldlm_resource_desc *)0)->lr_pad));
 	LASSERTF((int)offsetof(struct ldlm_resource_desc, lr_name) == 8, "found %lld\n",
 		 (long long)(int)offsetof(struct ldlm_resource_desc, lr_name));
 	LASSERTF((int)sizeof(((struct ldlm_resource_desc *)0)->lr_name) == 32, "found %lld\n",
@@ -3532,6 +3536,15 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct ldlm_gl_lquota_desc *)0)->gl_pad2) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct ldlm_gl_lquota_desc *)0)->gl_pad2));
 
+	/* Checks for struct mgs_send_param */
+	LASSERTF((int)sizeof(struct mgs_send_param) == 1024, "found %lld\n",
+		 (long long)(int)sizeof(struct mgs_send_param));
+	BUILD_BUG_ON(MGS_PARAM_MAXLEN != 1024);
+	LASSERTF((int)offsetof(struct mgs_send_param, mgs_param[1024]) == 1024, "found %lld\n",
+		 (long long)(int)offsetof(struct mgs_send_param, mgs_param[1024]));
+	LASSERTF((int)sizeof(((struct mgs_send_param *)0)->mgs_param[1024]) == 1, "found %lld\n",
+		 (long long)(int)sizeof(((struct mgs_send_param *)0)->mgs_param[1024]));
+
 	/* Checks for struct cfg_marker */
 	LASSERTF((int)sizeof(struct cfg_marker) == 160, "found %lld\n",
 		 (long long)(int)sizeof(struct cfg_marker));
@@ -3589,6 +3602,7 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(CHANGELOG_USER_REC != 0x10670000);
 	BUILD_BUG_ON(CHANGELOG_USER_REC2 != 0x10670002);
 	BUILD_BUG_ON(HSM_AGENT_REC != 0x10680000);
+	BUILD_BUG_ON(UPDATE_REC != 0x106a0000);
 	BUILD_BUG_ON(LLOG_HDR_MAGIC != 0x10645539);
 	BUILD_BUG_ON(LLOG_LOGID_MAGIC != 0x1064553b);
 
@@ -3727,42 +3741,6 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct llog_unlink64_rec *)0)->lur_padding3) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct llog_unlink64_rec *)0)->lur_padding3));
 
-	/* Checks for struct llog_setattr64_rec */
-	LASSERTF((int)sizeof(struct llog_setattr64_rec) == 64, "found %lld\n",
-		 (long long)(int)sizeof(struct llog_setattr64_rec));
-	LASSERTF((int)offsetof(struct llog_setattr64_rec, lsr_hdr) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_setattr64_rec, lsr_hdr));
-	LASSERTF((int)sizeof(((struct llog_setattr64_rec *)0)->lsr_hdr) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_setattr64_rec *)0)->lsr_hdr));
-	LASSERTF((int)offsetof(struct llog_setattr64_rec, lsr_oi) == 16, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_setattr64_rec, lsr_oi));
-	LASSERTF((int)sizeof(((struct llog_setattr64_rec *)0)->lsr_oi) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_setattr64_rec *)0)->lsr_oi));
-	LASSERTF((int)offsetof(struct llog_setattr64_rec, lsr_uid) == 32, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_setattr64_rec, lsr_uid));
-	LASSERTF((int)sizeof(((struct llog_setattr64_rec *)0)->lsr_uid) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_setattr64_rec *)0)->lsr_uid));
-	LASSERTF((int)offsetof(struct llog_setattr64_rec, lsr_uid_h) == 36, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_setattr64_rec, lsr_uid_h));
-	LASSERTF((int)sizeof(((struct llog_setattr64_rec *)0)->lsr_uid_h) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_setattr64_rec *)0)->lsr_uid_h));
-	LASSERTF((int)offsetof(struct llog_setattr64_rec, lsr_gid) == 40, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_setattr64_rec, lsr_gid));
-	LASSERTF((int)sizeof(((struct llog_setattr64_rec *)0)->lsr_gid) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_setattr64_rec *)0)->lsr_gid));
-	LASSERTF((int)offsetof(struct llog_setattr64_rec, lsr_gid_h) == 44, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_setattr64_rec, lsr_gid_h));
-	LASSERTF((int)sizeof(((struct llog_setattr64_rec *)0)->lsr_gid_h) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_setattr64_rec *)0)->lsr_gid_h));
-	LASSERTF((int)offsetof(struct llog_setattr64_rec, lsr_valid) == 48, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_setattr64_rec, lsr_valid));
-	LASSERTF((int)sizeof(((struct llog_setattr64_rec *)0)->lsr_valid) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_setattr64_rec *)0)->lsr_valid));
-	LASSERTF((int)offsetof(struct llog_setattr64_rec, lsr_tail) == 56, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_setattr64_rec, lsr_tail));
-	LASSERTF((int)sizeof(((struct llog_setattr64_rec *)0)->lsr_tail) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_setattr64_rec *)0)->lsr_tail));
-
 	/* Checks for struct llog_size_change_rec */
 	LASSERTF((int)sizeof(struct llog_size_change_rec) == 64, "found %lld\n",
 		 (long long)(int)sizeof(struct llog_size_change_rec));
@@ -3831,6 +3809,18 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct changelog_rec *)0)->cr_pfid) == 16, "found %lld\n",
 		 (long long)(int)sizeof(((struct changelog_rec *)0)->cr_pfid));
 
+	/* Checks for struct changelog_ext_rename */
+	LASSERTF((int)sizeof(struct changelog_ext_rename) == 32, "found %lld\n",
+		 (long long)(int)sizeof(struct changelog_ext_rename));
+	LASSERTF((int)offsetof(struct changelog_ext_rename, cr_sfid) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct changelog_ext_rename, cr_sfid));
+	LASSERTF((int)sizeof(((struct changelog_ext_rename *)0)->cr_sfid) == 16, "found %lld\n",
+		 (long long)(int)sizeof(((struct changelog_ext_rename *)0)->cr_sfid));
+	LASSERTF((int)offsetof(struct changelog_ext_rename, cr_spfid) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct changelog_ext_rename, cr_spfid));
+	LASSERTF((int)sizeof(((struct changelog_ext_rename *)0)->cr_spfid) == 16, "found %lld\n",
+		 (long long)(int)sizeof(((struct changelog_ext_rename *)0)->cr_spfid));
+
 	/* Checks for struct changelog_setinfo */
 	LASSERTF((int)sizeof(struct changelog_setinfo) == 12, "found %lld\n",
 		 (long long)(int)sizeof(struct changelog_setinfo));
@@ -3859,30 +3849,6 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct llog_changelog_rec *)0)->cr_do_not_use) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct llog_changelog_rec *)0)->cr_do_not_use));
 
-	/* Checks for struct llog_changelog_user_rec */
-	LASSERTF((int)sizeof(struct llog_changelog_user_rec) == 40, "found %lld\n",
-		 (long long)(int)sizeof(struct llog_changelog_user_rec));
-	LASSERTF((int)offsetof(struct llog_changelog_user_rec, cur_hdr) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_changelog_user_rec, cur_hdr));
-	LASSERTF((int)sizeof(((struct llog_changelog_user_rec *)0)->cur_hdr) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_changelog_user_rec *)0)->cur_hdr));
-	LASSERTF((int)offsetof(struct llog_changelog_user_rec, cur_id) == 16, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_changelog_user_rec, cur_id));
-	LASSERTF((int)sizeof(((struct llog_changelog_user_rec *)0)->cur_id) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_changelog_user_rec *)0)->cur_id));
-	LASSERTF((int)offsetof(struct llog_changelog_user_rec, cur_padding) == 20, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_changelog_user_rec, cur_padding));
-	LASSERTF((int)sizeof(((struct llog_changelog_user_rec *)0)->cur_padding) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_changelog_user_rec *)0)->cur_padding));
-	LASSERTF((int)offsetof(struct llog_changelog_user_rec, cur_endrec) == 24, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_changelog_user_rec, cur_endrec));
-	LASSERTF((int)sizeof(((struct llog_changelog_user_rec *)0)->cur_endrec) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_changelog_user_rec *)0)->cur_endrec));
-	LASSERTF((int)offsetof(struct llog_changelog_user_rec, cur_tail) == 32, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_changelog_user_rec, cur_tail));
-	LASSERTF((int)sizeof(((struct llog_changelog_user_rec *)0)->cur_tail) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_changelog_user_rec *)0)->cur_tail));
-
 	/* Checks for struct llog_gen */
 	LASSERTF((int)sizeof(struct llog_gen) == 16, "found %lld\n",
 		 (long long)(int)sizeof(struct llog_gen));
@@ -3946,18 +3912,6 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct llog_log_hdr, llh_tgtuuid));
 	LASSERTF((int)sizeof(((struct llog_log_hdr *)0)->llh_tgtuuid) == 40, "found %lld\n",
 		 (long long)(int)sizeof(((struct llog_log_hdr *)0)->llh_tgtuuid));
-	LASSERTF((int)offsetof(struct llog_log_hdr, llh_reserved) == 84, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_log_hdr, llh_reserved));
-	LASSERTF((int)sizeof(((struct llog_log_hdr *)0)->llh_reserved) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_log_hdr *)0)->llh_reserved));
-	LASSERTF((int)offsetof(struct llog_log_hdr, llh_bitmap) == 88, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_log_hdr, llh_bitmap));
-	LASSERTF((int)sizeof(((struct llog_log_hdr *)0)->llh_bitmap) == 8096, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_log_hdr *)0)->llh_bitmap));
-	LASSERTF((int)offsetof(struct llog_log_hdr, llh_tail) == 8184, "found %lld\n",
-		 (long long)(int)offsetof(struct llog_log_hdr, llh_tail));
-	LASSERTF((int)sizeof(((struct llog_log_hdr *)0)->llh_tail) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct llog_log_hdr *)0)->llh_tail));
 	BUILD_BUG_ON(LLOG_F_ZAP_WHEN_EMPTY != 0x00000001);
 	BUILD_BUG_ON(LLOG_F_IS_CAT != 0x00000002);
 	BUILD_BUG_ON(LLOG_F_IS_PLAIN != 0x00000004);
@@ -4018,7 +3972,9 @@ void lustre_assert_wire_constants(void)
 	BUILD_BUG_ON(LLOG_CHANGELOG_REPL_CTXT != 13);
 	BUILD_BUG_ON(LLOG_CHANGELOG_USER_ORIG_CTXT != 14);
 	BUILD_BUG_ON(LLOG_AGENT_ORIG_CTXT != 15);
-	BUILD_BUG_ON(LLOG_MAX_CTXTS != 16);
+	BUILD_BUG_ON(LLOG_UPDATELOG_ORIG_CTXT != 16);
+	BUILD_BUG_ON(LLOG_UPDATELOG_REPL_CTXT != 17);
+	BUILD_BUG_ON(LLOG_MAX_CTXTS != 18);
 
 	/* Checks for struct llogd_conn_body */
 	LASSERTF((int)sizeof(struct llogd_conn_body) == 40, "found %lld\n",
@@ -4036,7 +3992,7 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct llogd_conn_body *)0)->lgdc_ctxt_idx) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct llogd_conn_body *)0)->lgdc_ctxt_idx));
 
-	/* Checks for struct fiemap_info_key */
+	/* Checks for struct ll_fiemap_info_key */
 	LASSERTF((int)sizeof(struct ll_fiemap_info_key) == 248, "found %lld\n",
 		 (long long)(int)sizeof(struct ll_fiemap_info_key));
 	LASSERTF((int)offsetof(struct ll_fiemap_info_key, lfik_name[8]) == 8, "found %lld\n",
@@ -4167,7 +4123,6 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct mgs_config_body, mcb_units));
 	LASSERTF((int)sizeof(((struct mgs_config_body *)0)->mcb_units) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct mgs_config_body *)0)->mcb_units));
-
 	BUILD_BUG_ON(MGS_CFG_T_CONFIG != 0);
 	BUILD_BUG_ON(MGS_CFG_T_SPTLRPC != 1);
 	BUILD_BUG_ON(MGS_CFG_T_RECOVER != 2);
@@ -4608,6 +4563,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct hsm_current_action, hca_location));
 	LASSERTF((int)sizeof(((struct hsm_current_action *)0)->hca_location) == 16, "found %lld\n",
 		 (long long)(int)sizeof(((struct hsm_current_action *)0)->hca_location));
+	BUILD_BUG_ON(HPS_NONE != 0);
+	BUILD_BUG_ON(HPS_WAITING != 1);
+	BUILD_BUG_ON(HPS_RUNNING != 2);
+	BUILD_BUG_ON(HPS_DONE != 3);
 	BUILD_BUG_ON(HUA_NONE != 1);
 	BUILD_BUG_ON(HUA_ARCHIVE != 10);
 	BUILD_BUG_ON(HUA_RESTORE != 11);
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 77a64f2..7d92264 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -150,35 +150,6 @@ struct lu_seq_range_array {
  */
 
 /**
- * Flags for lustre_mdt_attrs::lma_compat and lustre_mdt_attrs::lma_incompat.
- * Deprecated since HSM and SOM attributes are now stored in separate on-disk
- * xattr.
- */
-enum lma_compat {
-	LMAC_HSM	= 0x00000001,
-/*	LMAC_SOM	= 0x00000002, obsolete since 2.8.0 */
-	LMAC_NOT_IN_OI	= 0x00000004, /* the object does NOT need OI mapping */
-	LMAC_FID_ON_OST = 0x00000008, /* For OST-object, its OI mapping is
-				       * under /O/<seq>/d<x>.
-				       */
-};
-
-/**
- * Masks for all features that should be supported by a Lustre version to
- * access a specific file.
- * This information is stored in lustre_mdt_attrs::lma_incompat.
- */
-enum lma_incompat {
-	LMAI_RELEASED		= 0x00000001, /* file is released */
-	LMAI_AGENT		= 0x00000002, /* agent inode */
-	LMAI_REMOTE_PARENT	= 0x00000004, /* the parent of the object
-					       * is on the remote MDT
-					       */
-};
-
-#define LMA_INCOMPAT_SUPP	(LMAI_AGENT | LMAI_REMOTE_PARENT)
-
-/**
  * fid constants
  */
 enum {
@@ -293,8 +264,8 @@ enum fid_seq {
 	FID_SEQ_OST_MDT0	= 0,
 	FID_SEQ_LLOG		= 1, /* unnamed llogs */
 	FID_SEQ_ECHO		= 2,
-	FID_SEQ_OST_MDT1	= 3,
-	FID_SEQ_OST_MAX		= 9, /* Max MDT count before OST_on_FID */
+	FID_SEQ_UNUSED_START	= 3, /* Unused */
+	FID_SEQ_UNUSED_END	= 9, /* Unused */
 	FID_SEQ_LLOG_NAME	= 10, /* named llogs */
 	FID_SEQ_RSVD		= 11,
 	FID_SEQ_IGIF		= 12,
@@ -340,6 +311,7 @@ enum special_oid {
 enum dot_lustre_oid {
 	FID_OID_DOT_LUSTRE	= 1UL,
 	FID_OID_DOT_LUSTRE_OBF	= 2UL,
+	FID_OID_DOT_LUSTRE_LPF	= 3UL,
 };
 
 /** OID for FID_SEQ_ROOT */
@@ -721,11 +693,8 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT_LARGE_ACL		0x200ULL /* more than 32 ACL entries */
 #define OBD_CONNECT_TRANSNO		0x800ULL /*replay sends init transno */
 #define OBD_CONNECT_IBITS	       0x1000ULL /* not checked in 2.11+ */
-#define OBD_CONNECT_JOIN	       0x2000ULL /*files can be concatenated.
-						  *We do not support JOIN FILE
-						  *anymore, reserve this flags
-						  *just for preventing such bit
-						  *to be reused.
+#define OBD_CONNECT_BARRIER	       0x2000ULL /* write barrier. Resevered to
+						  * avoid use on client.
 						  */
 #define OBD_CONNECT_ATTRFID	       0x4000ULL /*Server can GetAttr By Fid*/
 #define OBD_CONNECT_NODEVOH	       0x8000ULL /*No open hndl on specl nodes*/
@@ -1214,8 +1183,6 @@ static inline __u32 lov_mds_md_size(__u16 stripes, __u32 lmm_magic)
 							 * requests means the
 							 * client holds the lock
 							 */
-#define OBD_MD_FLOBJCOUNT	(0x0000400000000000ULL) /* for multiple destroy */
-
 /*	OBD_MD_FLRMTLSETFACL	(0x0001000000000000ULL) lfs lsetfacl, obsolete */
 /*	OBD_MD_FLRMTLGETFACL	(0x0002000000000000ULL) lfs lgetfacl, obsolete */
 /*	OBD_MD_FLRMTRSETFACL	(0x0004000000000000ULL) lfs rsetfacl, obsolete */
@@ -1293,6 +1260,7 @@ struct hsm_state_set {
 				      * space for unstable pages; asking
 				      * it to sync quickly
 				      */
+#define OBD_BRW_OVER_PRJQUOTA 0x8000 /* Running out of project quota */
 #define OBD_BRW_RDMA_ONLY    0x20000 /* RPC contains RDMA-only pages*/
 
 #define OBD_MAX_GRANT 0x7fffffffUL /* Max grant allowed to one client: 2 GiB */
@@ -2272,8 +2240,8 @@ struct ldlm_intent {
 };
 
 struct ldlm_resource_desc {
-	enum ldlm_type lr_type;
-	__u32 lr_padding;	/* also fix lustre_swab_ldlm_resource_desc */
+	enum ldlm_type	   lr_type;
+	__u32		   lr_pad; /* also fix lustre_swab_ldlm_resource_desc */
 	struct ldlm_res_id lr_name;
 };
 
@@ -2435,6 +2403,8 @@ enum llog_ctxt_id {
 	/* for multiple changelog consumers */
 	LLOG_CHANGELOG_USER_ORIG_CTXT = 14,
 	LLOG_AGENT_ORIG_CTXT = 15, /**< agent requests generation on cdt */
+	LLOG_UPDATELOG_ORIG_CTXT = 16, /* update log. reserve for the client */
+	LLOG_UPDATELOG_REPL_CTXT = 17, /* update log. reserve for the client */
 	LLOG_MAX_CTXTS
 };
 
@@ -2478,6 +2448,9 @@ enum llog_op_type {
 	CHANGELOG_USER_REC	= LLOG_OP_MAGIC | 0x70000,
 	CHANGELOG_USER_REC2	= LLOG_OP_MAGIC | 0x70002,
 	HSM_AGENT_REC		= LLOG_OP_MAGIC | 0x80000,
+	UPDATE_REC		= LLOG_OP_MAGIC | 0xa0000, /* Resevered to avoid
+							    * use on client.
+							    */
 	LLOG_HDR_MAGIC		= LLOG_OP_MAGIC | 0x45539,
 	LLOG_LOGID_MAGIC	= LLOG_OP_MAGIC | 0x4553b,
 };
@@ -2572,31 +2545,6 @@ struct llog_changelog_rec {
 	struct llog_rec_tail	cr_do_not_use;	/**< for_sizezof_only */
 } __attribute__((packed));
 
-#define CHANGELOG_USER_NAMELEN 16 /* base name including NUL terminator */
-
-struct llog_changelog_user_rec {
-	struct llog_rec_hdr	cur_hdr;
-	__u32			cur_id;
-	__u32			cur_padding;
-	__u64			cur_endrec;
-	struct llog_rec_tail	cur_tail;
-} __attribute__((packed));
-
-/* this is twice the size of CHANGELOG_USER_REC */
-struct llog_changelog_user_rec2 {
-	struct llog_rec_hdr	cur_hdr;
-	__u32			cur_id;
-	/* only for use in relative time comparisons to detect idle users */
-	__u32			cur_time;
-	__u64			cur_endrec;
-	__u32                   cur_mask;
-	__u32			cur_padding1;
-	char			cur_name[CHANGELOG_USER_NAMELEN];
-	__u64			cur_padding2;
-	__u64			cur_padding3;
-	struct llog_rec_tail	cur_tail;
-} __attribute__((packed));
-
 enum agent_req_status {
 	ARS_WAITING,
 	ARS_STARTED,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
