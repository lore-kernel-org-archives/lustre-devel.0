From: Chris <chris@whamcloud.com>
Date: Thu, 12 May 2011 19:10:53 +0100
Subject: [Lustre-devel] Technical debt in the lustre build system
In-Reply-To: <mailman.5319.1305221323.23683.lustre-devel@lists.lustre.org>
References: <mailman.5319.1305221323.23683.lustre-devel@lists.lustre.org>
Message-ID: <4DCC22AD.3050602@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


>> I think it would be great to see small incremental patches that fix the problems that you have detailed here. Some of them appear to be very minor changes (i.e. extra files included in the RPM packages, or poorly-named files).
> I totally agree; I definitely think this needs an incremental approach.
>    But also a concerted effort to drive those incremental changes.
>
> LLNL has tried to push up patches to clean up some of those minor
> changes in the past and failed to gain traction.  Maybe we just didn't
> push hard enough.  So this time I want to keep pushing.  And get more
> people involved so hopefully they'll understand where the incremental
> changes are leading.
>
Perhaps the right approach is to create a specification or document that 
fully outlines what the objective is and get sign-up from the broader 
community before work is started. The incremental changes can then refer 
to the 'master document' to illustrate the reason for the change.

Little steps are a good way of making sure that we don't trip over, but 
without an agreed long term target they don't allow people to be sure 
where the changes are taking them.

Chris
---
Chris Gearing
Snr Engineer
Whamcloud. Inc.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110512/6b4bdb30/attachment.htm>
