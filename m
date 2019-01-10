From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 10 Jan 2019 09:10:53 +0000
Subject: [lustre-devel] [PATCH v2 33/33] lustre: update version to 2.9.99
In-Reply-To: <87k1jdi99a.fsf@notabene.neil.brown.name>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
 <1546812868-11794-34-git-send-email-jsimmons@infradead.org>
 <874lakj5ck.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1901080352210.15230@casper.infradead.org>
 <45806D2E-8AAD-48ED-8B14-6D5CC11D824E@whamcloud.com>
 <alpine.LFD.2.21.1901081932010.14458@casper.infradead.org>
 <9BDCA6A9-A826-49A7-9126-BC1DCC96AC1D@whamcloud.com>
 <alpine.LFD.2.21.1901091734180.18138@casper.infradead.org>
 <53F17B0D-5FB3-4B69-B483-7AA4FBCA259B@whamcloud.com>
 <87k1jdi99a.fsf@notabene.neil.brown.name>
Message-ID: <E7AC15BE-1732-4BC7-AF01-2BEACDC06E0C@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 9, 2019, at 18:36, NeilBrown <neilb@suse.com> wrote:
> 
> On Wed, Jan 09 2019, Andreas Dilger wrote:
> 
>> On Jan 9, 2019, at 11:28, James Simmons <jsimmons@infradead.org> wrote:
>>> 
>>>>>> This might be because the upstream Lustre doesn't allow setting
>>>>>> per-process JobID via environment variable, only as a single
>>>>>> per-node value.  The real unfortunate part is that the "get JobID
>>>>>> from environment" actually works for every reasonable architecture
>>>>>> (even the one which was originally broken fixed it), but it got
>>>>>> yanked anyway.  This is actually one of the features of Lustre that
>>>>>> lots of HPC sites like to use, since it allows them to track on the
>>>>>> servers which users/jobs/processes on the client are doing IO.
>>>>> 
>>>>> To give background for Neil see thread:
>>>>> 
>>>>> https://lore.kernel.org/patchwork/patch/416846
>>>>> 
>>>>> In this case I do agree with Greg. The latest jobid does implement an
>>>>> upcall and upcalls don't play niece with containers. Their is also the
>>>>> namespace issue pointed out. I think the namespace issue might be fixed
>>>>> in the latest OpenSFS code.
>>>> 
>>>> I'm not sure what you mean?  AFAIK, there is no upcall for JobID, except
>>>> maybe in the kernel client where we weren't allowed to parse the process
>>>> environment directly.  I agree an upcall is problematic with namespaces,
>>>> in addition to being less functional (only a JobID per node instead of
>>>> per process), which is why direct access to JOBENV is better IMHO.
>>> 
>>> I have some evil ideas about this. Need to think about it some more since
>>> this is a more complex problem.
>> 
>> Since the kernel manages the environment variables via getenv() and setenv(), I honestly don't see why accessing them directly is a huge issue?
> 
> This is, at best, an over-simplification.  The kernel doesn't "manage" the
> environment variables.
> When a process calls execve() (or similar) a collection of strings called
> "arguments" and another collection of strings called "environment" are
> extracted from the processes vm, and used for initializing part of the
> newly created vm.  That is all the kernel does with either.
> (except for providing /proc/*/cmdline and /proc/*/environ, which is best-effort).

Sure, and we only provide a best effort at parsing it as a series of NUL-
terminated strings.  Userspace can't corrupt the kernel VMA mappings,
so at worst we don't find anything we are looking for, which can also
happen if no JobID is set in the first place.  It's not really any more
dangerous than any copy_from_user() in the filesystem/ioctl code.

