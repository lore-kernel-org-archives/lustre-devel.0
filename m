From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 14 Dec 2015 18:43:15 +0100
Subject: [lustre-devel] staging: lustre: Less checks in
 mgc_process_recover_log() after error detection
In-Reply-To: <20151214135750.GY5284@mwanda>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7952.7090401@users.sourceforge.net> <20151214110003.GV5284@mwanda>
	<566EB03E.2000007@users.sourceforge.net> <20151214123840.GX5284@mwanda>
	<566EB9D7.9090904@users.sourceforge.net> <20151214135750.GY5284@mwanda>
Message-ID: <566EFFB3.708@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>> I do not like patch squashing for my update suggestions here.
> 
> I am a maintainer in drivers/staging.

Thanks for this information.


> I am telling you what you need to do if you want us to apply your patch.

I am still waiting for a bit more constructive feedback for this
patch series. How many days should I wait before I should send adjusted
update suggestions for this approach?


> What you do with that information is up to you.

Our software development dialogue seems to trigger special
challenges between us so far.
Are you generally willing to change the exception handling for
the memory allocations in the function "mgc_process_recover_log"
at all?

Regards,
Markus
