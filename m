From: Andreas Dilger <adilger@whamcloud.com>
Date: Tue, 7 Jun 2011 13:02:34 -0600
Subject: [Lustre-devel] Orion Landing Plan/Process
References: <4DE7E760.9050201@whamcloud.com>
Message-ID: <D18976AD-64D5-416D-A4F4-B6897C93B4E7@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This (long) email is of primary interest to developers and testers of
Lustre, and is focussed on how to integrate the substantial amount of
development that has been done on the Orion development branch into
the mainline Lustre release branch in a stable manner, without seriously
disrupting other ongoing development projects.

Introduction
============
The Lustre 2.0 release introduced a new Object Storage Device (OSD)
interface, which improves the abstraction of the Lustre IO operations
from the underlying filesystem implementation.  Moving to the new OSD
interface allows Lustre to start using more advanced back-end filesystems
like ZFS, and Btrfs in the future.

For Lustre 2.0, the MDS stack was largely moved over to use the new OSD
interface, but some parts of the MDS code (llogs for distributed recovery
MDS->OST RPCs, etc) are still using the older "obd/lvfs/fsfilt" interface,
which has left unwanted complexity in the code.  As well, none of the
code for the OSS or MGS have been moved to use this new OSD interface,
leaving a large amount of duplicated code within Lustre, and sometimes
confusion for developers about which IO methods were in use for a
particular operation.  Moving everything over to use the OSD interface
will allow this duplicated code to be removed, and facilitates development
projects like Distributed Namespace (formerly CMD), unified targets
(i.e. small files on the MDT), and others in the future.

The Orion project at Whamcloud, in conjunction with LLNL, is focussed
on completing the restructuring of the Lustre code base to use the OSD
interface.  LLNL will begin using the Orion branch for their Sequoia
system (https://asc.llnl.gov/computing_resources/sequoia/) with ZFS
(http://zfsonlinux.org/lustre.html) as the back-end filesystem.  It is
expected that the Orion project will take about a year to complete.

Ongoing Development
===================
The existing Orion codebase represents a significant amount of development
that has already been done to update the Lustre server code to use the
OSD API.  Work is ongoing to complete the transition of the OSS, MGS,
and recovery code to use the OSD interface.

The large amount of change in this branch presents a serious obstacle to
integration of this code into the mainline Lustre codebase.  Directly
landing all of the branch to master would present a significant risk
of destabilizing the master branch.  Even with significant pre-landing
testing on the "orion" branch, it will still only be a fraction of the
different real-world load and environment combinations that are being
tested by different members of the community.  As well, debugging any
problems that appear after a large single landing would be very difficult
and time consuming.

Proposed Landing Process
========================
What we propose is to split the current changes in the Orion branch into
a series of smaller commits to the "master" branch over several months,
each of which is only changing a specific part of the code.  All of the
commits will provide stand-alone functionality, that will be pre-tested
in isolation before landing to meet the quality standards of the master
branch.

The benefits of making a series of independent commits spread over several
months are manyfold:
- each commit can be tested separately, both in advance of landing, and
  after integration, to isolate defects to the specific areas of the code
  that have been changed
- testing can be more extensive and focussed on the code being changed
- defects in smaller changes are easier to find and fix during pre-landing
  testing and are easier to isolate after landing
- in the unlikely case of serious defects appearing after landing, the
  offending patch(es) can be backed out without forcing all of the
  unrelated changes from orion to be backed out as well
- the commits will be isolated to a specific area of code or API, and
  will be grouped by logical change, rather than the more unordered
  sequence of changes and bug fixes from the ongoing development
- spacing major changes over a longer time period it will give other
  developers (both inside and outside Whamcloud) more time to become
  aware of the changes in the Orion branch, and adapt their projects to
  use the changes being made
- landing parts of the orion branch early means less code is developed
  that is in conflict with these changes, and less work will need in
  both the orion and other development branches to merge those changes
- smaller commits can be inspected more easily by developers, hopefully
  getting more eyes on the changes being made, and finding bugs earlier


As isolated changes are being extracted from the orion development branch,
they will be inspected, tested to the standard of the master branch, and
then landed to the master branch.  The orion branch will then be rebased
against the updated master branch, and the landed changes will be removed
from the outstanding changes on orion.  This process is shown in the
attached diagram, and can also be used for larger features unrelated to
the orion branch.

This development and code contribution model has served the Linux kernel
community very well to manage integration of large features.  At this
stage, this email is focussed on raising awareness of these plans within
the Lustre community.  A separate email detailing the plans for landing
specific changes will be sent at a later date.

Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.





-------------- next part --------------
A non-text attachment was scrubbed...
Name: Diagram 1.0.png
Type: image/png
Size: 68288 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110607/0367736e/attachment.png>
-------------- next part --------------



Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
