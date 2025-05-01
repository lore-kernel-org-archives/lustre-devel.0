Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9471CC369D9
	for <lustre-devel@archiver.kernel.org>; Thu,  1 May 2025 02:18:17 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZnyQ756nkz1xfN;
	Wed, 30 Apr 2025 19:18:07 -0700 (PDT)
Received: from mail-oo1-f46.google.com (mail-oo1-f46.google.com
 [209.85.161.46])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZnyQ51mLCz1xS0
 for <lustre-devel@lists.lustre.org>; Wed, 30 Apr 2025 19:18:05 -0700 (PDT)
Received: by mail-oo1-f46.google.com with SMTP id
 006d021491bc7-601f3674116so122332eaf.2
 for <lustre-devel@lists.lustre.org>; Wed, 30 Apr 2025 19:18:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1746065884; x=1746670684; darn=lists.lustre.org;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:from:to:cc:subject:date:message-id:reply-to;
 bh=GmVyzSHVctKnjefS+XVG2PSAPK1Ob04sbtYqf+itgW8=;
 b=ELWFYwth1pCTehgKn4OLbTWQ0eOq1Dsxw4P2S4xHcyowcAPXQ6dg+225XxbFA1jVbS
 XBaShXTmyGN5zUvU2wDY4gCbdzff6Edu5TzxSnef3VINx+1+m1aHEKQGdYih8vppfIQp
 mn5a0bppEERylSaf2Oinhg91FofttUyKh8MB/NrcNNhhmlF3z71vq8jFPHDF9OnHJGAs
 xAQaoSIsD+OOSu1U4ARc7VXe5VetutXtwCg8EzCW9m7oOAhxK739z/wsMMiT0p2PGK3t
 mgfwXPsdThcjAMtJTy2GLwZzUNDSclQ2D7iDqIIlUtrCA7w1iMT/74m/k4aXxBGe7rM9
 Q8tg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1746065884; x=1746670684;
 h=cc:to:subject:message-id:date:from:in-reply-to:references
 :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
 :reply-to;
 bh=GmVyzSHVctKnjefS+XVG2PSAPK1Ob04sbtYqf+itgW8=;
 b=rKskneZwheGi1tCUsAHiwL+G4/A4vOsdUy0cN3qyjTZUwnJeJwPDPyr19FkBPyDqPI
 xsuaFK88etIZE8EJL1z8SDIuojc5Cfxe3ELpnWwN6zIkFOOuLaCMyXLiyk7Ou2LLKi6Z
 6jRaDqz48oV9lHPqwPOpRc7zWRWaH//4UvznmHLawM4uRDe0uGozptnL0XMRkq3i3I06
 Lx9vY7etruhtT/2X37PEBZqOEA6SU3aWzN9qeh0qX1PL5tcCQCjMCiZaSpPxWLdSSb1R
 IkvlPgnscNwRuGyXcQB94HNcZb9gx7mEO6ea3Xy93Jpt/oWNH+g9miPSWXzKR0F0IIry
 0kEQ==
X-Gm-Message-State: AOJu0YxxXTo0D6OoxYOMDVFepltPW60UpMj/IKp1Uvhs+8xF3fL3/hUL
 Y+k8Z6NTugTsamRUpf4N0vnsZAjgZFVwKdAmAcxggLYDT2QWCuNKStXn51LvwklAxOu8rxoP1Q+
 aKFsrS61MTXstpLbWjdNvZNkf6fg=
X-Gm-Gg: ASbGncvwV6KetQgzoRl7nIbQswaYXtCJInOAV1gfWED77HdpnPSN72RPtYEnKWEdPqr
 o+2PaDq5hy2/5WgE1D1W2wHRCfNNxbHgSqiFEPP/DN5eOiSDMLxSbofiMT9pMvr8IwhBY8p3dzk
 OnN3vxHqZhwwUFdcPf8R9ubA==
X-Google-Smtp-Source: AGHT+IGGKo0clpNDaRxQrpGDItUllCSxQRoamRKDuc/7vgO6QS5gM7kyE8iHt6T3IAw/jPRBwVDDDBGjN/fI12BvrYc=
X-Received: by 2002:a05:6820:150d:b0:606:8579:4c5b with SMTP id
 006d021491bc7-607d43d5bf5mr3014525eaf.1.1746065884101; Wed, 30 Apr 2025
 19:18:04 -0700 (PDT)
MIME-Version: 1.0
References: <CAFhHJgkiiieEWpva9wtgNzr1iWbbc494BWxK9=9sqdEVkHhTHA@mail.gmail.com>
 <DC413C4A-68E7-4830-BAE7-ED34E094FCD1@ddn.com>
