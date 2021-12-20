Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0FDA8C433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 20 Dec 2021 02:31:35 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B738421C968;
	Sun, 19 Dec 2021 18:31:34 -0800 (PST)
Received: from mail-yb1-f169.google.com (mail-yb1-f169.google.com
 [209.85.219.169])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 92D7D21C905
 for <lustre-devel@lists.lustre.org>; Sun, 19 Dec 2021 18:31:32 -0800 (PST)
Received: by mail-yb1-f169.google.com with SMTP id j2so24281647ybg.9
 for <lustre-devel@lists.lustre.org>; Sun, 19 Dec 2021 18:31:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=YKUavU646tV5kCMpDUnmFrjfimJs1Y3ZkK/2dhw9A2A=;
 b=xytZmP+305NacqoLwdVml5Mej8pCRUaw0H3yX6iX5A0Gt7bsBfx3/pjZp0j69pe3wy
 TMl0Qxza9mdZBx3/so9Al7M3zNz9MT6sH0w1tsccbxwP7qVAajPnOXufjvlVH1qxXHdk
 XJu5tg8ag4YWFs659Gphj0N6ZjG4fz2yeenTjzrH2cYMEGgXWDsQJ8BemK/P72sBtwWd
 xc8w/u1ct6IrVkMEf+4PnGkcRu8h17ixx4Vg82jXemh/mzVSnepkHdOQkpB27Ekpi/5V
 X84l7MNnCjAVXFIeT0zV/yt2p7jQGAZ/Qg00io14/AxXh0R+At6N42QDqsUurIfkidjr
 5rzQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=YKUavU646tV5kCMpDUnmFrjfimJs1Y3ZkK/2dhw9A2A=;
 b=3bafq7JTJeV+W40HMOmSDJC7fe4BKGzVdYtqb4lKWwy8qKMZtD2lt3TENa1UbpkQiX
 5xUrctj16yFXX18woHyHwv7dJoUm5OaPFxQ9pmypIUyCQoXhOIPNViHrSibM9LibylhU
 YswP5sFGM753Eh/gb09t6CwmgnRuX4B4WuS0woz6MPlxz91ZyH6yqdS0+uj6oshslw+h
 hkOD+OT08VI5vmpJsxWbK+yx5augbrMHYJ6okNi6wh4wWvd1veSrOADL7dNLRUH5rexu
 QgQ8lcqsuVRDD7lk3CTPU05G41x6Mhp8tEh5alryVniX3FUev3SKrJUOAdRm6sqEfDdQ
 BDGQ==
X-Gm-Message-State: AOAM532j7AC5XmTQkrHOqluagx0D0D3szkNYiD9+jKVqIGp+Q9ZPP1mG
 iy9FqqisGi7Wm25ZPgQoDVcXCJfnPZyQUMDcB5HihA==
X-Google-Smtp-Source: ABdhPJwBZcUkyJXZ58Mdm0C6Siyz4S29WJk6cM91IwRaUIoATyrxTalys1oLiG9VVIWUNeQHVFyX7OWldYdo+FMg5As=
X-Received: by 2002:a25:6402:: with SMTP id y2mr20656200ybb.673.1639967491825; 
 Sun, 19 Dec 2021 18:31:31 -0800 (PST)
MIME-Version: 1.0
References: <CAKoKPby+hn5+py-f11c31Po241871un0v=SQM+Cc6_hzvxW8uA@mail.gmail.com>
In-Reply-To: <CAKoKPby+hn5+py-f11c31Po241871un0v=SQM+Cc6_hzvxW8uA@mail.gmail.com>
Date: Mon, 20 Dec 2021 10:30:56 +0800
Message-ID: <CAKoKPbxTcSxGzASKyVhiv_7W3OY6x3DRtkcTu8hzvLM+4-PzZw@mail.gmail.com>
To: Peter Jones <pjones@whamcloud.com>
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
Cc: Jian Yu <jiyu@whamcloud.com>, lixi@ddn.com,
 cloud-dev-request@op-lists.linaro.org, lustre-devel@lists.lustre.org
