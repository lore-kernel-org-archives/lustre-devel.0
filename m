From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Oct 2016 18:11:59 -0400
Subject: [lustre-devel] [PATCH 25/29] staging: lustre: llite: Inform
	copytool of dataversion changes
In-Reply-To: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
References: <1477606323-30325-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1477606323-30325-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>

From: Henri Doreau <henri.doreau@cea.fr>

Notify copytool that a file could not be archived due to dataversion
change. This does not introduce any functional change but ensures
that errors are consistently reported in copytool logs.

Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5683
Reviewed-on: http://review.whamcloud.com/14377
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Robert Read <robert.read@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 64a32d5..ce05493 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -837,10 +837,10 @@ static int ll_ioc_copy_end(struct super_block *sb, struct hsm_copy *copy)
 			 * when the file will not be modified for some tunable
 			 * time
 			 */
-			/* we do not notify caller */
 			hpk.hpk_flags &= ~HP_FLAG_RETRY;
+			rc = -EBUSY;
 			/* hpk_errval must be >= 0 */
-			hpk.hpk_errval = EBUSY;
+			hpk.hpk_errval = -rc;
 		}
 	}
 
-- 
1.7.1
