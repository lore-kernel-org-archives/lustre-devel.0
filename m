From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Mon, 09 May 2011 22:53:23 -0400
Subject: [Lustre-devel] Technical debt in the lustre build system
In-Reply-To: <4DC46DDB.4000906@llnl.gov>
Message-ID: <201105100253.p4A2rNeE013093@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>So I'd like to start a discussion about where we need to go with the 
>build system.  Here are some of the things off the top of my head that 
>are problems that need to be addressed, or improvements that I think we 
>should make.
>[...]

I agree with everything you've said, but I'd like to add one thing:

9) Portability

   This drives me nuts on the Mac port; the build system has a fair amount
   of cruft left over (see autoMakefile versus Makefile.am, for starters).
   If we're thinking about long-term plans on the build system, thinking
   about portability is important.

   (On the Mac, and AFAIK all other operating systems other than
   Linux, building a kernel module is relatively straightforward;
   just compile everything with a few extra options).

--Ken
