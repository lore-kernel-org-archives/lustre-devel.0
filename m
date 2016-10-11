From: James Simmons <jsimmons@infradead.org>
Date: Wed, 12 Oct 2016 00:22:35 +0100 (BST)
Subject: [lustre-devel] [PATCH 32/41] staging: lustre: llite: restart
 short read/write for normal IO
In-Reply-To: <20161009141637.GA2092@kroah.com>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
	<1475461717-21631-33-git-send-email-jsimmons@infradead.org>
	<20161009141637.GA2092@kroah.com>
Message-ID: <alpine.LFD.2.20.1610120019040.28392@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>


> On Sun, Oct 02, 2016 at 10:28:28PM -0400, James Simmons wrote:
> > From: Bobi Jam <bobijam.xu@intel.com>
> > 
> > If normal IO got short read/write, we'd restart the IO from where
> > we've accomplished until we meet EOF or error happens.
> > 
> > Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
> > Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
> > Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6389
> > Reviewed-on: http://review.whamcloud.com/14123
> > Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> > Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> >  drivers/staging/lustre/lnet/libcfs/fail.c          |    1 +
> >  .../staging/lustre/lustre/include/obd_support.h    |    2 +
> >  drivers/staging/lustre/lustre/llite/file.c         |   41 ++++++++++++--------
> >  drivers/staging/lustre/lustre/llite/vvp_io.c       |   19 ++++++++-
> >  4 files changed, 45 insertions(+), 18 deletions(-)
> 
> Due to other changes in the filesystem tree, this patch no longer
> applies :(
> 
> Can you rebase it and resend?

How long will you be accepting patches to merge for? If its going
to be a few weeks like to just include the missing two patches with
the next batch.

Another issue I need to look at is the IB changes. That's going to
require some heavy surgery to the ko2iblnd driver so its going to
take time for me to port this to the new RDMA RW api. That will
need to be push to linus so ko2iblnd can work with the 4.9 tree
if that is okay with you.
