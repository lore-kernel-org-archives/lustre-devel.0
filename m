From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Fri, 09 May 2008 22:17:28 +0400
Subject: [Lustre-devel] Wide area use of Lustre and client caches
In-Reply-To: <C449C4F5.418F%peter.braam@sun.com>
References: <1210343110.23307.203.camel@pc.ilinx>
	<C449C4F5.418F%peter.braam@sun.com>
Message-ID: <18468.38200.651406.598372@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam writes:
 > Nono - striping should only be used to get more bandwidth from servers.  The
 > correct solution to the problem you point out is a lock conversion, planned
 > long ago, still far away maybe (Nikita?).

Yes, it's far away. Interestingly, similar lock "conversion" for
meta-data locks is required for write-back cache, when a sub-tree lock
is split into a set of sub-sub-tree sub-locks.

 > 
 > Peter

Nikita.
