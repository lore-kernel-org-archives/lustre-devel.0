From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:31:01 -0500
Subject: [lustre-devel] [PATCH 31/35] staging: lustre: obdclass: add export
	for lprocfs_stats_alloc_one()
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-32-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Chennaiah Palla <chennaiah.palla@seagate.com>, James Simmons <jsimmons@infradead.org>

From: Chennaiah Palla <chennaiah.palla@seagate.com>

When compiling the kernel without optimization, when using GCOV,
the lprocfs_stats_alloc_one() symbol is not properly exported to
other modules and causes the ptlrpc module to fail loading with
an unknown symbol. Added EXPORT_SYMBOL(lprocfs_stats_alloc_one)
so that this works properly.

Signed-off-by: Chennaiah Palla <chennaiah.palla@seagate.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7515
Seagate-bug-id: MRP-3188
Reviewed-on: http://review.whamcloud.com/17443
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/obdclass/lprocfs_status.c        |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 8a2f02f..cccc749 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1052,6 +1052,7 @@ int lprocfs_stats_alloc_one(struct lprocfs_stats *stats, unsigned int cpuid)
 	}
 	return rc;
 }
+EXPORT_SYMBOL(lprocfs_stats_alloc_one);
 
 struct lprocfs_stats *lprocfs_alloc_stats(unsigned int num,
 					  enum lprocfs_stats_flags flags)
-- 
1.7.1
