Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 68118C77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:43:59 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWX93K1Gz217H;
	Sun,  9 Apr 2023 05:25:13 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWWw3ymlz22cZ
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:25:00 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 771451008495;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 759FF2B2; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:19 -0400
Message-Id: <1681042400-15491-40-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 39/40] lustre: uapi: add DMV_IMP_INHERIT
 connect flag
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

Add OBD_CONNECT2_DMV_IMP_INHERIT for implicit default LMV inherit.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15971
Lustre-commit: 203745e7b07101bb6 ("LU-15971 uapi: add DMV_IMP_INHERIT connect flag")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/47788
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/wiretest.c            | 2 ++
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 2 files changed, 3 insertions(+)

diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 2c02430..472d155c 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1245,6 +1245,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_ATOMIC_OPEN_LOCK);
 	LASSERTF(OBD_CONNECT2_ENCRYPT_NAME == 0x8000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_ENCRYPT_NAME);
+	LASSERTF(OBD_CONNECT2_DMV_IMP_INHERIT == 0x20000000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_DMV_IMP_INHERIT);
 	LASSERTF(OBD_CONNECT2_ENCRYPT_FID2PATH == 0x40000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_ENCRYPT_FID2PATH);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index d60d1d8..c979e24 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -784,6 +784,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_LOCK_CONTENTION	  0x2000000ULL /* contention detect */
 #define OBD_CONNECT2_ATOMIC_OPEN_LOCK	  0x4000000ULL /* lock on first open */
 #define OBD_CONNECT2_ENCRYPT_NAME	  0x8000000ULL /* name encrypt */
+#define OBD_CONNECT2_DMV_IMP_INHERIT	 0x20000000ULL /* client handle DMV inheritance */
 #define OBD_CONNECT2_ENCRYPT_FID2PATH	 0x40000000ULL /* fid2path enc file */
 /* XXX README XXX README XXX README XXX README XXX README XXX README XXX
  * Please DO NOT add OBD_CONNECT flags before first ensuring that this value
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
