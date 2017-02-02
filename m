From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 2 Feb 2017 12:22:52 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: shut up clang warnings
	on CLASSERT()
In-Reply-To: <20170202104357.GB22904@kroah.com>
References: <20170201165314.2588373-1-arnd@arndb.de>
	<C39A7DE9-5D89-4B98-A61F-1BB766ADEFC0@intel.com>
	<20170202095453.GA30437@kroah.com>
	<CAK8P3a1oT+yp_kP-faQMdVun7ny9gfSpby3Ae0xmEpzmuGEJCA@mail.gmail.com>
	<20170202104357.GB22904@kroah.com>
Message-ID: <CAK8P3a2HpQ+2sNethqAsT92Z60eSgq3YQzzgDMhQkiNhbGXLhg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: gregkh <gregkh@linuxfoundation.org>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, "Dilger, Andreas" <andreas.dilger@intel.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Eremin, Dmitry" <dmitry.eremin@intel.com>, LKML <linux-kernel@vger.kernel.org>, James Simmons <jsimmons@infradead.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Feb 2, 2017 11:43 AM, "Greg Kroah-Hartman"
<gregkh@linuxfoundation.org> wrote:
> On Thu, Feb 02, 2017 at 11:40:32AM +0100, Arnd Bergmann wrote:
> > I've done a semi-automated patch to replace CLASSERT() with the respective
> > BUILD_BUG_ON() now, but that patch is quite large.
>
> Should be easy to script, I missed that this was a build-time check.
> Heck, I'll take a script to do this, or I can just do it in my end

My patch has been through a couple of randconfig and allmodconfig builds now,
should be good. If it's wrong, it will at least blow up at compile time.

    Arnd
