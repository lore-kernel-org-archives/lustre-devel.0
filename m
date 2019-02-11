From: NeilBrown <neilb@suse.com>
Date: Mon, 11 Feb 2019 11:13:21 +1100
Subject: [lustre-devel] [PATCH 05/21] lustre: use list_first_entry() in
 lustre subdirectory.
In-Reply-To: <06F9EA63-3FD8-4BE3-A27C-1AE9BB65A97F@whamcloud.com>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781279.10620.5804477141390456723.stgit@noble.brown>
 <06F9EA63-3FD8-4BE3-A27C-1AE9BB65A97F@whamcloud.com>
Message-ID: <87y36ngp26.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Feb 08 2019, Andreas Dilger wrote:

> On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
>> 
>> Convert
>>  list_entry(foo->next .....)
>> to
>>  list_first_entry(foo, ....)
>> 
>> in 'lustre'
>> 
>> In several cases the call is combined with
>> a list_empty() test and list_first_entry_or_null() is used
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>
> One question below:
>
>> @@ -912,9 +913,9 @@ static int ll_agl_thread(void *arg)
>> 
>> 	spin_lock(&plli->lli_agl_lock);
>> 	sai->sai_agl_valid = 0;
>> -	while (!list_empty(&sai->sai_agls)) {
>> -		clli = list_entry(sai->sai_agls.next,
>> -				  struct ll_inode_info, lli_agl_list);
>> +	while ((clli = list_first_entry_or_null(&sai->sai_agls,
>> +						struct ll_inode_info,
>> +						lli_agl_list)) != NULL) {
>
> Lustre coding style used to require explicit comparisons against NULL or 0
> to avoid subtle bugs when developers treat pointers like booleans, so I'm
> not against this, but the kernel style is to not do this, like:
>
> 	while ((clli = list_first_entry_or_null(&sai->sai_agls,
> 						struct ll_inode_info,
> 						lli_agl_list))) {
>
> Will there be grief when this is pushed upstream?  In that case, it might
> be better to just use the implicit "!= NULL" and avoid the complaints.
>

I don't think there will be grief.  I personally prefer the explicit
test, and I think I recall Linus once saying he did too.

If you have
  while (p = func()) {

The compile will warn that maybe you meant '=='.
So you need

  while ((p = func())) {

and the extra parentheses look odd.  Make it

   while ((p = func()) != NULL) {

clears it all up.

The pattern
  while.* = .* != NULL

occurs 589 times in the kernel at present including fs/* mm/* net/*
so we certainly would be alone in using it.
  

> Either way, the technical aspects of the patch are OK, so:
>
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

Thanks,
NeilBrown

>
>
> Cheers, Andreas
> ---
> Andreas Dilger
> Principal Lustre Architect
> Whamcloud
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190211/6a5e0587/attachment.sig>
