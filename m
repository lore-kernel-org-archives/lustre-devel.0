From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:33 -0400
Subject: [lustre-devel] [PATCH 37/41] staging: lustre: lov: copy_to_user
	uses wrong casting
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-38-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

With certain version of gcc lov_obd.c failes to compile
with the following warning.

In function copy_to_user,
inlined from lov_iocontrol at
lustre/lustre/lov/lov_obd.c:1168:
./arch/x86/include/asm/uaccess.h:735: error: call to
__copy_to_user_overflow declared with attribute warning:
copy_to_user() buffer size is not probably correct

In lov_iocontrol the data was being casted to int instead
of the required unsigned long. This patch changes the cast
to what is needed for copy_to_user.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6302
Reviewed-on: http://review.whamcloud.com/14613
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_obd.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 473071c..18cb92d 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1085,8 +1085,8 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 
 		/* copy UUID */
 		if (copy_to_user(data->ioc_pbuf2, obd2cli_tgt(osc_obd),
-				 min((int)data->ioc_plen2,
-				     (int)sizeof(struct obd_uuid))))
+				 min_t(unsigned long, data->ioc_plen2,
+				       sizeof(struct obd_uuid))))
 			return -EFAULT;
 
 		memcpy(&flags, data->ioc_inlbuf1, sizeof(__u32));
@@ -1099,8 +1099,8 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 		if (rc)
 			return rc;
 		if (copy_to_user(data->ioc_pbuf1, &stat_buf,
-				 min((int)data->ioc_plen1,
-				     (int)sizeof(stat_buf))))
+				 min_t(unsigned long, data->ioc_plen1,
+				       sizeof(stat_buf))))
 			return -EFAULT;
 		break;
 	}
-- 
1.7.1
