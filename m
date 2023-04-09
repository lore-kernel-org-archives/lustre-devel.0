Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7C167C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:30:40 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWMq3XkKz226P;
	Sun,  9 Apr 2023 05:17:59 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWHS4TCPz1yDK
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:14:12 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id F30BF100827B;
 Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F1CD42B3; Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:53 -0400
Message-Id: <1681042400-15491-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/40] lustre: sec: Lustre/HSM on enc file
 with enc key
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

Support for Lustre/HSM on encrypted files when the encryption key is
available requires similar attention as with file migration.
The volatile file used for HSM restore must have the same encryption
context as the Lustre file being restored, so that file content
remains accessible after the layout swap at the end of the restore
procedure.

Please note that using Lustre/HSM with the encryption key creates
clear text copies of encrypted files on the HSM backend storage.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16310
Lustre-commit: df7a8d92d2378e236 ("LU-16310 sec: Lustre/HSM on enc file with enc key")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49153
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Etienne AUJAMES <eaujames@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/crypto.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index 5fb7f4d..61b85c8 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -246,7 +246,16 @@ int ll_setup_filename(struct inode *dir, const struct qstr *iname,
 		fid->f_oid = 0;
 		fid->f_ver = 0;
 	}
-	rc = fscrypt_setup_filename(dir, &dname, lookup, fname);
+	if (unlikely(filename_is_volatile(iname->name,
+					  iname->len, NULL))) {
+		/* keep volatile name as-is, matters for server side */
+		memset(fname, 0, sizeof(struct fscrypt_name));
+		fname->disk_name.name = (unsigned char *)iname->name;
+		fname->disk_name.len = iname->len;
+		rc = 0;
+	} else {
+		rc = fscrypt_setup_filename(dir, &dname, lookup, fname);
+	}
 	if (rc == -ENOENT && lookup) {
 		if (((is_root_inode(dir) &&
 		     iname->len == strlen(dot_fscrypt_name) &&
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
