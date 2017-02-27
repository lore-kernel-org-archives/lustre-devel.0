From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:55 -0500
Subject: [lustre-devel] [PATCH 30/34] staging: lustre: lnet: change
	lnet_event_kind_t to proper enum
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_event_kind_t from typedef to proper enum.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h      | 2 +-
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h | 2 +-
 drivers/staging/lustre/include/linux/lnet/types.h    | 6 +++---
 drivers/staging/lustre/lnet/lnet/lib-move.c          | 2 +-
 drivers/staging/lustre/lnet/lnet/lib-msg.c           | 2 +-
 drivers/staging/lustre/lnet/selftest/selftest.h      | 2 +-
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index 125d5cb..fc42898 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -147,7 +147,7 @@ int LNetMDBind(struct lnet_md md_in,
  * event that is deposited into the EQ.
  *
  * In addition to the lnet_handle_eq, the LNet API defines two types
- * associated with events: The ::lnet_event_kind_t defines the kinds of events
+ * associated with events: The ::lnet_event_kind defines the kinds of events
  * that can be stored in an EQ. The lnet_event defines a structure that
  * holds the information about with an event.
  *
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 2d684a7..dce09fe 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -486,7 +486,7 @@ void lnet_msg_attach_md(struct lnet_msg *msg, struct lnet_libmd *md,
 			unsigned int offset, unsigned int mlen);
 void lnet_msg_detach_md(struct lnet_msg *msg, int status);
 void lnet_build_unlink_event(struct lnet_libmd *md, struct lnet_event *ev);
-void lnet_build_msg_event(struct lnet_msg *msg, lnet_event_kind_t ev_type);
+void lnet_build_msg_event(struct lnet_msg *msg, enum lnet_event_kind ev_type);
 void lnet_msg_commit(struct lnet_msg *msg, int cpt);
 void lnet_msg_decommit(struct lnet_msg *msg, int cpt, int status);
 
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 4fde723..a621ab6 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -523,7 +523,7 @@ struct lnet_md {
 /**
  * Six types of events can be logged in an event queue.
  */
-typedef enum {
+enum lnet_event_kind {
 	/** An incoming GET operation has completed on the MD. */
 	LNET_EVENT_GET		= 1,
 	/**
@@ -559,7 +559,7 @@ struct lnet_md {
 	 * \see LNetMDUnlink
 	 */
 	LNET_EVENT_UNLINK,
-} lnet_event_kind_t;
+};
 
 #define LNET_SEQ_BASETYPE	long
 typedef unsigned LNET_SEQ_BASETYPE lnet_seq_t;
@@ -580,7 +580,7 @@ struct lnet_event {
 	 */
 	lnet_nid_t		sender;
 	/** Indicates the type of the event. */
-	lnet_event_kind_t	type;
+	enum lnet_event_kind	type;
 	/** The portal table index specified in the request */
 	unsigned int		pt_index;
 	/** A copy of the match bits specified in the request. */
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 3c54a3d..7fdbc75 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1987,7 +1987,7 @@
  * \retval -ENOMEM Memory allocation failure.
  * \retval -ENOENT Invalid MD object.
  *
- * \see lnet_event::hdr_data and lnet_event_kind_t.
+ * \see lnet_event::hdr_data and lnet_event_kind.
  */
 int
 LNetPut(lnet_nid_t self, struct lnet_handle_md mdh, lnet_ack_req_t ack,
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index b9b0259..008ac50 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -54,7 +54,7 @@
  * Don't need any lock, must be called after lnet_commit_md
  */
 void
-lnet_build_msg_event(struct lnet_msg *msg, lnet_event_kind_t ev_type)
+lnet_build_msg_event(struct lnet_msg *msg, enum lnet_event_kind ev_type)
 {
 	struct lnet_hdr *hdr = &msg->msg_hdr;
 	struct lnet_event *ev  = &msg->msg_ev;
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 2e2c215..3c68cf3 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -144,7 +144,7 @@ enum srpc_event_type {
 /* RPC event */
 struct srpc_event {
 	enum srpc_event_type	ev_type;	/* what's up */
-	lnet_event_kind_t ev_lnet;   /* LNet event type */
+	enum lnet_event_kind	ev_lnet;	/* LNet event type */
 	int		  ev_fired;  /* LNet event fired? */
 	int		  ev_status; /* LNet event status */
 	void		  *ev_data;  /* owning server/client RPC */
-- 
1.8.3.1
