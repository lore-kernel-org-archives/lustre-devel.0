From: NeilBrown <neilb@suse.com>
Date: Fri, 04 May 2018 09:26:36 +1000
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: obdclass: change
 spinlock of key to rwlock
In-Reply-To: <a3594bd7c393418c8fda5150a075ff1a@AcuMS.aculab.com>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
 <1525285308-15347-2-git-send-email-jsimmons@infradead.org>
 <a3594bd7c393418c8fda5150a075ff1a@AcuMS.aculab.com>
Message-ID: <87po2cfhhv.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>, 'James Simmons' <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Lai Siyao <lai.siyao@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre
 Development List <lustre-devel@lists.lustre.org>, Li Xi <lixi@ddn.com>, Gu
 Zheng <gzheng@ddn.com>

On Thu, May 03 2018, David Laight wrote:

> From: James Simmons
>> Sent: 02 May 2018 19:22
>> From: Li Xi <lixi@ddn.com>
>> 
>> Most of the time, keys are never changed. So rwlock might be
>> better for the concurrency of key read.
>
> OTOH unless there is contention on the spin lock during reads the
> additional cost of a rwlock (probably double that of a spinlock)
> will hurt performance.

That's roughly what I was going to say - rwlocks are rarely a win.
I think the second patch which caused the lock to be taken less often
would have a bigger impact that the switch to rwlocks.

However I suspect a better approach would be to investigate some sort of
lockless solution.
I think the use of the spinlock in lu_context_key_register() could be
replaced with a careful cmp_xchg().  I'm less sure about
lu_context_key_degister(), but it might be possible.

>
> ...
>> -	spin_lock(&lu_keys_guard);
>> +	read_lock(&lu_keys_guard);
>>  	atomic_inc(&lu_key_initing_cnt);
>> -	spin_unlock(&lu_keys_guard);
>> +	read_unlock(&lu_keys_guard);
>
> WTF, seems unlikely that you need to hold any kind of lock
> over an atomic_inc().
>
> If this is just ensuring that no code holds the lock then
> it would need to request the write_lock().
> (and would need a comment)

There is a comment - that patch showed the last 2 lines of it.
This is for synchronization with lu_context_key_quiesce().
That spins(!! calling schedule, but still... not good) until
the lu_key_initing_cnt is zero while it holds the write lock.
Then it is sure that the code protected by this counter isn't
running.
I'm sure this can be improved!  I would need to study it carefully to
see how.

Note that I don't object to these patches going in - if they provide a
measurable improvement which seems likely, then in they go.  But I
hope the code won't stay like this long term.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180504/516bfbd4/attachment.sig>
