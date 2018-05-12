From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Date: Sat, 12 May 2018 14:14:26 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: Use 'kvfree()' for memory
 allocated by 'kvzalloc()'
Message-ID: <20180512121426.22988-1-christophe.jaillet@wanadoo.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, neilb@suse.com, aastha.gupta4104@gmail.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org, Christophe JAILLET <christophe.jaillet@wanadoo.fr>

'buf' is allocated with 'kvzalloc()'. 'kvfree()' must be used to free it.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/staging/lustre/lustre/obdclass/llog.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 693e1129f1f9..5e04d133b596 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -385,7 +385,7 @@ static int llog_process_thread(void *arg)
 	if (cd)
 		cd->lpcd_last_idx = last_called_index;
 
-	kfree(buf);
+	kvfree(buf);
 	lpi->lpi_rc = rc;
 	return 0;
 }
-- 
2.17.0
