Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 60CFFC4332F
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:35 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0BM08nzz1y5s;
	Fri, 14 Oct 2022 14:38:35 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0B46slfz1y5k
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:20 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 0674010084A6;
 Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 00709DD53C; Fri, 14 Oct 2022 17:38:13 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:37:59 -0400
Message-Id: <1665783491-13827-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/20] lnet: only use PUBLIC IP6 addresses
 for connections
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

From: Mr NeilBrown <neilb@suse.de>

IPv6 can have temporary address.  These can be used for short-lives
outgoing connections to increase privacy.  They are not suitable for
long-term connections.

So request that only PUBLIC IPv6 addresses are used when making a
connection.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: cd3b89be221b4c5b6 ("LU-10391 lnet: only use PUBLIC IP6 addresses for connections")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48571
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-socket.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/lnet/lnet/lib-socket.c b/net/lnet/lnet/lib-socket.c
index 3a99cb69f66f..01f375ed96a3 100644
--- a/net/lnet/lnet/lib-socket.c
+++ b/net/lnet/lnet/lib-socket.c
@@ -379,6 +379,17 @@ lnet_sock_connect(int interface, int local_port,
 	if (IS_ERR(sock))
 		return sock;
 
+	/* Avoid temporary address, they are bad for long-lived
+	 * connections such as lustre mounts.
+	 * RFC4941, section 3.6 suggests that:
+	 *    Individual applications, which have specific
+	 *    knowledge about the normal duration of connections,
+	 *    MAY override this as appropriate.
+	 */
+	if (peeraddr->sa_family == PF_INET6)
+		ip6_sock_set_addr_preferences(sock->sk,
+					      IPV6_PREFER_SRC_PUBLIC);
+
 	rc = kernel_connect(sock, peeraddr, sizeof(struct sockaddr_in6), 0);
 	if (!rc)
 		return sock;
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
