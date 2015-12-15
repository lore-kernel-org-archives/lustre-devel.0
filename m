From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 15 Dec 2015 19:02:44 +0100
Subject: [lustre-devel] staging: lustre: Delete unnecessary goto
 statements in six functions
In-Reply-To: <1450191751.3551.14.camel@perches.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7830.9060000@users.sourceforge.net>
	<1450189676.3551.1.camel@perches.com> <20151215144133.GC5284@mwanda>
	<1450191751.3551.14.camel@perches.com>
Message-ID: <567055C4.8000806@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> This is the original code:
Really ??
> 	result = baz();
> 	if (result)
> 		goto label;
>
> label:
> 	go on...

I do not see such a source code structure
at the six places I propose to clean-up.


> I don't find the test->goto label; label: use offensive,
> but if he does, I think keeping a blank line in place of
> the test->goto might be better.

I find this an interesting view on source code layout.
Are there any more opinions around such implementation details?

Regards,
Markus
