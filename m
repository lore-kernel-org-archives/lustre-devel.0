From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 25 Oct 2016 23:22:30 +0200
Subject: [lustre-devel] [PATCH v2 1/2] staging: lustre: remove broken dead
	code in cfs_cpt_table_create_pattern
Message-ID: <20161025212310.2346367-1-arnd@arndb.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Patrick Farrell <paf@cray.com>, lustre-devel@lists.lustre.org, Bobi Jam <bobijam@hotmail.com>, James Simmons <uja.ornl@yahoo.com>, Olaf Weber <olaf@sgi.com>, James Simmons <jsimmons@infradead.org>, Jinshan Xiong <jinshan.xiong@intel.com>, "John L . Hammond" <john.hammond@intel.com>, Liang Zhen <liang.zhen@intel.com>, Arnd Bergmann <arnd@arndb.de>, Andreas Dilger <andreas.dilger@intel.com>, Shivani Bhardwaj <shivanib134@gmail.com>, Andriy Skulysh <Andriy_Skulysh@xyratex.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

After a recent bugfix, we get a warning about the use of an uninitialized
variable:

drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c: In function 'cfs_cpt_table_create_pattern':
drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c:833:7: error: 'str' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This part of the function used to not do anything as we would reassign
the 'str' pointer to something else right away, but now we pass an
uninitialized pointer into 'strchr', which can cause a kernel page fault
or worse.

Fixes: 239fd5d41f9b ("staging: lustre: libcfs: shortcut to create CPT from NUMA topology")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 464b27923ac0..6a31521f6ae0 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -829,13 +829,6 @@ cfs_cpt_table_create_pattern(char *pattern)
 	int			c;
 	int i;
 
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