Content-Type: multipart/mixed; boundary="===============7704285089190299862=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7704285089190299862==
Content-Type: multipart/alternative; boundary="000000000000cb36d705d38aaf37"

--000000000000cb36d705d38aaf37
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

(Maybe converting to plain text email will be more readable.)

Hi Peter and all,
As Kevin(on cc) and I have been working on Lustre Arm stuff for some time.
We want to give a status and progress report to the community and list our
work plan for the next year.
Please help to review our work plan and give some comments and suggestions.
Thanks.


Status and Progress
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Release
-------
- No Arm packages built on official community release yet.

Build
------
- Verified Lustre, openZFS build and multi-nodes setup on Arm64 CentOS 8,
all are ok.
- Lbuild script support for Arm is on review, LU-15293.

CI
---
- No Arm server end CI support yet.
- Arm client with x86_64 server test is already in the CI gate.
  - Only run a few ldiskfs test suites(sanity, sanity-sec, sanctity-lnet,
etc.), not a full test.
  - A full test (with empty GRANT_CHECK_LIST) shows several Arm client
related failed test cases, see test results page:
https://testing.whamcloud.com/test_sessions?jobs=3Dlustre-reviews&builds=3D=
82774&start_date=3D2021-08-26#redirect
    - sanity test 317: LU-11667 (Workaround fix landed)
    - sanityn test 16a: LU-11597, test 71a: LU-11787
    - conf-sanity test 98: LU-11785, test 112: LU-13813
    - sanity-flr test 50a: LU-14970
    - sanity-pcc test 7a: LU-14346

Arm server end test on local setup
---------------------------------------------
- Run a full ldiskfs test with all test suites.
  - Due to the multi MDTs crash issue, some multi MDTs tests are not run.
  - Many new failed tests come, see the test result google sheet for
details:
https://docs.google.com/spreadsheets/d/1EE5zU96_lqlkS0uk6NJeeNBrikYpd_ZEO7h=
dVt5spsw/edit#gid=3D969410610
  - The openZFS full test is not run, but heard that it should be more
stable than ldiskfs.

Bugfix
-------
- Old Arm always_except bugs https://jira.whamcloud.com/issues/?filter=3D15=
555
, the Arm related ones are almost addressed.
  - LU-11596, LU-11597, LU-14067, LU-11787: addressed, patch sent and
waiting for Arm client CI recovery to land.
  - LU-10073, LU-11671: can't be reproduced on Arm or happen on x86_64 also=
.

- Other old Arm bugs  LU-11785, LU-13813, LU-14970, LU-14346 to be fixed.

- New created server end bugs
  - LU-15122 : ASSERTION( iobuf->dr_rw =3D=3D 0 ) crash issue, fixed patch =
is
landed.
  - LU-15364: multi MDTs kernel oops issue, related to atomic unaligned
memory access, work in progress.
  - LU-15223: 64K page size read/write improvement, long-term work, in
progress.

- Full Arm related bug list with label arm:
https://jira.whamcloud.com/issues/?filter=3D16710

Reference to:
James Simmons=E2=80=99 Lustre Arm update:
https://connect.linaro.org/resources/san19/san19-224/


Work Plan
=3D=3D=3D=3D=3D=3D=3D=3D
- Lustre Server End Critical Bug Fix target 2022-06
  - Lustre Multiple MDTs kernel OOPS when stripe issue: LU-15364
  - Lustre hangs at Sanity Test 807
  - Lustre Conf-sanity test 44 kernel crash
  - Lustre Conf sanity case 58 kernel crash
  - Lustre Conf sanity case 78 kernel crash
  - Lustre Conf sanity case 79 crash
  - Lustre sanity-pcc 7a case hang the cluster

- Lustre Server End Non-critical Bug Fix target 2022-12
  - Lustre Sanity failure cases: 33 cases
  - Lustre server replay-single: 1 case
  - Lustre sanity-flr 200 cases fix: 1 case
  - Lustre sanity-hsm failure cases: 25 cases
  - Lustre lustre-rsync-test failure test: 3 cases
  - Lustre recovery-small/sanity-scrub: 2 cases
  - Lustre sanityn test cases fix: 12 cases
  - Lustre sanity-lfsck failure cases fix: 3 cases
  - Lustre sanity-sec failure cases fix =EF=BC=9A7 cases
  - Lustre sanity-lnet failure cases test fix: 2 cases

