Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id BAFA4C32771
	for <lustre-devel@archiver.kernel.org>; Sun, 18 Sep 2022 05:22:36 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MVbmB0pj4z1yDs;
	Sat, 17 Sep 2022 22:22:34 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MVblw6ns4z1wLC
 for <lustre-devel@lists.lustre.org>; Sat, 17 Sep 2022 22:22:20 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id D59B58ABE;
 Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id CBE6527E1; Sun, 18 Sep 2022 01:22:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 18 Sep 2022 01:21:53 -0400
Message-Id: <1663478534-19917-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
References: <1663478534-19917-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/24] lustre: ptlrpc: pass net num to
 ptlrpc_uuid_to_connection
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
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

Rather than passing a nid to indicate which net to choose,
pass just the net number.  This will make it easier to convert to
'struct lnet_nid'.

Also change ptlrpc_uuid_to_peer() to take the refnet as an explicit
argument, rather than embedding in in the peer pid.

This makes the refnet test more obvious, and removes the (strange)
need to test the address part against zero.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: a0bdb01ad05b24d24 ("LU-10391 ptlrpc: pass net num to ptlrpc_uuid_to_connection")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/44637
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h |  5 +++--
 fs/lustre/ldlm/ldlm_lib.c      | 10 +++++-----
 fs/lustre/ptlrpc/client.c      |  5 ++---
 fs/lustre/ptlrpc/events.c      |  7 ++++---
 4 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 3a35b03..d564e28 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -1707,7 +1707,8 @@ static inline bool nrs_policy_compat_one(const struct ptlrpc_service *svc,
 /* ptlrpc/events.c */
 int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 			struct lnet_process_id *peer,
-			struct lnet_nid *self);
+			struct lnet_nid *self,
+			u32 refnet);
 /**
  * These callbacks are invoked by LNet when something happened to
  * underlying buffer
@@ -1811,7 +1812,7 @@ static inline int ptlrpc_client_bulk_active(struct ptlrpc_request *req)
 void ptlrpc_init_client(int req_portal, int rep_portal, const char *name,
 			struct ptlrpc_client *);
 struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid,
-						    lnet_nid_t nid4refnet);
+						    u32 refnet);
 
 int ptlrpc_queue_wait(struct ptlrpc_request *req);
 int ptlrpc_replay_req(struct ptlrpc_request *req);
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 02d1eea..804bb9c 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -56,7 +56,7 @@ static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
 {
 	struct ptlrpc_connection *ptlrpc_conn;
 	struct obd_import_conn *imp_conn = NULL, *item;
-	lnet_nid_t nid4refnet = LNET_NID_ANY;
+	u32 refnet = LNET_NET_ANY;
 	int rc = 0;
 
 	if (!create && !priority) {
@@ -66,10 +66,10 @@ static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
 
 	if (imp->imp_connection &&
 	    imp->imp_connection->c_remote_uuid.uuid[0] == 0)
-		/* nid4refnet is used to restrict network connections */
-		nid4refnet = lnet_nid_to_nid4(&imp->imp_connection->c_self);
+		/* refnet is used to restrict network connections */
+		refnet = LNET_NID_NET(&imp->imp_connection->c_self);
 
-	ptlrpc_conn = ptlrpc_uuid_to_connection(uuid, nid4refnet);
+	ptlrpc_conn = ptlrpc_uuid_to_connection(uuid, refnet);
 	if (!ptlrpc_conn) {
 		CDEBUG(D_HA, "can't find connection %s\n", uuid->uuid);
 		return -ENOENT;
@@ -145,7 +145,7 @@ int client_import_dyn_add_conn(struct obd_import *imp, struct obd_uuid *uuid,
 	struct ptlrpc_connection *ptlrpc_conn;
 	int rc;
 
-	ptlrpc_conn = ptlrpc_uuid_to_connection(uuid, prim_nid);
+	ptlrpc_conn = ptlrpc_uuid_to_connection(uuid, LNET_NIDNET(prim_nid));
 	if (!ptlrpc_conn) {
 		const char *str_uuid = obd_uuid2str(uuid);
 
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 7a4a9c9..7ca7d35 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -102,7 +102,7 @@ void ptlrpc_init_client(int req_portal, int rep_portal, const char *name,
  * Return PortalRPC connection for remote uud @uuid
  */
 struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid,
-						    lnet_nid_t nid4refnet)
+						    u32 refnet)
 {
 	struct ptlrpc_connection *c;
 	struct lnet_nid self;
@@ -114,8 +114,7 @@ struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid,
 	 * before accessing its values.
 	 * coverity[uninit_use_in_call]
 	 */
-	peer.nid = nid4refnet;
-	err = ptlrpc_uuid_to_peer(uuid, &peer, &self);
+	err = ptlrpc_uuid_to_peer(uuid, &peer, &self, refnet);
 	if (err != 0) {
 		CNETERR("cannot find peer %s!\n", uuid->uuid);
 		return NULL;
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index 231eace..793c078 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -469,7 +469,8 @@ static void ptlrpc_master_callback(struct lnet_event *ev)
 
 int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 			struct lnet_process_id *peer,
-			struct lnet_nid *self)
+			struct lnet_nid *self,
+			u32 refnet)
 {
 	int best_dist = 0;
 	u32 best_order = 0;
@@ -484,8 +485,8 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 
 	/* Choose the matching UUID that's closest */
 	while (lustre_uuid_to_peer(uuid->uuid, &dst_nid, count++) == 0) {
-		if (peer->nid != LNET_NID_ANY && LNET_NIDADDR(peer->nid) == 0 &&
-		    LNET_NID_NET(&dst_nid) != LNET_NIDNET(peer->nid))
+		if (refnet != LNET_NET_ANY &&
+		    LNET_NID_NET(&dst_nid) != refnet)
 			continue;
 
 		dist = LNetDist(&dst_nid, &src_nid, &order);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
