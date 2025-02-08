Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C37F8C02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:41:23 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWyD4qrJz1xTw;
	Fri, 07 Feb 2025 16:32:36 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWw51kCKz1xS5
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:45 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 11D3A893E88;
 Fri,  7 Feb 2025 19:30:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 10163106BE14; Fri,  7 Feb 2025 19:30:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:18 -0500
Message-ID: <20250208003027.180076-13-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 12/21] lnet: udsp: lnetctl udsp improvements
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
Cc: Chris Horn <chris.horn@hpe.com>, Cyril Bordage <cbordage@whamcloud.com>,
 Frank Sehr <fsehr@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

lnet_udsp_del_policy() did not previously return non-zero, but its
single caller would check for a non-zero and call
lnet_udsp_apply_policies(). This code is removed.
lnet_udsp_del_policy() will now return non-zero but only in the case
where there is no matching policy index. In this case the policies
are not modified and thus we needn't re-apply them.

HPE-bug-id: LUS-11490
WC-bug-id: https://jira.whamcloud.com/browse/LU-16574
Lustre-commit: 9e6c0915bb73a04e2 ("LU-16574 udsp: lnetctl udsp improvements")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51087
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 6 ------
 net/lnet/lnet/udsp.c   | 3 +++
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index d3d51acdf2ad..6884c5d3ad86 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4550,12 +4550,6 @@ LNetCtl(unsigned int cmd, void *arg)
 
 		mutex_lock(&the_lnet.ln_api_mutex);
 		rc = lnet_udsp_del_policy(idx);
-		if (!rc) {
-			rc = lnet_udsp_apply_policies(NULL, false);
-			CDEBUG(D_NET, "policy re-application returned %d\n",
-			       rc);
-			rc = 0;
-		}
 		mutex_unlock(&the_lnet.ln_api_mutex);
 
 		return rc;
diff --git a/net/lnet/lnet/udsp.c b/net/lnet/lnet/udsp.c
index eb9a614a0ec1..9f6ff5baf118 100644
--- a/net/lnet/lnet/udsp.c
+++ b/net/lnet/lnet/udsp.c
@@ -982,6 +982,9 @@ lnet_udsp_del_policy(int idx)
 		}
 	}
 
+	if (!removed)
+		return -ENOENT;
+
 	return 0;
 }
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
