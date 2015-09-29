From: Ashish Purkar <ashish.purkar@seagate.com>
Date: Wed, 30 Sep 2015 02:40:23 +0530
Subject: [lustre-devel] Channel Bonding Debug Information
In-Reply-To: <CAAqp6i2jWQheq7aeT+VkQ5+=JsuAuMTJSPewGAfvaC8r8kSf9Q@mail.gmail.com>
References: <CAAqp6i2jWQheq7aeT+VkQ5+=JsuAuMTJSPewGAfvaC8r8kSf9Q@mail.gmail.com>
Message-ID: <CA+HqLi4-Gm_HwC8OUGcYBz53LuZ40mPZyT_Rgjs3vz7nG3R8mg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

It's useful to have Rx, Tx stats counters available from NIDs participating
in channel bonding and SG list usage(Rx,Tx,command/status ring descriptors)
to debug performance problems seen with LACP bonding.

app?
On Sep 29, 2015 1:00 AM, "Amir Shehata" <amir.shehata.whamcloud@gmail.com>
wrote:

> Hello,
>
> As a followup on the discussion in the LAD developer summit, regarding
> ensuring that there is enough debug information provided as part of the
> Channel Bonding solution, I'm sending this email to ask for ideas on what
> type of debug information you would like to see.
>
> thanks
> amir
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
>
> https://urldefense.proofpoint.com/v2/url?u=http-3A__lists.lustre.org_listinfo.cgi_lustre-2Ddevel-2Dlustre.org&d=BQICAg&c=IGDlg0lD0b-nebmJJ0Kp8A&r=FtYV9f_ig6ynAGsdwsQr2_tmRri3ty7J2xOP7XSVZbg&m=_S5QRz-57VM5yeaQJZCqqS9aJS2rCxpXpxAkqPTLpb4&s=ePZoRO7uPl9fRDKoXdNMzz_YNyHPslWDcMNBx34caJk&e=
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150930/96672af6/attachment.htm>
