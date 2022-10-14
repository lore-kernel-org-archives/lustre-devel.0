Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 02DD0C4332F
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0BV4pntz1y53;
	Fri, 14 Oct 2022 14:38:42 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0B62xx2z1y2q
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:22 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 0B44610084A8;
 Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 09685DD6C6; Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:38:01 -0400
Message-Id: <1665783491-13827-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/20] lustre: ptlrpc: add assert for
 ptlrpc_service_purge_all
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
Cc: Etienne AUJAMES <etienne.aujames@cea.fr>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Etienne AUJAMES <etienne.aujames@cea.fr>

ptlrpc_service_purge_all() calls ptlrpc_server_request_get() with
"force=true" to purge all active requests before stopping an NRS
policy (when unregistering a service).

"force" mode should always return a request if a pending request is
present in the NRS policy.

BUG: unable to handle kernel NULL pointer dereference at
0000000000000114
IP: [<ffffffffc0d9e965>] ptlrpc_nrs_req_stop_nolock+0x5/0x150
.....
? ptlrpc_server_finish_active_request+0x2b/0x140 [ptlrpc]
ptlrpc_service_purge_all+0x137/0x920 [ptlrpc]
ptlrpc_unregister_service+0xe7/0x6f0 [ptlrpc]
ost_cleanup+0x52/0x1b0 [ost]
class_free_dev+0x21d/0x720 [obdclass]
class_export_put+0x1f0/0x2c0 [obdclass]
class_unlink_export+0x135/0x170 [obdclass]
class_decref+0x80/0x160 [obdclass]
class_detach+0x1b3/0x2e0 [obdclass]
class_process_config+0x1a38/0x2830 [obdclass]
? complete+0x4a/0x60
? list_del+0xd/0x30
? wait_for_completion+0x4e/0x140
class_manual_cleanup+0x1e0/0x710 [obdclass]
server_stop_servers+0xd5/0x160 [obdclass]
server_put_super+0x12d/0xd00 [obdclass]
generic_shutdown_super+0x6d/0x100

WC-bug-id: https://jira.whamcloud.com/browse/LU-16144
Lustre-commit: 1bba7dd425d3fc9ef3 ("LU-16144 nrs: implement force mode for nrs_tbf_req_get()")
Signed-off-by: Etienne AUJAMES <etienne.aujames@cea.fr>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48494
Reviewed-by: Nikitas Angelinas <nikitas.angelinas@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/service.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index 59fe1f4aa18f..aaf7529e25f3 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -2939,6 +2939,7 @@ ptlrpc_service_purge_all(struct ptlrpc_service *svc)
 
 		while (ptlrpc_server_request_pending(svcpt, true)) {
 			req = ptlrpc_server_request_get(svcpt, true);
+			LASSERT(req);
 			ptlrpc_server_finish_active_request(svcpt, req);
 		}
 
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
