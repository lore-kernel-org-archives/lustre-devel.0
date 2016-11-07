From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 7 Nov 2016 21:50:32 +0000
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: replace uses of
 class_devno_max by MAX_OBD_DEVICES
In-Reply-To: <CAJBmjuh8+WOoNseDFVN248gCJje2iWd2awKu16VP1usK9nQxNg@mail.gmail.com>
References: <cover.1476739569.git.mahfouz.saif.elyazal@gmail.com>
	<4ba436cdccbea6c6dbc631f8cf75cd80f4f9ddb4.1476739569.git.mahfouz.saif.elyazal@gmail.com>
	<D62F1CE1-61E3-43B9-8742-705AF196729C@intel.com>
	<20161025164730.GA27553@waves>
	<8FDBA22B-F6A6-4CA7-B997-41327603E8A9@intel.com>
	<CAJBmjuhuMX-qemMm1t_jhzaMc0HOWGGq66rBBWDU7eEky+-=4A@mail.gmail.com>
	<02D3ADEE-88C0-47EE-9A24-1DF770B17893@intel.com>
	<CAJBmjuh8+WOoNseDFVN248gCJje2iWd2awKu16VP1usK9nQxNg@mail.gmail.com>
Message-ID: <AA65294D-6CA3-4364-992D-B205D7D2F5D8@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Nov 7, 2016, at 02:07, Aya Mahfouz <mahfouz.saif.elyazal@gmail.com> wrote:
> 
> On Mon, Nov 7, 2016 at 6:22 AM, Oleg Drokin <oleg.drokin@intel.com> wrote:
> 
>> On Nov 4, 2016, at 4:37 AM, Aya Mahfouz wrote:
>> 
>> >
>> > On Thu, Nov 3, 2016 at 1:05 AM, Dilger, Andreas <andreas.dilger@intel.com> wrote:
>> > On Oct 25, 2016, at 10:47, Aya Mahfouz <mahfouz.saif.elyazal@gmail.com> wrote:
>> > >
>> > > On Mon, Oct 17, 2016 at 10:38:31PM +0000, Dilger, Andreas wrote:
>> > >> On Oct 17, 2016, at 15:46, Aya Mahfouz <mahfouz.saif.elyazal@gmail.com> wrote:
>> > >>>
>> > >>> class_devno_max is an inline function that returns
>> > >>> MAX_OBD_DEVICES. Replace all calls to the function
>> > >>> by MAX_OBD_DEVICES.
>> > >>
>> > >> Thanks for your patch, but unfortunately it can't be accepted.
>> > >>
>> > >> This function was added in preparation of being able to tune the maximum
>> > >> number of storage devices dynamically, rather than having to hard code it
>> > >> to the maximum possible number of servers that a client can possibly
>> > >> connect to.
>> > >>
>> > >> While the current maximum of 8192 servers has been enough for current
>> > >> filesystems, I'd rather move in the direction of dynamically handling this
>> > >> limit rather than re-introducing a hard-coded constant throughout the code.
>> > >>
>> > > Hello,
>> > >
>> > > I would like to proceed with implementing the function if possible.
>> > > Kindly direct me to some starting pointers.
>> >
>> > Hi Aya,
>> > thanks for offering to look into this.
>> >
>> > There are several ways to approach this problem  to make the allocation
>> > of the obd_devs[] array dynamic.  In most cases, there isn't any value
>> > to dynamically shrink this array, since the filesystem(s) will typically
>> > be mounted until the node is rebooted, and it is only in the tens of KB
>> > size range, so this will not affect ongoing operations, and that simplifies
>> > the implementation.
>> >
>> > The easiest way would be to have a dynamically-sized obd_devs[] array that
>> > is reallocated in class_newdev() in PAGE_SIZE chunks whenever the current
>> > array has no more free slots and copied to the new array, using obd_dev_lock
>> > to protect the array while it is being reallocated and copied.  In most
>> > cases, this would save memory over the static array (not many filesystems
>> > have so many servers), but for the few sites that have 10000+ servers they
>> > don't need to change the source to handle this.  Using libcfs_kvzalloc()
>> > would avoid issues with allocating large chunks of memory.
>> >
>> > There are a few places where obd_devs[] is accessed outside obd_dev_lock
>> > that would need to be fixed now that this array may be changed at runtime.
>> >
>> > A second approach that may scale better is to change obd_devs from an array
>> > to a doubly linked list (using standard list_head helpers).  In many cases
>> > the whole list is seached linearly, and most of the uses of class_num2obd()
>> > are just used to walk that list in order, which could be replaced with
>> > list_for_each_entry() list traversal.  The class_name2dev() function should
>> > be changed to return the pointer to the obd_device structure, and a new
>> > helper class_dev2num() would just return the obd_minor number from the
>> > obd_device struct for the one use in class_resolve_dev_name().  Using a
>> > linked list has the advantage that there is no need to search for free slots
>> > in the array, since devices would be removed from the list when it is freed.
>> >
>> > Cheers, Andreas
>> >
>> > Thanks Andreas! Will start looking into it.
>> 
>> I also would like to point out that Alexey Lyashkov had an implementation
>> of this in http://review.whamcloud.com/347 but it needed to be reverted
>> as it was way too race-prone in the end.
>> I don't know if Alexey ever improved the patch to actually work (at least
>> there was some talk about it), but even if so, the end result was never
>> contributed back to us.
>> 
>> Also please be advised that this is the kind of change that you'll need to
>> have fully functional Lustre setup to verify it works, please let me know
>> if you have any problems setting this up.
>> 
>> Thanks!
> 
> I'm currently trying to understand the concerned parts of the lustre
> code. I will try to setup the lustre file system and take a look at
> Alexey's implementation this week.

I think it makes sense to split this change into a couple of smaller chunks than
what was in the original patch, if the original patch is used at all.  The proposals
I made above are relatively simple to implement and change the existing code to use
the new dynamic array (or list) handling without introducing a lot of complexity.

Then, separately, it would be possible to move the code over from linear list
walking to hash-based device name/UUID lookups, which is where things got more
complex and error-prone.

Having the changes done in a series of smaller and easily understood patches makes
the code much easier to review, easier to test in case a bug is introduced, and
often provides value at each step (i.e. dynamic device count) even if the later
patches are held up or rejected for one reason or another.

Cheers, Andreas
