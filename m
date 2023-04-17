Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3929BC77B70
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 14:03:56 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T4B2fwrz1yHG;
	Mon, 17 Apr 2023 06:51:38 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0T231KkLz1wb0
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:49:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id AE8B01008497;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id ACDD5379; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:17 -0400
Message-Id: <1681739243-29375-22-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 21/27] lnet: change LNetAddPeer() to take
 struct lnet_nid
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

Rather than an array of lnet_nid_t, LNetAddPeer now takes an array of
struct lnet_nid.

The array passed is *always* from struct uuid_nid_data, so that data
structure is changed to store struct lnet_nid.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 42b49afdc8a4d2ec65 ("LU-10391 lnet: change LNetAddPeer() to take struct lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50085
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/lustre_peer.c | 34 +++++++++++++++++++---------------
 include/linux/lnet/api.h         |  2 +-
 net/lnet/lnet/peer.c             | 17 +++++++----------
 3 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/fs/lustre/obdclass/lustre_peer.c b/fs/lustre/obdclass/lustre_peer.c
index 5eae2eb..2049c41 100644
--- a/fs/lustre/obdclass/lustre_peer.c
+++ b/fs/lustre/obdclass/lustre_peer.c
@@ -44,7 +44,7 @@ struct uuid_nid_data {
 	struct list_head	un_list;
 	struct obd_uuid		un_uuid;
 	int			un_nid_count;
-	lnet_nid_t		un_nids[MTI_NIDS_MAX];
+	struct lnet_nid		un_nids[MTI_NIDS_MAX];
 };
 
 /* FIXME: This should probably become more elegant than a global linked list */
@@ -65,7 +65,7 @@ int lustre_uuid_to_peer(const char *uuid, struct lnet_nid *peer_nid, int index)
 				break;
 
 			rc = 0;
-			lnet_nid4_to_nid(data->un_nids[index], peer_nid);
+			*peer_nid = data->un_nids[index];
 			break;
 		}
 	}
@@ -77,13 +77,15 @@ int lustre_uuid_to_peer(const char *uuid, struct lnet_nid *peer_nid, int index)
 /* Add a nid to a niduuid.  Multiple nids can be added to a single uuid;
  * LNET will choose the best one.
  */
-int class_add_uuid(const char *uuid, u64 nid)
+int class_add_uuid(const char *uuid, lnet_nid_t nid4)
 {
 	struct uuid_nid_data *data, *entry;
+	struct lnet_nid nid;
 	int found = 0;
 	int rc;
 
-	LASSERT(nid != 0);  /* valid newconfig NID is never zero */
+	LASSERT(nid4 != 0);  /* valid newconfig NID is never zero */
+	lnet_nid4_to_nid(nid4, &nid);
 
 	if (strlen(uuid) > UUID_MAX - 1)
 		return -EOVERFLOW;
@@ -103,7 +105,7 @@ int class_add_uuid(const char *uuid, u64 nid)
 
 			found = 1;
 			for (i = 0; i < entry->un_nid_count; i++)
-				if (nid == entry->un_nids[i])
+				if (nid_same(&nid, &entry->un_nids[i]))
 					break;
 
 			if (i == entry->un_nid_count) {
@@ -119,16 +121,16 @@ int class_add_uuid(const char *uuid, u64 nid)
 
 	if (found) {
 		CDEBUG(D_INFO, "found uuid %s %s cnt=%d\n", uuid,
-		       libcfs_nid2str(nid), entry->un_nid_count);
+		       libcfs_nidstr(&nid), entry->un_nid_count);
 		rc = LNetAddPeer(entry->un_nids, entry->un_nid_count);
 		CDEBUG(D_INFO, "Add peer %s rc = %d\n",
-		       libcfs_nid2str(data->un_nids[0]), rc);
+		       libcfs_nidstr(&data->un_nids[0]), rc);
 		kfree(data);
 	} else {
-		CDEBUG(D_INFO, "add uuid %s %s\n", uuid, libcfs_nid2str(nid));
+		CDEBUG(D_INFO, "add uuid %s %s\n", uuid, libcfs_nidstr(&nid));
 		rc = LNetAddPeer(data->un_nids, data->un_nid_count);
 		CDEBUG(D_INFO, "Add peer %s rc = %d\n",
-		       libcfs_nid2str(data->un_nids[0]), rc);
+		       libcfs_nidstr(&data->un_nids[0]), rc);
 	}
 	return 0;
 }
@@ -167,7 +169,7 @@ int class_del_uuid(const char *uuid)
 
 		CDEBUG(D_INFO, "del uuid %s %s/%d\n",
 		       obd_uuid2str(&data->un_uuid),
-		       libcfs_nid2str(data->un_nids[0]),
+		       libcfs_nidstr(&data->un_nids[0]),
 		       data->un_nid_count);
 
 		kfree(data);
