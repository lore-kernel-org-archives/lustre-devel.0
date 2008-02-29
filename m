From: Vladimir V. Saveliev <Vladimir.Saveliev@Sun.COM>
Date: Fri, 29 Feb 2008 17:05:12 +0200
Subject: [Lustre-devel] subtree locks and path re-validation avoidance
In-Reply-To: <47BF8FBA.3090705@sun.com>
References: <1203080062.19279.91.camel@linux.site> <47BD7D0D.6090906@sun.com>
	<47BF8FBA.3090705@sun.com>
Message-ID: <1204297512.24711.20.camel@linux.site>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello

On Fri, 2008-02-22 at 20:15 -0700, Peter J Braam wrote:
> I'd like to make a suggestion to perhaps immediately find the right 
> primitives for getcwd to return a reasonably correct pathname in 
> Lustre.

Peter, would you say a bit more about that:

currently, there is nothing a filesystem can do in linux's getcwd. It
simply returns instant dcache path from "." to "/". 

>   I believe this is the simplest case where I have seen pathname 
> revalidation being important.  In the context of that example the 
> subtree lock discussion might gain more clarity.
> 
> I would also like to note that I had a discussion with Linus at one of 
> the kernel workshops in Ottawa maybe almost 4-5 years ago.  First Linus 
> attacked the idea of using file identifiers - he suggested that doing 
> everything with pathnames was better (which is what InterMezzo did).   
> When we explained to him that this requires locking all parents he began 
> to see the problems we had with this and understood the locking at the 
> fid/name level that we use in Lustre.  I found little resistance when I 
> mentioned to him that for this model the VFS does not have a correct 
> implementation of getcwd, unless the dcache is kept current.
> 
> UCSC has received funding from the National Labs and now been turned 
> into a peta-scale I/O institute I believe did more results on file 
> systems implemented with pathnames.  Some things are beautiful and easy 
> with pathnames, but others get really ugly, and so far I don't see this 
> displacing fid ideas that govern NFS, AFS and Lustre.
> 

Best regards,
Vladimir
