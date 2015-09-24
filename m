From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 24 Sep 2015 22:15:51 +0200
Subject: [lustre-devel] [PATCH 32/37] staging/lustre: use 64-bit times
	for exp_last_request_time
In-Reply-To: <847A8CB9-E040-4149-BE38-6E284AD73D6F@intel.com>
References: <1443035640-1617003-1-git-send-email-arnd@arndb.de>
	<1956624.Zv9KJSmuQh@wuerfel>
	<847A8CB9-E040-4149-BE38-6E284AD73D6F@intel.com>
Message-ID: <3415466.Q2DxJVi5PK@wuerfel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thursday 24 September 2015 19:03:12 Drokin, Oleg wrote:
> On Sep 24, 2015, at 2:54 PM, Arnd Bergmann wrote:
> > On Thursday 24 September 2015 16:01:40 Drokin, Oleg wrote:
> >> On Sep 24, 2015, at 11:18 AM, Arnd Bergmann wrote:
> >>> On Thursday 24 September 2015 03:55:20 Drokin, Oleg wrote:
> >>>> On Sep 23, 2015, at 3:13 PM, Arnd Bergmann wrote:
> >> This is only true on the servers so we can replace it with a corresponding LASSERT,
> >> I imagine.
> > 
> > Ok, I see. This wasn't clear as I really know nothing about what lustre
> > actually does. Just for my information, can you clarify where the server
> > code sits? Is that a fork of the same code base running in user space,
> > or is there another set of kernel modules on top of the common ones that
> > implements the server?
> 
> Lustre server (and out of tree client) live in http://git.whamcloud.com/fs/lustre-release.git/
> 
> Code in the staging tree is a snapshot from between 2.4 and 2.5 releases
> that undergoes cleanups in order to conform to kernel standards.
> It's only client too, so all server-side parts are being removed as they are identified.

Ok, I see.

> >> I have not finished a detailed runthrough yet, but on the surface, why did you remove
> >> suppress_pings parameter 0 that is still valid on clients, to let them not ping servers.
> >> Also ptlrpc_ping_import_soon and friends - all that code is actually needed.
> >> 
> >> Only "ping evictor" is not needed on the client as it's only servers that are going to
> >> kick out clients that are silent for too long. Clients are still expected to
> >> send their "keep alive" pings in periodically (unless suppress_pings option is enabled).
> >> 
> >> Hm?. I now see it is not fully implemented, that's why you are removing it as it's really not
> >> called from anywhere.
> > 
> > Right, I obviously cannot tell the difference between code that is not needed
> > on the client or that has been orphaned in a previous cleanup and code that
> > has just been added in order to soon be used.
> 
> This code is not "soon to be used", so it's ok to kill it now and we can
> spring it back to life when it actually becomes useful.

Makes sense.

> >> Anyway this does remove a lot of stuff that we don't really need in the client,
> >> I'll try to get it built and tested just to make sure it does not really break anything
> >> (unfortunately it does not seem to apply cleanly to the tip of staging-next tree).
> > Ok. I based the patches on top of my 37 patch series, and if you want I can
> > upload a git branch somewhere to make rebasing easier.
> 
> That would be great.
> Though in the end likely this huge patch would need to be split into smaller chunks.
> Like if all unused llog code removal is done, that would allow subsequent dt_object.[ch]
> removal and so on.
> But for testing a current snapshot would be great, then I can run it through my testbed
> to see how it fares there.

Ok, I've pushed out the branch to

git.kernel.org/pub/scm/linux/kernel/git/arnd/playground.git y2038-lustre

This contains the latest version of the y2038 series (with the warning fixed
that Sudip Mukherjee found) but no other changes, and the big code removal
on top.

	ARnd
