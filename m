From: Jeremy Filizetti <jeremy.filizetti@gmail.com>
Date: Wed, 3 Nov 2010 16:51:42 -0400
Subject: [Lustre-devel] releasing BKL in lustre_fill_super
In-Reply-To: <B0280D0B-7D61-48C0-99AD-CA45F5DD70A9@ddn.com>
References: <AANLkTinN5dP6KOqE3ZEo2ZKWxo_GJesAN5dvPFyVXc7c@mail.gmail.com>
	<53B6B788-B146-45B9-9FAB-F3F4C163B1B3@dilger.ca>
	<B0280D0B-7D61-48C0-99AD-CA45F5DD70A9@ddn.com>
Message-ID: <AANLkTi=kTAXoR1T8sXDruESDWU0TJOQqoC=WLypBPnPL@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Are you seeing individual OST mount times in the 10 minute region or for all
OSTs?

Releasing the lock is more common then you think.  Both ext3, ext4 release
the lock in their ext[34]_fill_super and reacquire before exiting.  So when
Lustre does the pre mount it gets released, and when it does the real mount
for ldiskfs, but after that during that first llog write when the buddy
allocator is initializing I don't see where it can be getting released.  I
was going to try to confirm things 100% with systemtap but our the version I
have doesn't seem to pick up the lustre modules (or any additionallly added
ones for that matter).  I don't have any easy way to upgrade it either.

Jeremy



> I've been thinking about this and can't make up my mind on if it's a good
> idea or not, we often see mount times in the ten minute region so anything
> we can do to speed them up is a good thing, I find it hard to believe the
> core kernel mount code would accept you doing this behind their back though
> and I'd be surprised if it worked.
>
> Then again - when we were discussing this yesterday is the mount command
> *really* holding the BKL for the entire duration?  Surely if this lock is
> being held for minutes we'd notice this in other ways because other kernel
> paths that require this lock would block?
>
> Ashley.
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20101103/18bd4387/attachment.htm>
