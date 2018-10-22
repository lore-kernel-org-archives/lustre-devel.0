From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Oct 2018 14:09:29 +1100
Subject: [lustre-devel] [PATCH 03/10] lustre: lnd: rework map_on_demand
 behavior
In-Reply-To: <alpine.LFD.2.21.1810201758590.16676@casper.infradead.org>
References: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
 <1539543332-28679-4-git-send-email-jsimmons@infradead.org>
 <87bm7tdrvu.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1810201758590.16676@casper.infradead.org>
Message-ID: <87sh0y8yom.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Oct 20 2018, James Simmons wrote:

>> On Sun, Oct 14 2018, James Simmons wrote:
>> 
>> > @@ -1320,9 +1324,8 @@ static void kiblnd_destroy_fmr_pool(struct kib_fmr_pool *fpo)
>> >  {
>> >  	LASSERT(!fpo->fpo_map_count);
>> >  
>> > -	if (fpo->fpo_is_fmr) {
>> > -		if (fpo->fmr.fpo_fmr_pool)
>> > -			ib_destroy_fmr_pool(fpo->fmr.fpo_fmr_pool);
>> > +	if (fpo->fpo_is_fmr && fpo->fmr.fpo_fmr_pool) {
>> > +		ib_destroy_fmr_pool(fpo->fmr.fpo_fmr_pool);
>> >  	} else {
>> >  		struct kib_fast_reg_descriptor *frd;
>> >  		int i = 0;
>> 
>> This change looks strange.
>> With the new code: if fpo_fmr_pool is NULL, then the fpo_pool_list is
>> destroyed, even though fpo_is_fmr.
>> 
>> Are we sure that is correct??
>> I don't really understand this code so it might be correct, but the
>> change looks wrong.
>> 
>> Can someone please confirm that it really is right - and maybe explain
>> why?
>
> It is wrong!!! The only reason it didn't show up is that fp_fmr_pool is
> very unlikely to NULL. I understand why this bug was introduced since
> its desirable to reduce the indentation. This is the fault of how the
> code is written. To avoid this in the future it should be written:

Thanks for the confirmation.
As the 'else' clause is significantly more indented than the 'then'
cause, reducing the indentation there seems gratuitous.
I've removed the offending hunk from the patch.
If you particularly want to proceed with the version below I won't
object.

>
> if (!fpo->fpo_is_fmr) {
> 	struct kib_fast_reg_descriptor *frd, *tmp;
> 	....
> } else if (fpo->fmr.fpo_fmr_pool) {
> 	ib_destroy_fmr_pool(fpo->fmr.fpo_fmr_pool);
> }
>
> I opened a ticket for https://jira.whamcloud.com/browse/LU-11552 and 
> submitted a patch - https://review.whamcloud.com/#/c/33408. To address
> this.

Thanks for following up this side too!

NeilBrown


>
> So please remove this part from the change. We could redo the patch to
> include the above or I could just send a follow up patch to make this
> code clearer. I leave that up to you.
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181022/4a0138bb/attachment-0001.sig>
