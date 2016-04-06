From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:27 -0400
Subject: [lustre-devel] [PATCH 01/24] staging: lustre: selftest: convert
	srpc_event_type to proper enum
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn tyepdef srpc_event_type to proper enum

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/selftest.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index f50580e..00d73a1 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -134,7 +134,7 @@ srpc_service2reply(int service)
 	return srpc_service2request(service) + 1;
 }
 
-typedef enum {
+enum srpc_event_type {
 	SRPC_BULK_REQ_RCVD   = 1, /* passive bulk request(PUT sink/GET source)
 				   * received */
 	SRPC_BULK_PUT_SENT   = 2, /* active bulk PUT sent (source) */
@@ -143,11 +143,11 @@ typedef enum {
 	SRPC_REPLY_SENT      = 5, /* outgoing reply sent */
 	SRPC_REQUEST_RCVD    = 6, /* incoming request received */
 	SRPC_REQUEST_SENT    = 7, /* outgoing request sent */
-} srpc_event_type_t;
+};
 
 /* RPC event */
 typedef struct {
-	srpc_event_type_t ev_type;   /* what's up */
+	enum srpc_event_type	ev_type;	/* what's up */
 	lnet_event_kind_t ev_lnet;   /* LNet event type */
 	int		  ev_fired;  /* LNet event fired? */
 	int		  ev_status; /* LNet event status */
-- 
1.7.1
