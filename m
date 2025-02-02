Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id AB960C02193
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:54:14 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMDv74Gvz1y7k;
	Sun, 02 Feb 2025 12:49:19 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMCh07Gyz20vF
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:48:15 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D77CC18236C;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id D5219106BE18; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:16 -0500
Message-ID: <20250202204633.1148872-17-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 16/33] lnet: improve numeric NID to CPT
 hashing
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

Testing shows that the sum-by-multiplication of nid bytes method for
hashing a NID to a CPT does not have good distribution for gnilnd
and kfilnd NIDs. For these LNDs, use the old hash_long() method.

Also modify lustre_lnet_calc_cpt_of_nid() to ensure the specified
number of CPTs is greater than 0. This avoids a divide by zero.

HPE-bug-id: LUS-11576
WC-bug-id: https://jira.whamcloud.com/browse/LU-16797
Lustre-commit: bd12731f2f15b3903 ("LU-16797 lnet: improve numeric NID to CPT hashing")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50862
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/api-ni.c | 31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 585148b4b6aa..fa42cfd99aa7 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1532,20 +1532,31 @@ static unsigned int
 lnet_nid4_cpt_hash(lnet_nid_t nid, unsigned int number)
 {
 	u64 key = nid;
-	u64 pair_bits = 0x0001000100010001LLU;
-	u64 mask = pair_bits * 0xFF;
-	u64 pair_sum;
+	u16 lnd = LNET_NETTYP(LNET_NIDNET(nid));
+	unsigned int cpt;
 
-	/* Use (sum-by-multiplication of nid bytes) mod (number of CPTs)
-	 * to match nid to a CPT.
-	 */
-	pair_sum = (key & mask) + ((key >> 8) & mask);
-	pair_sum = (pair_sum * pair_bits) >> 48;
+	if (lnd == KFILND || lnd == GNILND) {
+		cpt = hash_long(key, LNET_CPT_BITS);
+
+		/* NB: The number of CPTs needn't be a power of 2 */
+		if (cpt >= number)
+			cpt = (key + cpt + (cpt >> 1)) % number;
+	} else {
+		u64 pair_bits = 0x0001000100010001LLU;
+		u64 mask = pair_bits * 0xFF;
+		u64 pair_sum;
+		/* For ipv4 NIDs, use (sum-by-multiplication of nid bytes) mod
+		 * (number of CPTs) to match nid to a CPT.
+		 */
+		pair_sum = (key & mask) + ((key >> 8) & mask);
+		pair_sum = (pair_sum * pair_bits) >> 48;
+		cpt = (unsigned int)(pair_sum) % number;
+	}
 
 	CDEBUG(D_NET, "Match nid %s to cpt %u\n",
-	       libcfs_nid2str(nid), (unsigned int)(pair_sum) % number);
+	       libcfs_nid2str(nid), cpt);
 
-	return (unsigned int)(pair_sum) % number;
+	return cpt;
 }
 
 unsigned int
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
