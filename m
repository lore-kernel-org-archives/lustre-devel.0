From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:27 -0400
Subject: [lustre-devel] [PATCH 12/28] staging/lustre/llite: take trunc_sem
	only at vvp layer
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-13-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Patrick Farrell <paf@cray.com>, Oleg Drokin <green@linuxhacker.ru>

From: Patrick Farrell <paf@cray.com>

The lli_trunc_sem is taken in 'read' mode in both
ll_page_mkwrite and vvp_io_fault_start. This can lead to a
deadlock with another thread which asks for the semaphore
in write mode between thse two read calls.

Since all users of lli_trunc_sem are in the vvp layer, we
can satisfy the requirement to exclude truncate by taking
the semaphore only in vvp_io_fault_start.

Signed-off-by: Patrick Farrell <paf@cray.com>
Reviewed-on: http://review.whamcloud.com/19315
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7981
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@seagate.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/llite_mmap.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index fb1c3b6..66ee5db 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -196,18 +196,11 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
 
 	set = cfs_block_sigsinv(sigmask(SIGKILL) | sigmask(SIGTERM));
 
-	/* we grab lli_trunc_sem to exclude truncate case.
-	 * Otherwise, we could add dirty pages into osc cache
-	 * while truncate is on-going.
-	 */
 	inode = vvp_object_inode(io->ci_obj);
 	lli = ll_i2info(inode);
-	down_read(&lli->lli_trunc_sem);
 
 	result = cl_io_loop(env, io);
 
-	up_read(&lli->lli_trunc_sem);
-
 	cfs_restore_sigs(set);
 
 	if (result == 0) {
-- 
2.7.4