- Continuous add more test suites for Arm client CI ??
  - Once a test suite is all passed for Arm then add it into CI.

- Server CI support for Arm on Centos8 ??
  - Ideally, Arm server CI can come with Arm server end fixes patches and
ensure future patches merged don=E2=80=99t make any regressions on Arm.
  - As the test infra is not open source and maintained by whamcloud, it
might need whamcloud to make it ??

- Other works in future
  - Full test with openZFS backend.
  - Test x86 client with Arm64 Server
  - Test other distros like ubuntu, SUSE etc.
  - Basic Optimised: CRC/AES
  - All-flash optimization


Best Regards,
Xinliang

--000000000000cb36d705d38aaf37
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">(Maybe converting to plain text email will be more readabl=
e.)<br><br>Hi Peter and all,<br>As Kevin(on cc) and I have been working on =
Lustre Arm stuff for some time.<br>We want to give a status and progress re=
port to the community and list our work plan for the next year.<br>Please h=
elp to review our work plan and give some comments and suggestions. Thanks.=
<br><br><br>Status and Progress<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D<br>Release<br>-------<br>- No Arm packages built on official comm=
unity release yet.<br><br>Build<br>------<br>- Verified Lustre, openZFS bui=
ld and multi-nodes setup on Arm64 CentOS 8, all are ok.<br>- Lbuild script =
support for Arm is on review, LU-15293.<br><br>CI<br>---<br>- No Arm server=
 end CI support yet.<br>- Arm client with x86_64 server test is already in =
the CI gate.<br>=C2=A0 - Only run a few ldiskfs test suites(sanity, sanity-=
sec, sanctity-lnet, etc.), not a full test.<br>=C2=A0 - A full test (with e=
mpty GRANT_CHECK_LIST) shows several Arm client related failed test cases, =
see test results page: <a href=3D"https://testing.whamcloud.com/test_sessio=
ns?jobs=3Dlustre-reviews&amp;builds=3D82774&amp;start_date=3D2021-08-26#red=
irect">https://testing.whamcloud.com/test_sessions?jobs=3Dlustre-reviews&am=
p;builds=3D82774&amp;start_date=3D2021-08-26#redirect</a><br>=C2=A0 =C2=A0 =
- sanity test 317: LU-11667 (Workaround fix landed)<br>=C2=A0 =C2=A0 - sani=
tyn test 16a: LU-11597, test 71a: LU-11787<br>=C2=A0 =C2=A0 - conf-sanity t=
est 98: LU-11785, test 112: LU-13813<br>=C2=A0 =C2=A0 - sanity-flr test 50a=
: LU-14970<br>=C2=A0 =C2=A0 - sanity-pcc test 7a: LU-14346<br><br>Arm serve=
r end test on local setup<br>---------------------------------------------<=
br>- Run a full ldiskfs test with all test suites.<br>=C2=A0 - Due to the m=
ulti MDTs crash issue, some multi MDTs tests are not run.<br>=C2=A0 - Many =
new failed tests come, see the test result google sheet for details: <a hre=
f=3D"https://docs.google.com/spreadsheets/d/1EE5zU96_lqlkS0uk6NJeeNBrikYpd_=
ZEO7hdVt5spsw/edit#gid=3D969410610">https://docs.google.com/spreadsheets/d/=
1EE5zU96_lqlkS0uk6NJeeNBrikYpd_ZEO7hdVt5spsw/edit#gid=3D969410610</a><br>=
=C2=A0 - The openZFS full test is not run, but heard that it should be more=
 stable than ldiskfs.<br><br>Bugfix<br>-------<br>- Old Arm always_except b=
