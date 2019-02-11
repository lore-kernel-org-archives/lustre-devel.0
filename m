From: NeilBrown <neilb@suse.com>
Date: Mon, 11 Feb 2019 11:24:26 +1100
Subject: [lustre-devel] [PATCH 02/21] lustre: obd_class: remove
 csi_barrier from struct cl_sync_io
In-Reply-To: <28122F36-DB60-49B8-82E5-1C2F9546C83E@whamcloud.com>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781242.10620.4427066512247634121.stgit@noble.brown>
 <28122F36-DB60-49B8-82E5-1C2F9546C83E@whamcloud.com>
Message-ID: <87va1rgojp.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Feb 08 2019, Andreas Dilger wrote:

> On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
>> 
>> This flag is used to ensure that structure isn't freed before
>> the wakeup completes.  The same can be achieved using the
>> csi_waitq.lock and calling wake_up_all_locked().
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>> drivers/staging/lustre/lustre/include/cl_object.h |    2 --
>> drivers/staging/lustre/lustre/obdclass/cl_io.c    |   16 +++++++---------
>> 2 files changed, 7 insertions(+), 11 deletions(-)
>> 
>> @@ -1080,11 +1079,10 @@ int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
>> 	} else {
>> 		rc = anchor->csi_sync_rc;
>> 	}
>> +	/* We take the lock to ensure that cl_sync_io_note() has finished */
>> +	spin_lock(&anchor->csi_waitq.lock);
>> 	LASSERT(atomic_read(&anchor->csi_sync_nr) == 0);
>> -
>> -	/* wait until cl_sync_io_note() has done wakeup */
>> -	while (unlikely(atomic_read(&anchor->csi_barrier) != 0))
>> -		cpu_relax();
>> +	spin_unlock(&anchor->csi_waitq.lock);
>> 
>> 	return rc;
>> }
>> @@ -1104,11 +1102,11 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
>> 	 * IO.
>> 	 */
>> 	LASSERT(atomic_read(&anchor->csi_sync_nr) > 0);
>> -	if (atomic_dec_and_test(&anchor->csi_sync_nr)) {
>> +	if (atomic_dec_and_lock(&anchor->csi_sync_nr,
>> +				&anchor->csi_waitq.lock)) {
>> 
>> -		wake_up_all(&anchor->csi_waitq);
>> -		/* it's safe to nuke or reuse anchor now */
>> -		atomic_set(&anchor->csi_barrier, 0);
>> +		wake_up_all_locked(&anchor->csi_waitq);
>> +		spin_unlock(&anchor->csi_waitq.lock);
>
> Maybe a matching comment here that the lock is to synchronize with cl_sync_io_wait() cleanup?
> Either way,
>
Good idea.  I added

		/*
		 * Holding the lock across both the decrement and
		 * the wakeup ensures cl_sync_io_wait() doesn't complete
		 * before the wakeup completes.
		 */

> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190211/56192e20/attachment.sig>
