Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1BB97C36007
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:25:44 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2rF0ZQTz20vF;
	Fri, 21 Mar 2025 06:10:53 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2nC30zYz1xdl
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:08:15 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8864A88F9FA;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 86F9D106BE19; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:59 -0400
Message-ID: <20250321130711.3257092-17-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 16/27] lustre: ptlrpc: add missing header
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

Missing headers for layout.c in ptlrpc cause functions
to be incorrectly marked as only being used within
layout.c. This patch adds the missing header.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8181
Lustre-commit: fba78a416621343aa ("LU-8191 ptlrpc: add missing headers")
Signed-off-by: Timothy Day <timday@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51480
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/layout.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 64e0224ce496..263a926d1e02 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -58,6 +58,8 @@
 #include <lustre_req_layout.h>
 #include <lustre_acl.h>
 
+#include "ptlrpc_internal.h"
+
 /*
  * RQFs (see below) refer to two struct req_msg_field arrays describing the
  * client request and server reply, respectively.
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
