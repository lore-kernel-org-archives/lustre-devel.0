Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A961C433ED
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:14 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 399A56112E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 399A56112E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 59D1632C526;
	Mon,  5 Apr 2021 00:52:34 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0D1F021F718
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:27 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 15405E3E;
 Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1408F90AA8; Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:51:01 -0400
Message-Id: <1617583870-32029-33-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 32/41] lustre: mark strings in char arrays as
 const
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

From: Mr NeilBrown <neilb@suse.de>

Most array of strings are marked 'const', but the strings within the
arrays often aren't.
This patch mark all strings in const arrays of strings as const.
This allows them to be placed in read-only memory.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: 734d6eb11b572a9a ("LU-6142 lustre: mark strings in char arrays as const")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39742
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_cksum.h           | 2 +-
 fs/lustre/llite/lproc_llite.c           | 2 +-
 include/uapi/linux/lustre/lustre_user.h | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/obd_cksum.h b/fs/lustre/include/obd_cksum.h
index f7d316b..08c1cb9 100644
--- a/fs/lustre/include/obd_cksum.h
+++ b/fs/lustre/include/obd_cksum.h
@@ -127,7 +127,7 @@ enum cksum_types obd_cksum_type_select(const char *obd_name,
 /* Checksum algorithm names. Must be defined in the same order as the
  * OBD_CKSUM_* flags.
  */
-#define DECLARE_CKSUM_NAME const char *cksum_name[] = {"crc32", "adler", \
+#define DECLARE_CKSUM_NAME const char *const cksum_name[] = {"crc32", "adler", \
 	"crc32c", "reserved", "t10ip512", "t10ip4K", "t10crc512", "t10crc4K"}
 
 typedef u16 (obd_dif_csum_fn) (void *, unsigned int);
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 5d1e2f4..a2e61e1 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -995,7 +995,7 @@ static ssize_t default_easize_store(struct kobject *kobj,
 
 static int ll_sbi_flags_seq_show(struct seq_file *m, void *v)
 {
-	const char *str[] = LL_SBI_FLAGS;
+	const char *const str[] = LL_SBI_FLAGS;
 	struct super_block *sb = m->private;
 	int flags = ll_s2sbi(sb)->ll_flags;
 	int i = 0;
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 0f195a4..7d4a9e9 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1213,7 +1213,7 @@ enum changelog_rec_type {
 
 static inline const char *changelog_type2str(int type)
 {
-	static const char *changelog_str[] = {
+	static const char *const changelog_str[] = {
 		"MARK",  "CREAT", "MKDIR", "HLINK", "SLINK", "MKNOD", "UNLNK",
 		"RMDIR", "RENME", "RNMTO", "OPEN",  "CLOSE", "LYOUT", "TRUNC",
 		"SATTR", "XATTR", "HSM",   "MTIME", "CTIME", "ATIME", "",
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
