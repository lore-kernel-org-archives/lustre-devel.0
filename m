From: Peter Braam <Peter.Braam@Sun.COM>
Date: Wed, 21 May 2008 08:23:56 +0800
Subject: [Lustre-devel] Replication for NRL/NGA
In-Reply-To: <483362FF.3050504@sun.com>
Message-ID: <C4598C9C.46DA%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 5/20/08 5:47 PM, "Nathaniel Rutman" <Nathan.Rutman@Sun.COM> wrote:

> Peter Braam wrote:
>>> ps: Nathan, to build the changelog ZFS exploits a tree structure for
>>> objects, directories and blocks ? the tree structure allows the file
>>> system to be searched fast for changes (log based). A missing element
>>> is a fast object to path lookup. To get an approximation of the
>>> metadata changelog, ZFS would use the difference on changed
>>> directories at the beginning and ending snapshot (the tree structure
>>> will help you to find pages that have seen insertions and removals ?
>>> this function would be called zapdiff).
>>>     
>> 
>> Hi Nathan -
>> 
>>   
>>> At first glance I am interpreting this very similar to the "zfs send"
>>> output stream, but the format of the stream would be
>>> 1. a fixed user API
>>>     
>> 
>> Hmm, don't understand this part.
>>   
> I meant a stream that a user can read/interpret, as opposed to a closed
> proprietary form that only "zfs receive" can understand.

Ah, but that's merely a matter of adding API.  And while you are at it, you
might as well ensure that the stream is rich enough for the search
requirements we are discussing elsewhere.

>>   
>>> 2. include full path names (or enough info to generate full path names)
>>> The stream would then be passed to a userland replicator (our current
>>> replication plan, and not "zfs recv")
>>>     
>> 
>> Yes, including policy processing, like only syncing certain subtrees.
>> 
>>   
>>> Is that about right? So we're just moving the MDT changelog generating
>>> part into ZFS
>>>     
>> 
>> Yup, but careful, this is a changeset (not an ordered log) but with
>> snapshots and you can change it into some kind of log that performs the same
>> changes.
>>   
> Right, it is a set of deltas between two snapshots, not a series of
> steps from A to B.  Once again, this makes things easier for us, because
> we don't care about intermediary states; we can just look up "original
> filename" and "final filename" for all changed objects.

Hmm.  You need to detect renames from the feed, and order these right to
avoid clobbering files?

>> , and assuming data changes are reflected in mtime updates
>>   
>>> on the MDT's znodes (i.e. we still are only paying attention to the
>>> MDTs, and not the OSTs).
>>>     
>> 
>> We use the same mechanism to make an OST change set.
>>   
> I'm not sure we ever got this straight between us: I was (am) planning
> on using the SOM feature to give me solid mtime data on the MDT, for any
> OST writes.

No.  We are going to use parallel data movements using all the OSS logs
independently to avoid a bottleneck that you would create by looking at the
MDS log.

Given that the ZFS log has the exact blocks in objects that need to be
moved, we would be silly not to exploit that immediately.

Peter


>  Thus I see no need to involve changelogs on the OSTs at
> all.  I just do an efficient copy (rsync) of my modified files list
> (from the MDT), and all is good.  (Yes, we could do a more efficient
> copy of only changed data blocks with the OST data, but is this worth
> the extra synchronization effort?)



>>   
>>> And for the efficient pathname generation, the plan would still be a
>>> (fid,name,parent list) database on the MDT, or something new / ZFS
>>> specific? I haven't really dug into ZFS much, but I assume we could go
>>> back to the "store parent znode in file EAs, store dirname in dir EAs" idea.
>>> The snapshots give us a way to avoid the dynamic "current path" issue,
>>> so this would be a little easier.
>>>     
>> 
>> Jeff Bonwick has extremely clear ideas about how he wants to do this (email
>> him and cc me, he'll explain, should he miss this line here).
>>   
> looking forward to it.
>> 
>>   
>>> But a big question is are we delivering zfs-based Lustre this fall? Not
>>> that I know anything about it, but aren't there licence problems with
>>> zfs and Linux?
>>>     
>> 
>> My proposal is that we demo ZFS replication first and then put it in Lustre
>> (and pNFS etc).
>>   
> I'm going to let Bryon sell that bridge.
>> BTW, we discussed other exciting things, namely that ZFS can just do the
>> rollback for CMD and that it can do metadata only snapshots to avoid
>> consuming lots of free space with the snapshotting of data,
> although presumably we're doing small incremental snapshots and erasing
> them when done; shouldn't be too big in general.  I suppose we can
> always come up with a pathologic case.
>> and Jeff even
>> came up with an idea to not snapshot at all but retain a few transactions to
>> roll back to.
>>   
> 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
