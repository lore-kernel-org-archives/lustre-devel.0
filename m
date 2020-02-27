From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:11 -0500
Subject: [lustre-devel] [PATCH 023/622] lustre: osc: Do not request more
 than 2GiB grant
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Patrick Farrell <pfarrell@whamcloud.com>

The server enforces a grant limit of 2 GiB, which the
client must honor.  The existing client code combined with
16 MiB RPCs make it possible for the client to ask for
more than this limit.

Make this limit explicit, and also fix an overflow bug in
o_undirty calculation in osc_announce_cached.  (o_undirty
is a 32 bit value and 16 MiB*256 rpcs_in_flight = 4 GiB.
4 GiB + extra grant components overflows o_undirty.)

Cray-bug-id: LUS-5750
WC-bug-id: https://jira.whamcloud.com/browse/LU-10776
Lustre-commit: c0246d887809 ("LU-10776 osc: Do not request more than 2GiB grant")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31533
Reviewed-by: Nathaniel Clark <nclark@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c            | 10 ++++++++--
 include/uapi/linux/lustre/lustre_idl.h |  2 ++
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 99c9620..c430239 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -664,11 +664,12 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 		oa->o_undirty = 0;
 	} else {
 		unsigned long nrpages;
+		unsigned long undirty;
 
 		nrpages = cli->cl_max_pages_per_rpc;
 		nrpages *= cli->cl_max_rpcs_in_flight + 1;
 		nrpages = max(nrpages, cli->cl_dirty_max_pages);
-		oa->o_undirty = nrpages << PAGE_SHIFT;
+		undirty = nrpages << PAGE_SHIFT;
 		if (OCD_HAS_FLAG(&cli->cl_import->imp_connect_data,
 				 GRANT_PARAM)) {
 			int nrextents;
@@ -679,8 +680,13 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 			 */
 			nrextents = DIV_ROUND_UP(nrpages,
 						 cli->cl_max_extent_pages);
-			oa->o_undirty += nrextents * cli->cl_grant_extent_tax;
+			undirty += nrextents * cli->cl_grant_extent_tax;
 		}
+		/* Do not ask for more than OBD_MAX_GRANT - a margin for server
+		 * to add extent tax, etc.
+		 */
+		oa->o_undirty = min(undirty, OBD_MAX_GRANT -
+				    (PTLRPC_MAX_BRW_PAGES << PAGE_SHIFT)*4UL);
 	}
 	oa->o_grant = cli->cl_avail_grant + cli->cl_reserved_grant;
 	oa->o_dropped = cli->cl_lost_grant;
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 307feb3..0bce63d 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1213,6 +1213,8 @@ struct hsm_state_set {
 				      * it to sync quickly
 				      */
 
+#define OBD_MAX_GRANT 0x7fffffffUL /* Max grant allowed to one client: 2 GiB */
+
 #define OBD_OBJECT_EOF	LUSTRE_EOF
 
 #define OST_MIN_PRECREATE 32
-- 
1.8.3.1
