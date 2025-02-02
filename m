Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 953BCC0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:55:33 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMFK0JHhz1y82;
	Sun, 02 Feb 2025 12:49:41 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMCj4mqHz1yCG
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:48:17 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm2-e204-208.ccs.ornl.gov [160.91.203.3])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id C751B899AD8;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id C5A10106BE18; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:12 -0500
Message-ID: <20250202204633.1148872-13-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 12/33] lnet: Use dynamic allocation for LND
 tunables
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
Cc: Chris Horn <chris.horn@hpe.com>, Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

Increasing size of lnet_ioctl_config_lnd_tunables can cause us to
trip Werror=frame-larger-than warning in lnet_net_cmd() and its
call to static function lnet_genl_parse_local_ni(). Dynamically
allocate this memory instead.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16801
Lustre-commit: fe2e85e5c312a6a10 ("LU-16801 lnet: Use dynamic allocation for LND tunables")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50872
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 5ec6faa2da98..585148b4b6aa 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4973,16 +4973,22 @@ lnet_genl_parse_local_ni(struct nlattr *entry, struct genl_info *info,
 			 bool *ni_list)
 {
 	bool create = info->nlhdr->nlmsg_flags & NLM_F_CREATE;
-	struct lnet_ioctl_config_lnd_tunables tun;
+	struct lnet_ioctl_config_lnd_tunables *tun;
 	struct nlattr *settings;
 	int rem3, rc = 0;
 
-	memset(&tun, 0, sizeof(tun));
+	tun = kzalloc(sizeof(*tun), GFP_KERNEL);
+	if (!tun) {
+		GENL_SET_ERR_MSG(info, "cannot allocate memory for tunables");
+		rc = -ENOMEM;
+		goto out;
+	}
+
 	/* Use LND defaults */
-	tun.lt_cmn.lct_peer_timeout = -1;
-	tun.lt_cmn.lct_peer_tx_credits = -1;
-	tun.lt_cmn.lct_peer_rtr_credits = -1;
-	tun.lt_cmn.lct_max_tx_credits = -1;
+	tun->lt_cmn.lct_peer_timeout = -1;
+	tun->lt_cmn.lct_peer_tx_credits = -1;
+	tun->lt_cmn.lct_peer_rtr_credits = -1;
+	tun->lt_cmn.lct_max_tx_credits = -1;
 	conf->lic_ncpts = 0;
 
 	nla_for_each_nested(settings, entry, rem3) {
@@ -5031,7 +5037,7 @@ lnet_genl_parse_local_ni(struct nlattr *entry, struct genl_info *info,
 				goto out;
 			}
 
-			rc = lnet_genl_parse_tunables(settings, &tun);
+			rc = lnet_genl_parse_tunables(settings, tun);
 			if (rc < 0) {
 				GENL_SET_ERR_MSG(info,
 						 "failed to parse tunables");
@@ -5058,7 +5064,7 @@ lnet_genl_parse_local_ni(struct nlattr *entry, struct genl_info *info,
 			}
 
 			rc = lnet_genl_parse_lnd_tunables(settings,
-							  &tun.lt_tun, lnd);
+							  &tun->lt_tun, lnd);
 			if (rc < 0) {
 				GENL_SET_ERR_MSG(info,
 						 "failed to parse lnd tunables");
@@ -5150,7 +5156,7 @@ lnet_genl_parse_local_ni(struct nlattr *entry, struct genl_info *info,
 			goto out;
 		}
 
-		rc = lnet_dyn_add_ni(conf, net_id, &tun);
+		rc = lnet_dyn_add_ni(conf, net_id, tun);
 		switch (rc) {
 		case -ENOENT:
 			GENL_SET_ERR_MSG(info,
@@ -5168,6 +5174,8 @@ lnet_genl_parse_local_ni(struct nlattr *entry, struct genl_info *info,
 		}
 	}
 out:
+	kfree(tun);
+
 	return rc;
 }
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
