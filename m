From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:05 -0400
Subject: [lustre-devel] [PATCH 26/42] lustre: osc: don't allow negative
 grants
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Add check in the osc_init_grant() to prevent possible
underflow of cl_avail_grant and report error if it happens

WC-bug-id: https://jira.whamcloud.com/browse/LU-13763
Lustre-commit: e05ccafd6ee214 ("LU-13763 osc: don't allow negative grants")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39827
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Olaf Faaland-LLNL <faaland1@llnl.gov>
Reviewed-by: Vladimir Saveliev <c17830@cray.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index fbb8453..53f87ea 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1030,12 +1030,19 @@ void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 	cli->cl_avail_grant = ocd->ocd_grant;
 	spin_lock(&cli->cl_loi_list_lock);
 	if (cli->cl_import->imp_state != LUSTRE_IMP_EVICTED) {
-		cli->cl_avail_grant -= cli->cl_reserved_grant;
+		unsigned long consumed = cli->cl_reserved_grant;
+
 		if (OCD_HAS_FLAG(ocd, GRANT_PARAM))
-			cli->cl_avail_grant -= cli->cl_dirty_grant;
+			consumed += cli->cl_dirty_grant;
 		else
-			cli->cl_avail_grant -=
-				cli->cl_dirty_pages << PAGE_SHIFT;
+			consumed += cli->cl_dirty_pages << PAGE_SHIFT;
+		if (cli->cl_avail_grant < consumed) {
+			CERROR("%s: granted %ld but already consumed %ld\n",
+			       cli_name(cli), cli->cl_avail_grant, consumed);
+			cli->cl_avail_grant = 0;
+		} else {
+			cli->cl_avail_grant -= consumed;
+		}
 	}
 
 	if (OCD_HAS_FLAG(ocd, GRANT_PARAM)) {
-- 
1.8.3.1
