From: James Simmons <jsimmons@infradead.org>
Date: Fri, 19 Aug 2016 20:44:18 +0100 (BST)
Subject: [lustre-devel] [PATCH 0/7] staging: lustre: last missing
 patches for lustre 2.6
In-Reply-To: <1471631966.3893.29.camel@perches.com>
References: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
	<1471631966.3893.29.camel@perches.com>
Message-ID: <alpine.LFD.2.20.1608192007420.7759@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Fri, 2016-08-19 at 14:07 -0400, James Simmons wrote:
> > Resolved the last remain bug that prevented earlier submission.
> > This covers the remaining patches that were missing from the
> > upstream client that was in Lustre 2.6 except for the work for
> > LU-2484. The work for LU-2484 depends on the stat infrastructure
> > that was removed earlier from the upstream client. That will
> > be done at a later date. In reality this is a pre-2.7 client
> > due to the landing of many patches earlier from lustre 2.7.
> > In any case this is a huge milestone for the lustre client in
> > the linux kernel.
> 
> Couple things:
> 
> 1: I'd like to see the lustre #include files separated into
> ? ?only two internal/external directories akin to the
> ? ?include/linux and include/uapi directories used by linux.
> 
> ? ?Is this a reasonable thing?
> 
> and
> 
> 2: James, you seem to aggregate a lot of lustre patches and
> ? ?yet you are not a listed maintainer. ?Should you be?
 
The second question is easy to answer. At this point yeah I
should be listed as a maintainer. As long as Andreas and Oleg
are okay with that.

For the first question yes it is reasonable and developers
have been working to cleanup and separate out the uapi headers
from the normal kernel headers. For staging/lustre/lustre we
have local headers *_internal.h which only matter for that
particular subdirectory. The rest of the headers are all in

staging/lustre/lustre/include/*

In that directory we have the linux subdirectory. That has
gone away in newer lustre versions so I would need to push
the patch to remove it. The other directory

staging/lustre/lustre/include/lustre/*

contains all our uapi headers like lustre_user.h and lustre_idl.h.
Well that is not entirely correct. We still have uapi headers
like uapi_kernelcomm.h one directory up. It just if we change those
I need to update our userland tools as well. I have a patch ready
but I need to push it to our utility branch as well.

The next lot is all the LNet/libcfs stuff. The good news for LNet
the headers have been cleaned up so separating them out is easy.
Well there can always be more improvements. Now libcfs is a bit
messy. The libcfs/linux directory needs to be removed yet. Also
libcfs_debug.h needs to broken up for uapi use.

Thats the run down about where we are at for the headers. Also it
gives you an idea where we are heading. So how do you need this
layed out for what you want to do? Where do you want to place the
headers?
