From: James Simmons <jsimmons@infradead.org>
Date: Tue, 16 Aug 2016 16:18:36 -0400
Subject: [lustre-devel] [PATCH 23/80] staging: lustre: mdc: fixup
	MDS_SWAP_LAYOUTS ELC handling
In-Reply-To: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471378773-24590-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

In mdc_ioc_swap_layouts() cancel *any* unused locks with LAYOUT or
XATTR IBITS set on the two files. (This matches the locks acquired in
mdt_swap_layouts(). Previously only locks that conflicted with a CR
LAYOUT lock were cancelled.)

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4320
Reviewed-on: http://review.whamcloud.com/9329
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/mdc/mdc_request.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 702ced9..030295f 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1670,9 +1670,11 @@ static int mdc_ioc_swap_layouts(struct obd_export *exp,
 	 * with the request RPC to avoid extra RPC round trips
 	 */
 	count = mdc_resource_get_unused(exp, &op_data->op_fid1, &cancels,
-					LCK_CR, MDS_INODELOCK_LAYOUT);
+					LCK_CR, MDS_INODELOCK_LAYOUT |
+					MDS_INODELOCK_XATTR);
 	count += mdc_resource_get_unused(exp, &op_data->op_fid2, &cancels,
-					 LCK_CR, MDS_INODELOCK_LAYOUT);
+					 LCK_CR, MDS_INODELOCK_LAYOUT |
+					 MDS_INODELOCK_XATTR);
 
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_MDS_SWAP_LAYOUTS);
-- 
1.7.1
