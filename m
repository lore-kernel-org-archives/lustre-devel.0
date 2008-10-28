From: Andreas Dilger <adilger@sun.com>
Date: Tue, 28 Oct 2008 12:26:13 -0600
Subject: [Lustre-devel] HSM comments
In-Reply-To: <4907249E.60904@cea.fr>
References: <4905F121.6000501@cea.fr>
	<20081027231204.GP3184@webber.adilger.int> <4907249E.60904@cea.fr>
Message-ID: <20081028182613.GX3184@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Oct 28, 2008  15:41 +0100, DEGREMONT Aurelien wrote:
> Andreas Dilger a ?crit :
>> I would recommend that we can keep a reference to a "dirty" HSM object
>> even if the copyout did not complete successfully, and HSM policy engine
>> should decide if the dirty object is kept or deleted.  In some cases
>> it may never be possible to do a complete copyout of the file, and having
>> some copy of the file would be better than having none at all.
>   
> So we will have three states for the hsm object:
> - exist
> - completed (exist & copy was completed)
> - uptodate (exist, copy was completed and the lustre file was not dirtied)

We already need to have the distinction between "completed" and "uptodate"
because an "uptodate" HSM copy stop being uptodate as soon as the file is
again modified.

I was a bit unclear when I wrote "...a complete copyout of the file".  What
I meant was "impossible to ever complete an uptodate copyout of the file
if it is continually changing".  I don't think we need to make any distinction
between "exist" and "complete" because both mean "not uptodate".

>>> - Also, if, instead of setting hsm_dirty bit to 1 when the file is
>>> modified, can we do counter += 1 ? That way 'counter' could be use as
>>> 'light' file revision. You compare two versions of this variable, is
>>> their differ, the file has been modified  (this is not intended to check
>>> 'counter_c1 < counter_c2' but just 'counter_c1 != counter_c2', that way,
>>> you can have circular counters.)
>>>     
>> The MDS in 1.8 (and soon 2.0) will already keep a version counter for all
>> changes to the MDS inode.  The OSTs will also keep version numbers for
>> all of the objects there.
>>   
> In our first (and old) hlds, we based several mechanisms on such  
> information.  But we were told that the version will be available
> for MDT but not for OST object

This hasn't changed - the OST object versions are local to the OSTs.
We could get this OST version information at the agent (just like with
file size being fetched from all OSTs) and store it with the HSM archive
copy.  This can be a later optimization, however.  I think mtime is
itself sufficient for an initial indication for file data changes.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
