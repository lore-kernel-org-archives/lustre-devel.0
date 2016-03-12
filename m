From: James Simmons <jsimmons@infradead.org>
Date: Sat, 12 Mar 2016 13:00:32 -0500
Subject: [lustre-devel] [PATCH 2/6] staging: lustre: add missing buffer
	overflow fix for console.c
In-Reply-To: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
References: <1457805636-23859-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457805636-23859-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Patch 9389 change a strncpy call into a strlcpy call. This was
missed in the merger into the upstream client.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4629
Reviewed-on: http://review.whamcloud.com/9389
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/selftest/console.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 1a923ea..c009ad3 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -1749,7 +1749,7 @@ lstcon_session_new(char *name, int key, unsigned feats,
 
 	if (strlen(name) > sizeof(console_session.ses_name) - 1)
 		return -E2BIG;
-	strncpy(console_session.ses_name, name,
+	strlcpy(console_session.ses_name, name,
 		sizeof(console_session.ses_name));
 
 	rc = lstcon_batch_add(LST_DEFAULT_BATCH);
-- 
1.7.1
