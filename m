Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id EF105C36000
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:09:32 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2mp617Pz1xny;
	Fri, 21 Mar 2025 06:07:54 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2m43VWsz1whP
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:07:16 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 593C717D1C3;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 5520C106BE18; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:46 -0400
Message-ID: <20250321130711.3257092-4-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 03/27] lustre: gss: no sec flavor on loopback
 connection
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
Cc: Aurelien Degremont <adegremont@nvidia.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sebastien Buisson <sbuisson@ddn.com>

When using a local client, i.e. a client mounted on a server node,
there is no benefit from a security standpoint to enforce an SSK or
KRB flavor, since the data does not go over the network.
So force the 'null' security flavor for connections on 0@lo,
independently of the currently defined srpc flavor.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13343
Lustre-commit: e3e91ea95fd96a5ea ("LU-13343 gss: no sec flavor on loopback connection")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/46704
Reviewed-by: Aurelien Degremont <adegremont@nvidia.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_obd.c       |  1 +
 fs/lustre/lov/lov_obd.c       | 11 +++++++----
 fs/lustre/ptlrpc/sec_config.c |  4 ++++
 3 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index f7c7826d0baf..da28bc0e544b 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -471,6 +471,7 @@ static int lmv_check_connect(struct obd_device *obd)
 			continue;
 
 		--lmv->lmv_mdt_descs.ltd_lmv_desc.ld_active_tgt_count;
+		obd_register_observer(tgt->ltd_exp->exp_obd, NULL);
 		obd_disconnect(tgt->ltd_exp);
 	}
 
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 392395f4c35e..f05091560e95 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -134,8 +134,10 @@ int lov_connect_osc(struct obd_device *obd, u32 index, int activate,
 	tgt_obd = lov->lov_tgts[index]->ltd_obd;
 
 	if (!tgt_obd->obd_set_up) {
-		CERROR("Target %s not set up\n", obd_uuid2str(tgt_uuid));
-		return -EINVAL;
+		rc = -EINVAL;
+		CERROR("%s: target not set up: rc = %d\n",
+		       obd_uuid2str(tgt_uuid), rc);
+		return rc;
 	}
 
 	/* override the sp_me from lov */
@@ -159,7 +161,7 @@ int lov_connect_osc(struct obd_device *obd, u32 index, int activate,
 
 	rc = obd_register_observer(tgt_obd, obd);
 	if (rc) {
-		CERROR("Target %s register_observer error %d\n",
+		CERROR("%s: target register_observer error: rc = %d\n",
 		       obd_uuid2str(tgt_uuid), rc);
 		return rc;
 	}
@@ -174,8 +176,9 @@ int lov_connect_osc(struct obd_device *obd, u32 index, int activate,
 	rc = obd_connect(NULL, &lov->lov_tgts[index]->ltd_exp, tgt_obd,
 			 &lov_osc_uuid, data, lov->lov_cache);
 	if (rc || !lov->lov_tgts[index]->ltd_exp) {
-		CERROR("Target %s connect error %d\n",
+		CERROR("%s: target connect error: rc = %d\n",
 		       obd_uuid2str(tgt_uuid), rc);
+		obd_register_observer(tgt_obd, NULL);
 		return -ENODEV;
 	}
 
diff --git a/fs/lustre/ptlrpc/sec_config.c b/fs/lustre/ptlrpc/sec_config.c
index 95e0da4b2da2..35bd95315bd7 100644
--- a/fs/lustre/ptlrpc/sec_config.c
+++ b/fs/lustre/ptlrpc/sec_config.c
@@ -380,6 +380,10 @@ static int sptlrpc_rule_set_choose(struct sptlrpc_rule_set *rset,
 	struct sptlrpc_rule *r;
 	int n;
 
+	if (nid_is_lo0(nid))
+		/* do not enforce any sec flavor on loopback connection */
+		return 0;
+
 	for (n = 0; n < rset->srs_nrule; n++) {
 		r = &rset->srs_rules[n];
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
