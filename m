From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Fri, 29 Aug 2008 15:42:14 -0700
Subject: [Lustre-devel] Summary of our HSM discussion
In-Reply-To: <48B86F3C.9080909@Sun.COM>
References: <C4BCA140.5486%peter.braam@sun.com> <48B85E2D.8000109@sun.com>
	<48B86F3C.9080909@Sun.COM>
Message-ID: <48B87B46.8050200@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Rick Matthews wrote:
> On 08/29/08 15:38, Nathaniel Rutman wrote:
>> Rick - I'm finally getting a chance to look at the ADM docs.
>> Most notably as far as I'm concerned, it looks like ADM depends on 
>> DMAPI filesystem interfaces.
>> What we have in Lustre at the moment is a changelog, which includes 
>> all namespace ops (file create, destroy, rename, etc.), and will 
>> include the closed-after-write (#1 below); and e2scan which can be 
>> used to semi-efficiently walk the filesystem gathering mtime/atme 
>> info (#3.)
> DMAPI is an implementation choice. You are correct in assuming what it 
> needs is event information from which an informed decision is made.
> If the necessary information is not with the event (because of later 
> change, or efficiency) the event/policy piece will gather the needed 
> info. I don't
> think there is anything outside of standard POSIX needed.
>> We'll have to add a flag into the lov_ea indicating "in HSM", and 
>> then block for file retrieval (#2).
> Correct...with a small twist...the HSM holds copies of data even when 
> they continue to exist in native disk. The "release" of this space 
> then doesn't need to
> wait for a slower data mover. So, change "in HSM" to "only in HSM" and 
> you are correct.
right, that's what I had in mind.
>> So we need to take these three items and provide some kind of 
>> interface that ADM is comfortable with, while not strictly following 
>> the DMAPI "check with us for every system event" paradigm.
>> The only synchronous event here is #2, where we are requesting a file 
>> out of HSM.
> Yep.
>>
>> From the ADM spec:
>> Changes to ZFS will be fasttracked separately and putback to the ONNV 
>> gate. Much of
>> DMAPI's interaction with ZFS for dm_xxx APIs is done through VFS 
>> interfaces. Imported
>> VFS interfaces are in the table below. A few additional changes are 
>> necessary, such as
>> calling DMAPI to send events, and not updating timestamps for 
>> invisible IO. The plan and
>> current prototype adds a flag value (FINVIS) to be passed into the 
>> VOP_READ,
>> VOP_WRITE, and VOP_SPACE interfaces for invisible IO.
>>
>> If I'm understanding things correctly, if Lustre just honors the 
>> open(...,O_WRONLY | FINVIS) call, and sends the cache miss request 
>> (#2), that is sufficient interaction to pull an HSM file back into 
>> Lustre.
>> We would need a second element that would read the changelogs and 
>> e2scan results to determine when/which files to archive, and the 
>> open(..., O_RDONLY | FINVIS) call to get the data. This element could 
>> be userspace and is asynchronous. Would this talk directly to ADM? 
>> Use DMAPI calls?
> Correct...we would create an interface for consuming your events. (By 
> we, I mean some subset of the two teams). Our DMAPI implementation relies
> heavily on filtering to prevent event floods. As we've discussed, 
> since filters just remove unwanted things, they can occur in the 
> "kernel" / log generation,
> and in user space without impact on the resulting event chain. The 
> "invisible I/O" just prevents additional events size and 
> modtime/access time changes.
> Need not be DMAPI.
Ok, so this is the "event/policy piece", JC I think this is a 
subcomponent of the "coordinator" piece from the old HSM HLD.  I see no 
reason why this can't be a userspace program.  I imagine this piece 
feeds the events/LRU list into the ADM policy engine, and then somebody 
(this piece? ADM itself?) starts doing the FINVIS copyouts into ADM.

Does it make sense to send the cache miss request to this same 
event/policy piece, or to ADM directly?  Somebody needs to do the FINVIS 
copyin.

Thinking a little more about the Lustre internals for step #2, instead 
of blocking the open call on the MDT, maybe it makes sense to grant the 
open lock to the client, who receives the "only in HSM" flagged LOV md, 
and locally blocks read/write requests until the LOV md has been updated 
(maybe signalled through a lock callback on file)  (We've talked about 
adding a file layout lock in the past; maybe that is appropriate here).


>>
>> Does this sound right?
> Yep.
>>
>>
>> Peter Braam wrote:
>>> The steps to reach a first implementation can be summarized as:
>>>
>>>    1. Include file closes in the changelog, if the file was opened for
>>>       write. Include timestamps in the changelog entries. This allows
>>>       the changelog processor to see files that have become inactive
>>>       and pass them on for archiving.
>>>    2. Build an open call that blocks for file retrieval and adapts
>>>       timeouts to avoid error returns.
>>>    3. Until a least-recently-used log is built, use the e2scan utility
>>>       to generate lists of candidates for purging.
>>>    4. Translate events and scan results into a form that they can be
>>>       understood by ADM.
>>>    5. Work with a single coordinator, whose role it is to avoid
>>>       getting multiple ?close? records for the same file (a basic
>>>       filter for events).
>>>    6. Do not use initiators ? these can come later and assist with
>>>       load balancing and free-ing space on demand (both of which we
>>>       can ignore for the first release)
>>>    7. Do not use multiple agents ? the agents can move stripes of
>>>       files etc, and this is not needed with a basic user level
>>>       solution, based on consuming the log. The only thing the agent
>>>       must do in release one is get the attention of a data mover to
>>>       restore files on demand.
>>>
>>>
>>> Peter
>>> ------------------------------------------------------------------------ 
>>>
>>>
>>> _______________________________________________
>>> Lustre-devel mailing list
>>> Lustre-devel at lists.lustre.org
>>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>>   
>>
>
>
