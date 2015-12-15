From: Joe Perches <joe@perches.com>
Date: Tue, 15 Dec 2015 10:22:07 -0800
Subject: [lustre-devel] staging: lustre: Delete unnecessary goto
 statements in six functions
In-Reply-To: <567055C4.8000806@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7830.9060000@users.sourceforge.net>
	<1450189676.3551.1.camel@perches.com> <20151215144133.GC5284@mwanda>
	<1450191751.3551.14.camel@perches.com>
	<567055C4.8000806@users.sourceforge.net>
Message-ID: <1450203727.4142.13.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 2015-12-15 at 19:02 +0100, SF Markus Elfring wrote:
> > This is the original code:
> Really ??
> > 	result = baz();
> > 	if (result)
> > 		goto label;
> > 
> > label:
> > 	go on...
> 
> I do not see such a source code structure
> at the six places I propose to clean-up.
> 
> 
> > I don't find the test->goto label; label: use offensive,
> > but if he does, I think keeping a blank line in place of
> > the test->goto might be better.
> 
> I find this an interesting view on source code layout.
> Are there any more opinions around such implementation details?

Or to put it another way, use a blank line before the
first or only label in an error/out block.

I don't find it different then commonly written blocks like:

void foo(void)
{
	...;

	wind1();

	val = func1(...);
	if (val) {
		printk(...);
		goto err_type;
	}

	wind2();

	val = func2(...);
	if (val) {
		printk(...);
		goto err_type2;
	}

	...

	return 0;

err_type2:
	unwind2();
err_type:
	unwind1();
	return -ERR;
}

Yes, you can elide all the blank lines, but using them can
help readability.
