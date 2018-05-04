From: NeilBrown <neilb@suse.com>
Date: Fri, 04 May 2018 10:53:36 +1000
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: obdclass: change
 spinlock of key to rwlock
In-Reply-To: <55458B75-4105-4F4F-BB50-3D506611AB24@intel.com>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
 <1525285308-15347-2-git-send-email-jsimmons@infradead.org>
 <a3594bd7c393418c8fda5150a075ff1a@AcuMS.aculab.com>
 <55458B75-4105-4F4F-BB50-3D506611AB24@intel.com>
Message-ID: <87a7tgfdgv.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>, David Laight <David.Laight@ACULAB.COM>
Cc: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, "Siyao, Lai" <lai.siyao@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Li Xi <lixi@ddn.com>, Gu Zheng <gzheng@ddn.com>

On Fri, May 04 2018, Dilger, Andreas wrote:

> On May 3, 2018, at 07:50, David Laight <David.Laight@ACULAB.COM> wrote:
>> 
>> From: James Simmons
>>> Sent: 02 May 2018 19:22
>>> From: Li Xi <lixi@ddn.com>
>>> 
>>> Most of the time, keys are never changed. So rwlock might be
>>> better for the concurrency of key read.
>> 
>> OTOH unless there is contention on the spin lock during reads the
>> additional cost of a rwlock (probably double that of a spinlock)
>> will hurt performance.
>> 
>> ...
>>> -	spin_lock(&lu_keys_guard);
>>> +	read_lock(&lu_keys_guard);
>>> 	atomic_inc(&lu_key_initing_cnt);
>>> -	spin_unlock(&lu_keys_guard);
>>> +	read_unlock(&lu_keys_guard);
>> 
>> WTF, seems unlikely that you need to hold any kind of lock
>> over an atomic_inc().
>> 
>> If this is just ensuring that no code holds the lock then
>> it would need to request the write_lock().
>> (and would need a comment)
>
> There was a fair amount of benchmarking done for this that shows the
> performance is significantly improved with the patch, which can be
> seen in the ticket that was referenced in the original commit comment:
>
> https://jira.hpdd.intel.com/browse/LU-6800?focusedCommentId=121776#comment-121776

That does surprise me.  The only places where the lock is held for read
are very short - clearing a few fields or incrementing a value.
But numbers don't lie.
I wonder if the next patch would have had just as big an effect. Taking
and dropping the lock 40 times is not likely to be good for performance.

Thanks,
NeilBrown


>
> That said, it might be good to include this information into the
> commit comment itself.
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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180504/944fe0df/attachment.sig>
