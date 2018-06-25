From: NeilBrown <neilb@suse.com>
Date: Mon, 25 Jun 2018 11:57:06 +1000
Subject: [lustre-devel] [PATCH 1/3] lustre: use
 generic_error_remove_page()
In-Reply-To: <EAC0696A-9C7F-419A-A360-C352537B1DA2@linuxhacker.ru>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669032.10587.11474850109829193046.stgit@noble>
 <alpine.LFD.2.21.1806160115430.15679@casper.infradead.org>
 <87y3ffft80.fsf@notabene.neil.brown.name>
 <61C2F92E-8F88-49C6-83FB-F3013289265C@linuxhacker.ru>
 <877emwg8ao.fsf@notabene.neil.brown.name>
 <87lgb3ag3k.fsf@notabene.neil.brown.name>
 <EAC0696A-9C7F-419A-A360-C352537B1DA2@linuxhacker.ru>
Message-ID: <87d0wf8w7h.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jun 24 2018, Oleg Drokin wrote:

>> On Jun 24, 2018, at 8:02 PM, NeilBrown <neilb@suse.com> wrote:
>> 
>> 
>> lustre's internal ll_invalidate_page() is behaviourally identical to
>> generic_error_remove_page().
>> In the case of lustre it isn't a memory hardware error that requires
>> the page being invalidated, it is the loss of a lock, which will like
>> result in the data changing on the server.
>> In either case, we don't want the page to be accessed any more, so the
>> same removal is appropriate.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>> 
>> I've replaced
>> [PATCH 08/24] lustre: use truncate_inode_page in place of truncate_complete_page
>> with 3 patches, this and the next two.
>
> This looks reasonable. Are you running any tests on this?

Just the sanity tests on a 4-node vcluster.  They haven't caused any
noticeable regressions.

>
> Acked-by: Oleg Drokin <green@linuxhacker.ru>

Thanks,
NeilBrown

>
>> 
>> Thanks,
>> NeilBrown
>> 
>> 
>> drivers/staging/lustre/lustre/llite/llite_internal.h | 17 -----------------
>> drivers/staging/lustre/lustre/llite/vvp_io.c         |  2 +-
>> drivers/staging/lustre/lustre/llite/vvp_page.c       |  2 +-
>> 3 files changed, 2 insertions(+), 19 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
>> index c08a6e14b6d7..22dcabf6de0f 100644
>> --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
>> +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
>> @@ -928,23 +928,6 @@ void policy_from_vma(union ldlm_policy_data *policy, struct vm_area_struct *vma,
>> struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
>> 			       size_t count);
>> 
>> -static inline void ll_invalidate_page(struct page *vmpage)
>> -{
>> -	struct address_space *mapping = vmpage->mapping;
>> -	loff_t offset = vmpage->index << PAGE_SHIFT;
>> -
>> -	LASSERT(PageLocked(vmpage));
>> -	if (!mapping)
>> -		return;
>> -
>> -	/*
>> -	 * truncate_complete_page() calls
>> -	 * a_ops->invalidatepage()->cl_page_delete()->vvp_page_delete().
>> -	 */
>> -	ll_teardown_mmaps(mapping, offset, offset + PAGE_SIZE);
>> -	truncate_complete_page(mapping, vmpage);
>> -}
>> -
>> #define    ll_s2sbi(sb)	(s2lsi(sb)->lsi_llsbi)
>> 
>> /* don't need an addref as the sb_info should be holding one */
>> diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
>> index e7a4778e02e4..5a67955974ad 100644
>> --- a/drivers/staging/lustre/lustre/llite/vvp_io.c
>> +++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
>> @@ -1098,7 +1098,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
>> 	LASSERT(PageLocked(vmpage));
>> 
>> 	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_FAULT_TRUNC_RACE))
>> -		ll_invalidate_page(vmpage);
>> +		generic_error_remove_page(vmpage->mapping, vmpage);
>> 
>> 	size = i_size_read(inode);
>> 	/* Though we have already held a cl_lock upon this page, but
>> diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
>> index 6eb0565ddc22..dcc4d8faa0cd 100644
>> --- a/drivers/staging/lustre/lustre/llite/vvp_page.c
>> +++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
>> @@ -147,7 +147,7 @@ static void vvp_page_discard(const struct lu_env *env,
>> 	if (vpg->vpg_defer_uptodate && !vpg->vpg_ra_used)
>> 		ll_ra_stats_inc(vmpage->mapping->host, RA_STAT_DISCARDED);
>> 
>> -	ll_invalidate_page(vmpage);
>> +	generic_error_remove_page(vmpage->mapping, vmpage);
>> }
>> 
>> static void vvp_page_delete(const struct lu_env *env,
>> -- 
>> 2.14.0.rc0.dirty
>> 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180625/a2a1b8c7/attachment.sig>
