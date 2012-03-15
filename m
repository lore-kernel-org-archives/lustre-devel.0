From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Thu, 15 Mar 2012 14:45:38 -0400
Subject: [Lustre-devel] [Twg] Lustre and cross-platform portability
In-Reply-To: <5609A4E0-2356-400F-9D53-F71B7007338C@whamcloud.com>
Message-ID: <201203151845.q2FIjcXV029439@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>I have no information that the WinNT project will ever be released
>by Oracle, and as yet there has not been any code released from the
>MacOS port, so the libcfs portability layer is potentially exacting
>a high cost in code maintenance and complexity (CLIO being a prime
>example) for no apparent benefit.  Similarly, the liblustre client needs
>a portability layer for userspace, and suffers from the same apparent
>lack of interest or users.

In terms of the MacOS X port, I don't think that's quite fair ...
the code I did is available and anyone can download it.  It was
functional in a very basic way but needed some additonal love.
Okay, I haven't rolled that stuff into the Whamcloud release ...
what happened there was when there was all the uncertainty with
Oracle & Lustre development I lost momentum and got caught up in
other things.  I've talked with the guys at Whamcloud about bringing
at least the portability changes over, and that's all been on me;
it's certainly on my list to work on.

I can say that at least for MacOS X, there has been interest; I can't
speak for the amount of interest, and there's a bit of a chicken and
egg problem ... people don't plan their Lustre use around MacOS X
clients because there isn't one that works well, and people don't put
work into it because there isn't people who plan their Lustre use
around it.

>I'd like to get some feedback from the Lustre community about removing
>the libcfs abstraction entirely, or possibly restructuring it to look
>like the Linux kernel API, and having the other platforms code against
>it as a Linux portability layer, like ZFS on Linux uses the Solaris
>Portability Layer (SPL) to avoid changing the core ZFS code.  A related
>topic is whether it would be better to replace all cfs_* functions with
>standard Linux kernel functions en-masse, or migrate away from cfs_*
>functions slowly?

The only thing I can think of is that if this is done, then officially
Lustre is going to be a Linux-only filesystem.  I understand there are
real costs to maintaining the cfs layer, and I can't speak to whether or
not the loss would be worth the gains.

--Ken
