Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0E7F7C433FE
	for <lustre-devel@archiver.kernel.org>; Mon, 27 Dec 2021 07:56:36 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 453CA3A60FC;
	Sun, 26 Dec 2021 23:56:36 -0800 (PST)
Received: from mail-yb1-f169.google.com (mail-yb1-f169.google.com
 [209.85.219.169])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CE4CB3A5BAF
 for <lustre-devel@lists.lustre.org>; Sun, 26 Dec 2021 23:56:34 -0800 (PST)
Received: by mail-yb1-f169.google.com with SMTP id 139so11041985ybd.3
 for <lustre-devel@lists.lustre.org>; Sun, 26 Dec 2021 23:56:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=cojn+yTW76E9uXF5rpUl45CbXzQ81MVXzsTUy88d3xs=;
 b=BOGcln3P0dewANmaEvHLUPt6ei5FMqktpTEfwhfZc2/8IzjnQL3egnVVyZyi6z8kyY
 SQdjvA3ORSzJQmfsfBHueksxTdyrNIV5nqGhgJ8TojiAIJFHNAdyVW4SNSMzeTGvuh6g
 EQqEboToJfR+JQ1L4fo+KM2CoMEIbWVdsHllUGbuDci2LWVaBg7mEpSnL3g9OoHDIItb
 xZJYM6LlK80+vnuyHQSPyHHCxhwFTjA4+4gIPpowdBKIGufqpk5jauSI0zc/I7KZzuIU
 +FABoJ5zaoLLq+bBv7oP/cUwlvYz9AKKgpA4vR2KxWLf4eJAUwPSGXACZ+ODgFYHkbo9
 zmDg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=cojn+yTW76E9uXF5rpUl45CbXzQ81MVXzsTUy88d3xs=;
 b=Do+ZgTJmEbqgSUawr7OvvcP1kRSIeAal1OgN5OoxvSpusOtawyizOsFlGrnDMA8t05
 1K+82R1i23CDVREFAOz/cU6TRxdOoDaI10OKajZrd1aVI/P6Qi4GZFO0Yp3CtLqJ6A20
 0Dg6lvr+3y4SODtm5c62mMsFl9BYijK0jtanCqP17hHX56rk+WuxHdI4llLV+gUapUP7
 1a9YgLAZNjxwkSK5hz5OMMNOWoIKuvHnYXbx5eRNup/uiRkCsJjFjjwF0g59+/6eesz5
 G8JWsrtEXfbOTqkR3ZsRohFwpsVaREv51jq+oQCUY38XNX7osgxbYZfp9DX3rWB4X5/k
 f4/A==
X-Gm-Message-State: AOAM5331f1xzCFhA/Xt7nr8TuHqRn7ywAHwssAFYUeoWvOI3oDDnEvwD
 4MolhAxPG3die/2YjmrUqJI43JH91XDGuXCQmFWy9g==
X-Google-Smtp-Source: ABdhPJxAzk1tl/jhntdHSRZpxpqK2YnZ8ih6+I7Ch0Jwk3uWYYA+aUzpwGO/M7snFaYVyBDdBQXG+NhM8rlj/VPdScM=
X-Received: by 2002:a25:7dc4:: with SMTP id
 y187mr20664173ybc.165.1640591793946; 
 Sun, 26 Dec 2021 23:56:33 -0800 (PST)
MIME-Version: 1.0
References: <CAKoKPby+hn5+py-f11c31Po241871un0v=SQM+Cc6_hzvxW8uA@mail.gmail.com>
 <CAKoKPbxTcSxGzASKyVhiv_7W3OY6x3DRtkcTu8hzvLM+4-PzZw@mail.gmail.com>
 <6C592E3F-0437-4776-BB29-C5EE489C5FAE@whamcloud.com>
In-Reply-To: <6C592E3F-0437-4776-BB29-C5EE489C5FAE@whamcloud.com>
Date: Mon, 27 Dec 2021 15:56:00 +0800
Message-ID: <CAKoKPbxmvn7GVc6wsYrLP_HD8SpNMVFfSFdiZMo-5ZXqS-HSdg@mail.gmail.com>
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
Content-Type: multipart/mixed; boundary="===============8302157574299114152=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8302157574299114152==
Content-Type: multipart/alternative; boundary="000000000000199bce05d41c0b39"

