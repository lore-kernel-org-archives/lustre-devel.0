From: Andreas Dilger <adilger@sun.com>
Date: Sat, 27 Sep 2008 00:15:02 -0600
Subject: [Lustre-devel] Question on iopen_lookup()
In-Reply-To: <48DA6024.5080507@yahoo-inc.com>
References: <48DA6024.5080507@yahoo-inc.com>
Message-ID: <20080927061502.GK10950@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sep 24, 2008  10:43 -0500, Nathan Roberts wrote:
> I've got a quick question on the open_by_inode support that ldiskfs
> is using.
> 
> Since there is only a single magic ".inode" directory inode, AND
> real_lookup() locks the directory mutex when performing the lookup
> of the actual file inode, I'm seeing major contention for this lock.
> The contention makes it impossible for the io scheduler to do anything
> intelligent when there are lots of opens occurring at the same time,
> thus killing small file performance.

We're always interested in improving the metadata performance of
Lustre, and it sounds like you have an interesting patch.

> Since this directory isn't real I don't think there is a reason
> we need to hold the lock during this type of lookup. I added
> a couple of lines to drop and re-aquire this lock around the
> expensive iget() just to see if it removes the bottleneck. My
> read request rate went up from 96 ops/second to 565 so it does
> seem to help.
> 
> Can you see any danger in this type of approach? If it is a completely
> broken approach, any suggestions on how to go about removing this
> contention?

> +       mutex_unlock(&dir->i_mutex);
> 	inode = iget(dir->i_sb, ino);
> +	mutex_lock(&dir->i_mutex);

It looks reasonable to make the change you are proposing.  In fact,
we are also discussing to replace __iopen__ with ext3_fh_to_dentry(),
which calls ext3_nfs_get_inode() internally and it also does iget()
without any locking from looking at these functions and callers.

The benefit of replacing __iopen__ with the ext3_export_ops() is that
we don't have to maintain the twisty mazes of the __iopen__ code in
the face of constantly changing kernel APIs.  This would also be one
step closer to having a patchless server kernel.

We haven't had anyone working on this previously, but if you'd like
to take a crack at it I think we could get both the performance and
reduction in code complexity at the same time.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
