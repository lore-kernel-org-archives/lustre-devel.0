Return-Path: <SRS0=GtYW=HL=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B26B7C433E6
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:48 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6AEF664E77
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AEF664E77
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6B7DC30FAF4;
	Mon,  8 Feb 2021 16:54:42 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 67B5330F986
 for <lustre-devel@lists.lustre.org>; Mon,  8 Feb 2021 16:54:32 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 04AFD1006EBE;
 Mon,  8 Feb 2021 19:54:29 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EE7DD4CC39; Mon,  8 Feb 2021 19:54:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Feb 2021 19:54:23 -0500
Message-Id: <1612832067-1449-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
References: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 5/9] lustre: ldlm: don't change GROUP lock
 GID on client
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
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mikhail Pershin <mpershin@whamcloud.com>

GROUP lock GID is part of inodebits policy and is passed
to the server from client in policy li_gid field.
Meanwhile the ldlm_ibits_policy_wire_to_local() is used on
client also when server reply or completion AST is processed,
so client original GID can be overwritten by server value.
This is not problem if both server and client have the same
Lustre version but if server is older then it can have garbage
in li_gid field and client lock policy is updated with it.

Considering that GROUP lock GID is never changed and server should
not do that, the solution is to ignore returned li_gid from server
and never update original GID of GROUP lock on client from server
response.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14312
Lustre-commit: da18ad5628556cb ("LU-14312 ldlm: don't change GROUP lock GID on client")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41268
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_inodebits.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/ldlm/ldlm_inodebits.c b/fs/lustre/ldlm/ldlm_inodebits.c
index a367ff1..32de9b9 100644
--- a/fs/lustre/ldlm/ldlm_inodebits.c
+++ b/fs/lustre/ldlm/ldlm_inodebits.c
@@ -59,7 +59,10 @@ void ldlm_ibits_policy_wire_to_local(const union ldlm_wire_policy_data *wpolicy,
 				     union ldlm_policy_data *lpolicy)
 {
 	lpolicy->l_inodebits.bits = wpolicy->l_inodebits.bits;
-	lpolicy->l_inodebits.li_gid = wpolicy->l_inodebits.li_gid;
+	/**
+	 * try_bits and li_gid are to be handled outside of generic
+	 * write_to_local due to different behavior on a server and client.
+	 */
 }
 
 void ldlm_ibits_policy_local_to_wire(const union ldlm_policy_data *lpolicy,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
