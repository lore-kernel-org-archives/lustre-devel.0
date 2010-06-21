From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Mon, 21 Jun 2010 15:35:26 -0600
Subject: [Lustre-devel] Attribute caching and OBD_CONNECT_ATTRFID
In-Reply-To: <201006211917.o5LJH9G4023021@hedwig.cmf.nrl.navy.mil>
References: <201006211917.o5LJH9G4023021@hedwig.cmf.nrl.navy.mil>
Message-ID: <9B242A89-CFDA-47D6-9726-4C2754DA141F@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-06-21, at 13:17, Ken Hornstein wrote:
>> This is in fact the right way to do it. If the lock is cancelledq then  
>> the client has no way of knowing whether that name will continue to  
>> point at the same FID or not.
> 
> I guess I was thinking in terms of inodebits locks, you may (for example)
> get the file size invalidated, but the name/FID is still the same.  Is
> my understanding of inodebits locks wrong?  It's entirely possible that
> it is.

That is correct.  It is possible to grant multiple ibits on the same lock, or it is possible to grant separate ibits on different locks.  Currently, we don't have DLM lock conversion, to allow e.g. cancelling only one bit from a granted lock.  That means if one lock bit is conflicting the whole lock (i.e. all its bits) will be cancelled.  The client will re-request only the ibits that it needs to avoid future contention.

>> Also note we recently changed the Linux client to invalidate the inode  
>> when all of the DLM locks related to that inode are cancelled.  This  
>> ensures the client 'forgets' about deleted inodes even when another  
>> client deleted it. Otherwise, the client will accumulate a lot of  
>> unnecessary inodes in cache.
> 
> I guess I could simply revoke the vnode when all of the DLM locks for
> it are cancelled (that tells the upper layer to forget everything you
> knew about the vnode).  That seems ... well, I guess I can't see
> anything wrong with it.  I guess now that you mention it, if another
> client deletes a file and you don't have a lock on it, you're not
> necessarily going to know that the delete happened, will you?
> But what happens if that file that's been invalidated is in use?

Currently, the Linux VFS will flag it as "DCACHE_INVALID" and it needs to be revalidated before use.

> Hm, actually, I see now that revoking the vnode has unintended
> consequences if someone has it open (as in, you won't be able to do
> anything but close it).  Perhaps a recycle is better; I'll have to
> figure that one out.
> 
> Could you point me to the section of the code in the Linux client that
> does the inode invalidation upon lock cancellation?  I want to make sure
> that I follow it and I'm doing the right thing.

The majority of this work was done in bug 20433.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
