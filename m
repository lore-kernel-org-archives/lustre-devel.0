From: Lee Ward <lee@sandia.gov>
Date: Thu, 10 Sep 2009 13:03:05 -0600
Subject: [Lustre-devel] Multithreaded liblustre
In-Reply-To: <EBD3008A-44E8-4A1E-A642-4777F7D206C7@sun.com>
References: <68880AC1-3DDB-4B20-AE49-55227D64F295@swedisk.se>
	<EBD3008A-44E8-4A1E-A642-4777F7D206C7@sun.com>
Message-ID: <1252609385.3953.41.camel@wheel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, 2009-09-10 at 12:39 -0600, Oleg Drokin wrote:
> Hello!
> 
> On Sep 10, 2009, at 8:52 AM, Tuve Nordius wrote:
> > Does anyone know what need to be done/ the main obstacles  in order to
> > make liblustre multithreaded?
> 
> What sort of multi-threadness are you looking at?
> Currently socklnd has separate threads if I remember right.
> There are no callbacks and other async stuff happening, but that is
> pretty much by design so would be hard to change.

If you are talking about the API, the current head for SYSIO is
thread-safe for all but initialization, mount, unmount, and shutdown.
Don't think it works for liblustre at present, but rklundt at sandia.gov is
currently doing a port, maybe done already.

Re-entrancy is to be supported some time in 2010.

But... I thought SUN had dropped support for liblustre entirely? Did I
miss something?

		--Lee

> 
> Bye,
>      Oleg
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
