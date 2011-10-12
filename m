From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Wed, 12 Oct 2011 14:44:32 -0700
Subject: [Lustre-devel] Moving ldiskfs external to the Lustre tree
Message-ID: <4E960A40.9040509@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We would like to see the ldiskfs tree removed from the lustre tree and 
made an independent package.  I have been floating this idea 
unofficially for a while, but I would like to now officially propose 
this for Lustre 2.2.

With the OBD changes that are taking place on the Orion branch, we want 
to make lustre be able to use any of a number of backend filesystems. 
The current tree and configure tools make it very hard to build without 
ldiskfs (instead using zfs, btrfs, or something we haven't thought of 
yet).  As part of cleaning that up, moving ldiskfs external to lustre 
will help ensure that we don't have unnecessary dependencies crop up in 
the future.

We have created an external package of the ldiskfs tree and put it up on 
github:

   https://github.com/chaos/ldiskfs

To use the new external ldiskfs package with lustre, you will also need 
a few patches to lustre itself.  There are links to the patches in this 
jira ticket:

   http://jira.whamcloud.com/browse/LU-723

On a RHEL system, ldiskfs has a build dependency on the kernel-debuginfo 
packages by default.  That is where we find the ext4 source code.

Building should be fairly straight forward.  Build and install ldiskfs 
(in particular the lustre-ldiskfs-devel package), and then build lustre. 
  The main new change to lustre is the addition of the configure option 
"--with-ldiskfs-devel".  On a RHEL system if you have the 
lustre-ldiskfs-devel package installed, you won't need to give a path.

Note that we have not yet removed the in-tree ldiskfs.  Our first step 
was to get this working.  Once this is accepted, we will be happy to 
submit the patches to remove lustre's copy of ldiskfs and generally 
clean up lustre's autoconf checks involving ldiskfs.

We attempted to keep the changes minimal, so we didn't change the name 
of the ldiskfs rpm packages.  But we think is would be nice to change 
the name from "lustre-ldiskfs" to simply "ldiskfs".  If we want to make 
that change, now is the time to do it.

Chris
