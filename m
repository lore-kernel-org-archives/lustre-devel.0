Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4409BC19F2D
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:38:41 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyrwc3ZRBz23JT;
	Wed,  3 Aug 2022 18:38:40 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwR2X70z23J4
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:31 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B95EA100AFF8;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B0EDC82CCE; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:37:52 -0400
Message-Id: <1659577097-19253-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/32] lustre: enc: enc-unaware clients get
 ENOKEY if file not found
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

To reduce issues with applications running on clients without keys
or without fscrypt support that check for the existence of a file in
an encrypted directory, return -ENOKEY instead of -ENOENT.
For encryption-unaware clients, this is done on server side in the
mdt layer, by checking if clients have the OBD_CONNECT2_ENCRYPT
connection flag.
For clients without the key, this is done in llite when the searched
filename is not in encoded form.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15855
Lustre-commit: 00898697f998c095e ("LU-15855 enc: enc-unaware clients get ENOKEY if file not found")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/47349
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/crypto.c | 35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index f075b9a..ad045c3 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -233,21 +233,26 @@ int ll_setup_filename(struct inode *dir, const struct qstr *iname,
 		fid->f_ver = 0;
 	}
 	rc = fscrypt_setup_filename(dir, &dname, lookup, fname);
-	if (rc == -ENOENT && lookup &&
-	    ((is_root_inode(dir) && iname->len == strlen(dot_fscrypt_name) &&
-	      strncmp(iname->name, dot_fscrypt_name, iname->len) == 0) ||
-	     (!fscrypt_has_encryption_key(dir) &&
-	      unlikely(filename_is_volatile(iname->name, iname->len, NULL))))) {
-		/* In case of subdir mount of an encrypted directory, we allow
-		 * lookup of /.fscrypt directory.
-		 */
-		/* For purpose of migration or mirroring without enc key, we
-		 * allow lookup of volatile file without enc context.
-		 */
-		memset(fname, 0, sizeof(struct fscrypt_name));
-		fname->disk_name.name = (unsigned char *)iname->name;
-		fname->disk_name.len = iname->len;
-		rc = 0;
+	if (rc == -ENOENT && lookup) {
+		if (((is_root_inode(dir) &&
+		     iname->len == strlen(dot_fscrypt_name) &&
+		     strncmp(iname->name, dot_fscrypt_name, iname->len) == 0) ||
+		     (!fscrypt_has_encryption_key(dir) &&
+		      unlikely(filename_is_volatile(iname->name,
+						    iname->len, NULL))))) {
+			/* In case of subdir mount of an encrypted directory,
+			 * we allow lookup of /.fscrypt directory.
+			 */
+			/* For purpose of migration or mirroring without enc key,
+			 * we allow lookup of volatile file without enc context.
+			 */
+			memset(fname, 0, sizeof(struct fscrypt_name));
+			fname->disk_name.name = (unsigned char *)iname->name;
+			fname->disk_name.len = iname->len;
+			rc = 0;
+		} else if (!fscrypt_has_encryption_key(dir)) {
+			rc = -ENOKEY;
+		}
 	}
 	if (rc)
 		return rc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
