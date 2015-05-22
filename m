From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Fri, 22 May 2015 08:08:44 +0000
Subject: [lustre-devel] [PATCH v4 10/13] staging: lustre: lnet: lnet:
 checkpatch.pl fixes
In-Reply-To: <alpine.DEB.2.10.1505220704541.2672@hadrien>
References: <1432237849-53947-1-git-send-email-shuey@purdue.edu>
	<1432237849-53947-11-git-send-email-shuey@purdue.edu>
	<1432242004.20840.68.camel@perches.com>
	<alpine.DEB.2.10.1505212328500.5370@hadrien>
	<CABqvwjuKypiacf3336j-q450FGKaO4wh0Ld7PF8MGz0VPsYBbw@mail.gmail.com>
	<alpine.DEB.2.10.1505220704541.2672@hadrien>
Message-ID: <15C0AFDB-CA69-40E5-B65E-C559A5B5CE47@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On May 22, 2015, at 1:06 AM, Julia Lawall wrote:

> On Thu, 21 May 2015, Michael Shuey wrote:
> 
>> That's a task (of many) I've been putting on the back burner until the code
>> is cleaner.  It's also a HUGE change, since there are debug macros
>> everywhere, and they all check a #define'd mask to see if they should fire,
>> and the behavior is likely governed by parts of the lustre user land tools
>> as well.
>> 
>> Suggestions are welcome.  Do other parts of the linux kernel define complex
>> debugging macros like these, or is this a lustre-ism?  Any suggestions on
>> how to handle this more in line with existing drivers?
> 
> Once you decide what to do, you can use Coccinelle to make the changes for
> you.  So you shouldn't be put off by the number of code sites to change.
> 
> The normal functions are pr_err, pr_warn, etc.  Perhaps you can follow
> Joe's suggestions if you really need something more complicated.

Ideally leaving CERROR/CDEBUG in Lustre would be desirable from my perspective.
It allows you fine grained control about what to collect and what to output
into a (quite finite) kernel buffer (and over a quite slow serial console)
and at the same time if you need more info, there's a buffer you can fetch
separately that can grow much bigger and there's even a way to run a special
daemon to scrub the buffer eagerly so none of it is lost.

Bye,
    Oleg
