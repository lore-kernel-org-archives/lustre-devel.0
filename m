Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8876AC36001
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:23:20 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2q75yDhz20Vv;
	Fri, 21 Mar 2025 06:09:55 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2n45Y2Wz1y1k
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:08:08 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7E13117B5A6;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 7C1C7106BE17; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:56 -0400
Message-ID: <20250321130711.3257092-14-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 13/27] lustre: convert ec,
 ldlm functions to static
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
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Timothy Day <timday@amazon.com>

Static analysis shows that a number of functions
could be made static. This patch declares several
functions in ec, and ldlm static.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8191
Lustre-commit: bcc828bdf88f8a19e ("LU-8191 lustre: convert ec,fid,ldlm,quota functions to static")
Signed-off-by: Timothy Day <timday@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51476
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ec/ec_base.c        | 4 ++--
 fs/lustre/ldlm/ldlm_request.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/ec/ec_base.c b/fs/lustre/ec/ec_base.c
index e5204668eea1..4241659d28de 100644
--- a/fs/lustre/ec/ec_base.c
+++ b/fs/lustre/ec/ec_base.c
@@ -106,7 +106,7 @@ void ec_init_tables(int k, int rows, unsigned char *a, unsigned char *g_tbls)
 }
 EXPORT_SYMBOL(ec_init_tables);
 
-unsigned char gf_mul(unsigned char a, unsigned char b)
+static unsigned char gf_mul(unsigned char a, unsigned char b)
 {
 	int i;
 
@@ -117,7 +117,7 @@ unsigned char gf_mul(unsigned char a, unsigned char b)
 	return gff_base[i > 254 ? i - 255 : i];
 }
 
-unsigned char gf_inv(unsigned char a)
+static unsigned char gf_inv(unsigned char a)
 {
 	if (a == 0)
 		return 0;
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index bccce8b8e5e8..127f5777a5a3 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -2355,7 +2355,7 @@ static int lock_can_replay(struct obd_import *imp)
 	       1 + min_t(u32, cli->cl_max_rpcs_in_flight, 8);
 }
 
-int __ldlm_replay_locks(struct obd_import *imp, bool rate_limit)
+static int __ldlm_replay_locks(struct obd_import *imp, bool rate_limit)
 {
 	struct ldlm_namespace *ns = imp->imp_obd->obd_namespace;
 	LIST_HEAD(list);
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
