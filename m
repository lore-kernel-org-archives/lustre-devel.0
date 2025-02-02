Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B4D5AC0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 21:11:17 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMHb3G9Hz21cp;
	Sun, 02 Feb 2025 12:51:39 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMFT6xNHz211g
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:49:49 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm2-e204-208.ccs.ornl.gov [160.91.203.3])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id EFA4F89ABF5;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id ED097106BE18; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:22 -0500
Message-ID: <20250202204633.1148872-23-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 22/33] lustre: ptlrpc: switch
 sptlrpc_rule_set_choose to large nid
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

From: Mr NeilBrown <neilb@suse.de>

sptlrpc_rule_set_choose() and sptlrpc_target_choose_flavor() now take
a large nid.  Only the net number is needed, so this is quite straight
forward.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 80a4a2ebe0a269d56 ("LU-10391 ptlrpc: switch sptlrpc_rule_set_choose to large nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50102
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/sec_config.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/ptlrpc/sec_config.c b/fs/lustre/ptlrpc/sec_config.c
index 1b56ef40ebda..95e0da4b2da2 100644
--- a/fs/lustre/ptlrpc/sec_config.c
+++ b/fs/lustre/ptlrpc/sec_config.c
@@ -374,7 +374,7 @@ static int sptlrpc_rule_set_merge(struct sptlrpc_rule_set *rset,
 static int sptlrpc_rule_set_choose(struct sptlrpc_rule_set *rset,
 				   enum lustre_sec_part from,
 				   enum lustre_sec_part to,
-				   lnet_nid_t nid,
+				   struct lnet_nid *nid,
 				   struct sptlrpc_flavor *sf)
 {
 	struct sptlrpc_rule *r;
@@ -383,9 +383,9 @@ static int sptlrpc_rule_set_choose(struct sptlrpc_rule_set *rset,
 	for (n = 0; n < rset->srs_nrule; n++) {
 		r = &rset->srs_rules[n];
 
-		if (LNET_NIDNET(nid) != LNET_NET_ANY &&
+		if (!LNET_NID_IS_ANY(nid) &&
 		    r->sr_netid != LNET_NET_ANY &&
-		    LNET_NIDNET(nid) != r->sr_netid)
+		    __be16_to_cpu(nid->nid_num) != r->sr_netid)
 			continue;
 
 		if (from != LUSTRE_SP_ANY && r->sr_from != LUSTRE_SP_ANY &&
@@ -811,13 +811,13 @@ void sptlrpc_conf_choose_flavor(enum lustre_sec_part from,
 	conf_tgt = sptlrpc_conf_get_tgt(conf, name, 0);
 	if (conf_tgt) {
 		rc = sptlrpc_rule_set_choose(&conf_tgt->sct_rset, from, to,
-					     lnet_nid_to_nid4(nid), sf);
+					     nid, sf);
 		if (rc)
 			goto out;
 	}
 
 	rc = sptlrpc_rule_set_choose(&conf->sc_rset, from, to,
-				     lnet_nid_to_nid4(nid), sf);
+				     nid, sf);
 out:
 	mutex_unlock(&sptlrpc_conf_lock);
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
