From: NeilBrown <neilb@suse.com>
Date: Tue, 27 Nov 2018 13:21:08 +1100
Subject: [lustre-devel] [PATCH 7/9] lustre: lnet: Stop MLX5 triggering a
 dump_cqe
In-Reply-To: <alpine.LFD.2.21.1811260146540.32255@casper.infradead.org>
References: <154295730810.2850.961218355189474016.stgit@noble>
 <154295732806.2850.603181458106225374.stgit@noble>
 <alpine.LFD.2.21.1811260146540.32255@casper.infradead.org>
Message-ID: <87bm6bqmzv.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Nov 26 2018, James Simmons wrote:

>> From: Doug Oucharek <doug.s.oucharek@intel.com>
>> 
>> We have found that MLX5 will trigger a dump_cqe if we don't
>> invalidate the rkey on a newly allocated MR for FastReg usage.
>> 
>> This fix just tags the MR as invalid on its creation if we are
>> using FastReg and that will force it to do an invalidate of the
>> rkey on first usage.
>
> I pushed this one already, see https://lkml.org/lkml/2018/3/16/1410.
> Dan felt this was more a infiniband layer bug that needed to be fixed.
> It could be fixed already upstream or if it is not once this problem
> is reported we will need to work the rdma group to fix it.

Thanks.  I've dropped it for now.

If I had any idea about infiniband, I might look at the MLX driver - but
I don't :-(

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181127/90c3732c/attachment.sig>
