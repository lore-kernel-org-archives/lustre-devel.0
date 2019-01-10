From: NeilBrown <neilb@suse.com>
Date: Thu, 10 Jan 2019 15:04:05 +1100
Subject: [lustre-devel] [PATCH 23/29] lustre: osc_cache: remove
 'transient' arg from osc_enter_cache_try
In-Reply-To: <87E1C21A-052C-46A7-81AA-2183EB3BB178@whamcloud.com>
References: <154701488711.26726.17363928508883972338.stgit@noble>
 <154701504254.26726.7702205638412400024.stgit@noble>
 <87E1C21A-052C-46A7-81AA-2183EB3BB178@whamcloud.com>
Message-ID: <87bm4pi2fe.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jan 10 2019, Andreas Dilger wrote:

> On Jan 8, 2019, at 23:24, NeilBrown <neilb@suse.com> wrote:
>> 
>> This arg is always '0', so remove it.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>
> Out of curiosity, how would you find something like this?  Just
> through code reading, or do you have some sort of static analysis
> tool that shows this is dead code?

Just through code inspection - exactly as you demonstrate below :-)

I'll add the changes you suggest, probably all in the one patch if that
ends up looking OK.

Thanks,
NeilBrown


>
> Digging into this a bit more, it looks like this is the only place
> that increments cl_dirty_transit and sets OBD_BRW_NOCACHE, which
> means the corresponding code in osc_release_write_grant() that checks
> OBD_BRW_NOCACHE and decrements cl_dirty_transit is also dead, which
> is good otherwise there would have been some kind of accounting leak.
>
> That further implies that cl_dirty_transit is unused and can be removed,
> along with obd_dirty_transit_pages.  The OBD_BRW_NOCACHE flag is part
> of the wire protocol, but it looks like this was never actually sent on
> the wire, just an internal housekeeping flag, so it should be marked like:
>
> /* #define OBD_BRW_NOCACHE		0x400 internal use only 2.2.57-2.12 */
>
> The follow-on cleanup could be part of this patch or a separate one.
>
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
>
>> ---
>> drivers/staging/lustre/lustre/osc/osc_cache.c |   11 +++--------
>> 1 file changed, 3 insertions(+), 8 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
>> index 8a68d3eb9314..b4bb36926046 100644
>> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
>> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
>> @@ -1535,7 +1535,7 @@ static void osc_exit_cache(struct client_obd *cli, struct osc_async_page *oap)
>>  */
>> static bool osc_enter_cache_try(struct client_obd *cli,
>> 				struct osc_async_page *oap,
>> -				int bytes, int transient)
>> +				int bytes)
>> {
>> 	OSC_DUMP_GRANT(D_CACHE, cli, "need:%d\n", bytes);
>> 
>> @@ -1545,11 +1545,6 @@ static bool osc_enter_cache_try(struct client_obd *cli,
>> 	if (cli->cl_dirty_pages < cli->cl_dirty_max_pages &&
>> 	    atomic_long_read(&obd_dirty_pages) + 1 <= obd_max_dirty_pages) {
>> 		osc_consume_write_grant(cli, &oap->oap_brw_page);
>> -		if (transient) {
>> -			cli->cl_dirty_transit++;
>> -			atomic_long_inc(&obd_dirty_transit_pages);
>> -			oap->oap_brw_flags |= OBD_BRW_NOCACHE;
>> -		}
>> 		return true;
>> 	} else {
>> 		__osc_unreserve_grant(cli, bytes, bytes);
>> @@ -1618,7 +1613,7 @@ static int osc_enter_cache(const struct lu_env *env, struct client_obd *cli,
>> 	remain = wait_event_idle_exclusive_timeout_cmd(
>> 		cli->cl_cache_waiters,
>> 		(entered = osc_enter_cache_try(
>> -			cli, oap, bytes, 0)) ||
>> +			cli, oap, bytes)) ||
>> 		(cli->cl_dirty_pages == 0 &&
>> 		 cli->cl_w_in_flight == 0),
>> 		timeout,
>> @@ -2396,7 +2391,7 @@ int osc_queue_async_io(const struct lu_env *env, struct cl_io *io,
>> 
>> 		/* it doesn't need any grant to dirty this page */
>> 		spin_lock(&cli->cl_loi_list_lock);
>> -		if (!osc_enter_cache_try(cli, oap, grants, 0)) {
>> +		if (!osc_enter_cache_try(cli, oap, grants)) {
>> 			grants = 0;
>> 			need_release = 1;
>> 		}
>> 
>> 
>
> Cheers, Andreas
> ---
> Andreas Dilger
> CTO Whamcloud
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190110/a2c410d6/attachment.sig>
