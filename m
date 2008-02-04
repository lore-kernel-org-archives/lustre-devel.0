From: Peter J Braam <Peter.Braam@Sun.COM>
Date: Mon, 04 Feb 2008 08:17:10 -0700
Subject: [Lustre-devel] Feed API and Changelog HLD
In-Reply-To: <47A38894.3020002@sun.com>
References: <47A38894.3020002@sun.com>
Message-ID: <47A72C76.7000206@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On page 10 of the changelog API: recursive behavior for directories in 
filesets must exclude directories that are mount point of other filesets 
(as implemented for the Path Forward a few years back).

I didn't see where ABORT sizes are discussed, but as I mentioned before 
there are few cases where ditching records is possible.

The storage of the records should be discussed.  The llog headers may 
need changes and probably the API's for canceling records will change to 
indicate what consumer is canceling.

It would be wise to discuss how disk full failures etc are handled in 
some detail.

- peter -

Nathaniel Rutman wrote:
> The Feed API is a subset of the Changelog HLD.
> Changelog HLD is not complete, but hopefully decently fleshed out at 
> this point.
>
> ------------------------------------------------------------------------
>
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
