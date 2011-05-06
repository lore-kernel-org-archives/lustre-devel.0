From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Fri, 06 May 2011 14:53:31 -0700
Subject: [Lustre-devel] Technical debt in the lustre build system
Message-ID: <4DC46DDB.4000906@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton has been raising awareness about the need to address 
technical debt in the lustre code base.  I think we should also start 
talking about the technical debt in the lustre build system.

Overtime, we've cobbled together a very complex, and very fragile build 
system for lustre.  Every time I work on the build system, my 
frustration level builds and I am tempted to pull the whole thing apart 
and start from scratch.  But when I am thinking more rationally, I admit 
that a more evolutionary approach to improving the build system would be 
more likely to succeed.

So I'd like to start a discussion about where we need to go with the 
build system.  Here are some of the things off the top of my head that 
are problems that need to be addressed, or improvements that I think we 
should make.

1) The recursive configure system should be removed.

Each system that requires its own build system should be a standalone 
package.  Each standalone package should have proper Requires:, 
BuildRequires:, Provides:, etc. in the .spec file for rpm.  Appropriate 
equivalents should be used in other packaging systems (deb).

ldiskfs is a good candidate for this.  With the changes to support 
multiple backend filesystems, making the backends separate packages 
makes even more sense than it did in the past.  In fact, LLNL has 
already packaged ldiskfs separately for 2.1.  It would be great if the 
rest of the community adopted this approach in a future release.

I am guessing that the snmp directory could easily be its own package as 
well.

Lets identify more things like that.

2) Installed files need serious cleanup and reorganization.  Case in 
point, the main lustre package installs this file:

   /usr/bin/config.sh

This pretty much wins the lifetime award for Poorly Named Command In A 
Standard Path Location.  There are many others such as obdfilter-survey, 
ost-survey, parse-ior, plot-obdfilter, etc. that are clearly useful 
testing tools, but inappropriate for the main lustre rpm package.

3) Remove old build system tools dealing with CVS or Subversion 
repositories.  We've moved to git, and it is clearly superior.  We are 
not going back.  It is time to remove the cruft.

4) make_META.pl -> version_tag.pl.  Why is make_META.pl part of the 
build system and just a symlink to version_tag.pl?  I don't understand 
the rationale on this one.  Mighty confusing when you need to fix a bug 
in make_META.pl, but no file named make_META.pl exists in your source tree.

5) Need to keep in mind that third parties will be building this, and 
will need the flexibility to have their own tags and versioning schemes. 
  We can partly do this now, but it needs improvement.

Some of the code to check git version numbers and tags and such seems 
like it was well intentioned, but just adds too much complexity to an 
already complex problem.  Lets look into ways to simplify this.

6) The lustre.spec file.

Lets face it, rpm's spec language is just awful.  But it is what we are 
stuck with for most of our platforms, so we need to figure out how to 
live with it.  Lustre's spec file is a bit of a mess now, and pretty 
difficult for those of us downstream to use unmodified.  Some of the 
previous suggestions will naturally improve the state of the spec file, 
but additional improvements are needed.  I think we should take another 
look at the decision to parse --with-linux and --with-linux-objs out of 
%configure_args.  It just makes the interactions between various rpm 
variables and configure arguments too complex, in my opinion.

I think that we can take some inspiration here from Brian Behlendorf's 
zfs-modules.spec.in file in his ZFS repo:

   https://github.com/behlendorf/zfs

Brian has gone to great lengths to make ZFS buildable under just about 
every Linux distro under the sun, and I still am able to understand his 
spec file.  I can't say the same for Lustre's spec file, and lustre 
doesn't build nearly as cleanly.

Grantly, lustre is a bit more complex in ways...but by splitting the 
code into multiple projects I think we can reduce the spec file complexity.

7) build/lbuild-*

What is this stuff?  Does anyone outside of the core CFS/Sun/Oracle/etc. 
team use this?  Seriously, if you do, please speak up.

I know that LLNL has never used it.  Frankly, I think it should be 
removed from the main Lustre tree.  My impression, from a brief skimming 
of the files, is that they are the automated build system that upstream 
has used to generate kernel packages, lustre packages, and maybe IB 
packages.

LLNL uses an automated build environment based on buildbot that builds 
lustre and all of our other packages under a chroot environment 
individually created for each package by "mock".  It contains only the 
rpms needed by the package, which enforces that we have to have our spec 
file dependencies correct (another reason why the lustre.spec often 
doesn't work for us).

That is a bit of a digression, but my point is this: we probably all 
have our own build systems to contend with.  Those scripts shouldn't be 
part of the main lustre tree.  They should be a separate package, or 
just Whamcloud's internal scripts if no one else is using them.

8) Lustre .src.rpm should be rebuildable.  It is now, more-or-less, but 
could use improvement.

So where do we go from here?  I think we should set up a wiki page to 
plan the overhaul, and start opening bugs to track individual changes 
that need to be made.

Make a large overhaul for 2.1 is out of the question, but perhaps we can 
make many of the changes in the next release.

Chris
