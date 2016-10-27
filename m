From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:35 -0400
Subject: [lustre-devel] [PATCH 01/29] staging: lustre: osc: remove handling
	cl_avail_grant less than zero
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Earlier cl_avail_grant was changed to an unsigned int. Juila
Lawall reported for the upstream client the following which
affects the Intel branch as well:

drivers/staging/lustre/lustre/osc/osc_request.c:1045:5-24: WARNING: Unsigned
expression compared with zero: cli -> cl_avail_grant < 0

Since cl_avail_grant can never be negative we can remove the
code handling the negative value case.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: LU-8697 https://jira.hpdd.intel.com/browse/LU-6303
Reviewed-on: http://review.whamcloud.com/23155
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_request.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 038f00c..efd938a 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -801,16 +801,6 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 		cli->cl_avail_grant = ocd->ocd_grant -
 				      (cli->cl_dirty_pages << PAGE_SHIFT);
 
-	if (cli->cl_avail_grant < 0) {
-		CWARN("%s: available grant < 0: avail/ocd/dirty %ld/%u/%ld\n",
-		      cli->cl_import->imp_obd->obd_name, cli->cl_avail_grant,
-		      ocd->ocd_grant, cli->cl_dirty_pages << PAGE_SHIFT);
-		/* workaround for servers which do not have the patch from
-		 * LU-2679
-		 */
-		cli->cl_avail_grant = ocd->ocd_grant;
-	}
-
 	/* determine the appropriate chunk size used by osc_extent. */
 	cli->cl_chunkbits = max_t(int, PAGE_SHIFT, ocd->ocd_blocksize);
 	spin_unlock(&cli->cl_loi_list_lock);
-- 
1.7.1
