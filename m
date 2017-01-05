From: Di Natale, Giuseppe <dinatale2@llnl.gov>
Date: Thu, 5 Jan 2017 00:16:42 +0000
Subject: [lustre-devel] (no subject)
Message-ID: <974262C966B9F640899A48EB96313E9A318459F8@PRDEXMBX-08.the-lab.llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Greetings,

I am attempting to port the SysV lnet script as part of a transition to systemd. I ran into the following in lustre/scripts/lnet:

        if [ -x $LUSTRE_LNET_CONFIG_UTILITY -a -f "$LUSTRE_LNET_CONFIG_FILE" ]; then
                $LUSTRE_LNET_CONFIG_UTILITY lnet configure || exit 1
        else
                lctl network up || exit 1
        fi

Can the check for LUSTRE_LNET_CONFIG_UTILITY  (/usr/sbin/lnetctl by default) be removed so that way lnetctl is used exclusively?

Thanks,
Giuseppe Di Natale
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20170105/7e17c5c9/attachment.htm>
