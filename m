From: D. Marc Stearman <marc@llnl.gov>
Date: Thu, 19 Jun 2008 08:13:42 -0700
Subject: [Lustre-devel] maximum MDT inode count
In-Reply-To: <20080617171058.GF3726@webber.adilger.int>
References: <20080617171058.GF3726@webber.adilger.int>
Message-ID: <03F8D5A8-99C0-4877-BEF2-819D7F24A160@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On our filesystem that was built to support BGL, we have 2B inodes  
with 2T of capacity.

Inode count: 2097315840
Inodes per group: 32768
Inode blocks per group: 4096
Inode size: 512

We explicitly chose this number and put it in the XML when the  
filesystem was built.  Then the users changed their I/O pattern and  
did not end up creating nearly as many files as we estimated.  Since  
then we have created file systems with a smaller number of inodes to  
reduce fsck time.  (Not really an issue as much now, though with the  
fast fsck feature).

-Marc

----
D. Marc Stearman
LC Lustre Administration Lead
marc at llnl.gov
925.423.9670
Pager: 1.888.203.0641



On Jun 17, 2008, at 10:10 AM, Andreas Dilger wrote:

> For future filesystem compatibility, we are wondering if there are any
> Lustre MDT filesystems in existence that have 2B or more total inodes?
>
> This is fairly unlikely, because it would require an MDT filesystem
> that is > 8TB in size (which isn't even supported yet) and/or has been
> formatted with specific options to increase the total number of  
> inodes.
>
> This can be checked with "dumpe2fs -h /dev/{mdtdev} | grep 'Inode  
> count'"
> on the MDT.
>
>
> If there are issues with privacy, please email me directly.   
> Otherwise,
> I think people would be interested to know what the larger MDT sizes
> are (even if they aren't as high as 2B inodes).
>
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
