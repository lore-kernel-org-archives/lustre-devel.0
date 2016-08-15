From: Joe Perches <joe@perches.com>
Date: Mon, 15 Aug 2016 14:29:17 -0700
Subject: [lustre-devel] Building a subdirectory ignores parent
 subdir-ccflags (was: Re: [PATCH 1/2] staging: lustre: Add include path to
 Makefile)
In-Reply-To: <1471295658.4075.117.camel@perches.com>
References: <cover.1471289489.git.joe@perches.com>
	<5f9f49c1e0caeb3b9ee0656b6d922dbaf52a15b7.1471289489.git.joe@perches.com>
	<20160815210420.GA30864@kroah.com>
	<1471295658.4075.117.camel@perches.com>
Message-ID: <1471296557.4075.127.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Yann E. MORIN" <yann.morin.1998@free.fr>, Michal Marek <mmarek@suse.com>, linux-kbuild <linux-kbuild@vger.kernel.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Mon, 2016-08-15 at 14:14 -0700, Joe Perches wrote:
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
> hmm, yeah, it does. ?Oh well, nevermind for awhile.
> > I remember the last time I tried to clean this up, it took a while...
> It seems like something the build tools should
> handle correctly now, but I'll look at it.

Perhaps making a specific directory should also walk up
any parent directory Makefiles looking for subdir flags.

Is that unreasonable?  Any suggestions?
