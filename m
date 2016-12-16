From: Joe Perches <joe@perches.com>
Date: Fri, 16 Dec 2016 11:19:22 -0800
Subject: [lustre-devel] [PATCH] staging : lustre : Remove braces from
	single-line body.
In-Reply-To: <20161216185355.GH8176@mwanda>
References: <1481911175-19592-1-git-send-email-khan.tabrez21@gmail.com>
	<1481913804.29291.92.camel@perches.com> <20161216185355.GH8176@mwanda>
Message-ID: <1481915962.29291.96.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Tabrez khan <khan.tabrez21@gmail.com>, oleg.drokin@intel.com, jsimmons@infradead.org, andreas.dilger@intel.com, devel@driverdev.osuosl.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Fri, 2016-12-16 at 21:53 +0300, Dan Carpenter wrote:
> On Fri, Dec 16, 2016 at 10:43:24AM -0800, Joe Perches wrote:
> > On Fri, 2016-12-16 at 23:29 +0530, Tabrez khan wrote:
> > > Remove unnecessary braces {} from single line if statement.
> > > This warning is found using checkpatch.pl.
> > 
> > []
> > > diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
> > 
> > []
> > > @@ -1134,9 +1134,9 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
> > >  	}
> > >  
> > >  	/* Sanity checks for a reconnected import. */
> > > -	if (!(imp->imp_replayable) != !(msg_flags & MSG_CONNECT_REPLAYABLE)) {
> > > +	if (!(imp->imp_replayable) != !(msg_flags & MSG_CONNECT_REPLAYABLE))
> > >  		CERROR("imp_replayable flag does not match server after reconnect. We should LBUG right here.\n");
> > > -	}
> > > +
> > 
> > There are one too many blank lines now.
> 
> I was expecting checkpatch.pl to catch the extra blank.  It was there in
> the last patch as well.  Apparently it doesn't.

checkpatch is imperfect and always will be.

checkpatch is a stupid little script.

It mostly works on added lines and generally
only looks for style defects on lines that
precede those added lines.

Here the now unnecessary blank line follows the
added blank line.

Oh well.

Anyway, here's an almost completely untested
possible patch to checkpatch.

(also attached because evolution is a terrible
 email client, but I seem to be stuck with it)

---
 scripts/checkpatch.pl | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 1579230ebacc..97078f7629e2 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -3063,6 +3063,19 @@ sub process {
 			$last_blank_line = $linenr;
 		}
 
+# Another check for multiple consecutive blank lines where the following
+# line is part of the context and is also blank
+		if ($line =~ /^\+\s*$/ &&
+		    defined $rawlines[$linenr] &&
+		    $rawlines[$linenr] =~ /^ \s*$/) {
+			if (CHK("LINE_SPACING",
+				"Please don't use multiple blank lines\n" . $hereprev) &&
+			    $fix) {
+				fix_delete_line($fixlinenr, $rawline);
+			}
+			$last_blank_line = $linenr;
+		}
+
 # check for missing blank lines after declarations
 		if ($sline =~ /^\+\s+\S/ &&			#Not at char 1
 			# actual declarations
-------------- next part --------------
A non-text attachment was scrubbed...
Name: cp_trailing_context_blank.diff
Type: text/x-patch
Size: 860 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161216/63a30696/attachment.bin>
