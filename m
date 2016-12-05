From: sandeepjain.linux at gmail.com <sandeepjain.linux@gmail.com>
Date: Mon,  5 Dec 2016 08:36:37 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: Fix function
	declaration/definition mismatch
Message-ID: <1480907197-23201-1-git-send-email-sandeepjain.linux@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org
Cc: gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Sandeep Jain <sandeepjain.linux@gmail.com>

From: Sandeep Jain <sandeepjain.linux@gmail.com>

Fixes following Sparse errors.
lprocfs_status.c:1568:5: error: symbol 'lprocfs_wr_root_squash'
redeclared with different type...
lprocfs_status.c:1632:5: error: symbol 'lprocfs_wr_nosquash_nids'
redeclared with different type...

Signed-off-by: Sandeep Jain <sandeepjain.linux@gmail.com>
---
 drivers/staging/lustre/lustre/include/lprocfs_status.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index cc0713e..b5c24ca 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -701,9 +701,9 @@ static struct lustre_attr lustre_attr_##name = __ATTR(name, mode, show, store)
 extern const struct sysfs_ops lustre_sysfs_ops;
 
 struct root_squash_info;
-int lprocfs_wr_root_squash(const char *buffer, unsigned long count,
+int lprocfs_wr_root_squash(const char __user *buffer, unsigned long count,
 			   struct root_squash_info *squash, char *name);
-int lprocfs_wr_nosquash_nids(const char *buffer, unsigned long count,
+int lprocfs_wr_nosquash_nids(const char __user *buffer, unsigned long count,
 			     struct root_squash_info *squash, char *name);
 
 /* all quota proc functions */
-- 
2.7.4
