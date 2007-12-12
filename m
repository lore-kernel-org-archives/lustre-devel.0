From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Wed, 12 Dec 2007 08:53:59 +0300
Subject: [Lustre-devel] read ahead
In-Reply-To: <20071211234708.GT3214@webber.adilger.int>
References: <475ED623.6090204@sun.com>
	<18270.55813.185376.299242@gargle.gargle.HOWL>
	<20071211234708.GT3214@webber.adilger.int>
Message-ID: <18271.30583.338003.357861@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger writes:

[...]

 > 
 > Two areas where our readahead is lacking are:
 > - strided reads (may turn the above 16 x 4kB reads into a situation
 >   where the client will prefetch pages instead of "random" IO, depending
 >   on access pattern, and will avoid prefetch of data the client is not
 >   expecting to use)
 > - limiting the readahead to the rate that the client is actually consuming
 >   it (currently once we detect sequential reads the readahead window grows
 >   eventually to the maximum even if this is far more than what the client
 >   needs)

I wonder how useful can inter-file read-ahead be. For example, starting
an executable almost always incurs a sequence of reads of the shared
libraries, compilation re-reads header files in the same order over and
over again, etc.

 > 
 > Cheers, Andreas

Nikita.
