From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:54 -0500
Subject: [lustre-devel] [PATCH 186/622] lustre: obdclass: report all obd
 states for OBD_IOC_GETDEVICE
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-187-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The wrong state '--' which is reported when the obd device is
inactive. Reporting the "IN" state cover all the information that
is provided by 'devices' debugfs file. Now all the information
from 'devices' can be collected from the lustre sysfs tree.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Lustre-commit: adfec49f334d ("LU-8066 obdclass: report all obd states for OBD_IOC_GETDEVICE")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/33774
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/class_obd.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/lustre/obdclass/class_obd.c b/fs/lustre/obdclass/class_obd.c
index 4ef9cca..0435f62 100644
--- a/fs/lustre/obdclass/class_obd.c
+++ b/fs/lustre/obdclass/class_obd.c
@@ -427,6 +427,8 @@ int class_handle_ioctl(unsigned int cmd, unsigned long arg)
 
 		if (obd->obd_stopping)
 			status = "ST";
+		else if (obd->obd_inactive)
+			status = "IN";
 		else if (obd->obd_set_up)
 			status = "UP";
 		else if (obd->obd_attached)
-- 
1.8.3.1
