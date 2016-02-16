From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:17 -0500
Subject: [lustre-devel] [PATCH 45/45] staging/lustre: Convert
	cfs_str2num_check to use kstrtoul
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-46-git-send-email-green@linuxhacker.ru>
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
 drivers/staging/lustre/lustre/libcfs/libcfs_string.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
index 09ab0e4..9dca666 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_string.c
@@ -229,18 +229,13 @@ int
 cfs_str2num_check(char *str, int nob, unsigned *num,
 		  unsigned min, unsigned max)
 {
-	char	*endp;
+	int rc;
 
 	str = cfs_trimwhite(str);
-	*num = simple_strtoul(str, &endp, 0);
-	if (endp == str)
+	rc = kstrtouint(str, 10, num);
+	if (rc)
 		return 0;
 
-	for (; endp < str + nob; endp++) {
-		if (!isspace(*endp))
-			return 0;
-	}
-
 	return (*num >= min && *num <= max);
 }
 EXPORT_SYMBOL(cfs_str2num_check);
-- 
2.1.0
