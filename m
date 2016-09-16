From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 16 Sep 2016 08:00:30 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: lustre/ldlm: Fixed
	sparse warnings
In-Reply-To: <57DAE988.6040609@gmail.com>
References: <1473434435-27025-1-git-send-email-itachi.opsrc@gmail.com>
	<20160912102747.GA13621@kroah.com>
	<47AECAA7-59D7-41DB-9A85-A23ACF6A7B1F@intel.com>
	<57DAE988.6040609@gmail.com>
Message-ID: <03072924-D829-4AA9-A749-E0B5B70DFCD9@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: nayeem <itachi.opsrc@gmail.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sep 15, 2016, at 12:33, nayeem <itachi.opsrc@gmail.com> wrote:
> On Wednesday 14 September 2016 10:44 AM, Dilger, Andreas wrote:
>> On Sep 12, 2016, at 04:27, Greg KH <gregkh@linuxfoundation.org> wrote:
>>> 
>>> On Fri, Sep 09, 2016 at 08:50:35PM +0530, Nayeemahmed Badebade wrote:
>>>> Added __acquires / __releases sparse locking annotations
>>>> to lock_res_and_lock and unlock_res_and_lock functions in
>>>> l_lock.c, to fix below sparse warnings:
>>>> 
>>>> l_lock.c:47:22: warning: context imbalance in 'lock_res_and_lock' - wrong count at exit
>>>> l_lock.c:62:6: warning: context imbalance in 'unlock_res_and_lock' - unexpected unlock
>>>> 
>>>> Signed-off-by: Nayeemahmed Badebade <itachi.opsrc@gmail.com>
>>>> ---
>>>> drivers/staging/lustre/lustre/ldlm/l_lock.c | 4 ++++
>>>> 1 file changed, 4 insertions(+)
>>>> 
>>>> diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
>>>> index ea8840c..c4b9612 100644
>>>> --- a/drivers/staging/lustre/lustre/ldlm/l_lock.c
>>>> +++ b/drivers/staging/lustre/lustre/ldlm/l_lock.c
>>>> @@ -45,6 +45,8 @@
>>>>  * being an atomic operation.
>>>>  */
>>>> struct ldlm_resource *lock_res_and_lock(struct ldlm_lock *lock)
>>>> +				__acquires(&lock->l_lock)
>>>> +				__acquires(lock->l_resource)
>>> 
>>> Hm, these are tricky, I don't want to take this type of change without
>>> an ack from the lustre developers...
>> 
>> The "__acquires(&lock->l_lock)" line here looks correct, along with the
>> corresponding "__releases(&lock->l_lock)" at unlock_res_and_lock().
>> 
>> The problem, however, is that "l_resource" is not a lock, but rather a
>> struct.  The call to "lock_res(lock->l_resource)" is actually locking
>> "lr_lock" internally.
>> 
>> It would be better to add "__acquires(&res->lr_lock)" at lock_res() and
>> "__releases(&res->lr_lock)" at unlock_res().  That will also forestall
>> any other warnings about an imbalance with lock_res()/unlock_res() or
>> their callsites.
>> 
>> Cheers, Andreas
>> 
> 
> Hi Andreas,
> 
> Thank you for your review comments. I did the change according to your comments and the diff is attached to mail. But this change doesn't seem to fix the sparse warning.
> With this change when i compile the code "make C=2 ./drivers/staging/lustre/lustre/", sparse warning still comes:

> {{{
>  CHECK   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/l_lock.c
> drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/l_lock.c:47:22: warning: context imbalance in 'lock_res_and_lock' - wrong count at exit
> drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/l_lock.c:62:6: warning: context imbalance in 'unlock_res_and_lock' - unexpected unlock
>  CC [M]  drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/l_lock.o
> }}}

Strange, one would think that your patch should work properly.  Maybe the
__acquires() label doesn't work on inline functions?

> Would it be a good idea to add "__acquires(&lock->l_resource->lr_lock)" & "__acquires(&lock->l_lock)" at lock_res_and_lock() and "__releases(&lock->l_resource->lr_lock)" & "__releases(&lock->l_lock)" at unlock_res_and_lock() ?
> Because with that change the sparse warning is fixed.
> {{{
>  CHECK   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/l_lock.c
>  CC [M]  drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/l_lock.o
> }}}

This would also be possible, but then it exposes any callers of lock_res()
and unlock() res to similar compiler warnings in the future.  I'm not
against this in principle, but it is worthwhile to see why sparse is not
handling this case correctly.

Cheers, Andreas

> Could you please confirm this.
> 
> Regards,
> Nayeem
> 
> <sparse-warnings-fix-patch-v2.patch>
