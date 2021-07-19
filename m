Return-Path: <SRS0=HxeM=ML=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38E86C07E9D
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:33 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EB4BB6113B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB4BB6113B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CB8C534F988;
	Mon, 19 Jul 2021 05:32:25 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DE88734F962
 for <lustre-devel@lists.lustre.org>; Mon, 19 Jul 2021 05:32:17 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 91D016B8;
 Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 89251BD1CC; Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 19 Jul 2021 08:31:58 -0400
Message-Id: <1626697933-6971-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
References: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/18] lustre: uapi: per-user changelog names
 and mask
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
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mikhail Pershin <mpershin@whamcloud.com>

Allow specifying a name for newly-registered changelog users,
rather than the default "clNNN" that is otherwise used. This
allows services to register a "well-known" changelog user,
rather than having to store the changelog username in HA storage
outside of the filesystem.

Each changelog user still has a unique ID appended to it, to allow
the changelog_clear and changelog_deregister commands to be run
using only the ID if necessary/desired. User name can be used to
deregister. User name is also unique per server.

If no name is given, then default "cl" format is used.

With this new functionality, it is possible to specify the name like:
  testfs-MDT0000: Registered changelog userid 'cl13-watcher'

Per-user mask is also added to allow specific operation logging on
per-user basis. Mask can be set only during registration. Resulting
mask from per-server mask and all user masks is used for current
changelog operations.

Lustre-commit: a15eb4f13224e14 ("LU-13055 mdd: per-user changelog names and mask")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43380
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/llog_swab.c          | 17 ++++++++++++-----
 fs/lustre/ptlrpc/wiretest.c             | 23 ++++++++++++-----------
 include/uapi/linux/lustre/lustre_idl.h  | 18 ++++++++++++++++++
 include/uapi/linux/lustre/lustre_user.h |  2 +-
 4 files changed, 43 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/obdclass/llog_swab.c b/fs/lustre/obdclass/llog_swab.c
index 0b83dc3..7bfc304 100644
--- a/fs/lustre/obdclass/llog_swab.c
+++ b/fs/lustre/obdclass/llog_swab.c
@@ -185,19 +185,26 @@ void lustre_swab_llog_rec(struct llog_rec_hdr *rec)
 		 * to compute its location at runtime
 		 */
 		tail = (struct llog_rec_tail *)((char *)&cr->cr +
-						changelog_rec_size(&cr->cr) +
-						cr->cr.cr_namelen);
+						rec->lrh_len - sizeof(*tail));
 		break;
 	}
 
 	case CHANGELOG_USER_REC:
+	case CHANGELOG_USER_REC2:
 	{
-		struct llog_changelog_user_rec *cur =
-			(struct llog_changelog_user_rec *)rec;
+		struct llog_changelog_user_rec2 *cur =
+			(struct llog_changelog_user_rec2 *)rec;
 
 		__swab32s(&cur->cur_id);
 		__swab64s(&cur->cur_endrec);
-		tail = &cur->cur_tail;
+		if (cur->cur_hdr.lrh_type == CHANGELOG_USER_REC2) {
+			__swab32s(&cur->cur_mask);
+			BUILD_BUG_ON(offsetof(typeof(*cur), cur_padding1) == 0);
+			BUILD_BUG_ON(offsetof(typeof(*cur), cur_padding2) == 0);
+			BUILD_BUG_ON(offsetof(typeof(*cur), cur_padding3) == 0);
+		}
+		tail = (struct llog_rec_tail *)((char *)rec +
+						rec->lrh_len - sizeof(*tail));
 		break;
 	}
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 9e0eaa7..c7eb218 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -3567,17 +3567,18 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct llog_logid, lgl_ogen));
 	LASSERTF((int)sizeof(((struct llog_logid *)0)->lgl_ogen) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct llog_logid *)0)->lgl_ogen));
