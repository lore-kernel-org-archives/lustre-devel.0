From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 15 Nov 2016 11:00:35 +0100
Subject: [lustre-devel] [PATCH 00/35] second batch of missing lustre 2.8
	patches
In-Reply-To: <alpine.LFD.2.20.1611141727250.29600@casper.infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
	<20161114151650.GA12605@kroah.com>
	<alpine.LFD.2.20.1611141727250.29600@casper.infradead.org>
Message-ID: <20161115100035.GA5376@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Nov 14, 2016 at 06:27:57PM +0000, James Simmons wrote:
> 
> > On Thu, Nov 10, 2016 at 12:30:30PM -0500, James Simmons wrote:
> > > More fixes missing from the upstream client. Also a nice cleanup
> > > with the removal of cl_req which is no longer needed. More cleanup
> > > for lustre_idl.h which is a uapi header. Like the last batch these
> > > patches are independent of order.
> > 
> > I didn't apply a few of these (string parsing stuff, and build
> > breakages.)
> > 
> > What's the plan for getting this out of staging?  I feel like you all
> > are still adding new features along with these "cleanups".  Normally
> > that's fine, but I really really want to get this out of staging as it's
> > been there for way too long.  When is that going to happen?
> 
> First I should address why the push to bring it into sync with our
> prouction code base. One was to make it attractive to our user base.
> In my other email I explained that.

Yes, but remember, it's not _our_ fault your have a diverged source code
base, that's yours :)

> Second the feed back here has been
> so valuable. We are at the point where bugs we haven't found are being
> reported here and addressed. Also your input has made the Lustre 
> developers to reflect on what we have done. In a way leaving staging will 
> be sad since that will stop :-(

Why do you think that once the code is out of staging people will stop
reviewing your patches?  You still have to get patches in through the
vfs maintainer, and really, I've never heard anyone say that getting
patches reviewed on linux-fsdevel is "easier" than the staging mailing
list...

> Lastly I really didn't want to cleanup the lustre client and then when
> it left staging do this massive dump of changes without people like
> Julia, Dan and you looking at it. I just felt that wouldn't of been
> right.

You wouldn't be allowed to do a "dump", you still have to follow the
same rules if you are in staging or in fs/

> We are super close to reaching a very important mile stone of reaching
> lustre 2.8.0 level of suppport. At this point we can stop at our lustre 
> 2.8.0 release for the sync since currently most the lustre users out their 
> are staying at that version. Secondly the major of patches landed to our 
> soon to be release 2.9 version was for the patches missing from the 
> staging tree.

I have no idea what your numbering scheme is, nor how it relates to the
kernel release numbers, nor do I really want to learn it :)

> So before we consider moving out of staging some gaps need to be filled.
> The zero day system has found bugs on platforms we don't have access too.

Good, you will have access to that once you are in fs/ as well.

> We really need to hook into that system. Also Julia Lawall Coccinelle
> work has been really wonderful. Intel does have a mirror of your tree and
> have started the integration of the test harness. For my work I have
> using a local private test harness setup. This Intel one is planned for
> public consumption. What is done here with Coccinelle and zero day needs
> to be intergrated. So this is what needs to be done from our side.

Both of that can happen today with your own trees, no need to be in
drivers/staging/ or in fs/, so please don't think that matters.

> Now for what is required to leave the staging tree. Honestly I can think
> of many many many things that need to be done. The question becomes what
> has to be done before leaving staging verses what can be completed after
> leaving staging. We have the normal style issues and checkpatch issues
> which is not much anymore. Then their is the uapi header cleanup. What 
> else beyond that?

Why not do these basic things first and then we can worry about the
rest?  The fact that there is still such basic cleanups needed is
worrying to me...

thanks,

greg k-h
