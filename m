From: Andreas Dilger <andreas.dilger@oracle.com>
Date: Fri, 29 Oct 2010 23:26:15 +0800
Subject: [Lustre-devel] layout lock bug with 118k
In-Reply-To: <4CC82688.4050801@cea.fr>
References: <4CC82688.4050801@cea.fr>
Message-ID: <18180EC5-3EFB-4C92-8F6A-4169A1DBA2D7@oracle.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2010-10-27, at 21:18, Jacques-Charles Lafoucriere wrote:
> I have found a bug in layout lock (the bug was seen with test 118k, this is the last known).
> 
> A simpler reproducer is to make an rm during a long file write.
> 
> A lock timeout is trigged because during the writes the client hold the layout lock which is in the same lock as a lookup (muliple inode_bits in the same lock). So when the MDS try to get an LCK_EX on the object (before calling  mdo_unlink), the lock is not freed because of the ref count.

The client should only be holding a reference on the layout lock for 1MB chunks of IO.  Between each IO the layout lock reference should be dropped, and if there was a blocking callback on the lock the client should also cancel the lock at that time.

> A solution is the request a LCK_CR on the object before the mdo_unlink (the directory is still protected by a strong lock).  Is it a good solution ? Do you have another one ?

We discussed this issue recently, and the preferred solution is to release the layout lock as soon as the OST extent locks are referenced, since we don't actually require the layout lock once we hold the object extent lock(s).

We discussed this before, and it is a bit tricky, because the ll_layout_lock_get() and ll_layout_lock_put() currently wrap the IO function. One proposal is to refcount the lsm structure under the layout lock, and then drop the last lsm reference in the LOV code after the object lock is held, and that would release the lsm lock.

Cheers, Andreas
--
Andreas Dilger
Lustre Technical Lead
Oracle Corporation Canada Inc.
