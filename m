From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:57 -0500
Subject: [lustre-devel] [PATCH 32/34] staging: lustre: lnet: remove
	LNET_SEQ_BASETYPE
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-33-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

The lnet_seq_t is a simple unsigned long so lets
simplify it.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-types.h | 4 ++--
 drivers/staging/lustre/include/linux/lnet/types.h     | 6 ++----
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index b9f1bd2..69c11c1 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -119,8 +119,8 @@ struct lnet_libhandle {
 struct lnet_eq {
 	struct list_head	  eq_list;
 	struct lnet_libhandle	  eq_lh;
-	lnet_seq_t		  eq_enq_seq;
-	lnet_seq_t		  eq_deq_seq;
+	unsigned long		  eq_enq_seq;
+	unsigned long		  eq_deq_seq;
 	unsigned int		  eq_size;
 	lnet_eq_handler_t	  eq_callback;
 	struct lnet_event	 *eq_events;
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 8e10ad6..7d39496 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -561,9 +561,7 @@ enum lnet_event_kind {
 	LNET_EVENT_UNLINK,
 };
 
-#define LNET_SEQ_BASETYPE	long
-typedef unsigned LNET_SEQ_BASETYPE lnet_seq_t;
-#define LNET_SEQ_GT(a, b)	(((signed LNET_SEQ_BASETYPE)((a) - (b))) > 0)
+#define LNET_SEQ_GT(a, b)      (((signed long)((a) - (b))) > 0)
 
 /**
  * Information about an event on a MD.
@@ -634,7 +632,7 @@ struct lnet_event {
 	 * The sequence number for this event. Sequence numbers are unique
 	 * to each event.
 	 */
-	volatile lnet_seq_t	sequence;
+	volatile unsigned long	sequence;
 };
 
 /**
-- 
1.8.3.1
