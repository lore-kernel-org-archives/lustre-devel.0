From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:36:53 -0400
Subject: [lustre-devel] [PATCH 08/18] staging: lustre: hsm: copy start error
	should set HP_FLAG_COMPLETED
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Aurelien Degremont <aurelien.degremont@cea.fr>, James Simmons <jsimmons@infradead.org>

From: Aurelien Degremont <aurelien.degremont@cea.fr>

If an error occurs when initializing a HSM request, in
ll_ioc_copy_start(), the PROGRESS message, sent to coordinator, should
carry the error code but also HP_FLAG_COMPLETED to mark the request as
finished (with error). If not, the Coordinator will ignore this
message and consider the request is still running.

Signed-off-by: Aurelien Degremont <aurelien.degremont@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3685
Reviewed-on: http://review.whamcloud.com/7265
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index b085fb4..41481cc 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -959,6 +959,9 @@ static int ll_ioc_copy_start(struct super_block *sb, struct hsm_copy *copy)
 	}
 
 progress:
+	/* On error, the request should be considered as completed */
+	if (hpk.hpk_errval > 0)
+		hpk.hpk_flags |= HP_FLAG_COMPLETED;
 	rc = obd_iocontrol(LL_IOC_HSM_PROGRESS, sbi->ll_md_exp, sizeof(hpk),
 			   &hpk, NULL);
 
-- 
1.7.1
