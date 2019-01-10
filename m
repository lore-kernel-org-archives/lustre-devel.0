From: NeilBrown <neilb@suse.com>
Date: Thu, 10 Jan 2019 16:25:34 +1100
Subject: [lustre-devel] [PATCH 28/29] lustre: osc_request: assorted
 white-space and check-patch fixes.
In-Reply-To: <C6E49B56-15FA-4660-AB79-F68E03E1531B@whamcloud.com>
References: <154701488711.26726.17363928508883972338.stgit@noble>
 <154701504282.26726.12048576544354457365.stgit@noble>
 <C6E49B56-15FA-4660-AB79-F68E03E1531B@whamcloud.com>
Message-ID: <87zhs9gk35.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Jan 10 2019, Andreas Dilger wrote:

> On Jan 8, 2019, at 23:24, NeilBrown <neilb@suse.com> wrote:
>> 
>> Just misc formatting fixes.  Some minot code change
>
> (typo) "minor"
>
>> where an 'else' after 'return' was discarded.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>> drivers/staging/lustre/lustre/osc/osc_request.c |  163 +++++++++++++----------
>> 1 file changed, 89 insertions(+), 74 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
>> index ccc491efa982..c2239c99a7b2 100644
>> --- a/drivers/staging/lustre/lustre/osc/osc_request.c
>> +++ b/drivers/staging/lustre/lustre/osc/osc_request.c
>> 
>> @@ -652,8 +651,8 @@ static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
>> 		 * Wait until the number of on-going destroy RPCs drops
>> 		 * under max_rpc_in_flight
>> 		 */
>> -		rc = l_wait_event_abortable_exclusive(cli->cl_destroy_waitq,
>> -						      osc_can_send_destroy(cli));
>> +		rc = l_wait_event_abortable_exclusive(
>> +			cli->cl_destroy_waitq, osc_can_send_destroy(cli));
>> 		if (rc) {
>> 			ptlrpc_req_finished(req);
>> 			return rc;
>
> I don't really see this change as an improvement?  I'd instead just de-indent
> the osc_can_send_destroy() by a space or two so it fits within 80 colunmns.
> That is IMHO closer to the normal coding style.

That would result in:

CHECK: Alignment should match open parenthesis
#655: FILE: drivers/staging/lustre/lustre/osc/osc_request.c:655:
+		rc = l_wait_event_abortable_exclusive(cli->cl_destroy_waitq,
+						    osc_can_send_destroy(cli));

though now we have:

CHECK: Lines should not end with a '('
#654: FILE: drivers/staging/lustre/lustre/osc/osc_request.c:654:
+		rc = l_wait_event_abortable_exclusive(

I might just leave it as it is, with an 81-column line.

Thanks,
NeilBrown


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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190110/937db209/attachment.sig>