--000000000000199bce05d41c0b39
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello Oleg,
Thank you for your suggestions about Arm CI.

On Thu, 23 Dec 2021 at 15:43, Oleg Drokin <green@whamcloud.com> wrote:

> Hello!
>
>  Thank you for your work on this.
>
> the test infra is not open source, but it is open - it=E2=80=99s just ger=
rit, so
> you can plug your own CI nodes
> to report test results for configurations that you think are well working
> (to ensure they don=E2=80=99t break).
>  This applies to everybody having ideas about gaps in test coverage for
> patches in review (which is
>   the most important part of the pipeline IMO - stuff that was not caught
> on this step and got committed is much
>   harder to fix - it then needs a triage for failures, a ticket and
> somebody assigned to do it and another patch)
>
>  It=E2=80=99ll need some work on your end to create the setup that meets =
the level
> of testing you feel is adequate,
>  e.g. you could do something simple using this builder
> https://wiki.lustre.org/index.php?title=3DSimple_Gerrit_Builder_Howto
>
>  or you could do something really advanced like what I have with the
> janitortester that is also on github
> https://github.com/verygreen/lustretester
>
>   or I guess you can use some off the shelf CI solution that integrtes
> with gerrit.
>
>   You can also report results into Maloo DB if you don=E2=80=99t want to =
host your
> own logs infra, there=E2=80=99s API for that, though I see it=E2=80=99s n=
ot exactly public
>    but that=E2=80=99s probably just an omission and it should be made pub=
lic
> https://wiki.whamcloud.com/display/TEI/Test+results+format
>    Let me know if that=E2=80=99s something you are interested in and I wi=
ll try to
> provide you with this data.
>

Yeah, that sounds interesting. Please provide me with this data, the link
responses 404 now., thanks.

Ideally, we want enough Arm CI tests as x86_64. And these tests are running
and maintained in the Lustre official test infra like review-ldiskfs-arm we
have now.
But if it is impossible now, we will consider setting up such CI on our own=
.

And if we run some kind of tests externally in our end, we can see the test
result (pass or not, running log link) displayed on the gerrit patch page
as the community running tests.
We want to make our test results public to the Lustre community, so that
developers can see the test results and adjust the patch if necessary. Thus
avoiding breaking previous Arm work.
That can be made via reporting results into Maloo DB, right? Am I
understanding correctly?

We will look into the links and evaluate on setting up our own or
self-hosted test infra and see if we can make it.
Such as,
1. How many VMs resources for the test infra and test running;
2. Other requirements for the self-hosted test infra;
3. Work items to be done;
..

Thanks,
Xinliang



