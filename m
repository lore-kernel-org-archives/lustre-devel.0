From: Eric Barton <eeb@sun.com>
Date: Mon, 18 May 2009 22:01:15 +0100
Subject: [Lustre-devel] [RFC] two ideas for Meta Data Write Back Cache
In-Reply-To: <m3y6ud3x7q.fsf@bzzz.home.net>
References: <200904061339.02850.alexander.zarochentsev@sun.com>
	<20090406100345.GO3199@webber.adilger.int>
	<m3zleu5b8f.fsf@bzzz.home.net>
	<49DA7BE6.6070006@sun.com> <m3y6ud3x7q.fsf@bzzz.home.net>
Message-ID: <016001c9d7fb$ca6f8880$5f4e9980$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Zam,

A couple of things to consider when splitting up operations
into updates....

1. Each update must contain some information about its peer
   updates so that in the absence of the client (e.g. on
   client eviction) we can check that all the operations's
   updates have been applied and apply a correction if not.

   I think there is an advantage if every update includes
   sufficient information to reconstruct all its peer
   updates.

2. The current security design grants capabilities to clients
   to perform operations on Lustre objects.  If you allow
   remote "raw" OSD ops, you're effectively distributing the
   Lustre clustered server further - i.e. nodes allowed to
   do such operations are being trusted just as much as
   servers to keep the filesystem consistent.

    Cheers,
              Eric
