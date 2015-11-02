From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 2 Nov 2015 17:48:38 +0300
Subject: [lustre-devel] [PATCH 1/3] staging: lustre: checkpatch cleanups
 for nidstring.c
In-Reply-To: <229dae23c2f34950a21db4bd6dbdcfba@EXCHCS32.ornl.gov>
References: <1446161303-798-1-git-send-email-jsimmons@infradead.org>
	<1446161303-798-2-git-send-email-jsimmons@infradead.org>
	<20151030230148.GB2920@kroah.com>
	<229dae23c2f34950a21db4bd6dbdcfba@EXCHCS32.ornl.gov>
Message-ID: <20151102144837.GG18797@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Yeah.  That is often the fastest way to fix all the checkpatch warnings.

Checkpatch warnings are pretty mechanical.  Just send like 100 patches
at a time until everything is fixed.  Don't overthink.  Say your patch
breaks the alignment then you have to fix that, but otherwise only fix
one thing at a time.  Sometimes people will ask you to fix something
else on the same line, but just say "I didn't introduce that, but yes I
am planning to fix that in a later patchset since I am following the
one thing per patch rule."

Don't feel shame about sending many small patches.  We pretty much merge
everything.

regards,
dan carpenter
