Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id BD008C433EF
	for <lustre-devel@archiver.kernel.org>; Tue, 28 Dec 2021 01:54:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A67BF2462B4;
	Mon, 27 Dec 2021 17:53:41 -0800 (PST)
Received: from mail-yb1-f170.google.com (mail-yb1-f170.google.com
 [209.85.219.170])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AE07421FFE6
 for <lustre-devel@lists.lustre.org>; Mon, 27 Dec 2021 17:53:39 -0800 (PST)
Received: by mail-yb1-f170.google.com with SMTP id d201so25597972ybc.7
 for <lustre-devel@lists.lustre.org>; Mon, 27 Dec 2021 17:53:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=oGOKorLE7lsq1Iu/U9wppBMTBfbxK4GEqqdHWI8TgGI=;
 b=ejWnQtnvquSIkVec7XA2/mk6ZoQqiVQFPSfBkp+rAspRMsyx5u+JNH+W9iiD9LIsku
 D4rkgQx1nDE95rSeQvYMrMJb9eABbQb+1t3nX1KVGXbP1o2s9A2MxhqwCvyfuu2oWyGc
 qDPNVN0k+rwFmcpDS89GFMB4vz3Mfige8oXg1UvPcdJTc9VieG7TBaN6bsVakLo5a7kQ
 VkhxnkmrQGPQypA2VZAp38qKegganNfURR1dFfhvyk9FeE1YBkrRVZdCQjQee4tP/CVl
 rL6nvzzm/kcrXv9kze0ezWNQ14Hm8I8uESOCTboGboF62NmRnt5YKE5Do4MToriyIX9C
 hIpg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=oGOKorLE7lsq1Iu/U9wppBMTBfbxK4GEqqdHWI8TgGI=;
 b=mZvNE9PRByWIuW7mlstScc3mNVOiyK0HCh4eucjzvIg8nonuDduweWSU2rM+CDEK+F
 VnRw0+lZW0yuQJSbpQB+OtGi4rWntixn0CCwCPqOgDis4w6IclTRUbXASpQNjhNZR5l3
 pakYTRvAAv1+8X49rl11jckSO7U0OFC9Am5HQnLhiohHzTuHV72cJ8igD3TAKaAGm5sF
 e7aIPyptBvH1J051/OX6BZyo/eUdC/TX7AHN4+hpebEeeoEBxgedTw4E9UZWi/RF3MTJ
 mV2Nuiy8MopRuv2KI0M/dxh89mZ0AjxozI/LBWc9obgh78Cj63JFDLidNylChMITc8Wi
 LJUg==
X-Gm-Message-State: AOAM5303bZCrUatfqHgIBImTargm3/LTm5Dx5gY2CZByBBgV0N91Dsvu
 ewayO00SQj9zU6yD06My5o/9cQ96OXfpaM+x0/IxhQ==
X-Google-Smtp-Source: ABdhPJxFdPDNy3O2EzrGK4nDJjDO6wmOxFDkJgRlT1ro0arHyG/vap76ZDaVn9Pyd0vMx65t5wrzqgtTYglUIELSa34=
X-Received: by 2002:a25:8a:: with SMTP id 132mr8965723yba.738.1640656419137;
 Mon, 27 Dec 2021 17:53:39 -0800 (PST)
MIME-Version: 1.0
References: <CAKoKPby+hn5+py-f11c31Po241871un0v=SQM+Cc6_hzvxW8uA@mail.gmail.com>
 <CAKoKPbxTcSxGzASKyVhiv_7W3OY6x3DRtkcTu8hzvLM+4-PzZw@mail.gmail.com>
 <6C592E3F-0437-4776-BB29-C5EE489C5FAE@whamcloud.com>
 <CAKoKPbxmvn7GVc6wsYrLP_HD8SpNMVFfSFdiZMo-5ZXqS-HSdg@mail.gmail.com>
 <7AAC4FDA-AC84-4E73-83AB-130B6BD3AE1B@whamcloud.com>
