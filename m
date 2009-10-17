From: Andreas Dilger <adilger@sun.com>
Date: Sat, 17 Oct 2009 11:53:12 -0600
Subject: [Lustre-devel] max_dirty_mb and fsync
In-Reply-To: <4AD76F52.4040706@ornl.gov>
References: <4AD76F52.4040706@ornl.gov>
Message-ID: <F0F8DECF-1BD9-4B47-A183-23B6697D79F8@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 15-Oct-09, at 12:52, Bradley W. Settlemyer wrote:
>  What is the difference between setting the max_dirty_mb setting in
> /proc to 4 and making sure that all of my applications fsync every  
> 4MBs
> of data that are transmitted?
>
>  I would guess that one difference is the 32MB is a filesystem-wide
> setting rather than a per file setting -- so the sync occurs  
> regardless
> of the number of files receiving data.  But are there any other
> differences with regards to the interaction with the file system.
>
>  More to the point perhaps, does an fsync have additional side effects
> beyond those that occur for the max_dirty_mb threshhold being  
> exceeded?


One important distinction between max_dirty_mb (which is a Lustre  
mechanism
to avoid too much file cache memory pressure on the client node causing
application data to be paged out of memory) and an fsync() is  
max_dirty_mb
only pushes out file data to the OSTs on an as-needed basis, while  
fsync()
flushes ALL of the data, and also guarantees that you can ACCESS that  
data
after it was written to the OSTs/disks.

Whether on Lustre or a local filesystem, just because the blocks are  
on disk,
it doesn't mean that the metadata (either Lustre on the MDS, or ext3/ 
xfs/etc)
to access that data (whether for the pathname traversal, or the inode  
itself)
is also safe on disk.  This is one of the issues being discussed a lot  
on
linux-fsdevel regarding the semantics of O_DIRECT, which guarantees  
that the
DATA is on disk but it doesn't mean that the just-created inode or the  
mapping
for just-allocated blocks have made it to the disk at all.

That behaviour is fine for a database, which will generally always  
preallocate
the file on disk, so the only thing changing is the file data, but it  
may be
a surprise to other users of O_DIRECT.

That said, Lustre WILL of course write all of this data to disk as  
soon as
practical, without forcing everything to a standstill while the  
fsync() is
completed.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
