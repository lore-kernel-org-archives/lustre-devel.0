From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 11 Mar 2016 22:24:00 -0800
Subject: [lustre-devel] [PATCH 07/10] staging: lustre: cleanup comment
 style for lnet selftest
In-Reply-To: <D308C0DE.13458A%andreas.dilger@intel.com>
References: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
	<1457746191-27981-8-git-send-email-jsimmons@infradead.org>
	<D308C0DE.13458A%andreas.dilger@intel.com>
Message-ID: <20160312062400.GA13693@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: James Simmons <jsimmons@infradead.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, Mar 12, 2016 at 01:39:01AM +0000, Dilger, Andreas wrote:
> On 2016/03/11, 18:29, "lustre-devel on behalf of James Simmons"
> <lustre-devel-bounces@lists.lustre.org on behalf of
> jsimmons at infradead.org> wrote:
> 
> >Apply a consistent style for comments in the lnet selftest
> >code.
> >
> >Signed-off-by: James Simmons <jsimmons@infradead.org>
> >---
> > drivers/staging/lustre/lnet/selftest/brw_test.c  |    8 ++--
> > drivers/staging/lustre/lnet/selftest/conctl.c    |   50
> >+++++++++++-----------
> > drivers/staging/lustre/lnet/selftest/conrpc.c    |   23 +++++-----
> > drivers/staging/lustre/lnet/selftest/console.c   |   11 +++--
> > drivers/staging/lustre/lnet/selftest/framework.c |   20 ++++----
> > drivers/staging/lustre/lnet/selftest/ping_test.c |    2 +-
> > drivers/staging/lustre/lnet/selftest/rpc.c       |   46
> >++++++++++----------
> > drivers/staging/lustre/lnet/selftest/rpc.h       |    2 +-
> > drivers/staging/lustre/lnet/selftest/selftest.h  |    3 +-
> > drivers/staging/lustre/lnet/selftest/timer.c     |    6 +-
> > 10 files changed, 87 insertions(+), 84 deletions(-)
> >
> >diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c
> >b/drivers/staging/lustre/lnet/selftest/brw_test.c
> >index eebc924..6ac4d02 100644
> >--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
> >+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
> >@@ -86,7 +86,7 @@ brw_client_init(sfw_test_instance_t *tsi)
> > 		opc = breq->blk_opc;
> > 		flags = breq->blk_flags;
> > 		npg = breq->blk_npg;
> >-		/*
> >+		/**
> > 		 * NB: this is not going to work for variable page size,
> > 		 * but we have to keep it for compatibility
> > 		 */
> 
> The "/**" comment opener is only for header comment blocks that
> have markup in them.  I don't think that is kernel style for
> normal multi-line comments in the code.

Yes, that is correct.  James, can you fix this up and resend this
series?

thanks,

greg k-h
