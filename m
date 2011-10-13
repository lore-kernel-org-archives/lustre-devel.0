From: Prakash Surya <surya1@llnl.gov>
Date: Thu, 13 Oct 2011 08:41:05 -0700
Subject: [Lustre-devel] Moving ldiskfs external to the Lustre tree
In-Reply-To: <2B361165-F4ED-4339-BA05-D216AE62A4AC@whamcloud.com>
References: <4E960A40.9040509@llnl.gov>
	<2B361165-F4ED-4339-BA05-D216AE62A4AC@whamcloud.com>
Message-ID: <20111013154105.GL28548@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Oct 12, 2011 at 07:05:51PM -0700, Andreas Dilger wrote:
> Chris,
> I'm not against this in principle, but I think it may be more difficult to actually implement before the OSD changes from Orion are landed to master.  In the past we also thought about making ldiskfs as a separate package, before ext4 started in the kernel. 
> 
> I've seen Prakash working on those patches but will not have time to look at them until at least next week. 
> 
> Are those patches against the master branch or against Orion?  Also, what kernels are supported?

The patches for Lustre are against master. I believe our plan is to
have the patches landed and working on master, before we officially
integrate them into Orion.

As far as supported kernels, I've tried to keep that consistent with
what is already supported; although I admit most testing so far has
been done on RHEL.

What kernels are officially supported by Whamcloud? What kernels does it
need to support?

> 
> Cheers, Andreas
> 
> On 2011-10-12, at 3:44 PM, "Christopher J. Morrone" <morrone2@llnl.gov> wrote:
> 
> > We would like to see the ldiskfs tree removed from the lustre tree and 
> > made an independent package.  I have been floating this idea 
> > unofficially for a while, but I would like to now officially propose 
> > this for Lustre 2.2.
> > 
> > With the OBD changes that are taking place on the Orion branch, we want 
> > to make lustre be able to use any of a number of backend filesystems. 
> > The current tree and configure tools make it very hard to build without 
> > ldiskfs (instead using zfs, btrfs, or something we haven't thought of 
> > yet).  As part of cleaning that up, moving ldiskfs external to lustre 
> > will help ensure that we don't have unnecessary dependencies crop up in 
> > the future.
> > 
> > We have created an external package of the ldiskfs tree and put it up on 
> > github:
> > 
> >  https://github.com/chaos/ldiskfs
> > 
> > To use the new external ldiskfs package with lustre, you will also need 
> > a few patches to lustre itself.  There are links to the patches in this 
> > jira ticket:
> > 
> >  http://jira.whamcloud.com/browse/LU-723
> > 
> > On a RHEL system, ldiskfs has a build dependency on the kernel-debuginfo 
> > packages by default.  That is where we find the ext4 source code.
> > 
> > Building should be fairly straight forward.  Build and install ldiskfs 
> > (in particular the lustre-ldiskfs-devel package), and then build lustre. 
> > The main new change to lustre is the addition of the configure option 
> > "--with-ldiskfs-devel".  On a RHEL system if you have the 
> > lustre-ldiskfs-devel package installed, you won't need to give a path.
> > 
> > Note that we have not yet removed the in-tree ldiskfs.  Our first step 
> > was to get this working.  Once this is accepted, we will be happy to 
> > submit the patches to remove lustre's copy of ldiskfs and generally 
> > clean up lustre's autoconf checks involving ldiskfs.
> > 
> > We attempted to keep the changes minimal, so we didn't change the name 
> > of the ldiskfs rpm packages.  But we think is would be nice to change 
> > the name from "lustre-ldiskfs" to simply "ldiskfs".  If we want to make 
> > that change, now is the time to do it.
> > 
> > Chris
> > 
> > _______________________________________________
> > Lustre-devel mailing list
> > Lustre-devel at lists.lustre.org
> > http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel

-- 
Cheers,
Prakash
