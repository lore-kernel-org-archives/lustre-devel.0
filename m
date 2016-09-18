From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:22 -0400
Subject: [lustre-devel] [PATCH 083/124] staging: lustre: ldlm: evict clients
	returning errors on ASTs
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-84-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alexey Lyashkov <alexey_lyashkov@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Alexey Lyashkov <alexey_lyashkov@xyratex.com>

To test proper behavior of clients returning errors on ASTs
we can induce a failure with setting OBD_FAIL_LDLM_BL_CALLBACK_NET.
Handle the new additonal case of cfs_fail_err being set as well
so that the cfs_fail_err can be sent back in a reply.

Signed-off-by: Alexey Lyashkov <alexey_lyashkov@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5581
Xyratex-bug-id: MRP-2041
Reviewed-on: http://review.whamcloud.com/11752
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index b91b26d..ff2c28e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -559,8 +559,11 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 
 	switch (lustre_msg_get_opc(req->rq_reqmsg)) {
 	case LDLM_BL_CALLBACK:
-		if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_BL_CALLBACK_NET))
+		if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_BL_CALLBACK_NET)) {
+			if (cfs_fail_err)
+				ldlm_callback_reply(req, -(int)cfs_fail_err);
 			return 0;
+		}
 		break;
 	case LDLM_CP_CALLBACK:
 		if (OBD_FAIL_CHECK(OBD_FAIL_LDLM_CP_CALLBACK_NET))
-- 
1.7.1
