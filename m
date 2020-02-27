From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:26 -0500
Subject: [lustre-devel] [PATCH 218/622] lustre: osc: check if opg is in lru
 list without locking
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-219-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Dongyang <dongyangli@ddn.com>

osc_lru_use is called for every page queued for io,
we can just check if the osc_page is in the lru list
without taking the cl_lru_list_lock and return if not
as a fast path.
Note we still need to do the check again after locking
as it could be removed from the lru list by another thread.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11775
Lustre-commit: b3af0798682b ("LU-11775 osc: check if opg is in lru list without locking")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/33860
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_page.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/lustre/osc/osc_page.c b/fs/lustre/osc/osc_page.c
index 4dc6c18..7382e0d 100644
--- a/fs/lustre/osc/osc_page.c
+++ b/fs/lustre/osc/osc_page.c
@@ -494,6 +494,9 @@ static void osc_lru_use(struct client_obd *cli, struct osc_page *opg)
 	 * ops_lru should be empty
 	 */
 	if (opg->ops_in_lru) {
+		if (list_empty(&opg->ops_lru))
+			return;
+
 		spin_lock(&cli->cl_lru_list_lock);
 		if (!list_empty(&opg->ops_lru)) {
 			__osc_lru_del(cli, opg);
-- 
1.8.3.1
