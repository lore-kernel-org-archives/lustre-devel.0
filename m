From: Patrick Farrell <pfarrell@whamcloud.com>
Date: Wed, 20 Feb 2019 22:54:09 +0000
Subject: [lustre-devel] Lustre interval tree problems
In-Reply-To: <87h8cycchl.fsf@notabene.neil.brown.name>
References: <alpine.LFD.2.21.1902201738170.6267@casper.infradead.org>,
 <87h8cycchl.fsf@notabene.neil.brown.name>
Message-ID: <MN2PR19MB25107E921212A20D9CCE8215C57D0@MN2PR19MB2510.namprd19.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Also, many LDLM locks do not have an interval.  The node which has the most of them is generally an MDS, which can have millions in certain scenarios, and makes no use of the interval at all.  This is a lot of lost memory if we're really adding part of the interval_tree in to the lock struct (I haven't looked at the patch).

________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
Sent: Wednesday, February 20, 2019 4:37:58 PM
To: James Simmons; Lustre Developement
Cc: Vitaly Fertman
Subject: Re: [lustre-devel] Lustre interval tree problems

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

Thanks for this valuable feedback!  I'll look over the code again with
these issues in mind, and let you know what I find.

NeilBrown
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190220/41263bdf/attachment.html>
