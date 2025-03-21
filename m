Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id AFFA9C36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:23:19 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2q72c21z20Vt;
	Fri, 21 Mar 2025 06:09:55 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2mR3v9Zz1xdq
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:07:35 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6D62F17D18B;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 6C7A0106BE16; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:52 -0400
Message-ID: <20250321130711.3257092-10-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 09/27] lustre: llite: skip fast reads if
 layout is invalid
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Alex Zhuravlev <bzzz@whamcloud.com>

don't let fast reads from the pagecache if the layout
is not valid.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15431
Lustre-commit: fe2fafa1af7edc251 ("LU-15431 llite: skip fast reads if layout is invalid")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/46282
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 448aea7ceb12..c7f77295d3b3 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1983,6 +1983,7 @@ ll_file_io_generic(const struct lu_env *env, struct vvp_io_args *args,
 static ssize_t
 ll_do_fast_read(struct kiocb *iocb, struct iov_iter *iter)
 {
+	struct ll_inode_info *lli = ll_i2info(file_inode(iocb->ki_filp));
 	ssize_t result;
 
 	if (!ll_sbi_has_fast_read(ll_i2sbi(file_inode(iocb->ki_filp))))
@@ -1995,6 +1996,9 @@ ll_do_fast_read(struct kiocb *iocb, struct iov_iter *iter)
 	if (iocb->ki_filp->f_flags & O_DIRECT)
 		return 0;
 
+	if (ll_layout_version_get(lli) == CL_LAYOUT_GEN_NONE)
+		return 0;
+
 	result = generic_file_read_iter(iocb, iter);
 
 	/* If the first page is not in cache, generic_file_aio_read() will be
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