In-Reply-To: <DC413C4A-68E7-4830-BAE7-ED34E094FCD1@ddn.com>
From: GEORGE ZHAO <georgezhaojobs@gmail.com>
Date: Wed, 30 Apr 2025 22:18:01 -0400
X-Gm-Features: ATxdqUGyGbWf5HqLe4WWolshGpXHM2CZASwsRO8mm4_m-fq4Vd910rdHIE17BcI
Message-ID: <CAFhHJg=GrakUdiZ713MjmDfUSFypNtc0HDfjVOsaWPrp+qzjQQ@mail.gmail.com>
To: Andreas Dilger <adilger@ddn.com>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Subject: Re: [lustre-devel] 
	=?utf-8?q?New_contributor_inquiry_=E2=80=93_statu?=
	=?utf-8?q?s_of_LU-1643_=28=E2=80=9Creserved_space=E2=80=9D_in_stat?=
	=?utf-8?q?fs/df=29_and_guidance_requested?=
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Content-Type: multipart/mixed; boundary="===============6639989712537574342=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============6639989712537574342==
Content-Type: multipart/alternative; boundary="000000000000c6c103063409a4d0"

--000000000000c6c103063409a4d0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Thank you, Andreas!
I'm currently looking into LU-7880. Will follow up if I have an
implementation plan or run into any questions (quite likely).

By the way, should I reach out to the lustre-devel for questions like this,
or is there a more specific channel?

Thanks!
George

On Wed, Apr 30, 2025 at 4:44=E2=80=AFAM Andreas Dilger <adilger@ddn.com> wr=
ote:

> Hi George,
> thanks for your interest.  There are definitely a number of open tickets
> in the "easy" (and "medium") categories that you could work on, though
> there have been a number of interns and new hires working on those ticket=
s
> recently and fewer are now available.
>
> LU-1643 happens to be the oldest "easy" ticket, but don't let that guide
> your selection.  I would suggest you take a look through the whole list a=
nd
> pick something that is of interest to you and/or matches your experience
> level.
>
> - LU-16738 <https://jira.whamcloud.com/browse/LU-16738> - Improve
> mount.lustre with many MGS NIDs
> <https://jira.whamcloud.com/browse/LU-16738>: this is partly a userspace
> (mount.lustre) change and partly in the kernel (though not incredibly
> complex).  This is actually in the "useful" category that provides improv=
ed
> functionality for something that is seen regularly.
>
>
> If you are feeling more adventurous, you might look at one of the "medium=
"
> tickets, which may not be too difficult:
> - LU-7880 <https://jira.whamcloud.com/browse/LU-7880> - add OST/MDT
> performance statistics to obd_statfs
> <https://jira.whamcloud.com/browse/LU-7880>:  this is a very useful
> feature that would allow clients/user applications to probe the IO load o=
n
> OSTs, and self-optimize checkpoint IO to times when the OSTs are less bus=
y
> - LU-13123 <https://jira.whamcloud.com/browse/LU-13123> - Add list of
> client NIDs to job_stats output
> <https://jira.whamcloud.com/browse/LU-13123>: this would associate all of
> the clients that are contributing to the job_stats for a specific JobID,
> and would be useful for debugging and monitoring/
>
> On Apr 29, 2025, at 17:41, GEORGE ZHAO <georgezhaojobs@gmail.com> wrote:
>
>
> I'm a storage engineer and a Lustre beginner who just figured out how to
> deploy it. Did read a lot about it though.
> My goal is using Lustre to support HPC/ML workload. And I believe doing
> some tasks would help me proceed better.
>
> As wiki suggested, I found an "easy" ticket LU-1643: =E2=80=9CRequest to =
remove
> display of reserved space from statfs (df) total space.=E2=80=9D
> Is it still unclaimed?
> If it's already in progress, or there's a higher priority issue that coul=
d
> use help, please point me in the right direction.
>
> Thanks in advance for any advice.
>
> Best regards,
> George
> _______________________________________________
> lustre-devel mailing list
> lustre-devel@lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>
>
> Cheers, Andreas
> =E2=80=94
> Andreas Dilger
> Lustre Principal Architect
> Whamcloud/DDN
>
>
>
>
>

--000000000000c6c103063409a4d0
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr">Thank you, Andreas!<br>I&#39;m currently =
looking into LU-7880. Will follow up if I have an implementation plan or ru=
n into any questions (quite likely).<br><br>By the way, should I reach out =
to the lustre-devel for questions like this, or is there a more specific ch=
annel?<br><div><br></div><div>Thanks!</div><div>George</div></div><br><div =
class=3D"gmail_quote gmail_quote_container"><div dir=3D"ltr" class=3D"gmail=
_attr">On Wed, Apr 30, 2025 at 4:44=E2=80=AFAM Andreas Dilger &lt;<a href=
=3D"mailto:adilger@ddn.com">adilger@ddn.com</a>&gt; wrote:<br></div><blockq=
uote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1p=
x solid rgb(204,204,204);padding-left:1ex">



