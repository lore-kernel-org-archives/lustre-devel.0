From: Andreas Dilger <adilger@sun.com>
Date: Tue, 17 Jun 2008 11:10:59 -0600
Subject: [Lustre-devel] maximum MDT inode count
Message-ID: <20080617171058.GF3726@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

For future filesystem compatibility, we are wondering if there are any
Lustre MDT filesystems in existence that have 2B or more total inodes?

This is fairly unlikely, because it would require an MDT filesystem
that is > 8TB in size (which isn't even supported yet) and/or has been
formatted with specific options to increase the total number of inodes.

This can be checked with "dumpe2fs -h /dev/{mdtdev} | grep 'Inode count'"
on the MDT.  


If there are issues with privacy, please email me directly.  Otherwise,
I think people would be interested to know what the larger MDT sizes
are (even if they aren't as high as 2B inodes).

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
