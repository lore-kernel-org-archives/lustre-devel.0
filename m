From: NeilBrown <neilb@suse.com>
Date: Wed, 13 Jun 2018 22:02:55 +1000
Subject: [lustre-devel] [PATCH] staging: lustre: add error handling for
 try_module_get
In-Reply-To: <ed5d91f54b5a4776a66df87b645b0ee9@AcuMS.aculab.com>
References: <1528778968-42225-1-git-send-email-jiazhouyang09@gmail.com>
 <ed5d91f54b5a4776a66df87b645b0ee9@AcuMS.aculab.com>
Message-ID: <87k1r2j3m8.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>, 'Zhouyang Jia' <jiazhouyang09@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Haneen Mohammed <hamohammed.sa@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, "Gustavo A. R. Silva" <garsilva@embeddedor.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jun 13 2018, David Laight wrote:

> From: Zhouyang Jia
>> Sent: 12 June 2018 05:49
>> 
>> When try_module_get fails, the lack of error-handling code may
>> cause unexpected results.
>> 
>> This patch adds error-handling code after calling try_module_get.
> ...
>> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
>> @@ -2422,7 +2422,10 @@ ksocknal_base_startup(void)
>> 
>>  	/* flag lists/ptrs/locks initialised */
>>  	ksocknal_data.ksnd_init = SOCKNAL_INIT_DATA;
>> -	try_module_get(THIS_MODULE);
>> +	if (!try_module_get(THIS_MODULE)) {
>> +		CERROR("%s: cannot get module\n", __func__);
>> +		goto failed;
>> +	}
>
>
> Can try_module_get(THIS_MODULE) ever fail?

Yes.

> Since you are running code in 'THIS_MODULE' the caller must have a
> reference that can't go away.

Not necessarily, though it does usually work that way.

try_module_get() can fail while the exit function is running, but it is
safe to run code in the module until the exit function completes.
So if the exit function takes a lock, then other code can safely run
code in the module while holding the lock, but not holding a reference
to the module.  If this code calls try_module_get(), it could fail.

That is exactly what is happening here.
ksoclnd_exit() calls lnet_unregister_lnd() which takes
the_lnet.ln_lnd_mutex.

ksocknal_base_startup() is called from ksocknal_startup()
which is the_ksocklnd.lnd_startup and is called, from
lnet_startup_lndni(), with that lock held.

> So try_module_get() just increments the count that is already greater
> than zero.
>
> Similarly module_put(THIS_MODULE) must never be able to release the
> last reference.

It can if a suitable lock is held.

> Any such calls that aren't in error paths after try_module_get() are
> probably buggy.
Being in an error path doesn't make it safe.
module_put(THIS_MODULE) can only be safe if a lock is held which
prevents the exit function from completing.  Some code outside the
module must release the lock.

Having said that, I don't really like this approach.  I much prefer for
the module reference to be taken and put outside of the module - it
seems less error-prone.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180613/d4ecae9b/attachment.sig>
