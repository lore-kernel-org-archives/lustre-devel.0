Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CA2AFC02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:41:19 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWxW5Qf1z1yCv;
	Fri, 07 Feb 2025 16:31:59 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWw60mHBz1xYp
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:46 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 19C78893E8A;
 Fri,  7 Feb 2025 19:30:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 17937106BE17; Fri,  7 Feb 2025 19:30:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:20 -0500
Message-ID: <20250208003027.180076-15-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 14/21] lustre: gss: fix ptlrpc_gss automatic
 loading
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
Cc: Aurelien Degremont <adegremont@nvidia.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sebastien Buisson <sbuisson@ddn.com>

ptlrpc_gss kernel module is automatically loaded when a GSS security
flavor is enforced. Loading success is recorded in a static variable
in the ptlrpc module, which prevents further reloading in case
ptlrpc_gss is unloaded while keeping ptlrpc loaded.
Get rid of this static variable as it is not required in order to
avoid calling request_module("ptlrpc_gss") when not needed. Indeed,
once loaded, the static array policies[] has an entry at the
SPTLRPC_POLICY_GSS index, indicating that the ptlrpc_gss module is
loaded.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16888
Lustre-commit: b80d6defb7b018250 ("LU-16888 gss: fix ptlrpc_gss automatic loading")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51264
Reviewed-by: Aurelien Degremont <adegremont@nvidia.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/sec.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index 576e6480cda8..c9ad27617836 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -116,10 +116,9 @@ static
 struct ptlrpc_sec_policy *sptlrpc_wireflavor2policy(u32 flavor)
 {
 	static DEFINE_MUTEX(load_mutex);
-	static atomic_t loaded = ATOMIC_INIT(0);
 	struct ptlrpc_sec_policy *policy;
 	u16 number = SPTLRPC_FLVR_POLICY(flavor);
-	u16 flag = 0;
+	int rc;
 
 	if (number >= SPTLRPC_POLICY_MAX)
 		return NULL;
@@ -129,25 +128,26 @@ struct ptlrpc_sec_policy *sptlrpc_wireflavor2policy(u32 flavor)
 		policy = policies[number];
 		if (policy && !try_module_get(policy->sp_owner))
 			policy = NULL;
-		if (!policy)
-			flag = atomic_read(&loaded);
 		read_unlock(&policy_lock);
 
-		if (policy || flag != 0 ||
-		    number != SPTLRPC_POLICY_GSS)
+		if (policy || number != SPTLRPC_POLICY_GSS)
 			break;
 
-		/* try to load gss module, once */
+		/* try to load gss module, happens only if policy at index
+		 * SPTLRPC_POLICY_GSS is not already referenced in
+		 * global array policies[]
+		 */
 		mutex_lock(&load_mutex);
-		if (atomic_read(&loaded) == 0) {
-			if (request_module("ptlrpc_gss") == 0)
-				CDEBUG(D_SEC,
-				       "module ptlrpc_gss loaded on demand\n");
-			else
-				CERROR("Unable to load module ptlrpc_gss\n");
-
-			atomic_set(&loaded, 1);
-		}
+		/* The fact that request_module() returns 0 does not guarantee
+		 * the module has done its job. So we must check that the
+		 * requested policy is now available. This is done by checking
+		 * again for policies[number] in the loop.
+		 */
+		rc = request_module("ptlrpc_gss");
+		if (rc == 0)
+			CDEBUG(D_SEC, "module ptlrpc_gss loaded on demand\n");
+		else
+			CERROR("Unable to load module ptlrpc_gss: rc %d\n", rc);
 		mutex_unlock(&load_mutex);
 	}
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
