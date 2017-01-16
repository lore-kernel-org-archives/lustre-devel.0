From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 21:00:24 +0000 (GMT)
Subject: [lustre-devel] LUSTRE_LNET_CONFIG_UTILITY in lnet SysV script
In-Reply-To: <CAAqp6i3ugkCEhXbr+oYDdfJgte9cz0qvDgNS1zLbZ6EaBn17FQ@mail.gmail.com>
References: <974262C966B9F640899A48EB96313E9A318459F8@PRDEXMBX-08.the-lab.llnl.gov>
	<1ea178df-8afa-135a-3bde-a2e7b7fc5e12@llnl.gov>
	<CAAqp6i1SCn8XJT1Qouq5zPpkjQyT10ePSxRJF1w0xvGQqGNh9g@mail.gmail.com>
	<CAAqp6i3ugkCEhXbr+oYDdfJgte9cz0qvDgNS1zLbZ6EaBn17FQ@mail.gmail.com>
Message-ID: <alpine.LFD.2.20.1701162058300.27875@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> We can probably make these YAML parsing libraries mandatory and checked in the configuration step. If not
> there the build doesn't move forward until they are installed. The libraries will also need to be
> installed on the nodes which Lustre is deployed on.

The reason for this was that SLES11 lacked yaml support. Today a 
search libyaml will show it is available on all the platforms
lustre is supported on. Even SLES11SP4 has yaml support now.
I support making this a hard requirement.

> On 10 January 2017 at 12:17, Amir Shehata <amir.shehata.whamcloud@gmail.com> wrote:
>       The reason it is conditional is because we use 3rd party library for YAML parsing. If this is
>       not installed on the build system, then we wouldn't be building lnetctl in that scenario.
> I agree that we should be removing DLC terminology from the code.
> 
> thanks
> amir
> 
> On 4 January 2017 at 17:36, Christopher J. Morrone <morrone2@llnl.gov> wrote:
>       lnetctl is currently an optional build, and its build is not even
>       enabled by default in the lustre spec file.? To use lnetctl exclusively,
>       we would need lnetctl's build would need to be unconditional.
> 
>       I don't have a problem with making the lnetctl build unconditional.? I'm
>       not sure why it was done that way.? Perhaps someone else can comment on
>       that.
> 
>       When/if lnetctl is built unconditionally, it would be nice to purge the
>       "DLC" terminology from the code.
> 
>       Chris
> 
>       On 01/04/2017 04:16 PM, Di Natale, Giuseppe wrote:
>       > Greetings,
>       >
>       > I am attempting to port the SysV lnet script as part of a transition to
>       > systemd. I ran into the following in lustre/scripts/lnet:
>       >
>       >? ? ? ? ?if [ -x $LUSTRE_LNET_CONFIG_UTILITY -a -f
>       > "$LUSTRE_LNET_CONFIG_FILE" ]; then
>       >? ? ? ? ? ? ? ? ?$LUSTRE_LNET_CONFIG_UTILITY lnet configure || exit 1
>       >? ? ? ? ?else
>       >? ? ? ? ? ? ? ? ?lctl network up || exit 1
>       >? ? ? ? ?fi
>       >
>       > Can the check for LUSTRE_LNET_CONFIG_UTILITY? (/usr/sbin/lnetctl by
>       > default) be removed so that way lnetctl is used exclusively?
>       >
>       > Thanks,
>       > Giuseppe Di Natale
>       >
>       >
>       > _______________________________________________
>       > lustre-devel mailing list
>       > lustre-devel at lists.lustre.org
>       > http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>       >
> 
>       _______________________________________________
>       lustre-devel mailing list
>       lustre-devel at lists.lustre.org
>       http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> 
> 
> 
> 
> 