@@ -200,7 +202,7 @@ int class_add_nids_to_uuid(struct obd_uuid *uuid, lnet_nid_t *nids,
 		matched = true;
 		CDEBUG(D_NET, "Updating UUID '%s'\n", obd_uuid2str(uuid));
 		for (i = 0; i < nid_count; i++)
-			entry->un_nids[i] = nids[i];
+			lnet_nid4_to_nid(nids[i], &entry->un_nids[i]);
 		entry->un_nid_count = nid_count;
 		break;
 	}
@@ -208,7 +210,7 @@ int class_add_nids_to_uuid(struct obd_uuid *uuid, lnet_nid_t *nids,
 	if (matched) {
 		rc = LNetAddPeer(entry->un_nids, entry->un_nid_count);
 		CDEBUG(D_INFO, "Add peer %s rc = %d\n",
-		       libcfs_nid2str(entry->un_nids[0]), rc);
+		       libcfs_nidstr(&entry->un_nids[0]), rc);
 	}
 
 	return 0;
@@ -216,13 +218,15 @@ int class_add_nids_to_uuid(struct obd_uuid *uuid, lnet_nid_t *nids,
 EXPORT_SYMBOL(class_add_nids_to_uuid);
 
 /* check if @nid exists in nid list of @uuid */
-int class_check_uuid(struct obd_uuid *uuid, u64 nid)
+int class_check_uuid(struct obd_uuid *uuid, lnet_nid_t nid4)
 {
 	struct uuid_nid_data *entry;
+	struct lnet_nid nid;
 	int found = 0;
 
+	lnet_nid4_to_nid(nid4, &nid);
 	CDEBUG(D_INFO, "check if uuid %s has %s.\n",
-	       obd_uuid2str(uuid), libcfs_nid2str(nid));
+	       obd_uuid2str(uuid), libcfs_nidstr(&nid));
 
 	spin_lock(&g_uuid_lock);
 	list_for_each_entry(entry, &g_uuid_list, un_list) {
@@ -233,7 +237,7 @@ int class_check_uuid(struct obd_uuid *uuid, u64 nid)
 
 		/* found the uuid, check if it has @nid */
 		for (i = 0; i < entry->un_nid_count; i++) {
-			if (entry->un_nids[i] == nid) {
+			if (nid_same(&entry->un_nids[i], &nid)) {
 				found = 1;
 				break;
 			}
diff --git a/include/linux/lnet/api.h b/include/linux/lnet/api.h
index 7ea61cb..f6d6c17 100644
--- a/include/linux/lnet/api.h
+++ b/include/linux/lnet/api.h
@@ -164,7 +164,7 @@ int LNetGet(struct lnet_nid *self,
 int LNetCtl(unsigned int cmd, void *arg);
 void LNetDebugPeer(struct lnet_processid *id);
 int LNetGetPeerDiscoveryStatus(void);
-int LNetAddPeer(lnet_nid_t *nids, u32 num_nids);
+int LNetAddPeer(struct lnet_nid *nids, u32 num_nids);
 
 /** @} lnet_misc */
 
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index f1b0eb0d..9168641 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1341,7 +1341,7 @@ struct lnet_peer_ni *
 }
 
 int
-LNetAddPeer(lnet_nid_t *nids, u32 num_nids)
+LNetAddPeer(struct lnet_nid *nids, u32 num_nids)
 {
 	struct lnet_nid pnid = LNET_ANY_NID;
 	bool mr;
@@ -1361,14 +1361,11 @@ struct lnet_peer_ni *
 
 	rc = 0;
 	for (i = 0; i < num_nids; i++) {
-		struct lnet_nid nid;
-
-		if (nids[i] == LNET_NID_LO_0)
+		if (nid_is_lo0(&nids[i]))
 			continue;
 
-		lnet_nid4_to_nid(nids[i], &nid);
 		if (LNET_NID_IS_ANY(&pnid)) {
-			lnet_nid4_to_nid(nids[i], &pnid);
+			pnid = nids[i];
 			rc = lnet_add_peer_ni(&pnid, &LNET_ANY_NID, mr, flags);
 			if (rc == -EALREADY) {
 				struct lnet_peer *lp;
@@ -1384,11 +1381,11 @@ struct lnet_peer_ni *
 				lnet_peer_decref_locked(lp);
 			}
 		} else if (lnet_peer_discovery_disabled) {
-			lnet_nid4_to_nid(nids[i], &nid);
-			rc = lnet_add_peer_ni(&nid, &LNET_ANY_NID, mr, flags);
+			rc = lnet_add_peer_ni(&nids[i], &LNET_ANY_NID, mr,
+					      flags);
 		} else {
-			lnet_nid4_to_nid(nids[i], &nid);
-			rc = lnet_add_peer_ni(&pnid, &nid, mr, flags);
+			rc = lnet_add_peer_ni(&pnid, &nids[i], mr,
+					      flags);
 		}
 
 		if (rc && rc != -EEXIST)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
