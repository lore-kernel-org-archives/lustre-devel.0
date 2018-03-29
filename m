From: NeilBrown <neilb@suse.com>
Date: Thu, 29 Mar 2018 15:26:48 +1100
Subject: [lustre-devel] [PATCH 01/17] staging: lustre: remove invariant in
 cl_io_read_ahead()
In-Reply-To: <152229732768.27689.4800156943561963977.stgit@noble>
References: <152229732768.27689.4800156943561963977.stgit@noble>
Message-ID: <152229760825.27689.17083243052405696738.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

This invariant can fail as ci_type is somtimes CIS_INIT.

According to Jinshan Xiong, or of the most recent significant
change to this code, "We should get rid of it."

So do that.

Fixes: 1e1db2a97be5 ("staging: lustre: clio: Revise read ahead implementation")
Cc: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/cl_io.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index ab84e011b560..fcdae6029258 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -599,7 +599,6 @@ int cl_io_read_ahead(const struct lu_env *env, struct cl_io *io,
 	int		       result = 0;
 
 	LINVRNT(io->ci_type == CIT_READ || io->ci_type == CIT_FAULT);
-	LINVRNT(io->ci_state == CIS_IO_GOING || io->ci_state == CIS_LOCKED);
 	LINVRNT(cl_io_invariant(io));
 
 	cl_io_for_each(scan, io) {