-	BUILD_BUG_ON(OST_SZ_REC != 274730752);
-	BUILD_BUG_ON(MDS_UNLINK_REC != 274801668);
-	BUILD_BUG_ON(MDS_UNLINK64_REC != 275325956);
-	BUILD_BUG_ON(MDS_SETATTR64_REC != 275325953);
-	BUILD_BUG_ON(OBD_CFG_REC != 274857984);
-	BUILD_BUG_ON(LLOG_GEN_REC != 274989056);
-	BUILD_BUG_ON(CHANGELOG_REC != 275120128);
-	BUILD_BUG_ON(CHANGELOG_USER_REC != 275185664);
-	BUILD_BUG_ON(HSM_AGENT_REC != 275251200);
-	BUILD_BUG_ON(LLOG_HDR_MAGIC != 275010873);
-	BUILD_BUG_ON(LLOG_LOGID_MAGIC != 275010875);
+	BUILD_BUG_ON(OST_SZ_REC != 0x10600f00);
+	BUILD_BUG_ON(MDS_UNLINK_REC != 0x10612404);
+	BUILD_BUG_ON(MDS_UNLINK64_REC != 0x10692404);
+	BUILD_BUG_ON(MDS_SETATTR64_REC != 0x10692401);
+	BUILD_BUG_ON(OBD_CFG_REC != 0x10620000);
+	BUILD_BUG_ON(LLOG_GEN_REC != 0x10640000);
+	BUILD_BUG_ON(CHANGELOG_REC != 0x10660000);
+	BUILD_BUG_ON(CHANGELOG_USER_REC != 0x10670000);
+	BUILD_BUG_ON(CHANGELOG_USER_REC2 != 0x10670002);
+	BUILD_BUG_ON(HSM_AGENT_REC != 0x10680000);
+	BUILD_BUG_ON(LLOG_HDR_MAGIC != 0x10645539);
+	BUILD_BUG_ON(LLOG_LOGID_MAGIC != 0x1064553b);
 
 	/* Checks for struct llog_catid */
 	LASSERTF((int)sizeof(struct llog_catid) == 32, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 68bb807..8f49adb 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -2480,6 +2480,7 @@ enum llog_op_type {
 	/* LLOG_JOIN_REC	= LLOG_OP_MAGIC | 0x50000, obsolete  1.8.0 */
 	CHANGELOG_REC		= LLOG_OP_MAGIC | 0x60000,
 	CHANGELOG_USER_REC	= LLOG_OP_MAGIC | 0x70000,
+	CHANGELOG_USER_REC2	= LLOG_OP_MAGIC | 0x70002,
 	HSM_AGENT_REC		= LLOG_OP_MAGIC | 0x80000,
 	LLOG_HDR_MAGIC		= LLOG_OP_MAGIC | 0x45539,
 	LLOG_LOGID_MAGIC	= LLOG_OP_MAGIC | 0x4553b,
@@ -2575,6 +2576,8 @@ struct llog_changelog_rec {
 	struct llog_rec_tail	cr_do_not_use;	/**< for_sizezof_only */
 } __attribute__((packed));
 
+#define CHANGELOG_USER_NAMELEN 16 /* base name including NUL terminator */
+
 struct llog_changelog_user_rec {
 	struct llog_rec_hdr	cur_hdr;
 	__u32			cur_id;
@@ -2583,6 +2586,21 @@ struct llog_changelog_user_rec {
 	struct llog_rec_tail	cur_tail;
 } __attribute__((packed));
 
+/* this is twice the size of CHANGELOG_USER_REC */
+struct llog_changelog_user_rec2 {
+	struct llog_rec_hdr	cur_hdr;
+	__u32			cur_id;
+	/* only for use in relative time comparisons to detect idle users */
+	__u32			cur_time;
+	__u64			cur_endrec;
+	__u32                   cur_mask;
+	__u32			cur_padding1;
+	char			cur_name[CHANGELOG_USER_NAMELEN];
+	__u64			cur_padding2;
+	__u64			cur_padding3;
+	struct llog_rec_tail	cur_tail;
+} __attribute__((packed));
+
 enum agent_req_status {
 	ARS_WAITING,
 	ARS_STARTED,
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 49b013c..0cd3500 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1248,7 +1248,7 @@ enum changelog_rec_type {
 	CL_RESYNC	= 22, /* FLR: file was resync-ed */
 	CL_GETXATTR	= 23,
 	CL_DN_OPEN	= 24, /* denied open */
-	CL_LAST
+	CL_LAST,
 };
 
 static inline const char *changelog_type2str(int type)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