In-Reply-To: <7AAC4FDA-AC84-4E73-83AB-130B6BD3AE1B@whamcloud.com>
Date: Tue, 28 Dec 2021 09:53:03 +0800
Message-ID: <CAKoKPbxQymhN93F5oM_TxK6y0kk5_bv3p62FncUz6Ri_0jmABw@mail.gmail.com>
To: Oleg Drokin <green@whamcloud.com>
Subject: Re: [lustre-devel] Lustre Arm stuff status and work plan
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
From: Xinliang Liu via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Xinliang Liu <xinliang.liu@linaro.org>
Cc: Jian Yu <jiyu@whamcloud.com>, Li Xi <lixi@ddn.com>,
 "cloud-dev-request@op-lists.linaro.org"
 <cloud-dev-request@op-lists.linaro.org>,
 Xinliang Liu via lustre-devel <lustre-devel@lists.lustre.org>
Content-Type: multipart/mixed; boundary="===============8119224779093855861=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8119224779093855861==
Content-Type: multipart/alternative; boundary="0000000000000fc13005d42b17cc"

--0000000000000fc13005d42b17cc
Content-Type: text/plain; charset="UTF-8"

On Mon, 27 Dec 2021 at 23:23, Oleg Drokin <green@whamcloud.com> wrote:

>
>
> > On Dec 27, 2021, at 2:56 AM, Xinliang Liu <xinliang.liu@linaro.org>
> wrote:
> >
> > And if we run some kind of tests externally in our end, we can see the
> test result (pass or not, running log link) displayed on the gerrit patch
> page as the community running tests.
> > We want to make our test results public to the Lustre community, so that
> developers can see the test results and adjust the patch if necessary. Thus
> avoiding breaking previous Arm work.
> > That can be made via reporting results into Maloo DB, right? Am I
> understanding correctly?
>
> In general people are more likely to see results when you post a comment
> to gerrit with said results.
>

Yeah, that's what we want.


> Maloo is just one place to link to to actually let people see the results,
> but you can link to external resources too
> like e.g. gatekeeper janitor helper does or assuming the information is
> small enough it could be entirely contained
> in the comment (like say for a build failure)
>

Ok, understand now. Is there any other reference external CI that posts
results to Lustre gerrit now?


>
> > We will look into the links and evaluate on setting up our own or
> self-hosted test infra and see if we can make it.
> > Such as,
> > 1. How many VMs resources for the test infra and test running;
> > 2. Other requirements for the self-hosted test infra;
> > 3. Work items to be done;
> > ..
>

--0000000000000fc13005d42b17cc
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote">=
<div dir=3D"ltr" class=3D"gmail_attr">On Mon, 27 Dec 2021 at 23:23, Oleg Dr=
okin &lt;<a href=3D"mailto:green@whamcloud.com">green@whamcloud.com</a>&gt;=
 wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px =
0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><br>
<br>
&gt; On Dec 27, 2021, at 2:56 AM, Xinliang Liu &lt;<a href=3D"mailto:xinlia=
ng.liu@linaro.org" target=3D"_blank">xinliang.liu@linaro.org</a>&gt; wrote:=
<br>
&gt; <br>
&gt; And if we run some kind of tests externally in our end, we can see the=
 test result (pass or not, running log link) displayed on the gerrit patch =
page as the community running tests. <br>
&gt; We want to make our test results public to the Lustre community, so th=
at developers can see the test results and adjust the patch if necessary. T=
hus avoiding breaking previous Arm work.<br>
&gt; That can be made via reporting results into Maloo DB, right? Am I unde=
rstanding correctly?<br>
<br>
In general people are more likely to see results when you post a comment to=
 gerrit with said results.<br></blockquote><div><br></div><div>Yeah, that&#=
39;s what we want.</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" =
style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);pa=
dding-left:1ex">
Maloo is just one place to link to to actually let people see the results, =
but you can link to external resources too<br>
like e.g. gatekeeper janitor helper does or assuming the information is sma=
ll enough it could be entirely contained<br>
in the comment (like say for a build failure)<br></blockquote><div><br></di=
v><div>Ok, understand now. Is there any other reference external CI that po=
sts results to Lustre gerrit now?</div><div>=C2=A0</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rg=
b(204,204,204);padding-left:1ex">
<br>
&gt; We will look into the links and evaluate on setting up our own or self=
-hosted test infra and see if we can make it.<br>
&gt; Such as,<br>
&gt; 1. How many VMs resources for the test infra and test running;<br>
&gt; 2. Other requirements for the self-hosted test infra; <br>
&gt; 3. Work items to be done;<br>
&gt; ..<br>
</blockquote></div></div>

--0000000000000fc13005d42b17cc--

--===============8119224779093855861==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8119224779093855861==--
