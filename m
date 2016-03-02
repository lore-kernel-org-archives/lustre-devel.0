From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:44 -0500
Subject: [lustre-devel] [PATCH 01/27] staging: lustre: set downis to 1 if
	there's no NI for remote net
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

lnet_route_t::lr_downis is marked as zero even if there is no NI to
target network, this is wrong and breaks logic of ARF. This patch
fixes this problem.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6060
Reviewed-on: http://review.whamcloud.com/13417
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/router.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 5e8b0ba..2eae8f6 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -718,6 +718,13 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 			rte->lr_downis = 0;
 			continue;
 		}
+		/**
+		 * if @down is zero and this route is single-hop, it means
+		 * we can't find NI for target network
+		 */
+		if (!down && rte->lr_hops == 1)
+			down = 1;
+
 		rte->lr_downis = down;
 	}
 }
-- 
1.7.1
