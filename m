Return-Path: <SRS0=EtqC=H7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.4 required=3.0 tests=BAYES_20,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86085C433E0
	for <lustre-devel@archiver.kernel.org>; Mon,  1 Mar 2021 22:25:41 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 21EB460202
	for <lustre-devel@archiver.kernel.org>; Mon,  1 Mar 2021 22:25:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21EB460202
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=lists.lustre.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2772821F217;
	Mon,  1 Mar 2021 14:25:40 -0800 (PST)
Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com
 [209.85.221.48])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8F40721F217;
 Mon,  1 Mar 2021 14:25:36 -0800 (PST)
Received: by mail-wr1-f48.google.com with SMTP id e10so17573907wro.12;
 Mon, 01 Mar 2021 14:25:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:from:date:message-id:subject:to:cc;
 bh=heUx/kmGVcSZCob8VANLQ71QrKM/pHu6L8HCjrGteMI=;
 b=MjrQ1WpjxekzWT5kwcythz01bFAi+2T1VMl5PAJAloEAyG7MyfK9/ukjRqKPmurePg
 k0d2ZZ9637Z3s1fcg0nMIgLyIALZBFNdSZkT0ZsTVc/xtKNpXABZj7JdzyUEpOVO1VCu
 NX4+QToPJ+A+aUbVFoyjfoEfTJ1MrAJ8Yw0j1yzThAuSBhQ4ItE7RwiQq6GebeDmKNYo
 kN3d3f1pOkGQT1xiKmbL5b8AweDFRtcHq59xAtWH7CzDDGzOZYZ5I+Ml5GRuor/f16+1
 FccUf+sEM7snh/vEH5cIzsNqznQeIjzYiP/GIlUj3Tb1DK+AzJp1MelEcLwgjVo5GVlJ
 fkyw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
 bh=heUx/kmGVcSZCob8VANLQ71QrKM/pHu6L8HCjrGteMI=;
 b=Y2X4LRb1z3rTPaxiw1drT9TmfPBd+7WSiCCgqm77bk8YzLHmLl5ZOEDSasmyBpn2Db
 iZO/xJlcmmLBdTGWmBgDkQ/6lo2+38bEPreUDPnLnmiAQJOULyLHNxvbU0N1DdwfNn/w
 FmOkZ8X50z9ZbSVEsORa7fiMOWs6QzesEi1xJ9qhRerW05NZMV6ygaS77neBjXxUP2r2
 VvFeuOWw9ebJNK2D/Au0FKigmsM1QU6nAyUMDLEXaAjib4BnVR9ay78K71llJsQQPsar
 7CVhooRoZxF/TyF//6Q0vIZvIoD0H3EzH4oIBfy6Qh0ijuLhDt2lIpz/+wXHEV85waT+
 DnnQ==
X-Gm-Message-State: AOAM533Y9yRPtM+HXcORy50d1okMGISQgE1dsvoFpdHDIfnO0VFbKA/O
 PqantNZFTo1PmAbz3lD5vZyrzwsaPBVyQqT4lsAUvBVFgkpQjA==
X-Google-Smtp-Source: ABdhPJz6AmbgwDzw+JIZn8u8PrcWUeQAvYA7/0bgNxLCR8mCtQEQq1HsF0cNpbqFmnVsDMYu8PdiRHVPo7h2BXBOjJM=
X-Received: by 2002:a5d:4b50:: with SMTP id w16mr18481674wrs.34.1614637534961; 
 Mon, 01 Mar 2021 14:25:34 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 1 Mar 2021 14:24:58 -0800
Message-ID: <CABnqofw57pE==TEougqzPA8gLYhMNCkuCByvgdwUM95zH_4Aww@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] Index operations
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
From: Sudheendra Sampath via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Sudheendra Sampath <sudheendra.sampath@gmail.com>
Cc: lustre-discuss@lists.lustre.org
Content-Type: multipart/mixed; boundary="===============0808971154109610237=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============0808971154109610237==
Content-Type: multipart/alternative; boundary="000000000000b6608105bc811874"

--000000000000b6608105bc811874
Content-Type: text/plain; charset="UTF-8"

Hi,

I am trying to understand how index operation work in Lustre.   I have a 2
node setup.  One of them is a client and the other node is hosting both MDS
and OSS with ZFS as backend filesystem.

I put printk in osd_oi_probe() and I see that there are 128 object indexes
created for each of the MDT and OST.

Now, when I create a file or directory from the client I want to know how
the object index gets mapped to file FID.  How the FID -> dnode mapping
works in conjunction with index object.

Any input appreciated.

Thanks,

-Sudhe

--000000000000b6608105bc811874
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi,<div dir=3D"auto"></div>
<div><br></div><div>I am trying to understand how index operation work in L=
ustre.=C2=A0 =C2=A0I have a 2 node setup.=C2=A0 One of them is a client and=
 the other node is hosting both MDS and OSS with ZFS as backend=C2=A0filesy=
stem.</div><div><br></div><div>I put printk in=C2=A0osd_oi_probe() and I se=
e that there are 128 object indexes created for each of the MDT and OST.</d=
iv><div><br></div><div>Now, when I create a file or directory from the clie=
nt I want to know how the object index gets mapped to file FID.=C2=A0 How t=
he FID -&gt; dnode mapping works in conjunction with index object.</div><di=
v><br></div><div>Any input appreciated.</div><div><br></div><div>Thanks,</d=
iv><div><br></div><div>-Sudhe</div></div>

--000000000000b6608105bc811874--

--===============0808971154109610237==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0808971154109610237==--
