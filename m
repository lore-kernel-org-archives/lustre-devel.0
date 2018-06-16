From: NeilBrown <neilb@suse.com>
Date: Sun, 17 Jun 2018 08:49:40 +1000
Subject: [lustre-devel] [PATCH 01/11] staging: lustre: simplify use of
 interval-tree.
In-Reply-To: <alpine.LFD.2.21.1806160344210.6450@casper.infradead.org>
References: <152826510267.16761.14361003167157833896.stgit@noble>
 <152826511890.16761.16115276596203531205.stgit@noble>
 <alpine.LFD.2.21.1806160344210.6450@casper.infradead.org>
Message-ID: <87sh5mfit7.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Oleg Drokin <green@linuxhacker.ru>, Andreas Dilger <andreas.dilger@whamcloud.io>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, Jun 16 2018, James Simmons wrote:

>> Lustre has a private interval-tree implementation.  This
>> implementation (inexplicably) refuses to insert an interval if an
>> identical interval already exists.  It is OK with all sorts of
>> overlapping intervals, but identical intervals are rejected.
>
> I talked to Oleg about this since this changes the behavior. He is worried
> about having identical items that would end up being merged.  If we can 
> guarantee by some other means there are no identical nodes, we are 
> probably fine with the interval tree code allowing this. Oleg can explain 
> better than me in this case.

I don't think this is a change in behaviour.
In the driver/staging client code, interval tree is being used in two
places and both of them have clumsy work-arounds for the fact that they
cannot insert duplicates in the interval tree.
The patch just cleans his up.

However if I have missed something, please provide details.
What "identical items" might get merged?

>  
>> Both users of interval-tree in lustre would be simpler if this was not
>> the case.  They need to store all intervals, even if some are
>> identical.
>> 
>> llite/range_lock.c add a rl_next_lock list_head to each lock.
>> If it cannot insert a new lock because the range is in use, it
>> attached the new lock to the existing lock using rl_next_lock.
>> This requires extra code to iterate over the rl_next_lock lists when
>> iterating over locks, and to update the list when deleting a lock from
>> the tree.
>> 
>> ldlm_extend allocates a separate ldlm_interval which as a list of
>> ldlm_locks which share the same interval.  This is linked together
>> by over-loading the l_sl_policy which, for non-extent locks, is used
>> for linking together locks with the same policy.
>> This doesn't only require extra code, but also an extra memory
>> allocation.
>> 
>> This patch removes all that complexity.
>> - interval_insert() now never fails.
>
> Its not really a failure. What it does is if it finds a already existing
> node with the range requested it returns the already existing node 
> pointer. If not it just creates a new node and returns NULL. Sometimes
> identical request can happen. A good example of this is with HSM request
> on the MDS server. In that case sometimes we get identical progress
> reports which we want to filter out so not add the same data.

This example is server-side code which is not a focus at present.
Having a quick look, it looks like it would be easy enough to do a
lookup first and then only insert if the lookup failed.
I think this is a much nicer approach than never allowing duplicates in
the interval tree.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180617/87d764cd/attachment.sig>
