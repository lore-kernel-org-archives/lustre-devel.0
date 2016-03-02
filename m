From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:45 -0500
Subject: [lustre-devel] [PATCH 02/27] staging: lustre: recv could access
	freed message
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

When lnet_parse_put calls lnet_ptl_match_md, this function can attach
current message on the delayed list if there is no match. It means
this message can be taken over and freed by another thread who is
posting new MD, then it is not safe for caller of lnet_parse_put to
check this message again.

This patch fixes this issue by adding a local variable "ready_delay"
to store corresponding status of lnet_msg, so lnet doesn't need to
check the message again if lnet_ptl_match_md returned MATCH_NONE for
it.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7324
Reviewed-on: http://review.whamcloud.com/17065
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/lib-move.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 7bc3e91..fa5b7cd 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1466,6 +1466,7 @@ lnet_parse_put(lnet_ni_t *ni, lnet_msg_t *msg)
 {
 	lnet_hdr_t *hdr = &msg->msg_hdr;
 	struct lnet_match_info info;
+	bool ready_delay;
 	int rc;
 
 	/* Convert put fields to host byte order */
@@ -1482,6 +1483,7 @@ lnet_parse_put(lnet_ni_t *ni, lnet_msg_t *msg)
 	info.mi_mbits	= hdr->msg.put.match_bits;
 
 	msg->msg_rx_ready_delay = !ni->ni_lnd->lnd_eager_recv;
+	ready_delay = msg->msg_rx_ready_delay;
 
  again:
 	rc = lnet_ptl_match_md(&info, msg);
@@ -1494,12 +1496,18 @@ lnet_parse_put(lnet_ni_t *ni, lnet_msg_t *msg)
 		return 0;
 
 	case LNET_MATCHMD_NONE:
-		if (msg->msg_rx_delayed) /* attached on delayed list */
+		/**
+		 * no eager_recv or has already called it, should
+		 * have been attached on delayed list
+		 */
+		if (ready_delay)
 			return 0;
 
 		rc = lnet_ni_eager_recv(ni, msg);
-		if (!rc)
+		if (!rc) {
+			ready_delay = true;
 			goto again;
+		}
 		/* fall through */
 
 	case LNET_MATCHMD_DROP:
-- 
1.7.1
