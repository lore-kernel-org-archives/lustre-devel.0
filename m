From: Oleg Drokin <green@linuxhacker.ru>
Date: Thu, 25 Aug 2016 13:50:59 -0400
Subject: [lustre-devel] [PATCH] staging/lustre: Fix max_dirty_mb output in
	sysfs
Message-ID: <1472147459-800686-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

%ul definitely was supposed to be %lu in the format string,
so we print long unsigned int value, not just unsigned int
with a letter l added at the end.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
index 8f70dd2..bcf005d 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-sysctl.c
@@ -95,8 +95,9 @@ LUSTRE_STATIC_UINT_ATTR(timeout, &obd_timeout);
 static ssize_t max_dirty_mb_show(struct kobject *kobj, struct attribute *attr,
 				 char *buf)
 {
-	return sprintf(buf, "%ul\n",
-			obd_max_dirty_pages / (1 << (20 - PAGE_SHIFT)));
+	return sprintf(buf, "%lu\n",
+		       (unsigned long)obd_max_dirty_pages /
+		       (1 << (20 - PAGE_SHIFT)));
 }
 
 static ssize_t max_dirty_mb_store(struct kobject *kobj, struct attribute *attr,
-- 
2.7.4
