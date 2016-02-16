From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:16 -0500
Subject: [lustre-devel] [PATCH 44/45] staging/lustre: Convert
	cfs_trace_daemon_command to use kstrtoul
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-45-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

simple_strtoul is obsolete

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/tracefile.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.c b/drivers/staging/lustre/lustre/libcfs/tracefile.c
index 7df8f0a..510673d 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.c
@@ -878,12 +878,15 @@ int cfs_trace_daemon_command(char *str)
 		memset(cfs_tracefile, 0, sizeof(cfs_tracefile));
 
 	} else if (strncmp(str, "size=", 5) == 0) {
-		cfs_tracefile_size = simple_strtoul(str + 5, NULL, 0);
-		if (cfs_tracefile_size < 10 || cfs_tracefile_size > 20480)
-			cfs_tracefile_size = CFS_TRACEFILE_SIZE;
-		else
-			cfs_tracefile_size <<= 20;
-
+		unsigned long tmp;
+
+		rc = kstrtoul(str + 5, 10, &tmp);
+		if (!rc) {
+			if (tmp < 10 || tmp > 20480)
+				cfs_tracefile_size = CFS_TRACEFILE_SIZE;
+			else
+				cfs_tracefile_size = tmp << 20;
+		}
 	} else if (strlen(str) >= sizeof(cfs_tracefile)) {
 		rc = -ENAMETOOLONG;
 	} else if (str[0] != '/') {
-- 
2.1.0
