From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Tue, 18 Dec 2012 21:30:29 -0500
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
	primitives usage.
In-Reply-To: <1355868747.22854.20.camel@brian-laptop>
Message-ID: <201212190230.qBJ2UTCl005883@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

See, now, this is EXACTLY why I didn't want to say anything.  Sigh.

>The complaint is that the Lustre (2.4.2) that's in the RHEL 9 kernel
>that you are using is too old for some reason?

Right.

>So what's the remedy?  You can either (a) download the stand-alone
>Lustre module source for the version of Lustre you need and build it
>against the RHEL 9 kernel you want to use (assuming they are near enough
>to be compatible -- which is the same situation that exists today) or
>(b) you download the entire upstream kernel that has the version of
>Lustre that you want to use and build that.

So (b) isn't an option for us, ever.  And I think that Prakash has already
explained why what we have today isn't exactly (a).  Generally we
have to run one particular version of Lustre with maybe one version
skew.

>There might be something obvious that I'm missing, but I'm failing to
>see how having Lustre (client) in the kernel is any worse than the
>status quo (basically scenario (a) above) and indeed should provide
>Lustre compatibility to the current stable Linux sooner than we can
>typically turn it around.  

Well, turn it around: Lustre in the Linux kernel doesn't GAIN me
anything.  So like I said, at best it's a no-op; I can't imagine a
situation where we'll use it.  I'm personally extremely skeptical that
having it in the kernel will bring Lustre compatibility to stable Linux
sooner than usual.  Of course, I'm just speaking from my view; obviously
from the developer side of things it can look very different.

And that's my last email on this topic.

--Ken
