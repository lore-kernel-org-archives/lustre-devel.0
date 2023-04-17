Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1A9BFC77B70
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 14:12:21 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T7W6K51z22Vv;
	Mon, 17 Apr 2023 06:54:31 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0T2G44w1z21HF
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:49:58 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B2E231008498;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B1BD9372; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:18 -0400
Message-Id: <1681739243-29375-23-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 22/27] lustre: obdclass: change
 class_add/check_uuid to large nid
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

class_add_uuid() and class_check_uuid() are changed to take
a struct lnet_nid* rather than a u64 (aka lnet_nid_t).

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 16d84b030520c431da ("LU-10391 obdclass: change class_add/check_uuid to large nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50086
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h    |  4 ++--
 fs/lustre/ldlm/ldlm_lib.c        | 13 +++++++++----
 fs/lustre/obdclass/lustre_peer.c | 24 ++++++++++--------------
 fs/lustre/obdclass/obd_config.c  |  5 +++--
 4 files changed, 24 insertions(+), 22 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 0c95c3c..f77fd12 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -1742,11 +1742,11 @@ struct lwp_register_item {
 /* lustre_peer.c    */
 int lustre_uuid_to_peer(const char *uuid, struct lnet_nid *peer_nid,
 			int index);
-int class_add_uuid(const char *uuid, u64 nid);
+int class_add_uuid(const char *uuid, struct lnet_nid *nid);
 int class_del_uuid(const char *uuid);
 int class_add_nids_to_uuid(struct obd_uuid *uuid, lnet_nid_t *nids,
 			   int nid_count);
-int class_check_uuid(struct obd_uuid *uuid, u64 nid);
+int class_check_uuid(struct obd_uuid *uuid, struct lnet_nid *nid);
 
 /* class_obd.c */
 extern char obd_jobid_name[];
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index b1ce0d4..4f9cf5f 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -141,16 +141,18 @@ int client_import_add_conn(struct obd_import *imp, struct obd_uuid *uuid,
 EXPORT_SYMBOL(client_import_add_conn);
 
 int client_import_dyn_add_conn(struct obd_import *imp, struct obd_uuid *uuid,
-			       lnet_nid_t prim_nid, int priority)
+			       lnet_nid_t prim_nid4, int priority)
 {
 	struct ptlrpc_connection *ptlrpc_conn;
+	struct lnet_nid prim_nid;
 	int rc;
 
-	ptlrpc_conn = ptlrpc_uuid_to_connection(uuid, LNET_NIDNET(prim_nid));
+	lnet_nid4_to_nid(prim_nid4, &prim_nid);
+	ptlrpc_conn = ptlrpc_uuid_to_connection(uuid, LNET_NID_NET(&prim_nid));
 	if (!ptlrpc_conn) {
 		const char *str_uuid = obd_uuid2str(uuid);
 
-		rc = class_add_uuid(str_uuid, prim_nid);
+		rc = class_add_uuid(str_uuid, &prim_nid);
 		if (rc) {
 			CERROR("%s: failed to add UUID '%s': rc = %d\n",
 			       imp->imp_obd->obd_name, str_uuid, rc);
@@ -172,7 +174,10 @@ int client_import_add_nids_to_conn(struct obd_import *imp, lnet_nid_t *nids,
 
 	spin_lock(&imp->imp_lock);
 	list_for_each_entry(conn, &imp->imp_conn_list, oic_item) {
-		if (class_check_uuid(&conn->oic_uuid, nids[0])) {
+		struct lnet_nid nid;
+
+		lnet_nid4_to_nid(nids[0], &nid);
+		if (class_check_uuid(&conn->oic_uuid, &nid)) {
 			*uuid = conn->oic_uuid;
 			spin_unlock(&imp->imp_lock);
 			rc = class_add_nids_to_uuid(&conn->oic_uuid, nids,
diff --git a/fs/lustre/obdclass/lustre_peer.c b/fs/lustre/obdclass/lustre_peer.c
index 2049c41..aae69d3 100644
--- a/fs/lustre/obdclass/lustre_peer.c
+++ b/fs/lustre/obdclass/lustre_peer.c
@@ -77,15 +77,13 @@ int lustre_uuid_to_peer(const char *uuid, struct lnet_nid *peer_nid, int index)
 /* Add a nid to a niduuid.  Multiple nids can be added to a single uuid;
  * LNET will choose the best one.
  */
-int class_add_uuid(const char *uuid, lnet_nid_t nid4)
+int class_add_uuid(const char *uuid, struct lnet_nid *nid)
 {
 	struct uuid_nid_data *data, *entry;
-	struct lnet_nid nid;
 	int found = 0;
 	int rc;
 
-	LASSERT(nid4 != 0);  /* valid newconfig NID is never zero */
-	lnet_nid4_to_nid(nid4, &nid);
+	LASSERT(nid->nid_type != 0);  /* valid newconfig NID is never zero */
 
 	if (strlen(uuid) > UUID_MAX - 1)
 		return -EOVERFLOW;
@@ -95,7 +93,7 @@ int class_add_uuid(const char *uuid, lnet_nid_t nid4)
 		return -ENOMEM;
 
 	obd_str2uuid(&data->un_uuid, uuid);
-	data->un_nids[0] = nid;
+	data->un_nids[0] = *nid;
 	data->un_nid_count = 1;
 
 	spin_lock(&g_uuid_lock);
@@ -105,12 +103,12 @@ int class_add_uuid(const char *uuid, lnet_nid_t nid4)
 
 			found = 1;
 			for (i = 0; i < entry->un_nid_count; i++)
-				if (nid_same(&nid, &entry->un_nids[i]))
+				if (nid_same(nid, &entry->un_nids[i]))
 					break;
 
 			if (i == entry->un_nid_count) {
 				LASSERT(entry->un_nid_count < MTI_NIDS_MAX);
-				entry->un_nids[entry->un_nid_count++] = nid;
+				entry->un_nids[entry->un_nid_count++] = *nid;
 			}
 			break;
 		}
@@ -121,13 +119,13 @@ int class_add_uuid(const char *uuid, lnet_nid_t nid4)
 
 	if (found) {
 		CDEBUG(D_INFO, "found uuid %s %s cnt=%d\n", uuid,
-		       libcfs_nidstr(&nid), entry->un_nid_count);
+		       libcfs_nidstr(nid), entry->un_nid_count);
 		rc = LNetAddPeer(entry->un_nids, entry->un_nid_count);
 		CDEBUG(D_INFO, "Add peer %s rc = %d\n",
 		       libcfs_nidstr(&data->un_nids[0]), rc);
 		kfree(data);
 	} else {
-		CDEBUG(D_INFO, "add uuid %s %s\n", uuid, libcfs_nidstr(&nid));
+		CDEBUG(D_INFO, "add uuid %s %s\n", uuid, libcfs_nidstr(nid));
 		rc = LNetAddPeer(data->un_nids, data->un_nid_count);
 		CDEBUG(D_INFO, "Add peer %s rc = %d\n",
 		       libcfs_nidstr(&data->un_nids[0]), rc);
@@ -218,15 +216,13 @@ int class_add_nids_to_uuid(struct obd_uuid *uuid, lnet_nid_t *nids,
 EXPORT_SYMBOL(class_add_nids_to_uuid);
 
 /* check if @nid exists in nid list of @uuid */
-int class_check_uuid(struct obd_uuid *uuid, lnet_nid_t nid4)
+int class_check_uuid(struct obd_uuid *uuid, struct lnet_nid *nid)
 {
 	struct uuid_nid_data *entry;
-	struct lnet_nid nid;
 	int found = 0;
 
-	lnet_nid4_to_nid(nid4, &nid);
 	CDEBUG(D_INFO, "check if uuid %s has %s.\n",
-	       obd_uuid2str(uuid), libcfs_nidstr(&nid));
+	       obd_uuid2str(uuid), libcfs_nidstr(nid));
 
 	spin_lock(&g_uuid_lock);
 	list_for_each_entry(entry, &g_uuid_list, un_list) {
@@ -237,7 +233,7 @@ int class_check_uuid(struct obd_uuid *uuid, lnet_nid_t nid4)
 
 		/* found the uuid, check if it has @nid */
 		for (i = 0; i < entry->un_nid_count; i++) {
-			if (nid_same(&entry->un_nids[i], &nid)) {
+			if (nid_same(&entry->un_nids[i], nid)) {
 				found = 1;
 				break;
 			}
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index f2173df..81021e1 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -822,6 +822,7 @@ static int process_param2_config(struct lustre_cfg *lcfg)
 int class_process_config(struct lustre_cfg *lcfg)
 {
 	struct obd_device *obd;
+	struct lnet_nid nid;
 	int err;
 
 	LASSERT(lcfg && !IS_ERR(lcfg));
@@ -839,8 +840,8 @@ int class_process_config(struct lustre_cfg *lcfg)
 		       lustre_cfg_string(lcfg, 1), lcfg->lcfg_nid,
 		       libcfs_nid2str(lcfg->lcfg_nid));
 
-		err = class_add_uuid(lustre_cfg_string(lcfg, 1),
-				     lcfg->lcfg_nid);
+		lnet_nid4_to_nid(lcfg->lcfg_nid, &nid);
+		err = class_add_uuid(lustre_cfg_string(lcfg, 1), &nid);
 		goto out;
 	}
 	case LCFG_DEL_UUID: {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
