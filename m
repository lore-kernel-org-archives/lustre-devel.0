From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:43 -0500
Subject: [lustre-devel] [PATCH 05/19] staging: lustre: libcfs: fix aligment
	issue
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Make alignment match open parenthesis for
parameters to wait_event_interruptible_exclusive()
call.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/workitem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/workitem.c b/drivers/staging/lustre/lnet/libcfs/workitem.c
index e98c818..84118b5 100644
--- a/drivers/staging/lustre/lnet/libcfs/workitem.c
+++ b/drivers/staging/lustre/lnet/libcfs/workitem.c
@@ -273,7 +273,7 @@ static int cfs_wi_scheduler(void *arg)
 
 		spin_unlock(&sched->ws_lock);
 		rc = wait_event_interruptible_exclusive(sched->ws_waitq,
-						!cfs_wi_sched_cansleep(sched));
+							!cfs_wi_sched_cansleep(sched));
 		spin_lock(&sched->ws_lock);
 	}
 
-- 
1.7.1
