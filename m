From: Andreas Dilger <adilger@sun.com>
Date: Tue, 08 Dec 2009 23:35:32 -0700
Subject: [Lustre-devel] loadgen improvements
In-Reply-To: <1260335244.9521.114.camel@berloga.shadowland>
References: <3ed212d00912050521l530cefc4oc6c44afce48faaa@mail.gmail.com>
	<5250C925-EDB4-48FA-AD3C-AC37B212BB2B@sun.com>
	<1260335244.9521.114.camel@berloga.shadowland>
Message-ID: <20C3E301-9A42-47D9-A1A7-BA06814D396F@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2009-12-08, at 22:07, Alexey Lyashkov wrote:
> This can be something similar as
>>
>     pattern $name $pool_name $operation [$stripe_size [$stripe_count]]
>
> where
> name - is pattern name
> pool_name - is name of OST pools assigned to this pattern
> operation - is one of READ or WRITE.
> stripe_size - if set, workload need to setup LOV and add linkage  
> between
> LOV and OSC targets, and separate single operation to stripes.
> stripe_count - if set, workload should be use for only part of OST  
> pool
> to each echo object.

Please do not use positional parameters.  That makes it nearly  
impossible to change the input format in the future, or to skip some  
fields and leave them as defaults.  This needs to use getopt() and  
named parameters:

  --pool=pool_name, --stripe_size=N,  --stripe_count=N

> next stage is prepare clients.
> In this stage we should be send obd_connect to echo client and wait
> until all osc targets is connected (via send obd_statfs() or something
> similar).
> To start clients we can uses:
>>
>     clients $name $count $workload_name [shared]
> where
> name - is client group name
> count - is client's count in that group
> workload_name - is name of workload parameters.
> shared - if set, clients in this pattern is share single OSC or LOV
> target. if don't set - each worker have own lustre stack.
> At this stage we also create echo objects with requested LSM for each
> client.

Same as above - please use named parameters instead of positional ones.

It probably also makes sense to look at the functions provided by LST  
(LNET self test) so that we might have these two tools operate in a  
similar manner. LST testing at the LNET level, loadgen testing at the  
OBD/CLIO level.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
