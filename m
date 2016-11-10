From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:48 -0500
Subject: [lustre-devel] [PATCH 18/35] staging: lustre: osc: fix max_dirty_mb
	tunable setting limit
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Gregoire Pichon <gregoire.pichon@bull.net>, James Simmons <jsimmons@infradead.org>

From: Gregoire Pichon <gregoire.pichon@bull.net>

The OSC tunable max_dirty_mb must be set to a value strictly lower
than 2048, as it is assumed by OSS in ofd_grant_alloc() routine.

Signed-off-by: Gregoire Pichon <gregoire.pichon@bull.net>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7218
Reviewed-on: http://review.whamcloud.com/16652
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/lproc_osc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 4421cfe..575b296 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -162,7 +162,7 @@ static ssize_t max_dirty_mb_store(struct kobject *kobj,
 	pages_number *= 1 << (20 - PAGE_SHIFT); /* MB -> pages */
 
 	if (pages_number <= 0 ||
-	    pages_number > OSC_MAX_DIRTY_MB_MAX << (20 - PAGE_SHIFT) ||
+	    pages_number >= OSC_MAX_DIRTY_MB_MAX << (20 - PAGE_SHIFT) ||
 	    pages_number > totalram_pages / 4) /* 1/4 of RAM */
 		return -ERANGE;
 
-- 
1.7.1