> getenv() ad setenv() are entirely implemented in user-space.  It is quite
> possible for a process to mess-up its args or environment in a way that
> will make /proc/*/{cmdline,environ} fail to return anything useful.

If userspace has also messed it up so badly that it can't parse the
environment variables themselves, then even a userspace upcall isn't
going to work.

> It is quite possible for the memory storing args and env to be swapped
> out.  If a driver tried to accesses either, it might trigger page-in of
> that part of the address space, which would probably work but might not
> be a good idea.

I've never seen a report of problems like this.  Processes that are
swapped out are probably not going to be submitting IO either...  We
cache the JobID in the kernel so it is only fetched on the first IO
for that process ID.  There once was a bug where the JobID was fetched
during mmap IO which caused a deadlock, and was since fixed.  We also
added the JobID cache, which has reduced the overhead significantly.

> As I understand it, the goal here is to have a cluster-wide identifier
> that can be attached to groups of processes on different nodes.  Then
> stats relating to all of those processes can be collected together.

Correct, but it isn't just _any_ system-wide identifier.  The large
parallel MPI applications already get assigned an identifier by the
batch scheduler before they are run, and a large number of tools in
these systems use JobID for tracking logs, CPU/IO accounting, etc.

The JobID is stored in an environment variable (e.g. SLURM_JOB_ID)
by the batch scheduler before the actual job is forked.  See the
comment at the start of lustre/obdclass/lprocfs_jobstats.c for
examples.  We can also set artificial jobid values for debugging
or use with systems not using MPI (e.g. procname_uid), but they do
not need access to the process environment.

For Lustre, the admin does a one-time configuration of the name of
the environment variable ("lctl conf_param jobid_var=SLURM_JOB_ID")
to tell the kernel which environment variable to use.

> ... But as I do think that control-groups are an abomination, I couldn't
> possible suggest any such thing.
> Unix already has a perfectly good grouping abstraction - process groups
> (unfortunately there are about 3 sorts of these, but that needn't be a
> big problem).  Stats can be collected based on pgid, and a mapping from
> client+pgid->jobid can be communicated to whatever collects the
> statistics ... somehow.

So, right now we have "scan a few KB of kernel memory for a string"
periodically in the out-of-tree client (see jobid_get_from_environ()
and cfs_get_environ()), and then a hash table that caches the JobID
internally and maps the pid to the JobID when it is needed.  Most of
the code is an simplified copy of access_process_vm() for kernels after
v2.6.24-rc1-652-g02c3530da6b9 when it was un-EXPORT_SYMBOL'd, but
since kernel v4.9-rc3-36-gfcd35857d662 it is again exported so it makes
sense to add a configure check.  Most of the rest is for when the
variable or value crosses a page boundary.


Conversely, the kernel client has something like "upcall a userspace
process, fork a program (millions of cycles), have that program do the
same scan of the kernel environment memory, but now it is doing it in
userspace, open a file, write the environment variable to the kernel,
exit and clean up the process that was created" to do the same thing.


Using a pgid seems mostly unusable, since the stats are not collected
on the client, they are collected on the server (the JobID is sent with
every userspace-driven RPC to the server), which is the centralized
location where all clients submit their IO.  JobStats gives us relatively
easy and direct method to see which client process(es) are going a lot of
IO or RPCs, just looking into a /proc file if necessary (though they are
typically further centralized and monitored from the multiple servers).

We can't send a different pgid from each client along with the RPCs and
hope to aggregate that at the server without adding huge complexity.  We
would need real-time mapping from every new pgid on each client (maybe
thousands per second per client) to the JobID then passed to the MDS/OSS
so that they can reverse-map the pgid back into a JobID before the first
RPC arrives at the server.  Alternately, track separate stats for each client:pgid combination on the server (num_cores * clients = millions of
times more than today if there are multiple jobs per client) until they
are fetched into userspace for mapping and re-aggregation.


Thanks, but I'd rather stick with the relatively simple and direct method
we are using today.  It's worked without problems for 10 years of kernels.
I think that is one of the big obstacles that we face with many of the
upstream kernel maintainers, is that they are focussed on issues that are
local to a one or a few nodes, but we have to deal with issues that may
involve hundreds or thousands of different nodes working as a single task
(unlike cloud stuff where there may be many nodes, but they are all doing
things independently).  It's not that we develop crazy things because we
have spare time to burn, but because they are needed to deal sanely with
such environments.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
