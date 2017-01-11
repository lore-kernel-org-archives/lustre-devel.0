From: Christopher J. Morrone <morrone2@llnl.gov>
Date: Wed, 11 Jan 2017 15:20:39 -0800
Subject: [lustre-devel] (no subject)
In-Reply-To: <30DCC240-3E47-4A2B-8C7B-B46D165C2127@intel.com>
References: <974262C966B9F640899A48EB96313E9A318459F8@PRDEXMBX-08.the-lab.llnl.gov>
	<CAAqp6i21NbmZUsxSRZwkZdbKDp-LO8maFxMjKASYp2Aw6vdpyw@mail.gmail.com>
	<67f5b76c-cadb-747b-cb90-b2b40ca30c65@llnl.gov>
	<CAAqp6i2rJHPWH0nj+TSCjWU7HEMt_MQHpT2Qu6pbLRuUQTEAyw@mail.gmail.com>
	<30DCC240-3E47-4A2B-8C7B-B46D165C2127@intel.com>
Message-ID: <34fdf36d-b7d2-4a50-9656-dd720d805d31@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Right, I meant copy in lnet-specific functionality from lctl to lnetctl.
 I didn't mean to sound like I was suggesting moving the rest of lctl's
non-lnet parts into lnetctl.

Chris

On 01/10/2017 08:18 PM, Dilger, Andreas wrote:
> It's fine to add the lnet-specific functionality from lctl to lnetctl,
> but we shouldn't remove existing functionality from lctl to avoid
> breaking scripts that may be using it today.  4+ releases after all of
> the LNet specific lctl functionality has been added to lnetctl we can
> start printing deprecation warnings, and after 8+ releases they can be
> removed.
> 
>  
> 
> Cheers, Andreas
> 
> -- 
> 
> Andreas Dilger
> 
> Lustre Principal Architect
> 
> Intel High Performance Data Division
> 
>  
> 
> On 2017/01/10, 18:08, "lustre-devel on behalf of Amir Shehata"
> <lustre-devel-bounces@lists.lustre.org
> <mailto:lustre-devel-bounces@lists.lustre.org> on behalf of
> amir.shehata.whamcloud at gmail.com
> <mailto:amir.shehata.whamcloud@gmail.com>> wrote:
> 
>  
> 
> lnetctl was designed to control LNet only. We have not moved the rest of
> the lctl functionality. lctl does a lot of other lustre specific functions.
> 
>  
> 
> The idea was to have lnetctl be only LNet specific, and lctl lustre
> specific. In essence we are attempting to decouple LNet from lustre.
> There has been some talk about upstreaming LNet before lustre with all
> the work that James Simmons from ORNL is doing.
> 
>  
> 
> thanks
> 
> amir
> 
>  
> 
> On 10 January 2017 at 14:06, Christopher J. Morrone <morrone2@llnl.gov
> <mailto:morrone2@llnl.gov>> wrote:
> 
>     Sounds good to me.  Ideally, lnetctl should be able to do everything
>     that lctl could do (plus all of the new features).  Has it reached
>     parity?  If not, what else still remains to be done?
> 
>     Chris
> 
>     On 01/10/2017 12:15 PM, Amir Shehata wrote:
>     > lctl usage is kept for backwards compatibility. Eventually, we
>     should be
>     > moving to using lnetctl exclusively. Which lustre-release we should do
>     > that in, is the question. 2.10?
>     >
>     > thanks
>     > amir
>     >
>     > On 4 January 2017 at 16:16, Di Natale, Giuseppe
>     <dinatale2 at llnl.gov <mailto:dinatale2@llnl.gov>
>     > <mailto:dinatale2 at llnl.gov <mailto:dinatale2@llnl.gov>>> wrote:
>     >
>     >     Greetings,
>     >
>     >     I am attempting to port the SysV lnet script as part of a
>     transition
>     >     to systemd. I ran into the following in lustre/scripts/lnet:
>     >
>     >             if [ -x $LUSTRE_LNET_CONFIG_UTILITY -a -f
>     >     "$LUSTRE_LNET_CONFIG_FILE" ]; then
>     >                     $LUSTRE_LNET_CONFIG_UTILITY lnet configure ||
>     exit 1
>     >             else
>     >                     lctl network up || exit 1
>     >             fi
>     >
>     >     Can the check for LUSTRE_LNET_CONFIG_UTILITY 
>     (/usr/sbin/lnetctl by
>     >     default) be removed so that way lnetctl is used exclusively?
>     >
>     >     Thanks,
>     >     Giuseppe Di Natale
>     >
>     >     _______________________________________________
>     >     lustre-devel mailing list
>     >     lustre-devel at lists.lustre.org
>     <mailto:lustre-devel@lists.lustre.org>
>     <mailto:lustre-devel@lists.lustre.org
>     <mailto:lustre-devel@lists.lustre.org>>
>     >     http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>     >     <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>
> 
>     >
>     >
>     >
>     >
>     > _______________________________________________
>     > lustre-devel mailing list
>     > lustre-devel at lists.lustre.org <mailto:lustre-devel@lists.lustre.org>
>     > http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>     >
> 
>     _______________________________________________
>     lustre-devel mailing list
>     lustre-devel at lists.lustre.org <mailto:lustre-devel@lists.lustre.org>
>     http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> 
>  
> 
