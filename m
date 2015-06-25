From: Patrick Farrell <paf@cray.com>
Date: Thu, 25 Jun 2015 15:13:16 -0500
Subject: [lustre-devel] Lock ahead v1
In-Reply-To: <91F184C2-54C3-4BB5-B74E-1320C0C12F82@intel.com>
References: <558085B3.1040400@cray.com>
	<D1B0E406.F92B6%andreas.dilger@intel.com>
	<91F184C2-54C3-4BB5-B74E-1320C0C12F82@intel.com>
Message-ID: <558C60DC.6010805@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Jinshan,

That's exactly what I'm suggesting. :)

Andreas,

I think you're asking why is that lock expanded, since there would 
usually be other lock ahead locks - I'll try to draw this out. Pretend a 
file is divided in to equal size extents.  Each letter is a lock, a 
letter with _ _ _ _ indicates a lock on more than one extent.

A single larger lock looks like this:
A _ _ _ _ _ _ _

A set of lock ahead locks looks like this:
A B C D E F G H

I believe you're saying that if, for example, the race on lock E was 
lost, the resulting non lock-ahead lock request would not expand, 
because it would be blocked by F.  That's clearly correct, and wouldn't 
cause any problems for future lock ahead requests.

The suggestion is, essentially, that it might happen for lock H (or 
perhaps the race for F could be lost so badly the I/O wins out over lock 
requests F, G, and H), in which case we get this:

A B C F E F F G H _ _ _ _ _ _ _ _ [... max size]

So lock ahead requests I, J, K, etc are blocked by this lock. 
Eventually, the write corresponding to lock I arrives, and we get this:
.... G H _ _ _ _ _ _ [... max size]
              I
It conflicts with lock H, then we get ([ ] is part of the file with no 
lock):
.... G [  ]  I _ _ _ _ _ _ [... max size]

And then we begin handing the expanded lock back and forth, blocking 
lock ahead all the while.

This is not completely theoretical - With lower lock ahead counts (IE, 
number of locks taken ahead of the I/O), we sometimes saw this behavior 
in our testing.  Our testing showed that turning up the count of locks 
taken ahead makes this less likely, but that drives up lock count, which 
is generally undesirable.

Also, this does not cover the case of someone else reading the full 
file, fx with cat.  In that case, the normal lock expansion followed by 
lock exchange behavior would take over completely.

About causing future problems for the process using that file 
descriptor:  The idea is that this usage is limited to a library, which 
knows it has done something odd to the file descriptor (which will 
certainly cause performance problems for normal I/O).  So, if the 
library wants to do other I/O, it opens a new file descriptor for that 
purpose.

- Patrick

