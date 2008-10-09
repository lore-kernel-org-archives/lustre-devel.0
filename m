From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Thu, 09 Oct 2008 14:05:24 -0700
Subject: [Lustre-devel] HSM cache-miss locking
In-Reply-To: <48EE574E.2010808@sun.com>
References: <20081009080425.GJ2009@webber.adilger.int>
	<48EE574E.2010808@sun.com>
Message-ID: <48EE7214.4080200@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Note that Andreas' simple vs. complex case seems to fundamentally affect 
the design of the coordinator (whether it is associated with the MDT or 
the OSTs), and so I don't see a clear non-throw-away path from one to 
the other.   I think the "original in-place copyin" idea is more 
compatible with the simple case.  Also note that Braam also posited that 
the copyin at open is a desired simplification for the "Simplified HSM 
for Lustre" (lustre-devel 7/16).

Nathaniel Rutman wrote:
> Andreas Dilger wrote:
>   
>> Nathan,
>> Eric and I had a lengthy discussion today about HSM and the copy-in
>> process.  This was largely driven by Braam's assertion that having a
>> copy-in process that blocks all access to the file data is not sufficient
>> to meet customer demands.  Some customers require processes be able to
>> access the file data as soon as it is present in the objects.
>>
>> Eric and I both agreed that we want to start with as simple an HSM solution
>> as possible and incrementally provide improvements, so long as the early
>> implementation is not a "throw-away" that consumes significant developer
>> resources but doesn't provide long term benefits.  In both the "simple"
>> and the "complex" copy-in the client has no knowledge/participation
>> of the process being done by the HSM/coordinator.
>>
>> We both agreed that the simplest copy-in process is a reasonable starting
>> point and can be used by many customers.  To review the simple case
>> (I hope this also matches your recollection):
>>
>> 1) client tries to access a file that has been purged
>>   a) if client is only doing getattr, attributes can be returned from MDS
>>     - MDS holds file size[*]
>>     - client may get MDS attribute read locks, but not layout lock
>>     -> DONE
>>   b) if client is trying to do an open (read or write)
>>     - layout lock is required by client to do any read/write of the file
>>     - client enqueues layout lock request
>>     - MDS notices that file is purged, does upcall to coordinator to
>>       start copy-in on FID N
>>   
>>     
> s/does upcall/asks/.  We expect coordinator to be in-kernel for LNET 
> comms to agents.
>   
>> 2) client is blocked waiting for layout lock
>>   - if MDS crashes at this point, client will resend open to MDS, goto 1b
>>   - MDS should send early replies indicating lock will be slow to grant
>>   
>>     
> The reply to the layout lock request includes a "wait forever" flag 
> (this is the one client code change required for HSM at this point.)  
> There are no early replies for lock enqueue requests.  Maybe indefinite 
> ongoing early replies for lock enqueus are a requirement for HSM copyin?
>   
>>   ? need to have a mechanism to ensure copy-in hasn't failed?
>>   
>>     
> Coordinator needs to decide is copy-in has failed, and redistribute the 
> request to a new agent. (Needs detail: timer?  progress messages from 
> agent?) There's nothing the client or MDT can do at this point (except 
> fail the request), so we may as well just wait.
>   
>> 3) coordinator contacts agent(s) to retrieve FID N from HSM
>>   - agent(s) create temp file X (new or backed-up layout parameters) [!]
>>   
>>     
> backed up in EA with original copyout request.  We should try to respect 
> specific layout settings (pool, stripecount, stripesize), but be 
> flexible if e.g. pool doesn't exist anymore.  Maybe we want to ignore 
> offset and/or specific ost allocations in order to rebalance.
>   
>>   - agent(s) restore data into temp file
>>   - agent or coordinator do ioctl on file to move file X objects to
>>     file N, old objects are destroyed on file close, or 
>>   - agent or coordinator do ioctl on file to notify MDS copy-in is done
>>   
>>     
> I was thinking the latter, and MDT moves the layout from X to N.
>   
>> 4) MDS handles ioctl, drops layout lock
>> 5) client(s) waiting on layout lock are granted the layout lock by MDS
>>   - client(s) get OST extent locks
>>   - client(s) read/write file data
>>   -> DONE
>>
>> [*] The MDS will already store the file size today, even without SOM, if
>>     the file does not have any objects/striping.  If SOM is not implemented
>>     then the "purged" state and object removal (with destroy llog entries)
>>     would need to be a synchronous operation BEFORE the objects are actually
>>     destroyed.  Otherwise, SOM-like recovery of the object purge state is
>>     needed.  Avoiding the sync is desirable, but making HSM dependent upon
>>     SOM is undesirable.
>>   
>>     
> All we really have to do is insure that the destroy llog entry is 
> committed, right?  Then the OSTs should eventually purge the objects 
> during orphan recovery, yes?
>   
>> [!] If MDS kept layout then it could pre-create the temp file and pass the
>>     restore-to FID to the coordinator/agent, to keep agent more similar to
>>     "complex" case where it is restoring directly into real file.  The only
>>     reason the agent is restoring into the temp file is to avoid needing
>>     to open the file while the MDS is blocking layout lock access, but maybe
>>     that isn't a big obstacle (e.g. open flag).
>>   
>>     
> You mean open flag O_IGNORE_LAYOUT_LOCK?  So the one problem I see with 
> this is the case of a stuck agent - if we want to start another agent 
> doing copyin we have to insure that the first agent doesn't try to write 
> anything else.  Or we give them two separate temp files, but this 
> remains a problem with the direct restore into real file case.  Although 
> I suppose this is already handled by write extent locks and eviction...
>   
>> In the "complex" case, the clients should be able to read/write the file
>> data as soon as possible and the OSTs need to prevent access to the parts
>> of the file which have not yet been restored.
>>
>> 1) client tries to access a file that has been purged
>>   a) if client is only doing getattr, attributes can be returned from MDS
>>     - MDS holds file size[*]
>>     - client may get MDS attribute read locks, but not layout lock
>>     -> DONE
>>   b) if client is trying to do an open (read or write)
>>     - layout lock is required by client to do any read/write of the file
>>     - client enqueues layout lock request
>>   
>>     
>            -  MDT generates new layout based on old lov EA, assigning 
> newly created OST objects.
>   
>>     - MDS grants layout lock to client
>> 2) client enqueues extent lock on OST
>>     - object was previously marked fully/partly invalid during purge
>>     - object may have persistent invalid map of extent(s) that indicate
>>       which parts of object require copy-in
>>   
>>     
> I'll read this as if you're proposing your 2,3 (call it "per-object 
> invalid ranges held on OSTs") as a new method to do the copyin 
> in-place.  This is not the original in-place idea proposed in Menlo Park 
> (see below), and so I'll comment with an eye toward the differences.
>  
> I think we can't assume we're restoring back to the original OSTs. 
> Therefore the MDT must create new empty objects on the OSTs and have the 
> OSTs mark them purged before the layout lock can be granted to the clients.
>   
>>     - access to invalid parts of object trigger copy-in upcall to coordinator
>>   
>>     
> Now we need to figure out how to map the object back to a particular 
> range extent of a particular file (are we storing this in an EA with 
> each object now?)  We also need to initiate OST->coordinator 
> communication, so either coordinator becomes a distributed function on 
> the OSTs or we need new services going the reverse of the normal 
> mdt->ost direction.  Maybe the coordinator-as-distributed-function works 
> - the coordinators must all choose the same agent for objects belonging 
> to the same file, yet distribute load among agents: I think the 
> coordinator just got a lot more complicated.
>   
>>     ? group locks on invalid part of file block writes to missing data
>>   
>>     
> The issue here is that we can't allow any client to write and then have 
> the agent overwrite the new data with old data being restored.  So we 
> could have the OST give a group lock to agent via coordinator, 
> preventing all other writes.  But it seems that we can check the special 
> "clear invalid" flag used by the agent (see (3) below), and silently 
> drop writes into areas not in the "invalid extents" list.  Any client 
> write to any extent will clear the invalid flag for those extents.  And 
> then we only ever need to block on reading.
> What about reads to missing data?  OST refuses to grant read locks on 
> invalid extents, needs clients to wait forever.
>   
>>     - clients block waiting on extent locks for invalid parts of objects
>>   
>>     
> We'll have to set this extent lock enqueue timeout to wait forever.
>   
>>     - OST crash at this timek restarts enqueue process
>>   
>>     
> Agent crash will still have to be detected and restarted by coordinator
>
>   
>> 3) coordinator contacts agent(s) to retrieve FID N from HSM
>>     - agents write to actual object to be restored with "clear invalid" flag
>>     - writes by agent shrink invalid extent, periodically update on-disk
>>       invalid extent and release locks on that part of file (on commit?)
>>   
>>     
> The OST should keep track of all invalid extents.  Invalid extents list 
> changes should be stored on disk, transactionally with the data write.
>   
>>     - client or agent agent crash doesn't want to access parts of multi-
>>       part archive it will
>>   
>>     
> ??
>
> Invalid extents list will be accurate regardless of client, agent, or 
> OST crash.  I hope.  Subsequent requests to missing data will result in 
> new OST requests to coordinator.
>   
>> 4) client is granted extent lock when that part of file is copied in
>>   
>>     
>
> So that actually doesn't sound too bad.  I think the original idea of 
> keeping the locking (and the coordinator) on the MDT (below) is still 
> simpler, but I think it's going to be the recovery issues that decide 
> this one way or the other.
>
> Original in-place copyin idea:
> When MDT generates new layout, it takes PW write locks on all extents of 
> every stripe on behalf of the agent, and then somehow transfers these 
> locks to the agent (this transferability was the point of using the 
> group lock).  The agent then releases extent locks as it copies in data.
> This was the first design we discussed in Menlo Park:
>
>     (older idea, for posterity)
>     Open intent enques layout lock.  MDT checks "purged" bit; if purged,
>     MDT selects new layout and populates MD.  MDT takes group extent
>     locks on all objects, then grants layout read lock to client,
>     allowing open to finish successfully, quickly.  (Client reads/writes
>     will block forever on extents enqueues until group lock has been
>     dropped.)  MDT then sends request to coordinator requesting copyin
>     FID XXXX with group lock id YYYY (and extents 0-end).  Coordinator
>     distributes that request to an appropriate agent.  Agent retrieves
>     file from HSM and writes into /.lustre/fid/XXXX:XXXX using group
>     lock YYYY.  Agent takes group lock, MDT still holds group lock. 
>     When finished, the agent clears "purged" bit from EA, and drops the
>     group lock.  Clearing purged bit causes MDT to drop group lock as
>     well, allowing the client to read/write.
>
> It gets fuzzy at the end there, about exactly when the MDT drops the 
> group lock in order to do handle the dead agent case.  It seems the safe 
> thing to do is for the MDT to keep it until the agent is done, but then 
> this blocks access to completed extents.  If the MDT drops the group 
> lock as soon as the agent takes it, then somehow the agent converts the 
> group lock to regular write lock, then other clients can get read/write 
> locks on released extents.  But if the agent dies, the extent locks will 
> be freed at eviction, and other clients are free to start reading 
> (missing) data.
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
