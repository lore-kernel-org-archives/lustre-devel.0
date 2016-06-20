From: Oleg Drokin <green@linuxhacker.ru>
Date: Mon, 20 Jun 2016 16:55:43 -0400
Subject: [lustre-devel] [PATCH v2 20/29] staging/lustre/mdc: Zero atime in
	close RPC
In-Reply-To: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
References: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466456152-2199975-21-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Niu Yawei <yawei.niu@intel.com>

While atime on close is supposed to only increase, there's
a bug in some older server versions where atime from a client
is taken no matter the value that allows a stale client atime
to overwrite a correct value.

Update atime in close rpc to 0 to help such servers out.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-on: http://review.whamcloud.com/19932
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8041
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/mdc/mdc_lib.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 2703113..143bd76 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -467,6 +467,18 @@ void mdc_close_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	mdc_setattr_pack_rec(rec, op_data);
+	/*
+	 * The client will zero out local timestamps when losing the IBITS lock
+	 * so any new RPC timestamps will update the client inode's timestamps.
+	 * There was a defect on the server side which allowed the atime to be
+	 * overwritten by a zeroed-out atime packed into the close RPC.
+	 *
+	 * Proactively clear the MDS_ATTR_ATIME flag in the RPC in this case
+	 * to avoid zeroing the atime on old unpatched servers.  See LU-8041.
+	 */
+	if (rec->sa_atime == 0)
+		rec->sa_valid &= ~MDS_ATTR_ATIME;
+
 	mdc_ioepoch_pack(epoch, op_data);
 	mdc_hsm_release_pack(req, op_data);
 }
-- 
2.7.4
