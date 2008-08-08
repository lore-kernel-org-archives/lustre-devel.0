From: James Hughes <James.Hughes@Sun.COM>
Date: Fri, 08 Aug 2008 07:25:36 -0700
Subject: [Lustre-devel] security: rpc message vs bulk data
In-Reply-To: <C4BF8667.5519%peter.braam@sun.com>
References: <C4BF8667.5519%peter.braam@sun.com>
Message-ID: <1218205536.814.55.camel@JimsOSlap>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



On Wed, 2008-08-06 at 16:48 -0600, Peter Braam wrote:

> Of course the CMU research about NASD concluded the same 10-15 years
> ago -
> you need a different protocol here, calling it ad-hoc is not so
> positive,
> calling it the NASD protocol sounds rather nice.


I am not following the thread here. 

The existing implementation leverages off of kerberos in the client
machine and does not leverage the NASD style ticket granting with
versioning that the CMU papers advocated. Going to the NASD protocol is
OK, but that means either abandoning Kerberos or adding Kerberos ticket
honoring to the NASD versioned ticketing. This is doable, but not
trivial. 

Can you send pointers to the relevant NASD security papers so that we
can have a firm set of terminology to discuss this with?
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080808/484084ff/attachment.htm>
