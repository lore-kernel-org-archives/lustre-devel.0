From: NeilBrown <neilb@suse.com>
Date: Thu, 21 Feb 2019 12:00:30 +1100
Subject: [lustre-devel] Lustre interval tree problems
In-Reply-To: <alpine.LFD.2.21.1902201738170.6267@casper.infradead.org>
References: <alpine.LFD.2.21.1902201738170.6267@casper.infradead.org>
Message-ID: <874l8yc5w1.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Feb 20 2019, James Simmons wrote:

> With the port of the interval tree work to the OpenSFS branch several 
> problems have been pointed out in the implementation which impacts
> performance and the memory footprint in some cases.
>
> The biggest issues is the ability to add duplicate locks. The reason
> the original implementation avoided adding duplicate locks was to
> avoid the extra compares being done with the same type of locks.
> Especially in the case of the range lock where you can end up with
> many duplicate read locks [0-EOF]. Comparing with 1000s of identical
> read locks will have an impact. Their is teh question of the memory
> foot print in this case as well. I believe this is the case with the
> ldlm locks as well since the ability to skip large lock amounts if
> not matching has been lost.
>
> The next problem Vitaly pointed in the implementation is the emebedding
> of lit_root in ldlm_interval_tree also has a negative impact. Since many
> locaks are kept in memory he wants to see that ldlm_lock struct stay as
> small as possible. Explained that is why ldlm_interval was not original
> embedded but allocated separately. I added him to this chain.

I've replied separately about the size of struct ldlm_lock, but this
last point is either talking about something different, or is badly
confused.
In either case, I think some clarity might help.

lit_root in struct ldlm_interval_tree was indeed changed from a pointer
to an embedded 'struct rb_root_cached'.
rb_root_cached contains 2 pointers, so this replaces one pointer with two,
a growth of one pointer.
The ldlm_interval_tree also contains
	int			lit_size;
	enum ldlm_mode		lit_mode;  /* lock mode */
which would be equivalent to 1 more (64 bit) pointer.

ldlm_interval_tree only exists when allocated when allocated in
ldlm_resource_new() and assigned to res->lr_itree (still a pointer)
which is only done for resources of type LDLM_EXTENT.  Such a resource
will also need an interval tree, and now it gets one which uses 3 longs
instead of 2.

If this space usage is a problem (it isn't a problem for 'struct
ldlm_lock'), then I'm fairly sure we can find other places to save
space, to make up for it

I'll go look into the issue with duplicate ranges now.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190221/346e2f41/attachment.sig>
