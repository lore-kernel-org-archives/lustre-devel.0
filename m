From: Joe Perches <joe@perches.com>
Date: Fri, 19 Aug 2016 11:39:26 -0700
Subject: [lustre-devel] [PATCH 0/7] staging: lustre: last missing
	patches for lustre 2.6
In-Reply-To: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
References: <1471630051-26700-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1471631966.3893.29.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, 2016-08-19 at 14:07 -0400, James Simmons wrote:
> Resolved the last remain bug that prevented earlier submission.
> This covers the remaining patches that were missing from the
> upstream client that was in Lustre 2.6 except for the work for
> LU-2484. The work for LU-2484 depends on the stat infrastructure
> that was removed earlier from the upstream client. That will
> be done at a later date. In reality this is a pre-2.7 client
> due to the landing of many patches earlier from lustre 2.7.
> In any case this is a huge milestone for the lustre client in
> the linux kernel.

Couple things:

1: I'd like to see the lustre #include files separated into
? ?only two internal/external directories akin to the
? ?include/linux and include/uapi directories used by linux.

? ?Is this a reasonable thing?

and

2: James, you seem to aggregate a lot of lustre patches and
? ?yet you are not a listed maintainer. ?Should you be?
