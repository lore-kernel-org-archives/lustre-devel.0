Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 13E6CC19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:39:58 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyry53lzRz23K5;
	Wed,  3 Aug 2022 18:39:57 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Lyrwj6Jdkz23Jr
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:45 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id F3414100B053;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F0AAF8D620; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:12 -0400
Message-Id: <1659577097-19253-28-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 27/32] lnet: Define KFILND network type
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

Define the KFILND network type. This reserves the network type number
for future implementation and allows creation of kfi peers and
adding routes to kfi peers.

HPE-bug-id: LUS-11060

WC-bug-id: https://jira.whamcloud.com/browse/LU-15983
Lustre-commit: 5fea36c952373c9a2 ("LU-15983 lnet: Define KFILND network type")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/47830
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lnet/nidstr.h |  1 +
 net/lnet/lnet/nidstrings.c       | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index 80be2eb..d5829fe 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -55,6 +55,7 @@ enum {
 	GNILND		= 13,
 	GNIIPLND	= 14,
 	PTL4LND		= 15,
+	KFILND		= 16,
 
 	NUM_LNDS
 };
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index 3523b78..ac2aa97 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -758,6 +758,16 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 	  .nf_print_addrlist	= libcfs_num_addr_range_print,
 	  .nf_match_addr	= libcfs_num_match
 	},
+	{
+	  .nf_type		= KFILND,
+	  .nf_name		= "kfi",
+	  .nf_modname		= "kkfilnd",
+	  .nf_addr2str		= libcfs_decnum_addr2str,
+	  .nf_str2addr		= libcfs_num_str2addr,
+	  .nf_parse_addrlist	= libcfs_num_parse,
+	  .nf_print_addrlist	= libcfs_num_addr_range_print,
+	  .nf_match_addr	= libcfs_num_match
+	},
 };
 
 static const size_t libcfs_nnetstrfns = ARRAY_SIZE(libcfs_netstrfns);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
