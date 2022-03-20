Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3EED7C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:33:10 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EEAFA21FC28;
	Sun, 20 Mar 2022 06:32:13 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2DD9621F999
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:20 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 794A1EFE;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7753CD87DE; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:53 -0400
Message-Id: <1647783064-20688-40-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 39/50] lnet: improve hash distribution across
 CPTs
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

Change the nid-to-cpt allocation function to use
(sum-by-multiplication of nid bytes) mod (number of CPTs)
to match nid to a CPT. This patch only addresses IPV4 nids.

Make the matching change for the nid-to-cpt function
used by the 'lnetctl cpt-of-nid' utility.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14676
Lustre-commit: 9b6e27755507b9bb4 ("LU-14676 lnet: improve hash distribution across CPTs")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/46233
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 7a05752..1978905 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1447,19 +1447,20 @@ struct lnet_net *
 lnet_nid4_cpt_hash(lnet_nid_t nid, unsigned int number)
 {
 	u64 key = nid;
-	unsigned int val;
-
-	LASSERT(number >= 1 && number <= LNET_CPT_NUMBER);
+	u64 pair_bits = 0x0001000100010001LLU;
+	u64 mask = pair_bits * 0xFF;
+	u64 pair_sum;
 
-	if (number == 1)
-		return 0;
+	/* Use (sum-by-multiplication of nid bytes) mod (number of CPTs)
+	 * to match nid to a CPT.
+	 */
+	pair_sum = (key & mask) + ((key >> 8) & mask);
+	pair_sum = (pair_sum * pair_bits) >> 48;
 
-	val = hash_long(key, LNET_CPT_BITS);
-	/* NB: LNET_CP_NUMBER doesn't have to be PO2 */
-	if (val < number)
-		return val;
+	CDEBUG(D_NET, "Match nid %s to cpt %u\n",
+	       libcfs_nid2str(nid), (unsigned int)(pair_sum) % number);
 
-	return (unsigned int)(key + val + (val >> 1)) % number;
+	return (unsigned int)(pair_sum) % number;
 }
 
 unsigned int
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
