Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 39BB4C0219D
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:34:17 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWw96WVYz1xNq;
	Fri, 07 Feb 2025 16:30:49 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWw675RVz1xdj
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:46 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 247BA893E8D;
 Fri,  7 Feb 2025 19:30:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 1F10C106BE14; Fri,  7 Feb 2025 19:30:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:22 -0500
Message-ID: <20250208003027.180076-17-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 16/21] lustre: osc: Don't include lock for
 srvlock
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <pfarrell@whamcloud.com>

When doing server side locking, it doesn't make sense to do
the 'search for covering lock and send it to the server'
step when building an RPC, because we will not use that
lock.

This can disguise issues on the client, because prolonging
a lock is supposed to let a client avoid eviction if it is
still doing IO under the lock, but we are not.  This can
result in delaying an eviction which should be occurring
because the client can't give the lock back.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13805
Lustre-commit: 9a34ec2b09864a933 ("LU-13805 osc: Don't include lock for srvlock")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50067
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_object.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index efb053323dda..dd2820b8049a 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -344,10 +344,12 @@ static void osc_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 	struct lov_oinfo *oinfo;
 	struct ost_lvb *lvb;
 	struct obdo *oa;
+	struct osc_page *opg;
 
 	oinfo = cl2osc(obj)->oo_oinfo;
 	lvb = &oinfo->loi_lvb;
 	oa = attr->cra_oa;
+	opg = osc_cl_page_osc(attr->cra_page, cl2osc(obj));
 
 	if (flags & OBD_MD_FLMTIME) {
 		oa->o_mtime = lvb->lvb_mtime;
@@ -381,14 +383,15 @@ static void osc_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 		}
 		oa->o_valid |= OBD_MD_FLID;
 	}
-	if (flags & OBD_MD_FLHANDLE) {
+	/* if srvlock is set, don't look for a local lock, since we won't use
+	 * it and shouldn't note it in the RPC
+	 */
+	if (flags & OBD_MD_FLHANDLE && !opg->ops_srvlock) {
 		struct ldlm_lock *lock;
-		struct osc_page *opg;
 
-		opg = osc_cl_page_osc(attr->cra_page, cl2osc(obj));
 		lock = osc_dlmlock_at_pgoff(env, cl2osc(obj), osc_index(opg),
 					    OSC_DAP_FL_TEST_LOCK | OSC_DAP_FL_CANCELING);
-		if (!lock && !opg->ops_srvlock) {
+		if (!lock) {
 			struct ldlm_namespace *ns;
 			struct ldlm_resource *res;
 			struct ldlm_res_id *resname;
@@ -405,12 +408,9 @@ static void osc_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 			LBUG();
 		}
 
-		/* check for lockless io. */
-		if (lock) {
-			oa->o_handle = lock->l_remote_handle;
-			oa->o_valid |= OBD_MD_FLHANDLE;
-			LDLM_LOCK_PUT(lock);
-		}
+		oa->o_handle = lock->l_remote_handle;
+		oa->o_valid |= OBD_MD_FLHANDLE;
+		LDLM_LOCK_PUT(lock);
 	}
 }
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
