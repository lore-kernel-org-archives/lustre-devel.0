From: Tapan Prakash T <tapanprakasht@gmail.com>
Date: Sun, 28 Feb 2016 19:44:22 +0530
Subject: [lustre-devel] [PATCH] drivers: staging: lustre: lustre: ptlrpc:
	Fix comment related coding style issue
Message-ID: <1456668862-14419-1-git-send-email-tapanprakasht@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, gregkh@linuxfoundation.org
Cc: lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org, Tapan Prakash T <tapanprakasht@gmail.com>

Fixed checkpatch.pl warning 'Block comments use * on subsequent lines'

Signed-off-by: Tapan Prakash T <tapanprakasht@gmail.com>
---
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 0c36663..8db8740 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -423,7 +423,6 @@ static int ptlrpcd(void *arg)
 	complete(&pc->pc_starting);
 
 	/*
-
 	 * This mainloop strongly resembles ptlrpc_set_wait() except that our
 	 * set never completes.  ptlrpcd_check() calls ptlrpc_check_set() when
 	 * there are requests in the set. New requests come in on the set's
-- 
1.9.1
