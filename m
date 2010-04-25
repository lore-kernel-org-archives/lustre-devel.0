From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Sun, 25 Apr 2010 19:32:58 -0400
Subject: [Lustre-devel] Build system and portability
In-Reply-To: <06A66EC3-497E-4651-B0B1-DDAF3BF64E49@oracle.com>
Message-ID: <201004252333.o3PNWxxw019025@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>Is this something you are interested to invest some time on fixing, or  
>is it more a question of curiosity as to how we got into this Rube  
>Goldberg build system?

I am definitely interested in helping to clean up the current build
system.  Obviously history is helpful to understand how things ended
up where they are now, and I'm not that experienced on how to
configure a build system to create Linux kernel modules so the goal of
my note was to just start the ball rolling.

I think it's obvious that the autoconf system needs some work as well;
no one disagrees, do they?

I guess the first thing that comes to mind is ... what's the deal with
Makefile.in and autoMakefile.am?  Why not just one Makefile.am?

--Ken
