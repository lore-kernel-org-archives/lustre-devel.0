From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 7 Mar 2018 21:08:45 +0000
Subject: [lustre-devel] [PATCH 03/17] staging: lustre: statahead: remove
 incorrect test on agl_list_empty()
In-Reply-To: <151994708514.7628.7094184804431206060.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
 <151994708514.7628.7094184804431206060.stgit@noble>
Message-ID: <4D8083A9-175E-418C-ACD3-252A34EF4746@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mar 1, 2018, at 16:31, NeilBrown <neilb@suse.com> wrote:
> 
> Including agl_list_empty() in the wait_event_idle() condition
> is pointless as the body of the loop doesn't do anything
> about the agl list.
> So if the list wasn't empty, the while loop would spin
> indefinitely.
> 
> The test was removed in the lustre-release commit
> 672ab0e00d61 ("LU-3270 statahead: small fixes and cleanup"),
> but not in the Linux commit 5231f7651c55 ("staging: lustre:
> statahead: small fixes and cleanup").
> 
> Fixes: 5231f7651c55 ("staging: lustre: statahead: small fixes and cleanup")
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/llite/statahead.c |    1 -
> 1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
> index 6052bfd7ff05..ba00881a5745 100644
> --- a/drivers/staging/lustre/lustre/llite/statahead.c
> +++ b/drivers/staging/lustre/lustre/llite/statahead.c
> @@ -1124,7 +1124,6 @@ static int ll_statahead_thread(void *arg)
> 	while (thread_is_running(sa_thread)) {
> 		wait_event_idle(sa_thread->t_ctl_waitq,
> 				sa_has_callback(sai) ||
> -				!agl_list_empty(sai) ||
> 				!thread_is_running(sa_thread));
> 
> 		sa_handle_callback(sai);
> 
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
