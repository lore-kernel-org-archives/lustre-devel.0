From: NeilBrown <neilb@suse.com>
Date: Fri, 08 Jun 2018 16:07:21 +1000
Subject: [lustre-devel] A new drivers/staging/lustre
In-Reply-To: <16129B94-CF52-4E5E-9A5A-2EC0E01BEEE0@intel.com>
References: <874lifnxbp.fsf@notabene.neil.brown.name>
 <16129B94-CF52-4E5E-9A5A-2EC0E01BEEE0@intel.com>
Message-ID: <87wov9lskm.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jun 07 2018, Dilger, Andreas wrote:

> On Jun 6, 2018, at 20:29, NeilBrown <neilb@suse.com> wrote:
>> Greg's patch to remove lustre has now landed in this staging-next tree,
>> so I suspect it will get to Linus before too long.  So I have to find a
>> new place to work on lustre.
>> 
>> I've added 2 branches to
>>   git://git.neil.brown.name/linux
>> 
>> lustre:
>>   is based on Greg's patch that removes lustre, and starts with a
>>   revert of the patch, followed by a merge of v4.17.
>>   I plan to merge each release and RC from Linus, and also
>>   add lustre patches that I think are "ready".  That will usually mean
>>   they have been posted to this list at least a week earlier, and
>>   have not had a credible negative response (Acks and Reviewed-by
>>   would be nice).
>>   I plan to update this branch about once a week, and to never rebase
>>   it.
>> 
>> lustre-testing:
>>   is based on 'lustre' and has most of my current lustre-related work.
>>   It includes assorted patches that are not specifically for lustre
>>   (rhashtables mostly at the moment).  Patches will move from here
>>   to 'lustre' or to mainline when they are ready.
>>   I plan to update this branch on most days that I work on Lustre,
>>   and expect it to rebase frequently.
>
> We also have a clone of Greg's staging branch on our Gerrit server,
> which could be replaced with a "vanilla" upstream kernel clone that
> holds a copy of the for-upstream Lustre tree.
>
> One benefit of hosting the tree on the Gerrit server is that it is
> much easier to get automated testing of the patches (a lot or a little)
> to ensure that the code doesn't break anything obvious.
>
>> I'm happy to review and, if acceptable, apply patches from other
>> developers.  I have fairly high standards, but if I don't accept your
>> patch I'll explain why and possible help fix it.
>> I'm happy to accept enhancements and new features, but these need
>> to be of a quality that would be accepted upstream.
>> I'm only interested in client-side code at present - nothing that is
>> only used on the server.  I do want to include server-side eventually,
>> but I need some focus for now.
>> 
>> I hope to get to a stage where the code is of suitable quality that I
>> can submit it to Linux as a new filesystem.  I hope that will happen
>> this year.
>
> I think one major drawback of starting with the from-staging version of
> the code is that this is significantly behind the out-of-tree master
> code and would need a lot of effort to catch up.
>
> I think the only way we are going to make this work is if the cleanups
> go into the same repo as the ongoing development.  Otherwise, we'll be
> back in the same situation as we are now where there are two different
> versions of the code and we need to move patches back and forth between
> them.
>
> On the plus side, this will avoid code drift, and the extra efforts of
> porting patches back and forth.  On the minus side, it means (on some
> fronts) that the code will regress from what is upstream, because we
> don't have all of the trivial whitespace cleanups and other drive-by
> kernel newbie patches that went into the upstream client.  However, it
> does mean that those cleanups would now become part of the single code
> tree and not be lost again in the future.
>
> This would also mean some restructuring of the current Lustre tree so
> that it could build as a drop-in at linux/fs/lustre but that is probably
> a good idea for the long term in any case.

One of the difficulties I imagine with a single tree is that the current
tree has lots of backward compatibility support to allow the code to
compile on old kernels.  Having to maintain that would seem to interfere
with getting the code into an upstreamable state.
If the lustre development model could change to be working primarily in
a tree what was kept in-sync with upstream and which didn't carry
back-compat code, then I think we might be able to do development and
cleanup in the same tree.
Every other linux project (that I know of) works this way.  Patches are
developed in an upstream kernel, then back-ported to other kernels as
needed.  Enterprise distros do this all the time and are quite good at
it.

Can we move all the kernel code out of the lustre tree and into a clone
of Linux??

Thanks,
NeilBrown


>
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Principal Architect
> Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180608/da30e556/attachment.sig>
