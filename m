From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:35 -0400
Subject: [lustre-devel] [PATCH 096/124] staging: lustre: osc:
	osc_object_ast_clear() LBUG
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-97-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

An OSC object could be destroyed with AGL locks waiting for granted,
so we'd get rid of the osc_object_ast_clear() assertion that its
dlm locks all getting granted.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6042
Reviewed-on: http://review.whamcloud.com/13163
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Niu Yawei <yawei.niu@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/osc/osc_object.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index d211d19..5fc5479 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -195,7 +195,6 @@ static int osc_object_glimpse(const struct lu_env *env,
 
 static int osc_object_ast_clear(struct ldlm_lock *lock, void *data)
 {
-	LASSERT(lock->l_granted_mode == lock->l_req_mode);
 	if (lock->l_ast_data == data)
 		lock->l_ast_data = NULL;
 	return LDLM_ITER_CONTINUE;
-- 
1.7.1
