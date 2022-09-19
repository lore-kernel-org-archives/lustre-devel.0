Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1A561ECAAD3
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Sep 2022 13:49:45 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MWQyx3FnGz1wQd;
	Mon, 19 Sep 2022 06:49:45 -0700 (PDT)
Received: from mail-yb1-f172.google.com (mail-yb1-f172.google.com
 [209.85.219.172])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MWQyv3gZwz1wLM
 for <lustre-devel@lists.lustre.org>; Mon, 19 Sep 2022 06:49:43 -0700 (PDT)
Received: by mail-yb1-f172.google.com with SMTP id y82so42572008yby.6
 for <lustre-devel@lists.lustre.org>; Mon, 19 Sep 2022 06:49:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linaro.org; s=google;
 h=cc:to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date; bh=5a/+u8XAPjpObXoC5H0UQSXJ47i8SCcQYczX0wZ9H2Q=;
 b=QckOWDPTxJXWgKLpK0fcs4/1QIHIH4Yzz5zYAl59s/D/xprKQK8mfJc1tvvx2T/XSo
 A0SrgQTsGuPIq99YtyiK/11s8lYLDz31wCTswagGUE33Rr8PDPwrq5o779Owte9mtSRZ
 3bOBD1tE0vujQHGl9gCcJ7zFz1gjLcoibt7IR2Rb+yXL5gy8PFDJZ6icjkLiswKuhJ6B
 iMZP0v0oP7nKTrGUng1xgrzKE6PZkXQZvQjkEf4FFt+d5FjJ6WKeb5SWOQST0vEI9H1X
 BsZ7Vhw/T5shhv9MyFshpm7SCO97Owrewvm3jMK+wWUve+gAKD+HLjMdN72LzbrKjFmL
 nx7Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112;
 h=cc:to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date;
 bh=5a/+u8XAPjpObXoC5H0UQSXJ47i8SCcQYczX0wZ9H2Q=;
 b=HSUmjV2YBxCcQ4dTf2QYMfG9cqsg8xIPJbb2V4lH+ZgwX3FwKf6Pq4PT9uC78SUEtM
 gLFxn0wUHS8qDNrETJgmqMGxaFW+87qOQ3ZxpTTlCmENVugouQo+2IL0KCgIrZNe88UQ
 c8CswKt/EAXnhBcOsKOfc4c6a4rLv8hyfxshVrJoj+kvhobD4KEFzJrm7UVkb+USpbX8
 3321gPEfdjQBtnmV6qtu07H+nibPDbPFy33eTWD6c2G0wiZUXyuvEsj7eHLCO1gxNM9p
 of06FGmb+Ks9oc4jA4w8nlFW6EFgoaBfl5eyDYn1tHgGJNJlowThr+lYZ0CIDL2s/4sP
 PiDA==
X-Gm-Message-State: ACrzQf39hW0R2iPAypdJwQsx3S6Hmoi3zFOPTAK7zHkg8V21s43+4FA8
 pNcfIKXxOialwNHWnzmRelGRwA7M7w7SUkjxp0GTypXWq56s
X-Google-Smtp-Source: AMsMyM7uMdFBg2jYXHC6jxNBRgdcbaCP128dBL7Zddz7Rp/70d8R5Phyiq4OQdVvge/au9TeDn1FriMdkO2LQr6vU6A=
X-Received: by 2002:a5b:9c5:0:b0:6ae:a4f7:ad3b with SMTP id
 y5-20020a5b09c5000000b006aea4f7ad3bmr14189902ybq.11.1663595382256; Mon, 19
 Sep 2022 06:49:42 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 19 Sep 2022 21:49:31 +0800
Message-ID: <CACzn6-U5JR6XKuJQjMRtrDne+voBR0hrjFhx2kW_um1kbaxL5A@mail.gmail.com>
To: "lustre-devel@lists.lustre.org lustre-devel"
 <lustre-devel@lists.lustre.org>
