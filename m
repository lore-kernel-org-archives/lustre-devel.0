From: James Simmons <jsimmons@infradead.org>
Date: Tue, 24 Oct 2017 23:20:35 +0100 (BST)
Subject: [lustre-devel] [PATCH 0/9] Assorted cleanups for
 staging/.../lustre/ldlm/ldlm_flock.c
In-Reply-To: <150871988297.3340.4522589460981284121.stgit@noble>
References: <150871988297.3340.4522589460981284121.stgit@noble>
Message-ID: <alpine.LFD.2.20.1710242320020.20646@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, linux-kernel@vger.kernel.org


> This file contains quite a bit of dead code and unused variables.
> This patch series cleans it up in various ways.
> It should change behaviour at all, just code
> readability/maintainabilty.
> 
> I sent the back in July but got not response, possibly because there
> were included with other patches which caused a distraction.
> So here they are by themselves.

Thanks for separating them out. I will give them a spin.

> Thanks,
> NeilBrown
> 
> 
> ---
> 
> NeilBrown (9):
>       staging: lustre: ldlm: remove 'first_enq' arg from ldlm_process_flock_lock()
>       staging: lustre: ldlm: remove unused 'work_list' arg from ldlm_process_flock_lock()
>       staging: lustre: ldlm: remove unneeded 'err' arg to ldlm_process_flock_lock()
>       staging: lustre: ldlm: remove 'flags' arg from ldlm_process_flock_lock()
>       staging: lustre: ldlm: remove unused 'overlaps' variable
>       staging: lustre: ldlm: remove 'flags' arg from ldlm_flock_destroy()
>       staging: lustre: ldlm: tidy list walking in ldlm_flock()
>       staging: lustre: ldlm: remove unnecessary 'ownlocks' variable.
>       staging: lustre: ldlm: remove unused field 'fwd_generation'
> 
> 
>  drivers/staging/lustre/lustre/ldlm/ldlm_flock.c |  208 +++++------------------
>  1 file changed, 42 insertions(+), 166 deletions(-)
> 
> --
> Signature
> 
> 
