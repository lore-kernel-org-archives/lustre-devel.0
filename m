From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:44 -0500
Subject: [lustre-devel] [PATCH 236/622] lustre: osc: pass client page size
 during reconnect too
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-237-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Client page size is reported to the server in ocd_grant_blkbits
and server returns back device blocksize. During reconnect that
ocd_grant_blkbits contains server device blocksize which is used
by server as client page size wrongly.

Patch sets ocd_grant_blkbits to the client page size again during
reconnect so server will get expected information.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11752
Lustre-commit: 5bec8f95cc10 ("LU-11752 osc: pass client page size during reconnect too")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33847
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index dca141f..a7e4f7a 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -3003,10 +3003,13 @@ int osc_reconnect(const struct lu_env *env, struct obd_export *exp,
 
 		spin_lock(&cli->cl_loi_list_lock);
 		grant = cli->cl_avail_grant + cli->cl_reserved_grant;
-		if (data->ocd_connect_flags & OBD_CONNECT_GRANT_PARAM)
+		if (data->ocd_connect_flags & OBD_CONNECT_GRANT_PARAM) {
+			/* restore ocd_grant_blkbits as client page bits */
+			data->ocd_grant_blkbits = PAGE_SHIFT;
 			grant += cli->cl_dirty_grant;
-		else
+		} else {
 			grant += cli->cl_dirty_pages << PAGE_SHIFT;
+		}
 		data->ocd_grant = grant ? : 2 * cli_brw_size(obd);
 		lost_grant = cli->cl_lost_grant;
 		cli->cl_lost_grant = 0;
-- 
1.8.3.1
