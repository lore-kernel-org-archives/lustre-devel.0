From: Ashley Pittman <apittman@ddn.com>
Date: Thu, 12 May 2011 01:58:24 -0700
Subject: [Lustre-devel] Technical debt in the lustre build system
In-Reply-To: <4DC46DDB.4000906@llnl.gov>
References: <4DC46DDB.4000906@llnl.gov>
Message-ID: <27CC7301-CA70-4AB6-8AB0-4302637B0367@ddn.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On 6 May 2011, at 23:53, Christopher J. Morrone wrote:
> 2) Installed files need serious cleanup and reorganization.  Case in 
> point, the main lustre package installs this file:
> 
>   /usr/bin/config.sh
> 
> This pretty much wins the lifetime award for Poorly Named Command In A 
> Standard Path Location.  There are many others such as obdfilter-survey, 
> ost-survey, parse-ior, plot-obdfilter, etc. that are clearly useful 
> testing tools, but inappropriate for the main lustre rpm package.

You could argue that this is a separate issue from the build but I can see it'd be easier to fix them both at the same time.

> 5) Need to keep in mind that third parties will be building this, and 
> will need the flexibility to have their own tags and versioning schemes. 
>  We can partly do this now, but it needs improvement.

We rebuild Lustre and add our own tag to the build, if it's not possible to add a tag to the build on the command line we'll need to patch it ourselves.

> 7) build/lbuild-*
> 
> What is this stuff?  Does anyone outside of the core CFS/Sun/Oracle/etc. 
> team use this?  Seriously, if you do, please speak up.

> I know that LLNL has never used it.  Frankly, I think it should be 
> removed from the main Lustre tree.  My impression, from a brief skimming 
> of the files, is that they are the automated build system that upstream 
> has used to generate kernel packages, lustre packages, and maybe IB 
> packages.

We use this right now.  We are not tied to it however we need some of the functionality it provides so if we move away from it we'll have to find another way.

> That is a bit of a digression, but my point is this: we probably all 
> have our own build systems to contend with.  Those scripts shouldn't be 
> part of the main lustre tree.  They should be a separate package, or 
> just Whamcloud's internal scripts if no one else is using them.

We'd be happy to maintain our own if it meant the central tree could be cleaner and easier to use for people using the stock release.

> So where do we go from here?

10)

One of the things that bugs me is that currently we build and distribute a new kernel for each and every update when in theory we could re-use the kernel and only update the modules 90% of the time.  As a background to this we maintain our list of patches to Lustre with quilt and for any given commit there is no way that I know of to tell if the change impacts the kernel patches or just the module/userspace.  As a result the only safe thing to do is to build a whole new kernel each and every time.  Actually the cost of this is pretty low as Lustre runs on dedicated machines so rebooting during updates is not an issue.

One thing I changed at Quadrics where we had a similar problem was to separate the kernel patches from the kernel modules into different "packages" and maintain, distribute, and update them as separate bits of software.  This had the added benefit of making it obvious when people were patching the kernel further which reduced the incidence of this and meant we put more thought into changes.  I suspect this wouldn't work for Lustre as it's more intrusive into the kernel source but I'd welcome ideas for solving the do-I-update-the-kernel-or-not problem.

Ashley.
