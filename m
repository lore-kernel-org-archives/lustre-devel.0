From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:21 -0400
Subject: [lustre-devel] [PATCH 06/28] staging/lustre/osc: Fix reverted
	condition in osc_lock_weight
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-7-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

When importing clio simplification patch, the check for
object got reversed by mistake when converting from
if (obj == NULL) it somehow became if (obj) which is obviously wrong,
and so when it does hit, a crash was happening as result.

Fix the condition and all if fine now.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/osc/osc_lock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index d856775..5455d9d 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -699,7 +699,7 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
 
 	LASSERT(dlmlock->l_resource->lr_type == LDLM_EXTENT);
 	obj = dlmlock->l_ast_data;
-	if (obj) {
+	if (!obj) {
 		weight = 1;
 		goto out;
 	}
-- 
2.7.4
