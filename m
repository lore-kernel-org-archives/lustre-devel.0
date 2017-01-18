From: Amir Shehata <amir.shehata.whamcloud@gmail.com>
Date: Wed, 18 Jan 2017 12:10:42 -0800
Subject: [lustre-devel] (no subject)
In-Reply-To: <alpine.LFD.2.20.1701162100360.27875@casper.infradead.org>
References: <974262C966B9F640899A48EB96313E9A318459F8@PRDEXMBX-08.the-lab.llnl.gov>
	<CAAqp6i21NbmZUsxSRZwkZdbKDp-LO8maFxMjKASYp2Aw6vdpyw@mail.gmail.com>
	<67f5b76c-cadb-747b-cb90-b2b40ca30c65@llnl.gov>
	<alpine.LFD.2.20.1701162100360.27875@casper.infradead.org>
Message-ID: <CAAqp6i1LPAqEehrzpZaoOP-SdFZQB4e08Vs6J9z=JL5y3PFtFg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We have a patch for lnetctl ping coming in soon.

On 16 January 2017 at 13:02, James Simmons <jsimmons@infradead.org> wrote:

>
> > Sounds good to me.  Ideally, lnetctl should be able to do everything
> > that lctl could do (plus all of the new features).  Has it reached
> > parity?  If not, what else still remains to be done?
>
> No lctl pings and the peer and connection handling is missing. I did
> some work to support the missing features in lnetctl and combined with
> multi-rail should fill in the gaps. Also we are missing lnetctl ping
> but I think multi-rail might fix that. Not 100% sure tho.
>
> >
> > Chris
> >
> > On 01/10/2017 12:15 PM, Amir Shehata wrote:
> > > lctl usage is kept for backwards compatibility. Eventually, we should
> be
> > > moving to using lnetctl exclusively. Which lustre-release we should do
> > > that in, is the question. 2.10?
> > >
> > > thanks
> > > amir
> > >
> > > On 4 January 2017 at 16:16, Di Natale, Giuseppe <dinatale2@llnl.gov
> > > <mailto:dinatale2@llnl.gov>> wrote:
> > >
> > >     Greetings,
> > >
> > >     I am attempting to port the SysV lnet script as part of a
> transition
> > >     to systemd. I ran into the following in lustre/scripts/lnet:
> > >
> > >             if [ -x $LUSTRE_LNET_CONFIG_UTILITY -a -f
> > >     "$LUSTRE_LNET_CONFIG_FILE" ]; then
> > >                     $LUSTRE_LNET_CONFIG_UTILITY lnet configure || exit
> 1
> > >             else
> > >                     lctl network up || exit 1
> > >             fi
> > >
> > >     Can the check for LUSTRE_LNET_CONFIG_UTILITY  (/usr/sbin/lnetctl by
> > >     default) be removed so that way lnetctl is used exclusively?
> > >
> > >     Thanks,
> > >     Giuseppe Di Natale
> > >
> > >     _______________________________________________
> > >     lustre-devel mailing list
> > >     lustre-devel at lists.lustre.org <mailto:lustre-devel@lists.
> lustre.org>
> > >     http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> > >     <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>
> > >
> > >
> > >
> > >
> > > _______________________________________________
> > > lustre-devel mailing list
> > > lustre-devel at lists.lustre.org
> > > http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> > >
> >
> > _______________________________________________
> > lustre-devel mailing list
> > lustre-devel at lists.lustre.org
> > http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> >
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170118/75d022c0/attachment.htm>
