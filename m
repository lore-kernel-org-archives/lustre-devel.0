From: Peter Braam <Peter.Braam@Sun.COM>
Date: Mon, 22 Sep 2008 14:58:56 +0800
Subject: [Lustre-devel] Doubly indexed tree / changelogs
In-Reply-To: <48D732B9.6090309@sun.com>
Message-ID: <C4FD6330.7CD7%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Objects can be in many filesets, and be added to some, removed from others.

I think this is an almost arbitrary collection of pairs (FID, fileset-id)
and we need it indexed by both.

Peter


On 9/22/08 1:52 PM, "Alex Zhuravlev" <Alex.Zhuravlev@Sun.COM> wrote:

> can object migrate between filesets? if not, we probably
> can use fid's sequence as a record in that index?
> 
> thanks, Alex
> 
> Peter Braam wrote:
>> Hi Nikita, Nathan -
>> 
>> After some pondering I have come to two conclusions.
>> 
>> To encode filesets, we need a tree that makes two iterations fast:
>> 
>>    1. list all filesets that contain a certain object
>>    2. list all objects in a certain fileset
>> 
>> 
>> Is there a doubly indexed tree for this?
>> 
>> Secondly, to make the changelogs useful and scalable for filesets we
>> will need to be able to list all changelog entries associated with a
>> certain inode efficiently.  I see two ways to do this ? one is an
>> auxiliary directory file mapping inodes to many changelog entries, the
>> second is to embed forward and backward pointers in the changelog
>> entries to build a linked list rooted at the inode (using an EA in the
>> inode pointing to the first and last element of the list).  Both have
>> some overheads.  What are your thoughts?
>> 
>> Peter
>> 
>> 
>> ------------------------------------------------------------------------
>> 
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
