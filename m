Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 641D0C54EAA
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:09:45 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15Jh3XkLz216F;
	Mon, 23 Jan 2023 15:04:20 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15JP52lsz2161
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:04:05 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 44A706DE;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 435E558994; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:25 -0500
Message-Id: <1674514855-15399-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/42] lustre: sec: reserve flag for fid2path
 for encrypted files
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

From: Sebastien Buisson <sbuisson@ddn.com>

Reserve OBD_CONNECT2_ENCRYPT_FID2PATH connection flag for fid2path
support for encrypted files.
This connection flag is required so that newer servers continue to
return -ENODATA to older clients.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16205
Lustre-commit: 6f74bb60ff6c58f4a ("LU-16205 sec: reserve flag for fid2path for encrypted files")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49028
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lprocfs_status.c    | 3 +++
 fs/lustre/ptlrpc/wiretest.c            | 2 ++
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 3 files changed, 6 insertions(+)

diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 5089e7cfd377..5e4ad7c227b1 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -137,6 +137,9 @@ static const char *const obd_connect_names[] = {
 	"lock_contend",			/* 0x2000000 */
 	"atomic_open_lock",		/* 0x4000000 */
 	"name_encryption",		/* 0x8000000 */
+	"mkdir_replay",			/* 0x10000000 */
+	"dmv_inherit",			/* 0x20000000 */
+	"encryption_fid2path",		/* 0x40000000 */
 	NULL
 };
 
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 66c7c1763959..daa11e5d76dc 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1243,6 +1243,8 @@ void lustre_assert_wire_constants(void)
 		 OBD_CONNECT2_ATOMIC_OPEN_LOCK);
 	LASSERTF(OBD_CONNECT2_ENCRYPT_NAME == 0x8000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT2_ENCRYPT_NAME);
+	LASSERTF(OBD_CONNECT2_ENCRYPT_FID2PATH == 0x40000000ULL, "found 0x%.16llxULL\n",
+		 OBD_CONNECT2_ENCRYPT_FID2PATH);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 475151ce72fb..8cf9323c3579 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -783,6 +783,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_LOCK_CONTENTION	  0x2000000ULL /* contention detect */
 #define OBD_CONNECT2_ATOMIC_OPEN_LOCK	  0x4000000ULL /* lock on first open */
 #define OBD_CONNECT2_ENCRYPT_NAME	  0x8000000ULL /* name encrypt */
+#define OBD_CONNECT2_ENCRYPT_FID2PATH	 0x40000000ULL /* fid2path enc file */
 /* XXX README XXX README XXX README XXX README XXX README XXX README XXX
  * Please DO NOT add OBD_CONNECT flags before first ensuring that this value
  * is not in use by some other branch/patch.  Email adilger@whamcloud.com
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
