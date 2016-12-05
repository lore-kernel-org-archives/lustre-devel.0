From: sandeepjain.linux at gmail.com <sandeepjain.linux@gmail.com>
Date: Mon,  5 Dec 2016 07:51:21 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: mgc: make llog_process_lock
	static
Message-ID: <1480904481-20149-1-git-send-email-sandeepjain.linux@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org
Cc: gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Sandeep Jain <sandeepjain.linux@gmail.com>

From: Sandeep Jain <sandeepjain.linux@gmail.com>

Fix following sparse warning.
mgc_request.c:376:1:
warning: symbol 'llog_process_lock' was not declared. Should it be static?

Signed-off-by: Sandeep Jain <sandeepjain.linux@gmail.com>
---
 drivers/staging/lustre/lustre/mgc/mgc_request.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 23600fb..e98a2ce 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -373,7 +373,7 @@ static int config_log_add(struct obd_device *obd, char *logname,
 	return rc;
 }
 
-DEFINE_MUTEX(llog_process_lock);
+static DEFINE_MUTEX(llog_process_lock);
 
 /** Stop watching for updates on this log.
  */
-- 
2.7.4