>
> On Dec 19, 2021, at 9:30 PM, Xinliang Liu <xinliang.liu@linaro.org> wrote=
:
>
> (Maybe converting to plain text email will be more readable.)
>
> Hi Peter and all,
> As Kevin(on cc) and I have been working on Lustre Arm stuff for some time=
.
> We want to give a status and progress report to the community and list ou=
r
> work plan for the next year.
> Please help to review our work plan and give some comments and
> suggestions. Thanks.
>
>
> Status and Progress
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Release
> -------
> - No Arm packages built on official community release yet.
>
> Build
> ------
> - Verified Lustre, openZFS build and multi-nodes setup on Arm64 CentOS 8,
> all are ok.
> - Lbuild script support for Arm is on review, LU-15293.
>
> CI
> ---
> - No Arm server end CI support yet.
> - Arm client with x86_64 server test is already in the CI gate.
>   - Only run a few ldiskfs test suites(sanity, sanity-sec, sanctity-lnet,
> etc.), not a full test.
>   - A full test (with empty GRANT_CHECK_LIST) shows several Arm client
> related failed test cases, see test results page:
> https://testing.whamcloud.com/test_sessions?jobs=3Dlustre-reviews&builds=
=3D82774&start_date=3D2021-08-26#redirect
>     - sanity test 317: LU-11667 (Workaround fix landed)
>     - sanityn test 16a: LU-11597, test 71a: LU-11787
>     - conf-sanity test 98: LU-11785, test 112: LU-13813
>     - sanity-flr test 50a: LU-14970
>     - sanity-pcc test 7a: LU-14346
>
> Arm server end test on local setup
> ---------------------------------------------
> - Run a full ldiskfs test with all test suites.
>   - Due to the multi MDTs crash issue, some multi MDTs tests are not run.
>   - Many new failed tests come, see the test result google sheet for
> details:
> https://docs.google.com/spreadsheets/d/1EE5zU96_lqlkS0uk6NJeeNBrikYpd_ZEO=
7hdVt5spsw/edit#gid=3D969410610
>   - The openZFS full test is not run, but heard that it should be more
> stable than ldiskfs.
>
> Bugfix
> -------
> - Old Arm always_except bugs
> https://jira.whamcloud.com/issues/?filter=3D15555 , the Arm related ones
> are almost addressed.
>   - LU-11596, LU-11597, LU-14067, LU-11787: addressed, patch sent and
> waiting for Arm client CI recovery to land.
>   - LU-10073, LU-11671: can't be reproduced on Arm or happen on x86_64
> also.
>
> - Other old Arm bugs  LU-11785, LU-13813, LU-14970, LU-14346 to be fixed.
>
> - New created server end bugs
>   - LU-15122 : ASSERTION( iobuf->dr_rw =3D=3D 0 ) crash issue, fixed patc=
h is
> landed.
>   - LU-15364: multi MDTs kernel oops issue, related to atomic unaligned
> memory access, work in progress.
>   - LU-15223: 64K page size read/write improvement, long-term work, in
> progress.
>
> - Full Arm related bug list with label arm:
> https://jira.whamcloud.com/issues/?filter=3D16710
>
> Reference to:
> James Simmons=E2=80=99 Lustre Arm update:
> https://connect.linaro.org/resources/san19/san19-224/
>
>
> Work Plan
> =3D=3D=3D=3D=3D=3D=3D=3D
> - Lustre Server End Critical Bug Fix target 2022-06
>   - Lustre Multiple MDTs kernel OOPS when stripe issue: LU-15364
>   - Lustre hangs at Sanity Test 807
>   - Lustre Conf-sanity test 44 kernel crash
>   - Lustre Conf sanity case 58 kernel crash
>   - Lustre Conf sanity case 78 kernel crash
>   - Lustre Conf sanity case 79 crash
>   - Lustre sanity-pcc 7a case hang the cluster
>
> - Lustre Server End Non-critical Bug Fix target 2022-12
>   - Lustre Sanity failure cases: 33 cases
>   - Lustre server replay-single: 1 case
>   - Lustre sanity-flr 200 cases fix: 1 case
>   - Lustre sanity-hsm failure cases: 25 cases
>   - Lustre lustre-rsync-test failure test: 3 cases
>   - Lustre recovery-small/sanity-scrub: 2 cases
>   - Lustre sanityn test cases fix: 12 cases
>   - Lustre sanity-lfsck failure cases fix: 3 cases
>   - Lustre sanity-sec failure cases fix =EF=BC=9A7 cases
>   - Lustre sanity-lnet failure cases test fix: 2 cases
>
> - Continuous add more test suites for Arm client CI ??
>   - Once a test suite is all passed for Arm then add it into CI.
>
> - Server CI support for Arm on Centos8 ??
>   - Ideally, Arm server CI can come with Arm server end fixes patches and
> ensure future patches merged don=E2=80=99t make any regressions on Arm.
>   - As the test infra is not open source and maintained by whamcloud, it
> might need whamcloud to make it ??
>
> - Other works in future
>   - Full test with openZFS backend.
>   - Test x86 client with Arm64 Server
>   - Test other distros like ubuntu, SUSE etc.
>   - Basic Optimised: CRC/AES
>   - All-flash optimization
>
>
> Best Regards,
> Xinliang
>
>
>

