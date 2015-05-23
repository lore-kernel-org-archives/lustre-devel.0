From: Joe Perches <joe@perches.com>
Date: Fri, 22 May 2015 17:36:30 -0700
Subject: [lustre-devel] [PATCH v4 10/13] staging: lustre: lnet: lnet:
 checkpatch.pl fixes
In-Reply-To: <467D21EA-E5E8-4F16-AABD-31D79062FFF9@intel.com>
References: <1432237849-53947-1-git-send-email-shuey@purdue.edu>
	<1432237849-53947-11-git-send-email-shuey@purdue.edu>
	<1432242004.20840.68.camel@perches.com>
	<alpine.DEB.2.10.1505212328500.5370@hadrien>
	<CABqvwjuKypiacf3336j-q450FGKaO4wh0Ld7PF8MGz0VPsYBbw@mail.gmail.com>
	<alpine.DEB.2.10.1505220704541.2672@hadrien>
	<15C0AFDB-CA69-40E5-B65E-C559A5B5CE47@intel.com>
	<1432309337.29657.16.camel@perches.com>
	<05DE4AF3-20A6-40F6-BAC6-79C140E490AF@intel.com>
	<1432339030.29657.20.camel@perches.com>
	<863F0D66-99B1-4658-8A99-E3A843E0E8FC@intel.com>
	<1432340285.29657.26.camel@perches.com>
	<467D21EA-E5E8-4F16-AABD-31D79062FFF9@intel.com>
Message-ID: <1432341390.29657.29.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, 2015-05-23 at 00:25 +0000, Drokin, Oleg wrote:
> On May 22, 2015, at 8:18 PM, Joe Perches wrote:
> >>>> I wonder what is more clear about that in your opinion ve
> >>>> lustre_error/lustre_debug?
> >>> 
> >>> The fact that you have to explain this shows that it's
> >>> at least misleading unless you completely understand the
> >>> code.
> >> 
> >> Or you know, you might take the function name at the face value
> >> and assume that CERROR means it's an error and CDEBUG means it's a debug message?
> > 
> > Maybe, but I think that it'd be better if the mechanism
> > it uses was more plainly named something like lustre_log.
> 
> While the idea seems good, the biggest obstacle here is such that
> there's already a thing called lustre log (llog for short too) -
> it's kind of a distributed journal of operations.
> 
> Its there a different synonym, I wonder?

Maybe: lustre_printk, lustre_logmsg, lustre_output
