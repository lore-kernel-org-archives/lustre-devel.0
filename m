Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5CF86C77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:41:35 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWTL5YqMz22Xq;
	Sun,  9 Apr 2023 05:22:46 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWRF0NJ9z22Ts
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:20:57 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 5C3E2100848F;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5AECB2B2; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:13 -0400
Message-Id: <1681042400-15491-34-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 33/40] lustre: ldlm: remove
 client_import_find_conn()
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

This function hasn't been used since
Commit 3dd3fe462023 ("lustre: mgc: Use IR for client->MDS/OST connections").
So remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10360
Lustre-commit: 14544bdca5cc42a3e ("LU-10360 ldlm: remove client_import_find_conn()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50000
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: jsimmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h |  2 --
 fs/lustre/ldlm/ldlm_lib.c      | 24 ------------------------
 2 files changed, 26 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 1ffe9f7..a305ba3 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -2358,8 +2358,6 @@ int client_import_dyn_add_conn(struct obd_import *imp, struct obd_uuid *uuid,
 int client_import_add_nids_to_conn(struct obd_import *imp, lnet_nid_t *nids,
 				   int nid_count, struct obd_uuid *uuid);
 int client_import_del_conn(struct obd_import *imp, struct obd_uuid *uuid);
-int client_import_find_conn(struct obd_import *imp, lnet_nid_t peer,
-			    struct obd_uuid *uuid);
 int import_set_conn_priority(struct obd_import *imp, struct obd_uuid *uuid);
 void client_destroy_import(struct obd_import *imp);
 /** @} */
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 0b8389e..b1ce0d4 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -243,30 +243,6 @@ int client_import_del_conn(struct obd_import *imp, struct obd_uuid *uuid)
 }
 EXPORT_SYMBOL(client_import_del_conn);
 
-/**
- * Find conn UUID by peer NID. @peer is a server NID. This function is used
- * to find a conn uuid of @imp which can reach @peer.
- */
-int client_import_find_conn(struct obd_import *imp, lnet_nid_t peer,
-			    struct obd_uuid *uuid)
-{
-	struct obd_import_conn *conn;
-	int rc = -ENOENT;
-
-	spin_lock(&imp->imp_lock);
-	list_for_each_entry(conn, &imp->imp_conn_list, oic_item) {
-		/* Check if conn UUID does have this peer NID. */
-		if (class_check_uuid(&conn->oic_uuid, peer)) {
-			*uuid = conn->oic_uuid;
-			rc = 0;
-			break;
-		}
-	}
-	spin_unlock(&imp->imp_lock);
-	return rc;
-}
-EXPORT_SYMBOL(client_import_find_conn);
-
 void client_destroy_import(struct obd_import *imp)
 {
 	/*
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
