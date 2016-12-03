From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:24 -0500
Subject: [lustre-devel] [PATCH 17/22] staging: lustre: clio: remove mtime
	check in vvp_io_fault_start()
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

In fault IO initialization, inode's mtime is saved, and after
getting locks, when the IO is about to start, vvp_io_fault_start()
checks the mtime's intactness.

It's a false alarm, since the timestamp from MDS could be stale,
we maintain mtime mainly on OST objects, and if the check in
vvp_io_fault_start() happens before mtime on OST objects are merged,
it will get wrong timestamp from the inode, even the timestamp it
fetched in vvp_io_fault_init() could be wrong in the first place.

This patch remove the mtime check in vvp_io_fault_start().

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7198
Reviewed-on: http://review.whamcloud.com/19162
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/vvp_io.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index 114906d..0b6d388 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -1064,12 +1064,6 @@ static int vvp_io_fault_start(const struct lu_env *env,
 	loff_t	       size;
 	pgoff_t		     last_index;
 
-	if (fio->ft_executable &&
-	    inode->i_mtime.tv_sec != vio->u.fault.ft_mtime)
-		CWARN("binary "DFID
-		      " changed while waiting for the page fault lock\n",
-		      PFID(lu_object_fid(&obj->co_lu)));
-
 	down_read(&lli->lli_trunc_sem);
 
 	/* offset of the last byte on the page */
-- 
1.7.1
