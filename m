From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Mon, 22 Sep 2008 09:52:57 +0400
Subject: [Lustre-devel] Doubly indexed tree / changelogs
In-Reply-To: <C4FCFC69.7CC2%peter.braam@sun.com>
References: <C4FCFC69.7CC2%peter.braam@sun.com>
Message-ID: <48D732B9.6090309@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

can object migrate between filesets? if not, we probably
can use fid's sequence as a record in that index?

thanks, Alex

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
> certain inode efficiently.  I see two ways to do this ? one is an 
> auxiliary directory file mapping inodes to many changelog entries, the 
> second is to embed forward and backward pointers in the changelog 
> entries to build a linked list rooted at the inode (using an EA in the 
> inode pointing to the first and last element of the list).  Both have 
> some overheads.  What are your thoughts?
> 
> Peter
> 
> 
> ------------------------------------------------------------------------
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
