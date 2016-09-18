From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Sun, 18 Sep 2016 20:29:55 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: lustre/ldlm: Fixed
	sparse warnings
In-Reply-To: <57DEF73C.3090807@gmail.com>
References: <1473434435-27025-1-git-send-email-itachi.opsrc@gmail.com>
	<20160912102747.GA13621@kroah.com>
	<47AECAA7-59D7-41DB-9A85-A23ACF6A7B1F@intel.com>
	<57DAE988.6040609@gmail.com>
	<03072924-D829-4AA9-A749-E0B5B70DFCD9@intel.com>
	<57DEF73C.3090807@gmail.com>
Message-ID: <DAAEA517-69C8-4BDC-9F5E-526D7544F9B4@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: nayeem <itachi.opsrc@gmail.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sep 18, 2016, at 14:21, nayeem <itachi.opsrc@gmail.com> wrote:
> On Friday 16 September 2016 01:30 PM, Dilger, Andreas wrote:
>> On Sep 15, 2016, at 12:33, nayeem <itachi.opsrc@gmail.com> wrote:
>>> On Wednesday 14 September 2016 10:44 AM, Dilger, Andreas wrote:
>>>> On Sep 12, 2016, at 04:27, Greg KH <gregkh@linuxfoundation.org> wrote:
>>>>> 
>>>>> On Fri, Sep 09, 2016 at 08:50:35PM +0530, Nayeemahmed Badebade wrote:
>>>>>> Added __acquires / __releases sparse locking annotations
>>>>>> to lock_res_and_lock and unlock_res_and_lock functions in
>>>>>> l_lock.c, to fix below sparse warnings:
>>>>>> 
>>>>>> l_lock.c:47:22: warning: context imbalance in 'lock_res_and_lock' - wrong count at exit
>>>>>> l_lock.c:62:6: warning: context imbalance in 'unlock_res_and_lock' - unexpected unlock
>>>>>> 
>>>>>> Signed-off-by: Nayeemahmed Badebade <itachi.opsrc@gmail.com>
>>>>>> ---
>>>>>> drivers/staging/lustre/lustre/ldlm/l_lock.c | 4 ++++
>>>>>> 1 file changed, 4 insertions(+)
>>>>>> 
>>>>>> diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
>>>>>> index ea8840c..c4b9612 100644
>>>>>> --- a/drivers/staging/lustre/lustre/ldlm/l_lock.c
>>>>>> +++ b/drivers/staging/lustre/lustre/ldlm/l_lock.c
>>>>>> @@ -45,6 +45,8 @@
>>>>>>  * being an atomic operation.
>>>>>>  */
>>>>>> struct ldlm_resource *lock_res_and_lock(struct ldlm_lock *lock)
>>>>>> +				__acquires(&lock->l_lock)
>>>>>> +				__acquires(lock->l_resource)
>>>>> 
>>>>> Hm, these are tricky, I don't want to take this type of change without
>>>>> an ack from the lustre developers...
>>>> 
>>>> The "__acquires(&lock->l_lock)" line here looks correct, along with the
>>>> corresponding "__releases(&lock->l_lock)" at unlock_res_and_lock().
>>>> 
>>>> The problem, however, is that "l_resource" is not a lock, but rather a
>>>> struct.  The call to "lock_res(lock->l_resource)" is actually locking
>>>> "lr_lock" internally.
>>>> 
>>>> It would be better to add "__acquires(&res->lr_lock)" at lock_res() and
>>>> "__releases(&res->lr_lock)" at unlock_res().  That will also forestall
>>>> any other warnings about an imbalance with lock_res()/unlock_res() or
>>>> their callsites.
>>>> 
>>>> Cheers, Andreas
>>>> 
>>> 
>>> Hi Andreas,
>>> 
>>> Thank you for your review comments. I did the change according to your comments and the diff is attached to mail. But this change doesn't seem to fix the sparse warning.
>>> With this change when i compile the code "make C=2 ./drivers/staging/lustre/lustre/", sparse warning still comes:
>> 
>>> {{{
>>>  CHECK   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/l_lock.c
>>> drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/l_lock.c:47:22: warning: context imbalance in 'lock_res_and_lock' - wrong count at exit
>>> drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/l_lock.c:62:6: warning: context imbalance in 'unlock_res_and_lock' - unexpected unlock
>>>  CC [M]  drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/l_lock.o
>>> }}}
>> 
>> Strange, one would think that your patch should work properly.  Maybe the
>> __acquires() label doesn't work on inline functions?
>> 
> 
> I think sparse works on inline functions.
> I ran sparse on a hello world kernel module in different cases explained below
> 
> 
>>> Would it be a good idea to add "__acquires(&lock->l_resource->lr_lock)" & "__acquires(&lock->l_lock)" at lock_res_and_lock() and "__releases(&lock->l_resource->lr_lock)" & "__releases(&lock->l_lock)" at unlock_res_and_lock() ?
>>> Because with that change the sparse warning is fixed.
>>> {{{
>>>  CHECK   drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/l_lock.c
>>>  CC [M]  drivers/staging/lustre/lustre/ptlrpc/../../lustre/ldlm/l_lock.o
>>> }}}
>> 
>> This would also be possible, but then it exposes any callers of lock_res()
>> and unlock() res to similar compiler warnings in the future.  I'm not
>> against this in principle, but it is worthwhile to see why sparse is not
>> handling this case correctly.
>> 
>> Cheers, Andreas
>> 
> 
> case 1:
> -------
> hello.c, where spin_lock() and spin_unlock() are called indirectly via foo_lock() and foo_unlock() in the same function i.e "say_hello()" in below code.
> 
> The following code when checked with sparse doesn't give any warning
> 
> #include<linux/module.h>
> #include<linux/init.h>
> 
> static DEFINE_SPINLOCK(my_lock);
> 
> static inline void foo_lock(spinlock_t *spl)
> {
>        spin_lock(spl);
> }
> 
> static inline void foo_unlock(spinlock_t *spl)
> {
>        spin_unlock(spl);
> }
> 
> static int __init say_hello(void)
> {
>        foo_lock(&my_lock);
>        pr_info("Hello World!\n");
>        foo_unlock(&my_lock);
>        return 0;
> }
> 
> static void __exit cleanup(void)
> {
> }
> 
> module_init(say_hello);
> module_exit(cleanup);
> 
> 
> 
> case 2.
> ------
> The above code when slightly modified so that, spin_lock() is called indirectly via foo_lock() in say_hello() and spin_unlock() via foo_unlock() in cleanup()
> 
> static int __init say_hello(void)
> {
>        foo_lock(&my_lock);
>        pr_info("Hello World!\n");
> 
>        return 0;
> }
> 
> static void __exit cleanup(void)
> {
>        foo_unlock(&my_lock);
> }
> 
> Then sparse gives the warning:
> {{{
> test-module/hello.c:16:19: warning: context imbalance in 'say_hello' - wrong count at exit
> test-module/hello.c:23:20: warning: context imbalance in 'cleanup' - unexpected unlock
> }}}
> To fix this if we put sparse annotations __acquires() at foo_lock() and __releases() at foo_unlock(), then also sparse warnings comes, which is exactly the case with l_lock.c in lustre code.
> 
> The warning will still be thrown if these functions are not inline.
> I think this kind of case sparse is not able to handle, irrespective of whether function is inline or not.
> 
> case 3:
> -------
> Instead of putting sparse annotations at foo_lock and foo_unlock, if we put them at say_hello() and cleanup()
> 
> static int __init say_hello(void)
>                __acquires(&my_lock)
> {
>        foo_lock(&my_lock);
>        pr_info("Hello World!\n");
>        return 0;
> }
> 
> static void __exit cleanup(void)
>                __releases(&my_lock)
> {
>        foo_unlock(&my_lock);
> }
> 
> Then sparse seems to work properly and warning doesn't come.
> 
> So i think in case of l_lock.c in lustre, both "lock_res_and_lock()" and "unlock_res_and_lock" needs to have sparse annotations.
> 
> Please provide your inputs on this.

Originally I was thinking that there may be a bug in sparse to report,
but I think I can agree with your argument.  It isn't "foo_lock()" that has
the locking imbalance (it would always be imbalanced since it is the one
getting the lock in the first place).  Rather, it is say_hello() and
cleanup() that are the unusual functions with the imbalanced locking,
and should be the ones with the annotation.

Thanks for following through with this.  Please submit a patch with your
proposal from two emails ago, with annotations at lock_res_and_lock()
and unlock_res_and_lock().

Cheers, Andreas
