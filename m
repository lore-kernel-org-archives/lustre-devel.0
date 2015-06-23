From: Joe Perches <joe@perches.com>
Date: Tue, 23 Jun 2015 15:11:23 -0700
Subject: [lustre-devel] [PATCH 01/12] staging: lustre: fid: Use !x to
 check for kzalloc failure
In-Reply-To: <20150623092303.GN28762@mwanda>
References: <1434819550-3193-1-git-send-email-Julia.Lawall@lip6.fr>
	<1434819550-3193-2-git-send-email-Julia.Lawall@lip6.fr>
	<D1AECA61.F8DE5%andreas.dilger@intel.com>
	<20150623092303.GN28762@mwanda>
Message-ID: <1435097483.2504.10.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 2015-06-23 at 12:23 +0300, Dan Carpenter wrote:
> people decided that
> Yoda code was a good idea based on their gut instead of using statistics
> and measurements and science.

I think that style exists because compilers
disallow CONST = val assignment typos.
