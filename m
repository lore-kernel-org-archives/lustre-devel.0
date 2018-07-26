From: Jia-Ju Bai <baijiaju1990@gmail.com>
Date: Thu, 26 Jul 2018 22:02:22 +0800
Subject: [lustre-devel] [BUG] staging: lustre: Possible null function
 pointer in ctx_refresh_timeout()
Message-ID: <6920e093-ad62-56dc-6f58-36cf8d7ed3b4@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, paf@cray.com, namit@vmware.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

In Linux-4.16, drivers/staging/lustre/lustre/ptlrp/sec.c,

557. int ctx_refresh_timeout(...) {
 ??????????? .......
573. req->rq_cli_ctx->cc_ops->force_die(req->rq_cli_ctx, 0);
 ??????????? ......
575. }

For x86 kernel configuration, there is no assignment of the function 
pointer ".force_die" in the kernel code.
So calling the function pointer in line 573 may cause a null pointer 
dereference.


Best wishes,
Jia-Ju Bai
