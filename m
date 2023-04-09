Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 54613C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:37:50 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWQC34qPz22SS;
	Sun,  9 Apr 2023 05:20:03 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWMK2dxlz21KC
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:17:33 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 3A4A41008488;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 390FF2AB; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:06 -0400
Message-Id: <1681042400-15491-27-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 26/40] lustre: client: -o network needs
 add_conn processing
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
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mikhail Pershin <mpershin@whamcloud.com>

Mount option -o network restricts client import to use
only selected network. It processes connection UUID/NIDs
during 'setup' config command handling but skips any
'add_conn' command if its UUID has no mention about that
network. Meahwhile connection UUID is just a name and may
have many NIDs configured including those on restricted
network which are skipped as well. Therefore client import
configuration misses failover NIDs on restricted network.

Patch makes import to save restricted network information
after 'setup' command processing, so it is applied to any
client_import_add_conn() call. The 'add_conn' command is
always processed now and its NIDs will be filtered in the
same way as for 'setup'.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16557
Lustre-commit: c508c9426838f1625 ("LU-16557 client: -o network needs add_conn processing")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49986
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h |  1 +
 fs/lustre/ldlm/ldlm_lib.c         | 20 +++++++++-----------
 fs/lustre/obdclass/obd_config.c   | 17 -----------------
 3 files changed, 10 insertions(+), 28 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index 3ae05b5..ac46aae 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -340,6 +340,7 @@ struct obd_import {
 
 	struct imp_at			imp_at;	/* adaptive timeout data */
 	time64_t			imp_last_reply_time; /* for health check */
+	u32				imp_conn_restricted_net;
 };
 
 /* import.c : adaptive timeout handling.
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index ddedaad..0b8389e 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -56,7 +56,7 @@ static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
 {
 	struct ptlrpc_connection *ptlrpc_conn;
 	struct obd_import_conn *imp_conn = NULL, *item;
-	u32 refnet = LNET_NET_ANY;
+	u32 refnet = imp->imp_conn_restricted_net;
 	int rc = 0;
 
 	if (!create && !priority) {
@@ -64,10 +64,11 @@ static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
 		return -EINVAL;
 	}
 
-	if (imp->imp_connection &&
-	    imp->imp_connection->c_remote_uuid.uuid[0] == 0)
-		/* refnet is used to restrict network connections */
-		refnet = LNET_NID_NET(&imp->imp_connection->c_self);
+	/* refnet is used to restrict network connections */
+	if (refnet != LNET_NET_ANY)
+		CDEBUG(D_HA, "imp %s: restrict %s to %s net\n",
+		       imp->imp_obd->obd_name, uuid->uuid,
+		       libcfs_net2str(refnet));
 
 	ptlrpc_conn = ptlrpc_uuid_to_connection(uuid, refnet);
 	if (!ptlrpc_conn) {
@@ -296,10 +297,6 @@ int client_obd_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	int rq_portal, rp_portal, connect_op;
 	const char *name = obd->obd_type->typ_name;
 	enum ldlm_ns_type ns_type = LDLM_NS_TYPE_UNKNOWN;
-	struct ptlrpc_connection fake_conn = {
-		.c_self = {},
-		.c_remote_uuid.uuid[0] = 0
-	};
 	int rc;
 
 	/*
@@ -494,8 +491,9 @@ int client_obd_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 			       rc);
 			goto err_import;
 		}
-		lnet_nid4_to_nid(LNET_MKNID(refnet, 0), &fake_conn.c_self);
-		imp->imp_connection = &fake_conn;
+		imp->imp_conn_restricted_net = refnet;
+	} else {
+		imp->imp_conn_restricted_net = LNET_NET_ANY;
 	}
 
 	rc = client_import_add_conn(imp, &server_uuid, 1);
diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 953f544..f2173df 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -1331,23 +1331,6 @@ int class_config_llog_handler(const struct lu_env *env,
 			}
 		}
 
-		/* Skip add_conn command if uuid is not on restricted net */
-		if (clli && clli->cfg_sb && s2lsi(clli->cfg_sb)) {
-			struct lustre_sb_info *lsi = s2lsi(clli->cfg_sb);
-			char *uuid_str = lustre_cfg_string(lcfg, 1);
-
-			if (lcfg->lcfg_command == LCFG_ADD_CONN &&
-			    lsi->lsi_lmd->lmd_nidnet &&
-			    LNET_NIDNET(libcfs_str2nid(uuid_str)) !=
-			    libcfs_str2net(lsi->lsi_lmd->lmd_nidnet)) {
-				CDEBUG(D_CONFIG, "skipping add_conn for %s\n",
-				       uuid_str);
-				rc = 0;
-				/* No processing! */
-				break;
-			}
-		}
-
 		lcfg_len = lustre_cfg_len(bufs.lcfg_bufcount, bufs.lcfg_buflen);
 		lcfg_new = kzalloc(lcfg_len, GFP_NOFS);
 		if (!lcfg_new) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
