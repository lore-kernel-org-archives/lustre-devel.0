From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 2 Dec 2015 16:59:30 +0300
Subject: [lustre-devel] [PATCH 21/40] staging: lustre: improve LNet
 clean up code and API
In-Reply-To: <CAHtKf-aEa4YvhgvZgAFLuOVbX=bdmC+YQwaAH5p2-qCAS_W8Vg@mail.gmail.com>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-22-git-send-email-jsimmons@infradead.org>
	<20151202125440.GS18797@mwanda>
	<CAHtKf-aEa4YvhgvZgAFLuOVbX=bdmC+YQwaAH5p2-qCAS_W8Vg@mail.gmail.com>
Message-ID: <20151202135930.GM7289@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Dec 02, 2015 at 04:20:59PM +0300, Alexander Zarochentsev wrote:
> >  BAD:   if (rc != 0)
> > GOOD:   if (rc)
> 
> The latest suggestion is not correct,
> from http://wiki.lustre.org/Lustre_Coding_Guidelines :
> Conditional boolean (if (expr)), scalar (if (val != 0)) and pointer
> (if (ptr != NULL)) expressions should be written consistently.

Kernel style trumps Lustre style.  Double negative don't not hurt
readability.  != NULL is a checkpatch.pl warning.  Also comparisons like
== false or == true are checkpatch warnings.

I can think of two places where comparing with zero is appropriate and
those are:

1)  If you are talking about the numer zero.

	if (x == 0 || x == 2)

2) strcmp() and other *cmp() functions.

	if (strcmp(foo, bar) == 0)   /* foo and bar are the same */
	if (strcmp(foo, bar) < 0)    /* foo less than bar */
	if (strcmp(foo, bar) != 0)   /* foo not the same as bar */

For "if (rc) {" a zero return doesn't mean zero, it means success so
comparing against zero is bad style.

regards,
dan carpenter