Subject: [lustre-devel] Lustre Server on Arm64 Progress
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
From: Kevin Zhao via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Kevin Zhao <kevin.zhao@linaro.org>
Content-Type: multipart/mixed; boundary="===============0980898555753941378=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============0980898555753941378==
Content-Type: multipart/alternative; boundary="000000000000cf512405e907fba2"

--000000000000cf512405e907fba2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Lustre,

In June we enabled the Lustre Arm64 Server and client CI. And we have built
the Lustre Master branch code RPMs daily and publish the Lustre/e2progsfs
at https://uk.linaro.cloud/repo/

The CI Jenkins Link: http://213.146.155.72:8080/

The CI Management script: https://github.com/Linaro/lustretest

The jobs are daily to grab the code, build RPMs and run the whole test
suite. Now we cover all the tests and recorded at
https://github.com/Linaro/lustretest/blob/main/lustretest/cfg/test-groups.y=
aml


Now Lustre test cases fail on Arm64 is less than 20, we are still WIP to
fix all the test failure.

The Arm64 External CI has already been running for about 3 months, and it=
=E2=80=99s
time for us to think further and do more to make Arm64 official support for
Lustre.

Next step:

   1.

   Gerrit Patch Landing Triagger Arm64 Jobs: Considering our limited
   resources and the expectation about the Lustre code robust on Arm64, we=
=E2=80=99d
   planned to implement the Lustre patch landing CI. The idea is to run the
   Arm64 RPM build and the whole test suite when the patch in gerrit is +2 =
and
   cherry pick to the master branch.
   2.

   Build and store the Lustre packages for special versions(Both for 4K and
   64K page size). Now we just build and store the development release.


Any feedback/advice/help are really appreciated. Look forward to hearing
from you soon. Thanks for the upstream help.

--=20
*Best Regards*

*Kevin Zhao*

Tech Lead, LDCG Cloud Infra & Storage

Linaro Vertical Technologies

IRC(freenode): kevinz

Slack(kubernetes.slack.com): kevinz

kevin.zhao@linaro.org | Mobile/Direct/Wechat:  +86 18818270915

--000000000000cf512405e907fba2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><span id=3D"gmail-docs-internal-guid-b96cfebc-7fff-33a8-5d=
33-e156d4753ea2"><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;ma=
rgin-bottom:0pt"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(=
0,0,0);background-color:transparent;font-variant-numeric:normal;font-varian=
t-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">Hi Lustre=
,</span></p><br><p dir=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;mar=
gin-bottom:0pt"><span style=3D"font-size:11pt;font-family:Arial;color:rgb(0=
,0,0);background-color:transparent;font-variant-numeric:normal;font-variant=
-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">In June we=
 enabled the Lustre Arm64 Server and client CI. And we have built the Lustr=
e Master branch code RPMs daily and publish the Lustre/e2progsfs at </span>=
<a href=3D"https://uk.linaro.cloud/repo/" style=3D"text-decoration-line:non=
e"><span style=3D"font-size:11pt;font-family:Arial;background-color:transpa=
rent;font-variant-numeric:normal;font-variant-east-asian:normal;text-decora=
tion-line:underline;vertical-align:baseline;white-space:pre-wrap">https://u=
k.linaro.cloud/repo/</span></a></p><p dir=3D"ltr" style=3D"line-height:1.38=
;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:11pt;font-famil=
y:Arial;color:rgb(0,0,0);background-color:transparent;font-variant-numeric:=
normal;font-variant-east-asian:normal;vertical-align:baseline;white-space:p=
re-wrap">The CI Jenkins Link: </span><a href=3D"http://213.146.155.72:8080/=
" style=3D"text-decoration-line:none"><span style=3D"font-size:11pt;font-fa=
mily:Arial;background-color:transparent;font-variant-numeric:normal;font-va=
riant-east-asian:normal;text-decoration-line:underline;vertical-align:basel=
ine;white-space:pre-wrap">http://213.146.155.72:8080/</span></a></p><p dir=
=3D"ltr" style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span =
style=3D"font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color=
:transparent;font-variant-numeric:normal;font-variant-east-asian:normal;ver=
tical-align:baseline;white-space:pre-wrap">The CI Management script: </span=
><a href=3D"https://github.com/Linaro/lustretest" style=3D"text-decoration-=
line:none"><span style=3D"font-size:11pt;font-family:Arial;background-color=
:transparent;font-variant-numeric:normal;font-variant-east-asian:normal;tex=
t-decoration-line:underline;vertical-align:baseline;white-space:pre-wrap">h=
ttps://github.com/Linaro/lustretest</span></a></p><p dir=3D"ltr" style=3D"l=
ine-height:1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"font-size:=
11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent;font-v=
ariant-numeric:normal;font-variant-east-asian:normal;vertical-align:baselin=
e;white-space:pre-wrap">The jobs are daily to grab the code, build RPMs and=
 run the whole test suite. Now we cover all the tests and recorded at </spa=
