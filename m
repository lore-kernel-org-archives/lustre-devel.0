Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4E6BAC0218F
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:18:22 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLZw2f6rz1y1r;
	Thu, 30 Jan 2025 06:12:56 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLYL0rXmz1whJ
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:11:34 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id D7658891204;
 Thu, 30 Jan 2025 09:11:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id CE737106BE16; Thu, 30 Jan 2025 09:11:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:10:51 -0500
Message-ID: <20250130141115.950749-2-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 01/25] lustre: remove additional cl_env_get()
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

The patch to adjust the read count for truncated file was not
properly applied. In ll_file_read_iter() cl_env moved to earlier
in the function but the original call to cl_env_get() remained.
This left an additional reference that later prevented the lustre
module from unloading.

Fixes: 07084899763 ("lustre: llite: adjust read count as file got truncated")
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 05a75aed7826..24904acb28e0 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -2108,10 +2108,6 @@ static ssize_t ll_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	if (result < 0 || iov_iter_count(to) == 0)
 		goto out;
 
-	env = cl_env_get(&refcheck);
-	if (IS_ERR(env))
-		return PTR_ERR(env);
-
 	args = ll_env_args(env);
 	args->u.normal.via_iter = to;
 	args->u.normal.via_iocb = iocb;
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
