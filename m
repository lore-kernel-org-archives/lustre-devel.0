From: Andreas Dilger <adilger@sun.com>
Date: Tue, 14 Oct 2008 11:48:45 -0600
Subject: [Lustre-devel] HSM cache-miss locking
In-Reply-To: <48EE574E.2010808@sun.com>
References: <20081009080425.GJ2009@webber.adilger.int>
	<48EE574E.2010808@sun.com>
Message-ID: <20081014174845.GN2009@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Oct 09, 2008  12:11 -0700, Nathaniel Rutman wrote:
> Andreas Dilger wrote:
>>     The only reason the agent is restoring into the temp file is to avoid
>>     needing to open the file while the MDS is blocking layout lock access,
>>     but maybe that isn't a big obstacle (e.g. open flag).
>
> You mean open flag O_IGNORE_LAYOUT_LOCK?  So the one problem I see with  
> this is the case of a stuck agent - if we want to start another agent  
> doing copyin we have to insure that the first agent doesn't try to write  
> anything else.

Having two agents on the same file wouldn't itself be harmful, because they
should both be restoring the same data to the same place.  That said, we
would still want to be able to kill the stuck agent to avoid it continuing
to "restore" the file over new user data after the second agent had reported
"file is available" and the user process started writing to it.

>> 2) client enqueues extent lock on OST
>>     - object was previously marked fully/partly invalid during purge
>>     - object may have persistent invalid map of extent(s) that indicate
>>       which parts of object require copy-in
>
> I'll read this as if you're proposing your 2,3 (call it "per-object  
> invalid ranges held on OSTs") as a new method to do the copyin in-place.  
> This is not the original in-place idea proposed in Menlo Park (see 
> below), and so I'll comment with an eye toward the differences.

Correct, this is something Eric and I recently discussed in the context
of being able to begin using a file before copyin had completed.

> I think we can't assume we're restoring back to the original OSTs.  

Definitely not.

> Therefore the MDT must create new empty objects on the OSTs and have the  
> OSTs mark them purged before the layout lock can be granted to the 
> clients.

Correct.

>>     - access to invalid parts of object trigger copy-in upcall to coordinator
>   
> Now we need to figure out how to map the object back to a particular  
> range extent of a particular file (are we storing this in an EA with  
> each object now?)

We had also discussed the need for this with migration.  The OSTs already
store the MDS FID on each object, and even if the OSTs cannot do the
object->file extent mapping, their upcall to the coordinator can do this
with the LOV EA and the object extent.

> We also need to initiate OST->coordinator  
> communication, so either coordinator becomes a distributed function on  
> the OSTs or we need new services going the reverse of the normal  
> mdt->ost direction.  Maybe the coordinator-as-distributed-function works  
> - the coordinators must all choose the same agent for objects belonging  
> to the same file, yet distribute load among agents: I think the  
> coordinator just got a lot more complicated.

I don't think this implies the need for a distributed coordinator.  The
OSTs would contact the coordinator (as MDS does at file access in "simple"
model) with MDS FID (+OST extent?) and coordinator determines if there is
an existing copyin for that FID or not.

>>     ? group locks on invalid part of file block writes to missing data
>
> The issue here is that we can't allow any client to write and then have  
> the agent overwrite the new data with old data being restored.  So we  
> could have the OST give a group lock to agent via coordinator,  
> preventing all other writes.  But it seems that we can check the special  
> "clear invalid" flag used by the agent (see (3) below), and silently  
> drop writes into areas not in the "invalid extents" list.  Any client  
> write to any extent will clear the invalid flag for those extents.  And  
> then we only ever need to block on reading.

Eric and I discussed this at length.  The solution we came up with is to
have "agent" writes that are restoring the file be flagged as such and
only be allowed for parts of the file which are still marked "in HSM".
This allows normal writes to proceed without danger of being overwritten,
and for operations like "truncate" it would remove the need to restore
some/any of the file data because it would also clear the "in HSM" marker
from the truncated parts of the file.

NB: we haven't discussed truncates/unlinks in the context of HSM, but this
should _definitely_ not start a copyin of the file data.

> What about reads to missing data?  OST refuses to grant read locks on  
> invalid extents, needs clients to wait forever.

This would also trigger HSM copy-in.  If the HSM decides this data is
permanently inaccessible then the object (or parts thereof) should be
marked as such and client reads should get -EIO.

>> 3) coordinator contacts agent(s) to retrieve FID N from HSM
>>     - agents write to actual object to be restored with "clear invalid" flag
>>     - writes by agent shrink invalid extent, periodically update on-disk
>>       invalid extent and release locks on that part of file (on commit?)
>
> The OST should keep track of all invalid extents.  Invalid extents list  
> changes should be stored on disk, transactionally with the data write.

Yes, definitely it needs to be stored on disk, and it should be kept with
the object itself.  For completely purged objects, the MDS needs to mark
the whole file as "in HSM", and it would also truncate the objects to the
right size as soon as they are created (this already happens today when
the MDS file has no objects and is storing the size).

Remember this is all in the "complex" case where we want concurrent file
access with HSM copyin, and in simple case client will just block until
the copyin is finished.  Similarly, if copyin crashes in the middle, it
would have to start at the beginning, but that should be rare enough to
ignore it until the full solution is implemented.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