n><a href=3D"https://github.com/Linaro/lustretest/blob/main/lustretest/cfg/=
test-groups.yaml" style=3D"text-decoration-line:none"><span style=3D"font-s=
ize:11pt;font-family:Arial;background-color:transparent;font-variant-numeri=
c:normal;font-variant-east-asian:normal;text-decoration-line:underline;vert=
ical-align:baseline;white-space:pre-wrap">https://github.com/Linaro/lustret=
est/blob/main/lustretest/cfg/test-groups.yaml</span></a></p><p dir=3D"ltr" =
style=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"=
font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transpar=
ent;font-variant-numeric:normal;font-variant-east-asian:normal;vertical-ali=
gn:baseline;white-space:pre-wrap"><br></span><span style=3D"font-size:11pt;=
font-family:Arial;color:rgb(0,0,0);background-color:transparent;font-varian=
t-numeric:normal;font-variant-east-asian:normal;vertical-align:baseline;whi=
te-space:pre-wrap">Now Lustre test cases fail on Arm64 is less than 20, we =
are still WIP to fix all the test failure.</span></p><br><p dir=3D"ltr" sty=
le=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"fon=
t-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transparent=
;font-variant-numeric:normal;font-variant-east-asian:normal;vertical-align:=
baseline;white-space:pre-wrap">The Arm64 External CI has already been runni=
ng for about 3 months, and it=E2=80=99s time for us to think further and do=
 more to make Arm64 official support for Lustre.</span></p><p dir=3D"ltr" s=
