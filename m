From: Ulka Vaze <ulka.vaze@clogeny.com>
Date: Wed, 13 May 2015 10:03:46 +0530
Subject: [lustre-devel] Changelogs and RH
Message-ID: <CAN+e8N-k-Eg6p=wiDKxF_TyDW1BCT00ktNB=N+Zxcg2LY2iLDA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Nathan ,
   I was just going through the questions and i was wondering
     Is it possible to have SNMP trap like mechanism in MDS ?

    Every  policy engine has to register for the traps or events from MDS.
Traps can be change log full , or disk  full etc.
 So when MDS reaches high water mark it will send trap  to RH
then RH should buffer requests till it gets next trap.

But i am not aware of architectural complexity or amount of change needed
etc.
I am new to lustre. So sorry if i have suggested something which might have
already discussed or stupid in this context.
So this is just a thought and thought of sharing to have your view.






On Wed, May 13, 2015 at 1:34 AM, <lustre-devel-request@lists.lustre.org>
wrote:

> Send lustre-devel mailing list submissions to
>         lustre-devel at lists.lustre.org
>
> To subscribe or unsubscribe via the World Wide Web, visit
>         http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> or, via email, send a message with subject or body 'help' to
>         lustre-devel-request at lists.lustre.org
>
> You can reach the person managing the list at
>         lustre-devel-owner at lists.lustre.org
>
> When replying, please edit your Subject line so it is more specific
> than "Re: Contents of lustre-devel digest..."
>
>
> Today's Topics:
>
>    1. Changelogs and RH (Nathan Rutman)
>
>
> ----------------------------------------------------------------------
>
> Message: 1
> Date: Tue, 12 May 2015 11:27:42 -0700
> From: Nathan Rutman <nathan.rutman@seagate.com>
> To: henri.doreau at cea.fr, Thomas Leibovici <Thomas.Leibovici@cea.fr>
> Cc: "lustre-devel at lists.lustre.org" <lustre-devel@lists.lustre.org>,
>         St?phane Thiell <stephane.thiell@cea.fr>
> Subject: [lustre-devel] Changelogs and RH
> Message-ID:
>         <CAB_j=
> MdgcH6_3Y0RopcL_YaX86iNrVjOo7Pp3dJD1kJvhVAcJQ at mail.gmail.com>
> Content-Type: text/plain; charset="utf-8"
>
> Someone sent me a link to this:
> http://arxiv.org/pdf/1505.02656v1.pdf
> Very cool. We'll need to start using that.
>
> This reminded me to send my changelog/robinhood/HSM concerns that I brought
> up at LUG to you guys for your thoughts.
>
> 1. What should happen when the changelog on an MDS fills up? Maybe LCAP
> helps with the processing rate, but fundamentally the issue might still
> happen if nobody consumes due to various software or comms errors. We
> should either stop recording records and risk losing change tracking, or
> stop MDS processing. (I believe at the moment this will just crash the
> MDS.) We probably need a high water mark.
>
> 2. There should be some kind of rate limiting for HSM requests (RH to MDS),
> so that the number of HSM requests queued up in the coordinator doesn't
> grow without bound.  Probably we need a -EAGAIN return code to RH at some
> point.
>
> 3. It feels like there needs to be some feedback from the backend HSM
> storage to RH, in particular to pass back a "backend full" message. We can
> presumably pass a backend ENOSPC from the copytool back to the Coordinator,
> but how can that message get back to Robinhood? I guess coordinator could
> start returning ENOSPC for subsequent archive requests from RH, but then we
> have to clear that response if the backend condition clears.
>
> *--*
>
> *Nathan Rutman ? Principal Systems ArchitectSeagate Technology** ? *+1 503
> 877-9507* ? *GMT-8
> -------------- next part --------------
> An HTML attachment was scrubbed...
> URL: <
> http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150512/66138479/attachment.html
> >
>
> ------------------------------
>
> Subject: Digest Footer
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
>
> ------------------------------
>
> End of lustre-devel Digest, Vol 100, Issue 5
> ********************************************
>



-- 
Thanks & Regards,

   *Ulka Vaze*
Principle System Software Engineer,

ClogenyTechnologies

Ulka.vaze at clogeny.com

+91-989-032-3754
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150513/f964a9fb/attachment.htm>
