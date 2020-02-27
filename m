From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:50 -0500
Subject: [lustre-devel] [PATCH 242/622] lustre: grant: prevent overflow of
 o_undirty
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-243-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Zhuravlev <bzzz@whamcloud.com>

For the server side tgt_grant_inflate() returns a u64, and if
tgd_blockbits and val are large enough, can return a value >= 2^32.
tgt_grant_incoming() assigns oa->o_undirty the returned value.
Since o_undirty is u32, it can overflow.

This occurs with Lustre clients < 2.10 and a ZFS backend when the zfs
"recordsize" > 128k (the default).

In tgt_grant_inflate(), check the returned value and prevent o_undirty
from being assigned a value greater than 2^30.

For the osc client side use PTLRPC_MAX_RW_SIZE to prevent o_undirty
overflow.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11798
Lustre-commit: d6f521916211 ("LU-11798 grant: prevent overflow of o_undirty")
Signed-off-by: Alexey Zhuravlev <bzzz@whamcloud.com>
Signed-off-by: Olaf Faaland <faaland1@llnl.gov>
Reviewed-on: https://review.whamcloud.com/33948
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index a7e4f7a..1fc50cc 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -686,8 +686,8 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 		/* Do not ask for more than OBD_MAX_GRANT - a margin for server
 		 * to add extent tax, etc.
 		 */
-		oa->o_undirty = min(undirty, OBD_MAX_GRANT -
-				    (PTLRPC_MAX_BRW_PAGES << PAGE_SHIFT)*4UL);
+		oa->o_undirty = min(undirty, OBD_MAX_GRANT &
+				    ~(PTLRPC_MAX_BRW_SIZE * 4UL));
 	}
 	oa->o_grant = cli->cl_avail_grant + cli->cl_reserved_grant;
 	oa->o_dropped = cli->cl_lost_grant;
-- 
1.8.3.1
