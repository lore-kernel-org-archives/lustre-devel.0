From: tao.peng at emc.com <tao.peng@emc.com>
Date: Thu, 8 Mar 2012 20:54:38 -0500
Subject: [Lustre-devel] oldest lustre supported SUSE kernel
In-Reply-To: <alpine.LFD.2.02.1203081648010.1375@casper.infradead.org>
References: <F19688880B763E40B28B2B462677FBF805E803B132@MX09A.corp.emc.com>
	<9C0BB3E3-D296-42A0-89EA-67F299215215@whamcloud.com>
	<F19688880B763E40B28B2B462677FBF805EC1D87AC@MX09A.corp.emc.com>
	<alpine.LFD.2.02.1203081648010.1375@casper.infradead.org>
Message-ID: <F19688880B763E40B28B2B462677FBF805EC1D87C8@MX09A.corp.emc.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> -----Original Message-----
> From: James Simmons [mailto:jsimmons at infradead.org]
> Sent: Friday, March 09, 2012 12:49 AM
> To: Peng, Tao
> Cc: adilger at whamcloud.com; wc-discuss at whamcloud.com; lustre-devel at lists.lustre.org
> Subject: Re: [Lustre-devel] oldest lustre supported SUSE kernel
> 
> 
> > > On 2012-02-06, at 2:53, <tao.peng@emc.com> wrote:
> > > >
> > > > As I know, the oldest lustre supported RHEL kernel is 2.6.18-latest. What is the oldest SUSE
> kernel?
> > > 2.6.32-latest?
> > >
> > > That depends on which version of Lustre you are asking about, and whether you are asking about the
> > > client or server.
> > >
> > > For Lustre 2.2+ servers it will be SLES11 SP1 (2.6.32), since it matches RHEL6 (2.6.32).
> > >
> > > For clients it is RHEL5 (2.6.18) and SLES11 SP0 (2.6.27).
> > >
> > We found that latest master branch doesn't build client for SLES11 SP0 (2.6.27). Does it mean master
> has moved on dropping SLES11 SP0 or it should be fixed?
> 
> I build and use lustre on SLES11 SP1 clients and routers (using server
> version). It works fine. Is there a reason you use SP0?
We are not using SP0. Just that we are working on cleaning up some old code and would like to make sure Lustre works as it says in the lustre/kernel_patches/which_patch
2.6.27.19-5		(SLES11)

Thanks,
Tao
