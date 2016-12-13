From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 12 Dec 2016 16:37:28 -0800
Subject: [lustre-devel] [PATCH v2 5/5] staging: lustre: headers: use
 proper byteorder functions in lustre_idl.h
In-Reply-To: <alpine.LFD.2.20.1612121952371.29051@casper.infradead.org>
References: <1481393161-22623-1-git-send-email-jsimmons@infradead.org>
	<1481393161-22623-6-git-send-email-jsimmons@infradead.org>
	<20161210181649.GB8477@kroah.com>
	<alpine.LFD.2.20.1612121952371.29051@casper.infradead.org>
Message-ID: <20161213003728.GA3052@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, James Simmons <uja.ornl@yahoo.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Dec 12, 2016 at 08:00:02PM +0000, James Simmons wrote:
> 
> > On Sat, Dec 10, 2016 at 01:06:01PM -0500, James Simmons wrote:
> > > In order for lustre_idl.h to be usable for both user
> > > land and kernel space it has to use the proper
> > > byteorder functions.
> > 
> > Why would userspace need/want all of these inline functions?  A uapi
> > header file should just have a the structures that are passed
> > user/kernel and any needed ioctls.  Why would they ever care about
> > strange byte flip functions and a ton of inline functions?
> > 
> > I don't think this is needed, of if it is, I really don't want to see
> > your crazy userspace code...
> 
> Sigh. More cleanups were done based on the idea this was okay. The reason
> this was does was when you look at the headers in include/uapi/linux you
> see a huge number of headers containing a bunch of inline function. To
> an outside project looking to merge their work into the kernel they would
> think this is okay. Hopefully all those broken headers will be cleaned
> up in the near future. Alright I will look to fixing up our tools to 
> handle this requirement. 

But why do you need this type of stuff at all for your userspace code?
Why do they need these "complex" inline functions?  That implies that
there is duplicated logic on both sides of the user/kernel boundry,
shouldn't that be resolved somehow?

thanks,

greg k-h
