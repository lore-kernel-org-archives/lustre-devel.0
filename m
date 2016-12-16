From: Xiong, Jinshan <jinshan.xiong@intel.com>
Date: Fri, 16 Dec 2016 17:23:03 +0000
Subject: [lustre-devel] [PATCH] staging : lustre : Remove braces from
 single-line body.
In-Reply-To: <1481904353.29291.87.camel@perches.com>
References: <1481898571-16842-1-git-send-email-khan.tabrez21@gmail.com>
	<1481904353.29291.87.camel@perches.com>
Message-ID: <F553A04A-251B-4356-BBD0-F64513395B5A@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>
Cc: Tabrez khan <khan.tabrez21@gmail.com>, "Dilger, Andreas" <andreas.dilger@intel.com>, "jsimmons@infradead.org" <jsimmons@infradead.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>


> On Dec 16, 2016, at 8:05 AM, Joe Perches <joe@perches.com> wrote:
> 
> On Fri, 2016-12-16 at 19:59 +0530, Tabrez khan wrote:
>> Remove unnecessary braces {} for single while statement.
> 
> Your patch is fine Tabrez, but to the lustre folk:
> 
>> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> []
>> @@ -1371,9 +1371,9 @@ int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
> 	LASSERT(atomic_read(&anchor->csi_sync_nr) == 0);
> 
> 	/* wait until cl_sync_io_note() has done wakeup */
> -	while (unlikely(atomic_read(&anchor->csi_barrier) != 0)) {
> +	while (unlikely(atomic_read(&anchor->csi_barrier) != 0))
> 		cpu_relax();
> -	}
> +
> 
> What if the wakeup never occurs/succeeds?
> Should there be a timeout?

There is no wakeup at all. This piece of code is to solve the preempting race condition in cl_sync_io_end(), where it calls wake_up_all() to wake up the cl_sync_io_wait() process, and then is preempted _inside_ wake_up_all(), and then cl_sync_io_wait() process gains the CPU and frees memory cl_sync_io. Therefore when cl_sync_io_end() comes back to finish its work in wake_up_all(), a piece of freed memory will be accessed.

csi_barrier is proposed to solve this problem, which makes sure wake_up_all() is complete before cl_sync_io_wait() can continue. It should be a really short time so it?s reasonable for cl_sync_io_wait() to do a busy loop wait.

Jinshan

> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
