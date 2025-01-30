Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5891EC0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:31:24 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLdq2ntTz217m;
	Thu, 30 Jan 2025 06:15:27 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLYl34Phz1xPH
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:11:55 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id F19AB18233D;
 Thu, 30 Jan 2025 09:11:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id EF585106BE18; Thu, 30 Jan 2025 09:11:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:10:58 -0500
Message-ID: <20250130141115.950749-9-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 08/25] lustre: enc: make sure DoM files are
 correctly decrypted
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
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sebastien Buisson <sbuisson@ddn.com>

Make sure DoM files are decrypted upon read by loading their
associated encryption context, via fscrypt_prepare_readdir()/
fscrypt_get_encryption_info().

WC-bug-id: https://jira.whamcloud.com/browse/LU-16670
Lustre-commit: 1c424252d37c64e3c ("LU-16670 enc: make sure DoM files are correctly decrypted")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50429
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c  | 7 +++++--
 fs/lustre/llite/namei.c | 6 +-----
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 9307007c3e18..d196362a40ca 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -453,14 +453,13 @@ static inline int ll_dom_readpage(void *data, struct page *page)
 	if (lnb->lnb_len < PAGE_SIZE)
 		memset(kaddr + lnb->lnb_len, 0,
 		       PAGE_SIZE - lnb->lnb_len);
-	flush_dcache_page(page);
-	SetPageUptodate(page);
 	kunmap_atomic(kaddr);
 
 	if (inode && IS_ENCRYPTED(inode) && S_ISREG(inode->i_mode)) {
 		if (!fscrypt_has_encryption_key(inode)) {
 			CDEBUG(D_SEC, "no enc key for " DFID "\n",
 			       PFID(ll_inode2fid(inode)));
+			rc = -ENOKEY;
 		} else {
 			unsigned int offs = 0;
 
@@ -481,6 +480,10 @@ static inline int ll_dom_readpage(void *data, struct page *page)
 			}
 		}
 	}
+	if (!rc) {
+		flush_dcache_page(page);
+		SetPageUptodate(page);
+	}
 	unlock_page(page);
 
 	return rc;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index a19e5f707027..920b592489ab 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -735,10 +735,6 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 			rc = fscrypt_get_encryption_info(inode);
 			if (rc)
 				goto out;
-			if (!fscrypt_has_encryption_key(inode)) {
-				rc = -ENOKEY;
-				goto out;
-			}
 		}
 	} else if (!it_disposition(it, DISP_OPEN_CREATE)) {
 		/*
@@ -1204,6 +1200,7 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 		rc = fscrypt_get_encryption_info(dir);
 		if (rc)
 			goto out_release;
+		encrypt = true;
 		if (open_flags & O_CREAT) {
 			/* For migration or mirroring without enc key, we still
 			 * need to be able to create a volatile file.
@@ -1216,7 +1213,6 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 				rc = -ENOKEY;
 				goto out_release;
 			}
-			encrypt = true;
 		}
 	}
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
