From: Niklas Edmundsson <Niklas.Edmundsson@hpc2n.umu.se>
Date: Wed, 7 Nov 2007 09:39:55 +0100 (MET)
Subject: [Lustre-devel] Checksum Algorithm
In-Reply-To: <200711061130.32694.behlendorf1@llnl.gov>
References: <BLU115-W12E96D373F497BF1EDDCD0CD890@phx.gbl>
	<200711061130.32694.behlendorf1@llnl.gov>
Message-ID: <Pine.GSO.4.64.0711070930110.16770@kleopatra.acc.umu.se>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 6 Nov 2007, Brian Behlendorf wrote:

>  My view on the issue is that it is madness to run with checksums disabled
> and we need to investigate more efficient checksum algorithms.  The current
> crc32 algorithm may be too heavy weight but the simple XOR algorithm you
> propose I fear is not strong enough.  I've seen to many cases now of various
> network components corrupting data in all sorts of interesting ways.
> Happily we have a lot of other choices for algorithms to investigate.
>
>  If you have the time I'd encourage you to investigate an assortment of
> algorithms and see which work best.  Making this a runtime option via
> proc I think is also an excellent idea.

I'd strongly recommend looking at which algorithms are used for 
checksumming in ZFS, they have done rather extensive investigations on 
the subject.

If I remember correctly ZFS is using fletcher by default with good 
performance, with sha256 as an option for those who wants it.

Anyhow, given the nowadays tight bond between CFS and SUN finding the 
relevant info on the subject should be a no-brainer :)

/Nikke
-- 
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  Niklas Edmundsson, Admin @ {acc,hpc2n}.umu.se     |    nikke at hpc2n.umu.se
---------------------------------------------------------------------------
  OH NO, my wife burned the rice crispies--AGAIN!!
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