<div>
Hi George,
<div>thanks for your interest.=C2=A0 There are definitely a number of open =
tickets in the &quot;easy&quot; (and &quot;medium&quot;) categories that yo=
u could work on, though there have been a number of interns and new hires w=
orking on those tickets recently and fewer are now available.</div>
<div><br>
</div>
<div>LU-1643 happens to be the oldest &quot;easy&quot; ticket, but don&#39;=
t let that guide your selection.=C2=A0 I would suggest you take a look thro=
ugh the whole list and pick something that is of interest to you and/or mat=
ches your experience level.</div>
<div><br>
</div>
<div>-=C2=A0<a href=3D"https://jira.whamcloud.com/browse/LU-16738" id=3D"m_=
1429994837881312626key-val" rel=3D"75582" target=3D"_blank">LU-16738</a>=C2=
=A0-=C2=A0<a href=3D"https://jira.whamcloud.com/browse/LU-16738" target=3D"=
_blank">Improve mount.lustre
 with many MGS NIDs</a>: this is partly a userspace (mount.lustre) change a=
nd partly in the kernel (though not incredibly complex).=C2=A0 This is actu=
ally in the &quot;useful&quot; category that provides improved functionalit=
y for something that is seen regularly.</div>
<div><br>
</div>
<div><br>
</div>
<div>If you are feeling more adventurous, you might look at one of the &quo=
t;medium&quot; tickets, which may not be too difficult:</div>
<div>-=C2=A0<a href=3D"https://jira.whamcloud.com/browse/LU-7880" target=3D=
"_blank">LU-7880</a>=C2=A0-=C2=A0<a href=3D"https://jira.whamcloud.com/brow=
se/LU-7880" target=3D"_blank">add OST/MDT performance statistics to obd_sta=
tfs</a>:
 =C2=A0this is a very useful feature that would allow clients/user applicat=
ions to probe the IO load on OSTs, and self-optimize checkpoint IO to times=
 when the OSTs are less busy</div>
<div>-=C2=A0<a href=3D"https://jira.whamcloud.com/browse/LU-13123" target=
=3D"_blank">LU-13123</a>=C2=A0-=C2=A0<a href=3D"https://jira.whamcloud.com/=
browse/LU-13123" target=3D"_blank">Add list of client NIDs to job_stats out=
put</a>:
 this would associate all of the clients that are contributing to the job_s=
tats for a specific JobID, and would be useful for debugging and monitoring=
/<br id=3D"m_1429994837881312626lineBreakAtBeginningOfMessage">
<div><br>
<div>
<div>On Apr 29, 2025, at 17:41, GEORGE ZHAO &lt;<a href=3D"mailto:georgezha=
ojobs@gmail.com" target=3D"_blank">georgezhaojobs@gmail.com</a>&gt; wrote:<=
/div>
</div>
<blockquote type=3D"cite">
<div>
<div>
<div>
<div dir=3D"ltr">
<div><br>
</div>
<div>I&#39;m a storage engineer and a Lustre=C2=A0beginner who just figured=
 out how to deploy it. Did read a lot about it though.</div>
<div>My goal is using Lustre to support=C2=A0HPC/ML workload. And I believe=
 doing some tasks would help me proceed better.</div>
<div><br>
</div>
<div>As wiki suggested, I found an &quot;easy&quot; ticket LU-1643: =E2=80=
=9CRequest to remove display of reserved space from statfs (df) total space=
.=E2=80=9D</div>
<div>Is it still unclaimed?=C2=A0</div>
<div>If it&#39;s already in progress, or there&#39;s a higher priority issu=
e that could use help, please point me in the right direction.</div>
<div><br>
</div>
<div>Thanks in advance for any advice.<br>
<br>
Best regards,</div>
<div>George</div>
</div>
</div>
</div>
_______________________________________________<br>
lustre-devel mailing list<br>
<a href=3D"mailto:lustre-devel@lists.lustre.org" target=3D"_blank">lustre-d=
evel@lists.lustre.org</a><br>
<a href=3D"http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org" ta=
rget=3D"_blank">http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.or=
g</a><br>
</div>
</blockquote>
</div>
<br>
<div>
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div dir=3D"auto" style=3D"color:rgb(0,0,0);letter-spacing:normal;text-alig=
n:start;text-indent:0px;text-transform:none;white-space:normal;word-spacing=
:0px;text-decoration:none">
<div>Cheers, Andreas</div>
<div>=E2=80=94</div>
<div>Andreas Dilger</div>
<div>Lustre Principal Architect</div>
<div>Whamcloud/DDN</div>
</div>
<br>
</div>
<br>
<br>
</div>
<br>
</div>
</div>

</blockquote></div></div>

--000000000000c6c103063409a4d0--

--===============6639989712537574342==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============6639989712537574342==--
