From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:15 -0400
Subject: [lustre-devel] [PATCH 19/20] lustre: mdc: allow setting
 max_mod_rpcs_in_flight larger
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Allow setting mdc.*.max_mod_rpcs_in_flight > mdc.*.max_rpcs_in_flight
by increasing the latter value, rather than returning an error and
telling the user to do that.  This matches the similar behavior if
mdc.*.max_rpcs_in_flight is reduced lower than max_mod_rpcs_in_flight.

If there are multiple MDTs, the "mdc.*.max_mod_rpcs_in_flight" param
may be set from e.g. the MDT0000 config log before MDT0001 is fully
configured, catching MDT0001 with ocd_maxmodrpcs = 0 before the OCD
from the MDT has been filled in, and incorrectly trigger an error.
If seen during setup, allow ocd_maxmodrpcs = (max_rpcs_in_flight - 1),
since this will be fixed up later if mdc.*.max_rpcs_in_flight is set
smaller in the config log (if set larger it doesn't matter).

WC-bug-id: https://jira.whamcloud.com/browse/LU-13503
Lustre-commit: 6d314902e6d19 ("LU-13503 mdc: allow setting max_mod_rpcs_in_flight larger")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: Jian Yu <yujian@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38455
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/genops.c | 50 +++++++++++++++++++++++++++++++++------------
 1 file changed, 37 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 607f0d6..1647fe9 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -1324,7 +1324,6 @@ u32 obd_get_max_rpcs_in_flight(struct client_obd *cli)
 int obd_set_max_rpcs_in_flight(struct client_obd *cli, u32 max)
 {
 	struct obd_request_slot_waiter *orsw;
-	const char *type_name;
 	u32 old;
 	int diff;
 	int rc;
@@ -1333,14 +1332,18 @@ int obd_set_max_rpcs_in_flight(struct client_obd *cli, u32 max)
 	if (max > OBD_MAX_RIF_MAX || max < 1)
 		return -ERANGE;
 
-	type_name = cli->cl_import->imp_obd->obd_type->typ_name;
-	if (!strcmp(type_name, LUSTRE_MDC_NAME)) {
+	CDEBUG(D_INFO, "%s: max = %hu max_mod = %u rif = %u\n",
+	       cli->cl_import->imp_obd->obd_name, max,
+	       cli->cl_max_mod_rpcs_in_flight, cli->cl_max_rpcs_in_flight);
+
+	if (strcmp(cli->cl_import->imp_obd->obd_type->typ_name,
+		   LUSTRE_MDC_NAME) == 0) {
 		/*
 		 * adjust max_mod_rpcs_in_flight to ensure it is always
 		 * strictly lower that max_rpcs_in_flight
 		 */
 		if (max < 2) {
-			CERROR("%s: cannot set max_rpcs_in_flight to 1 because it must be higher than max_mod_rpcs_in_flight value\n",
+			CERROR("%s: cannot set mdc.*.max_rpcs_in_flight=1\n",
 			       cli->cl_import->imp_obd->obd_name);
 			return -ERANGE;
 		}
@@ -1385,22 +1388,43 @@ int obd_set_max_mod_rpcs_in_flight(struct client_obd *cli, u16 max)
 	if (max > OBD_MAX_RIF_MAX || max < 1)
 		return -ERANGE;
 
-	/* cannot exceed or equal max_rpcs_in_flight */
+	CDEBUG(D_INFO, "%s: max = %hu flags = %llx, max_mod = %u rif = %u\n",
+	       cli->cl_import->imp_obd->obd_name, max, ocd->ocd_connect_flags,
+	       ocd->ocd_maxmodrpcs, cli->cl_max_rpcs_in_flight);
+
+	if (max == OBD_MAX_RIF_MAX)
+		max = OBD_MAX_RIF_MAX - 1;
+
+	/* Cannot exceed or equal max_rpcs_in_flight.  If we are asked to
+	 * increase this value, also bump up max_rpcs_in_flight to match.
+	 */
 	if (max >= cli->cl_max_rpcs_in_flight) {
-		CERROR("%s: can't set max_mod_rpcs_in_flight to a value (%hu) higher or equal to max_rpcs_in_flight value (%u)\n",
-		       cli->cl_import->imp_obd->obd_name,
-		       max, cli->cl_max_rpcs_in_flight);
+		CDEBUG(D_INFO,
+		       "%s: increasing max_rpcs_in_flight=%hu to allow larger max_mod_rpcs_in_flight=%u\n",
+		       cli->cl_import->imp_obd->obd_name, max + 1, max);
 		return -ERANGE;
 	}
 
-	/* cannot exceed max modify RPCs in flight supported by the server */
-	ocd = &cli->cl_import->imp_connect_data;
-	if (ocd->ocd_connect_flags & OBD_CONNECT_MULTIMODRPCS)
+	/* cannot exceed max modify RPCs in flight supported by the server,
+	 * but verify ocd_connect_flags is at least initialized first.  If
+	 * not, allow it and fix value later in ptlrpc_connect_set_flags().
+	 */
+	if (!ocd->ocd_connect_flags) {
+		maxmodrpcs = cli->cl_max_rpcs_in_flight - 1;
+	} else if (ocd->ocd_connect_flags & OBD_CONNECT_MULTIMODRPCS) {
 		maxmodrpcs = ocd->ocd_maxmodrpcs;
-	else
+		if (maxmodrpcs == 0) { /* connection not finished yet */
+			maxmodrpcs = cli->cl_max_rpcs_in_flight - 1;
+			CDEBUG(D_INFO,
+			       "%s: partial connect, assume maxmodrpcs=%hu\n",
+			       cli->cl_import->imp_obd->obd_name, maxmodrpcs);
+		}
+	} else {
 		maxmodrpcs = 1;
+	}
+
 	if (max > maxmodrpcs) {
-		CERROR("%s: can't set max_mod_rpcs_in_flight to a value (%hu) higher than max_mod_rpcs_per_client value (%hu) returned by the server at connection\n",
+		CERROR("%s: can't set max_mod_rpcs_in_flight=%hu higher than ocd_maxmodrpcs=%hu returned by the server at connection\n",
 		       cli->cl_import->imp_obd->obd_name,
 		       max, maxmodrpcs);
 		return -ERANGE;
-- 
1.8.3.1