On 06/25/2015 03:33 AM, Xiong, Jinshan wrote:
> If non-lockahead lock is expanded, it will be conflicted with any later enqueue attempt of lockahead locks, therefore lookahead is indeed turned off. Then the other clients will have to enqueue locks for I/O and then most likely take over that expanded lock, and so on. This will make lockahead useless.
>
> Please let me know if I missed something.
>
> Jinshan
>
>> On Jun 24, 2015, at 10:48 PM, Dilger, Andreas <andreas.dilger@intel.com> wrote:
>>
>> Maybe I'm missing something, but it isn't clear why the non-lockahead lock
>> wouldn't conflict with the locks granted by lockahead to prevent lock
>> expansion that cancels the other locks?  That would be my expectation, and
>> would avoid the need to add a separate ioctl to disable lock expansion
>> (which IMHO might cause problems in the future for this process).
>>
>> Cheers, Andreas
>>
>> On 2015/06/16, 2:23 PM, "Patrick Farrell" <paf@cray.com> wrote:
>>
>>> Hello,
>>>
>>> I?ve been hard at work on lock ahead for some time, and there's been a
>>> notable change in the design. (I?m not going to recap lock ahead here ?
>>> If you?d like background, please check out the slides and/or video of my
>>> LUG talk:
>>> http://cdn.opensfs.org/wp-content/uploads/2015/04/Shared-File-Performance-
>>> in-Lustre_Farrell.pdf
>>> ; http://youtu.be/ITfZfV5QzIs )
>>>
>>> I'm emailing here primarily to explain the change for those reviewing
>>> the patch (http://review.whamcloud.com/#/c/13564/).
>>>
>>> It has proved extremely difficult to make blocking asynchronous lock
>>> requests, which I originally wanted. If the lock requests could be
>>> blocking, then they could clear out existing locks on the file. However,
>>> there are a number of problems with asynchronous blocking requests, some
>>> of which I detailed in emails to this list. With help from Jinshan, I
>>> have an idea what to do to fix them, but the changes are significant
>>> and, it turns out, not really necessary for lock ahead.
>>>
>>> Here's why:
>>>
>>> The main problem with non-blocking lock requests is they will not clear
>>> out existing locks, so if there are any on the file, we will not get
>>> lock ahead locks granted. To avoid this situation, we will have the
>>> library take and release a (blocking) group lock when it first opens the
>>> file. This will clear out any existing locks on the file, making it
>>> ?clean? for the lock ahead requests. This (mostly) means we don't need
>>> blocking lock ahead requests.
>>>
>>> The lock ahead writing process for writing out a large file, then, looks
>>> like this:
>>> OPEN, GROUP_LOCK, GROUP_UNLOCK, LOCK_AHEAD (n blocks ahead), WRITE,
>>> WRITE, WRITE ? [track position of writes (IE, number of lock ahead locks
>>> remaining ahead of the IO), when lock ahead count is small?>] LOCK_AHEAD
>>> (n blocks ahead), WRITE, WRITE, WRITE? Etc.
>>>
>>> This also helps keep the lock count manageable, which avoids some
>>> performance issues.
>>>
>>> However, we need one more thing:
>>>
>>> Imagine if lock ahead locks are not created of the IO (due to raciness)
>>> or they are cancelled by a request from a node that is not part of the
>>> collective IO (for example, a user tries to read the file during the
>>> IO). In either case, the lock which results will be expanded normally.
>>> So it's possible for that lock to be extended to cover the rest of the
>>> file, and so it will block future lock ahead requests. That lock will be
>>> cancelled when a read or write request happens in the range covered by
>>> that lock, but that read/write request will be expanded as well - And we
>>> return to handing the lock back and forth between clients.
>>>
>>> The way to avoid this is to turn off lock expansion for anyone who is
>>> supposed to be using lock ahead locks. Their IO requests will normally
>>> use the lock ahead locks provided for them, but if the lock ahead locks
>>> aren't available (for reasons described above), the locks for these
>>> requests will not be expanded.
>>>
>>> This means that losing a race between IO and the lock ahead lock on a
>>> particular lock ahead request (or entire set of lock ahead requests)
>>> will never create a large lock, which would block future lock ahead
>>> requests.
>>>
>>> Additionally, if lock ahead is interrupted by a request from another
>>> client (preventing lock ahead requests by creating a large lock), the
>>> 'real' IO requests from the lock ahead clients will eventually cancel
>>> that large lock. Since the locks for those requests aren't expanded, the
>>> next set of lock ahead requests (which are out ahead of the IO) will work.
>>>
>>> Effectively, this means that if lock ahead is interrupted by a competing
>>> request or if it fails the race to be ready in time, it can avoid
>>> returning to the pathological case.
>>>
>>> Code implementing lock and this other ioctl to disable expansion is up
>>> for review here:
>>> http://review.whamcloud.com/#/c/13564/
>>>
>>> The current version is essentially 'code complete' and ready for review.
>>>
>>> - Patrick Farrell
>>> _______________________________________________
>>> lustre-devel mailing list
>>> lustre-devel at lists.lustre.org
>>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>>>
>>
>> Cheers, Andreas
>> -- 
>> Andreas Dilger
>>
>> Lustre Software Architect
>> Intel High Performance Data Division
>>
>>
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