--000000000000199bce05d41c0b39
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr">Hello Oleg,<div>Thank you=C2=A0for your s=
uggestions about=C2=A0Arm CI.</div></div><br><div class=3D"gmail_quote"><di=
v dir=3D"ltr" class=3D"gmail_attr">On Thu, 23 Dec 2021 at 15:43, Oleg Droki=
n &lt;<a href=3D"mailto:green@whamcloud.com" target=3D"_blank">green@whamcl=
oud.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"=
margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);padding-lef=
t:1ex">



<div>
Hello!
<div><br>
</div>
<div>=C2=A0Thank you for your work on this.</div>
<div><br>
</div>
<div>the test infra is not open source, but it is open - it=E2=80=99s just =
gerrit, so you can plug your own CI nodes</div>
<div>to report test results for configurations that you think are well work=
ing (to ensure they don=E2=80=99t break).</div>
<div>=C2=A0This applies to everybody having ideas about gaps in test covera=
ge for patches in review (which is</div>
<div>=C2=A0 the most important part of the pipeline IMO - stuff that was no=
t caught on this step and got committed is much</div>
<div>=C2=A0 harder to fix - it then needs a triage for failures, a ticket a=
nd somebody assigned to do it and another patch)=C2=A0</div>
<div><br>
</div>
<div>=C2=A0It=E2=80=99ll need some work on your end to create the setup tha=
t meets the level of testing you feel is adequate,</div>
<div>=C2=A0e.g. you could do something simple using this builder=C2=A0<a hr=
ef=3D"https://wiki.lustre.org/index.php?title=3DSimple_Gerrit_Builder_Howto=
" target=3D"_blank">https://wiki.lustre.org/index.php?title=3DSimple_Gerrit=
_Builder_Howto</a></div>
<div><br>
</div>
<div>=C2=A0or you could do something really advanced like what I have with =
the janitortester that is also on github=C2=A0<a href=3D"https://github.com=
/verygreen/lustretester" target=3D"_blank">https://github.com/verygreen/lus=
tretester</a></div>
<div><br>
</div>
<div>=C2=A0 or I guess you can use some off the shelf CI solution that inte=
grtes with gerrit.</div>
<div><br>
</div>
<div>=C2=A0 You can also report results into Maloo DB if you don=E2=80=99t =
want to host your own logs infra, there=E2=80=99s API for that, though I se=
e it=E2=80=99s not exactly public</div>
<div>=C2=A0 =C2=A0but that=E2=80=99s probably just an omission and it shoul=
d be made public=C2=A0<a href=3D"https://wiki.whamcloud.com/display/TEI/Tes=
t+results+format" target=3D"_blank">https://wiki.whamcloud.com/display/TEI/=
Test+results+format</a></div>
<div>=C2=A0 =C2=A0Let me know if that=E2=80=99s something you are intereste=
d in and I will try to provide you with this data.</div></div></blockquote>=
<div><br></div><div>Yeah, that sounds interesting. Please=C2=A0provide me w=
ith this data, the link responses 404 now., thanks.</div><div><br></div><di=
v>Ideally, we want enough Arm CI tests as x86_64. And these tests are runni=
ng and maintained in the Lustre official=C2=A0test infra like <span style=
=3D"color:rgb(53,53,53);font-family:sans-serif;white-space:pre-wrap">review=
-ldiskfs-arm we have now</span>.</div><div>But if it is impossible now, we =
will consider setting up such CI=C2=A0on our own.</div><div><br></div><div>=
And if we run some kind of tests externally in our end, we can see the test=
 result (pass or not, running log link) displayed on the gerrit=C2=A0patch =
page as the community running tests.=C2=A0</div><div>We want to=C2=A0make o=
ur test results public to the Lustre community,=C2=A0so that developers can=
 see the=C2=A0test results and adjust the patch if necessary. Thus avoiding=
 breaking previous Arm work.</div><div>That can be made via reporting resul=
