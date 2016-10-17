From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 18 Oct 2016 00:08:56 +0200
Subject: [lustre-devel] [PATCH 09/28] staging: lustre: remove broken dead
	code in cfs_cpt_table_create_pattern
In-Reply-To: <20161017220342.1627073-1-arnd@arndb.de>
References: <20161017220342.1627073-1-arnd@arndb.de>
Message-ID: <20161017220903.1746743-3-arnd@arndb.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Liang Zhen <liang.zhen@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org

After a recent bugfix, we get a warning about the use of an uninitialized
variable:

drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c: In function 'cfs_cpt_table_create_pattern':
drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c:833:7: error: 'str' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This part of the function used to not do anything as we would reassign
the 'str' pointer to something else right away, but now we pass an
uninitialized pointer into 'strchr', which can cause a kernel page fault
or worse.

Fixes: 239fd5d41f9b ("staging: lustre: libcfs: shortcut to create CPT from NUMA topology")
Cc: Liang Zhen <liang.zhen@intel.com>
Cc: James Simmons <jsimmons@infradead.org>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index e8b1a61..1226cba 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -824,13 +824,6 @@ cfs_cpt_table_create_pattern(char *pattern)
 	int			ncpt;
 	int			c;
 
-	for (ncpt = 0;; ncpt++) { /* quick scan bracket */
-		str = strchr(str, '[');
-		if (!str)
-			break;
-		str++;
-	}
-
 	str = cfs_trimwhite(pattern);
 	if (*str == 'n' || *str == 'N') {
 		pattern = str + 1;
-- 
2.9.0
