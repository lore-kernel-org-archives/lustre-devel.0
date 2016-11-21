From: Oleg Drokin <green@linuxhacker.ru>
Date: Mon, 21 Nov 2016 00:46:48 -0500
Subject: [lustre-devel] [PATCH] staging/lustre: Use proper number of bytes
	in copy_from_user
Message-ID: <1479707208-1241688-1-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jian Yu <jian.yu@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Jian Yu <jian.yu@intel.com>

This patch removes the usage of MAX_STRING_SIZE from
copy_from_user() and just copies enough bytes to cover
count passed in.

Signed-off-by: Jian Yu <jian.yu@intel.com>
Reviewed-on: http://review.whamcloud.com/23462
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8774
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 8a2f02f3..db49992 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -400,10 +400,17 @@ int lprocfs_wr_uint(struct file *file, const char __user *buffer,
 	char dummy[MAX_STRING_SIZE + 1], *end;
 	unsigned long tmp;
 
-	dummy[MAX_STRING_SIZE] = '\0';
-	if (copy_from_user(dummy, buffer, MAX_STRING_SIZE))
+	if (count >= sizeof(dummy))
+		return -EINVAL;
+
+	if (count == 0)
+		return 0;
+
+	if (copy_from_user(dummy, buffer, count))
 		return -EFAULT;
 
+	dummy[count] = '\0';
+
 	tmp = simple_strtoul(dummy, &end, 0);
 	if (dummy == end)
 		return -EINVAL;
-- 
2.7.4
