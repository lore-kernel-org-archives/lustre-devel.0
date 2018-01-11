From: Ben Evans <bevans@cray.com>
Date: Thu, 11 Jan 2018 17:25:20 +0000
Subject: [lustre-devel] (no subject)
In-Reply-To: <1515691022-22729-1-git-send-email-fabian_huegel@web.de>
References: <1515691022-22729-1-git-send-email-fabian_huegel@web.de>
Message-ID: <D67D07B1.EB5E%jevans@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fabian Huegel <fabian_huegel@web.de>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Lai Siyao <lai.siyao@intel.com>, "John L . Hammond" <john.hammond@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Ben Evans <bevans@cray.com>, NeilBrown <neilb@suse.com>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-kernel@i4.cs.fau.de" <linux-kernel@i4.cs.fau.de>

I've been working off and on with this.  Since you're getting into the
counters in a couple of the patches, part of the reason for all the
#defines here are because MDC, MDT and OST counters are all shoved into
the same array dynamically, sometimes.  It would be a much cleaner
approach to have a separate array for the MDC stats, then print them
conditionally.

This would reduce all of the calls to these macros to counter increments.

-Ben Evans

On 1/11/18, 12:16 PM, "Fabian Huegel" <fabian_huegel@web.de> wrote:

>We cleaned up a lot of checkpatch errors and warnings in obd_class.h,
>but there are still some CHECKs and two warnings about flow control
>inside macros left.
>
>Changing those macros to inline functions would probably
>be a good idea, unfortunatly it's not straightforward since they use
>'#op' to print the name of the operation.
>
>We also did some aligning to make the code more readable and removed
>an unnecessary macro.
>
>We only tested, that the kernel still compiles and the lustre kernel
>module loads successfully, but given the harmless nature of these
>changes we don't expect any problems.
>
>The patches are based on the staging-testing branch of the staging tree.
>
