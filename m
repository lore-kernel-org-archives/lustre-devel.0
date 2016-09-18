From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:12 -0400
Subject: [lustre-devel] [PATCH 013/124] staging: lustre: osc: update kms in
	brw_interpret() properly
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

In brw_interpret(), we forgot page offset when calculating
write offset, that leads to wrong kms for sync write.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5463
Reviewed-on: http://review.whamcloud.com/11374
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Li Dongyang <dongyang.li@anu.edu.au>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_request.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index e861973..e44b4fa 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1796,7 +1796,8 @@ static int brw_interpret(const struct lu_env *env,
 
 		if (lustre_msg_get_opc(req->rq_reqmsg) == OST_WRITE) {
 			struct lov_oinfo *loi = cl2osc(obj)->oo_oinfo;
-			loff_t last_off = last->oap_count + last->oap_obj_off;
+			loff_t last_off = last->oap_count + last->oap_obj_off +
+					  last->oap_page_off;
 
 			/* Change file size if this is an out of quota or
 			 * direct IO write and it extends the file size
-- 
1.7.1
