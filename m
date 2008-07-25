From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Fri, 25 Jul 2008 23:50:13 +0400
Subject: [Lustre-devel] statahead feature
In-Reply-To: <20080725194109.GV5346@webber.adilger.int>
References: <4888573F.4010506@sun.com> <488957EC.1040701@sun.com>
	<4889597A.6060109@sun.com> <1216978676.16594.104.camel@bear.shadowland>
	<20080725194109.GV5346@webber.adilger.int>
Message-ID: <488A2E75.80901@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> IMHO it would also be useful to start the OST glimpse in the callback as
> soon as the MDT "glimpse" is returned.  Without a change like this we
> are limited to <= 2x speedup for statahead until size-on-MDS is done.
> That is because we are hiding the MDT RPC latency, but still have to wait
> for the parallel OST RPC latency, so:
> 
> speedup = (old time / new time) = (MDT RPC + max(OST RPC)) / max(OST RPC)

definitely

thanks, Alex
