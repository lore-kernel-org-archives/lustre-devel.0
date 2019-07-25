From: James Simmons <jsimmons@infradead.org>
Date: Wed, 24 Jul 2019 22:44:01 -0400
Subject: [lustre-devel] [PATCH 2/8] lustre: ptlrpc: Fix an rq_no_reply
 assertion failure
In-Reply-To: <1564022647-17351-1-git-send-email-jsimmons@infradead.org>
References: <1564022647-17351-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1564022647-17351-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Li Wei <wei.g.li@intel.com>

An OSS had an assertion failure:

  LustreError: 5366:0:(ldlm_lib.c:2689:target_bulk_io()) @@@ timeout
  on bulk GET after 0+0s  req at ffff88083a61b400
  x1476486691018500/t0(4300509964)
  o4->8dda3382-83f8-6445-5eea-828fd59e4a06 at 192.168.1.116@o2ib1:0/0
  lens 504/448 e 391470 to 0 dl 1408494729 ref 2 fl Complete:/4/0 rc
  0/0
  LustreError: 5432:0:(niobuf.c:550:ptlrpc_send_reply()) ASSERTION(
  req->rq_no_reply == 0 ) failed:
  Lustre: soaked-OST0000: Bulk IO write error with
  8dda3382-83f8-6445-5eea-828fd59e4a06 (at 192.168.1.116 at o2ib1),
  client will retry: rc -110
  LustreError: 5432:0:(niobuf.c:550:ptlrpc_send_reply()) LBUG
  Pid: 5432, comm: ll_ost_io03_003

  Call Trace:
  [<ffffffffa0641895>] libcfs_debug_dumpstack+0x55/0x80 [libcfs]
  [<ffffffffa0641e97>] lbug_with_loc+0x47/0xb0 [libcfs]
  [<ffffffffa09cda4c>] ptlrpc_send_reply+0x4ec/0x7f0 [ptlrpc]
  [<ffffffffa09d4aae>] ? lustre_pack_reply_flags+0xae/0x1f0 [ptlrpc]
  [<ffffffffa09e4d75>] ptlrpc_at_check_timed+0xcd5/0x1370 [ptlrpc]
  [<ffffffffa09dc1e9>] ? ptlrpc_wait_event+0xa9/0x2d0 [ptlrpc]
  [<ffffffffa09e66f8>] ptlrpc_main+0x12e8/0x1990 [ptlrpc]
  [<ffffffff81069290>] ? pick_next_task_fair+0xd0/0x130
  [<ffffffff81529246>] ? schedule+0x176/0x3b0
  [<ffffffffa09e5410>] ? ptlrpc_main+0x0/0x1990 [ptlrpc]
  [<ffffffff8109abf6>] kthread+0x96/0xa0
  [<ffffffff8100c20a>] child_rip+0xa/0x20
  [<ffffffff8109ab60>] ? kthread+0x0/0xa0
  [<ffffffff8100c200>] ? child_rip+0x0/0x20

The thread in tgt_brw_write() had decided not to reply by setting
rq_no_reply, right before another thread tried to send an early reply
for the request.

WC-bug-id: https://jira.whamcloud.com/browse/LU-5537
Lustre-commit: a8d448e4cd5978c546911f98067232bcdd30b651
Signed-off-by: Li Wei <wei.g.li@intel.com>
Reviewed-on: http://review.whamcloud.com/11740
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Johann Lombardi <johann.lombardi@intel.com>
---
 fs/lustre/ptlrpc/service.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index a40e964..c9ab9c3 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1098,6 +1098,16 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	reqcopy->rq_reqmsg = reqmsg;
 	memcpy(reqmsg, req->rq_reqmsg, req->rq_reqlen);
 
+	/*
+	 * tgt_brw_read() and tgt_brw_write() may have decided not to reply.
+	 * Without this check, we would fail the rq_no_reply assertion in
+	 * ptlrpc_send_reply().
+	 */
+	if (reqcopy->rq_no_reply) {
+		rc = -ETIMEDOUT;
+		goto out;
+	}
+
 	LASSERT(atomic_read(&req->rq_refcount));
 	/** if it is last refcount then early reply isn't needed */
 	if (atomic_read(&req->rq_refcount) == 1) {
-- 
1.8.3.1
