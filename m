From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 16 Aug 2016 12:53:15 +0200
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: Add include path to
	Makefile
In-Reply-To: <1471295658.4075.117.camel@perches.com>
References: <cover.1471289489.git.joe@perches.com>
	<5f9f49c1e0caeb3b9ee0656b6d922dbaf52a15b7.1471289489.git.joe@perches.com>
	<20160815210420.GA30864@kroah.com>
	<1471295658.4075.117.camel@perches.com>
Message-ID: <20160816105315.GE28337@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Mon, Aug 15, 2016 at 02:14:18PM -0700, Joe Perches wrote:
> On Mon, 2016-08-15 at 23:04 +0200, Greg Kroah-Hartman wrote:
> > On Mon, Aug 15, 2016 at 12:33:23PM -0700, Joe Perches wrote:
> > > Start to rationalize include paths in source code files.
> []
> > > diff --git a/drivers/staging/lustre/Makefile b/drivers/staging/lustre/Makefile
> []
> > > @@ -1,2 +1,5 @@
> > > +subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/include/
> > > +subdir-ccflags-y += -I$(srctree)/drivers/staging/lustre/lustre/include/
> > > +
> > > ?obj-$(CONFIG_LNET)		+= lnet/
> > > ?obj-$(CONFIG_LUSTRE_FS)		+= lustre/
> > This is good, but does this break the subdir make command:
> > 	make M=drivers/staging/lustre/foo_dir/
> > ?
> 
> hmm, yeah, it does. ?Oh well, nevermind for awhile.
> 
> > I remember the last time I tried to clean this up, it took a while...
> 
> It seems like something the build tools should
> handle correctly now, but I'll look at it.

Nah, I think it's fine the way it is.  What's wrong with the "../" type
things in the include directives?  The build system works well with it,
you can build any single module or file correctly, and it's obvious what
the code is including from.

Now you might argue that the lustre code shouldn't have such a mess of
include files like this, and I would totally agree.  I suggest working
on reducing the number of .h files they have, and centralizing them such
that all of these cross-directory includes aren't needed anymore either
in the build directives, or in the .c files.

thanks,

greg k-h
