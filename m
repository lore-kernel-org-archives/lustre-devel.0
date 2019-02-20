From: James Simmons <jsimmons@infradead.org>
Date: Wed, 20 Feb 2019 17:59:38 +0000 (GMT)
Subject: [lustre-devel] Lustre interval tree problems
Message-ID: <alpine.LFD.2.21.1902201738170.6267@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


With the port of the interval tree work to the OpenSFS branch several 
problems have been pointed out in the implementation which impacts
performance and the memory footprint in some cases.

The biggest issues is the ability to add duplicate locks. The reason
the original implementation avoided adding duplicate locks was to
avoid the extra compares being done with the same type of locks.
Especially in the case of the range lock where you can end up with
many duplicate read locks [0-EOF]. Comparing with 1000s of identical
read locks will have an impact. Their is teh question of the memory
foot print in this case as well. I believe this is the case with the
ldlm locks as well since the ability to skip large lock amounts if
not matching has been lost.

The next problem Vitaly pointed in the implementation is the emebedding
of lit_root in ldlm_interval_tree also has a negative impact. Since many
locaks are kept in memory he wants to see that ldlm_lock struct stay as
small as possible. Explained that is why ldlm_interval was not original
embedded but allocated separately. I added him to this chain.
