From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:42 -0500
Subject: [lustre-devel] [PATCH 234/622] lustre: osc: grant shrink shouldn't
 account skipped OSC
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-235-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alex Zhuravlev <bzzz@whamcloud.com>

otherwise only the first 100 OSCs are subject to grant shrink procedure.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11409
Lustre-commit: 2b215d3763a8 ("LU-11409 osc: grant shrink shouldn't account skipped OSC")
Signed-off-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33206
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 7b120da..14180a4 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -879,9 +879,11 @@ static void osc_grant_work_handler(struct work_struct *data)
 	mutex_lock(&client_gtd.gtd_mutex);
 	list_for_each_entry(cli, &client_gtd.gtd_clients,
 			    cl_grant_chain) {
-		if (++rpc_sent < GRANT_SHRINK_RPC_BATCH &&
-		    osc_should_shrink_grant(cli))
+		if (rpc_sent < GRANT_SHRINK_RPC_BATCH &&
+		    osc_should_shrink_grant(cli)) {
 			osc_shrink_grant(cli);
+			rpc_sent++;
+		}
 
 		if (!init_next_shrink) {
 			if (cli->cl_next_shrink_grant < next_shrink &&
-- 
1.8.3.1
