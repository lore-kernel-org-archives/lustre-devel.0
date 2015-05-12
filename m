From: Nathan Rutman <nathan.rutman@seagate.com>
Date: Tue, 12 May 2015 11:27:42 -0700
Subject: [lustre-devel] Changelogs and RH
Message-ID: <CAB_j=MdgcH6_3Y0RopcL_YaX86iNrVjOo7Pp3dJD1kJvhVAcJQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Someone sent me a link to this:
http://arxiv.org/pdf/1505.02656v1.pdf
Very cool. We'll need to start using that.

This reminded me to send my changelog/robinhood/HSM concerns that I brought
up at LUG to you guys for your thoughts.

1. What should happen when the changelog on an MDS fills up? Maybe LCAP
helps with the processing rate, but fundamentally the issue might still
happen if nobody consumes due to various software or comms errors. We
should either stop recording records and risk losing change tracking, or
stop MDS processing. (I believe at the moment this will just crash the
MDS.) We probably need a high water mark.

2. There should be some kind of rate limiting for HSM requests (RH to MDS),
so that the number of HSM requests queued up in the coordinator doesn't
grow without bound.  Probably we need a -EAGAIN return code to RH at some
point.

3. It feels like there needs to be some feedback from the backend HSM
storage to RH, in particular to pass back a "backend full" message. We can
presumably pass a backend ENOSPC from the copytool back to the Coordinator,
but how can that message get back to Robinhood? I guess coordinator could
start returning ENOSPC for subsequent archive requests from RH, but then we
have to clear that response if the backend condition clears.

*--*

*Nathan Rutman ? Principal Systems ArchitectSeagate Technology** ? *+1 503
877-9507* ? *GMT-8
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150512/66138479/attachment.htm>
