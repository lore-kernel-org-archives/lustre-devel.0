From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Aug 2016 18:41:46 +0100 (BST)
Subject: [lustre-devel] [PATCH 0/7] staging: lustre: last missing
 patches for lustre 2.6
In-Reply-To: <1471636905.3893.40.camel@perches.com>
References: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
	<1471631966.3893.29.camel@perches.com>
	<alpine.LFD.2.20.1608192007420.7759@casper.infradead.org>
	<1471636905.3893.40.camel@perches.com>
Message-ID: <alpine.LFD.2.20.1608221810590.9872@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Fri, 2016-08-19 at 20:44 +0100, James Simmons wrote:
> > > 1: I'd like to see the lustre #include files separated into
> > > ? ?only two internal/external directories akin to the
> > > ? ?include/linux and include/uapi directories used by linux.
> []
> > For the first question yes it is reasonable and developers
> > have been working to cleanup and separate out the uapi headers
> > from the normal kernel headers. For staging/lustre/lustre we
> > have local headers *_internal.h which only matter for that
> > particular subdirectory. The rest of the headers are all in
> > 
> > staging/lustre/lustre/include/*
> > 
> > In that directory we have the linux subdirectory. That has
> > gone away in newer lustre versions so I would need to push
> > the patch to remove it. The other directory
> > 
> > staging/lustre/lustre/include/lustre/*
> > 
> > contains all our uapi headers like lustre_user.h and lustre_idl.h.
> > Well that is not entirely correct. We still have uapi headers
> > like uapi_kernelcomm.h one directory up. It just if we change those
> > I need to update our userland tools as well. I have a patch ready
> > but I need to push it to our utility branch as well.
> > The next lot is all the LNet/libcfs stuff. The good news for LNet
> > the headers have been cleaned up so separating them out is easy.
> > Well there can always be more improvements. Now libcfs is a bit
> > messy. The libcfs/linux directory needs to be removed yet. Also
> > libcfs_debug.h needs to broken up for uapi use.
> > 
> > Thats the run down about where we are at for the headers. Also it
> > gives you an idea where we are heading. So how do you need this
> > layed out for what you want to do? Where do you want to place the
> > headers?
> 
> Thanks.
> 
> I don't _need_ anything, but I think it'd be simpler to
> have just 2 directories, one for lustre kernel stuff
> and another for lustre uapi stuff.
> 
> That applies for LNet and libcfs #includes as well.
> 
> To me, ideally, there'd only be 2 #include directories
> so that the only used #include styles could become:
> 
> #include <linux/lustre/foo.h>
> and
> #include <uapi/lustre/bar.h>
> 
> and that would work regardless of lustre's layout
> in staging or elsewhere.

I didn't expect this to be requested at this time. I thought this would be 
addressed just before we left staging. I had to ponder the impact of
this change since this affects our userland utilities as well. Moving
the staging/lustre/lustre/include/* to include/linux/lustre is pretty
straight forward for the internal kernel headers.

The issues is that we still have entanglement issues with some of our uapi 
headers with internals of the kernel leaking to userland. I can push the 
cleanups we have so far but its not complete. Its close but not yet 
their. The other issue is I see some of our uapi headers for the upstream
client got nuked i.e userland  ifdefs got remove, so they are useless for 
userland now. Besides that is the impact on our userland utilities. 
Currently we expect our lustre uapi headers to be in /usr/include/lustre.
I noticed for uapi headers their is a mapping of

include/uapi/XXX -> /usr/include/XXX

This would mean that instead of the lustre api being moved to 

include/uapi/linux/lustre 

they would need to be instead in

include/uapi/lustre

Would that be acceptable? If not I guess we could add userland wrappers in 
/usr/include/lustre that point to the uapi headers. In any case we have to 
figure out something for our utilities. The same goes for LNet. We tend to 
use /usr/include/lnet/XXX. Is inclue/uapi/lnet acceptable. Also the few 
libcfs headers we use in userland needs to find a new home. 

This Wednsday we have a lustre community conference call were we discuss
upstream issues. This will need to be discussed.  
