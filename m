From: Simmons, James A. <simmonsja@ornl.gov>
Date: Fri, 1 Apr 2016 15:58:20 +0000
Subject: [lustre-devel] [RFC PATCH 0/3] staging: lustre: detypedef
In-Reply-To: <cover.1459515208.git.joe@perches.com>
References: <cover.1459515208.git.joe@perches.com>
Message-ID: <e80afb24bd424ab183bc7732ed556d3a@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Joe Perches' <joe@perches.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

>Question about removing lustre typedefs.
>
>Various bits of lustre code use a mix of struct foo and foo_t.
>
>When would be an appropriate time to submit patches similar to
>below that individually remove various typedefs from lustre code?
>
>These are pretty trivial to produce and verify so there's no
>particular hurry to do them now but applying them will require
>resync points for active and actually useful developers.

Actually could you hold off for the LNet core and LND drivers these
changes. I have plans to push a few more LNet patches soon. I have
been just waiting for everyone to figure out how to deal with the 
latest changes to the infinband layer first. So the plan is to push
FMR support for the ko2iblnd driver. Also we have additional work
too handle setting the size of the DMA pools for o2iblnd but that
patch touches some of the core LNet code as well. Once those are
landed we can look at removing most of the typedefs. When its
time for the typedef to be cleaned up lets do just the structs first.
There are a few typedefs like lnet_nid_t I like to keep or if it has to
be changed turn it into a struct then. Things like lnet_nid_t act like
a cookie handle.

Now the best place to do this cleanup right now is LNet selftest. No
new code is planned for landing. We have lots of typedefs to remove
and I was planning to do that cleanup but if you want to do it just CC
me, jsimmons at infradead.org, so I can test the changes.
