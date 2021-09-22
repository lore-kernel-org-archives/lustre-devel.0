Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E1C4C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:22 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2228160F4C
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 2228160F4C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6D4A321F1F3;
	Tue, 21 Sep 2021 19:20:16 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C2BF121E02E
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:07 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 15547359;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0F975FF4C3; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:45 -0400
Message-Id: <1632277201-6920-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/24] lnet: socklnd: factor out key
 calculation for ksnd_peers
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

The hash_table library requires a "long" to be used as a key.  We
currently provide the nid, which at 64bits is a suitable long on 64bit
hosts, but isn't really correct on 32bit hosts.

When we change to an extend nid (which is 160bits) it will be even
less appropriate.

So create a separate function to compute a 'long' key, and implement
by simply xoring 'long'-sized parts of the nid together.  On a 64bit
machine, this is currently optimized away for lnet_nid_t, but that
will change when we convert to struct lnet_nid.

This new function is placed in lnet-types.h as it will be more
generally useful later.

The hash_table library calls hash_long() on the key, so we don't need
to do anything more interesting than xoring.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 96a0c378c2e0a0c8f ("LU-10391 socklnd: factor out key calculation for ksnd_peers")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/42103
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lnet/lnet-types.h | 10 ++++++++++
 net/lnet/klnds/socklnd/socklnd.c     | 17 +++++++++++------
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index ba8a079..5538d4e 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -163,6 +163,16 @@ static inline int nid_same(const struct lnet_nid *n1,
 		n1->nid_addr[3] == n2->nid_addr[3];
 }
 
+/* This can be used when we need to hash a nid */
+static inline unsigned long nidhash(lnet_nid_t nid)
+{
+	unsigned long hash = 0;
+
+	hash ^= LNET_NIDNET(nid);
+	hash ^= LNET_NIDADDR(nid);
+	return hash;
+}
+
 struct lnet_counters_health {
 	__u32	lch_rst_alloc;
 	__u32	lch_resend_count;
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 21569fb..08d1cf4 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -221,9 +221,10 @@ struct ksock_peer_ni *
 ksocknal_find_peer_locked(struct lnet_ni *ni, struct lnet_process_id id)
 {
 	struct ksock_peer_ni *peer_ni;
+	unsigned long hash = nidhash(id.nid);
 
 	hash_for_each_possible(ksocknal_data.ksnd_peers, peer_ni,
-			       ksnp_list, id.nid) {
+			       ksnp_list, hash) {
 		LASSERT(!peer_ni->ksnp_closing);
 
 		if (peer_ni->ksnp_ni != ni)
@@ -602,7 +603,8 @@ struct ksock_peer_ni *
 		peer_ni = peer2;
 	} else {
 		/* peer_ni table takes my ref on peer_ni */
-		hash_add(ksocknal_data.ksnd_peers, &peer_ni->ksnp_list, id.nid);
+		hash_add(ksocknal_data.ksnd_peers, &peer_ni->ksnp_list,
+			 nidhash(id.nid));
 	}
 
 	ksocknal_add_conn_cb_locked(peer_ni, conn_cb);
@@ -656,7 +658,8 @@ struct ksock_peer_ni *
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	if (id.nid != LNET_NID_ANY) {
-		lo = hash_min(id.nid, HASH_BITS(ksocknal_data.ksnd_peers));
+		lo = hash_min(nidhash(id.nid),
+			      HASH_BITS(ksocknal_data.ksnd_peers));
 		hi = lo;
 	} else {
 		lo = 0;
@@ -935,7 +938,7 @@ struct ksock_peer_ni *
 			 * table (which takes my ref)
 			 */
 			hash_add(ksocknal_data.ksnd_peers,
-				 &peer_ni->ksnp_list, peerid.nid);
+				 &peer_ni->ksnp_list, nidhash(peerid.nid));
 		} else {
 			ksocknal_peer_decref(peer_ni);
 			peer_ni = peer2;
@@ -1567,7 +1570,8 @@ struct ksock_peer_ni *
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
 
 	if (id.nid != LNET_NID_ANY) {
-		lo = hash_min(id.nid, HASH_BITS(ksocknal_data.ksnd_peers));
+		lo = hash_min(nidhash(id.nid),
+			      HASH_BITS(ksocknal_data.ksnd_peers));
 		hi = lo;
 	} else {
 		lo = 0;
@@ -1662,7 +1666,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	int rc = -ENOENT;
 
 	if (id.nid != LNET_NID_ANY) {
-		lo = hash_min(id.nid, HASH_BITS(ksocknal_data.ksnd_peers));
+		lo = hash_min(nidhash(id.nid),
+			      HASH_BITS(ksocknal_data.ksnd_peers));
 		hi = lo;
 	} else {
 		lo = 0;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