ts into Maloo DB, right? Am I understanding correctly?</div><div><br></div>=
<div>We will look into the links and evaluate on setting up our own or self=
-hosted test infra and see if we can make it.</div><div>Such as,</div><div>=
1. How many VMs resources for the test infra and test running;</div><div>2.=
 Other requirements for the self-hosted test infra;=C2=A0</div><div>3. Work=
 items to be done;</div><div>..</div><div><br></div><div>Thanks,</div><div>=
Xinliang</div><div><br></div><div><br></div><blockquote class=3D"gmail_quot=
e" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204)=
;padding-left:1ex"><div>
<div><br>
</div>
<div>
<div><br>
<blockquote type=3D"cite">
<div>On Dec 19, 2021, at 9:30 PM, Xinliang Liu &lt;<a href=3D"mailto:xinlia=
ng.liu@linaro.org" target=3D"_blank">xinliang.liu@linaro.org</a>&gt; wrote:=
</div>
<br>
<div>
<div dir=3D"ltr">(Maybe converting to plain text email will be more readabl=
e.)<br>
<br>
Hi Peter and all,<br>
As Kevin(on cc) and I have been working on Lustre Arm stuff for some time.<=
br>
We want to give a status and progress report to the community and list our =
work plan for the next year.<br>
Please help to review our work plan and give some comments and suggestions.=
 Thanks.<br>
<br>
<br>
Status and Progress<br>
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>
Release<br>
-------<br>
- No Arm packages built on official community release yet.<br>
<br>
Build<br>
------<br>
- Verified Lustre, openZFS build and multi-nodes setup on Arm64 CentOS 8, a=
ll are ok.<br>
- Lbuild script support for Arm is on review, LU-15293.<br>
<br>
CI<br>
---<br>
- No Arm server end CI support yet.<br>
- Arm client with x86_64 server test is already in the CI gate.<br>
=C2=A0 - Only run a few ldiskfs test suites(sanity, sanity-sec, sanctity-ln=
et, etc.), not a full test.<br>
=C2=A0 - A full test (with empty GRANT_CHECK_LIST) shows several Arm client=
 related failed test cases, see test results page:
<a href=3D"https://testing.whamcloud.com/test_sessions?jobs=3Dlustre-review=
s&amp;builds=3D82774&amp;start_date=3D2021-08-26#redirect" target=3D"_blank=
">
https://testing.whamcloud.com/test_sessions?jobs=3Dlustre-reviews&amp;build=
s=3D82774&amp;start_date=3D2021-08-26#redirect</a><br>
=C2=A0 =C2=A0 - sanity test 317: LU-11667 (Workaround fix landed)<br>
=C2=A0 =C2=A0 - sanityn test 16a: LU-11597, test 71a: LU-11787<br>
=C2=A0 =C2=A0 - conf-sanity test 98: LU-11785, test 112: LU-13813<br>
=C2=A0 =C2=A0 - sanity-flr test 50a: LU-14970<br>
=C2=A0 =C2=A0 - sanity-pcc test 7a: LU-14346<br>
<br>
Arm server end test on local setup<br>
---------------------------------------------<br>
- Run a full ldiskfs test with all test suites.<br>
=C2=A0 - Due to the multi MDTs crash issue, some multi MDTs tests are not r=
un.<br>
=C2=A0 - Many new failed tests come, see the test result google sheet for d=
etails: <a href=3D"https://docs.google.com/spreadsheets/d/1EE5zU96_lqlkS0uk=
6NJeeNBrikYpd_ZEO7hdVt5spsw/edit#gid=3D969410610" target=3D"_blank">
https://docs.google.com/spreadsheets/d/1EE5zU96_lqlkS0uk6NJeeNBrikYpd_ZEO7h=
dVt5spsw/edit#gid=3D969410610</a><br>
=C2=A0 - The openZFS full test is not run, but heard that it should be more=
 stable than ldiskfs.<br>
