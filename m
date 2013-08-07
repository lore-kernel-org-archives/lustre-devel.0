From: Isaac Huang <he.huang@intel.com>
Date: Wed, 7 Aug 2013 14:39:14 -0600
Subject: [Lustre-devel] LND Development
In-Reply-To: <520225E4.1070000@stud.uni-heidelberg.de>
References: <520225E4.1070000@stud.uni-heidelberg.de>
Message-ID: <20130807203914.GA1099@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Aug 07, 2013 at 12:48:04PM +0200, Tobias Groschup wrote:
> ......
> After consulting the Lustre Manual, some guides and papers including 
> "The Lustre Storage Architecture" and "Understanding Lustre Filesystem 
> Internals"  I did not find an comprehensive overview for the API a LND 
> has to implement. Although the function names are easy to find, its not 
> clear what the expected behaviour of the function is, or with which 
> ranges of input data they have to deal.

There's no document on the LND API as far as I know.

> Also, the Doxygen generated from the LNet source files was not very helpful.

That documents the external LNet API, not the LND API.

> So my question is: where do I start to implement a LND?

I'd suggest to read lnet/lnet/lo.c to get a basic understanding of the
LND API. That's the implementation of a simple loopback LND, similar
to the Linux lo if device.

If you're not already familiar with the LNet API, it'd be helpful to
understand its semantics, which is well documented by the LNet Doxygen
comments.

It's a difficult task to build a new LND. So far we have two 3rd party
LNDs contributed to Lustre. If you search the list archives for mxlnd
or gnilnd, you'd find some previous discussions on the LND API.

> And: how can I test a LND without recompiling the whole Lustre RPM?

You can test it with the LNet selftest tool. You'd only need to
compile and replace the LND.ko to test it.

- Isaac
