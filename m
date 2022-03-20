Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D9992C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:23 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1114821FA66;
	Sun, 20 Mar 2022 06:31:52 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E996921E05E
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:16 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 4B943EF2;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 45B62D6A26; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:41 -0400
Message-Id: <1647783064-20688-28-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 27/50] lnet: Fix NULL-deref in lnet_nidstr_r()
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

It is valid to pass NULL as the nid for lnet_nidstr_r() - it indicate
"any" nid.  LNET_NID_IS_ANY() tests for this and the function exits
early.

However, 'lnd' is assigned from "nid->nid_type" and 'nnum' from
"nid->nid_num", causing a NULL-pointer dereference.

So move these assignments later.

Fixes: a2cfedead042 ("lnet: introduce struct lnet_nid")
WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 8ed370864c4747281 ("LU-10391 lnet: Fix NULL-deref in lnet_nidstr_r()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/44838
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/nidstrings.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index dfd6744..3523b78 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -967,8 +967,8 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 char *
 libcfs_nidstr_r(const struct lnet_nid *nid, char *buf, size_t buf_size)
 {
-	u32 nnum = be16_to_cpu(nid->nid_num);
-	u32 lnd  = nid->nid_type;
+	u32 nnum;
+	u32 lnd;
 	struct netstrfns *nf;
 
 	if (LNET_NID_IS_ANY(nid)) {
@@ -977,6 +977,8 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 		return buf;
 	}
 
+	nnum = be16_to_cpu(nid->nid_num);
+	lnd = nid->nid_type;
 	nf = libcfs_lnd2netstrfns(lnd);
 	if (nf) {
 		size_t addr_len;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
