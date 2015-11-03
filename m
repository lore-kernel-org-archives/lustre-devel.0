From: Simmons, James A. <simmonsja@ornl.gov>
Date: Tue, 3 Nov 2015 23:56:22 +0000
Subject: [lustre-devel] [PATCH 1/3] staging: lustre: checkpatch cleanups
 for nidstring.c
In-Reply-To: <20151102144837.GG18797@mwanda>
References: <1446161303-798-1-git-send-email-jsimmons@infradead.org>
	<1446161303-798-2-git-send-email-jsimmons@infradead.org>
	<20151030230148.GB2920@kroah.com>
	<229dae23c2f34950a21db4bd6dbdcfba@EXCHCS32.ornl.gov>
	<20151102144837.GG18797@mwanda>
Message-ID: <fc4cb8a899234adabb499f57b76a20b2@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>Yeah.  That is often the fastest way to fix all the checkpatch warnings.
>
>Checkpatch warnings are pretty mechanical.  Just send like 100 patches
>at a time until everything is fixed.  Don't overthink.  Say your patch
>breaks the alignment then you have to fix that, but otherwise only fix
>one thing at a time.  Sometimes people will ask you to fix something
>else on the same line, but just say "I didn't introduce that, but yes I
>am planning to fix that in a later patchset since I am following the
>one thing per patch rule."
>
>Don't feel shame about sending many small patches.  We pretty much merge
>everything.

It was the sense of it taking forever with that amount of patches needed with
the one file approach. Looking at the back log of fixes its not as bad as I thought
for libcfs/LNet. Once those fixes are merged the style cleanups can happen
pretty quickly.
