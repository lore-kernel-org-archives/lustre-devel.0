From: DOREAU Henri <henri.doreau@cea.fr>
Date: Wed, 13 May 2015 09:54:50 +0200
Subject: [lustre-devel] Changelogs and RH
In-Reply-To: <CAB_j=MdgcH6_3Y0RopcL_YaX86iNrVjOo7Pp3dJD1kJvhVAcJQ@mail.gmail.com>
References: <CAB_j=MdgcH6_3Y0RopcL_YaX86iNrVjOo7Pp3dJD1kJvhVAcJQ@mail.gmail.com>
Message-ID: <5553034A.1060703@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Le 12/05/2015 20:27, Nathan Rutman a ?crit :
> Someone sent me a link to this:
> http://arxiv.org/pdf/1505.02656v1.pdf
> Very cool. We'll need to start using that.
>
> This reminded me to send my changelog/robinhood/HSM concerns that I 
> brought up at LUG to you guys for your thoughts.
>
> 1. What should happen when the changelog on an MDS fills up? Maybe 
> LCAP helps with the processing rate, but fundamentally the issue might 
> still happen if nobody consumes due to various software or comms 
> errors. We should either stop recording records and risk losing change 
> tracking, or stop MDS processing. (I believe at the moment this will 
> just crash the MDS.) We probably need a high water mark.
>
> 2. There should be some kind of rate limiting for HSM requests (RH to 
> MDS), so that the number of HSM requests queued up in the coordinator 
> doesn't grow without bound. Probably we need a -EAGAIN return code to 
> RH at some point.
>
> 3. It feels like there needs to be some feedback from the backend HSM 
> storage to RH, in particular to pass back a "backend full" message. We 
> can presumably pass a backend ENOSPC from the copytool back to the 
> Coordinator, but how can that message get back to Robinhood? I guess 
> coordinator could start returning ENOSPC for subsequent archive 
> requests from RH, but then we have to clear that response if the 
> backend condition clears.
>
> *--*
> *Nathan Rutman ? Principal Systems Architect
> Seagate Technology** ? *+1 503 877-9507* ? *GMT-8

Hello Nathan,

1: when the changelog catalog is full (4B entries IIRC) lustre should 
either automatically clear the catalog or turn the FS read-only 
(tunable, indeed). I want to propose a patch for this but don't have it yet.

2: Right, there is no limitation at the moment. I think what is needed 
there is rather a high watermark on the number of pending requests than 
rate limiting. Note that on robinhood side your can set limitations on 
the number of active requests.

3: As you say, the copytools can propagate error messages back to the 
coordinator, indicating whether they are retryable or not. Non-retryable 
errors would cause the requests to fail. Lustre can then either emit a 
changelog for failed requests (which is on the edge of what changelogs 
are for, though...) or we can add some mechanism into rbh to let it 
react when it detects that too many requests have failed. That said, 
many failed requests is something that probably has to be detected and 
handled by monitoring systems. Avoiding too tight coupling between HSM 
components is desirable.


Regards

-- 
Henri
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150513/423ea916/attachment.htm>
