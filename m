From: Tapan Prakash T <tapanprakasht@gmail.com>
Date: Sun, 28 Feb 2016 20:04:15 +0530
Subject: [lustre-devel] [PATCH] drivers: staging: lustre: lustre: ptlrpc:
	Fix space related coding style issue
Message-ID: <1456670055-16218-1-git-send-email-tapanprakasht@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org
Cc: lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org, Tapan Prakash T <tapanprakasht@gmail.com>

Fixed checkpatch.pl warning space prohibited between function name and
open parenthesis '('

Signed-off-by: Tapan Prakash T <tapanprakasht@gmail.com>
---
 drivers/staging/lustre/lustre/ptlrpc/service.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 6f71ecc..a337603 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -2214,7 +2214,7 @@ static int ptlrpc_hr_main(void *arg)
 {
 	struct ptlrpc_hr_thread	*hrt = arg;
 	struct ptlrpc_hr_partition *hrp = hrt->hrt_partition;
-	LIST_HEAD	(replies);
+	LIST_HEAD(replies);
 	char threadname[20];
 	int rc;
 
@@ -2315,7 +2315,7 @@ static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
 {
 	struct l_wait_info lwi = { 0 };
 	struct ptlrpc_thread *thread;
-	LIST_HEAD	(zombie);
+	LIST_HEAD(zombie);
 
 	CDEBUG(D_INFO, "Stopping threads for service %s\n",
 	       svcpt->scp_service->srv_name);
-- 
1.9.1
