From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:09 -0500
Subject: [lustre-devel] [PATCH 02/22] staging: lustre: osc: fix debug log
	message formatting
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Ashish Purkar <ashish.purkar@seagate.com>, James Simmons <jsimmons@infradead.org>

From: Ashish Purkar <ashish.purkar@seagate.com>

Corrected newline specifier in debug log message.

Signed-off-by: Ashish Purkar <ashish.purkar@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7029
Reviewed-on: http://review.whamcloud.com/16046
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_page.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index a80a847..c5129d1 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -462,7 +462,7 @@ static void osc_lru_del(struct client_obd *cli, struct osc_page *opg)
 		 * stealing one of them.
 		 */
 		if (osc_cache_too_much(cli)) {
-			CDEBUG(D_CACHE, "%s: queue LRU workn", cli_name(cli));
+			CDEBUG(D_CACHE, "%s: queue LRU work\n", cli_name(cli));
 			(void)ptlrpcd_queue_work(cli->cl_lru_work);
 		}
 		wake_up(&osc_lru_waitq);
-- 
1.7.1
