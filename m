From: Joe Perches <joe@perches.com>
Date: Tue, 24 Jan 2017 18:23:37 -0800
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: libcfs: use octal
	permissions
In-Reply-To: <715A0C57-2EE3-486E-A5DE-E372366B6BE8@intel.com>
References: <20170124174050.6534-1-ernestas.kulik@gmail.com>
	<715A0C57-2EE3-486E-A5DE-E372366B6BE8@intel.com>
Message-ID: <1485311017.12563.48.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>, Ernestas Kulik <ernestas.kulik@gmail.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 2017-01-24 at 22:22 +0000, Dilger, Andreas wrote:
> On Jan 24, 2017, at 09:40, Ernestas Kulik <ernestas.kulik@gmail.com> wrote:
> > 
> > Using octal permissions instead of symbolic ones is preferred.
> 
> Typically the reverse is true - using symbolic constants is preferred over numeric ones.
> Where does this recommendation come from?

http://lkml.kernel.org/r/CA+55aFw5v23T-zvDZp-MmD_EYxF8WbafwwB59934FV7g21uMGQ at mail.gmail.com

which is:

https://marc.info/?l=linux-arm-kernel&m=147017161402213&w=2

Subject:    Please don't replace numeric parameter like 0444 with macro
From:       Linus Torvalds <torvalds () linux-foundation ! org>
Date:       2016-08-02 20:58:29

[ So I answered similarly to another patch, but I'll just re-iterate
and change the subject line so that it stands out a bit from the
millions of actual patches ]

On Tue, Aug 2, 2016 at 1:42 PM, Pavel Machek <pavel@ucw.cz> wrote:
>
> Everyone knows what 0644 is, but noone can read S_IRUSR | S_IWUSR |
> S_IRCRP | S_IROTH (*). Please don't do this.

Absolutely. It's *much* easier to parse and understand the octal
numbers, while the symbolic macro names are just random line noise and
hard as hell to understand. You really have to think about it.

So we should rather go the other way: convert existing bad symbolic
permission bit macro use to just use the octal numbers.

The symbolic names are good for the *other* bits (ie sticky bit, and
the inode mode _type_ numbers etc), but for the permission bits, the
symbolic names are just insane crap. Nobody sane should ever use them.
Not in the kernel, not in user space.
