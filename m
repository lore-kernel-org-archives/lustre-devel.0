From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:21:02 -0400
Subject: [lustre-devel] [PATCH 10/15] staging: lustre: clio: add debug
	message in osc_completion()
In-Reply-To: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461795667-29035-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Niu Yawei <yawei.niu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Niu Yawei <yawei.niu@intel.com>

Replace LASSERT with LASSERTF in osc_completion, thus we can get
more info when the LASSERT is triggered.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3843
Reviewed-on: http://review.whamcloud.com/7494
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index dccd309..de28e42 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1333,8 +1333,10 @@ static int osc_completion(const struct lu_env *env, struct osc_async_page *oap,
 	int srvlock;
 
 	cmd &= ~OBD_BRW_NOQUOTA;
-	LASSERT(equi(page->cp_state == CPS_PAGEIN,  cmd == OBD_BRW_READ));
-	LASSERT(equi(page->cp_state == CPS_PAGEOUT, cmd == OBD_BRW_WRITE));
+	LASSERTF(equi(page->cp_state == CPS_PAGEIN, cmd == OBD_BRW_READ),
+		 "cp_state:%u, cmd:%d\n", page->cp_state, cmd);
+	LASSERTF(equi(page->cp_state == CPS_PAGEOUT, cmd == OBD_BRW_WRITE),
+		 "cp_state:%u, cmd:%d\n", page->cp_state, cmd);
 	LASSERT(opg->ops_transfer_pinned);
 
 	/*
-- 
1.7.1
