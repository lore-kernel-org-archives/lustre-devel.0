From: NeilBrown <neilb@suse.com>
Date: Fri, 03 Aug 2018 12:36:26 +1000
Subject: [lustre-devel] [PATCH 10/22] Revert "staging: lustre: lnet:
 conrpc: Use list_for_each_entry_safe"
In-Reply-To: <alpine.LFD.2.21.1808020348550.5677@casper.infradead.org>
References: <153292153459.13840.17465048403476297915.stgit@noble>
 <153292186099.13840.6595803769201521471.stgit@noble>
 <alpine.LFD.2.21.1808020348550.5677@casper.infradead.org>
Message-ID: <871sbgp45x.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Aug 02 2018, James Simmons wrote:

>> This reverts commit a9a6cb4f4693253349358f8163d826eb0cfecfbc.
>> 
>> These loops really want to remove everything, and using a
>>   while(!list_empty())
>> loop makes this more obvious.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  drivers/staging/lustre/lnet/selftest/conrpc.c |    5 +++--
>>  1 file changed, 3 insertions(+), 2 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
>> index 95cbd1a14e1b..3afde0141db5 100644
>> --- a/drivers/staging/lustre/lnet/selftest/conrpc.c
>> +++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
>> @@ -1327,7 +1327,6 @@ lstcon_rpc_cleanup_wait(void)
>>  {
>>  	struct lstcon_rpc_trans *trans;
>>  	struct lstcon_rpc *crpc;
>> -	struct lstcon_rpc *temp;
>>  	struct list_head *pacer;
>>  	struct list_head zlist;
>>  
>> @@ -1367,7 +1366,9 @@ lstcon_rpc_cleanup_wait(void)
>>  
>>  	spin_unlock(&console_session.ses_rpc_lock);
>>  
>> -	list_for_each_entry_safe(crpc, temp, &zlist, crp_link) {
>> +	while (!list_empty(&zlist)) {
>> +		crpc = list_entry(zlist.next, lstcon_rpc_t, crp_link);
>> +
>
> Nak. This one needs to be updated to. The typedef lstcon_rpc_t no longer
> exist. Now you need to use struct lstcon_rpc.

Clearly I wasn't compiled with CONFIG_LNET_SELFTEST enabled.  I am now.
Thanks - I've added all your Reviewed-bys.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180803/dfa2a1d9/attachment.sig>
