From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 14 Sep 2016 05:14:02 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: lustre/ldlm: Fixed
	sparse warnings
In-Reply-To: <20160912102747.GA13621@kroah.com>
References: <1473434435-27025-1-git-send-email-itachi.opsrc@gmail.com>
	<20160912102747.GA13621@kroah.com>
Message-ID: <47AECAA7-59D7-41DB-9A85-A23ACF6A7B1F@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Nayeemahmed Badebade <itachi.opsrc@gmail.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sep 12, 2016, at 04:27, Greg KH <gregkh@linuxfoundation.org> wrote:
> 
> On Fri, Sep 09, 2016 at 08:50:35PM +0530, Nayeemahmed Badebade wrote:
>> Added __acquires / __releases sparse locking annotations
>> to lock_res_and_lock and unlock_res_and_lock functions in
>> l_lock.c, to fix below sparse warnings:
>> 
>> l_lock.c:47:22: warning: context imbalance in 'lock_res_and_lock' - wrong count at exit
>> l_lock.c:62:6: warning: context imbalance in 'unlock_res_and_lock' - unexpected unlock
>> 
>> Signed-off-by: Nayeemahmed Badebade <itachi.opsrc@gmail.com>
>> ---
>> drivers/staging/lustre/lustre/ldlm/l_lock.c | 4 ++++
>> 1 file changed, 4 insertions(+)
>> 
>> diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
>> index ea8840c..c4b9612 100644
>> --- a/drivers/staging/lustre/lustre/ldlm/l_lock.c
>> +++ b/drivers/staging/lustre/lustre/ldlm/l_lock.c
>> @@ -45,6 +45,8 @@
>>  * being an atomic operation.
>>  */
>> struct ldlm_resource *lock_res_and_lock(struct ldlm_lock *lock)
>> +				__acquires(&lock->l_lock)
>> +				__acquires(lock->l_resource)
> 
> Hm, these are tricky, I don't want to take this type of change without
> an ack from the lustre developers...

The "__acquires(&lock->l_lock)" line here looks correct, along with the
corresponding "__releases(&lock->l_lock)" at unlock_res_and_lock().

The problem, however, is that "l_resource" is not a lock, but rather a
struct.  The call to "lock_res(lock->l_resource)" is actually locking
"lr_lock" internally.

It would be better to add "__acquires(&res->lr_lock)" at lock_res() and
"__releases(&res->lr_lock)" at unlock_res().  That will also forestall
any other warnings about an imbalance with lock_res()/unlock_res() or
their callsites.

Cheers, Andreas
