From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 15 Dec 2015 17:41:34 +0300
Subject: [lustre-devel] [PATCH 1/7] staging: lustre: Delete unnecessary
 goto statements in six functions
In-Reply-To: <1450189676.3551.1.camel@perches.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<566D7830.9060000@users.sourceforge.net>
	<1450189676.3551.1.camel@perches.com>
Message-ID: <20151215144133.GC5284@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Dec 15, 2015 at 06:27:56AM -0800, Joe Perches wrote:
> On Sun, 2015-12-13 at 14:52 +0100, SF Markus Elfring wrote:
> > From: Markus Elfring <elfring@users.sourceforge.net>
> > Date: Sun, 13 Dec 2015 09:30:47 +0100
> > 
> > Six goto statements referred to a source code position directly behind them.
> > Thus omit such unnecessary jumps.
> 
> I suggest you leave a blank line instead
> of deleting the goto.
> 

What is the point of the little bunny hop?

regards,
dan carpenter