ugs <a href=3D"https://jira.whamcloud.com/issues/?filter=3D15555">https://j=
ira.whamcloud.com/issues/?filter=3D15555</a> , the Arm related ones are alm=
ost addressed.<br>=C2=A0 - LU-11596, LU-11597, LU-14067, LU-11787: addresse=
d, patch sent and waiting for Arm client CI recovery to land.<br>=C2=A0 - L=
U-10073, LU-11671: can&#39;t be reproduced on Arm or happen on x86_64 also.=
<br><br>- Other old Arm bugs =C2=A0LU-11785, LU-13813, LU-14970, LU-14346 t=
o be fixed.<br><br>- New created server end bugs<br>=C2=A0 - LU-15122 : ASS=
ERTION( iobuf-&gt;dr_rw =3D=3D 0 ) crash issue, fixed patch is landed.<br>=
=C2=A0 - LU-15364: multi MDTs kernel oops issue, related to atomic unaligne=
d memory access, work in progress.<br>=C2=A0 - LU-15223: 64K page size read=
/write improvement, long-term work, in progress.<br><br>- Full Arm related =
bug list with label arm: <a href=3D"https://jira.whamcloud.com/issues/?filt=
er=3D16710">https://jira.whamcloud.com/issues/?filter=3D16710</a><br><br>Re=
ference to:<br>James Simmons=E2=80=99 Lustre Arm update: <a href=3D"https:/=
/connect.linaro.org/resources/san19/san19-224/">https://connect.linaro.org/=
resources/san19/san19-224/</a><br><br><br>Work Plan<br>=3D=3D=3D=3D=3D=3D=
=3D=3D<br>- Lustre Server End Critical Bug Fix target 2022-06<br>=C2=A0 - L=
ustre Multiple MDTs kernel OOPS when stripe issue: LU-15364<br>=C2=A0 - Lus=
tre hangs at Sanity Test 807<br>=C2=A0 - Lustre Conf-sanity test 44 kernel =
crash<br>=C2=A0 - Lustre Conf sanity case 58 kernel crash<br>=C2=A0 - Lustr=
e Conf sanity case 78 kernel crash<br>=C2=A0 - Lustre Conf sanity case 79 c=
rash<br>=C2=A0 - Lustre sanity-pcc 7a case hang the cluster<br><br>- Lustre=
 Server End Non-critical Bug Fix target 2022-12<br>=C2=A0 - Lustre Sanity f=
ailure cases: 33 cases<br>=C2=A0 - Lustre server replay-single: 1 case<br>=
=C2=A0 - Lustre sanity-flr 200 cases fix: 1 case<br>=C2=A0 - Lustre sanity-=
hsm failure cases: 25 cases<br>=C2=A0 - Lustre lustre-rsync-test failure te=
st: 3 cases<br>=C2=A0 - Lustre recovery-small/sanity-scrub: 2 cases<br>=C2=
=A0 - Lustre sanityn test cases fix: 12 cases<br>=C2=A0 - Lustre sanity-lfs=
ck failure cases fix: 3 cases<br>=C2=A0 - Lustre sanity-sec failure cases f=
ix =EF=BC=9A7 cases<br>=C2=A0 - Lustre sanity-lnet failure cases test fix: =
2 cases<br><br>- Continuous add more test suites for Arm client CI ??<br>=
=C2=A0 - Once a test suite is all passed for Arm then add it into CI.<br><b=
r>- Server CI support for Arm on Centos8 ??<br>=C2=A0 - Ideally, Arm server=
 CI can come with Arm server end fixes patches and ensure future patches me=
rged don=E2=80=99t make any regressions on Arm.<br>=C2=A0 - As the test inf=
ra is not open source and maintained by whamcloud, it might need whamcloud =
to make it ??<br><br>- Other works in future<br>=C2=A0 - Full test with ope=
nZFS backend.<br>=C2=A0 - Test x86 client with Arm64 Server<br>=C2=A0 - Tes=
t other distros like ubuntu, SUSE etc.<br>=C2=A0 - Basic Optimised: CRC/AES=
<br>=C2=A0 - All-flash optimization<br><br><br>Best Regards,<br>Xinliang<br=
></div>

--000000000000cb36d705d38aaf37--

--===============7704285089190299862==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7704285089190299862==--
