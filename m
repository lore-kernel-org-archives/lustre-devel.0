From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:21 -0400
Subject: [lustre-devel] [PATCH 082/124] staging: lustre: mdc: Proper
	accessing struct lov_user_md
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-83-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Yoshifumi Uemura <kogexe@gmail.com>, James Simmons <jsimmons@infradead.org>

From: Yoshifumi Uemura <kogexe@gmail.com>

In mdc_setattr_pack() access the members of struct lov_user_md by
little endian byte order.

Signed-off-by: Yoshifumi Uemura <kogexe@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5889
Reviewed-on: http://review.whamcloud.com/12683
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Yang Sheng <yang.sheng@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_lib.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index 82d1c4d..aac7e04 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -328,7 +328,7 @@ void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 
 	lum = req_capsule_client_get(&req->rq_pill, &RMF_EADATA);
 	if (!ea) { /* Remove LOV EA */
-		lum->lmm_magic = LOV_USER_MAGIC_V1;
+		lum->lmm_magic = cpu_to_le32(LOV_USER_MAGIC_V1);
 		lum->lmm_stripe_size = 0;
 		lum->lmm_stripe_count = 0;
 		lum->lmm_stripe_offset = (typeof(lum->lmm_stripe_offset))(-1);
-- 
1.7.1
