From: Darrick J. Wong <darrick.wong@oracle.com>
Date: Sun, 11 Feb 2018 18:16:09 -0800
Subject: [lustre-devel] [e2fsprogs PATCH] tune2fs: don't recover journal
 if device is busy.
In-Reply-To: <871shrrok4.fsf@notabene.neil.brown.name>
References: <871shrrok4.fsf@notabene.neil.brown.name>
Message-ID: <20180212021609.GA5204@magnolia>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: tytso@mit.edu, linux-ext4@vger.kernel.org, lustre <lustre-devel@lists.lustre.org>

On Mon, Feb 12, 2018 at 12:20:43PM +1100, NeilBrown wrote:
> 
> tune2fs currently replays the journal if it needs
> recovery and the filesystem isn't mounted.
> 
> The test for "is the filesystem mounted" isn't completely robust.
> Lustre makes use of ext4 filesystems in a way that they are mounted
> without being visible in /proc/mounts or similar.
> This usage can easily be detected by attempting to open the device
> with O_EXCL.  tune2fs already does this and the EXT2_MF_BUSY flag
> is set if open(O_EXCL) fails.
> Several uses other than lustre mounts could cause O_EXCL to fail,
> but in any case it seems unwise to recover the journal when something
> else is keeping the device busy.
> 
> So add an extra test to avoid journal recovery when the device
> is busy.  This fixes some problems with lustre usage.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> 
> --
> Note: it seems wrong to recover the journal *after* making
> changes to the superblock - there is a good chance that
> recovering the journal will over-write those changes.
> This is what was happening that lead me to this problem.
> Shouldn't journal recovery happen *first*??

Yes.  Oops. :/

This whole hunk ought to move up to be right after
ext2fs_check_if_mounted, I think.

As for this patch itself,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D
