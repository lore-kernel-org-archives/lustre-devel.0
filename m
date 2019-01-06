From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:13:56 -0500
Subject: [lustre-devel] [PATCH v2 01/33] lustre: clio: fix incorrect
 invariant in cl_io_iter_fini()
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

It was discovered during PFL testing that if you enable invarients
that cl_io_iter_fini() will crash with the following back trace:

kernel: cl_io_iter_fini+0x10c/0x110 [obdclass]
kernel: cl_io_loop+0x46/0x220 [obdclass]
kernel: cl_setattr_ost+0x1ed/0x2a0 [lustre]
kernel: ll_setattr_raw+0x7b0/0x9a0 [lustre]
kernel: notify_change+0x1dc/0x430
kernel: do_truncate+0x72/0xc0
kernel: do_sys_ftruncate+0xf5/0x160

This is due to assumption that the ci_state will always be
CIS_UNLOCKED but by looking at the behavior of cl_io_loop() it
can be seen that is not the case. We do want to make sure the
state is in the range of CIS_IT_STARTED to CIS_IO_FINISHED when
cl_io_iter_fini() is called.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-11828
Reviewed-on: https://review.whamcloud.com/33915
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/cl_io.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 879383ae..0da731c 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -436,7 +436,7 @@ void cl_io_iter_fini(const struct lu_env *env, struct cl_io *io)
 	const struct cl_io_slice *scan;
 
 	LINVRNT(cl_io_is_loopable(io));
-	LINVRNT(io->ci_state == CIS_UNLOCKED);
+	LINVRNT(io->ci_state < CIS_LOCKED || io->ci_state > CIS_IO_FINISHED);
 	LINVRNT(cl_io_invariant(io));
 
 	list_for_each_entry_reverse(scan, &io->ci_layers, cis_linkage) {
-- 
1.8.3.1
