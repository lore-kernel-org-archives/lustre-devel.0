From: NeilBrown <neilb@suse.com>
Date: Thu, 21 Feb 2019 11:33:14 +1100
Subject: [lustre-devel] Lustre interval tree problems
In-Reply-To: <MN2PR19MB25107E921212A20D9CCE8215C57D0@MN2PR19MB2510.namprd19.prod.outlook.com>
References: <alpine.LFD.2.21.1902201738170.6267@casper.infradead.org>
 <87h8cycchl.fsf@notabene.neil.brown.name>
 <MN2PR19MB25107E921212A20D9CCE8215C57D0@MN2PR19MB2510.namprd19.prod.outlook.com>
Message-ID: <87bm36c75h.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Hmmm...

The patch which converted ldlm_lock to use a Linux interval-tree rather
than a lustre interval tree contained:

@@ -619,9 +618,11 @@ struct ldlm_lock {
         */
        struct list_head                l_res_link;
        /**
-        * Tree node for ldlm_extent.
+        * Interval-tree node for ldlm_extent.
         */
-       struct interval_node    l_tree_node;
+       struct rb_node          l_rb;
+       __u64                   __subtree_last;
+
        /**
         * Requested mode.
         * Protected by lr_lock.

So a 'struct interval_node' was replaced with a 'struct rb_node' and a
'__u64'.

A 'struct interval_node' was

-struct interval_node {
-       struct interval_node   *in_left;
-       struct interval_node   *in_right;
-       struct interval_node   *in_parent;
-       unsigned                in_color:1,
-                               in_intree:1, /** set if the node is in tree */
-                               in_res1:30;
-       __u8                in_res2[4];  /** tags, 8-bytes aligned */
-       __u64              in_max_high;
-       struct interval_node_extent {
-               __u64 start;
-               __u64 end;
-       } in_extent;
-};

which, is 7 64-bit words (on a 64-bit host).
The 'struct rb_node' is
struct rb_node {
	unsigned long  __rb_parent_color;
	struct rb_node *rb_right;
	struct rb_node *rb_left;
} __attribute__((aligned(sizeof(long))));

which is 3 64-bit words.  Add the __u64, and we have 4.

So I replaced 7 64-bit words with 4 64-bit words.
I have since also made 'struct portals_handle' (also embedded in
'ldlm_lock') smaller.
So I genuinely don't see any evidence in the code that anyone cares
about how big a 'ldlm_lock' is.
But I'm fairly sure I can keep making it smaller, if you think that
would help.

(Patrick: I do appreciate that you didn't accuse the patch of making the
structure bigger, you were just highlighting the problems that would be
caused if that were true - thanks).

Thanks,
NeilBrown


On Wed, Feb 20 2019, Patrick Farrell wrote:

> Also, many LDLM locks do not have an interval.  The node which has the most of them is generally an MDS, which can have millions in certain scenarios, and makes no use of the interval at all.  This is a lot of lost memory if we're really adding part of the interval_tree in to the lock struct (I haven't looked at the patch).
>
> ________________________________
> From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
> Sent: Wednesday, February 20, 2019 4:37:58 PM
> To: James Simmons; Lustre Developement
> Cc: Vitaly Fertman
> Subject: Re: [lustre-devel] Lustre interval tree problems
>
> On Wed, Feb 20 2019, James Simmons wrote:
>
>> With the port of the interval tree work to the OpenSFS branch several
>> problems have been pointed out in the implementation which impacts
>> performance and the memory footprint in some cases.
>>
>> The biggest issues is the ability to add duplicate locks. The reason
>> the original implementation avoided adding duplicate locks was to
>> avoid the extra compares being done with the same type of locks.
>> Especially in the case of the range lock where you can end up with
>> many duplicate read locks [0-EOF]. Comparing with 1000s of identical
>> read locks will have an impact. Their is teh question of the memory
>> foot print in this case as well. I believe this is the case with the
>> ldlm locks as well since the ability to skip large lock amounts if
>> not matching has been lost.
>>
>> The next problem Vitaly pointed in the implementation is the emebedding
>> of lit_root in ldlm_interval_tree also has a negative impact. Since many
>> locaks are kept in memory he wants to see that ldlm_lock struct stay as
>> small as possible. Explained that is why ldlm_interval was not original
>> embedded but allocated separately. I added him to this chain.
>
> Thanks for this valuable feedback!  I'll look over the code again with
> these issues in mind, and let you know what I find.
>
> NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190221/f6b46fb8/attachment.sig>
