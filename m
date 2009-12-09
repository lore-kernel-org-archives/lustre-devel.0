From: Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
Date: Wed, 09 Dec 2009 08:16:49 +0300
Subject: [Lustre-devel] loadgen improvements
In-Reply-To: <5250C925-EDB4-48FA-AD3C-AC37B212BB2B@sun.com>
References: <3ed212d00912050521l530cefc4oc6c44afce48faaa@mail.gmail.com>
	<5250C925-EDB4-48FA-AD3C-AC37B212BB2B@sun.com>
Message-ID: <1260335809.9521.115.camel@berloga.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Andreas,

> 
> > However, these days it has number of issues:
> > 1. Wrong stack size for threads, that results in segfault (find
the  
> > patch in attachment);
> > 2. Little locking issues (push_kid() function);
> > 3. Absence of striping functionality, it only may create load on
one  
> > OST/ECHO server.
> 
> Can you please file a bug for this, and attach this patch and later  
> ones there.  That will ensure that it follows the proper inspection  
> and testing process.
Sure, but looks this will be complete rewrite loadgen.
Reasons for that - loadgen should be use jt functions to set,get lprocfs
data, should be add LOV targets into LOV instance.


> > Let's discuss these matters. The way we're going to implement this  
> > may be roughly expressed as follows:
> >
> > 1. Attach to LOV device in loadgen, using "device" command. To do
so  
> > we need to construct new LOV instance, used by loadgen only, as we  
> > cannot use LOV instance used by LLITE. This requires changes to  
> > handling function for command "device". It should accept more than  
> > one OST target;
> 
> This sounds reasonable.  It might be useful to support the wildcard  
> specification of OSTs like "lustre-OST00[0-30]" or "lustre- 
> OST00[0,3,6,9].  Some of that functionality already exists in lustre/ 
> utils/nidlist.c.
As we need fully setup lustre stack to testing, we can't use willcard in
'device' command, because we don't have access to MGS at this case and
don't have info about all OST tagets in cluster.
But we can use this in 'pool' command.

> > 2. Stripe size and stripe count of new LOV instance should also be  
> > specified while constructing it using "device" command;
> 
> It probably makes sense to have this specified with a separate  
> command, so that these parameters can be changed without having to  
> tear down the devices and recreate them just to change the striping,  
> and it avoids overloading the "device" command (which will soon
become  
> much more complex by allowing many OSTs to be specified).


in first we need call many "device" commands - which add linkage between
UUID and NID.

second step we define OST pool for each workload pattern, this can be
done via new added command 
>>>> pool $name $coma_sepated_OST_uuid
this command used to make LOV_ADD_TARGET commands, but later can be
translated into real OST pool, if need. Main goals of this, add
possibility to use different OST's in different LOV instance.


next step is define workload pattern. currently LoadGen is support only
write, or read command - this translated to obd_brw() or obd_brw_async.
But echo client have support for 3 types of IO.
1) simulate obd_brw/obd_brw_async.
2) simulate obd_queue_async_page()
3) looks direct connect to obdfilter to use obd_prep() & obd_commit()
calls.

Also we need extend this pattern to use OST pool and striping
parameters.
This can be something similar as
>>> pattern $name $pool_name $operation [$stripe_size [$stripe_count]]
where 
name - is pattern name
pool_name - is name of OST pools assigned to this pattern
operation - is one of READ or WRITE.
stripe_size - if set, workload need to setup LOV and add linkage between
LOV and OSC targets, and separate single operation to stripes.
stripe_count - if set, workload should be use for only part of OST pool
to each echo object.

next stage is prepare clients.
In this stage we should be send obd_connect to echo client and wait
until all osc targets is connected (via send obd_statfs() or something
similar).
To start clients we can uses:
>>>>  clients $name $count $workload_name [shared]
where 
name - is client group name
count - is client's count in that group
workload_name - is name of workload parameters.
shared - if set, clients in this pattern is share single OSC or LOV
target. if don't set - each worker have own lustre stack.  
At this stage we also create echo objects with requested LSM for each
client.

final step is spawn one thread for one client and client read own
pattern to call echo client obd IOCTL to start load.


-- 
Alexey Lyashkov <alexey.lyashkov@clusterstor.com>
ClusterStor
