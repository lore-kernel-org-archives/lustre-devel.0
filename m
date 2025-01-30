Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 69FDAC0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:22:02 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLbk0y6mz1xfG;
	Thu, 30 Jan 2025 06:13:38 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLYY4Wl6z1xP1
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:11:45 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E369B182332;
 Thu, 30 Jan 2025 09:11:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id DC4B1106BE19; Thu, 30 Jan 2025 09:11:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:10:54 -0500
Message-ID: <20250130141115.950749-5-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 04/25] lnet: change cfs_match_nid to take
 large nid.
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
Cc: Frank Sehr <fsehr@whamcloud.com>, Cyril Bordage <cbordage@whamcloud.com>,
 Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

large nid now used more places.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 3d0b1b0200542f845 ("LU-10391 lustre: change cfs_match_nid to take large nid.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50098
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c      |  2 +-
 include/uapi/linux/lnet/nidstr.h |  2 +-
 net/lnet/lnet/nidstrings.c       | 10 ++++++----
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 2c286e858056..d4f17ce24465 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -3746,7 +3746,7 @@ void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 		while (LNetGetId(i++, &id) != -ENOENT) {
 			if (nid_is_lo0(&id.nid))
 				continue;
-			if (cfs_match_nid(lnet_nid_to_nid4(&id.nid),
+			if (cfs_match_nid(&id.nid,
 					  &squash->rsi_nosquash_nids)) {
 				matched = true;
 				break;
diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index d5829fef0d9f..1ccb8fa826b4 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -98,7 +98,7 @@ char *libcfs_id2str(struct lnet_process_id id);
 void cfs_free_nidlist(struct list_head *list);
 int cfs_parse_nidlist(char *str, int len, struct list_head *list);
 int cfs_print_nidlist(char *buffer, int count, struct list_head *list);
-int cfs_match_nid(lnet_nid_t nid, struct list_head *list);
+int cfs_match_nid(struct lnet_nid *nid, struct list_head *list);
 int cfs_match_net(__u32 net_id, __u32 net_type,
 		  struct list_head *net_num_list);
 
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index b5a585507d6a..d235048a8ff0 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -358,20 +358,22 @@ EXPORT_SYMBOL(cfs_parse_nidlist);
  *
  * Return:	1 on match, 0 otherwises
  */
-int cfs_match_nid(lnet_nid_t nid, struct list_head *nidlist)
+int cfs_match_nid(struct lnet_nid *nid, struct list_head *nidlist)
 {
 	struct nidrange *nr;
 	struct addrrange *ar;
 
+	if (!nid_is_nid4(nid))
+		return 0;
 	list_for_each_entry(nr, nidlist, nr_link) {
-		if (nr->nr_netstrfns->nf_type != LNET_NETTYP(LNET_NIDNET(nid)))
+		if (nr->nr_netstrfns->nf_type != nid->nid_type)
 			continue;
-		if (nr->nr_netnum != LNET_NETNUM(LNET_NIDNET(nid)))
+		if (nr->nr_netnum != be16_to_cpu(nid->nid_num))
 			continue;
 		if (nr->nr_all)
 			return 1;
 		list_for_each_entry(ar, &nr->nr_addrranges, ar_link)
-			if (nr->nr_netstrfns->nf_match_addr(LNET_NIDADDR(nid),
+			if (nr->nr_netstrfns->nf_match_addr(be32_to_cpu(nid->nid_addr[0]),
 							    &ar->ar_numaddr_ranges))
 				return 1;
 	}
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