tyle=3D"line-height:1.38;margin-top:0pt;margin-bottom:0pt"><span style=3D"f=
ont-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transpare=
nt;font-variant-numeric:normal;font-variant-east-asian:normal;vertical-alig=
n:baseline;white-space:pre-wrap">Next step:</span></p><ol style=3D"margin-t=
op:0px;margin-bottom:0px"><li dir=3D"ltr" style=3D"list-style-type:decimal;=
font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-color:transpar=
ent;font-variant-numeric:normal;font-variant-east-asian:normal;vertical-ali=
gn:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-height:1.38;margi=
n-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=3D"font-size=
:11pt;background-color:transparent;font-variant-numeric:normal;font-variant=
-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">Gerrit Pat=
ch Landing Triagger Arm64 Jobs: Considering our limited resources and the e=
xpectation about the Lustre code robust on Arm64, we=E2=80=99d planned to i=
mplement the Lustre patch landing CI. The idea is to run the Arm64 RPM buil=
d and the whole test suite when the patch in gerrit is +2 and cherry pick t=
o the master branch.</span></p></li><li dir=3D"ltr" style=3D"list-style-typ=
e:decimal;font-size:11pt;font-family:Arial;color:rgb(0,0,0);background-colo=
r:transparent;font-variant-numeric:normal;font-variant-east-asian:normal;ve=
rtical-align:baseline;white-space:pre"><p dir=3D"ltr" style=3D"line-height:=
1.38;margin-top:0pt;margin-bottom:0pt" role=3D"presentation"><span style=3D=
"font-size:11pt;background-color:transparent;font-variant-numeric:normal;fo=
nt-variant-east-asian:normal;vertical-align:baseline;white-space:pre-wrap">=
Build and store the Lustre packages for special versions(Both for 4K and 64=
K page size). Now we just build and store the development release.=C2=A0</s=
pan></p></li></ol></span><div><br></div><div>Any feedback/advice/help are r=
eally appreciated. Look forward to hearing from you soon. Thanks for the up=
stream help.</div><div><br></div>-- <br><div dir=3D"ltr" class=3D"gmail_sig=
nature" data-smartmail=3D"gmail_signature"><div dir=3D"ltr"><div><div dir=
=3D"ltr"><div><div dir=3D"ltr"><div dir=3D"ltr"><b>Best Regards</b><div><di=
v style=3D"margin:0px;padding:0px 0px 20px;width:1262px"><div><div style=3D=
"margin:8px 0px 0px;padding:0px"><div><div dir=3D"ltr"><font><div dir=3D"lt=
r"><div dir=3D"ltr"><p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);=
font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"=
><b><span style=3D"font-size:11pt"><font color=3D"#38761d">Kevin Zhao</font=
></span></b></p><p class=3D"MsoNormal" style=3D"color:rgb(136,136,136);font=
-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:medium"><fo=
nt color=3D"#757b80"><span style=3D"font-size:14.6667px">Tech Lead, LDCG Cl=
oud Infra &amp; Storage</span></font></p><p class=3D"MsoNormal" style=3D"co=
lor:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-se=
rif;font-size:medium"><font color=3D"#757b80"><span style=3D"font-size:14.6=
667px">Linaro Vertical Technologies</span></font></p><p class=3D"MsoNormal"=
 style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoDraft,Helvetica,A=
rial,sans-serif;font-size:medium"><font color=3D"#757b80"><span style=3D"fo=
nt-size:14.6667px">IRC(freenode): kevinz</span></font></p><p class=3D"MsoNo=
rmal"><font color=3D"#757b80"><font color=3D"#888888" face=3D"Roboto, Robot=
oDraft, Helvetica, Arial, sans-serif"><span style=3D"font-size:14.6667px">S=
lack(</span></font><font face=3D"Roboto, RobotoDraft, Helvetica, Arial, san=
s-serif"><span style=3D"font-size:14.6667px"><a href=3D"http://kubernetes.s=
lack.com" target=3D"_blank">kubernetes.slack.com</a>)</span></font><font co=
lor=3D"#888888" face=3D"Roboto, RobotoDraft, Helvetica, Arial, sans-serif">=
<span style=3D"font-size:14.6667px">: kevinz</span></font></font></p><p cla=
ss=3D"MsoNormal" style=3D"color:rgb(136,136,136);font-family:Roboto,RobotoD=
raft,Helvetica,Arial,sans-serif;font-size:medium"><font color=3D"#757b80"><=
span style=3D"font-size:14.6667px"><a href=3D"mailto:kevin.zhao@linaro.org"=
 target=3D"_blank"><span>kevin.zhao@linaro.org</span></a>=C2=A0| Mobile/Dir=
ect/Wechat:=C2=A0 +86 18818270915</span></font><span style=3D"color:rgb(117=
,123,128);font-size:11pt">=C2=A0</span><br></p><div style=3D"color:rgb(136,=
136,136);font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-siz=
e:medium"><span style=3D"color:rgb(117,123,128);font-size:11pt"><br></span>=
</div></div></div></font></div><div style=3D"font-family:Roboto,RobotoDraft=
,Helvetica,Arial,sans-serif;font-size:medium"></div></div></div><div style=
=3D"font-family:Roboto,RobotoDraft,Helvetica,Arial,sans-serif;font-size:med=
ium"></div></div></div></div></div></div></div></div></div></div></div></di=
v>

--000000000000cf512405e907fba2--

--===============0980898555753941378==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0980898555753941378==--
