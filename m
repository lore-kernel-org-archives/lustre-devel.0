Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F7CBC4338F
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:11 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D2ABC61360
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org D2ABC61360
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7DBD221CC12;
	Sun, 22 Aug 2021 19:28:02 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3D42C21CAB2
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 19:27:53 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 349B5100BB00;
 Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2D577B6C80; Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 22 Aug 2021 22:27:42 -0400
Message-Id: <1629685666-4533-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
References: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/15] lustre: obdclass: Add peer/peer NI
 when processing llog
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

Construct peers when processing the config log so that LNet has
complete information about peer info stored in the config log.

These are "temporary" peers which can be overwritten by discovery.

In client_import_add_nids_to_conn(), we do not need to hold the
import lock when adding NIDs to the obd_uuid, and LNet needs to take
the LNet API mutex when adding/modifying peers. We don't want to take
the mutex while a spin lock is already being held, so drop the spin
lock prior to calling class_add_nids_to_uuid().

HPE-bug-id: LUS-9293
WC-bug-id: https://jira.whamcloud.com/browse/LU-14661
Lustre-commit: 16321de596f63951 ("LU-14661 obdclass: Add peer/peer NI when processing llog")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/43510
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Sergey Cheremencev <sergey.cheremencev@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lib.c        |  3 ++-
 fs/lustre/obdclass/lustre_peer.c | 18 +++++++++++++++++-
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index c5ee2c3..90bad71 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -173,9 +173,10 @@ int client_import_add_nids_to_conn(struct obd_import *imp, lnet_nid_t *nids,
 	list_for_each_entry(conn, &imp->imp_conn_list, oic_item) {
 		if (class_check_uuid(&conn->oic_uuid, nids[0])) {
 			*uuid = conn->oic_uuid;
+			spin_unlock(&imp->imp_lock);
 			rc = class_add_nids_to_uuid(&conn->oic_uuid, nids,
 						    nid_count);
-			break;
+			return rc;
 		}
 	}
 	spin_unlock(&imp->imp_lock);
diff --git a/fs/lustre/obdclass/lustre_peer.c b/fs/lustre/obdclass/lustre_peer.c
index c0a0bfb..f7e6a0f 100644
--- a/fs/lustre/obdclass/lustre_peer.c
+++ b/fs/lustre/obdclass/lustre_peer.c
@@ -81,6 +81,7 @@ int class_add_uuid(const char *uuid, u64 nid)
 {
 	struct uuid_nid_data *data, *entry;
 	int found = 0;
+	int rc;
 
 	LASSERT(nid != 0);  /* valid newconfig NID is never zero */
 
@@ -119,9 +120,15 @@ int class_add_uuid(const char *uuid, u64 nid)
 	if (found) {
 		CDEBUG(D_INFO, "found uuid %s %s cnt=%d\n", uuid,
 		       libcfs_nid2str(nid), entry->un_nid_count);
+		rc = LNetAddPeer(entry->un_nids, entry->un_nid_count);
+		CDEBUG(D_INFO, "Add peer %s rc = %d\n",
+		       libcfs_nid2str(data->un_nids[0]), rc);
 		kfree(data);
 	} else {
 		CDEBUG(D_INFO, "add uuid %s %s\n", uuid, libcfs_nid2str(nid));
+		rc = LNetAddPeer(data->un_nids, data->un_nid_count);
+		CDEBUG(D_INFO, "Add peer %s rc = %d\n",
+		       libcfs_nid2str(data->un_nids[0]), rc);
 	}
 	return 0;
 }
@@ -173,7 +180,8 @@ int class_add_nids_to_uuid(struct obd_uuid *uuid, lnet_nid_t *nids,
 			   int nid_count)
 {
 	struct uuid_nid_data *entry;
-	int i;
+	int i, rc;
+	bool matched = false;
 
 	if (nid_count >= MTI_NIDS_MAX) {
 		CDEBUG(D_NET, "too many NIDs (%d) for UUID '%s'\n",
@@ -188,6 +196,8 @@ int class_add_nids_to_uuid(struct obd_uuid *uuid, lnet_nid_t *nids,
 
 		if (!obd_uuid_equals(&entry->un_uuid, uuid))
 			continue;
+
+		matched = true;
 		CDEBUG(D_NET, "Updating UUID '%s'\n", obd_uuid2str(uuid));
 		for (i = 0; i < nid_count; i++)
 			entry->un_nids[i] = nids[i];
@@ -195,6 +205,12 @@ int class_add_nids_to_uuid(struct obd_uuid *uuid, lnet_nid_t *nids,
 		break;
 	}
 	spin_unlock(&g_uuid_lock);
+	if (matched) {
+		rc = LNetAddPeer(entry->un_nids, entry->un_nid_count);
+		CDEBUG(D_INFO, "Add peer %s rc = %d\n",
+		       libcfs_nid2str(entry->un_nids[0]), rc);
+	}
+
 	return 0;
 }
 EXPORT_SYMBOL(class_add_nids_to_uuid);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
