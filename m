From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 14 Oct 2016 09:41:34 +0200
Subject: [lustre-devel] [PATCH 32/41] staging: lustre: llite: restart
 short read/write for normal IO
In-Reply-To: <alpine.LFD.2.20.1610132342251.18218@casper.infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
	<1475461717-21631-33-git-send-email-jsimmons@infradead.org>
	<20161009141637.GA2092@kroah.com>
	<alpine.LFD.2.20.1610120019040.28392@casper.infradead.org>
	<20161012060802.GA24118@kroah.com>
	<alpine.LFD.2.20.1610132342251.18218@casper.infradead.org>
Message-ID: <20161014074134.GA32578@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Bobi Jam <bobijam.xu@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Oct 13, 2016 at 11:45:28PM +0100, James Simmons wrote:
> 
> > On Wed, Oct 12, 2016 at 12:22:35AM +0100, James Simmons wrote:
> > > 
> > > > On Sun, Oct 02, 2016 at 10:28:28PM -0400, James Simmons wrote:
> > > > > From: Bobi Jam <bobijam.xu@intel.com>
> > > > > 
> > > > > If normal IO got short read/write, we'd restart the IO from where
> > > > > we've accomplished until we meet EOF or error happens.
> > > > > 
> > > > > Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
> > > > > Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
> > > > > Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6389
> > > > > Reviewed-on: http://review.whamcloud.com/14123
> > > > > Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> > > > > Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> > > > > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > > > > ---
> > > > >  drivers/staging/lustre/lnet/libcfs/fail.c          |    1 +
> > > > >  .../staging/lustre/lustre/include/obd_support.h    |    2 +
> > > > >  drivers/staging/lustre/lustre/llite/file.c         |   41 ++++++++++++--------
> > > > >  drivers/staging/lustre/lustre/llite/vvp_io.c       |   19 ++++++++-
> > > > >  4 files changed, 45 insertions(+), 18 deletions(-)
> > > > 
> > > > Due to other changes in the filesystem tree, this patch no longer
> > > > applies :(
> > > > 
> > > > Can you rebase it and resend?
> > > 
> > > How long will you be accepting patches to merge for? If its going
> > > to be a few weeks like to just include the missing two patches with
> > > the next batch.
> > 
> > I don't understand the question.  I always accept patches, no need to
> > not send them, I'll queue them up to the proper branches as needed.  So
> > what do you mean here?
> 
> I had the impression that more complex patches like the ones I have been
> sending tend to accepted only at the start of the release cycle and only
> simpler patches go into *-rc[3-7] versions. That is why I asked the
> above question.

Yes, that is true, but I will take your "complex" patches and put them
into the -next branch to go to the next kernel release, and only take
bug and regression fixes and add them to the -linus branch to go to the
-rc3-7 releases.

thanks,

greg k-h
