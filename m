Return-Path: <SRS0=JyPa=L7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C13FC07E9B
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:40 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 430F261C48
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 430F261C48
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 95C93338A1D;
	Wed,  7 Jul 2021 12:11:32 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EEF2F21F8CC
 for <lustre-devel@lists.lustre.org>; Wed,  7 Jul 2021 12:11:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 49CF810090F0;
 Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 45DC79D8B2; Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  7 Jul 2021 15:11:09 -0400
Message-Id: <1625685076-1964-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
References: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/15] lustre: mdt: New connect flag for
 non-open-by-fid lock request
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

From: Oleg Drokin <green@whamcloud.com>

While we removed the 2.1 check for open by fid when open
lock is requested, when you talk to old servers that don't
have that patch - they get an open error, so introduce a compat
flag.

Fixes: c9e0538f2b ("lustre: llite: Introduce inode open heat counter")
WC-bug-id: https://jira.whamcloud.com/browse/LU-10948
Lustre-commit: 72c9a6e5fb6e11fca ("LU-10948 mdt: New connect flag for non-open-by-fid lock request")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43907
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Nunez <jnunez@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c            | 3 ++-
 fs/lustre/llite/namei.c                | 4 +++-
 fs/lustre/obdclass/lprocfs_status.c    | 6 ++++++
 fs/lustre/ptlrpc/wiretest.c            | 2 ++
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 5 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 646bff8..b131edd 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -316,7 +316,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT2_CRUSH | OBD_CONNECT2_LSEEK |
 				   OBD_CONNECT2_GETATTR_PFID |
 				   OBD_CONNECT2_DOM_LVB |
-				   OBD_CONNECT2_REP_MBITS;
+				   OBD_CONNECT2_REP_MBITS |
+				   OBD_CONNECT2_ATOMIC_OPEN_LOCK;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index f42e872..f32aa14 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -1145,7 +1145,9 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	 * we only need to request open lock if it was requested
 	 * for every open
 	 */
-	if (ll_i2sbi(dir)->ll_oc_thrsh_count == 1)
+	if (ll_i2sbi(dir)->ll_oc_thrsh_count == 1 &&
+	    exp_connect_flags2(ll_i2mdexp(dir)) &
+	    OBD_CONNECT2_ATOMIC_OPEN_LOCK)
 		it->it_flags |= MDS_OPEN_LOCK;
 
 	/* Dentry added to dcache tree in ll_lookup_it */
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 0cad91d..db809f3 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -131,6 +131,12 @@
 	"lseek",		/* 0x40000 */
 	"dom_lvb",		/* 0x80000 */
 	"reply_mbits",		/* 0x100000 */
+	"mode_convert",		/* 0x200000 */
+	"batch_rpc",		/* 0x400000 */
+	"pcc_ro",		/* 0x800000 */
+	"mne_nid_type",		/* 0x1000000 */
+	"lock_contend",		/* 0x2000000 */
+	"atomic_open_lock",	/* 0x4000000 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index db97748..9e0eaa7 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1252,6 +1252,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_DOM_LVB);
 	LASSERTF(OBD_CONNECT2_REP_MBITS == 0x100000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_REP_MBITS);
+	LASSERTF(OBD_CONNECT2_ATOMIC_OPEN_LOCK == 0x4000000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_ATOMIC_OPEN_LOCK);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 813e4fc..68bb807 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -840,6 +840,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_LSEEK	      0x40000ULL /* SEEK_HOLE/DATA RPC */
 #define OBD_CONNECT2_DOM_LVB	      0x80000ULL /* pack DOM glimpse data in LVB */
 #define OBD_CONNECT2_REP_MBITS	     0x100000ULL /* match reply by mbits, not xid */
+#define OBD_CONNECT2_ATOMIC_OPEN_LOCK 0x4000000ULL/* request lock on 1st open */
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
  * flag value is not in use on some other branch.  Please clear any such
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