<br>
Bugfix<br>
-------<br>
- Old Arm always_except bugs <a href=3D"https://jira.whamcloud.com/issues/?=
filter=3D15555" target=3D"_blank">
https://jira.whamcloud.com/issues/?filter=3D15555</a> , the Arm related one=
s are almost addressed.<br>
=C2=A0 - LU-11596, LU-11597, LU-14067, LU-11787: addressed, patch sent and =
waiting for Arm client CI recovery to land.<br>
=C2=A0 - LU-10073, LU-11671: can&#39;t be reproduced on Arm or happen on x8=
6_64 also.<br>
<br>
- Other old Arm bugs =C2=A0LU-11785, LU-13813, LU-14970, LU-14346 to be fix=
ed.<br>
<br>
- New created server end bugs<br>
=C2=A0 - LU-15122 : ASSERTION( iobuf-&gt;dr_rw =3D=3D 0 ) crash issue, fixe=
d patch is landed.<br>
=C2=A0 - LU-15364: multi MDTs kernel oops issue, related to atomic unaligne=
d memory access, work in progress.<br>
=C2=A0 - LU-15223: 64K page size read/write improvement, long-term work, in=
 progress.<br>
<br>
- Full Arm related bug list with label arm: <a href=3D"https://jira.whamclo=
ud.com/issues/?filter=3D16710" target=3D"_blank">
https://jira.whamcloud.com/issues/?filter=3D16710</a><br>
<br>
Reference to:<br>
James Simmons=E2=80=99 Lustre Arm update: <a href=3D"https://connect.linaro=
.org/resources/san19/san19-224/" target=3D"_blank">
https://connect.linaro.org/resources/san19/san19-224/</a><br>
<br>
<br>
Work Plan<br>
=3D=3D=3D=3D=3D=3D=3D=3D<br>
- Lustre Server End Critical Bug Fix target 2022-06<br>
=C2=A0 - Lustre Multiple MDTs kernel OOPS when stripe issue: LU-15364<br>
=C2=A0 - Lustre hangs at Sanity Test 807<br>
=C2=A0 - Lustre Conf-sanity test 44 kernel crash<br>
=C2=A0 - Lustre Conf sanity case 58 kernel crash<br>
=C2=A0 - Lustre Conf sanity case 78 kernel crash<br>
=C2=A0 - Lustre Conf sanity case 79 crash<br>
=C2=A0 - Lustre sanity-pcc 7a case hang the cluster<br>
<br>
- Lustre Server End Non-critical Bug Fix target 2022-12<br>
=C2=A0 - Lustre Sanity failure cases: 33 cases<br>
=C2=A0 - Lustre server replay-single: 1 case<br>
=C2=A0 - Lustre sanity-flr 200 cases fix: 1 case<br>
=C2=A0 - Lustre sanity-hsm failure cases: 25 cases<br>
=C2=A0 - Lustre lustre-rsync-test failure test: 3 cases<br>
=C2=A0 - Lustre recovery-small/sanity-scrub: 2 cases<br>
=C2=A0 - Lustre sanityn test cases fix: 12 cases<br>
=C2=A0 - Lustre sanity-lfsck failure cases fix: 3 cases<br>
=C2=A0 - Lustre sanity-sec failure cases fix =EF=BC=9A7 cases<br>
=C2=A0 - Lustre sanity-lnet failure cases test fix: 2 cases<br>
<br>
- Continuous add more test suites for Arm client CI ??<br>
=C2=A0 - Once a test suite is all passed for Arm then add it into CI.<br>
<br>
- Server CI support for Arm on Centos8 ??<br>
=C2=A0 - Ideally, Arm server CI can come with Arm server end fixes patches =
and ensure future patches merged don=E2=80=99t make any regressions on Arm.=
<br>
=C2=A0 - As the test infra is not open source and maintained by whamcloud, =
it might need whamcloud to make it ??<br>
<br>
- Other works in future<br>
=C2=A0 - Full test with openZFS backend.<br>
=C2=A0 - Test x86 client with Arm64 Server<br>
=C2=A0 - Test other distros like ubuntu, SUSE etc.<br>
=C2=A0 - Basic Optimised: CRC/AES<br>
=C2=A0 - All-flash optimization<br>
<br>
<br>
Best Regards,<br>
Xinliang<br>
</div>
</div>
</blockquote>
</div>
<br>
</div>
</div>

</blockquote></div></div>

--000000000000199bce05d41c0b39--

--===============8302157574299114152==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8302157574299114152==--
