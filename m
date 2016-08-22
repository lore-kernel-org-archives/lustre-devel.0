From: Joe Perches <joe@perches.com>
Date: Mon, 22 Aug 2016 10:55:42 -0700
Subject: [lustre-devel] [PATCH 0/7] staging: lustre: last missing
	patches for lustre 2.6
In-Reply-To: <alpine.LFD.2.20.1608221810590.9872@casper.infradead.org>
References: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
	<1471631966.3893.29.camel@perches.com>
	<alpine.LFD.2.20.1608192007420.7759@casper.infradead.org>
	<1471636905.3893.40.camel@perches.com>
	<alpine.LFD.2.20.1608221810590.9872@casper.infradead.org>
Message-ID: <1471888542.3746.70.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, 2016-08-22 at 18:41 +0100, James Simmons wrote:
> On Fri, 2016-08-19 at 20:44 +0100, James Simmons wrote:

Hi again James.

> > I don't _need_ anything, but I think it'd be simpler to
> > have just 2 directories, one for lustre kernel stuff
> > and another for lustre uapi stuff.
> > 
> > That applies for LNet and libcfs #includes as well.
> > 
> > To me, ideally, there'd only be 2 #include directories
> > so that the only used #include styles could become:
> > 
> > #include 
> > and
> > #include 
> > 
> > and that would work regardless of lustre's layout
> > in staging or elsewhere.
> I didn't expect this to be requested at this time. I thought this would be?
> addressed just before we left staging.

Sooner is better to me, but that's up to you all.

> I had to ponder the impact of
> this change since this affects our userland utilities as well. Moving
> the staging/lustre/lustre/include/* to include/linux/lustre is pretty
> straight forward for the internal kernel headers.
> 
> The issues is that we still have entanglement issues with some of our uapi?
> headers with internals of the kernel leaking to userland.

Identifying the u_int_<size> and __u<size> types in the code
by userland/kernel uses could be done more easily after any
#include uapi/kernel separation is done.
> Would that be acceptable?

That's not for me to decide really.
It's not an immediate or even necessary want.
It's just a code reading convenience to me.


> This Wednsday we have a lustre community conference call were we discuss
> upstream issues. This will need to be discussed.??

Enjoy.
