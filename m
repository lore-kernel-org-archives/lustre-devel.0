From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:56 -0500
Subject: [lustre-devel] [PATCH 13/27] staging: lustre: fix api-ni.c issues
	found by Klocwork Insight tool
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Pointer 'ni' checked for NULL at line 1569 may be passed to
function and may be dereferenced there by passing argument 1 to
function 'lnet_ni_notify_locked' at line 1621.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4629
Reviewed-on: http://review.whamcloud.com/9386
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/router.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 9543ba3..6a44601 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1800,7 +1800,8 @@ lnet_notify(lnet_ni_t *ni, lnet_nid_t nid, int alive, unsigned long when)
 
 	lnet_notify_locked(lp, !ni, alive, when);
 
-	lnet_ni_notify_locked(ni, lp);
+	if (ni)
+		lnet_ni_notify_locked(ni, lp);
 
 	lnet_peer_decref_locked(lp);
 
-- 
1.7.1
