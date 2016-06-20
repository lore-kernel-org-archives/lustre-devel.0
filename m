From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:24 -0400
Subject: [lustre-devel] [PATCH 09/28] staging/lustre/ptlrpc: Early Reply vs
	Reply MDunlink
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-10-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Vitaly Fertman <vitaly.fertman@seagate.com>, Oleg Drokin <green@linuxhacker.ru>

From: Vitaly Fertman <vitaly.fertman@seagate.com>

A race between unregister_reply & early reply.
When buffers are busy for the early transfer, they cannon be unlinked
by unregister_reply, so the RPC gets into UNREGISTERING state. The
coming reply_in_callback for the early RPC already has unlinked flag
set due to previous mdunlink attempt, but we handle it properly only
for UNILNK event, whereas this is PUT in this case.

Signed-off-by: Vitaly Fertman <vitaly.fertman@seagate.com>
Seagate-bug-id: MRP-3323
Reviewed-by: Alexey Leonidovich Lyashkov <alexey.lyashkov@seagate.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@seagate.com>
Tested-by: Parinay Vijayprakash Kondekar <parinay.kondekar@seagate.com>
Reviewed-on: http://review.whamcloud.com/18934
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7434
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ptlrpc/events.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index a243342..b1ce725 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -137,7 +137,8 @@ void reply_in_callback(lnet_event_t *ev)
 
 		req->rq_early_count++; /* number received, client side */
 
-		if (req->rq_replied)   /* already got the real reply */
+		/* already got the real reply or buffers are already unlinked */
+		if (req->rq_replied || req->rq_reply_unlinked == 1)
 			goto out_wake;
 
 		req->rq_early = 1;
-- 
2.7.4
