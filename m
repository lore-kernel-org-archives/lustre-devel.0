From: NeilBrown <neilb@suse.com>
Date: Tue, 03 Apr 2018 08:34:00 +1000
Subject: [lustre-devel] [PATCH 13/17] staging: lustre: libcfs: remove
 cfs_timeout_cap()
In-Reply-To: <346B8E2C-5842-4771-86D8-CBB5CEF2DC35@intel.com>
References: <152229732768.27689.4800156943561963977.stgit@noble>
 <152229760874.27689.12453214678546053828.stgit@noble>
 <346B8E2C-5842-4771-86D8-CBB5CEF2DC35@intel.com>
Message-ID: <87k1tp1bmv.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 02 2018, Dilger, Andreas wrote:

> On Mar 28, 2018, at 22:26, NeilBrown <neilb@suse.com> wrote:

>> diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
>> index ff3aae2f1231..ecb2126a9e6f 100644
>> --- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
>> +++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-time.h
>> @@ -78,7 +78,7 @@ static inline int cfs_time_beforeq_64(u64 t1, u64 t2)
>> /*
>>  * One jiffy
>>  */
>> -#define CFS_TICK		(1)
>> +#define CFS_TICK		(1UL)
>
> It seems like CFS_TICK is mostly useless as well and could just be dropped?

Possibly, but I don't know what its purpose is so I didn't want to just
drop it in the middle of a patch that is performing an idempotent
transformation.

Do you know why the one place that uses CFS_TICK wants to protect about
a timeout of zero?  Maybe because the old l_wait_event() treated a
timeout of zero as meaning no timeout?
In that case this really is irrelevant now and that
wait_event_idle_timeout() should just use "timeout" directly.

Thanks,
NeilBrown


>
>> #define CFS_DURATION_T	  "%ld"
>> 
>> diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
>> index 4a9d1f189d01..dd4fd54128dd 100644
>> --- a/drivers/staging/lustre/lustre/ptlrpc/import.c
>> +++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
>> @@ -1486,7 +1486,7 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
>> 	}
>> 
>> 	if (ptlrpc_import_in_recovery(imp)) {
>> -		long timeout;
>> +		unsigned long timeout;
>> 
>> 		if (AT_OFF) {
>> 			if (imp->imp_server_timeout)
>> @@ -1501,7 +1501,7 @@ int ptlrpc_disconnect_import(struct obd_import *imp, int noclose)
>> 
>> 		if (wait_event_idle_timeout(imp->imp_recovery_waitq,
>> 					    !ptlrpc_import_in_recovery(imp),
>> -					    cfs_timeout_cap(timeout)) == 0)
>> +					    max(timeout, CFS_TICK)) == 0)
>> 			l_wait_event_abortable(
>> 				imp->imp_recovery_waitq,
>> 				!ptlrpc_import_in_recovery(imp));
>> 
>> 
>
> Cheers, Andreas
> --
> Andreas Dilger
> Lustre Principal Architect
> Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180403/d8e8f6a8/attachment.sig>
