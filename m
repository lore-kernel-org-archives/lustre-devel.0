From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 25 Sep 2015 18:09:13 +0200
Subject: [lustre-devel] [PATCH 32/37] staging/lustre: use 64-bit	times
	for exp_last_request_time
In-Reply-To: <04B462D5-CB6F-4AA6-8C48-1941E31A9A2F@intel.com>
References: <1443035640-1617003-1-git-send-email-arnd@arndb.de>
	<989D1FF5-705C-42EA-A41F-6CAD00BF53E4@intel.com>
	<04B462D5-CB6F-4AA6-8C48-1941E31A9A2F@intel.com>
Message-ID: <5823166.8kAioJAUND@wuerfel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Friday 25 September 2015 01:39:49 Drokin, Oleg wrote:
> On Sep 24, 2015, at 9:07 PM, Drokin, Oleg wrote:
> 
> > 
> > On Sep 24, 2015, at 4:15 PM, Arnd Bergmann wrote:
> >>>>> Anyway this does remove a lot of stuff that we don't really need in the client,
> >>>>> I'll try to get it built and tested just to make sure it does not really break anything
> >>>>> (unfortunately it does not seem to apply cleanly to the tip of staging-next tree).
> >>>> Ok. I based the patches on top of my 37 patch series, and if you want I can
> >>>> upload a git branch somewhere to make rebasing easier.
> >>> 
> >>> That would be great.
> >>> Though in the end likely this huge patch would need to be split into smaller chunks.
> >>> Like if all unused llog code removal is done, that would allow subsequent dt_object.[ch]
> >>> removal and so on.
> >>> But for testing a current snapshot would be great, then I can run it through my testbed
> >>> to see how it fares there.
> >> 
> >> Ok, I've pushed out the branch to
> >> 
> >> git.kernel.org/pub/scm/linux/kernel/git/arnd/playground.git y2038-lustre
> >> 
> >> This contains the latest version of the y2038 series (with the warning fixed
> >> that Sudip Mukherjee found) but no other changes, and the big code removal
> >> on top.
> > 
> > 
> > These do seem to be working fine in my testing.
> 
> Ah, and I should mention that just as I suspected, the debug log decoding tool
> is very unhappy.

I have updated the branch now to reflect our discussions so far. Can you handle
forwarding the patches to Greg from there, or complain if there are still
problems with them?

I still had problems with removing ptlrpc_update_export_timer(), so I left
a small patch for that, which you probably want to do differently, and
while I split out the nontrivial parts of the large removal patch, most of
it still is in one chunk that contains purely removals of whole lines.

	Arnd
