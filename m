From: Joe Perches <joe@perches.com>
Date: Fri, 19 Aug 2016 13:01:45 -0700
Subject: [lustre-devel] [PATCH 0/7] staging: lustre: last missing
	patches for lustre 2.6
In-Reply-To: <alpine.LFD.2.20.1608192007420.7759@casper.infradead.org>
References: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
	<1471631966.3893.29.camel@perches.com>
	<alpine.LFD.2.20.1608192007420.7759@casper.infradead.org>
Message-ID: <1471636905.3893.40.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, 2016-08-19 at 20:44 +0100, James Simmons wrote:
> > 1: I'd like to see the lustre #include files separated into
> > ? ?only two internal/external directories akin to the
> > ? ?include/linux and include/uapi directories used by linux.
[]
> For the first question yes it is reasonable and developers
> have been working to cleanup and separate out the uapi headers
> from the normal kernel headers. For staging/lustre/lustre we
> have local headers *_internal.h which only matter for that
> particular subdirectory. The rest of the headers are all in
> 
> staging/lustre/lustre/include/*
> 
> In that directory we have the linux subdirectory. That has
> gone away in newer lustre versions so I would need to push
> the patch to remove it. The other directory
> 
> staging/lustre/lustre/include/lustre/*
> 
> contains all our uapi headers like lustre_user.h and lustre_idl.h.
> Well that is not entirely correct. We still have uapi headers
> like uapi_kernelcomm.h one directory up. It just if we change those
> I need to update our userland tools as well. I have a patch ready
> but I need to push it to our utility branch as well.
> The next lot is all the LNet/libcfs stuff. The good news for LNet
> the headers have been cleaned up so separating them out is easy.
> Well there can always be more improvements. Now libcfs is a bit
> messy. The libcfs/linux directory needs to be removed yet. Also
> libcfs_debug.h needs to broken up for uapi use.
> 
> Thats the run down about where we are at for the headers. Also it
> gives you an idea where we are heading. So how do you need this
> layed out for what you want to do? Where do you want to place the
> headers?

Thanks.

I don't _need_ anything, but I think it'd be simpler to
have just 2 directories, one for lustre kernel stuff
and another for lustre uapi stuff.

That applies for LNet and libcfs #includes as well.

To me, ideally, there'd only be 2 #include directories
so that the only used #include styles could become:

#include <linux/lustre/foo.h>
and
#include <uapi/lustre/bar.h>

and that would work regardless of lustre's layout
in staging or elsewhere.
