From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 15 Dec 2015 20:48:44 +0300
Subject: [lustre-devel] [PATCH 1/7] staging: lustre: Delete unnecessary
 goto statements in six functions
In-Reply-To: <1450191751.3551.14.camel@perches.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7830.9060000@users.sourceforge.net>
	<1450189676.3551.1.camel@perches.com>
	<20151215144133.GC5284@mwanda>
	<1450191751.3551.14.camel@perches.com>
Message-ID: <20151215174844.GE5284@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Dec 15, 2015 at 07:02:31AM -0800, Joe Perches wrote:
> This is the original code:
> 
> 	result = foo();
> 	if (result)
> 		goto label;
> 
> 	result = bar();
> 	if (result)
> 		goto label;
>
> 	result = baz();
> 	if (result)
> 		goto label;
> 
> label:
> 	go on...
> 

No.  There is no test.  The original code looks like:

	result = foo();
	if (result)
		goto out;
	result = baz();
	goto out;
out:
	go on..

regards,
dan carpenter
