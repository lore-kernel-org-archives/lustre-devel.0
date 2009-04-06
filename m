From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Mon, 06 Apr 2009 07:29:25 +0300
Subject: [Lustre-devel] two ideas for Meta Data Write Back Cache
Message-ID: <200904060829.26043.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

There are ideas about WBC client MD stack, WBC protocol and changes 
needed at server side. They are Global OSD and another idea (let's name 
it CMD3+) explained in the WBC HLD outline draft.
 
Brief descriptions of the ideas:

GOSD: 

a portable component (called MDS in Alex's presentation) transates MD 
operations into OSD operations (updates).

MDS may be at client side (WBC-client), proxy server or MD server.

The MDS component is very similar to current MDD (Local MD server) layer 
in CMD3 server stack. I.e. it works like a local MD server, but the OSD 
layer below is not local, it is GOSD. 

It is simple as the local MD server and simplifies MD server stack a 
lot. Current MD stack processes MD operations at any level of MDT, CMM 
and MDD. First two levels should understand what is CMD and MDD layer 
should understand that some MD operations can be partial. It sounds 
like a unneeded complication. With GOSD those layers will be replaced 
by only one as simple as MDD layer! (however LDLM locking should be 
added).

CMD3+:

The component running on WBC client is based on MDT excluding transport 
things. Code reuse is possible.

The WBC protocol logically is the current MD protocol with the partial 
MD operations (object create w/o name, for example). Partial operations 
are already used between MD servers for distributed MD operations. MD 
operations will be packed into batches.

Both ideas (GOSD and CMD3+) assume a cache manager at WBC client to do 
caching & redo-logging of operations.

I think CMD3+ has minimum impact to current Lustre-2.x design. It is 
closer to the original goal of just implementation of WBC feature. But 
the GOSD is an attractive idea and may be potentially better.

With GOSD I am worrying about making Lustre 2.x unstable for some period 
of time. It would be good to think about a plan of incremental 
integration of new stack into existing code.

It is a request for comments and new ideas because design mistakes would 
be too costly.

Thanks,
-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
