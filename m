Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FB37C0219D
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:38:05 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWws2CNfz1y8w;
	Fri, 07 Feb 2025 16:31:25 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWw943B3z1xp7
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:49 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 2C854899AC0;
 Fri,  7 Feb 2025 19:30:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 2A7D2106BE18; Fri,  7 Feb 2025 19:30:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:25 -0500
Message-ID: <20250208003027.180076-20-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 19/21] lustre: misc: fix clang build errors
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

From: Timothy Day <timday@amazon.com>

Fix several format security errors by explicitly giving
the format to the affected functions.

Explicitly cast ll_nfs_get_name_filldir as a filldir_t
and NR_WRITEBACK as a zone_stat_item. This silences
some implicit cast errors. These casts can likely be
removed when older kernel support is dropped.

Refactor some code to avoid strncat, which was being
used incorrectly anyway.

Adjust some variables to use more appropriate types.

Inline some functions which are only sometimes used.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16510
Lustre-commit: 03ddd706d99b09790 ("LU-16518 misc: fix clang build errors")
Signed-off-by: Timothy Day <timday@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50332
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_nfs.c | 2 +-
 fs/lustre/mgc/mgc_request.c | 3 +--
 fs/lustre/obdclass/genops.c | 8 +++++---
 fs/lustre/osc/osc_lock.c    | 2 +-
 fs/lustre/osc/osc_page.c    | 6 ++++--
 5 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/llite/llite_nfs.c b/fs/lustre/llite/llite_nfs.c
index 232b2b311151..d505c206a62e 100644
--- a/fs/lustre/llite/llite_nfs.c
+++ b/fs/lustre/llite/llite_nfs.c
@@ -197,7 +197,7 @@ static int ll_get_name(struct dentry *dentry, char *name,
 	struct ll_getname_data lgd = {
 		.lgd_name = name,
 		.lgd_fid = ll_i2info(d_inode(child))->lli_fid,
-		.ctx.actor = ll_nfs_get_name_filldir,
+		.ctx.actor = (filldir_t)ll_nfs_get_name_filldir,
 	};
 	struct md_op_data *op_data;
 	u64 pos = 0;
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 56fb50aedbd9..c8ce8d4c1738 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -255,9 +255,8 @@ config_recover_log_add(struct obd_device *obd, char *fsname,
 	 * where only clients are notified if one of cmd server restarts
 	 */
 	LASSERT(strlen(fsname) < sizeof(logname) / 2);
-	strcpy(logname, fsname);
 	LASSERT(lcfg.cfg_instance);
-	strcat(logname, "-cliir");
+	scnprintf(logname, sizeof(logname), "%s-cliir", fsname);
 
 	cld = do_config_log_add(obd, logname, MGS_CFG_T_RECOVER, &lcfg, sb);
 	return cld;
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 43772aac3776..a3f7b59db47f 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -1277,6 +1277,7 @@ int obd_get_request_slot(struct client_obd *cli)
 			else
 				list_del(&orsw.orsw_entry);
 		}
+		rc = -EINTR;
 	}
 
 	if (orsw.orsw_signaled) {
@@ -1328,7 +1329,7 @@ int obd_set_max_rpcs_in_flight(struct client_obd *cli, u32 max)
 	if (max > OBD_MAX_RIF_MAX || max < 1)
 		return -ERANGE;
 
-	CDEBUG(D_INFO, "%s: max = %hu max_mod = %u rif = %u\n",
+	CDEBUG(D_INFO, "%s: max = %u max_mod = %u rif = %u\n",
 	       cli->cl_import->imp_obd->obd_name, max,
 	       cli->cl_max_mod_rpcs_in_flight, cli->cl_max_rpcs_in_flight);
 
@@ -1384,6 +1385,7 @@ int obd_set_max_mod_rpcs_in_flight(struct client_obd *cli, u16 max)
 	if (max > OBD_MAX_RIF_MAX || max < 1)
 		return -ERANGE;
 
+	ocd = &cli->cl_import->imp_connect_data;
 	CDEBUG(D_INFO, "%s: max = %hu flags = %llx, max_mod = %u rif = %u\n",
 	       cli->cl_import->imp_obd->obd_name, max, ocd->ocd_connect_flags,
 	       ocd->ocd_maxmodrpcs, cli->cl_max_rpcs_in_flight);
@@ -1396,9 +1398,9 @@ int obd_set_max_mod_rpcs_in_flight(struct client_obd *cli, u16 max)
 	 */
 	if (max >= cli->cl_max_rpcs_in_flight) {
 		CDEBUG(D_INFO,
-		       "%s: increasing max_rpcs_in_flight=%hu to allow larger max_mod_rpcs_in_flight=%u\n",
+		       "%s: increasing max_rpcs_in_flight=%u to allow larger max_mod_rpcs_in_flight=%u\n",
 		       cli->cl_import->imp_obd->obd_name, max + 1, max);
-		return -ERANGE;
+		obd_set_max_rpcs_in_flight(cli, max + 1);
 	}
 
 	/* cannot exceed max modify RPCs in flight supported by the server,
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index 3eac1d44fb2d..c7ae1ab3e3d3 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -65,7 +65,7 @@ static struct ldlm_lock *osc_handle_ptr(struct lustre_handle *handle)
 /**
  * Invariant that has to be true all of the time.
  */
-static int osc_lock_invariant(struct osc_lock *ols)
+static inline int osc_lock_invariant(struct osc_lock *ols)
 {
 	struct ldlm_lock *lock = osc_handle_ptr(&ols->ols_handle);
 	struct ldlm_lock *olock = ols->ols_dlmlock;
diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index c428c3626676..38903eb53a92 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -912,7 +912,8 @@ static inline void unstable_page_accounting(struct ptlrpc_bulk_desc *desc,
 		}
 
 		if (count > 0) {
-			mod_node_page_state(pgdat, NR_WRITEBACK,
+			mod_node_page_state(pgdat,
+					    (enum zone_stat_item)NR_WRITEBACK,
 					    factor * count);
 			count = 0;
 		}
@@ -920,7 +921,8 @@ static inline void unstable_page_accounting(struct ptlrpc_bulk_desc *desc,
 		++count;
 	}
 	if (count > 0)
-		mod_node_page_state(last, NR_WRITEBACK, factor * count);
+		mod_node_page_state(last, (enum zone_stat_item)NR_WRITEBACK,
+				    factor * count);
 }
 
 static inline void add_unstable_page_accounting(struct ptlrpc_bulk_desc *desc,
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
