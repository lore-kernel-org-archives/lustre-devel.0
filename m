From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Mon, 22 Sep 2008 20:49:21 -0700
Subject: [Lustre-devel] Doubly indexed tree / changelogs
In-Reply-To: <C4FCFC69.7CC2%peter.braam@sun.com>
References: <C4FCFC69.7CC2%peter.braam@sun.com>
Message-ID: <48D86741.2060101@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I actually added a "previous record" pointer in each changelog entry, 
but fill it in only where it is cheap -- when the metadata object is 
already in the cache I record the last changelog entry there. If it's 
not in the cache, I don't know where the last record associated with 
that fid is. We could store the last record number with the inode (EA?), 
but that would potentially be painful if we are recording e.g. file 
open/closes.
Forward pointers are also problematic, in that I don't want to go back 
and modify the old record every time a new one is recorded (seems like 
this will make the disks very seek-y), and I think maybe we don't need 
forward pointers anyhow (use case?). Anyhow, this effectively doubles 
the changelog write impact. Maybe that's ok: Manoj's measurements put 
the changelog overhead at only about 4% using mdsrate.

Peter Braam wrote:
> Hi Nikita, Nathan -
>
> After some pondering I have come to two conclusions.
>
> To encode filesets, we need a tree that makes two iterations fast:
>
>    1. list all filesets that contain a certain object
>    2. list all objects in a certain fileset
>
>
> Is there a doubly indexed tree for this?
>
> Secondly, to make the changelogs useful and scalable for filesets we 
> will need to be able to list all changelog entries associated with a 
> certain inode efficiently. I see two ways to do this ? one is an 
> auxiliary directory file mapping inodes to many changelog entries, the 
> second is to embed forward and backward pointers in the changelog 
> entries to build a linked list rooted at the inode (using an EA in the 
> inode pointing to the first and last element of the list). Both have 
> some overheads. What are your thoughts?
>
> Peter
> ------------------------------------------------------------------------
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
