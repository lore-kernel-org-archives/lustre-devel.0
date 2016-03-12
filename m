From: James Simmons <jsimmons@infradead.org>
Date: Fri, 11 Mar 2016 20:29:42 -0500
Subject: [lustre-devel] [PATCH 01/10] staging: lustre: fix bogus lst errors
	for lnet selftest
In-Reply-To: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
References: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457746191-27981-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Isaac Huang <he.huang@intel.com>

From: Isaac Huang <he.huang@intel.com>

It should not be counted as errors if a test RPC
has been stopped due to administrative actions,
e.g. lst end_session from the remote test console.

Signed-off-by: Isaac Huang <he.huang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4181
Reviewed-on: http://review.whamcloud.com/13279
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/selftest/rpc.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 5eb4232..60d38df 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -1427,9 +1427,16 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 	LASSERT(!in_interrupt());
 
 	if (ev->status) {
+		__u32 errors;
+
 		spin_lock(&srpc_data.rpc_glock);
-		srpc_data.rpc_counters.errors++;
+		if (ev->status != -ECANCELED) /* cancellation is not error */
+			srpc_data.rpc_counters.errors++;
+		errors = srpc_data.rpc_counters.errors;
 		spin_unlock(&srpc_data.rpc_glock);
+
+		CNETERR("LNet event status %d type %d, RPC errors %u\n",
+			ev->status, ev->type, errors);
 	}
 
 	rpcev->ev_lnet = ev->type;
-- 
1.7.1
