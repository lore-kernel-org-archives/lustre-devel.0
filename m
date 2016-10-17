From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 18 Oct 2016 01:00:44 +0200
Subject: [lustre-devel] [PATCH 08/28] staging: lustre: restore
	initialization of return code
In-Reply-To: <CA+55aFyfayS7zQwUv9VR2hFMSE25Fc4vje9y4Dyuzop-ic2YAw@mail.gmail.com>
References: <20161017220342.1627073-1-arnd@arndb.de>
	<11209173.masZYIyEty@wuerfel>
	<CA+55aFyfayS7zQwUv9VR2hFMSE25Fc4vje9y4Dyuzop-ic2YAw@mail.gmail.com>
Message-ID: <7466839.omZLGPO0np@wuerfel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Patrick Farrell <paf@cray.com>, Oleg Drokin <oleg.drokin@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

On Monday, October 17, 2016 3:37:11 PM CEST Linus Torvalds wrote:
> On Mon, Oct 17, 2016 at 3:29 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> >
> > Sorry, I pasted the wrong error message when writing the changelog.
> 
> Not just the warning, the summary above it talks about the wrong
> function too. And the commit it references doesn't actually exist
> either. So apparently this is against something else than my tree.

Right, it slipped in here together with the other lustre patch when
I rebased my longer series (based on linux-next) onto v4.9-rc1.

Both applied cleanly to v4.9-rc1 and they are required on linux-next
(not the version with the wrong changelog of course) but have no
effect in mainline so far.

I'll double-check the rest of the series tomorrow, to see if some
of the other patches also have the same problem and are only
needed on linux-next. I meant to send those as part of the
separate series for v4.10.

For now, it would be good to know if you see any remaining warnings
on your machine after applying the current series (with or without
the lustre patches, doesn't matter) to a test branch. Some other
patches in the series likely need to go through a second revision
anyway.

	Arnd
