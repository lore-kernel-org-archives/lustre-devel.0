From: Andreas Dilger <adilger@sun.com>
Date: Tue, 08 Dec 2009 12:10:52 -0700
Subject: [Lustre-devel] loadgen improvements
In-Reply-To: <3ed212d00912050521l530cefc4oc6c44afce48faaa@mail.gmail.com>
References: <3ed212d00912050521l530cefc4oc6c44afce48faaa@mail.gmail.com>
Message-ID: <5250C925-EDB4-48FA-AD3C-AC37B212BB2B@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Yuriy,

On 2009-12-05, at 06:21, Yuriy Umanets wrote:
> ClusterStor would like to start doing real contributions to Lustre  
> stability and popularity. First off, we would like to improve  
> loadgen utility, written by Nathan Rutman. We think loadgen is a  
> really good tool for testing and what is not less important, it is  
> implemented right way from architecture point of view.

Great.  We look forward to working with you again.

> However, these days it has number of issues:
> 1. Wrong stack size for threads, that results in segfault (find the  
> patch in attachment);
> 2. Little locking issues (push_kid() function);
> 3. Absence of striping functionality, it only may create load on one  
> OST/ECHO server.

Can you please file a bug for this, and attach this patch and later  
ones there.  That will ensure that it follows the proper inspection  
and testing process.

> We plan to add striping functionality to loadgen. General idea is to  
> use LOV module, which already has all the needed code. Loadgen  
> itself and echo_client also have related code, so it seems this  
> functionality was planned anyway, though it's not working currently.  
> Currently an attempt to attach to a LOV results in assertion failures.

Right - Eric and I worked on that some years ago, but it was never  
used fully.  Can you please ensure that you include a test in  
sanity.sh that exercises the functionality you are adding to loadgen,  
as with echo_client in test 180.  More complex load tests should go  
into their own script.

> Let's discuss these matters. The way we're going to implement this  
> may be roughly expressed as follows:
>
> 1. Attach to LOV device in loadgen, using "device" command. To do so  
> we need to construct new LOV instance, used by loadgen only, as we  
> cannot use LOV instance used by LLITE. This requires changes to  
> handling function for command "device". It should accept more than  
> one OST target;

This sounds reasonable.  It might be useful to support the wildcard  
specification of OSTs like "lustre-OST00[0-30]" or "lustre- 
OST00[0,3,6,9].  Some of that functionality already exists in lustre/ 
utils/nidlist.c.

> 2. Stripe size and stripe count of new LOV instance should also be  
> specified while constructing it using "device" command;

It probably makes sense to have this specified with a separate  
command, so that these parameters can be changed without having to  
tear down the devices and recreate them just to change the striping,  
and it avoids overloading the "device" command (which will soon become  
much more complex by allowing many OSTs to be specified).

> 3. Setup of virtual clients should take into account that LOV may be  
> used as a target. In this case attaching dedicated OSCs to created  
> echo_client's is not needed.
>
> 4. In order to be able to run thousands of threads, we need the  
> following:
>  - reasonable stack size for threads;
>  - change 8192 OBD number limit to something more reasonable.

If you are going beyond 8192 OBD devices just for the loadgen usage  
(presumably you need a new LOV device for each thread?) then it would  
make sense to have the obd_devs array be dynamically allocated and  
remove any upper limit on the number of devices.

Most of this work has already been done - all of the access to  
obd_devs[] is localized in lustre/obdclass/genops.c, with the  
exception of the array initialization, and an old  
EXPORT_SYMBOL(obd_devs), which isn't used anymore. The obd_devs[]  
declaration can be made static to genops.c and the initialization  
moved to obd_init_caches(), and then the actual representation of  
obd_devs[] can be changed without affecting the interface.

Note that the index number of the device is still exported to  
userspace, so it isn't possible/practical to simply go with a linked- 
list implementation.  The actual obd_device structures are already  
allocated and freed dynamically, just the master obd_devs[] array is  
static.  Probably a master array of pointers to pages that hold  
segments of the the obd_devs[] array in order is sufficient.  The  
master array will be quite small (1 pointer per 512 obd_devices) and  
can be reallocated under a rwlock, since nothing references it  
directly.  There is no need to be able to shrink the master array.

It would be trivial to also make the obd_types and obd_types_lock  
declarations static to genops.c, and the initialization in  
obd_init_caches() to properly isolate that code as well.

> 5. Load itself is created in the way being currently used - via  
> obd_brw().


Actually, the real code does not use obd_brw() directly anymore, but  
rather obd_brw_async().  I think Nic Henke submitted a patch to change  
that, I'm not sure of the current status of that patch.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
