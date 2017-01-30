From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jan 2017 00:09:26 +0000 (GMT)
Subject: [lustre-devel] [PATCH] staging: lustre: headers: potential UAPI
	headers
In-Reply-To: <20170121092459.GA29138@kroah.com>
References: <1482167207-22800-1-git-send-email-jsimmons@infradead.org>
	<20170103141248.GA8695@kroah.com>
	<alpine.LFD.2.20.1701162126170.27875@casper.infradead.org>
	<20170117074140.GA19328@kroah.com>
	<alpine.LFD.2.20.1701202331420.11070@casper.infradead.org>
	<20170121092459.GA29138@kroah.com>
Message-ID: <alpine.LFD.2.20.1701292356510.7496@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> > > > > On Mon, Dec 19, 2016 at 12:06:47PM -0500, James Simmons wrote:
> > > > > > Not for landing. This is the purposed UAPI headers
> > > > > > with the removal of unlikely and debugging macros.
> > > > > > This is just for feedback to see if this is acceptable
> > > > > > for the upstream client.
> > > > > > 
> > > > > > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > > > > > ---
> > > > > >  .../lustre/lustre/include/lustre/lustre_fid.h      | 353 +++++++++++++++++++++
> > > > > >  .../lustre/lustre/include/lustre/lustre_ostid.h    | 233 ++++++++++++++
> > > > > 
> > > > > Can you make a lustre "uapi" directory so we can see which files you
> > > > > really want to be UAPI and which you don't as time goes on?
> > > > 
> > > > Where do you want them placed? In uapi/linux/lustre or uapi/lustre. Does
> > > > it matter to you? The below was to forth coming UAPI headers which from
> > > > your response you seem okay with in general.
> > > 
> > > How many .h files are there going to be?  It's just a single filesystem,
> > > shouldn't you just need a single file?  If so, how about
> > > 	drivers/staging/lustre/include/uapi/lustre.h
> > > ?
> > > 
> > > If you really need multiple .h files, put them all in the same uapi/
> > > directory with a lustre_ prefix, you don't need a whole subdir just for
> > > yourself, right?
> > 
> > We have 12 UAPI headers and yes they all begin with lustre_*. Okay I will
> > create a driver/staging/lustre/include/uapi/linux directory and start
> > moving headers there.
> 
> 12 seems like a lot just for a single, tiny, filesystem :)

I bet several lustre sys admins find this funny. Lustre exposes a lot 
of functionality to the applications to help them best optimize their 
behavior. That extra complexity can make admins and even normal users
head spin!!!

> But moving them all to a single directory will see where we can later
> merge them together, sounds like a good plan.

That would be one big header that would be constantly change. BTW we also
have a few headers for LNet as well. One of them is lnetst.h which is for
the LNet testing utility. It would be strange to merge a network 
simulation api into what standard users would use. Lets see once the work
is done. I'm discussing currently with Intel developers the path forward
on this work but it show be done in the near future.
