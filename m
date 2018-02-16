From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 16 Feb 2018 15:18:43 +0100
Subject: [lustre-devel] [PATCH 08/19 - v2] staging: lustre: simplify
 waiting in ldlm_completion_ast()
In-Reply-To: <87fu64r6ed.fsf@notabene.neil.brown.name>
References: <151847037709.22826.16175867257667686132.stgit@noble>
 <151847055674.22826.12912356108048917428.stgit@noble>
 <87fu64r6ed.fsf@notabene.neil.brown.name>
Message-ID: <20180216141843.GA22540@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

On Wed, Feb 14, 2018 at 07:17:30AM +1100, NeilBrown wrote:
> 
> If a signal-callback (lwi_on_signal) is set without lwi_allow_intr, as
> is the case in ldlm_completion_ast(), the behavior depends on the
> timeout set.
> 
> If a timeout is set, then signals are ignored.  If the timeout is
> reached, the timeout handler is called.  If the timeout handler
> return 0, which ldlm_expired_completion_wait() always does, the
> l_wait_event() switches to exactly the behavior if no timeout was set.
> 
> If no timeout is set, then "fatal" signals are not ignored.  If one
> arrives the callback is run, but as the callback is empty in this
> case, that is not relevant.
> 
> This can be simplified to:
>  if a timeout is wanted
>      wait_event_idle_timeout()
>      if that timed out, call the timeout handler
>  l_wait_event_abortable()
> 
> i.e. the code always waits indefinitely.  Sometimes it performs a
> non-abortable wait first.  Sometimes it doesn't.  But it only
> aborts before the condition is true if it is signaled.
> This doesn't quite agree with the comments and debug messages.
> 
> Now that we call the timeout handler (ldlm_expired_completion_wait())
> wait directly, we can pass the two args directly rather then
> using a special-purpose struct.
> 
> Reviewed-by: Patrick Farrell <paf@cray.com>
> Reviewed-by: James Simmons <jsimmons@infradead.org>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> Patrick discovered a bug in v1, which this v2 fixes.
> 
> Greg - do you need me to resend the whole series, or are you ok with
> taking this replacement in the rest of the original series?

I can take this replacement, thanks.

greg k-h
