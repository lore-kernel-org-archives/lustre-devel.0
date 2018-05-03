From: David Laight <David.Laight@ACULAB.COM>
Date: Thu, 3 May 2018 13:50:07 +0000
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: obdclass: change
 spinlock of key to rwlock
In-Reply-To: <1525285308-15347-2-git-send-email-jsimmons@infradead.org>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
 <1525285308-15347-2-git-send-email-jsimmons@infradead.org>
Message-ID: <a3594bd7c393418c8fda5150a075ff1a@AcuMS.aculab.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'James Simmons' <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Lai Siyao <lai.siyao@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, NeilBrown <neilb@suse.com>
Cc: Gu Zheng <gzheng@ddn.com>, Li Xi <lixi@ddn.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: James Simmons
> Sent: 02 May 2018 19:22
> From: Li Xi <lixi@ddn.com>
> 
> Most of the time, keys are never changed. So rwlock might be
> better for the concurrency of key read.

OTOH unless there is contention on the spin lock during reads the
additional cost of a rwlock (probably double that of a spinlock)
will hurt performance.

...
> -	spin_lock(&lu_keys_guard);
> +	read_lock(&lu_keys_guard);
>  	atomic_inc(&lu_key_initing_cnt);
> -	spin_unlock(&lu_keys_guard);
> +	read_unlock(&lu_keys_guard);

WTF, seems unlikely that you need to hold any kind of lock
over an atomic_inc().

If this is just ensuring that no code holds the lock then
it would need to request the write_lock().
(and would need a comment)

	David
