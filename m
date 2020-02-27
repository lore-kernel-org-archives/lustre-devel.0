From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:10 -0500
Subject: [lustre-devel] [PATCH 202/622] lustre: clio: fix incorrect
 invariant in cl_io_iter_fini()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-203-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

It was discovered during PFL testing that if LINVRNT() is enabled
that cl_io_iter_fini() will crash with the following backtrace:

    kernel: LustreError: 16009:0:(cl_io.c:439:cl_io_iter_fini())
            ASSERTION( io->ci_state == CIS_UNLOCKED ) failed
    kernel: cl_io_iter_fini+0x10c/0x110 [obdclass]
    kernel: cl_io_loop+0x46/0x220 [obdclass]
    kernel: cl_setattr_ost+0x1ed/0x2a0 [lustre]
    kernel: ll_setattr_raw+0x7b0/0x9a0 [lustre]
    kernel: notify_change+0x1dc/0x430
    kernel: do_truncate+0x72/0xc0
    kernel: do_sys_ftruncate+0xf5/0x160

This is due to the incorrect assumption that the ci_state will
always be CIS_UNLOCKED, but by looking at the behavior of
cl_io_loop() it can be seen that is not the case with PFL.
We do want to make sure the IO state is not in the middle of
some other action (up to CIS_IT_STARTED or CIS_IO_FINISHED or
later) when cl_io_iter_fini() is called.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11828
Lustre-commit: 8160b9bdf16c ("LU-11828 clio: fix incorrect invariant in cl_io_iter_fini()")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/33915
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/cl_io.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/obdclass/cl_io.c b/fs/lustre/obdclass/cl_io.c
index a98be15..4278bc0 100644
--- a/fs/lustre/obdclass/cl_io.c
+++ b/fs/lustre/obdclass/cl_io.c
@@ -412,7 +412,8 @@ void cl_io_iter_fini(const struct lu_env *env, struct cl_io *io)
 	const struct cl_io_slice *scan;
 
 	LINVRNT(cl_io_is_loopable(io));
-	LINVRNT(io->ci_state < CIS_LOCKED || io->ci_state > CIS_IO_FINISHED);
+	LINVRNT(io->ci_state <= CIS_IT_STARTED ||
+		io->ci_state > CIS_IO_FINISHED);
 	LINVRNT(cl_io_invariant(io));
 
 	list_for_each_entry_reverse(scan, &io->ci_layers, cis_linkage) {
-- 
1.8.3.1
