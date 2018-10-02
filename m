From: NeilBrown <neilb@suse.com>
Date: Tue, 02 Oct 2018 12:25:47 +1000
Subject: [lustre-devel] [PATCH 07/34] lnet: lnet_peer_tables_cleanup:
 use an exclusive lock.
In-Reply-To: <alpine.LFD.2.21.1809292349290.25547@casper.infradead.org>
References: <153783752960.32103.8394391715843917125.stgit@noble>
 <153783763511.32103.5073326313518943569.stgit@noble>
 <alpine.LFD.2.21.1809292349290.25547@casper.infradead.org>
Message-ID: <87pnwtrsno.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Sep 29 2018, James Simmons wrote:

>> Why?? surely this will deadlock.
>> 
>> This is part of
>>     Commit: 58091af960fe ("LU-7734 lnet: Multi-Rail peer split")
>> from upstream lustre, where it is marked:
>>     Signed-off-by: Amir Shehata <amir.shehata@intel.com>
>>     WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
>>     Reviewed-on: http://review.whamcloud.com/18293
>>     Reviewed-by: Olaf Weber <olaf@sgi.com>
>>     Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
>
> The code is right but the commit message needs a update. 
> Olaf, Doug, or Amir can you fill  in the gaps.
>
> Reviewed-by: James Simmons <jsimmons@infradead.org>

thanks

>
> P.S
>     Its strange that git is not sending message to the people in the 
> Reviewed-by:. Maybe git can't handle the indent?

I wasn't asking it to - I was just sending it the list and Oleg,
Andreas, Doug, and you.  Maybe I should ...

Thanks,
NeilBrown

>  
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  drivers/staging/lustre/lnet/lnet/peer.c |   12 ++++++------
>>  1 file changed, 6 insertions(+), 6 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
>> index 53b0ca0a2021..376e3459fa92 100644
>> --- a/drivers/staging/lustre/lnet/lnet/peer.c
>> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
>> @@ -185,9 +185,9 @@ lnet_peer_tables_cleanup(struct lnet_ni *ni)
>>  	 * peers are gateways for.
>>  	 */
>>  	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
>> -		lnet_net_lock(i);
>> +		lnet_net_lock(LNET_LOCK_EX);
>>  		lnet_peer_table_del_rtrs_locked(ni, ptable, i);
>> -		lnet_net_unlock(i);
>> +		lnet_net_unlock(LNET_LOCK_EX);
>>  	}
>>  
>>  	/*
>> @@ -195,17 +195,17 @@ lnet_peer_tables_cleanup(struct lnet_ni *ni)
>>  	 * deathrow.
>>  	 */
>>  	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
>> -		lnet_net_lock(i);
>> +		lnet_net_lock(LNET_LOCK_EX);
>>  		lnet_peer_table_cleanup_locked(ni, ptable);
>> -		lnet_net_unlock(i);
>> +		lnet_net_unlock(LNET_LOCK_EX);
>>  	}
>>  
>>  	/* Cleanup all entries on deathrow. */
>>  	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
>> -		lnet_net_lock(i);
>> +		lnet_net_lock(LNET_LOCK_EX);
>>  		lnet_peer_table_deathrow_wait_locked(ptable, i);
>>  		list_splice_init(&ptable->pt_deathrow, &deathrow);
>> -		lnet_net_unlock(i);
>> +		lnet_net_unlock(LNET_LOCK_EX);
>>  	}
>>  
>>  	while (!list_empty(&deathrow)) {
>> 
>> 
>> 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181002/5b2f42ab/attachment.sig>
