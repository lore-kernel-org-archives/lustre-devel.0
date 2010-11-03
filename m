From: Ashley Pittman <apittman@ddn.com>
Date: Wed, 3 Nov 2010 08:57:53 -0700
Subject: [Lustre-devel] releasing BKL in lustre_fill_super
In-Reply-To: <53B6B788-B146-45B9-9FAB-F3F4C163B1B3@dilger.ca>
References: <AANLkTinN5dP6KOqE3ZEo2ZKWxo_GJesAN5dvPFyVXc7c@mail.gmail.com>
	<53B6B788-B146-45B9-9FAB-F3F4C163B1B3@dilger.ca>
Message-ID: <B0280D0B-7D61-48C0-99AD-CA45F5DD70A9@ddn.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On 2 Nov 2010, at 07:40, Andreas Dilger wrote:

> On 2010-10-28, at 21:07, Jeremy Filizetti wrote:
>> I've seen a lot of issues with mounting all of our OSTs on an OSS taking an excessive amount of time.  Most of the individual OST mount time was related to bug 18456, but we still see mount times take minutes per OST with the relevant patches.  At mount time the llog does a small write which ends up scanning nearly our entire 7+ TB OSTs to find the desired block and complete the write.
>> 
>> To reduce startup time mounting multiple OSTs simultaneously would help, but during that process it looks like the code path is still holding the big kernel lock from the mount system call.  During that time all other mount commands are in an uninterruptible sleep (D state).  Based on the discussions from bug 23790 it doesn't appear that Lustre relies on the BKL so would it be reasonable to call unlock_kernel in lustre_fill_super or at least before lustre_start_mgc and lock it again before the return so multiple OSTs could be mounting at the same time?  I think the same thing would apply to unmounting but I haven't looked at the code path there.
> 
> IIRC, the BKL is held at mount time to avoid potential races with mounting the same device multiple times.  However, the risk of this is pretty small, and can be controlled on an OSS, which has limited access.  Also, this code is being removed in newer kernels, as I don't think it is needed by most filesystems.
> 
> I _think_ it should be OK, but YMMV.

I've been thinking about this and can't make up my mind on if it's a good idea or not, we often see mount times in the ten minute region so anything we can do to speed them up is a good thing, I find it hard to believe the core kernel mount code would accept you doing this behind their back though and I'd be surprised if it worked.

Then again - when we were discussing this yesterday is the mount command *really* holding the BKL for the entire duration?  Surely if this lock is being held for minutes we'd notice this in other ways because other kernel paths that require this lock would block?

Ashley.
