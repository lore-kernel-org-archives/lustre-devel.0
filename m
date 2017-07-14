From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Fri, 14 Jul 2017 02:50:34 +0100
Subject: [lustre-devel] [PATCH] lustre: check
	copy_from_iter/copy_to_iter return code
In-Reply-To: <CAK8P3a3nJRN2QQO4AGVB3V=jKafqvjdwoJ5u4ntEMsEugzJ_+Q@mail.gmail.com>
References: <20170710130833.1834210-1-arnd@arndb.de>
	<alpine.LFD.2.20.1707131806080.14535@casper.infradead.org>
	<CAK8P3a3nJRN2QQO4AGVB3V=jKafqvjdwoJ5u4ntEMsEugzJ_+Q@mail.gmail.com>
Message-ID: <20170714015034.GE13102@ZenIV.linux.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: James Simmons <jsimmons@infradead.org>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, "# 3.4.x" <stable@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Doug Oucharek <doug.s.oucharek@intel.com>, Dmitry Eremin <dmitry.eremin@intel.com>, Liang Zhen <liang.zhen@intel.com>, Nicholas Hanley <nicholasjhanley@gmail.com>, Lustre Development List <lustre-devel@lists.lustre.org>, devel@driverdev.osuosl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jul 13, 2017 at 10:57:59PM +0200, Arnd Bergmann wrote:

> Thanks for testing it!
> 
> That means we did not copy any data and the kernel continues with
> an uninitialized buffer, right? The problem may be the definition of
> 
> struct kib_immediate_msg {
>         struct lnet_hdr ibim_hdr;        /* portals header */
>         char         ibim_payload[0]; /* piggy-backed payload */
> } WIRE_ATTR;
> 
> The check that Al added will try to ensure that we don't write
> beyond the size of the ibim_payload[] array, which unfortunately
> is defined as a zero-byte array, so I can see why it will now
> fail. However, it's already broken in mainline now, with or without
> my patch.
> 
> Are you able to come up with a fix that avoids the warning in
> 'allmodconfig' and makes the function do something reasonable
> again?

Might make sense to try and use valid C99 for "array of indefinite
size as the last member", i.e.
struct kib_immediate_msg {
         struct lnet_hdr ibim_hdr;        /* portals header */
         char         ibim_payload[]; /* piggy-backed payload */
} WIRE_ATTR;

	Zero-sized array as the last member is gcc hack predating that;
looks like gcc gets confused into deciding that it knows the distance
from the end of object...

	Said that, are we really guaranteed the IBLND_MSG_SIZE bytes
in there?
