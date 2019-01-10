From: NeilBrown <neilb@suse.com>
Date: Thu, 10 Jan 2019 12:36:33 +1100
Subject: [lustre-devel] [PATCH v2 33/33] lustre: update version to 2.9.99
In-Reply-To: <53F17B0D-5FB3-4B69-B483-7AA4FBCA259B@whamcloud.com>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
 <1546812868-11794-34-git-send-email-jsimmons@infradead.org>
 <874lakj5ck.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1901080352210.15230@casper.infradead.org>
 <45806D2E-8AAD-48ED-8B14-6D5CC11D824E@whamcloud.com>
 <alpine.LFD.2.21.1901081932010.14458@casper.infradead.org>
 <9BDCA6A9-A826-49A7-9126-BC1DCC96AC1D@whamcloud.com>
 <alpine.LFD.2.21.1901091734180.18138@casper.infradead.org>
 <53F17B0D-5FB3-4B69-B483-7AA4FBCA259B@whamcloud.com>
Message-ID: <87k1jdi99a.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jan 09 2019, Andreas Dilger wrote:

> On Jan 9, 2019, at 11:28, James Simmons <jsimmons@infradead.org> wrote:
>> 
>> 
>>>>> This might be because the upstream Lustre doesn't allow setting per-process
>>>>> JobID via environment variable, only as a single per-node value.  The real
>>>>> unfortunate part is that the "get JobID from environment" actually works for
>>>>> every reasonable architecture (even the one which was originally broken
>>>>> fixed it), but it got yanked anyway.  This is actually one of the features
>>>>> of Lustre that lots of HPC sites like to use, since it allows them to track
>>>>> on the servers which users/jobs/processes on the client are doing IO.
>>>> 
>>>> To give background for Neil see thread:
>>>> 
>>>> https://lore.kernel.org/patchwork/patch/416846
>>>> 
>>>> In this case I do agree with Greg. The latest jobid does implement an
>>>> upcall and upcalls don't play niece with containers. Their is also the
>>>> namespace issue pointed out. I think the namespace issue might be fixed
>>>> in the latest OpenSFS code.
>>> 
>>> I'm not sure what you mean?  AFAIK, there is no upcall for JobID, except
>>> maybe in the kernel client where we weren't allowed to parse the process
>>> environment directly.  I agree an upcall is problematic with namespaces,
>>> in addition to being less functional (only a JobID per node instead of
>>> per process), which is why direct access to JOBENV is better IMHO.
>> 
>> I have some evil ideas about this. Need to think about it some more since
>> this is a more complex problem.
>
> Since the kernel manages the environment variables via getenv() and setenv(),
> I honestly don't see why accessing them directly is a huge issue?

This is, at best, an over-simplification.  The kernel doesn't "manage" the
environment variables.
When a process calls execve() (or similar) a collection of strings called
"arguments" and another collection of strings called "environment" are
extracted from the processes vm, and used for initializing part of the
newly created vm.  That is all the kernel does with either.
(except for providing /proc/*/cmdline and /proc/*/environ, which is best-effort).

getenv() ad setenv() are entirely implemented in user-space.  It is quite
possible for a process to mess-up its args or environment in a way that
will make /proc/*/{cmdline,environ} fail to return anything useful.

It is quite possible for the memory storing args and env to be swapped
out.  If a driver tried to accesses either, it might trigger page-in of
that part of the address space, which would probably work but might not
be a good idea.

As I understand it, the goal here is to have a cluster-wide identifier
that can be attached to groups of processes on different nodes.  Then
stats relating to all of those processes can be collected together.

If I didn't think that control-groups were an abomination I would
probably suggest using them to define a group of processes, then to
attach a tag to that group. Both the netcl and net_prio cgroups
do exactly this.  perf_event does as well, and even uses the tag exactly
for collecting performance-data together for a set of processes.
Maybe we could try to champion an fs_event control group?
However it is a long time since I've looked at control groups, and they
might have moved on a bit.

But as I do think that control-groups are an abomination, I couldn't
possible suggest any such thing.
Unix already has a perfectly good grouping abstraction - process groups
(unfortunately there are about 3 sorts of these, but that needn't be a
big problem).
Stats can be collected based on pgid, and a mapping from
client+pgid->jobid can be communicated to whatever collects the
statistics ... somehow.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190110/de8e8a8a/attachment.sig>
