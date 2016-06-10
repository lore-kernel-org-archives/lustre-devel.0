From: Oleg Drokin <green@linuxhacker.ru>
Date: Thu,  9 Jun 2016 22:35:17 -0400
Subject: [lustre-devel] [PATCH 7/8] staging/lustre/ptlrpc: Fix Multiple
	Assignments
In-Reply-To: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
References: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465526118-521053-8-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Nathaniel Clark <nathaniel.l.clark@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Nathaniel Clark <nathaniel.l.clark@intel.com>

Fix all multiple assignments on lustre/ptlrpc directory.

Signed-off-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c       | 6 ++++--
 drivers/staging/lustre/lustre/ptlrpc/import.c       | 3 ++-
 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c | 3 ++-
 drivers/staging/lustre/lustre/ptlrpc/pinger.c       | 3 ++-
 drivers/staging/lustre/lustre/ptlrpc/sec_null.c     | 3 ++-
 5 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 4b7912a..8336ed1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -3024,8 +3024,10 @@ void *ptlrpcd_alloc_work(struct obd_import *imp,
 	req->rq_interpret_reply = work_interpreter;
 	/* don't want reply */
 	req->rq_receiving_reply = 0;
-	req->rq_req_unlink = req->rq_reply_unlink = 0;
-	req->rq_no_delay = req->rq_no_resend = 1;
+	req->rq_req_unlink = 0;
+	req->rq_reply_unlink = 0;
+	req->rq_no_delay = 1;
+	req->rq_no_resend = 1;
 	req->rq_pill.rc_fmt = (void *)&worker_format;
 
 	spin_lock_init(&req->rq_lock);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index a4f7544..a236e38 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -698,7 +698,8 @@ int ptlrpc_connect_import(struct obd_import *imp)
 
 	lustre_msg_add_op_flags(request->rq_reqmsg, MSG_CONNECT_NEXT_VER);
 
-	request->rq_no_resend = request->rq_no_delay = 1;
+	request->rq_no_resend = 1;
+	request->rq_no_delay = 1;
 	request->rq_send_state = LUSTRE_IMP_CONNECTING;
 	/* Allow a slightly larger reply for future growth compatibility */
 	req_capsule_set_size(&request->rq_pill, &RMF_CONNECT_DATA, RCL_SERVER,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 64c0f1e..ff40be2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -872,7 +872,8 @@ ptlrpc_lprocfs_svc_req_history_next(struct seq_file *s,
 
 		if (i > srhi->srhi_idx) { /* reset iterator for a new CPT */
 			srhi->srhi_req = NULL;
-			seq = srhi->srhi_seq = 0;
+			seq = 0;
+			srhi->srhi_seq = 0;
 		} else { /* the next sequence */
 			seq = srhi->srhi_seq + (1 << svc->srv_cpt_bits);
 		}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 8a86931..d9d4ca2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -57,7 +57,8 @@ ptlrpc_prep_ping(struct obd_import *imp)
 					LUSTRE_OBD_VERSION, OBD_PING);
 	if (req) {
 		ptlrpc_request_set_replen(req);
-		req->rq_no_resend = req->rq_no_delay = 1;
+		req->rq_no_resend = 1;
+		req->rq_no_delay = 1;
 	}
 	return req;
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
index 40e5349..af92e9e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_null.c
@@ -265,7 +265,8 @@ int null_enlarge_reqbuf(struct ptlrpc_sec *sec,
 		memcpy(newbuf, req->rq_reqbuf, req->rq_reqlen);
 
 		kvfree(req->rq_reqbuf);
-		req->rq_reqbuf = req->rq_reqmsg = newbuf;
+		req->rq_reqbuf = newbuf;
+		req->rq_reqmsg = newbuf;
 		req->rq_reqbuf_len = alloc_size;
 
 		if (req->rq_import)
-- 
2.7.4
