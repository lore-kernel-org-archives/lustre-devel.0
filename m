From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:52 -0400
Subject: [lustre-devel] [PATCH 113/124] staging: lustre: obd: use proper
	flags for call_usermodehelper
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-114-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

When a parameter is permanently changed on the MGS the
MGS send a changelog packet to the proper nodes that
are affected by the change. Once the nodes receive the
change they then call the userland utility lctl to
change its local value. When calling a userland
application from the kernel you specify a flag to
control the interaction with the application. Originally
by default the flag was set to 0 which is UMH_NO_WAIT
which meant lctl was being called asynchronously. In
older kernels this was fine since UHM_NO_WAIT and
UHM_WAIT_PROC had nearly the same logic. This changed
with newer kernels which broke updating our parameters.
Plus doing a UHM_NO_WAIT doesn't report back a error
if something goes wrong with lctl. The fix is to set
the flag to UHM_WAIT_PROC so kernel space waits until
lctl has finished and we get a proper error code if
something does go wrong with lctl.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6063
Reviewed-on: http://review.whamcloud.com/13677
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/obdclass/obd_config.c    |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index fddfc9c..bbed1b7 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -738,7 +738,7 @@ static int process_param2_config(struct lustre_cfg *lcfg)
 	}
 
 	start = ktime_get();
-	rc = call_usermodehelper(argv[0], argv, NULL, 1);
+	rc = call_usermodehelper(argv[0], argv, NULL, UMH_WAIT_PROC);
 	end = ktime_get();
 
 	if (rc < 0) {
-- 
1.7.1
