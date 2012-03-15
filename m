From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 14 Mar 2012 18:31:29 -0600
Subject: [Lustre-devel] Lustre and cross-platform portability
Message-ID: <5609A4E0-2356-400F-9D53-F71B7007338C@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Whamcloud and EMC are jointly investigating how to be able to contribute the Lustre client code into the upstream Linux kernel.

As a prerequisite to this, EMC is working to clean up the Lustre client code to better match the kernel coding style, and one of the anticipated major obstacles to upstream kernel submission is the heavy use of code abstraction via libcfs for portability to other operating systems (most notably MacOS and WinNT, but also for liblustre, and potentially *BSD).

I have no information that the WinNT project will ever be released by Oracle, and as yet there has not been any code released from the MacOS port, so the libcfs portability layer is potentially exacting a high cost in code maintenance and complexity (CLIO being a prime example) for no apparent benefit.  Similarly, the liblustre client needs a portability layer for userspace, and suffers from the same apparent lack of interest or users.

I'd like to get some feedback from the Lustre community about removing the libcfs abstraction entirely, or possibly restructuring it to look like the Linux kernel API, and having the other platforms code against it as a Linux portability layer, like ZFS on Linux uses the Solaris Portability Layer (SPL) to avoid changing the core ZFS code.  A related topic is whether it would be better to replace all cfs_* functions with standard Linux kernel functions en-masse, or migrate away from cfs_* functions slowly?

Also, we're planning on deprecating the liblustre client code, due to lack of interest/usage.  The current code is in disrepair, and we've been keeping it around for years without any benefit, and while I was one of the strongest advocates for keeping it in our back pocket in case of future needs, I don't see that materializing in the future.

The liblustre code would be left in the tree for now, in case someone from the community is interested to get it working and maintain it, and it may be updated on a best effort basis.  If nobody steps forward to do this work, the liblustre code would be deleted from the development branch in a year or so.


Unfortunately, after starting this thread, I may not be able to reply to questions in a timely manner due to vacation.  I look forward to a thread that concludes with unanimous agreement from all parties. :-)

Cheers, Andreas
--
Andreas Dilger                       Whamcloud, Inc.
Principal Lustre Engineer            http://www.whamcloud.com/
