From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 18 Jun 2016 23:53:10 -0400
Subject: [lustre-devel] [PATCH 1/4] staging/lustre: Fix blank line before
	EXPORT_SYMBOL()
In-Reply-To: <1466308393-1183295-1-git-send-email-green@linuxhacker.ru>
References: <1466308393-1183295-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466308393-1183295-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Emoly Liu <emoly.liu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Emoly Liu <emoly.liu@intel.com>

This patch fixes one checkpatch warning in lustre:
WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable

Signed-off-by: Emoly Liu <emoly.liu@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index fe6f7a6..bc93b75 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -1158,7 +1158,6 @@ void ptlrpc_lprocfs_brw(struct ptlrpc_request *req, int bytes)
 
 	lprocfs_counter_add(svc_stats, idx, bytes);
 }
-
 EXPORT_SYMBOL(ptlrpc_lprocfs_brw);
 
 void ptlrpc_lprocfs_unregister_service(struct ptlrpc_service *svc)
-- 
2.7.4
