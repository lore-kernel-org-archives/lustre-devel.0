Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5FCFFFA3741
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:25:28 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mynhs2lH8z219K;
	Thu, 27 Oct 2022 07:13:33 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mynhf2r9Fz2169
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:13:22 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 8CC681009108;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8AE00FD4FB; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:39 -0400
Message-Id: <1666879542-10737-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
References: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/15] lnet: ksocklnd: fix irq lock inversion
 while calling sk_data_ready()
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

sk->sk_data_ready() of sctp socket can be called from both BH and non-BH
contexts, but ksocklnd version of sk_data_ready, ksocknal_data_ready()
does not handle the BH case. Change how ksnd_global_lock is taken in
this case.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15807
Lustre-commit: 1df5199097ef0d789 ("LU-15807 ksocklnd: fix irq lock inversion while calling sk_data_ready()")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48715
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 net/lnet/klnds/socklnd/socklnd_lib.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd_lib.c b/net/lnet/klnds/socklnd/socklnd_lib.c
index 047e7a6..dd12945 100644
--- a/net/lnet/klnds/socklnd/socklnd_lib.c
+++ b/net/lnet/klnds/socklnd/socklnd_lib.c
@@ -374,7 +374,7 @@ static int lustre_csum(struct kvec *v, void *context)
 
 	/* interleave correctly with closing sockets... */
 	LASSERT(!in_irq());
-	read_lock(&ksocknal_data.ksnd_global_lock);
+	read_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	conn = sk->sk_user_data;
 	wspace = sk_stream_wspace(sk);
@@ -408,7 +408,7 @@ static int lustre_csum(struct kvec *v, void *context)
 		clear_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 	}
 
-	read_unlock(&ksocknal_data.ksnd_global_lock);
+	read_unlock_bh(&ksocknal_data.ksnd_global_lock);
 }
 
 void
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
