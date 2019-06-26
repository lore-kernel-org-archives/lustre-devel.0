From: Anna Fuchs <anna.fuchs@informatik.uni-hamburg.de>
Date: Wed, 26 Jun 2019 15:11:48 +0200
Subject: [lustre-devel] Request arc buffer, zerocopy
In-Reply-To: <1560426887.3392.0@informatik.uni-hamburg.de>
References: <1560426887.3392.0@informatik.uni-hamburg.de>
Message-ID: <1561554708.16396.0@informatik.uni-hamburg.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Dear all,

one more question related to ZFS-buffers in Lustre.

There is a function osd_grow_blocksize(obj, oh, ...) called after the 
fist portion of data (first rnb?)
has been committed to ZFS.
There are some restrictions for block size changing:
dmu_object_set_blocksize says:
The object cannot have any blocks allcated beyond the first. If
* the first block is allocated already, the new size must be greater
* than the current block size.
and later on
/*
 * Try to change the block size for the indicated dnode.  This can only
 * succeed if there are no blocks allocated or dirty beyond first block
 */

I am now interested on the frist block's size, which seems to be set 
when creating the dnode.
This size comes from ZFS and is something like
dnp->dn_datablkszsec << SPA_MINBLOCKSHIFT or SPA_MINBLOCKSIZE (not 
sure).

I would like to specify this size on Lustre's side, not just take what 
ZFS offers.
E.g. make the first block 128K instead of 4K.
Is it possible? Could I just overwrite the block size before the 
corresponsing memory for the block is allocated?

I am not able to call osd_grow_blocksize for the first block, since I 
do not have any thread context there, not yet.
Do I need to grab into dnode_allocate and dnode_create?

And for better understanding, does one dnode always represent one 
lustre object?

I would be greatful for any suggestions.

***

Some context for my questions:

I have compressed data chunks coming from the Lustre client. I want to 
hand them over to ZFS like they
were compressed by ZFS. ZFS offers some structures, e.g. compressed 
arc-buffers, which know how the data has been
compressed (which algo, physical and logical sizes). I want and need my 
chunks to be aligned to the records (arc buffers).
We have already extended the interfaces of the internal ZFS compression 
structures. But currently ZFS (or osd-zfs) first defines
the sizes of buffers and the data is put in there. In my case, the data 
should "dictate" how many buffers there are and how large they can be.

Best regards
Anna

--
Anna Fuchs
Universit?t Hamburg

On Thu, Jun 13, 2019 at 1:54 PM, Anna Fuchs 
<anna.fuchs@informatik.uni-hamburg.de> wrote:
> Dear all,
> 
> in osd-zfs/osd_io.c:osd_bufs_get_write you can find a comment 
> regarding zerocopy:
> 
> 	/*
> 	 * currently only full blocks are subject to zerocopy approach:
> 	 * so that we're sure nobody is trying to update the same block
> 	 */
> 
> Whenever a block to be written is full, an arc buffer is requested, 
> otherwise alloc_page.
> 
> I do not really understand the conclusion. Why and how do full blocks 
> prevent updates?
> And put it differently - why not to try zerocopy for not full blocks?
> What could happen if I tried to request an arc buffer for e.g. a 
> block with missin g last page?
> 
> I would be greateful for details.
> Best regards
> Anna
> 
> 
> 
> 
> 

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190626/8d054f5f/attachment.html>
