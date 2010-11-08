From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Mon, 8 Nov 2010 16:26:21 -0700
Subject: [Lustre-devel] releasing BKL in lustre_fill_super
In-Reply-To: <AANLkTi=Ymq8NGgLnVx+rj0U-9nOqV0qeB7Lhumay7_Pk@mail.gmail.com>
References: <AANLkTinN5dP6KOqE3ZEo2ZKWxo_GJesAN5dvPFyVXc7c@mail.gmail.com>
	<53B6B788-B146-45B9-9FAB-F3F4C163B1B3@dilger.ca>
	<B0280D0B-7D61-48C0-99AD-CA45F5DD70A9@ddn.com>
	<AANLkTi=Ymq8NGgLnVx+rj0U-9nOqV0qeB7Lhumay7_Pk@mail.gmail.com>
Message-ID: <AC0576E0-89E6-47C1-8739-ADD0B6C5D2AC@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-11-08, at 15:16, Jeremy Filizetti wrote:
> I've had a chance to take a longer look at this and I think I was wrong about the BKL.  I still don't see where it would be getting released but the problem appears to be that all OBD's are using the same MGC from a server.
>  
> In server_start_targets, server_mgc_set_fs acquires the cl_mgc_sem, holds it through lustre_process_log and releases with server_mgc_clear_fs after that.  As a result all of our mounts that are started at the same time are waiting for the cl_mgc_sem semaphore.  And each OBD has to process it's llog one at a time.  When you have OSTs near capacity like bug 18456 the first write when processing the llog can take minutes to complete.
>  
> I don't see any easy way to fix this because they are all using the same sb->lsi->lsi_mgc.  I was thinking maybe some of these structures could just modify a copy of that data instead of the actual structure itself but there are so many functions called its hard to see if anything would be using it.
>  
> Any ideas for a way to work around this?

The first thing I always think about when seeing a problem like this is not "how to reduce this contention" but "do we need to be doing this at all"?

Without having looked at that code in a long time, I'm having a hard time thinking why the OST needs to allocate a new block for the config during mount.  It is probably worthwhile to investigate why this is happening in the first place, and possibly just eliminating useless work, rather than making it slightly less slow.

Unfortunately, I don't have the bandwidth to look at this, but maybe Nathan or someone with more familiarity of the config code can chime in.

> Jeremy 
> On Wed, Nov 3, 2010 at 11:57 AM, Ashley Pittman <apittman@ddn.com> wrote:
> 
> On 2 Nov 2010, at 07:40, Andreas Dilger wrote:
> 
> > On 2010-10-28, at 21:07, Jeremy Filizetti wrote:
> >> I've seen a lot of issues with mounting all of our OSTs on an OSS taking an excessive amount of time.  Most of the individual OST mount time was related to bug 18456, but we still see mount times take minutes per OST with the relevant patches.  At mount time the llog does a small write which ends up scanning nearly our entire 7+ TB OSTs to find the desired block and complete the write.
> >>
> >> To reduce startup time mounting multiple OSTs simultaneously would help, but during that process it looks like the code path is still holding the big kernel lock from the mount system call.  During that time all other mount commands are in an uninterruptible sleep (D state).  Based on the discussions from bug 23790 it doesn't appear that Lustre relies on the BKL so would it be reasonable to call unlock_kernel in lustre_fill_super or at least before lustre_start_mgc and lock it again before the return so multiple OSTs could be mounting at the same time?  I think the same thing would apply to unmounting but I haven't looked at the code path there.
> >
> > IIRC, the BKL is held at mount time to avoid potential races with mounting the same device multiple times.  However, the risk of this is pretty small, and can be controlled on an OSS, which has limited access.  Also, this code is being removed in newer kernels, as I don't think it is needed by most filesystems.
> >
> > I _think_ it should be OK, but YMMV.
> 
> I've been thinking about this and can't make up my mind on if it's a good idea or not, we often see mount times in the ten minute region so anything we can do to speed them up is a good thing, I find it hard to believe the core kernel mount code would accept you doing this behind their back though and I'd be surprised if it worked.
> 
> Then again - when we were discussing this yesterday is the mount command *really* holding the BKL for the entire duration?  Surely if this lock is being held for minutes we'd notice this in other ways because other kernel paths that require this lock would block?
> 
> Ashley.
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel


Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
