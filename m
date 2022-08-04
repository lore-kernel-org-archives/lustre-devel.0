Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6C2E9C19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:38:50 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyrwp0VSgz23Ht;
	Wed,  3 Aug 2022 18:38:50 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwQ4YdSz23Hx
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:30 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B8FA1100AFF7;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B3E4C94BEB; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:37:53 -0400
Message-Id: <1659577097-19253-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/32] lnet: socklnd: Duplicate ksock_conn_cb
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

If two threads enter ksocknal_add_peer(), the first one to acquire
the ksnd_global_lock will create a ksock_peer_ni and associate a
ksock_conn_cb with it.

When the second thread acquires the ksnd_global_lock it will find the
existing ksock_peer_ni, but it does not check for an existing
ksock_conn_cb. As a result, it overwrites the existing ksock_conn_cb
(ksock_peer_ni::ksnp_conn_cb) and the ksock_conn_cb from the first
thread becomes stranded.

Modify ksocknal_add_peer() to check whether the peer_ni has an
existing ksock_conn_cb associated with it

Fixes: 3ffceb7502 ("lnet: socklnd: replace route construct")
HPE-bug-id: LUS-10956
WC-bug-id: https://jira.whamcloud.com/browse/LU-15860
Lustre-commit: 0c91d49a44e1214b5 ("LU-15860 socklnd: Duplicate ksock_conn_cb")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/47361
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 01b434f..2b08501 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -645,14 +645,17 @@ struct ksock_peer_ni *
 			 nidhash(&id->nid));
 	}
 
-	ksocknal_add_conn_cb_locked(peer_ni, conn_cb);
-
-	/* Remember conns_per_peer setting at the time
-	 * of connection initiation. It will define the
-	 * max number of conns per type for this conn_cb
-	 * while it's in use.
-	 */
-	conn_cb->ksnr_max_conns = ksocknal_get_conns_per_peer(peer_ni);
+	if (peer_ni->ksnp_conn_cb) {
+		ksocknal_conn_cb_decref(conn_cb);
+	} else {
+		ksocknal_add_conn_cb_locked(peer_ni, conn_cb);
+		/* Remember conns_per_peer setting at the time
+		 * of connection initiation. It will define the
+		 * max number of conns per type for this conn_cb
+		 * while it's in use.
+		 */
+		conn_cb->ksnr_max_conns = ksocknal_get_conns_per_peer(peer_ni);
+	}
 
 	write_unlock_bh(&ksocknal_data.ksnd_global_lock);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
