From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 4 May 2018 00:11:54 +0000
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: obdclass: change
 spinlock of key to rwlock
In-Reply-To: <a3594bd7c393418c8fda5150a075ff1a@AcuMS.aculab.com>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
 <1525285308-15347-2-git-send-email-jsimmons@infradead.org>
 <a3594bd7c393418c8fda5150a075ff1a@AcuMS.aculab.com>
Message-ID: <55458B75-4105-4F4F-BB50-3D506611AB24@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Gu Zheng <gzheng@ddn.com>, Li Xi <lixi@ddn.com>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin,
 Oleg" <oleg.drokin@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, "Siyao,
 Lai" <lai.siyao@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On May 3, 2018, at 07:50, David Laight <David.Laight@ACULAB.COM> wrote:
> 
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
> 
> ...
>> -	spin_lock(&lu_keys_guard);
>> +	read_lock(&lu_keys_guard);
>> 	atomic_inc(&lu_key_initing_cnt);
>> -	spin_unlock(&lu_keys_guard);
>> +	read_unlock(&lu_keys_guard);
> 
> WTF, seems unlikely that you need to hold any kind of lock
> over an atomic_inc().
> 
> If this is just ensuring that no code holds the lock then
> it would need to request the write_lock().
> (and would need a comment)

There was a fair amount of benchmarking done for this that shows the
performance is significantly improved with the patch, which can be
seen in the ticket that was referenced in the original commit comment:

https://jira.hpdd.intel.com/browse/LU-6800?focusedCommentId=121776#comment-121776

That said, it might be good to include this information into the
commit comment itself.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
