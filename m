Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1C08FECAAA1
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:56:36 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7m361Chz1yCj;
	Mon,  5 Sep 2022 18:56:35 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7lJ5YHxz1y6M
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:56 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E69CD100B035;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E5ACC37C; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:34 -0400
Message-Id: <1662429337-18737-22-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 21/24] lnet: Memory leak on adding existing
 interface
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
Cc: Frank Sehr <fsehr@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Frank Sehr <fsehr@whamcloud.com>

In the function lnet_dyn_add_ni an lnet_ni structure is allocated.
In case of an error the function returns without freeing the memory of
the structure.
Added handling of possible lnet_net structure memory leaks.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16081
Lustre-commit: 26beb8664f4533a6e ("LU-16081 lnet: Memory leak on adding existing interface")
Signed-off-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/48173
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 0449136..9bf2860 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3551,25 +3551,34 @@ int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf)
 		return -ENOMEM;
 
 	for (i = 0; i < conf->lic_ncpts; i++) {
-		if (conf->lic_cpts[i] >= LNET_CPT_NUMBER)
+		if (conf->lic_cpts[i] >= LNET_CPT_NUMBER) {
+			lnet_net_free(net);
 			return -EINVAL;
+		}
 	}
 
 	ni = lnet_ni_alloc_w_cpt_array(net, conf->lic_cpts, conf->lic_ncpts,
 				       conf->lic_ni_intf);
-	if (!ni)
+	if (!ni) {
+		lnet_net_free(net);
 		return -ENOMEM;
+	}
 
 	lnet_set_tune_defaults(tun);
 
 	mutex_lock(&the_lnet.ln_api_mutex);
-	if (the_lnet.ln_state != LNET_STATE_RUNNING)
+	if (the_lnet.ln_state != LNET_STATE_RUNNING) {
+		lnet_net_free(net);
 		rc = -ESHUTDOWN;
-	else
+	} else {
 		rc = lnet_add_net_common(net, tun);
+	}
 
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
+	if (rc)
+		lnet_ni_free(ni);
+
 	return rc;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
