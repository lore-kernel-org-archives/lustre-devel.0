From: Darrick J. Wong <darrick.wong@oracle.com>
Date: Mon, 26 Feb 2018 10:08:49 -0800
Subject: [lustre-devel] [e2fsprogs PATCH] tune2fs: don't recover journal
 if device is busy.
In-Reply-To: <20180224222352.GC14111@thunk.org>
References: <871shrrok4.fsf@notabene.neil.brown.name>
 <20180212021609.GA5204@magnolia> <20180224222352.GC14111@thunk.org>
Message-ID: <20180226180849.GA19295@magnolia>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Cc: linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre <lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org>

On Sat, Feb 24, 2018 at 05:23:52PM -0500, Theodore Ts'o wrote:
> On Sun, Feb 11, 2018 at 06:16:09PM -0800, Darrick J. Wong wrote:
> > > Note: it seems wrong to recover the journal *after* making
> > > changes to the superblock - there is a good chance that
> > > recovering the journal will over-write those changes.
> > > This is what was happening that lead me to this problem.
> > > Shouldn't journal recovery happen *first*??
> > 
> > Yes.  Oops. :/
> > 
> > This whole hunk ought to move up to be right after
> > ext2fs_check_if_mounted, I think.
> 
> After I did that, the test t_replay_and_set started failing.  The
> problem is that the test deliberately corrupts all of the inode and
> block bitmaps by writing bogus journal entries.  When tune2fs replays
> the journal, it ends up smashing the inode and block bitmaps; but then
> when it tries to rewrite checksums, the fact that inode bitmap is
> completely zeroed out means all of the inode entries are also cleared
> out.   Oops!
> 
> This normally isn't supposed to happen because check_fsck_needed() is
> not supposed to allow us to do dangerous things that require rewriting
> checksums unless the file system is freshly checked.
> 
> But the way the test was constructed the superblock's last mount time
> is still 0, since the file system was never mounted.  By definition,
> though, if there is a journal to be replayed, the file system has been
> mounted, and hence must be checked.  Once fixed I this to force
> s_lastcheck to be always less than s_mtimea after replaying the
> journal, then the t_replay_and_set test would fail because it's not
> safe to run "tune2fs -O ^metadata_csum" without running e2fsck first.
> 
> So I'll change the test to set the file system label instead doing
> something more dangerous like clear the metadata checksum feature.
> Was there someone who really wanted to be able to execute "tune2fs -O
> ^metadata_csum" on a file system with a dirty journal w/o running
> e2fsck first?

No, I didn't have a specific user in mind.  Frankly I doubt there will
be very many people who want to turn *off* that feature, but for those
who do so to a dirty fs we could replay the journal first.

(Though let's be honest, if you're going to tune2fs you really ought to
e2fsck before just to make sure the fs is ok...)

--D

> 
> 						- Ted
