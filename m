From: Joe Perches <joe@perches.com>
Date: Wed, 16 May 2018 08:44:06 -0700
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: obdclass: change
 object lookup to no wait mode
In-Reply-To: <EDCE6E68-0B5C-4F82-B356-8D70AE5FF92A@intel.com>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
 <1525285308-15347-5-git-send-email-jsimmons@infradead.org>
 <20180508114500.qrtnjax4siupgv3n@mwanda>
 <alpine.LFD.2.21.1805150207500.576@casper.infradead.org>
 <20180516080022.b4ihz7opiueobm7u@mwanda>
 <EDCE6E68-0B5C-4F82-B356-8D70AE5FF92A@intel.com>
Message-ID: <e889f1ece72522303916a755d2dfac507de07de9.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>, Dan Carpenter <dan.carpenter@oracle.com>
Cc: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, "Siyao, Lai" <lai.siyao@intel.com>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, 2018-05-16 at 09:12 +0000, Dilger, Andreas wrote:
> On May 16, 2018, at 02:00, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> > 
> > On Tue, May 15, 2018 at 04:02:55PM +0100, James Simmons wrote:
> > > 
> > > > > 	/*
> > > > > 	 * Allocate new object. This may result in rather complicated
> > > > > 	 * operations, including fld queries, inode loading, etc.
> > > > > 	 */
> > > > > 	o = lu_object_alloc(env, dev, f, conf);
> > > > > -	if (IS_ERR(o))
> > > > > +	if (unlikely(IS_ERR(o)))
> > > > > 		return o;
> > > > > 
> > > > 
> > > > This is an unrelated and totally pointless.  likely/unlikely annotations
> > > > hurt readability, and they should only be added if it's something which
> > > > is going to show up in benchmarking.  lu_object_alloc() is already too
> > > > slow for the unlikely() to make a difference and anyway IS_ERR() has an
> > > > unlikely built in so it's duplicative...
> > > 
> > > Sounds like a good checkpatch case to test for :-)
> > 
> > The likely/unlikely annotations have their place in fast paths so a
> > checkpatch warning would get annoying...
> 
> I think James was suggesting a check for unlikely(IS_ERR()),

Probably so.

$ git grep -P 'likely\s*\(\s*\!?\s*IS_ERR' | wc -l
42

Are there other known likely/unlikely duplications?

>  or possibly
> a check for unlikely() on something that is already unlikely() after CPP
> expansion.

checkpatch isn't the tool for that type of test
as it is a collection of trivial regex tests and
it is not a c90 preprocessor.

Anyway, here's a possible checkpatch patch.
---
 scripts/checkpatch.pl | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index baddac9379f0..20c0973f1c39 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -6299,6 +6299,12 @@ sub process {
 			      "#define of '$1' is wrong - use Kconfig variables or standard guards instead\n" . $herecurr);
 		}
 
+# likely/unlikely tests with IS_ERR (already unlikely)"
+		if ($line =~ /\b((?:un)?likely)\s*\(\s*\!?\s*(IS_ERR[A-Z_]*)\s*\(/) {
+			WARN("DUPLICATE_LIKELY",
+			     "Unnecessary use of $1 with $2 as it already has an unlikely\n" . $herecurr);
+		}
+
 # likely/unlikely comparisons similar to "(likely(foo) > 0)"
 		if ($^V && $^V ge 5.10.0 &&
 		    $line =~ /\b((?:un)?likely)\s*\(\s*$FuncArg\s*\)\s*$Compare/) {
