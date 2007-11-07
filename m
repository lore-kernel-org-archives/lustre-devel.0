From: Andreas Dilger <adilger@sun.com>
Date: Wed, 7 Nov 2007 13:05:20 -0700
Subject: [Lustre-devel] Checksum Algorithm
In-Reply-To: <BLU115-W12E96D373F497BF1EDDCD0CD890@phx.gbl>
References: <BLU115-W12E96D373F497BF1EDDCD0CD890@phx.gbl>
Message-ID: <20071107200520.GD3966@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Nov 06, 2007  11:59 -0500, RS RS wrote:
> We have seen a huge performance drop in 1.6.3, due to the checksum
> being enabled by default.  I looked at the algorithm being used, and it is
> actually a CRC32, which is a very strong algorithm for detecting all sorts
> of problems, such as single bit errors, swapped bytes, and missing bytes.

> I've been experimenting with using a simple XOR algorithm.  I've
> been able to recover most of the lost performance.  This algorithm
> will detected corrupted bytes and words.  This algorithm will not
> detect swapped bytes errors, but I think that these are pretty rare.
> This algorithm will not detect missing bytes, but I suspect that other
> things in Lustre or LNET will detect this problem.  This algorithm will
> not detect two errors that offset each other, such as a single bit error
> in two words that are a multiple of 4 bytes apart.

Note that it is possible to disable checksums to get the previous behaviour
back at runtime with (on all clients that should skip checksums):

	for C in /proc/fs/lustre/osc/*/checksums; do
		echo 0 > $C
	done

in the lustre configuration:

	mgs> lctl conf_param testfs-OST0001.osc.checksums=0

or at compile time with "configure --disable-checksum ..."

Cheers, Andreas
--
Andreas Dilger
Sr. Software Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
