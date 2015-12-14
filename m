From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 14 Dec 2015 12:31:22 +0300
Subject: [lustre-devel] [PATCH 2/7] staging: lustre: Rename a jump label
 for ptlrpc_req_finished() calls
In-Reply-To: <566E86F3.9010209@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7884.5050407@users.sourceforge.net>
	<20151214065325.GS5284@mwanda>
	<566E86F3.9010209@users.sourceforge.net>
Message-ID: <20151214093121.GU5284@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Dec 14, 2015 at 10:08:03AM +0100, SF Markus Elfring wrote:
> > Markus, please stop sending these things to rename out labels unless
> > there is a bug.  CodingStyle allows out labels.
> 
> How does this feedback fit to information like the following?
> 
> "?
> Chapter 7: ?
> ?
> Choose label names which say what the goto does or why the goto exists.

A lot of people think "out" says what the goto does and why it exists.
I personally don't agree with them but if you look at when I complain
about it, it's almost always when it causes a bug.

> ? Avoid using GW-BASIC names ?

Those when people just use numbers for their label names instead of
words like out1, out2, out4, out5.  It's a different thing.

regards,
dan carpenter
