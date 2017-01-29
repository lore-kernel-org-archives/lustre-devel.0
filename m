From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:26 -0500
Subject: [lustre-devel] [PATCH 58/60] staging: lustre: osc: avoid 64 divide
	in osc_cache_too_much
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-59-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The use of 64 bit time introduces an expensive 64 bit
division operation. Since the time lapse being calculated
in osc_cache_too_much will never be more than seventy years
we can cast the time lapse to an long and perform a normal
32 bit divison operation instead.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8835
Reviewed-on: https://review.whamcloud.com/23814
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_page.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 0461408..ab9d0d7 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -370,12 +370,17 @@ static int osc_cache_too_much(struct client_obd *cli)
 			return lru_shrink_min(cli);
 	} else {
 		time64_t duration = ktime_get_real_seconds();
+		long timediff;
 
 		/* knock out pages by duration of no IO activity */
 		duration -= cli->cl_lru_last_used;
-		duration >>= 6; /* approximately 1 minute */
-		if (duration > 0 &&
-		    pages >= div64_s64((s64)budget, duration))
+		/*
+		 * The difference shouldn't be more than 70 years
+		 * so we can safely case to a long. Round to
+		 * approximately 1 minute.
+		 */
+		timediff = (long)(duration >> 6);
+		if (timediff > 0 && pages >= budget / timediff)
 			return lru_shrink_min(cli);
 	}
 	return 0;
-- 
1.8.3.1
